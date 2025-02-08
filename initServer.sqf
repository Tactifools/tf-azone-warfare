/*
 * Server Initialization Script
 * Author: CharlesJohnMcC
 * 
 * Description:
 * Server-side initialization entry point. Executes only on server.
 * Handles core server setup and mission initialization.
 * 
 * Execution Order:
 * 1. Server validation
 * 2. Global init message
 * 3. Server initialization
 * 4. Error handling
 * 
 * Dependencies:
 * - MyFunctions_fnc_initServer
 * - MyFunctions_fnc_sendGlobalChatMessage
 */

if (!isServer) exitWith {
    diag_log "ERROR: Attempted to run initServer.sqf on non-server machine";
};

server_initialized = false;
publicVariable "server_initialized";

diag_log "INFO: Starting server initialization script";

["Server Init"] call MyFunctions_fnc_sendGlobalChatMessage;

diag_log "INFO: Calling MyFunctions_fnc_initServer";
private _serverInit = [] call MyFunctions_fnc_initServer;
if (!_serverInit) then {
    diag_log "ERROR: Server initialization failed";
    false
};

diag_log "INFO: Server initialization complete";

server_initialized = true;
publicVariable "server_initialized";

true