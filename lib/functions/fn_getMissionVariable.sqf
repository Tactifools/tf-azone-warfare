/*
Function: MyFunctions_fnc_getMissionVariable
Author: CharlesJohnMcC

Description:
    Gets a variable from the mission namespace with optional default value.
    Includes debug logging and parameter validation.

Parameters:
    _varName       - Name of the variable to get [String]
    _defaultValue  - Optional default value if variable not found [Any]

Returns:
    Any - The value of the variable, or default value if not found
        Returns nil if:
        - Empty variable name provided
        - Variable not found and no default value set
        - Error in variable retrieval

Examples:
    // Basic variable retrieval
    _value = ["varName"] call MyFunctions_fnc_getMissionVariable;

    // With default value
    _value = ["playerScore", 0] call MyFunctions_fnc_getMissionVariable;

    // Array default value
    _value = ["enemyPositions", []] call MyFunctions_fnc_getMissionVariable;

Side Effects:
    - Logs variable retrieval attempts
    - Logs errors for invalid parameters
    - Logs retrieved values for debugging

Dependencies:
    - None (uses engine missionNamespace)

Note:
    Debug logging enabled for all operations
    Supports all variable types
*/

params [
    ["_varName", "", [""]],
    ["_defaultValue", nil, []]
];

// Exit if invalid variable name
if (_varName == "") exitWith {
    diag_log "ERROR: Empty variable name provided to getMissionVariable";
    nil
};

diag_log format ["Getting mission variable: %1", _varName];

private _value = missionNamespace getVariable [_varName, _defaultValue];

diag_log format ["Mission variable retrieved: %1 = %2", _varName, _value];

_value