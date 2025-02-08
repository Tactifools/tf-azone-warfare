/*
Function: MyFunctions_fnc_createRespawnPosition
Author: CharlesJohnMcC

Description:
    Creates a respawn position for a specific side with named marker.
    Must be executed on server. Handles marker creation and respawn point registration.

Parameters:
    _position    - Position for respawn [x,y,z] [Array]
    _side        - Side to create respawn for [Side - west/east/resistance/civilian]
    _name        - Unique identifier for respawn marker [String]
    _displayName - Display name shown in respawn menu [String]

Returns:
    String - Created marker name, or empty string if failed
            Returns empty string if:
            - Not called on server
            - Invalid position provided
            - Invalid side provided
            - Invalid or duplicate marker name
            - Marker creation fails

Examples:
    // Basic west side respawn
    _marker = [
        [100,100,0], 
        west, 
        "respawn_west", 
        "Main Base"
    ] call MyFunctions_fnc_createRespawnPosition;

    // OPFOR mobile respawn
    _marker = [
        getPos _mobileHQ, 
        east, 
        "respawn_east_mobile", 
        "Mobile HQ"
    ] call MyFunctions_fnc_createRespawnPosition;

Side Effects:
    - Creates new marker on map
    - Registers respawn position in mission
    - Updates respawn menu for all players
    - Broadcasts to JIP clients

Dependencies:
    - BIS Respawn System
    - MyFunctions_fnc_markerExists (optional)

Note:
    - Uses marker-based respawn system
    - Marker name must start with "respawn_" for side specific spawns
    - Display name appears in respawn selection menu
    - Must be called on server only
*/

params [
    ["_position", [], [[]], 3],
    ["_side", sideUnknown, [west]],
    ["_name", "", [""]],
    ["_displayName", "", [""]]
];

if (!isServer) exitWith {
    diag_log "ERROR: createRespawnPosition must be called on server";
    ""
};

if (_position isEqualTo []) exitWith {
    diag_log "ERROR: Invalid position provided to createRespawnPosition";
    ""
};

if (_side == sideUnknown) exitWith {
    diag_log "ERROR: Invalid side provided to createRespawnPosition";
    ""
};

if (_name == "") exitWith {
    diag_log "ERROR: Invalid name provided to createRespawnPosition";
    ""
};

if (_displayName == "") exitWith {
    diag_log "ERROR: Invalid display name provided to createRespawnPosition";
    ""
};

// Create marker
private _marker = createMarker [_name, _position];
_marker setMarkerType "respawn_inf";
_marker setMarkerText _displayName;
_marker setMarkerColor (switch (_side) do {
    case west: {"ColorBLUFOR"};
    case east: {"ColorOPFOR"};
    case resistance: {"ColorIndependent"};
    case civilian: {"ColorCivilian"};
});

diag_log format ["Respawn position created for %1 at %2 with marker %3 and name %4", _side, _position, _marker, _displayName];

_marker