-- ********************************************
--
--             Script for Level 200
--
-- ********************************************




---The OnGameStart function is called when the level is first loaded and an entry point for the script
---This function will be called the same in any lua script for a level
function OnGameStart ()
    --setup of the level like creature pools, rooms, doors, traps, and spells
    Setup()
    --create the parties of heroes that will appear in the level
    Create_parties()
    --make triggers that couple actions to events
    Create_triggers()

    --        Objective Number  Objective Text (must be within quotes)                                          Player
    --   0,      "In the caves of Savactor, an rival Keeper battles with the tireless forces of good. Vanquish the pathetic heroes and them proceed to conquer the rival Keeper to gain dominance over this land.",  PLAYER0)
    DISPLAY_OBJECTIVE(113,  PLAYER0)
end

function Create_triggers()

    --there's multiple ways to create triggers, they can be found in triggers.lua
    -- the first argument is a function that will be called when the event is triggered
    -- the other arguments the RegisterEvent functions might take depend on the type

    -- RegisterTimerEvent for example takes a time in game ticks, and a boolean for whether the timer should repeat or just trigger once
    RegisterTimerEvent(Add_ap4_event,20000,false)
    
    RegisterOnActionPointEvent(function () ADD_PARTY_TO_LEVEL(	PLAYER_GOOD,"PARTY2",1,1) end,2,PLAYER0)
    --
    RegisterDungeonDestroyedEvent(Good_destroyed,PLAYER_GOOD)
    --if the function is short enough, it can be defined inline when registering the event
    RegisterDungeonDestroyedEvent(function () WIN_GAME() end,PLAYER1)
end

--once the timer passes a new events wich evaluates if actionpoint 4 is activated by player 0 will be created
--actionpoint 4 is the one near the 2 dungeon specials
function Add_ap4_event()

    --for debugging purposes you could add a print wich will show up in the log file
    print("timer passed")

    --the events don't all need to be registered at the start of the game, they can be registered at any time
    RegisterOnActionPointEvent(Spawn_party1,4,PLAYER0)

end

function Spawn_party1()
    --        The player the party is assigned to  Party Name  Action Point or Hero Door  Number of copies of party
    ADD_TUNNELLER_PARTY_TO_LEVEL(  PLAYER_GOOD,          "PARTY1",    -1,        "DUNGEON_HEART",  0,    3,    400)
end

--the logic that is executed when the good dungeon is destroyed, in this case it displays an objective
function Good_destroyed()
    --"The corpses of the good lie strewn around you. Now go, and conquer your rival on this land. Dominion awaits ...",  PLAYER0)
    DISPLAY_OBJECTIVE(114)

    --        The player the party is assigned to  Party Name  Action Point or Hero Door  Number of copies of party
    ADD_PARTY_TO_LEVEL(  PLAYER_GOOD, "PARTY3",    1,        1)
    ADD_PARTY_TO_LEVEL(  PLAYER_GOOD, "PARTY4",    2,        1)
end



-- **********     SETUP COMMANDS     **********

function Setup()
    -- ***** Set the Generation Speed of the  *****
    -- ***** Entrances                        *****

    SET_GENERATE_SPEED(500)


    -- ***** Set the computer players going   *****

    --    Player    Player Type

    COMPUTER_PLAYER(PLAYER1,  0)


    -- ***** Set the maximum number of        *****
    -- ***** creatures each player can have   *****

    --    Player    Number of creatures

    MAX_CREATURES(  PLAYER0,  30)
    MAX_CREATURES(  PLAYER1,  30)


    -- ***** Set the amount of gold each      *****
    -- ***** player starts with               *****

    --    Player    Amount of gold

    START_MONEY(  PLAYER0,  10000)
    START_MONEY(  PLAYER1,  10000)




    -- **********       SET MAGIC        **********
    -- **********     AND CREATURES      **********

    -- ***** Setup the creature pool          *****

    --      Creature Name  Number of creatures

    ADD_CREATURE_TO_POOL(  "BUG",    10)
    ADD_CREATURE_TO_POOL(  "FLY",    10)
    ADD_CREATURE_TO_POOL(  "SPIDER",    5)
    ADD_CREATURE_TO_POOL(  "SORCEROR",  30)
    ADD_CREATURE_TO_POOL(  "DEMONSPAWN",  20)
    ADD_CREATURE_TO_POOL(  "DRAGON",    20)
    ADD_CREATURE_TO_POOL(  "TROLL",    10)
    ADD_CREATURE_TO_POOL(  "ORC",    10)
    ADD_CREATURE_TO_POOL(  "HELL_HOUND",  10)
    ADD_CREATURE_TO_POOL(  "DARK_MISTRESS",  10)
    ADD_CREATURE_TO_POOL(  "BILE_DEMON",  20)


    -- ***** Enable each player to recieve    *****
    -- ***** creatures from pool              *****

    --          Player    Creatures  Can be available  amount forced

    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "BUG",      true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "FLY",      true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "SPIDER",    true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "SORCEROR",    true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "DEMONSPAWN",  true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "DRAGON",    true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "TROLL",    true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "ORC",      true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "HELL_HOUND",  true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "DARK_MISTRESS",true,      0)
    CREATURE_AVAILABLE(  "ALL_PLAYERS",  "BILE_DEMON",  true,      0)


    -- ***** Set the rooms available to each  *****
    -- ***** player                           *****

    --      Player    Room type  Can be available  Is available

    ROOM_AVAILABLE(    "ALL_PLAYERS",  "TREASURE",    true,      true)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "LAIR",      true,      true)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "GARDEN",    true,      true)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "TRAINING",    true,      true)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "RESEARCH",    true,      true)

    ROOM_AVAILABLE(    "ALL_PLAYERS",  "GUARD_POST",  true,      false)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "WORKSHOP",    true,      false)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "BARRACKS",    true,      false)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "PRISON",    true,      false)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "TORTURE",    true,      false)
    ROOM_AVAILABLE(    "ALL_PLAYERS",  "TEMPLE",    true,      false)


    -- ***** Set the doors available to each  *****
    -- ***** player                           *****

    --      Player    Door type    Can be available  Is available

    DOOR_AVAILABLE(    "ALL_PLAYERS",  "WOOD",      true,      1)
    DOOR_AVAILABLE(    "ALL_PLAYERS",  "BRACED",    true,      1)
    DOOR_AVAILABLE(    "ALL_PLAYERS",  "STEEL",    true,      1)
    DOOR_AVAILABLE(    "ALL_PLAYERS",  "MAGIC",    true,      1)


    -- ***** Set the traps available to each  *****
    -- ***** player                           *****

    --          Player    Trap type    Can be available  Is available

    TRAP_AVAILABLE(    "ALL_PLAYERS",  "BOULDER",      true,      1)
    TRAP_AVAILABLE(    "ALL_PLAYERS",  "ALARM",      true,      1)
    TRAP_AVAILABLE(    "ALL_PLAYERS",  "POISON_GAS",    true,      1)
    TRAP_AVAILABLE(    "ALL_PLAYERS",  "LIGHTNING",    true,      1)
    TRAP_AVAILABLE(    "ALL_PLAYERS",  "WORD_OF_POWER",  true,      1)
    TRAP_AVAILABLE(    "ALL_PLAYERS",  "LAVA",        true,      1)


    -- ***** Set the spells available to each *****
    -- ***** player                           *****

    --            Player    Spell type    Can be available  Is available

    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_IMP",        true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_OBEY",        true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_SIGHT",        true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_CALL_TO_ARMS",  true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_CAVE_IN",    true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_HEAL_CREATURE",  true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_HOLD_AUDIENCE",  true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_LIGHTNING",      true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_SPEED",        true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_PROTECT",    true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_CONCEAL",    true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_DISEASE",    true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_CHICKEN",    true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_DESTROY_WALLS",  true,      true)
    MAGIC_AVAILABLE(  "ALL_PLAYERS",  "POWER_ARMAGEDDON",      true,      true)

