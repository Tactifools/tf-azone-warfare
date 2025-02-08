/*
Function: MyFunctions_fnc_initMission
Author: CharlesJohnMcC

Description:
    Initializes mission environment, creates respawn points, patrols and initial tasks.
    Handles base setup, arsenal creation, and starting mission state.

Parameters:
    None

Returns:
    Boolean - True if initialization successful, false if failed
             Will return false if:
             - Mission variables fail to initialize
             - Respawn position creation fails
             - Arsenal items not found
             - Arsenal creation fails
             - Parent task creation fails

Example:
    if (!isServer) exitWith {};
    [] call MyFunctions_fnc_initMission;

Side Effects:
    - Creates BLUFOR respawn point at [6512.16,4002.02,0]
    - Spawns limited ACE Arsenal at [6521.92,4015.99,0]
    - Sets active_arsenal_items in missionNamespace
    - Initializes mission variables
    - Creates parent mission task

Dependencies:
    - MyFunctions_fnc_initMissionVariables
    - MyFunctions_fnc_createRespawnPosition
    - MyFunctions_fnc_spawnLimitedAceArsenal
    - ACE3 Arsenal

Note:
    Must be called on server only
    Initializes core mission components
    Debug logging enabled for all operations
*/

params [];

if (!isServer) exitWith {
    diag_log "ERROR: initMission must be called on server";
    false
};

diag_log "INFO: Starting mission initialization";

// Remove parsingDone check
diag_log "INFO: Proceeding with mission setup";

// Initialize mission variables first
diag_log "INFO: Calling MyFunctions_fnc_initMissionVariables";
[] spawn {
    sleep 0.1; // Small delay to allow frame update
    if !([] call MyFunctions_fnc_initMissionVariables) then {
        diag_log "ERROR: Failed to initialize mission variables";
    };
    
    // Continue with rest of initialization
    diag_log "INFO: Proceeding with mission components setup";
    
    // Add delay to ensure variables are synchronized
    sleep 0.5;

    // Create respawn point
    diag_log "INFO: Creating respawn point";
    private _respawnMarker = [[6512.16,4002.02,0], west, "respawn_west", "BLUFOR Base"] call MyFunctions_fnc_createRespawnPosition;
    if (_respawnMarker == "") exitWith {
        diag_log "ERROR: Failed to create respawn position";
        false
    };

    // Log respawn marker creation
    diag_log format ["INFO: Respawn marker created: %1", _respawnMarker];

    // Initialize arsenal
    private _baseArsenalItems = missionNamespace getVariable ["base_arsenal_items", []];
    if !(count _baseArsenalItems > 0) exitWith {
        diag_log "ERROR: Failed to retrieve base arsenal items";
        false
    };

    diag_log format ["INFO: Base arsenal items: %1", _baseArsenalItems];
    [[13284.9,13751.4,0], _baseArsenalItems, "player_arsenal", "C_IDAP_supplyCrate_F"] call MyFunctions_fnc_spawnLimitedAceArsenal;
    missionNamespace setVariable ["active_arsenal_items", _baseArsenalItems, true];

    // Log arsenal initialization
    diag_log "INFO: Arsenal initialized";

    // Initialise parent tasks
    private _taskConfigs = [
        [
            "alphaTasking",
            "Alpha Operations",
            "Clear and secure initial areas of operation"
        ],
        [
            "bravoTasking",
            "Bravo Operations",
            "Gather intelligence on enemy activities"
        ],
        [
            "charlieTasking",
            "Charlie Operations",
            "Locate the enemy resource dumps"
        ]
    ];

    {
        _x params ["_taskId", "_taskName", "_taskDesc"];
        
        private _parentTask = [
            west,
            _taskId,
            [_taskDesc, _taskName],
            [0,0,0],
            "CREATED",
            "documents",
            false
        ] call MyFunctions_fnc_createTask;
        
        if (_parentTask == "") exitWith {
            diag_log format ["ERROR: Failed to create parent task: %1", _taskId];
            false
        };
        
        diag_log format ["INFO: Created parent task: %1", _taskId];
    } forEach _taskConfigs;

    // Log task initialization
    diag_log "INFO: Parent tasks initialized";

    private _discoveredLzs = [
        [[10616.3,13245.2,0], "Alpha 1",true],
        [[14348.5,8497.76,0], "Bravo 1", false],
        [[8174.43,13554,0], "Charlie 1",true]
    ];

    {
        _x call MyFunctions_fnc_spawnDiscoveredLz;
    } forEach _discoveredLzs;

    private _discoverableLzs = [
        [[10920.2,12813.6,0], "Alpha 2",true],
        [[11072.7,11507.5,0], "Alpha 3",false],
        [[10632.3,11047.5,0], "Alpha 4",true],
        [[13341.4,8309.8,0], "Bravo 2", true],
        [[12815.5,9415.87,0], "Bravo 3", true],
        [[12405.1,9635.58,0], "Bravo 4", true],
        [[8344.72,12810.3,0], "Charlie 2",true],
        [[8119.9,11976.7,0], "Charlie 3",false],
        [[8481.96,10703.8,0], "Charlie 4",false]
    ];

    {
        _x call MyFunctions_fnc_spawnDiscoverableLz;
    } forEach _discoverableLzs;


    // Log LZ initialization
    diag_log "INFO: Discoverable LZs initialized";

    // Initialize first task
    if !([] call MyFunctions_fnc_initTasks) exitWith {
        diag_log "ERROR: Failed to initialize tasks";
        false
    };

    missionNamespace setVariable ["mission_started", true, true];

    // Final initialization checks
    if (isNil "mission_started") then {
        diag_log "ERROR: mission_started variable not set";
        false
    };

    diag_log "INFO: Mission initialization complete";
};

true