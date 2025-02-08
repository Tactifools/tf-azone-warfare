/*
Function: MyFunctions_fnc_createTask
Author: CharlesJohnMcC

Description:
    Creates and assigns a task to specified side with network synchronization.
    Handles task creation, marker placement, and state management.

Parameters:
    _side                 - Side to assign task to [Side - west/east/resistance/civilian]
    _taskData            - Task ID or [taskID, parentTaskID] [String or Array]
    _taskDetails         - Array of [title, description, marker] [Array]
    _position            - Position where to create task [x,y,z] [Array]
    _state              - Initial state ["CREATED","ASSIGNED","SUCCEEDED","FAILED","CANCELED"] [String]
    _taskType           - Type of task icon ["default","attack","defend","meet"] [String]
    _shareDestination   - Share task destination marker [Boolean, default: true]

Returns:
    String - Task ID of created task
            Returns empty string if:
            - Invalid side provided
            - Invalid task data
            - Invalid task details
            - Invalid position
            - Invalid state
            - Invalid task type

Examples:
    // Basic task creation
    _taskID = [
        west,
        "task_001",
        ["Secure Area", "Clear and secure the marked area", "secure1"],
        getMarkerPos "objective_1",
        "ASSIGNED",
        "attack",
        true
    ] call MyFunctions_fnc_createTask;

    // Subtask with parent
    _subtaskID = [
        west,
        ["subtask_1", "mainTask"],
        ["Clear Building", "Clear the marked building of hostiles", "clear1"],
        getPosASL _building,
        "CREATED",
        "search",
        true
    ] call MyFunctions_fnc_createTask;

Side Effects:
    - Creates task in mission task system
    - Creates task marker if position provided
    - Broadcasts to all clients
    - Updates task menu for specified side
    - Adds to JIP queue

Dependencies:
    - BIS_fnc_taskCreate
    - CBA Events (optional)
    
Note:
    Must be called on server
    All parameters validated before task creation
    Network synchronized
*/

params [
    ["_side", sideUnknown, [west]],
    ["_taskData", "", ["", []]],
    ["_taskDetails", [], [[]], 2],
    ["_position", [], [[]], 3],
    ["_state", "", [""]],
    ["_taskType", "default", ["default"]],
    ["_shareTaskDestination", true, [true, false]]
];

// Validate parameters
if (_side == sideUnknown) exitWith {
    diag_log "ERROR: Invalid side provided to createTask";
    ""
};

// Extract taskId and parentId
private _taskId = if (_taskData isEqualType []) then {
    if (count _taskData != 2) exitWith {
        diag_log "ERROR: Task data array must contain [taskId, parentTaskId]";
        "";
    };
    _taskData select 0
} else {
    _taskData
};

private _parentTaskId = if (_taskData isEqualType []) then { _taskData select 1 } else { "" };

if (_taskId == "") exitWith {
    diag_log "ERROR: Invalid task ID";
    ""
};

if (count _taskDetails != 2) exitWith {
    diag_log "ERROR: Task details must contain [title, description, marker]";
    ""
};

if (_position isEqualTo []) exitWith {
    diag_log "ERROR: Invalid position provided to createTask";
    ""
};

if !(_state in ["CREATED", "ASSIGNED", "SUCCEEDED", "FAILED", "CANCELED"]) exitWith {
    diag_log format ["ERROR: Invalid task state: %1", _state];
    ""
};

if !(_taskType in [
    // Actions
    "attack", "danger", "default", "defend", "destroy", "download", "exit",
    "getin", "getout", "heal", "interact", "kill", "land", "listen", "meet",
    "move", "move1", "move2", "move3", "move4", "move5", "navigate", "rearm",
    "refuel", "repair", "run", "scout", "search", "takeoff", "talk", "talk1",
    "talk2", "talk3", "talk4", "talk5", "target", "upload", "use", "wait", "walk",
    
    // Objects
    "armor", "backpack", "boat", "box", "car", "container", "documents", "heli",
    "intel", "map", "mine", "plane", "radio", "rifle", "whiteboard",
    
    // Letters
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
]) exitWith {
    diag_log format ["ERROR: Invalid task type: %1", _taskType];
    ""
};

diag_log format ["Creating task: %1, %2, %3, %4, %5", _side, _taskID, _taskDetails, _position, _state];

private _task = [
    _side,                          // Side
    [_taskId, _parentTaskId],       // Task ID, or ["taskID", "parentTaskID"]
    _taskDetails,                   // Task description and title
    _position,                      // Task position
    _state,                         // Task state
    -1,                             // Priority
    true,                           // Show notification
    _taskType,                      // Task type
    _shareTaskDestination           // Share task destination
] call BIS_fnc_taskCreate;

// Set the task destination marker
if (_shareTaskDestination) then {
    [_taskID, _position] call BIS_fnc_taskSetDestination;
};

diag_log format ["Task created: %1", _task];

// Return the task ID
_taskID