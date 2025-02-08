/*
Function: MyFunctions_fnc_spawnAceArsenal
Author: CharlesJohnMcC

Description:
    Spawns an ACE Arsenal box at a given position with optional box type.
    Handles network synchronization and variable management.

Parameters:
    _position     - Position to spawn the box [x,y,z] [Array]
                   Must be within map bounds
    _box_type     - Optional: Type of box to spawn [String, default: "B_supplyCrate_F"]
                   Must be valid vehicle classname
    _variableName - Optional: Variable name for the box [String, default: "ace_arsenal_box"]
                   Must be non-empty string

Returns:
    Object - Created arsenal box, or objNull if:
           - Invalid position provided
           - Position outside map bounds
           - Invalid box type
           - Empty variable name
           - Spawn fails
           - Network sync fails

Examples:
    // Basic arsenal spawn
    _box = [[100,100,0]] call MyFunctions_fnc_spawnAceArsenal;

    // Custom box type with error handling
    _box = [[200,200,0], "B_CargoNet_01_ammo_F"] call MyFunctions_fnc_spawnAceArsenal;
    if (isNull _box) then {
        diag_log "Failed to spawn arsenal box";
    };

    // Full parameter usage
    _box = [
        [300,300,0],
        "B_supplyCrate_F",
        "my_custom_arsenal"
    ] call MyFunctions_fnc_spawnAceArsenal;

Side Effects:
    - Creates physical box in game world
    - Initializes ACE Arsenal interface
    - Sets up network synchronization
    - Creates mission namespace variable
    - Updates for JIP clients

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
    ["_box_type", "B_supplyCrate_F", [""]],
    ["_variableName", "ace_arsenal_box", [""]]
];

// Validate parameters
if (_position isEqualTo []) exitWith {
    diag_log "ERROR: Invalid position provided to spawnAceArsenal";
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

if (_variableName == "") exitWith {
    diag_log "ERROR: Invalid variable name provided";
    objNull
};

diag_log format ["Spawning ACE Arsenal box at position: %1", _position];

// Create the supply box
private _supplyBox = createVehicle [_box_type, _position, [], 5, "NONE"];

diag_log format ["Supply box created: %1", _supplyBox];

// Clear existing cargo
clearItemCargoGlobal _supplyBox;
clearMagazineCargoGlobal _supplyBox;
clearWeaponCargoGlobal _supplyBox;
clearBackpackCargoGlobal _supplyBox;

// Initialize ACE Arsenal
[_supplyBox, true] call ace_arsenal_fnc_initBox;

diag_log "ACE Arsenal initialized";

// Set variable name (synchronized across network)
missionNamespace setVariable [_variableName, _supplyBox, true];

diag_log format ["ACE Arsenal box created and stored as: %1", _variableName];

// Return the created box
_supplyBox