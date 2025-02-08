/*
Function: MyFunctions_fnc_taskExtraction
Author: CharlesJohnMcC

Description:
    Creates and manages an extraction task for mission units. Handles smoke marker
    placement, extraction zone trigger setup, and task state management.

Parameters:
    _extractionPosition - Position3D where extraction will occur [Array, default: [0,0,0]]
    _taskData          - Task configuration in format [taskId, parentTaskId] or just taskId [Array|String]
    _taskTitle         - Display title for the task [String, default: "Exfil Exfil Exfil"]
    _taskDesc         - Detailed description for the task [String, default: "Move to the Extraction Point"]

Returns:
    Boolean - true if extraction setup successful, false if failed
             Will return false if:
             - Not called on server
             - Invalid taskId provided
             - Position is invalid

Examples:
    // Basic extraction task
    _success = [[1000,1000,0], "extract1"] call MyFunctions_fnc_taskExtraction;

    // Extraction with parent task
    _success = [[2000,2000,0], ["extract2", "mainTask"], "Hot Extract", "Get to the LZ ASAP"] call MyFunctions_fnc_taskExtraction;

Side Effects:
    - Creates new task in mission task system
    - Spawns red smoke at extraction point
    - Creates trigger for task completion
    - Updates task state when units enter extraction zone

Dependencies:
    - MyFunctions_fnc_createTask
    - MyFunctions_fnc_updateTaskState
    - ACE3 Smoke Effects (optional)

Note:
    Must be called on server side only
*/

if (!isServer) exitWith {
    diag_log "ERROR: taskExtraction must be called on server";
    false
};

params [
    ["_extractionPosition", [0,0,0], []],
    ["_taskData", [], []],
    ["_taskTitle", "Exfil Exfil Exfil", [""]],
    ["_taskDesc", "Move to the Extraction Point", [""]]
];

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
    false
};

// Create extraction task
private _moveTask = [
    west,
    _taskData,
    [_taskDesc, _taskTitle],
    _extractionPosition,
    "CREATED",
    "run",
    true
] call MyFunctions_fnc_createTask;

if (_moveTask == "") exitWith {
    diag_log "ERROR: Failed to create extraction task";
    false
};

// Spawn extraction marker with proper variable storage
private _smoke = [_extractionPosition, "RED", true, "extractionSmoke" + _taskId] call MyFunctions_fnc_spawnSmoke;
if (isNull _smoke) then {
    diag_log "ERROR: Failed to spawn extraction smoke";
};

// Create extraction trigger with proper smoke deletion
private _trigger = [
    "extractionTrigger" + _taskId,
    _extractionPosition,
    [10,10],
    "WEST",
    "PRESENT",
    "this",
    format [
        "
            ['%1', 'SUCCEEDED'] call MyFunctions_fnc_updateTaskState; 
            ['Mission Complete!'] call MyFunctions_fnc_sendGlobalChatMessage; 
            ['extractionSmoke%1'] call MyFunctions_fnc_deleteSmoke; 
            [['%1', '', true], 'MyFunctions_fnc_navigator'] remoteExec ['call', 2];
        ",
    _taskId]
] call MyFunctions_fnc_createTrigger;

if (isNull _trigger) exitWith {
    diag_log "ERROR: Failed to create extraction trigger";
    false
};

diag_log "Extraction task setup complete";
true