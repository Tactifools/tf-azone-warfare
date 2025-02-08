/*
 * Task System Configuration
 * Author: CharlesJohnMcC
 * 
 * Description:
 * Defines common task functions for easier mission implementation.
 * 
 */
 
class CommonTasks {
    file = "lib\tasks";
    
    class taskKillHVT {
        description = "Creates and manages HVT elimination task";
        example = "[_targetOfficer, ['hvt1', 'mainTasking'], 'Eliminate Officer', 'Find and eliminate the enemy commander'] call MyFunctions_fnc_taskKillHVT;";
    };

    class taskHoldAction {
        description = "Creates and manages task requiring hold action on object";
        example = "[_laptop, ['intel1', mainTasking], 'Gather Intel', 'Search the laptop', 'Download Intel', 10, '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa'] call MyFunctions_fnc_taskHoldAction;";
    };
    
    class taskExtraction {
        description = "Creates and manages extraction task";
        example = "[[2000,2000,0], 'extract1', 'Get to the LZ', 'Move to extraction point marked on map'] call MyFunctions_fnc_taskExtraction;";
    };

    class taskHackLaptop {
        description = "Creates and manages laptop hacking task with dynamic screen textures";
        example = "[_laptop, ['hack1', 'mainTasking'], 'Hack System', 'Access enemy network', 'Hack System', 10, '\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa', 'textures\screen_default.paa', 'textures\screen_hacking.paa', 'textures\screen_complete.paa'] call MyFunctions_fnc_taskHackLaptop;";
    }
};