/*
Function: MyFunctions_fnc_addHoldAction
Author: CharlesJohnMcC

Description:
    Adds a hold action to an object with multiplayer and JIP support.
    Wrapper for BIS_fnc_holdActionAdd with parameter validation and remote execution.

Parameters:
    _target        - Target object to attach action to [Object]
    _text          - Display text shown to player [String]
    _iconIdle      - Icon shown when action available [String, default: search icon]
    _iconProgress  - Icon shown during progress [String, default: search icon]
    _condition     - Condition to show action [String, default: "true"]
    _codeStart     - Code to run when action starts [String, default: ""]
    _codeInProgress- Code to run during action [String, default: ""]
    _codeComplete  - Code to run when action completes [String, default: ""]
    _codeInterupted- Code to run when action interupted [String, default: ""]
    _duration      - Duration in seconds [Number, default: 5]
    _priority      - Priority for multiple actions [Number, default: 1000]

Returns:
    Number - Action ID (-1 if failed)
            Will return -1 if:
            - Invalid target object
            - Invalid icon paths
            - Remote execution fails
            - JIP queue full

Examples:
    // Basic search action
    [
        myBox,
        "Search Box",
        "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_search_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_search_ca.paa",
        "true",
        "",
        "",
        "hint 'Found items!';",
        "",
        5,
        1000
    ] call MyFunctions_fnc_addHoldAction;

    // Conditional intel gathering
    [
        hvtObject,
        "Gather Intel",
        "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_search_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_search_ca.paa",
        "alive _target && _target distance player < 3",
        "player playMove 'AinvPknlMstpSnonWnonDnon_medic_1';",
        "",
        "['intelFound', true] call MyFunctions_fnc_setMissionVariable;",
        "",
        8,
        1001
    ] call MyFunctions_fnc_addHoldAction;

Side Effects:
    - Adds action to target object
    - Broadcasts action to all clients
    - Adds to JIP queue if enabled
    - May trigger animations on start/complete

Dependencies:
    - BIS_fnc_holdActionAdd
    - CBA Events (optional)
    - ACE3 Interactions (optional)
*/

params [
    ["_target", objNull, [objNull]],
    ["_text", "", [""]],
    ["_iconIdle", "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_search_ca.paa", [""]],
    ["_iconProgress", "a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_search_ca.paa", [""]],
    ["_condition", "true", [""]],
    ["_codeStart", "", [""]],
    ["_codeInProgress", "", [""]],
    ["_codeComplete", "", [""]],
    ["_codeInterupted", "", [""]],
    ["_duration", 5, [0]],
    ["_priority", 1000, [1000]]
];

// Validate icons exist in allowed paths
private _validIcons = [
    // Laws of War
    "\a3\Missions_F_Orange\Data\Img\Showcase_LawsOfWar\action_access_fm_CA.paa",
    "\a3\Missions_F_Orange\Data\Img\Showcase_LawsOfWar\action_end_sim_CA.paa",
    "\a3\Missions_F_Orange\Data\Img\Showcase_LawsOfWar\action_exit_CA.paa",
    "\a3\Missions_F_Orange\Data\Img\Showcase_LawsOfWar\action_start_sim_CA.paa",
    "\a3\Missions_F_Orange\Data\Img\Showcase_LawsOfWar\action_view_article_CA.paa",

    // Destroyer DLC
    "\a3\data_f_destroyer\data\UI\IGUI\Cfg\holdactions\holdAction_loadVehicle_ca.paa",
    "\a3\data_f_destroyer\data\UI\IGUI\Cfg\holdactions\holdAction_unloadVehicle_ca.paa",

    // Old Man
    "\a3\missions_f_oldman\data\img\holdactions\holdAction_box_ca.paa",
    "\a3\missions_f_oldman\data\img\holdactions\holdAction_follow_start_ca.paa",
    "\a3\missions_f_oldman\data\img\holdactions\holdAction_follow_stop_ca.paa",
    "\a3\missions_f_oldman\data\img\holdactions\holdAction_talk_ca.paa",
    "\a3\props_f_enoch\items\tools\data\tinfoil_action_ca.paa",

    // Base Actions
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_forceRespawn_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_loaddevice_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_passleadership_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_requestleadership_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_revive_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_takeOff1_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_takeOff2_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_thumbsdown_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_thumbsup_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa",

    // Progress Indicators
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_0_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_1_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_2_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_3_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_4_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_5_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_6_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_7_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_8_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_9_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_10_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\idle\idle_11_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\in\in_0_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\in\in_1_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\in\in_2_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\in\in_3_ca.paa",

    // Progress Bar 2
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_0_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_1_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_2_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_3_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_4_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_5_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_6_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_7_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_8_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_9_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_10_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_11_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_12_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_13_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_14_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_15_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_16_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_17_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_18_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_19_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_20_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_21_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_22_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_23_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress2\progress_24_ca.paa",

    // Progress Bar 1
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_0_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_1_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_2_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_3_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_4_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_5_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_6_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_7_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_8_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_9_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_10_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_11_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_12_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_13_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_14_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_15_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_16_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_17_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_18_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_19_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_20_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_21_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_22_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_23_ca.paa",
    "\a3\ui_f\data\igui\cfg\holdactions\progress\progress_24_ca.paa",

    // Old Man Actions
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\attack_ca.paa",
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\destroy_ca.paa",
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\holdAction_market_ca.paa",
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\holdAction_sleep2_ca.paa",
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\holdAction_sleep_ca.paa",
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\map_ca.paa",
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\meet_ca.paa",
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\refuel_ca.paa",
    "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\repair_ca.paa",

    // Orange DLC
    "\a3\ui_f_orange\Data\CfgOrange\Missions\action_aaf_ca.paa",
    "\a3\ui_f_orange\Data\CfgOrange\Missions\action_csat_ca.paa",
    "\a3\ui_f_orange\Data\CfgOrange\Missions\action_escape_ca.paa",
    "\a3\ui_f_orange\Data\CfgOrange\Missions\action_fia_ca.paa",
    "\a3\ui_f_orange\Data\CfgOrange\Missions\action_fragment_back_ca.paa",
    "\a3\ui_f_orange\Data\CfgOrange\Missions\action_fragment_ca.paa",
    "\a3\ui_f_orange\Data\CfgOrange\Missions\action_idap_ca.paa",
    "\a3\ui_f_orange\Data\CfgOrange\Missions\action_nato_ca.paa",

    // Art of War
    "\a3\ui_f_aow\data\igui\cfg\holdactions\holdaction_charity_ca.paa"
];

if !(_iconIdle in _validIcons) exitWith {
    diag_log format ["ERROR: Invalid idle icon: %1", _iconIdle];
    -1
};

if !(_iconProgress in _validIcons) exitWith {
    diag_log format ["ERROR: Invalid progress icon: %1", _iconProgress];
    -1
};

// Validate parameters
if (isNull _target) exitWith {
    diag_log "ERROR: Invalid target provided to addHoldAction";
    -1
};

if (_text == "") exitWith {
    diag_log "ERROR: No display text provided to addHoldAction";
    -1
};

// Add hold action
private _actionId = [
    _target,
    _text,
    _iconIdle,
    _iconProgress,
    _condition,
    "true",
    compile _codeStart,
    compile _codeInProgress,
    compile _codeComplete,
    compile _codeInterupted,
    [],
    _duration,
    _priority,
    true,
    false,
    true
] remoteExec ["BIS_fnc_holdActionAdd", 0, true];

diag_log format ["Hold action added to %1 with ID %2", _target, _actionId];

_actionId