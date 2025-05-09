-- ********************************************
--
--                  Alluagator
--
-- ********************************************


function OnGameStart()
    Setup()

    QuickObjective("An arid land in the shape of a dragon. Heroes and another Keeper are vying for control over this realm. Show them who truly deserves to rule here.", PLAYER0)
end


function Setup()
    SetGenerateSpeed(350)

    MaxCreatures(PLAYER0, 25)
    MaxCreatures(PLAYER1, 25)

    StartMoney(PLAYER0, 20000)
    StartMoney(PLAYER1, 60000)

    AddCreatureToPool("FLY", 8)
    AddCreatureToPool("BUG", 8)
    AddCreatureToPool("SPIDER", 8)
    AddCreatureToPool("TENTACLE", 8)
    AddCreatureToPool("SORCEROR", 8)
    AddCreatureToPool("DEMONSPAWN", 8)
    AddCreatureToPool("BILE_DEMON", 3)
    AddCreatureToPool("DRAGON", 3)
    AddCreatureToPool("TROLL", 8)
    AddCreatureToPool("ORC", 8)
    AddCreatureToPool("DARK_MISTRESS", 8)
    AddCreatureToPool("HELL_HOUND", 8)

    CreatureAvailable("ALL_PLAYERS", "FLY", true, 0)
    CreatureAvailable("ALL_PLAYERS", "BUG", true, 0)
    CreatureAvailable("ALL_PLAYERS", "SPIDER", true, 0)
    CreatureAvailable("ALL_PLAYERS", "TENTACLE", true, 0)
    CreatureAvailable("ALL_PLAYERS", "SORCEROR", true, 0)
    CreatureAvailable("ALL_PLAYERS", "DEMONSPAWN", true, 0)
    CreatureAvailable("PLAYER1", "BILE_DEMON", true, 0)
    CreatureAvailable("PLAYER1", "DRAGON", true, 0)
    CreatureAvailable("ALL_PLAYERS", "TROLL", true, 0)
    CreatureAvailable("ALL_PLAYERS", "ORC", true, 0)
    CreatureAvailable("ALL_PLAYERS", "DARK_MISTRESS", true, 0)
    CreatureAvailable("ALL_PLAYERS", "HELL_HOUND", true, 0)

    RoomAvailable("ALL_PLAYERS", "TREASURE", 2, true)
    RoomAvailable("ALL_PLAYERS", "LAIR", 2, true)
    RoomAvailable("ALL_PLAYERS", "GARDEN", 2, true)
    RoomAvailable("ALL_PLAYERS", "TRAINING", 2, true)
    RoomAvailable("ALL_PLAYERS", "RESEARCH", 2, true)

    RoomAvailable("ALL_PLAYERS", "BRIDGE", 2, false)
    RoomAvailable("ALL_PLAYERS", "GUARD_POST", 2, false)
    RoomAvailable("ALL_PLAYERS", "WORKSHOP", 2, false)
    RoomAvailable("ALL_PLAYERS", "BARRACKS", 2, false)
    RoomAvailable("PLAYER0", "PRISON", 3, false)
    RoomAvailable("PLAYER1", "PRISON", 2, false)
    RoomAvailable("ALL_PLAYERS", "TORTURE", 2, false)
    RoomAvailable("ALL_PLAYERS", "TEMPLE", 2, false)
    RoomAvailable("ALL_PLAYERS", "GRAVEYARD", 2, false)
    RoomAvailable("ALL_PLAYERS", "SCAVENGER", 2, false)

    -- Found in level: Lightning
    MagicAvailable("ALL_PLAYERS", "POWER_IMP", true, true)
    MagicAvailable("ALL_PLAYERS", "POWER_SIGHT", true, true)
    MagicAvailable("ALL_PLAYERS", "POWER_SPEED", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_OBEY", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_CALL_TO_ARMS", true, true)
    MagicAvailable("ALL_PLAYERS", "POWER_CONCEAL", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_HOLD_AUDIENCE", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_HEAL_CREATURE", true, true)
    MagicAvailable("PLAYER1", "POWER_LIGHTNING", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_PROTECT", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_CHICKEN", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_DISEASE", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_ARMAGEDDON", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_DESTROY_WALLS", true, false)

    -- Doors
    DoorAvailable("ALL_PLAYERS", "WOOD", true, 0)
    DoorAvailable("ALL_PLAYERS", "BRACED", true, 0)
    DoorAvailable("ALL_PLAYERS", "STEEL", true, 0)
    DoorAvailable("ALL_PLAYERS", "MAGIC", true, 0)
    DoorAvailable("ALL_PLAYERS", "SECRET", true, 0)
    DoorAvailable("ALL_PLAYERS", "MIDAS", true, 0)

    -- Traps
    TrapAvailable("PLAYER0", "ALARM", true, 0)
    TrapAvailable("ALL_PLAYERS", "POISON_GAS", true, 0)
    TrapAvailable("ALL_PLAYERS", "LIGHTNING", true, 0)
    TrapAvailable("ALL_PLAYERS", "LAVA", true, 0)
    TrapAvailable("ALL_PLAYERS", "WORD_OF_POWER", true, 0)
    TrapAvailable("ALL_PLAYERS", "BOULDER", true, 0)
    TrapAvailable("ALL_PLAYERS", "TNT", true, 0)

    -- Give Ranged Heal to Monks.
    SetCreatureInstance("MONK", 6, "RANGED_HEAL", 2)

    -- Make the final Knight more powerful.
    RunDKScriptCommand("Set_creature_configuration(KNIGHT, Health, 2000)")
    RunDKScriptCommand("Set_creature_configuration(KNIGHT, Strength, 150)")

    -- Imps gain experience over time and return knocked out allied creatures.
    SetGameRule("ImpWorkExperience", 512)
    SetGameRule("DragUnconsciousToLair", 2)

    SetupComputer()
    SetupHeroParties()
    CreateTriggers()
end


function SetupComputer()
    -- Defensive Skirmish AI that switches to an aggressive AI after 20 minutes.
    ComputerPlayer(PLAYER1, 13)

    RegisterTimerEvent(function() ComputerPlayer(PLAYER1, 16) end, 24000, false)
end


function SetupHeroParties()
    CreateParty("Scouts")
    AddToParty("Scouts", "ARCHER", 1, 250, "ATTACK_DUNGEON_HEART", 0)
    AddToParty("Scouts", "THIEF", 1, 500, "ATTACK_DUNGEON_HEART", 0)

    CreateParty("Brutes")
    AddToParty("Brutes", "GIANT", 2, 250, "ATTACK_ENEMIES", 0)
    AddToParty("Brutes", "BARBARIAN", 1, 250, "ATTACK_ENEMIES", 0)
    AddToParty("Brutes", "BARBARIAN", 1, 250, "ATTACK_ENEMIES", 0)

    CreateParty("DND")
    AddToParty("DND", "WIZARD", 5, 500, "ATTACK_ENEMIES", 0)
    AddToParty("DND", "DWARFA", 4, 250, "ATTACK_ENEMIES", 0)
    AddToParty("DND", "ARCHER", 3, 250, "ATTACK_ENEMIES", 0)
    AddToParty("DND", "MONK", 2, 250, "ATTACK_ENEMIES", 0)

    CreateParty("Landlord")
    AddToParty("Landlord", "KNIGHT", 8, 5000, "ATTACK_DUNGEON_HEART", 1000)
    AddToParty("Landlord", "ARCHER", 8, 500, "DEFEND_PARTY", 1000)
    AddToParty("Landlord", "MONK", 6, 0, "DEFEND_PARTY", 1000)
    AddToParty("Landlord", "MONK", 6, 0, "DEFEND_PARTY", 1000)
    AddToParty("Landlord", "WIZARD", 5, 1000, "DEFEND_PARTY", 1000)
end


function CreateTriggers()
    -- Make sure computer never quite runs out of Gold
    RegisterOnConditionEvent(function() PLAYER1.MONEY = 2000 end,
                            function() return (PLAYER1.MONEY < 2000) end)
--
--    -- Set up a list of hero parties to spawn at specified times.
--    -- First, connect the hero gates to the player dungeons and open up the map.
    RegisterTimerEvent(function () AddTunnellerPartyToLevel(PLAYER_GOOD, "Scouts", -4, "DUNGEON_HEART", 1, 1, 250) end, 6000, false)
--
--
    RegisterTimerEvent(function () AddTunnellerPartyToLevel(PLAYER_GOOD, "Scouts", -4, "DUNGEON_HEART", 1, 1, 250) end, 6000, false)
--
--
    RegisterTimerEvent(function () AddTunnellerPartyToLevel(PLAYER_GOOD, "Scouts", -3, "DUNGEON_HEART", 0, 1, 250)end , 7000, false)
    RegisterTimerEvent(function () AddPartyToLevel(PLAYER_GOOD, "Brutes", -4) end,8000, false)
    RegisterTimerEvent(function () AddPartyToLevel(PLAYER_GOOD, "Brutes", -3) end,9000, false)
    RegisterTimerEvent(function () AddTunnellerPartyToLevel(PLAYER_GOOD, "Scouts", -1, "DUNGEON", 0, 3, 250) end, 10000, false)
    RegisterTimerEvent(function () AddPartyToLevel(PLAYER_GOOD, "Brutes", -1) end, 11000, false)
    RegisterTimerEvent(function () AddPartyToLevel(PLAYER_GOOD, "DND", -4) end, 12000, false)
--
    ---- Open up the White Dungeon at 15 minutes into the game.
    ---- This lets the player access the Prison.
    RegisterTimerEvent(function () AddTunnellerPartyToLevel(PLAYER_GOOD, "Scouts", -2, "APPROPRIATE_DUNGEON", 0, 3, 250) end, 19000, false)
--
    ---- Start regular waves of heroes that come from random gates.
    RegisterTimerEvent(StartPeriodicWaves, 20000, false)

    -- Spawn defenders when the player reaches the White Dungeon Heart.
    RegisterOnActionPointEvent(FoundHeroHeart, 1, PLAYER0)

    -- Simple victory condition: Destroy both enemy dungeon hearts.
    RegisterOnConditionEvent(WinGame,
                            function() return (PLAYER_GOOD.DUNGEON_DESTROYED >= 1) and (PLAYER1.DUNGEON_DESTROYED >= 1) end)
end


function StartPeriodicWaves()
    -- Create a trigger that runs the SpawnPeriodicWave function every 5000 ticks...
    local SpawnTrigger = RegisterTimerEvent(SpawnPeriodicWave, 5000, true)
    -- ...as long as the White Dungeon Heart is still alive.
    TriggerAddCondition(SpawnTrigger, function() return PLAYER_GOOD.DUNGEON_DESTROYED < 1 end)
end


function SpawnPeriodicWave()
    local gatenum = math.random(-1,-4)
    AddPartyToLevel(PLAYER_GOOD, "DND", gatenum)
end


function FoundHeroHeart()
    QuickInformation(2, "The heroes' dungeon heart lies exposed. Destroy it!", 1)
    AddPartyToLevel(PLAYER_GOOD, "Landlord", 1)
    AddPartyToLevel(PLAYER_GOOD, "DND", -2)
end



function magic_use_power_teleport_orc_to_heart(player,power_kind,power_level,stl_x,stl_y,thing,is_free)

    if (thing.model ~= "ORC") then
        -- 0 means power simply doesn't have a valid target, so so simply does nothing
        return 0
    end

    --pay for the power, the function will return false if the player doesn't have enough gold
    if (not PayForPower(player, power_kind, power_level, is_free)) then

        -- -1 means it failed, and will make a reject sound
        return -1
    end

    --player here is used as a location, so it will teleport the player to the heart
    thing:teleport(player, "EFFECT_EXPLOSION_4")

    -- 1 means it was cast successfully
    return 1
end