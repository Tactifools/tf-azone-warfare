/*
Function: MyFunctions_fnc_grantMissionReward
Author: CharlesJohnMcC

Description:
    Grants appropriate rewards based on task completion.
    Handles arsenal updates and variable synchronization.

Parameters:
    _currentTask - Task ID that was completed [String]
                  Must be valid task ID from mission tasks

Returns:
    Boolean - True if reward granted successfully, false if:
             - Not called on server
             - Empty task ID provided
             - Invalid task ID provided
             - Reward items not found
             - Arsenal update fails

Examples:
    // Basic reward grant
    ["taskKillHVT"] call MyFunctions_fnc_grantMissionReward;

    // With error handling
    if (!["taskSearchIntel"] call MyFunctions_fnc_grantMissionReward) then {
        diag_log "Failed to grant mission reward";
    };

Side Effects:
    - Updates ACE Arsenal contents
    - Modifies active_arsenal_items
    - Broadcasts arsenal changes to clients
    - Logs reward distribution

Dependencies:
    - MyFunctions_fnc_updateAceArsenal
    - ACE3 Arsenal

Note:
    Must be called on server only
    Debug logging enabled
*/

params [
    ["_currentTask", "", [""]]
];

if (!isServer) exitWith {
    diag_log "ERROR: grant mission reward must be called on server";
    false
};

if (_currentTask == "") exitWith {
    diag_log "ERROR: No current task provided to grant mission reward";
    false
}; 

diag_log format ["Starting mission reward grant for task: %1", _currentTask];

// Reward configurations
private _rewardConfigs = createHashMapFromArray [
    ["alpha_officer", "alpha_arsenal_reward"],
    ["bravo_officer", "bravo_arsenal_reward"],
    ["charlie_officer", "charlie_arsenal_reward"]
];

// Helper function to update arsenal
private _fnc_updateArsenalWithReward = {
    params ["_rewardVar"];
    
    private _rewardItems = missionNamespace getVariable [_rewardVar, []];
    if !(count _rewardItems > 0) exitWith {
        diag_log format ["ERROR: Failed to retrieve %1", _rewardVar];
        false
    };
    
    private _currentItems = missionNamespace getVariable ["active_arsenal_items", []];
    _currentItems append _rewardItems;
    
    private _updatedArsenal = [[13284.9,13751.4,0], _currentItems, "player_arsenal", "C_IDAP_supplyCrate_F"] call MyFunctions_fnc_updateAceArsenal;
    if (!isNull _updatedArsenal) then {
        missionNamespace setVariable ["active_arsenal_items", _currentItems, true];
        diag_log format ["INFO: Updated arsenal with %1", _rewardVar];
        true
    };
    false
};

// Main reward logic
private _rewardVar = _rewardConfigs getOrDefault [_currentTask, ""];
if (_rewardVar != "") then {
    private _result = [_rewardVar] call _fnc_updateArsenalWithReward;
    _result
} else {
    diag_log format ["ERROR: Unknown task: %1 - cannot grant mission reward", _currentTask];
    false
};

// Ensure the function returns a boolean value
true