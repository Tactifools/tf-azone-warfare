/*
 * Mission Function Library Configuration
 * Author: CharlesJohnMcC
 * 
 * Description:
 * Defines all custom functions available in the mission namespace.
 * Functions are organized into logical classes for better organization.
 * 
 * Class Structure:
 * - MyFunctions
 *   |- CommonFunctions (lib\cfgCommonFunctions.hpp)
 *      |- Communication functions
 *      |- Variable handling
 *      |- Arsenal management
 *   |- CommonTasks (lib\cfgCommonTasks.hpp)
 *      |- HVT elimination
 *      |- Intel search
 *      |- Extraction
 *   |- TaskSystem (tasks\cfgTaskSystem.hpp)
 *      |- Task initialization
 *      |- Task navigation
 *      |- Reward system
 *   |- MissionSystem (mission\cfgMissionSystem.hpp)
 *      |- Server initialization
 *      |- Mission initialization
 *      |- Variable management
 * 
 * Dependencies:
 * - CBA_A3
 * - ACE3
 * 
 * Note:
 * All functions are prefixed with MyFunctions_fnc_
 * Debug logging enabled for all functions
 */
 
class MyFunctions {
    // Includes common functions from separate files
    #include "lib\cfgCommonFunctions.hpp"
    #include "lib\cfgCommonTasks.hpp"

    // Includes task and mission system configurations from separate files
    #include "tasks\cfgTaskSystem.hpp"
    #include "mission\cfgMissionSystem.hpp"
};