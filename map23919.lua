-- ********************************************
--
--                  Alluagator
--
-- ********************************************


function OnGameStart()
    Setup()

    QUICK_OBJECTIVE("An arid land in the shape of a dragon. Heroes and another Keeper are vying for control over this realm. Show them who truly deserves to rule here.", PLAYER0)
end


function Setup()
    SET_GENERATE_SPEED(350)

    MAX_CREATURES(PLAYER0, 25)
    MAX_CREATURES(PLAYER1, 25)

    START_MONEY(PLAYER0, 20000)
    START_MONEY(PLAYER1, 60000)

    ADD_CREATURE_TO_POOL("FLY", 8)
    ADD_CREATURE_TO_POOL("BUG", 8)
    ADD_CREATURE_TO_POOL("SPIDER", 8)
    ADD_CREATURE_TO_POOL("TENTACLE", 8)
    ADD_CREATURE_TO_POOL("SORCEROR", 8)
    ADD_CREATURE_TO_POOL("DEMONSPAWN", 8)
    ADD_CREATURE_TO_POOL("BILE_DEMON", 3)
    ADD_CREATURE_TO_POOL("DRAGON", 3)
    ADD_CREATURE_TO_POOL("TROLL", 8)
    ADD_CREATURE_TO_POOL("ORC", 8)
    ADD_CREATURE_TO_POOL("DARK_MISTRESS", 8)
    ADD_CREATURE_TO_POOL("HELL_HOUND", 8)

    CREATURE_AVAILABLE("ALL_PLAYERS", "FLY", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "BUG", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "SPIDER", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "TENTACLE", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "SORCEROR", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "DEMONSPAWN", true, 0)
    CREATURE_AVAILABLE("PLAYER1", "BILE_DEMON", true, 0)
    CREATURE_AVAILABLE("PLAYER1", "DRAGON", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "TROLL", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "ORC", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "DARK_MISTRESS", true, 0)
    CREATURE_AVAILABLE("ALL_PLAYERS", "HELL_HOUND", true, 0)

    ROOM_AVAILABLE("ALL_PLAYERS", "TREASURE", 2, true)
    ROOM_AVAILABLE("ALL_PLAYERS", "LAIR", 2, true)
    ROOM_AVAILABLE("ALL_PLAYERS", "GARDEN", 2, true)
    ROOM_AVAILABLE("ALL_PLAYERS", "TRAINING", 2, true)
    ROOM_AVAILABLE("ALL_PLAYERS", "RESEARCH", 2, true)

    ROOM_AVAILABLE("ALL_PLAYERS", "BRIDGE", 2, false)
    ROOM_AVAILABLE("ALL_PLAYERS", "GUARD_POST", 2, false)
    ROOM_AVAILABLE("ALL_PLAYERS", "WORKSHOP", 2, false)
    ROOM_AVAILABLE("ALL_PLAYERS", "BARRACKS", 2, false)
    ROOM_AVAILABLE("PLAYER0", "PRISON", 3, false)
    ROOM_AVAILABLE("PLAYER1", "PRISON", 2, false)
    ROOM_AVAILABLE("ALL_PLAYERS", "TORTURE", 2, false)
    ROOM_AVAILABLE("ALL_PLAYERS", "TEMPLE", 2, false)
    ROOM_AVAILABLE("ALL_PLAYERS", "GRAVEYARD", 2, false)
    ROOM_AVAILABLE("ALL_PLAYERS", "SCAVENGER", 2, false)

    -- Found in level: Lightning
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_IMP", true, true)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_SIGHT", true, true)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_SPEED", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_OBEY", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_CALL_TO_ARMS", true, true)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_CONCEAL", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_HOLD_AUDIENCE", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_HEAL_CREATURE", true, false)
    MAGIC_AVAILABLE("PLAYER1", "POWER_LIGHTNING", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_PROTECT", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_CHICKEN", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_DISEASE", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_ARMAGEDDON", true, false)
    MAGIC_AVAILABLE("ALL_PLAYERS", "POWER_DESTROY_WALLS", true, false)

    -- Doors
    DOOR_AVAILABLE("ALL_PLAYERS", "WOOD", true, 0)
    DOOR_AVAILABLE("ALL_PLAYERS", "BRACED", true, 0)
    DOOR_AVAILABLE("ALL_PLAYERS", "STEEL", true, 0)
    DOOR_AVAILABLE("ALL_PLAYERS", "MAGIC", true, 0)
    DOOR_AVAILABLE("ALL_PLAYERS", "SECRET", true, 0)
    DOOR_AVAILABLE("ALL_PLAYERS", "MIDAS", true, 0)

    -- Traps
    TRAP_AVAILABLE("PLAYER0", "ALARM", true, 0)
    TRAP_AVAILABLE("ALL_PLAYERS", "POISON_GAS", true, 0)
    TRAP_AVAILABLE("ALL_PLAYERS", "LIGHTNING", true, 0)
    TRAP_AVAILABLE("ALL_PLAYERS", "LAVA", true, 0)
    TRAP_AVAILABLE("ALL_PLAYERS", "WORD_OF_POWER", true, 0)
    TRAP_AVAILABLE("ALL_PLAYERS", "BOULDER", true, 0)
    TRAP_AVAILABLE("ALL_PLAYERS", "TNT", true, 0)

    -- Give Ranged Heal to Monks.
    SET_CREATURE_INSTANCE("MONK", 6, "RANGED_HEAL", 2)

    -- Make the final Knight more powerful.
    RunDKScriptCommand("SET_CREATURE_CONFIGURATION(KNIGHT, Health, 2000)")
    RunDKScriptCommand("SET_CREATURE_CONFIGURATION(KNIGHT, Strength, 150)")

    -- Imps gain experience over time and return knocked out allied creatures.
    SET_GAME_RULE("ImpWorkExperience", 512)
    SET_GAME_RULE("DragUnconsciousToLair", 2)

    SetupComputer()
    SetupHeroParties()
    CreateTriggers()
