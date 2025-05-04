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
    Display_objective(113,  PLAYER0)
end

function Create_triggers()

    --there's multiple ways to create triggers, they can be found in triggers.lua
    -- the first argument is a function that will be called when the event is triggered
    -- the other arguments the RegisterEvent functions might take depend on the type

    -- RegisterTimerEvent for example takes a time in game ticks, and a boolean for whether the timer should repeat or just trigger once
    RegisterTimerEvent(Add_ap4_event,20000,false)
    
    RegisterOnActionPointEvent(function () Add_party_to_level(	PLAYER_GOOD,"PARTY2",1,1) end,2,PLAYER0)
    --
    RegisterDungeonDestroyedEvent(Good_destroyed,PLAYER_GOOD)
    --if the function is short enough, it can be defined inline when registering the event
    RegisterDungeonDestroyedEvent(function () Win_game() end,PLAYER1)
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
    Add_tunneller_party_to_level(  PLAYER_GOOD,          "PARTY1",    -1,        "DUNGEON_HEART",  0,    3,    400)
end

--the logic that is executed when the good dungeon is destroyed, in this case it displays an objective
function Good_destroyed()
    --"The corpses of the good lie strewn around you. Now go, and conquer your rival on this land. Dominion awaits ...",  PLAYER0)
    Display_objective(114)

    --        The player the party is assigned to  Party Name  Action Point or Hero Door  Number of copies of party
    Add_party_to_level(  PLAYER_GOOD, "PARTY3",    1,        1)
    Add_party_to_level(  PLAYER_GOOD, "PARTY4",    2,        1)
end



-- **********     SETUP COMMANDS     **********

