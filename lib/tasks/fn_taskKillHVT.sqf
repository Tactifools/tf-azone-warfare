/*
Function: MyFunctions_fnc_taskKillHVT
Author: CharlesJohnMcC

Description:
    Creates and manages an HVT elimination task. Handles target tracking,
    task state management, and completion validation.

Parameters:
    _hvtObject    - Target unit to eliminate [Object, default: objNull]
    _taskData     - Task configuration in format [taskId, parentTaskId] [Array of Strings]
    _taskTitle    - Display title for the task [String, default: "Eliminate HVT"]
    _taskDesc     - Detailed description for the task [String, default: "Locate and eliminate the high value target"]

Returns:
    Boolean - true if HVT task setup successful, false if failed
             Will return false if:
             - Not called on server
             - Invalid HVT object provided
             - Invalid taskId format
             - Task creation fails

Examples:
    // Basic HVT task
    _success = [_targetOfficer, ["killHVT1", "mainTasking"]] call MyFunctions_fnc_taskKillHVT;

    // HVT task with parent task
    _success = [_targetOfficer, ["killHVT2", "mainMission"], "Eliminate Officer", "Find and eliminate the enemy commander"] call MyFunctions_fnc_taskKillHVT;

Side Effects:
    - Creates new task in mission task system
    - Adds event handler to HVT unit
    - Updates task state on HVT death
    - May create map markers (if enabled)

Dependencies:
    - MyFunctions_fnc_createTask
    - MyFunctions_fnc_updateTaskState
    - CBA Events (optional)

Note:
    Must be called on server side only
*/

if (!isServer) exitWith {
    diag_log "ERROR: taskKillHVT must be called on server";
    false
};

params [
    ["_hvtObject", objNull, [objNull]],
    ["_taskData", [], []],
    ["_taskTitle", "Eliminate HVT", [""]],
    ["_taskDesc", "Locate and eliminate the high value target", [""]]
];

if (isNull _hvtObject) exitWith {
    diag_log "ERROR: HVT object not found!";
    false
};

_taskID = _taskData select 0;
_parentTaskID = _taskData select 1;

if (_taskID == "") exitWith {
    diag_log "ERROR: Invalid task ID";
    false
};

if (_parentTaskID == "") exitWith {
    diag_log "ERROR: Invalid parent task ID";
    false
};

diag_log format ["Creating %1 task", _taskID];

if (!alive _hvtObject) exitWith {
    diag_log format ["HVT already dead, auto-completing task: %1", _taskID];
    
    private _killTask = [
        west,
        _taskData,
        [_taskDesc, _taskTitle],
        getPos _hvtObject,
        "SUCCEEDED",
        "kill", 
        true
    ] call MyFunctions_fnc_createTask;
    
    ["HVT Already Eliminated"] call MyFunctions_fnc_sendGlobalChatMessage;
    [[_taskID, _parentTaskID, true], {_this call MyFunctions_fnc_navigator}] remoteExec ['spawn', 2];
    true
};

private _killTask = [
    west,
    _taskData,
    [_taskDesc, _taskTitle],
    getPos _hvtObject,
    "CREATED",
    "kill", 
    true
] call MyFunctions_fnc_createTask;

if (_killTask == "") exitWith {
    diag_log format ["ERROR: Failed to create kill HVT task: %1", _taskID];
    false
};

diag_log format ["Kill HVT task created: %1", _killTask];

// Store task IDs in object namespace for event handler access
_hvtObject setVariable ["taskID", _taskID];
_hvtObject setVariable ["parentTaskID", _parentTaskID];

_hvtObject addEventHandler ["Killed", {
    params ["_unit", "_killer"];
    private _taskID = _unit getVariable "taskID";
    private _parentTaskID = _unit getVariable "parentTaskID";
    
    diag_log format ["HVT killed by %1, updating %2 to SUCCEEDED", name _killer, _taskID];
    [_taskID, "SUCCEEDED"] call MyFunctions_fnc_updateTaskState;
    ["HVT Eliminated"] call MyFunctions_fnc_sendGlobalChatMessage;
    [[_taskID, _parentTaskID, true], {_this call MyFunctions_fnc_navigator}] remoteExec ['spawn', 2];
}];

true