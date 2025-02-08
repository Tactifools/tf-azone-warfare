/*
Function: MyFunctions_fnc_createTrigger
Author: CharlesJohnMcC

Description:
    Creates a trigger at a specified position with given parameters.
    Handles trigger creation, activation conditions, and execution statements.

Parameters:
    _name           - Trigger name/variable [String]
    _position       - Position [x,y,z] [Array]
    _area          - Trigger area [width, height] [Array]
    _activationBy   - Who activates: "ANY", "EAST", "WEST", "GUER", "CIV" [String]
    _activationType - Type: "PRESENT", "NOT PRESENT", "WEST SEIZED" [String]
    _condition      - Trigger condition (String, default: "this") [String]
    _statement      - Code to execute when triggered [String]

Returns:
    Object - Created trigger object
            Returns objNull if:
            - Invalid trigger name
            - Invalid position format
            - Invalid area dimensions
            - Creation fails

Examples:
    // Basic presence trigger
    _trigger = [
        "checkpointTrigger",
        [1000,1000,0],
        [50,50],
        "WEST",
        "PRESENT",
        "this",
        "hint 'Checkpoint reached!'"
    ] call MyFunctions_fnc_createTrigger;

    // Complex condition with task
    _trigger = [
        "objectiveTrigger",
        getMarkerPos "objective_1",
        [100,100],
        "WEST",
        "PRESENT",
        "({side _x == west} count thisList) > 5",
        "['task_1', 'SUCCEEDED'] call MyFunctions_fnc_updateTaskState"
    ] call MyFunctions_fnc_createTrigger;

Side Effects:
    - Creates trigger in mission namespace
    - May affect mission state via trigger statements
    - Syncs across network in MP

Dependencies:
    - None (uses engine trigger system)

Note:
    - Triggers are server-side only
    - Area uses rectangular shape by default
    - Statements run in unscheduled environment
*/

params [
    ["_name", "", [""]],
    ["_position", [], [[]], 3],
    ["_area", [], [[]], 2],
    ["_activationBy", "", [""]],
    ["_activationType", "", [""]],
    ["_condition", "", [""]],
    ["_statement", "", [""]]
];

// Validate parameters
if (_name == "") exitWith {
    diag_log "ERROR: Invalid trigger name provided";
    objNull
};

if (_position isEqualTo []) exitWith {
    diag_log "ERROR: Invalid position provided";
    objNull
};

if (_area isEqualTo [] || count _area != 2) exitWith {
    diag_log "ERROR: Invalid trigger area provided";
    objNull
};

diag_log format ["Creating trigger: %1 at position %2", _name, _position];

private _trigger = createTrigger ["EmptyDetector", _position, false];
_trigger setTriggerArea [_area select 0, _area select 1, 0, false];
_trigger setTriggerActivation [_activationBy, _activationType, false];
_trigger setTriggerStatements [_condition, _statement, ""];

diag_log format ["Trigger '%1' created at position %2 with area %3", _name, _position, _area];

_trigger