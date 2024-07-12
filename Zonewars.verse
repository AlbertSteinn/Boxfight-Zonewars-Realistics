using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

ZonewarsTag := class(subtag) {}

zonewars := class<concrete>(storm_game_mode):
    @editable
    Timer:timer_device = timer_device{}
    @editable
    WeaponGranter:item_granter_device = item_granter_device{}
    @editable
    Barrier:barrier_device = barrier_device{}
    
    Tag<override>:ZonewarsTag = ZonewarsTag{} # Do not remove the ZonewarsTag(Important)

    Initialize<override>():void =
        Print("Zonewars")
        (super:)Initialize()
        Timer.SuccessEvent.Subscribe(OnTimerCompleted)

    # Disables Barriers
    # Generates Storm
    OnTimerCompleted(Agent:?agent):void =
        InitializeStorm()
        Barrier.Disable()

    Teleport<override>()<suspends>:void =
        (super:)Teleport()
        GrantWeapons(WeaponGranter)
        Timer.Start()
        
    # Sets Beacons, then generates storm
    InitializeStorm():void =
        defer:
            GenerateStorm()
        for:
            Index := 1..StormBeacons.Length - 1
            Position := vector3:
                X := RandomInterval(StormProps[Index].GetTransform().Translation.X, 1000.0)
                Y := RandomInterval(StormProps[Index].GetTransform().Translation.Y, 2500.0)
                Z := StormProps[Index].GetTransform().Translation.Z
            Rotation := IdentityRotation()
            StormBeacons[Index].TeleportTo[Position, Rotation]
            Beacon := StormBeacons[Index]
        do {Print("Beacon {Index} := {Beacon.GetTransform().Translation}")}
        