end




-- **********     CREATE AND ADD     **********
-- **********  CREATURES TO PARTIES  **********

-- ***** I have four parties of heroes to *****
-- ***** create. The first ("PARTY1") will  *****
-- ***** appear at Hero Door 1 when       *****
-- ***** TIMER0 reaches 20000 and ap4 has been triggered.
-- ***** The second ("PARTY2") will     *****
-- ***** appear at Action Point 1 when    *****
-- ***** any creature of PLayer 0's       *****
-- ***** triggers ActionPoint 2. The last *****
-- ***** two parties ("PARTY3" and "PARTY4")  *****
-- ***** will appear Action Points 1 and  *****
-- ***** 2 respectively when the Hero     *****
-- ***** Dungeon Heart has been destroyed *****


-- ***** Create any parties               *****

---called from the setup function, creates the hero parties in the script, and adds creatures to them
function Create_parties()
  
    --    Party Name

    CREATE_PARTY(  "PARTY1")
    CREATE_PARTY(  "PARTY2")
    CREATE_PARTY(  "PARTY3")


    -- ***** Add creatures to those parties   *****
    --    Party Name  Creature Name  Experience   Amount of Gold  Objective    Countdown

    ADD_TO_PARTY(  "PARTY1",    "ARCHER",    3,    200,    "ATTACK_DUNGEON_HEART",  0)
    ADD_TO_PARTY(  "PARTY1",    "ARCHER",    3,    200,    "ATTACK_DUNGEON_HEART",  0)
    ADD_TO_PARTY(  "PARTY1",    "DWARFA",    3,    400,    "ATTACK_DUNGEON_HEART",  0)
    ADD_TO_PARTY(  "PARTY1",    "DWARFA",    3,    400,    "ATTACK_DUNGEON_HEART",  0)
    ADD_TO_PARTY(  "PARTY1",    "WITCH",    4,    700,    "ATTACK_DUNGEON_HEART",  0)


    ADD_TO_PARTY(  "PARTY2",    "ARCHER",    5,    400,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY2",    "ARCHER",    5,    400,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY2",    "BARBARIAN",  6,    200,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY2",    "MONK",    5,    600,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY2",    "MONK",    5,    600,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY2",    "SAMURAI",  6,    500,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY2",    "SAMURAI",  6,    500,    "ATTACK_ENEMIES",    0)


    ADD_TO_PARTY(  "PARTY3",    "ARCHER",    7,    600,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY3",    "ARCHER",    7,    600,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY3",    "GIANT",    6,    200,    "DEFEND_PARTY",      0)
    ADD_TO_PARTY(  "PARTY3",    "GIANT",    6,    200,    "DEFEND_PARTY",      0)
    ADD_TO_PARTY(  "PARTY3",    "WIZARD",    5,    600,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY3",    "WIZARD",    6,    500,    "ATTACK_ENEMIES",    0)
    ADD_TO_PARTY(  "PARTY3",    "WIZARD",    6,    500,    "ATTACK_ENEMIES",    0)

end
