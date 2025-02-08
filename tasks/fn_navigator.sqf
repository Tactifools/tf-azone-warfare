/*
Function: MyFunctions_fnc_navigator
Author: CharlesJohnMcC

Description:
    Manages mission task flow for multiple teams (Alpha, Bravo, Charlie).
    Controls progression through cache search, arsenal location, and final objectives.
    Handles task creation, team assignments, and parent task relationships.
    Must be executed on server only.

Parameters:
    _currentTask - Task ID to process [String]
                  "" -> Creates initial cache tasks for all teams
                  "*_cache" -> Creates arsenal task for specific team
                  "*_arsenal" -> Creates final task for specific team
    _parentTask  - Parent task ID for task hierarchy [String]
                  "alphaTasking" -> Alpha team tasks
                  "bravoTasking" -> Bravo team tasks
                  "charlieTasking" -> Charlie team tasks

Returns:
    Boolean - True if task navigation successful, false if:
             - Not called on server
             - Invalid task ID provided
             - Task creation fails
             - Parent task mismatch
             - Task phase error

Examples:
    // Initial mission start - creates cache tasks
    [""] call MyFunctions_fnc_navigator;

    // Progress after alpha cache found
    ["alpha_cache", "alphaTasking"] call MyFunctions_fnc_navigator;

    // Create alpha final task
    ["alpha_arsenal", "alphaTasking"] call MyFunctions_fnc_navigator;

Side Effects:
    - Creates team-specific tasks
    - Updates task hierarchy
    - Manages task progression
    - Creates hold actions on objects
    - Updates mission state

Dependencies:
    - MyFunctions_fnc_taskHoldAction
    - MyFunctions_fnc_updateTaskState
    - MyFunctions_fnc_sendGlobalChatMessage
    - MyFunctions_fnc_grantMissionReward
    - MyFunctions_fnc_taskKillHVT
*/

params [["_currentTask", "", [""]], ["_parentTask", "", [""]], ["_succeeded", true, [true, false]]];

waitUntil {!isNil "mission_variables_initialized" && {mission_variables_initialized}};

if(!isServer) exitWith {
    diag_log "ERROR: navigator must be called on server";
    false
};

private _alphaTasking = "alphaTasking";
private _bravoTasking = "bravoTasking";
private _charlieTasking = "charlieTasking";

private _cacheTaskConfigs = [
    [ALPHA_CACHE, "alpha_cache", _alphaTasking],
    [BRAVO_CACHE, "bravo_cache", _bravoTasking],
    [CHARLIE_CACHE, "charlie_cache", _charlieTasking]
];

private _arsenalTaskConfigs = [
    [ALPHA_ARSENAL, "alpha_arsenal"],
    [BRAVO_ARSENAL, "bravo_arsenal"],
    [CHARLIE_ARSENAL, "charlie_arsenal"]
];

private _officerTaskConfigs = [
    [ALPHA_OFFICER, "alpha_officer"],
    [BRAVO_OFFICER, "bravo_officer"],
    [CHARLIE_OFFICER, "charlie_officer"]
];

private _aidWorkerTaskConfigs = [
    [ALPHA_AID_WORKER, "alpha_aid_worker"],
    [BRAVO_AID_WORKER, "bravo_aid_worker"],
    [CHARLIE_AID_WORKER, "charlie_aid_worker"]
];

private _hvtTaskConfigs = [
    [ALPHA_HVT, "alpha_hvt"],
    [BRAVO_HVT, "bravo_hvt"],
    [CHARLIE_HVT, "charlie_hvt"]
];

private _ammoTaskConfigs = [
    [ALPHA_AMMO, "alpha_ammo", "10*10*"],
    [BRAVO_AMMO, "bravo_ammo", "10*10*"],
    [CHARLIE_AMMO, "charlie_ammo", "10*10*"]
];

