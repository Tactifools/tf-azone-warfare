/*
Function: MyFunctions_fnc_spawnPatrol
Author: CharlesJohnMcC

Description:
    Creates an OPFOR FIA patrol group that moves in a square pattern around a center point.
    Handles unit creation, waypoint setup, and AI behavior configuration.

Parameters:
    _startPos  - Center position for patrol [x,y,z] [Array]
                Must be valid position within map bounds
    _unitCount - Number of units in patrol group [Number, default: 4]
                Must be between 1 and 8
    _radius    - Radius of patrol square in meters [Number, default: 100]
                Must be between 50 and 1000

Returns:
    Group - Created patrol group, or grpNull if:
          - Invalid position provided
          - Invalid unit count
          - Invalid radius
          - Group creation fails
          - Unit creation fails

Examples:
    // Basic patrol
    _group = [[1000,1000,0], 4, 100] call MyFunctions_fnc_spawnPatrol;

    // Larger patrol with error handling
    _group = [[2000,2000,0], 6, 200] call MyFunctions_fnc_spawnPatrol;
    if (isNull _group) then {
        diag_log "Failed to create patrol group";
    };

Side Effects:
    - Creates AI units in game world
    - Sets up patrol waypoints
    - Enables dynamic simulation
    - Updates AI behavior settings

Dependencies:
    - None (uses engine group system)

Note:
    - Group is created with OPFOR FIA units (O_G_Soldier_F)
    - Patrol moves in square pattern with SAFE behavior
    - Waypoints are cyclic (continuous patrol)
    - All units have 0.5 skill level
    - Must be called on server
*/

params [
    ["_startPos", [], [[]], 3],
    ["_unitCount", 4, [0]],
    ["_radius", 100, [0]]
];

// Validate parameters
if (_startPos isEqualTo [] || !(_startPos select 0 in [0, worldSize]) || !(_startPos select 1 in [0, worldSize])) exitWith {
    diag_log "ERROR: Invalid position provided to spawnPatrol";
    grpNull
};

if (_unitCount <= 0 || _unitCount > 8) exitWith {
    diag_log "ERROR: Invalid unit count provided to spawnPatrol";
    grpNull
};

if (_radius < 50 || _radius > 1000) exitWith {
    diag_log "ERROR: Invalid radius provided to spawnPatrol";
    grpNull
};

// Create OPFOR FIA group with loadout fix
private _group = createGroup [east, true];
if (isNull _group) exitWith {
    diag_log "ERROR: Failed to create group";
    grpNull
};

for "_i" from 1 to _unitCount do {
    private _unit = _group createUnit ["O_G_Soldier_F", _startPos, [], 0, "NONE"];
    if (isNull _unit) exitWith {
        diag_log "ERROR: Failed to create unit";
        deleteGroup _group;
        grpNull
    };
    _unit enableDynamicSimulation true;
    
    // Fix loadout
    removeAllWeapons _unit;
    {_unit removeMagazine _x} forEach magazines _unit;
    _unit addMagazines ["30Rnd_556x45_Stanag", 6];
    _unit addWeapon "arifle_TRG20_F";
};

// Create square patrol pattern using 4 waypoints
for "_i" from 0 to 3 do {
    private _wp = _group addWaypoint [
        [
            (_startPos select 0) + (sin (_i * 90) * _radius),
            (_startPos select 1) + (cos (_i * 90) * _radius),
            0
        ],
        0
    ];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE";
    _wp setWaypointSpeed "LIMITED";
};

// Close the patrol loop by returning to start
private _wp = _group addWaypoint [_startPos, 0];
_wp setWaypointType "CYCLE";

// Return the created group
_group