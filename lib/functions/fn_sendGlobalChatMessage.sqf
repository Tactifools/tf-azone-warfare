/*
Function: MyFunctions_fnc_sendGlobalChatMessage
Author: CharlesJohnMcC

Description:
    Sends a message to all players in global chat.
    Handles network synchronization and logging.

Parameters:
    _message - Message to send [String]
             Must be non-empty string

Returns:
    Boolean - True if message sent successfully, false if:
            - Empty message provided
            - Network sync fails
            - Remote execution fails

Examples:
    // Basic message
    ["Enemy spotted!"] call MyFunctions_fnc_sendGlobalChatMessage;

    // Mission status update
    ["Mission complete"] call MyFunctions_fnc_sendGlobalChatMessage;

    // With error handling
    if (!["Reinforcements arriving"] call MyFunctions_fnc_sendGlobalChatMessage) then {
        diag_log "Failed to send global message";
    };

Side Effects:
    - Displays message to all players
    - Logs message content
    - Creates network traffic
    - Updates chat history

Dependencies:
    - None (uses engine chat system)

Note:
    Can be called from any machine
    Messages are synchronized across network
    Uses systemChat for reliability
    Debug logging enabled
*/

params [["_message", "", [""]]];

if (_message == "") exitWith {
    diag_log "ERROR: Empty message provided to sendGlobalChatMessage";
    false
};

diag_log format ["Sending global chat message: %1", _message];

private _result = _message remoteExec ["systemChat", 0, true];

if (isNil "_result") exitWith {
    diag_log "ERROR: Failed to send global chat message";
    false
};

diag_log format ["Global chat message sent: %1", _message];
true