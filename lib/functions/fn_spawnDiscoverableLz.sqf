/*
Function: MyFunctions_fnc_spawnDiscoverableLz
Author: CharlesJohnMcC

Description:
    Creates a discoverable landing zone with persistent orange smoke that reveals
    the LZ location when players get within range.

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
    _lz = [[1000,1000,0], "LZ Alpha", false] call MyFunctions_fnc_spawnDiscoverableLz;

    // LZ with cleared surroundings
    _lz = [getPos player, "LZ Bravo", true] call MyFunctions_fnc_spawnDiscoverableLz;

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
    diag_log "ERROR: Invalid position for discoverable LZ";
    objNull
};

// Ensure LZ creation happens on server
if (!isServer) exitWith {
    _this remoteExec ["MyFunctions_fnc_spawnDiscoverableLz", 2];
    objNull
};

// Create LZ object
private _lzObject = createVehicle ["Land_HelipadCircle_F", _position, [], 0, "CAN_COLLIDE"];

// Hide terrain if requested
if (_withHideTerrain) then {
    private _hideTerrainObject = createVehicle ["ModuleHideTerrainObjects_F", _position, [], 0, "NONE"];
    _hideTerrainObject setVariable ["#area", [50, 50, 0, false]];
};

// Create marker globally
private _markerId = format ["lz_%1", floor random 99999];
private _marker = createMarker [_markerId, _position];
_marker setMarkerType "mil_pickup";
_marker setMarkerColor "ColorYellow";
_marker setMarkerAlpha 0;
_marker setMarkerText _markerName;

// Create persistent smoke with correct variable name
private _smokeVarName = format ["lzSmoke_%1", _markerId];
[_position, "ORANGE", true, _smokeVarName] call MyFunctions_fnc_spawnSmoke;

// Make sure trigger is created on server and synced
private _trigger = [
	_markerId + "Trigger",
	_position,
	[30,30],
	"WEST",
	"PRESENT",
	"this",
	format [
        "
        ['%1'] remoteExec ['MyFunctions_fnc_deleteSmoke', 2];
        '%2' setMarkerAlpha 1;
        ['LZ Location Discovered'] call MyFunctions_fnc_sendGlobalChatMessage;
        ",
        _smokeVarName,
        _markerId
    ]
] call MyFunctions_fnc_createTrigger;

_lzObject