/*
 * Mission Initialization Script
 * Author: CharlesJohnMcC
 * 
 * Description:
 * Executes on all machines when mission starts.
 * Handles mission briefing and initial chat notifications.
 * 
 * Execution Order:
 * 1. init.sqf (this file)
 * 2. briefing.sqf
 * 3. Server-side initialization (if server)
 * 
 * Dependencies:
 * - mission\briefing.sqf
 * - MyFunctions_fnc_sendGlobalChatMessage
 */

diag_log "INFO: Starting mission initialization script";

if (isServer) then {
    server_initialized = false;
    publicVariable "server_initialized";
};

// Initialize mission briefing
if (hasInterface) then {
    waitUntil {!isNull player};
    execVM "mission\briefing.sqf";
};

// Send global init message
["Global Init"] call MyFunctions_fnc_sendGlobalChatMessage;

// Log initialization
diag_log "INFO: Mission init.sqf completed";

diag_log "INFO: Mission initialization script complete";