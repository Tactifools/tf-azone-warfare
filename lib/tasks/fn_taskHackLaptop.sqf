/*
Function: MyFunctions_fnc_taskHackLaptop
Author: CharlesJohnMcC

Description:
    Creates and manages a laptop hacking task with texture changes.
    Sets up interaction with laptop, manages screen textures,
    and triggers follow-up tasks on successful hack.

Parameters:
    _laptopObject      - Laptop to hack [Object, default: objNull]
    _taskData         - Task configuration [taskId, parentTaskId] [Array]
    _taskTitle        - Display title for task [String]
    _taskDesc         - Task description [String]
    _actionText       - Hold action text [String, default: "Hack"]
    _actionDuration   - Hold action duration [Number, default: 5]
    _actionIcon       - Action icon path [String]
    _defaultTexture   - Default laptop screen texture [String]
    _inProgressTexture - Hacking in progress texture [String]
    _completedTexture - Hack complete texture [String]

Returns:
    Boolean - true if task setup successful, false if failed
             Will return false if:
             - Not called on server
             - Invalid laptop object
             - Invalid task data
             - Task creation fails
             - Hold action setup fails

Examples:
    // Basic laptop hack
    _success = [
        _laptop,
        ["hackSystem", "intelTasking"],
        "Hack System",
        "Access the enemy network",
        "Hack System",
        10,
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
        "textures\screen_default.paa",
        "textures\screen_hacking.paa",
        "textures\screen_complete.paa"
    ] call MyFunctions_fnc_taskHackLaptop;

Side Effects:
    - Creates task in mission system
    - Updates laptop screen textures
    - Creates hold action on laptop
    - Updates task state on completion
    - Triggers next task via navigator
    - Network synchronizes texture changes

Dependencies:
    - MyFunctions_fnc_createTask
    - MyFunctions_fnc_addHoldAction
    - MyFunctions_fnc_updateTaskState
    - MyFunctions_fnc_navigator
*/

if (!isServer) exitWith {
    diag_log "ERROR: taskHoldAction must be called on server";
    false
};

params [
    ["_laptopObject", objNull, [objNull]],
    ["_taskData", [], [[]]],
    ["_taskTitle", "", [""]],
    ["_taskDesc", "", [""]],
    ["_actionText", "Interact", [""]],
    ["_actionDuration", 5, [0]],
    ["_actionIcon", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa", [""]],
    ["_defaultTexture", "textures\radioTower.paa", [""]],
    ["_inProgressTexture", "textures\hackInProgress.paa", [""]],
    ["_completedTexture", "textures\hacked.paa", [""]]
];

// Validate parameters
if (isNull _laptopObject) exitWith {
    diag_log "ERROR: Invalid target object provided";
    false
};

_laptopObject setObjectTextureGlobal [1, _defaultTexture];

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
	getPos _laptopObject, 
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
    _laptopObject,                    // Target object
    _actionText,                      // Action display text
    _actionIcon,                      // Idle icon
    _actionIcon,                      // Progress icon
    "_target distance _this < 5",     // Condition to show action
    format ["_target setObjectTextureGlobal [1, '%1'];", _defaultTexture],  // Start
    format ["_target setObjectTextureGlobal [1, '%1'];", _inProgressTexture],  // Progress
    format [
        "
            ['%1', 'SUCCEEDED'] call MyFunctions_fnc_updateTaskState; 
            [['%1', '%2', true], {_this call MyFunctions_fnc_navigator}] remoteExec ['spawn', 2]; 
            _target setObjectTextureGlobal [1, '%3'];
            [_target, %4] remoteExec ['BIS_fnc_holdActionRemove', 0, format['%%1_holdAction_%%2', _target, %4]];
        ", 
        _taskID, _parentTaskID, _completedTexture, "_actionId"
    ], // Completion
    format ["_target setObjectTextureGlobal [1, '%1'];", _defaultTexture],  // Interrupt
    _actionDuration,                  // Duration
    1000                             // Priority
] call MyFunctions_fnc_addHoldAction;

diag_log format ["INFO: Task %1 created with hold action", _taskID];
true