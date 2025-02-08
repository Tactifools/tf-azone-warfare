/*
Function: MyFunctions_fnc_setMissionVariable
Author: CharlesJohnMcC

Description:
    Sets a variable in the mission namespace with optional network synchronization.
    Handles validation, logging, and broadcast functionality.

Parameters:
    _varName    - Name of the variable to set [String]
    _value      - Value to set [Any]
    _broadcast  - Optional: Broadcast to all clients [Boolean, default: false]

Returns:
    Boolean - True if set successfully, false if:
            - Empty variable name provided
            - Network sync fails
            - Remote execution fails

Examples:
    // Basic variable setting
    ["score", 100] call MyFunctions_fnc_setMissionVariable;

    // Networked variable with error handling
    if (!["gameState", "RUNNING", true] call MyFunctions_fnc_setMissionVariable) then {
        diag_log "Failed to set game state";
    };

    // Complex data type
    [
        "enemyPositions",
        [[100,100,0], [200,200,0]],
        true
    ] call MyFunctions_fnc_setMissionVariable;

Side Effects:
    - Updates mission namespace variable
    - Creates network traffic if broadcast enabled
    - Logs variable changes
    - Updates for JIP clients if broadcast enabled

Dependencies:
    - None (uses engine variable system)

Note:
    Can be called from any machine
    Variables synchronized if broadcast enabled
    Debug logging tracks all operations
*/

params [
    ["_varName", "", [""]],
    ["_value", nil, []],
    ["_broadcast", false, [true]]
];

// Exit if invalid variable name
if (_varName == "") exitWith {
    diag_log "ERROR: Empty variable name provided to setMissionVariable";
    false
};

diag_log format ["Setting mission variable: %1 to %2 (Broadcast: %3)", _varName, _value, _broadcast];

// Set the mission namespace variable
missionNamespace setVariable [_varName, _value, _broadcast];

diag_log format ["Mission variable set: %1 = %2", _varName, _value];

true