end


function SetupComputer()
    -- Defensive Skirmish AI that switches to an aggressive AI after 20 minutes.
    COMPUTER_PLAYER(PLAYER1, 13)

    RegisterTimerEvent(function() COMPUTER_PLAYER(PLAYER1, 16) end, 24000, false)
end


function SetupHeroParties()
    CREATE_PARTY("Scouts")
    ADD_TO_PARTY("Scouts", "ARCHER", 1, 250, "ATTACK_DUNGEON_HEART", 0)
    ADD_TO_PARTY("Scouts", "THIEF", 1, 500, "ATTACK_DUNGEON_HEART", 0)

    CREATE_PARTY("Brutes")
    ADD_TO_PARTY("Brutes", "GIANT", 2, 250, "ATTACK_ENEMIES", 0)
    ADD_TO_PARTY("Brutes", "BARBARIAN", 1, 250, "ATTACK_ENEMIES", 0)
    ADD_TO_PARTY("Brutes", "BARBARIAN", 1, 250, "ATTACK_ENEMIES", 0)

    CREATE_PARTY("DND")
    ADD_TO_PARTY("DND", "WIZARD", 5, 500, "ATTACK_ENEMIES", 0)
    ADD_TO_PARTY("DND", "DWARFA", 4, 250, "ATTACK_ENEMIES", 0)
    ADD_TO_PARTY("DND", "ARCHER", 3, 250, "ATTACK_ENEMIES", 0)
    ADD_TO_PARTY("DND", "MONK", 2, 250, "ATTACK_ENEMIES", 0)

    CREATE_PARTY("Landlord")
    ADD_TO_PARTY("Landlord", "KNIGHT", 8, 5000, "ATTACK_DUNGEON_HEART", 1000)
    ADD_TO_PARTY("Landlord", "ARCHER", 8, 500, "DEFEND_PARTY", 1000)
    ADD_TO_PARTY("Landlord", "MONK", 6, 0, "DEFEND_PARTY", 1000)
    ADD_TO_PARTY("Landlord", "MONK", 6, 0, "DEFEND_PARTY", 1000)
    ADD_TO_PARTY("Landlord", "WIZARD", 5, 1000, "DEFEND_PARTY", 1000)
end


function CreateTriggers()
    -- Make sure computer never quite runs out of Gold
    RegisterOnConditionEvent(function() PLAYER1.MONEY = 2000 end,
                            function() return (PLAYER1.MONEY < 2000) end)
--
--    -- Set up a list of hero parties to spawn at specified times.
--    -- First, connect the hero gates to the player dungeons and open up the map.
    RegisterTimerEvent(ADD_TUNNELLER_PARTY_TO_LEVEL, 6000, false,{PLAYER_GOOD, "Scouts", -4, "DUNGEON_HEART", 1, 1, 250})


    RegisterTimerEvent(ADD_TUNNELLER_PARTY_TO_LEVEL, 6000, false, {PLAYER_GOOD, "Scouts", -4, "DUNGEON_HEART", 1, 1, 250})


    RegisterTimerEvent(ADD_TUNNELLER_PARTY_TO_LEVEL, 7000, false,{PLAYER_GOOD, "Scouts", -3, "DUNGEON_HEART", 0, 1, 250})
    RegisterTimerEvent(ADD_PARTY_TO_LEVEL, 8000, false,{PLAYER_GOOD, "Brutes", -4})
    RegisterTimerEvent(ADD_PARTY_TO_LEVEL, 9000, false,{PLAYER_GOOD, "Brutes", -3})
    RegisterTimerEvent(ADD_TUNNELLER_PARTY_TO_LEVEL, 10000, false,{PLAYER_GOOD, "Scouts", -1, "DUNGEON", 0, 3, 250})
    RegisterTimerEvent(ADD_PARTY_TO_LEVEL, 11000, false,{PLAYER_GOOD, "Brutes", -1})
    RegisterTimerEvent(ADD_PARTY_TO_LEVEL, 12000, false,{PLAYER_GOOD, "DND", -4})

    -- Open up the White Dungeon at 15 minutes into the game.
    -- This lets the player access the Prison.
    RegisterTimerEvent(ADD_TUNNELLER_PARTY_TO_LEVEL, 19000, false,{PLAYER_GOOD, "Scouts", -2, "APPROPIATE_DUNGEON", 0, 3, 250})

    -- Start regular waves of heroes that come from random gates.
    RegisterTimerEvent(StartPeriodicWaves, 20000, false)

    -- Spawn defenders when the player reaches the White Dungeon Heart.
    RegisterOnActionPointEvent(FoundHeroHeart, 1, PLAYER0)

    -- Simple victory condition: Destroy both enemy dungeon hearts.
    RegisterOnConditionEvent(WIN_GAME,
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
    ADD_PARTY_TO_LEVEL(PLAYER_GOOD, "DND", gatenum)
end


function FoundHeroHeart()
    QUICK_INFORMATION(2, "The heroes' dungeon heart lies exposed. Destroy it!", 1)
    ADD_PARTY_TO_LEVEL(PLAYER_GOOD, "Landlord", 1)
    ADD_PARTY_TO_LEVEL(PLAYER_GOOD, "DND", -2)
end