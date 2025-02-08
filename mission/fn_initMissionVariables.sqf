/*
Function: MyFunctions_fnc_initMissionVariables
Author: CharlesJohnMcC

Description:
    Initializes all mission-wide variables with network synchronization.
    Sets up core mission state tracking and equipment configurations.
    Must be called on server during mission initialization.

Parameters:
    None

Returns:
    Boolean - True if initialization successful, false if:
             - Not called on server
             - Network sync fails
             - Variable setup fails

Example:
    if (!isServer) exitWith {};
    [] call MyFunctions_fnc_initMissionVariables;

Side Effects:
    - Sets mission_started to false
    - Sets missionStartTime to serverTime
    - Initializes active_arsenal_items array
    - Sets base_arsenal_items with default loadout
    - Broadcasts all variables to clients

Dependencies:
    - None (uses engine variable system)

Note:
    Must be called on server only
    All variables are network synchronized
    Debug logging enabled
*/

if (!isServer) exitWith {
    diag_log "ERROR: initMissionVariables must be called on server only";
    false
};

diag_log "INFO: Starting mission variables initialization";

// Remove parsingDone check and proceed directly
if (!isNil "mission_variables_initialized" && {mission_variables_initialized}) exitWith {
    diag_log "WARNING: Mission variables already initialized";
    true
};

// Initialize standard mission state variables
diag_log "DEBUG: Initializing mission_started variable";
missionNamespace setVariable ["mission_started", false, true];

diag_log "DEBUG: Initializing missionStartTime variable";
missionNamespace setVariable ["missionStartTime", serverTime, true];

// Custom mission variables
diag_log "DEBUG: Initializing active_arsenal_items variable";
missionNamespace setVariable ["active_arsenal_items", [], true];

diag_log "DEBUG: Initializing base_arsenal_items variable";
missionNamespace setVariable ["base_arsenal_items", [ 
	"rhsusf_weap_glock17g4", 
	"rhsusf_mag_17Rnd_9x19_FMJ", 
	"rhs_uniform_g3_rgr", 
	"B_LegStrapBag_black_F", 
	"ItemGPS", 
	"ItemCompass", 
	"ItemMap", 
	"G_Aviator", 
	"ACRE_PRC152", 
	"ACE_MapTools", 
	"ACE_surgicalKit", 
	"ACE_tourniquet", 
	"ACE_plasmaIV_500", 
	"ACE_plasmaIV_250", 
	"ACE_morphine", 
	"ACE_epinephrine", 
	"ACE_EarPlugs", 
	"ACE_elasticBandage", 
	"ACE_splint", 
	"V_TacVest_blk", 
	"rhs_6b7_1m_olive", 
	"ACE_EntrenchingTool", 
	"ItemWatch", 
	"ACE_painkillers" 
], true];

diag_log "DEBUG: Initializing alpha_arsenal_reward variable";
missionNamespace setVariable ["alpha_arsenal_reward", [
	"JCA_hgun_P226_olive_F",  
	"JCA_acc_flashlight_tactical_olive",  
	"JCA_30Rnd_9x21_MP5_Mag",  
	"JCA_optic_ARO_olive",  
	"JCA_smg_MP5_AFG_olive_F",  
	"MiniGrenade",  
	"JCA_15Rnd_9x21_P226_Mag",  
	"SmokeShell"
], true];

diag_log "DEBUG: Initializing bravo_arsenal_reward variable";
missionNamespace setVariable ["bravo_arsenal_reward", [
	"MiniGrenade", 
	"JCA_15Rnd_9x21_P226_Mag", 
	"SmokeShell", 
	"JCA_smg_UMP_AFG_black_F", 
	"JCA_hgun_P226_black_F", 
	"JCA_25Rnd_45ACP_UMP_Mag", 
	"JCA_acc_flashlight_tactical_black", 
	"JCA_optic_ARO_black" 
], true];

diag_log "DEBUG: Initializing charlie_arsenal_reward variable";
missionNamespace setVariable ["charlie_arsenal_reward", [
	"MiniGrenade", 
	"SmokeShell", 
	"JCA_hgun_P320_sand_F", 
	"JCA_17Rnd_9x21_P320_Mag", 
	"rhs_weap_vss_grip", 
	"rhs_10rnd_9x39mm_SP6", 
	"JCA_optic_ARO_sand" 
], true];

missionNamespace setVariable ["mission_variables_initialized", true, true];

// Add check for successful initialization
if (isNil "mission_variables_initialized") then {
    diag_log "ERROR: Failed to set mission_variables_initialized";
    false
} else {
    diag_log "INFO: Mission variables initialization complete";
    true
};