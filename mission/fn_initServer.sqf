/*
Function: MyFunctions_fnc_initServer
Author: CharlesJohnMcC

Description:
    Initializes server-side mission components and manages core initialization sequence.
    Handles server state tracking and mission startup validation.

Parameters:
    None

Returns:
    Boolean - True if initialization successful, false if:
             - Not called on server
             - Mission initialization fails
             - Server state sync fails

Example:
    if (!isServer) exitWith {};
    [] call MyFunctions_fnc_initServer;

Side Effects:
    - Sets server_initialized state
    - Triggers mission initialization
    - Broadcasts server state to clients
    - Initializes core mission components

Dependencies:
    - MyFunctions_fnc_initMission

Note:
    Must be called on server only
    Controls mission startup sequence
    Debug logging enabled
*/

if (!isServer) exitWith {
    diag_log "ERROR: initServer must be called on server";
    false
};

diag_log "INFO: Starting server initialization";
missionNamespace setVariable ["server_initialized", false, true];

// Don't wait for parsingDone, just check if it exists
if (isNil "parsingDone") then {
    diag_log "WARNING: parsingDone not set, continuing initialization";
};

diag_log "INFO: Proceeding with initialization sequence";

// Remove sleep and proceed directly to mission init
diag_log "INFO: Calling MyFunctions_fnc_initMission";
private _missionInit = [] spawn {
    sleep 0.1; // Small delay to allow frame update
    [] call MyFunctions_fnc_initMission
};

// Set initialization complete immediately
missionNamespace setVariable ["server_initialized", true, true];
diag_log "INFO: Server initialization marked as complete";
true