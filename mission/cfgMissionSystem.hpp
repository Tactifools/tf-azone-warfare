/*
 * Mission System Configuration
 * Author: CharlesJohnMcC
 * 
 * Description:
 * Defines mission initialization and lifecycle management functions.
 * Part of the MyFunctions namespace.
 */

class MissionSystem {
    file = "mission";
    
    class initServer {
        description = "Initializes server-side mission components including AI, triggers, and tasks";
        example = "if (!isServer) exitWith {}; [] spawn MyFunctions_fnc_initServer;";
    };
    
    class initMission {
        description = "Initializes mission environment, weather, time, and starting tasks";
        example = "if (isServer) then { [] spawn MyFunctions_fnc_initMission; };";
    };

    class initMissionVariables {
        description = "Initializes mission variables with default values and network sync";
        example = "if (isServer) then { [] call MyFunctions_fnc_initMissionVariables; };";
    };
};