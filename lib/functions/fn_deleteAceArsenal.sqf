/*
Function: MyFunctions_fnc_deleteAceArsenal
Author: CharlesJohnMcC

Description:
    Deletes an ACE Arsenal box and cleans up associated variables.
    Handles network synchronization and mission namespace cleanup.

Parameters:
    _variableName - Variable name of the arsenal box [String]
                  Must be non-empty and exist in missionNamespace

Returns:
    Boolean - True if deletion successful, false if:
            - Empty variable name provided
            - Box not found in missionNamespace
            - Deletion fails

Examples:
    // Delete basic arsenal box
    _success = ["myArsenalBox"] call MyFunctions_fnc_deleteAceArsenal;

    // Delete specific arsenal with error handling
    if (!["ace_arsenal_main"] call MyFunctions_fnc_deleteAceArsenal) then {
        diag_log "Failed to delete main arsenal";
    };

Side Effects:
    - Deletes physical arsenal object
    - Removes mission namespace variable
    - Broadcasts deletion to all clients
    - Logs operation result

Dependencies:
    - ACE Arsenal
    - CBA Events (optional)

Note:
    Must be called on server
    Handles JIP cleanup automatically
*/

params [["_variableName", "", [""]]];

// Exit if invalid variable name
if (_variableName == "") exitWith {
    diag_log "ERROR: Empty variable name provided to deleteAceArsenal";
    false
};

// Retrieve the reference to the arsenal from missionNamespace
private _arsenalBox = missionNamespace getVariable [_variableName, objNull];

// Check if the arsenal box exists
if (!isNull _arsenalBox) then {
    // Delete the vehicle (synchronized across network)
    deleteVehicle _arsenalBox;
    
    // Clean up mission namespace
    missionNamespace setVariable [_variableName, nil, true];
    
    diag_log format ["ACE Arsenal box '%1' deleted successfully", _variableName];
    true
} else {
    diag_log format ["ACE Arsenal box '%1' not found", _variableName];
    false
};