function Setup()
    -- ***** Set the Generation Speed of the  *****
    -- ***** Entrances                        *****

    Set_generate_speed(500)


    -- ***** Set the computer players going   *****

    --    Player    Player Type

    Computer_player(PLAYER1,  0)


    -- ***** Set the maximum number of        *****
    -- ***** creatures each player can have   *****

    --    Player    Number of creatures

    Max_creatures(  PLAYER0,  30)
    Max_creatures(  PLAYER1,  30)


    -- ***** Set the amount of gold each      *****
    -- ***** player starts with               *****

    --    Player    Amount of gold

    Start_money(  PLAYER0,  10000)
    Start_money(  PLAYER1,  10000)




    -- **********       SET MAGIC        **********
    -- **********     AND CREATURES      **********

    -- ***** Setup the creature pool          *****

    --      Creature Name  Number of creatures

    Add_creature_to_pool(  "BUG",    10)
    Add_creature_to_pool(  "FLY",    10)
    Add_creature_to_pool(  "SPIDER",    5)
    Add_creature_to_pool(  "SORCEROR",  30)
    Add_creature_to_pool(  "DEMONSPAWN",  20)
    Add_creature_to_pool(  "DRAGON",    20)
    Add_creature_to_pool(  "TROLL",    10)
    Add_creature_to_pool(  "ORC",    10)
    Add_creature_to_pool(  "HELL_HOUND",  10)
    Add_creature_to_pool(  "DARK_MISTRESS",  10)
    Add_creature_to_pool(  "BILE_DEMON",  20)


    -- ***** Enable each player to recieve    *****
    -- ***** creatures from pool              *****

    --          Player    Creatures  Can be available  amount forced

    Creature_available(  "ALL_PLAYERS",  "BUG",      true,      0)
    Creature_available(  "ALL_PLAYERS",  "FLY",      true,      0)
    Creature_available(  "ALL_PLAYERS",  "SPIDER",    true,      0)
    Creature_available(  "ALL_PLAYERS",  "SORCEROR",    true,      0)
    Creature_available(  "ALL_PLAYERS",  "DEMONSPAWN",  true,      0)
    Creature_available(  "ALL_PLAYERS",  "DRAGON",    true,      0)
    Creature_available(  "ALL_PLAYERS",  "TROLL",    true,      0)
    Creature_available(  "ALL_PLAYERS",  "ORC",      true,      0)
    Creature_available(  "ALL_PLAYERS",  "HELL_HOUND",  true,      0)
    Creature_available(  "ALL_PLAYERS",  "DARK_MISTRESS",true,      0)
    Creature_available(  "ALL_PLAYERS",  "BILE_DEMON",  true,      0)


    -- ***** Set the rooms available to each  *****
    -- ***** player                           *****

    --      Player    Room type  Can be available  Is available

    Room_available(    "ALL_PLAYERS",  "TREASURE",    0,      true)
    Room_available(    "ALL_PLAYERS",  "LAIR",        0,      true)
    Room_available(    "ALL_PLAYERS",  "GARDEN",      0,      true)
    Room_available(    "ALL_PLAYERS",  "TRAINING",    0,      true)
    Room_available(    "ALL_PLAYERS",  "RESEARCH",    0,      true)

    Room_available(    "ALL_PLAYERS",  "GUARD_POST",  1,      false)
    Room_available(    "ALL_PLAYERS",  "WORKSHOP",    1,      false)
    Room_available(    "ALL_PLAYERS",  "BARRACKS",    1,      false)
    Room_available(    "ALL_PLAYERS",  "PRISON",      1,      false)
    Room_available(    "ALL_PLAYERS",  "TORTURE",     1,      false)
    Room_available(    "ALL_PLAYERS",  "TEMPLE",      1,      false)


    -- ***** Set the doors available to each  *****
    -- ***** player                           *****

    --      Player    Door type    Can be available  Is available

    Door_available(    "ALL_PLAYERS",  "WOOD",      true,      1)
    Door_available(    "ALL_PLAYERS",  "BRACED",    true,      1)
    Door_available(    "ALL_PLAYERS",  "STEEL",    true,      1)
    Door_available(    "ALL_PLAYERS",  "MAGIC",    true,      1)


    -- ***** Set the traps available to each  *****
    -- ***** player                           *****

    --          Player    Trap type    Can be available  Is available

    Trap_available(    "ALL_PLAYERS",  "BOULDER",      true,      1)
    Trap_available(    "ALL_PLAYERS",  "ALARM",      true,      1)
    Trap_available(    "ALL_PLAYERS",  "POISON_GAS",    true,      1)
    Trap_available(    "ALL_PLAYERS",  "LIGHTNING",    true,      1)
    Trap_available(    "ALL_PLAYERS",  "WORD_OF_POWER",  true,      1)
    Trap_available(    "ALL_PLAYERS",  "LAVA",        true,      1)


    -- ***** Set the spells available to each *****
    -- ***** player                           *****

    --            Player    Spell type    Can be available  Is available

    Magic_available(  "ALL_PLAYERS",  "POWER_IMP",        true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_OBEY",        true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_SIGHT",        true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_CALL_TO_ARMS",  true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_CAVE_IN",    true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_HEAL_CREATURE",  true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_HOLD_AUDIENCE",  true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_LIGHTNING",      true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_SPEED",        true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_PROTECT",    true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_CONCEAL",    true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_DISEASE",    true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_CHICKEN",    true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_DESTROY_WALLS",  true,      true)
    Magic_available(  "ALL_PLAYERS",  "POWER_ARMAGEDDON",      true,      true)

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

    Create_party(  "PARTY1")
    Create_party(  "PARTY2")
    Create_party(  "PARTY3")


    -- ***** Add creatures to those parties   *****
    --    Party Name  Creature Name  Experience   Amount of Gold  Objective    Countdown

    Add_to_party(  "PARTY1",    "ARCHER",    3,    200,    "ATTACK_DUNGEON_HEART",  0)
    Add_to_party(  "PARTY1",    "ARCHER",    3,    200,    "ATTACK_DUNGEON_HEART",  0)
    Add_to_party(  "PARTY1",    "DWARFA",    3,    400,    "ATTACK_DUNGEON_HEART",  0)
    Add_to_party(  "PARTY1",    "DWARFA",    3,    400,    "ATTACK_DUNGEON_HEART",  0)
    Add_to_party(  "PARTY1",    "WITCH",    4,    700,    "ATTACK_DUNGEON_HEART",  0)


    Add_to_party(  "PARTY2",    "ARCHER",    5,    400,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY2",    "ARCHER",    5,    400,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY2",    "BARBARIAN",  6,    200,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY2",    "MONK",    5,    600,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY2",    "MONK",    5,    600,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY2",    "SAMURAI",  6,    500,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY2",    "SAMURAI",  6,    500,    "ATTACK_ENEMIES",    0)


    Add_to_party(  "PARTY3",    "ARCHER",    7,    600,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY3",    "ARCHER",    7,    600,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY3",    "GIANT",    6,    200,    "DEFEND_PARTY",      0)
    Add_to_party(  "PARTY3",    "GIANT",    6,    200,    "DEFEND_PARTY",      0)
    Add_to_party(  "PARTY3",    "WIZARD",    5,    600,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY3",    "WIZARD",    6,    500,    "ATTACK_ENEMIES",    0)
    Add_to_party(  "PARTY3",    "WIZARD",    6,    500,    "ATTACK_ENEMIES",    0)

end
