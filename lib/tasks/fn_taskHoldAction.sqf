/*
Function: MyFunctions_fnc_taskHoldAction
Author: CharlesJohnMcC

Description:
    Creates and manages a task requiring a hold action on an object.
    Sets up interaction with target object, handles task state management,
    and triggers follow-up tasks on completion.

Parameters:
    _targetObject   - Object to interact with [Object, default: objNull]
    _taskData       - Task configuration in format [taskId, parentTaskId] [Array of Strings]
    _taskTitle      - Display title for the task [String]
    _taskDesc       - Detailed description for the task [String]
    _actionText     - Text shown for hold action [String, default: "Interact"]
    _actionDuration - Duration of hold action in seconds [Number, default: 5]
    _actionIcon     - Path to action icon [String, default: "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa"]

Returns:
    Boolean - true if task setup successful, false if failed
             Will return false if:
             - Not called on server
             - Invalid target object provided
             - Invalid taskId format
             - Task creation fails
             - Hold action setup fails

Examples:
    // Search for intel
    _success = [
        _laptop,
        ["searchIntel", "mainTasking"],
        "Search for Intel",
        "Search the laptop for intelligence",
        "Download Intel",
        10,
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa"
    ] call MyFunctions_fnc_taskHoldAction;

    // Mark weapons cache
    _success = [
        _crate,
        ["markCache", "mainTasking"],
        "Mark Cache",
        "Mark the weapons cache for demolition",
        "Plant Beacon",
        5,
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_takeOff1_ca.paa"
    ] call MyFunctions_fnc_taskHoldAction;

Side Effects:
    - Creates new task in mission task system
    - Adds hold action to target object
    - Sets task state on completion
    - Updates task markers on map

Dependencies:
    - MyFunctions_fnc_createTask
    - MyFunctions_fnc_updateTaskState
    - MyFunctions_fnc_addHoldAction

Note:
    Must be called on server side only
    Uses addHoldAction wrapper for simplified interaction setup
*/

if (!isServer) exitWith {
    diag_log "ERROR: taskHoldAction must be called on server";
    false
};

params [
    ["_targetObject", objNull, [objNull]],
    ["_taskData", [], [[]]],
    ["_taskTitle", "", [""]],
    ["_taskDesc", "", [""]],
    ["_actionText", "Interact", [""]],
    ["_actionDuration", 5, [0]],
    ["_actionIcon", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa", [""]]
];

// Validate parameters
if (isNull _targetObject) exitWith {
    diag_log "ERROR: Invalid target object provided";
    false
};

if (_taskTitle isEqualTo "" || _taskDesc isEqualTo "") exitWith {
    diag_log "ERROR: Task title or description empty";
    false
};

_taskID = _taskData select 0;
_parentTaskID = _taskData select 1;

if (_taskId == "") exitWith {
    diag_log "ERROR: Invalid task ID";
    false
};

if (_parentTaskID == "") exitWith {
    diag_log "ERROR: Invalid parent task ID";
    false
};

private _success = [
	west, 
	_taskData, 
	[_taskDesc, _taskTitle], 
	getPos _targetObject, 
	"CREATED", 
	"interact", 
	true
] call MyFunctions_fnc_createTask;

if (_success == "") exitWith {
    diag_log format ["ERROR: Failed to create task: %1", _taskID];
    false
};

// Add hold action
private _actionId = [
    _targetObject,                    // Target object
    _actionText,                      // Action display text
    _actionIcon,                      // Idle icon
    _actionIcon,                      // Progress icon
    "_target distance _this < 10",     // Condition to show action
    "",                                 // Code to run when action starts
    "",                                 // Code to run on progress
    format [
        "
            ['%1', 'SUCCEEDED'] call MyFunctions_fnc_updateTaskState; 
            [['%1', '%2', true], {_this call MyFunctions_fnc_navigator}] remoteExec ['spawn', 2];
            [_target, %3] remoteExec ['BIS_fnc_holdActionRemove', 0, format['%%1_holdAction_%%2', _target, %3]];
        ",
        _taskID, _parentTaskID, "_actionId"
    ], // Code to run on completion
    "",                                 // Code to run on interupt
    _actionDuration,                  // Duration
    1000                             // Priority
] call MyFunctions_fnc_addHoldAction;

diag_log format ["INFO: Task %1 created with hold action", _taskID];
true