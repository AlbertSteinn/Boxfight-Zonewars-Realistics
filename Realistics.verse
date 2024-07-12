using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
                    

RealisticsTag := class(subtag) {}
ControllerTagA := class<final>(RealisticsTag) {}
ControllerTagB := class<final>(RealisticsTag) {}
ControllerTagC := class<final>(RealisticsTag) {}

realistics := class<concrete>(storm_game_mode):
    @editable
    Loadout:loadout = loadout{}
    @editable
    ThirtyPercentItemSpawner:item_spawner_device = item_spawner_device{}
    @editable
    SeventyFiftyPercentItemSpawners:[]item_spawner_device = array{}
    @editable
    NinetyPercentItemSpawners:[]item_spawner_device = array{}
    @editable
    ChairPropManipulators:[]prop_manipulator_device = array{}
    @editable
    Chairs:[]chair_device = array{}

    Tag<override>:RealisticsTag = RealisticsTag{} # Do not remove the RealisticsTag(Important)

    
    Initialize<override>():void =
        Print("Realistics")
        (super:)Initialize()
        spawn {Loadout.GrantLoadout()}
        spawn {SpawnLoot()}
        for:
            Index := 0..Chairs.Length - 1
            PropSeat := prop_seat:
                PropManipulator := ChairPropManipulators[Index]
                Chair := Chairs[Index]
        do {PropSeat.Initialize()}
        
    SetItems<override>():void =
        Print("Controller Index: {ControllerIndex}")
        set Items = Shuffle(
            case(ControllerIndex):
                0 => GetCreativeObjectsWithTag(ControllerTagA{})
                1 => GetCreativeObjectsWithTag(ControllerTagB{})
                _ => GetCreativeObjectsWithTag(ControllerTagC{})
        )

    # Spawns floor loot
    SpawnLoot()<suspends>:void =
        # 30% chance of spawning
        if(GetRandomInt(0, 100) <= 30):
            ThirtyPercentItemSpawner.Enable()
        # 75% chance of spawning
        for:
            ItemSpawner:SeventyFiftyPercentItemSpawners
            GetRandomInt(0, 100) <= 75
        do {ItemSpawner.Enable()}
        # 90% chance of spawning
        for:
            ItemSpawner:NinetyPercentItemSpawners
            GetRandomInt(0, 100) <= 90
        do {ItemSpawner.Enable()}

    Teleport<override>()<suspends>:void =
        (super:)Teleport()
        InitializeStorm()

    # Sets Beacons, then generates storm
    InitializeStorm():void =
        defer:
            GenerateStorm()
        for(Index := 1..StormBeacons.Length - 1):
            var Position:vector3 = vector3{}
            defer:
                if:
                    Rotation := IdentityRotation()
                    StormBeacons[Index].TeleportTo[Position, Rotation]
            if:
                # Phase 2
                Index = 1
                RandomPosition := vector3:
                    X := RandomInterval(StormProps[Index].GetTransform().Translation.X, 5000.0)
                    Y := RandomInterval(StormProps[Index].GetTransform().Translation.Y, 2500.0)
                    Z := StormProps[Index].GetTransform().Translation.Z
            then {set Position = RandomPosition}
            else if:
                # Phase 3
                Index = 2
                RandomPosition := vector3:
                    X := RandomInterval(StormProps[Index].GetTransform().Translation.X, 5000.0)
                    Y := RandomInterval(StormProps[Index].GetTransform().Translation.Y, 3500.0)
                    Z := StormProps[Index].GetTransform().Translation.Z
            then {set Position = RandomPosition}
            else if:
                # Phase 4
                Index = 3
                RandomPosition := vector3:
                    X := RandomInterval(StormProps[Index].GetTransform().Translation.X, 7000.0)
                    Y := RandomInterval(StormProps[Index].GetTransform().Translation.Y, 4000.0)
                    Z := StormProps[Index].GetTransform().Translation.Z
            then {set Position = RandomPosition}

# This class subscribes PropManipulator to Chair Devices
prop_seat := class:
    PropManipulator:prop_manipulator_device = prop_manipulator_device{}
    Chair:chair_device = chair_device{}

    # Subscribes PropManipulator
    Initialize():void =
        PropManipulator.DestroyedEvent.Subscribe(OnPropDestroyed)
        
    # Called when Prop is destroyed
    # Disables Chair Device
    OnPropDestroyed(Agent:agent):void =
        Chair.Disable()


loadout := class<concrete>:
    @editable
    ShotgunGranter:item_granter_device = item_granter_device{}
    @editable
    ARGranter:item_granter_device = item_granter_device{}
    @editable
    SMGGranter:item_granter_device = item_granter_device{}
    @editable
    ExtraGranter:item_granter_device = item_granter_device{}
    @editable
    HealGranter:item_granter_device = item_granter_device{}
    @editable
    TrapGranter:item_granter_device = item_granter_device{}
    @editable
    AmmoGranter:item_granter_device = item_granter_device{}


    # Grants all players random loadouts
    GrantLoadout()<suspends>:void =
        Itemgranters := array:
            ShotgunGranter, ARGranter, SMGGranter, ExtraGranter, HealGranter, TrapGranter
        for(Player:GetPlayers()):
            defer:
                # 25% chance of getting a Trap
                if(GetRandomInt(1, 100) <= 25):
                    TrapGranter.GrantItem(Player)
                AmmoGranter.GrantItem(Player)
                ShotgunGranter.GrantItem(Player)
                HealGranter.GrantItem(Player)
            # Changes current item to a random item
            for(ItemGranter:Itemgranters):
                ItemGranter.CycleToRandomItem(Player)
            Index := GetRandomInt(1, 100)
            # 3-item loadout (20% chance)
            if(Index <= 20):
                # 50% chance of getting an AR or SMG
                if(GetRandomInt(1, 100) <= 50):
                    ARGranter.GrantItem(Player)
                else {SMGGranter.GrantItem(Player)}
            # 5-item loadout (50% chance)
            else if(Index > 50):
                ARGranter.GrantItem(Player)
                SMGGranter.GrantItem(Player)
                ExtraGranter.GrantItem(Player)
            # 4 item loadout (30% chance)
            else:
                Index1 := GetRandomInt(1, 100)
                # 30% chance of getting an AR, no SMG
                if(Index1 <= 30):
                    ARGranter.GrantItem(Player)
                    ExtraGranter.GrantItem(Player)
                # 40% chance of getting both AR and SMG
                else if(Index1 >= 60):
                    ARGranter.GrantItem(Player)
                    SMGGranter.GrantItem(Player)
                # 30% chance of getting an SMG, no AR
                else:
                    SMGGranter.GrantItem(Player)
                    ExtraGranter.GrantItem(Player)
