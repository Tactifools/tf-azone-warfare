/*
Function: MyFunctions_fnc_sendSideChatMessageToSide
Author: CharlesJohnMcC

Description:
    Sends a message to players of a specific side in side chat.
    Handles network synchronization and logging.

Parameters:
    _message - Message to send [String]
             Must be non-empty string
    _side   - Side to send to [Side - west/east/resistance/civilian]
             Must be valid side

Returns:
    Boolean - True if message sent successfully, false if:
            - Empty message provided
            - Invalid side provided
            - Network sync fails
            - Remote execution fails

Examples:
    // Basic message to BLUFOR
    ["Enemy spotted!", west] call MyFunctions_fnc_sendSideChatMessageToSide;

    // Status update to OPFOR with error handling
    if (!["Mission complete", east] call MyFunctions_fnc_sendSideChatMessageToSide) then {
        diag_log "Failed to send message to OPFOR";
    };

    // Formatted message to INDFOR
    [format["Objective %1 complete", _objectiveNum], resistance] call MyFunctions_fnc_sendSideChatMessageToSide;

Side Effects:
    - Displays message to players on specified side
    - Logs message content and recipient side
    - Creates network traffic
    - Updates chat history

Dependencies:
    - None (uses engine chat system)

Note:
    Can be called from any machine
    Messages synchronized across network
    Uses sideChat for side-specific communication
    Performance impact scales with player count
    Debug logging enabled for all operations
*/

params [
    ["_message", "", [""]],
    ["_side", sideUnknown, [west]]
];

// Exit if invalid message
if (_message == "") exitWith {
    diag_log "ERROR: Empty message provided to sendSideChatMessageToSide";
    false
};

// Exit if invalid side
if (_side == sideUnknown) exitWith {
    diag_log "ERROR: Invalid side provided to sendSideChatMessageToSide";
    false
};

diag_log format ["Sending side chat message to %1: %2", _side, _message];

// Send message using remoteExec to specified side
if (![_message] remoteExec ["sideChat", _side]) exitWith {
    diag_log format ["ERROR: Failed to send side chat message to %1: %2", _side, _message];
    false
};

diag_log format ["Side chat message sent to %1: %2", _side, _message];
true