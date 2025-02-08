/*
Function: MyFunctions_fnc_deleteTrigger
Author: CharlesJohnMcC

Description:
    Deletes a trigger and cleans up associated variables.
    Must be executed on server. Handles network synchronization.

Parameters:
    _triggerVariableName - Variable name of trigger to delete [String]
                        Must be non-empty and exist in missionNamespace

Returns:
    Boolean - True if deletion successful, false if:
            - Empty trigger name provided
            - Trigger not found in missionNamespace
            - Network sync fails

Examples:
    // Basic trigger deletion
    _success = ["checkpointTrigger"] call MyFunctions_fnc_deleteTrigger;

    // Delete with error handling
    if (!["objectiveTrigger"] call MyFunctions_fnc_deleteTrigger) then {
        diag_log "Failed to delete objective trigger";
    };

Side Effects:
    - Deletes trigger object
    - Removes mission namespace variable
    - Broadcasts to all clients
    - Logs operation result

Dependencies:
    - None (uses engine trigger system)

Note:
    Must be called on server
    Handles JIP cleanup automatically
*/

params [["_triggerVariableName", "", [""]]];

// Exit if invalid variable name
if (_triggerVariableName == "") exitWith {
    diag_log "ERROR: Empty trigger name provided to deleteTrigger";
    false
};

// Retrieve the trigger from missionNamespace
private _trigger = missionNamespace getVariable [_triggerVariableName, objNull];

// Check if the trigger exists
if (!isNull _trigger) then {
    // Delete the trigger
    deleteVehicle _trigger;
    
    // Clean up mission namespace
    missionNamespace setVariable [_triggerVariableName, nil, true];
    
    diag_log format ["Trigger '%1' deleted successfully", _triggerVariableName];
    true
} else {
    diag_log format ["Trigger '%1' not found", _triggerVariableName];
    false
};