/*
Function: MyFunctions_fnc_deleteSmoke
Author: CharlesJohnMcC

Description:
    Deletes a smoke effect created by fn_spawnSmoke. Handles both persistent
    and non-persistent smoke cleanup.

Parameters:
    _variableName - Variable name storing smoke references [String]

Returns:
    Boolean - True if deletion successful, false if:
            - Not called on server
            - Empty variable name provided
            - Smoke variable not found

Examples:
    // Delete LZ smoke
    _success = ["lz_smoke"] call MyFunctions_fnc_deleteSmoke;

    // With error handling
    if (!["smoke_signal"] call MyFunctions_fnc_deleteSmoke) then {
        diag_log "Failed to delete smoke signal";
    };

Dependencies:
    None

Note:
    - Must be called on server
    - Handles cleanup of both smoke shell and spawn handle for persistent smoke
    - Variable is cleared from missionNamespace after cleanup
*/

if (!isServer) exitWith {
    _this remoteExec ["MyFunctions_fnc_deleteSmoke", 2];
    diag_log "ERROR: deleteSmoke must be called on server";
    false
};

params [["_variableName", "", [""]]];

if (_variableName == "") exitWith {
    diag_log "ERROR: No variable name provided to deleteSmoke";
    false
};

private _smokeArray = missionNamespace getVariable [_variableName, []];

if (_smokeArray isEqualTo []) exitWith {
    diag_log format ["ERROR: Smoke module '%1' not found", _variableName];
    false
};

// First terminate the spawn handle if it exists
if (count _smokeArray > 1) then {
    terminate (_smokeArray select 1);
};

// Then delete ALL smoke shells in the area
private _originalPos = getPosATL (_smokeArray select 0);

{
    deleteVehicle _x;
} forEach (nearestObjects [_originalPos, [
    "SmokeShell",
    "SmokeShellRed",
    "SmokeShellGreen", 
    "SmokeShellYellow",
    "SmokeShellPurple",
    "SmokeShellOrange"
], 30]);  // Increased from 2m to 30m to match trigger radius

// Ensure variable is cleared globally
missionNamespace setVariable [_variableName, nil, true];

diag_log format ["Smoke effect '%1' deleted and all nearby smoke cleared", _variableName];

true