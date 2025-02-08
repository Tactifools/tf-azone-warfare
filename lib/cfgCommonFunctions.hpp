/*
 * Mission Function Library Configuration
 * Author: CharlesJohnMcC
 * 
 * Description:
 * Defines custom functions available within the lib\functions namespace.
 */
 
class CommonFunctions {
    file = "lib\functions";
        
    class sendSideChatMessage {
        description = "Sends a message to all players in side chat";
        example = "['QRF requested at Grid 045089'] call MyFunctions_fnc_sendSideChatMessage;";
    };
    
    class sendSideChatMessageToSide {
        description = "Sends a message to players of a specific side";
        example = "['Reinforcements arriving at FOB Alpha', west] call MyFunctions_fnc_sendSideChatMessageToSide;";
    };
    
    class sendGlobalChatMessage {
        description = "Sends a message to all players in global chat";
        example = "['Mission will restart in 5 minutes'] call MyFunctions_fnc_sendGlobalChatMessage;";
    };
    
    class createTask {
        description = "Creates a task with specified parameters";
        example = "[west, 'task_assault_1', ['Clear Compound', 'Clear enemy forces from the marked compound', 'assault1'], getMarkerPos 'compound_1', 'ASSIGNED', 'attack', true] call MyFunctions_fnc_createTask;";
    };
    
    class updateTaskState {
        description = "Updates the state of an existing task";
        example = "['task_assault_1', 'SUCCEEDED'] call MyFunctions_fnc_updateTaskState;";
    };
    
    class setMissionVariable {
        description = "Sets a variable in the mission namespace with optional network sync";
        example = "['enemyReinforcements', true, true] call MyFunctions_fnc_setMissionVariable;";
    };
    
    class getMissionVariable {
        description = "Gets a variable from the mission namespace with optional default";
        example = "['currentPhase', 'PHASE_1'] call MyFunctions_fnc_getMissionVariable;";
    };

    class spawnAceArsenal {
        description = "Spawns an ACE Arsenal box at given position";
        example = "[[2000,2000,0], 'B_CargoNet_01_ammo_F', 'arsenal_main'] call MyFunctions_fnc_spawnAceArsenal;";
    };
    
    class spawnLimitedAceArsenal {
        description = "Spawns an ACE Arsenal with limited items";
        example = "[[2000,2000,0], ['arifle_MX_F', '30Rnd_65x39_caseless_mag'], 'arsenal_limited'] call MyFunctions_fnc_spawnLimitedAceArsenal;";
    };
    
    class updateAceArsenal {
        description = "Updates an existing ACE Arsenal box";
        example = "[[2100,2100,0], ['FirstAidKit', 'Medikit'], 'arsenal_main'] call MyFunctions_fnc_updateAceArsenal;";
    };
    
    class deleteAceArsenal {
        description = "Deletes an ACE Arsenal box";
        example = "['arsenal_main'] call MyFunctions_fnc_deleteAceArsenal;";
    };
    
    class createTrigger {
        description = "Creates a trigger with specified parameters";
        example = "['obj_clear_trigger', getMarkerPos 'objective_1', [100,100], 'WEST', 'PRESENT', '(triggerActivated _trigger) && ({side _x == east} count thisList == 0)', '[''obj_clear'', ''SUCCEEDED''] call MyFunctions_fnc_updateTaskState;'] call MyFunctions_fnc_createTrigger;";
    };
    
    class deleteTrigger {
        description = "Deletes a trigger by its variable name";
        example = "['obj_clear_trigger'] call MyFunctions_fnc_deleteTrigger;";
    };
    
    class spawnPatrol {
        description = "Spawns an OPFOR FIA patrol";
        example = "[getMarkerPos 'patrol_start', 4, 200] call MyFunctions_fnc_spawnPatrol;";
    };
    
    class spawnSmoke {
        description = "Spawns a smoke module at given position";
        example = "[getPos _extractionPoint, 'RED', true, 'extract_smoke'] call MyFunctions_fnc_spawnSmoke;";
    };
    
    class deleteSmoke {
        description = "Deletes a smoke module by variable name";
        example = "['extract_smoke'] call MyFunctions_fnc_deleteSmoke;";
    };
    
    class createRespawnPosition {
        description = "Creates a respawn position for a specific side with named marker";
        example = "[getMarkerPos 'fob_alpha', west, 'respawn_west_fob', 'FOB Alpha'] call MyFunctions_fnc_createRespawnPosition;";
    };

    class addHoldAction {
        description = "Adds a hold action to an object with support for code blocks and texture changes";
        example = "[_object, 'Hack System', '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa', '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa', '_target distance _this < 5', '_target setObjectTextureGlobal [1, _this select 3 select 0]', '_target setObjectTextureGlobal [1, _this select 3 select 1]', '_target setObjectTextureGlobal [1, _this select 3 select 2]', '_target setObjectTextureGlobal [1, _this select 3 select 0]', 10, 1000, true, false, '', [_defaultTexture, _inProgressTexture, _completedTexture]] call MyFunctions_fnc_addHoldAction;";
    };

    class deleteHoldAction {
        description = "Deletes a hold action from an object";
        example = "[_object, _holdActionId] call MyFunctions_fnc_deleteHoldAction;";
    };

    class spawnDiscoverableLz {
        description = "Creates a discoverable landing zone with smoke signal and hidden marker";
        example = "[[0,0,0], 'Alpha 1', false] call MyFunctions_fnc_spawnDiscoverableLz;";
    };

    class spawnDiscoveredLz {
        description = "Creates a discovered landing zone with visible marker";
        example = "[[0,0,0], 'Alpha 1', false] call MyFunctions_fnc_spawnDiscoveredLz;";
    };
};