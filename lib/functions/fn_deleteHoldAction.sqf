/*
Function: MyFunctions_fnc_deleteHoldAction
Author: CharlesJohnMcC

Description:
    Removes a hold action from a specified object.
    Executes the removal across all clients using remoteExec.

Parameters:
    _targetObject - Object to remove the hold action from [Object, default: objNull]
    _actionId     - ID of the action to remove [String]

Returns:
    Boolean - true if deletion successful, false if validation fails
             Will return false if:
             - Invalid target object provided
             - Empty action ID provided

Examples:
    // Remove a hold action from an object
    _success = [_laptop, "searchAction"] call MyFunctions_fnc_deleteHoldAction;

Side Effects:
    - Removes hold action from target object across all clients

Dependencies:
    None

Note:
    Can be called from any machine, will propagate to all clients
*/

params [
    ["_targetObject", objNull, [objNull]],
    ["_actionId", "", [""]]
];

// Validate parameters
if (isNull _targetObject) exitWith {
    diag_log "ERROR: Invalid target object provided";
    false
};

if (_actionId isEqualTo "") exitWith {
    diag_log "ERROR: Action ID empty";
    false
};

[_targetObject, _actionId] remoteExec ["MyFunctions_fnc_deleteHoldAction", 0, true];