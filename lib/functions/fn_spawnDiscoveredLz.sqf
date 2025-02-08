/*
Function: MyFunctions_fnc_spawnDiscoveredLz
Author: CharlesJohnMcC

Description:
    Creates a discovered landing zone.

Parameters:
    _position        - Position to create LZ [x,y,z] [Array]
    _markerName     - Display name for the LZ marker [String]
    _withHideTerrain - Whether to hide terrain objects in 50m radius [Boolean, default: false]

Returns:
    Object - Created helipad object
            Returns objNull if:
            - Invalid position provided
            - Creation fails

Examples:
    // Basic LZ
    _lz = [[1000,1000,0], "LZ Alpha", false] call MyFunctions_fnc_spawnDiscoveredLz;

    // LZ with cleared surroundings
    _lz = [getPos player, "LZ Bravo", true] call MyFunctions_fnc_spawnDiscoveredLz;

Dependencies:
    - MyFunctions_fnc_spawnSmoke
    - MyFunctions_fnc_deleteSmoke
    - MyFunctions_fnc_createTrigger
    - MyFunctions_fnc_sendGlobalChatMessage

Note:
    - Creates hidden marker that reveals when players get within 30m
    - Orange smoke persists until discovery
    - Automatically cleans up smoke on discovery
    - Broadcasting "LZ Discovered" message on reveal
*/

params [
    ["_position", [], [[]]],
	["_markerName", "", [""]],
    ["_withHideTerrain", false, [true, false]]
];

if (_position isEqualTo []) exitWith {
    diag_log "ERROR: Invalid position for discovered LZ";
    objNull
};

// Ensure LZ creation happens on server
if (!isServer) exitWith {
    _this remoteExec ["MyFunctions_fnc_spawnDiscoveredLz", 2];
    objNull
};

// Create LZ object
private _lzObject = createVehicle ["Land_HelipadCircle_F", _position, [], 0, "CAN_COLLIDE"];

// Hide terrain if requested
if (_withHideTerrain) then {
    private _radius = 50; // Define fixed radius for terrain hiding
    
    {
        private _objects = nearestTerrainObjects [_position, [_x], _radius];
        {
            _x hideObjectGlobal true;
        } forEach _objects;
    } forEach ["TREE", "SMALL TREE", "BUSH", "BUILDING", "HOUSE", "FOREST", "ROCK", "ROCKS"];
};

// Create marker globally
private _markerId = format ["lz_%1", floor random 99999];
private _marker = createMarker [_markerId, _position];
_marker setMarkerType "mil_pickup";
_marker setMarkerColor "ColorYellow";
_marker setMarkerAlpha 100;
_marker setMarkerText _markerName;

_lzObject