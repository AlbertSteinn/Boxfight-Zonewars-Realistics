using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

BoxfightTag := class(subtag) {}

boxfight := class<concrete>(game_mode):
    @editable
    Rifts:[]teleporter_device = array{}
    @editable
    Barriers:[]barrier_device = array{}
    @editable
    Timer:timer_device = timer_device{}
    @editable
    AudioPlayer:audio_player_device = audio_player_device{}
    @editable
    StormController:basic_storm_controller_device = basic_storm_controller_device{}
    @editable
    WeaponGranter:item_granter_device = item_granter_device{}

    Tag<override>:BoxfightTag = BoxfightTag{} # Do not remove the BoxfightTag(Important)

    Initialize<override>():void =
        Print("Boxfight")
        (super:)Initialize()
        Timer.SuccessEvent.Subscribe(OnTimerCompleted)
        SubscribeRifts()

    SubscribeRifts():void =
        Print("Subbing Rifts")
        for:
            Index := 0..Rifts.Length - 1
            RiftBarrier := rift_barrier:
                Rift := Rifts[Index]
                Barrier := Barriers[Index]   
        do{RiftBarrier.Initialize()}

    Teleport<override>()<suspends>:void =
        (super:)Teleport()
        GrantWeapons(WeaponGranter)
        Timer.Start()
        
    # Disables Barriers
    # Generates Storm
    OnTimerCompleted(Agent:?agent):void =
        AudioPlayer.Play()
        InitializeStorm()
        for(Barrier:Barriers):
            Barrier.Disable()

    InitializeStorm():void =
        if:
            Position := vector3:
                X := RandomInterval(StormController.GetTransform().Translation.X, 300.0)
                Y := RandomInterval(StormController.GetTransform().Translation.Y, 300.0)
                Z := StormController.GetTransform().Translation.Z
            Rotation := IdentityRotation()
            StormController.TeleportTo[Position, Rotation]
        then {StormController.GenerateStorm()}

# This class subscribes Rift to Barrier
rift_barrier := class:
    Rift:teleporter_device = teleporter_device{}
    Barrier:barrier_device = barrier_device{}

    # Subscribes Rift
    Initialize():void =
        Print("Rift Inititialized")
        Rift.TeleportedEvent.Subscribe(OnPlayerTeleported)
        
    # Called when Player is Teleported
    # Enables Barrier
    OnPlayerTeleported(Agent:agent):void =
        Barrier.Enable()
        Print("Rift Enabled")