private _finalTaskConfigs = [
    [ALPHA_LAPTOP, "alpha_laptop", "Hack the Radar", "Locate the radar laptop and disable their comms", "Hack", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa"],
    [BRAVO_WRECK, "bravo_wreck", "Locate the Wreck", "Locate the wreck and search for any useful intel", "Search Wreck", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa"],
    [CHARLIE_LAPTOP, "charlie_laptop", "Hack the Laptop", "We believe the white powder being created in the Tanoa Sugar Factory is not sugar! Locate the shipping Manifest so we can find who is supplying them!", "Hack", "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa"]
];

private _fnc_getPhase = {
    params ["_taskId", ["_delimiter", "_"]];
    _taskId select [0, (_taskId find _delimiter)]
};

switch (_currentTask) do {
    case "": {  // Initial mission start
        diag_log "No current task provided to navigator, navigating to first tasks";
        
        {
            _x params ["_cache", "_taskId", "_parentTaskId"];
            
            [
                _cache,
                [_taskId, _parentTaskId],
                "Locate the Weapons Cache",
                "Locate the weapons cache and search for anything useful",
                "Search Cache",
                3,
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa"
            ] call MyFunctions_fnc_taskHoldAction;
        } forEach _cacheTaskConfigs;
        
        true
    };
    case "alpha_cache";
    case "bravo_cache";
    case "charlie_cache": {
        diag_log format ["Cache task completed: %1", _currentTask];
        
        private _taskPhase = [_currentTask] call _fnc_getPhase;
        private _parentPhase = [_parentTask, "Tasking"] call _fnc_getPhase;
        
        if (_taskPhase == _parentPhase) then {
            {
                _x params ["_arsenal", "_taskId"];
                if ([_taskId] call _fnc_getPhase == _taskPhase) then {
                    [
                        _arsenal,
                        [_taskId, _parentTask],
                        "Locate the Arsenal",
                        "Locate the arsenal and mark for collection",
                        "Mark Arsenal",
                        3,
                        "\a3\missions_f_oldman\data\img\holdactions\holdAction_box_ca.paa"
                    ] call MyFunctions_fnc_taskHoldAction;
                };
            } forEach _arsenalTaskConfigs;
        };
        true
    };
    case "alpha_arsenal";
    case "bravo_arsenal";
    case "charlie_arsenal": {
        diag_log format ["Arsenal task completed: %1", _currentTask];
        
        private _taskPhase = [_currentTask] call _fnc_getPhase;
        private _parentPhase = [_parentTask, "Tasking"] call _fnc_getPhase;
        
        if (_taskPhase == _parentPhase) then {
            {
                _x params ["_officer", "_taskId"];

                if ([_taskId] call _fnc_getPhase == _taskPhase) then {
                    [
                        _officer,
                        [_taskId, _parentTask],
                        "Report to the Officer",
                        "Report back to the officer for further instructions",
                        "Report In",
                        3,
                        "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\meet_ca.paa"
                    ] call MyFunctions_fnc_taskHoldAction;
                };
            } forEach _officerTaskConfigs;
        };

        true
    };
    case "alpha_officer";
    case "bravo_officer";
    case "charlie_officer": {
        diag_log format ["Officer task completed: %1", _currentTask];
        
        private _taskPhase = [_currentTask] call _fnc_getPhase;
        private _parentPhase = [_parentTask, "Tasking"] call _fnc_getPhase;

        [_currentTask] call MyFunctions_fnc_grantMissionReward;
        
        if (_taskPhase == _parentPhase) then {
            {
                _x params ["_aidWorker", "_taskId"];

                if ([_taskId] call _fnc_getPhase == _taskPhase) then {
                    // Store task info on aid worker for EH access
                    _aidWorker setVariable ["taskId", _taskId, true];
                    _aidWorker setVariable ["parentTask", _parentTask, true];
                    
                    [
                        _aidWorker,
                        [_taskId, _parentTask],
                        "Interogate the Aid Worker",
                        "The aid worker may have information on enemy activities",
                        "Interogate",
                        3,
                        "\a3\missions_f_oldman\data\img\holdactions\holdAction_talk_ca.paa"
                    ] call MyFunctions_fnc_taskHoldAction;

                    _aidWorker addEventHandler ["killed", {
                        params ["_unit"];
                        private _taskId = _unit getVariable "taskId";
                        private _parentTask = _unit getVariable "parentTask";
                        
                        [_taskId, "FAILED"] call MyFunctions_fnc_updateTaskState;
                        ["Aid Worker killed!"] call MyFunctions_fnc_sendGlobalChatMessage;
                        
                        // Create next task despite failure
                        [_taskId, _parentTask, false] call MyFunctions_fnc_navigator;
                    }];
                };
            } forEach _aidWorkerTaskConfigs;
        };
        true
    };
    case "alpha_aid_worker";
    case "bravo_aid_worker";
    case "charlie_aid_worker": {
        diag_log format ["Aid Worker task completed: %1", _currentTask];
        
        private _taskPhase = [_currentTask] call _fnc_getPhase;
        private _parentPhase = [_parentTask, "Tasking"] call _fnc_getPhase;
        
        if (_taskPhase == _parentPhase) then {
            {
                _x params ["_hvt", "_taskId"];

                if ([_taskId] call _fnc_getPhase == _taskPhase) then {
                    [
                        _hvt,
                        [_taskId, _parentTask],
                        "Kill the HVT",
                        "Locate and take out that son of a bitch"
                    ] call MyFunctions_fnc_taskKillHVT;
                };
            } forEach _hvtTaskConfigs;
        };
        true
    };
    case "alpha_hvt";
    case "bravo_hvt";
    case "charlie_hvt": {
        diag_log format ["Kill HVT task completed: %1", _currentTask];
        
        private _taskPhase = [_currentTask] call _fnc_getPhase;
        private _parentPhase = [_parentTask, "Tasking"] call _fnc_getPhase;
        
        if (_taskPhase == _parentPhase) then {
            {
                _x params ["_ammo", "_taskId", "_location"];

                if ([_taskId] call _fnc_getPhase == _taskPhase) then {
                    [
                        _ammo,
                        [_taskId, _parentTask],
                        "Locate the ammo dump",
                        format ["We believe there may be an ammo dump somewhere in grid %1", _location],
                        "Mark Ammo Dump",
                        3,
                        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa"
                    ] call MyFunctions_fnc_taskHoldAction;
                };
            } forEach _ammoTaskConfigs;
        };

        true
    };
    case "alpha_ammo";
    case "bravo_ammo";
    case "charlie_ammo": {
        diag_log format ["Ammo Dump task completed: %1", _currentTask];
        
        private _taskPhase = [_currentTask] call _fnc_getPhase;
        private _parentPhase = [_parentTask, "Tasking"] call _fnc_getPhase;
        
        if (_taskPhase == _parentPhase) then {
            {
                _x params ["_object", "_taskId", "_title", "_description", "_action", "_icon"];

                if ([_taskId] call _fnc_getPhase == _taskPhase) then {
                    if (_taskPhase == "bravo") then {
                        [
                            _object,
                            [_taskId, _parentTask],
                            _title,
                            _description,
                            _action,
                            3,
                            _icon
                        ] call MyFunctions_fnc_taskHoldAction;
                    } else {
                        [
                            _object,
                            [_taskId, _parentTask],
                            _title,
                            _description,
                            _action,
                            3,
                            _icon
                        ] call MyFunctions_fnc_taskHackLaptop;
                    };
                };
            } forEach _finalTaskConfigs;
        };

        true
    };
    case "alpha_laptop";
    case "bravo_wreck";
    case "charlie_laptop": {
        diag_log format ["Final task completed: %1", _currentTask];
        
        private _taskPhase = [_currentTask] call _fnc_getPhase;
        private _parentPhase = [_parentTask, "Tasking"] call _fnc_getPhase;
        
        if (_taskPhase == _parentPhase) then {
            diag_log format ["Mission complete for %1 team", _taskPhase];
            true
        };
        
        false
    };

    default {  // Error handling
        diag_log format ["Unknown task: %1", _currentTask];
        false
    };
};