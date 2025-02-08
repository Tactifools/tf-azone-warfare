/*
Function: MyFunctions_fnc_spawnSmoke
Author: CharlesJohnMcC

Description:
    Spawns a colored smoke shell at specified position. Can create persistent smoke
    by spawning new shells periodically.

Parameters:
    _position     - Position to spawn smoke [x,y,z] [Array]
    _color        - Color of smoke [String, default: "WHITE"]
                   Valid: "WHITE","RED","GREEN","YELLOW","ORANGE","PURPLE"  
    _persistent   - Whether to respawn smoke shells every 25s [Boolean, default: false]
    _variableName - Variable name to store smoke references [String]

Returns:
    Array - [smokeShell, spawnHandle] or [smokeShell] if not persistent
            Returns [] if:
            - Not called on server
            - Invalid position provided

Examples:
    // Basic white smoke
    _smoke = [[100,100,0]] call MyFunctions_fnc_spawnSmoke;

    // Persistent orange smoke for LZ marking
    _smoke = [
        getPos player,
        "ORANGE", 
        true,
        "lz_smoke"
    ] call MyFunctions_fnc_spawnSmoke;

Dependencies:
    None

Note:
    - Must be called on server
    - Persistent smoke spawns new shell every 25s
    - For persistent smoke, handle must be terminated manually
*/

// Create smoke on server only
if (!isServer) exitWith {
    _this remoteExec ["MyFunctions_fnc_spawnSmoke", 2];
    []
};

params [
    ["_position", [], [[]], 3],
    ["_color", "WHITE", [""]], 
    ["_persistent", false, [true]], 
    ["_variableName", "", [""]]
];

if (_position isEqualTo []) exitWith {
    diag_log "ERROR: Invalid position provided to spawnSmoke";
    objNull
};

// Set color based on input
private _smokeType = switch (_color) do {
    case "RED": {"SmokeShellRed"};
    case "GREEN": {"SmokeShellGreen"};
    case "YELLOW": {"SmokeShellYellow"};
    case "PURPLE": {"SmokeShellPurple"};
    case "ORANGE": {"SmokeShellOrange"};
    default {"SmokeShell"};
};

private _smoke = _smokeType createVehicle _position;
_smoke setPosATL _position;

// Ensure smoke is local to server for reliable cleanup
_smoke setOwner 2;

// Store references with exact provided name
if (_persistent) then {
    private _handle = [_position, _smokeType, _variableName] spawn {
        params ["_pos", "_type", "_varName"];
        while {!isNil {missionNamespace getVariable _varName}} do {
            private _newSmoke = _type createVehicle _pos;
            _newSmoke setOwner 2;
            sleep 25;
        };
    };
    
    if (_variableName != "") then {
        missionNamespace setVariable [_variableName, [_smoke, _handle], true]; // Force global sync
    };
    
    [_smoke, _handle]
} else {
    if (_variableName != "") then {
        missionNamespace setVariable [_variableName, [_smoke], true];
    };
    
    [_smoke]
};

diag_log format ["Smoke effect spawned at %1 with color %2", _position, _color];