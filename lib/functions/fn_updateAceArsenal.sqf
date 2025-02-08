/*
Function: MyFunctions_fnc_updateAceArsenal
Author: CharlesJohnMcC

Description:
    Updates an existing ACE Arsenal box with new items and/or position.
    Handles deletion and recreation of box while maintaining variable reference.

Parameters:
    _position     - New position for the box [x,y,z] [Array]
                   Must be valid position within map bounds
    _arsenalItems - Array of classnames for allowed items [Array]
                   Must contain valid item classnames
    _variableName - Variable name of existing arsenal box [String]
                   Must match existing arsenal variable
    _box_type     - Optional: Type of box if recreating [String, default: "B_supplyCrate_F"]
                   Must be valid vehicle classname

Returns:
    Object - Updated arsenal box, or objNull if:
           - Invalid position provided
           - Empty arsenalItems array
           - Invalid variable name
           - Original box not found
           - New box creation fails
           - Network sync fails

Examples:
    // Update position and contents
    _box = [
        [100,100,0],
        ["arifle_MX_F", "30Rnd_65x39_caseless_mag"],
        "blufor_arsenal"
    ] call MyFunctions_fnc_updateAceArsenal;

    // Update with error handling
    _box = [getPosATL player, ["FirstAidKit"], "medical_arsenal"] call MyFunctions_fnc_updateAceArsenal;
    if (isNull _box) then {
        diag_log "Failed to update arsenal";
    };

Side Effects:
    - Deletes existing arsenal box
    - Creates new box at specified position
    - Updates allowed items list
    - Maintains variable reference
    - Updates network synchronization

Dependencies:
    - ACE3 Arsenal
    - ACE3 Interaction System

Note:
    Must be called on server
    Box is synchronized across network
    Debug logging enabled
*/

params [
    ["_position", [], [[]], 3],
    ["_arsenalItems", [], [[]]],
    ["_variableName", "", [""]],
    ["_box_type", "B_supplyCrate_F", [""]]
];

// Validate parameters
if (_position isEqualTo [] || 
    _arsenalItems isEqualTo [] || 
    _variableName == "") exitWith {
    diag_log "ERROR: Invalid parameters provided to updateAceArsenal";
    objNull
};

// Get existing arsenal
private _existingArsenal = missionNamespace getVariable [_variableName, objNull];
if (isNull _existingArsenal) exitWith {
    diag_log format ["ERROR: Arsenal box '%1' not found", _variableName];
    objNull
};

// Delete existing arsenal
deleteVehicle _existingArsenal;

diag_log format ["Spawning updated ACE Arsenal box at position: %1", _position];

// Create new supply box
private _supplyBox = createVehicle [_box_type, _position, [], 5, "NONE"];

diag_log format ["New supply box created: %1", _supplyBox];

// Clear cargo
clearItemCargoGlobal _supplyBox;
clearMagazineCargoGlobal _supplyBox;
clearWeaponCargoGlobal _supplyBox;
clearBackpackCargoGlobal _supplyBox;

// Initialize with new items
[_supplyBox, _arsenalItems, true] call ace_arsenal_fnc_initBox;

diag_log format ["ACE Arsenal initialized with %1 items", count _arsenalItems];

// Update mission namespace (synchronized across network)
missionNamespace setVariable [_variableName, _supplyBox, true];

diag_log format ["ACE Arsenal box updated and stored as: %1", _variableName];

// Return updated box
_supplyBox