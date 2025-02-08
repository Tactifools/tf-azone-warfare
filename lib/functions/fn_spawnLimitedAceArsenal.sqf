/*
Function: MyFunctions_fnc_spawnLimitedAceArsenal
Author: CharlesJohnMcC

Description:
    Spawns an ACE Arsenal box with limited items at a given position.
    Handles network synchronization and arsenal initialization.

Parameters:
    _position     - Position to spawn the box [x,y,z] [Array]
                   Must be within map bounds
    _arsenalItems - Array of classnames for allowed items [Array]
                   Must contain valid item classnames
    _variableName - Variable name for the box [String]
                   Must be non-empty string
    _box_type     - Optional: Type of box to spawn [String, default: "B_supplyCrate_F"]
                   Must be valid vehicle classname

Returns:
    Object - Created arsenal box, or objNull if:
           - Invalid position provided
           - Position outside map bounds
           - Empty arsenalItems array
           - Invalid item classnames
           - Invalid box type
           - Spawn fails
           - Network sync fails

Examples:
    // Basic limited arsenal with weapons
    _box = [
        [100,100,0],
        ["arifle_MX_F", "30Rnd_65x39_caseless_mag"],
        "blufor_weapons"
    ] call MyFunctions_fnc_spawnLimitedAceArsenal;

    // Medical supplies arsenal
    _box = [
        getPos player,
        ["FirstAidKit", "Medikit", "ACE_fieldDressing"],
        "medical_box",
        "ACE_medicalSupplyCrate"
    ] call MyFunctions_fnc_spawnLimitedAceArsenal;

Side Effects:
    - Creates physical box in game world
    - Initializes ACE Arsenal interface
    - Limits available items to specified list
    - Sets up network synchronization
    - Creates mission namespace variable

Dependencies:
    - ACE3 Arsenal
    - ACE3 Interaction System

Note:
    Must be called on server
    Box is synchronized across network
    Debug logging enabled for all operations
*/

params [
    ["_position", [], [[]], 3],
    ["_arsenalItems", [], [[]]],
    ["_variableName", "", [""]],
    ["_box_type", "B_supplyCrate_F", [""]]
];

// Validate parameters
if (_position isEqualTo []) exitWith {
    diag_log "ERROR: Invalid position provided to spawnLimitedAceArsenal";
    objNull
};

// Validate position is within map bounds
private _mapSize = worldSize;
if (_position select 0 < 0 || 
    _position select 0 > _mapSize || 
    _position select 1 < 0 || 
    _position select 1 > _mapSize) exitWith {
    diag_log format ["ERROR: Position %1 is outside map bounds", _position];
    objNull
};

if (_arsenalItems isEqualTo []) exitWith {
    diag_log "ERROR: No items provided for limited arsenal";
    objNull
};

if (_variableName == "") exitWith {
    diag_log "ERROR: No variable name provided for arsenal box";
    objNull
};

diag_log format ["Spawning limited ACE Arsenal box at position: %1", _position];

// Create the supply box
private _supplyBox = createVehicle [_box_type, _position, [], 5, "NONE"];

diag_log format ["Supply box created: %1", _supplyBox];

// Clear existing cargo
clearItemCargoGlobal _supplyBox;
clearMagazineCargoGlobal _supplyBox;
clearWeaponCargoGlobal _supplyBox;
clearBackpackCargoGlobal _supplyBox;

// Initialize limited ACE Arsenal
[_supplyBox, _arsenalItems, true] call ace_arsenal_fnc_initBox;

diag_log format ["Limited ACE Arsenal initialized with %1 items", count _arsenalItems];

// Set variable name (synchronized across network)
missionNamespace setVariable [_variableName, _supplyBox, true];

diag_log format ["Limited ACE Arsenal box created and stored as: %1", _variableName];

// Return the created box
_supplyBox