/*
Function: MyFunctions_fnc_updateTaskState
Author: CharlesJohnMcC

Description:
    Updates the state of an existing task and synchronizes across network.
    Handles validation, network sync, and logging.

Parameters:
    _taskID - Task identifier [String]
             Must be existing task ID
    _state  - New task state [String]
             Valid states:
             - "CREATED"  : Task exists but not yet assigned
             - "ASSIGNED" : Task is active and assigned to players
             - "SUCCEEDED": Task completed successfully
             - "FAILED"   : Task failed to complete
             - "CANCELED" : Task abandoned or cancelled

Returns:
    Boolean - True if state updated successfully, false if:
            - Invalid task ID provided
            - Invalid state provided
            - Task doesn't exist
            - Network sync fails

Examples:
    // Basic state update
    ["task_001", "SUCCEEDED"] call MyFunctions_fnc_updateTaskState;

    // With error handling
    if (!["killHVT", "FAILED"] call MyFunctions_fnc_updateTaskState) then {
        diag_log "Failed to update HVT task state";
    };

Side Effects:
    - Updates task state in mission system
    - Broadcasts to all clients
    - Updates task UI for all players
    - Triggers task notifications
    - Logs state change to RPT

Dependencies:
    - BIS_fnc_taskSetState

Note:
    Can be called from any machine
    Changes synchronized across network
    Debug logging enabled
*/

params [
    ["_taskID", "", [""]],
    ["_state", "", [""]]
];

// Validate parameters
if (_taskID == "") exitWith {
    diag_log "ERROR: Invalid task ID provided to updateTaskState";
    false
};

private _validStates = ["CREATED", "ASSIGNED", "SUCCEEDED", "FAILED", "CANCELED"];
if !(_state in _validStates) exitWith {
    diag_log format ["ERROR: Invalid task state: %1. Valid states are: %2", _state, _validStates];
    false
};

diag_log format ["Updating task state: %1 to %2", _taskID, _state];

// Update task state using BIS function directly
[_taskID, _state, true] call BIS_fnc_taskSetState;

diag_log format ["Task state updated: %1 to %2", _taskID, _state];