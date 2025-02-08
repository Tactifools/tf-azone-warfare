/*
Function: MyFunctions_fnc_sendSideChatMessage
Author: CharlesJohnMcC

Description:
    Sends a message to all players in side chat.
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
    ["Enemy spotted!"] call MyFunctions_fnc_sendSideChatMessage;

    // Mission status with error handling
    if (!["Mission complete"] call MyFunctions_fnc_sendSideChatMessage) then {
        diag_log "Failed to send side message";
    };

    // Formatted message
    [format["Objective %1 complete", _objectiveNum]] call MyFunctions_fnc_sendSideChatMessage;

Side Effects:
    - Displays message to all players on same side
    - Logs message content
    - Creates network traffic
    - Updates chat history

Dependencies:
    - None (uses engine chat system)

Note:
    Can be called from any machine
    Messages are synchronized across network
    Uses sideChat for side-specific communication
    Debug logging enabled
*/

params [["_message", "", [""]]];

// Exit if invalid message
if (_message == "") exitWith {
    diag_log "ERROR: Empty message provided to sendSideChatMessage";
    false
};

diag_log format ["Sending side chat message: %1", _message];

// Send message using remoteExec to ensure it appears for all players
private _result = [_message] remoteExec ["sideChat", 0];

// Check if message was sent successfully
if (_result) then {
    diag_log format ["Side chat message sent: %1", _message];
    true
} else {
    diag_log "ERROR: Failed to send side chat message";
    false
};