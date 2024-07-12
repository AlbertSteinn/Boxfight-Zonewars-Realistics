using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


subtag := class(tag) {}

game_mode := class<abstract>:
    @editable
    WinAccolade:accolades_device = accolades_device{}
    @editable
    PlacementAccolades:[]accolades_device = array{}

    Tag:subtag

    var Items:[]creative_object_interface = array{}
    var Players:[]player = array{}
    

    Initialize():void =
        set Players = GetPlayers()
        SetItems()
        spawn {Teleport()}

    SetItems():void =
        set Items = Shuffle(GetCreativeObjectsWithTag(Tag))
        
    # Teleports Players to GameMode Location
    Teleport()<suspends>:void =
        Rifts :=
            for(Item:Items, Rift := teleporter_device[Item]):
                Rift
        Print("Rifting Players")
        for:
            Index := 0..Players.Length - 1
            Rift := Rifts[Index]
            Player := Players[Index]
        do {Rift.Teleport(Player)}


storm_game_mode := class<abstract>(game_mode):
    @editable
    StormProps:[]creative_prop = array{}
    @editable
    StormBeacons:[]advanced_storm_beacon_device = array{}
    @editable
    StormControllers:[]advanced_storm_controller_device = array{}

    var ControllerIndex:int = 0

    Initialize<override>():void =
        set ControllerIndex = GetRandomInt(0, StormControllers.Length - 1)
        (super:)Initialize()
        

    # Generates Storm
    GenerateStorm():void =
        if:     
            StormController := StormControllers[ControllerIndex]
            StormProps[0].TeleportTo[StormController.GetTransform()]
            StormBeacons[0].TeleportTo[StormProps[0].GetTransform()]
        then {StormController.GenerateStorm()}

