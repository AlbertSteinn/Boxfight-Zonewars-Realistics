using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# This class subscribes Triggers to Switches
trigger_switch := class:
    Trigger:trigger_device = trigger_device{}
    Switch:switch_device = switch_device{}

    # Subscribes Trigger
    Initialize():void =
        Trigger.TriggeredEvent.Subscribe(OnInteractingWithTrigger)

    # Called when Trigger is triggered
    # Toggles Switch
    OnInteractingWithTrigger(Agent:?agent):void =
        if(Player := player[Agent?]):
            Switch.ToggleState(Player)
            

hub := class<concrete>:
    @editable
    SpawnPads:[]player_spawner_device = array{}
    @editable
    ElimAccolade:accolades_device = accolades_device{}
    @editable
    ModeSwitches:[]switch_device = array{}
    @editable
    ModeTriggers:[]trigger_device = array{}
    @editable
    ModeTracker:[]tracker_device = array{}

    # ModeSwitch devices
    var BoxfightSwitch:?switch_device = false
    var ZoneWarsSwitch:?switch_device = false
    var RealisticsSwitch:?switch_device = false

    # Array of Players Who Voted
    var BoxfightVoters:[]agent = array{}
    var ZoneWarsVoters:[]agent = array{}
    var RealisticsVoters:[]agent = array{}


    # Round 1 resets the Mode trackers to 0
    # 0 - off, 1 - on

    Initialize():void =
        InitializeModeSwitches()
        GetPlayerRemovedEvent().Subscribe(OnPlayerLeaving)
        for(SpawnPad:SpawnPads):
            SpawnPad.SpawnedEvent.Subscribe(OnPlayerSpawned)
        for:
            Index := 0..ModeSwitches.Length - 1
            TriggerSwitch := trigger_switch:
                Trigger := ModeTriggers[Index]
                Switch := ModeSwitches[Index]
        # Subscribe each switch and trigger
        do {TriggerSwitch.Initialize()}
        
    # Initializes ModeSwitches
    InitializeModeSwitches():void =
        set BoxfightSwitch = option{ModeSwitches[0]}
        set ZoneWarsSwitch = option{ModeSwitches[1]}
        set RealisticsSwitch = option{ModeSwitches[2]}
        option:
            BoxfightSwitch?.TurnedOnEvent.Subscribe(OnBoxfightSwitchTurnedOn)
            BoxfightSwitch?.TurnedOffEvent.Subscribe(OnBoxfightSwitchTurnedOff)
            ZoneWarsSwitch?.TurnedOnEvent.Subscribe(OnZoneWarsSwitchTurnedOn)
            ZoneWarsSwitch?.TurnedOffEvent.Subscribe(OnZoneWarsSwitchTurnedOff)
            RealisticsSwitch?.TurnedOnEvent.Subscribe(OnRealisticsSwitchTurnedOn)
            RealisticsSwitch?.TurnedOffEvent.Subscribe(OnRealisticsSwitchTurnedOff)

    # Adds Player to BoxfightVoters list
    OnBoxfightSwitchTurnedOn(Agent:agent):void =
        set BoxfightVoters += array{Agent}

    # Removes Player from BoxfightVoters list
    OnBoxfightSwitchTurnedOff(Agent:agent):void =
        if(Array := BoxfightVoters.RemoveFirstElement[Agent]):
            set BoxfightVoters = Array

    # Adds Player to ZoneWarsVoters list
    OnZoneWarsSwitchTurnedOn(Agent:agent):void =
        set ZoneWarsVoters += array{Agent}

    # Removes Player from ZoneWarsVoters list
    OnZoneWarsSwitchTurnedOff(Agent:agent):void =
        if(Array := ZoneWarsVoters.RemoveFirstElement[Agent]):
            set ZoneWarsVoters = Array

    # Adds Player to RealisticsVoters list
    OnRealisticsSwitchTurnedOn(Agent:agent):void =
        set RealisticsVoters += array{Agent}

    # Removes Player from RealisticsVoters list
    OnRealisticsSwitchTurnedOff(Agent:agent):void =
        if(Array := RealisticsVoters.RemoveFirstElement[Agent]):
            set RealisticsVoters = Array

    # Compares the vote to majority and adds the mode is successful
    HandleVotingResults(Voters:[]agent):void =
        TotalPlayers := GetPlayers().Length
        var SimpleMajorityThreshold:float = (TotalPlayers * 1.0) / 2.0
        if(Voters.Length * 1.0 > SimpleMajorityThreshold):
            # Add mode to list
        else if:
            Voters.Length * 1.0 = SimpleMajorityThreshold
            GetRandomInt(1, 100) <= 50
        then:
            # Add mode to list

    MakeModeDecision():void =
        HandleVotingResults(BoxfightVoters)
        HandleVotingResults(ZoneWarsVoters)
        HandleVotingResults(RealisticsVoters)

    # Removes Player from All Voters list 
    OnPlayerLeaving(Agent:agent):void = 
        OnBoxfightSwitchTurnedOff(Agent)
        OnZoneWarsSwitchTurnedOff(Agent)
        OnRealisticsSwitchTurnedOff(Agent)

    # Subscribes Players
    OnPlayerSpawned(Agent:agent):void =
        if(FortCharacter := Agent.GetFortCharacter[]):
            FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
        

    # Grants Accolade XP to Player that eliminated `EliminatedCharacter`
    OnPlayerEliminated(Result:elimination_result):void =
        if(Agent := Result.EliminatingCharacter?.GetAgent[]):
            ElimAccolade.Award(Agent)