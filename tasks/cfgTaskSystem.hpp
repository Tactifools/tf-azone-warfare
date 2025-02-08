/*
 * Task System Configuration
 * Author: CharlesJohnMcC
 * 
 * Description:
 * Defines all mission task functions and their configurations.
 * Part of the MyFunctions namespace.
 * 
 * Dependencies:
 * - TaskManagement class functions
 * - MissionNamespace class functions
 */
 
class TaskSystem {
    file = "tasks";
    
    class initTasks {
        description = "Initializes all mission tasks";
        example = "if (!isServer) exitWith {}; [] call MyFunctions_fnc_initTasks;";
    };

    class navigator {
        description = "Manages mission task flow and progression between different phases";
        example = "if (!isServer) exitWith {}; ['taskKillHVT', true] call MyFunctions_fnc_navigator;";
    };

    class grantMissionReward {
        description = "Grants mission rewards to player";
        example = "if (!isServer) exitWith {}; ['taskKillHVT'] call MyFunctions_fnc_grantMissionReward;";
    };
};