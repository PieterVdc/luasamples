--AutoChess map by Shinthoras, translated from DKscript to lua by qqluqq

local Creatures = {
    {Creature_type = "BILE_DEMON",   BoxToolTip = "BILE DEMON",    SpecialBoxId = 0,  Row = 1, column = 1, cost = 250 , levelRange = {2,8} },
    {Creature_type = "BUG",          BoxToolTip = "BUG",           SpecialBoxId = 1,  Row = 1, column = 2, cost = 50  , levelRange = {6,10}},
    {Creature_type = "DARK_MISTRESS",BoxToolTip = "DARK MISTRESS", SpecialBoxId = 2,  Row = 1, column = 3, cost = 450 , levelRange = {4,8} },
    {Creature_type = "DEMONSPAWN",   BoxToolTip = "DEMONSPAWN",    SpecialBoxId = 3,  Row = 1, column = 4, cost = 180 , levelRange = {4,10}},
    {Creature_type = "DRAGON",       BoxToolTip = "DRAGON",        SpecialBoxId = 4,  Row = 1, column = 5, cost = 700 , levelRange = {4,8} },
    {Creature_type = "DRUID",        BoxToolTip = "DRUID",         SpecialBoxId = 5,  Row = 1, column = 6, cost = 350 , levelRange = {3,8} },

    {Creature_type = "FLY",          BoxToolTip = "FLY",           SpecialBoxId = 6,  Row = 2, column = 1, cost = 10  , levelRange = {6,10}},
    {Creature_type = "GHOST",        BoxToolTip = "GHOST",         SpecialBoxId = 7,  Row = 2, column = 2, cost = 50  , levelRange = {4,8} },
    {Creature_type = "HELL_HOUND",   BoxToolTip = "HELL HOUND",    SpecialBoxId = 8,  Row = 2, column = 3, cost = 170 , levelRange = {5,10}},
    {Creature_type = "HORNY",        BoxToolTip = "HORNY",         SpecialBoxId = 9,  Row = 2, column = 4, cost = 1200, levelRange = {5,8} },
    {Creature_type = "ORC",          BoxToolTip = "ORC",           SpecialBoxId = 10, Row = 2, column = 5, cost = 200 , levelRange = {3,10}},
    {Creature_type = "SKELETON",     BoxToolTip = "SKELETON",      SpecialBoxId = 11, Row = 2, column = 6, cost = 180 , levelRange = {4,10}},

    {Creature_type = "SORCEROR",     BoxToolTip = "WARLOCK",       SpecialBoxId = 12, Row = 3, column = 1, cost = 100 , levelRange = {4,10}},
    {Creature_type = "SPIDER",       BoxToolTip = "SPIDER",        SpecialBoxId = 13, Row = 3, column = 2, cost = 80  , levelRange = {4,10}},
    {Creature_type = "TENTACLE",     BoxToolTip = "TENTACLE",      SpecialBoxId = 14, Row = 3, column = 3, cost = 110 , levelRange = {5,10}},
    {Creature_type = "TIME_MAGE",    BoxToolTip = "TIME MAGE",     SpecialBoxId = 15, Row = 3, column = 4, cost = 420 , levelRange = {4,10}},
    {Creature_type = "TROLL",        BoxToolTip = "TROLL",         SpecialBoxId = 16, Row = 3, column = 5, cost = 130 , levelRange = {5,10}},
    {Creature_type = "VAMPIRE",      BoxToolTip = "VAMPIRE",       SpecialBoxId = 17, Row = 3, column = 6, cost = 600 , levelRange = {4,10}},
}

local ROWS_COUNT = 3

local columns = {
    {changeOwnerAp = 79,spawnCreatureAp = 62, displayCostAp = 43, boxAp = 61, type = nil, creature = nil},
    {changeOwnerAp = 78,spawnCreatureAp = 38, displayCostAp = 44, boxAp = 33, type = nil, creature = nil},
    {changeOwnerAp = 77,spawnCreatureAp = 39, displayCostAp = 45, boxAp = 34, type = nil, creature = nil},
    {changeOwnerAp = 76,spawnCreatureAp = 40, displayCostAp = 46, boxAp = 35, type = nil, creature = nil},
    {changeOwnerAp = 75,spawnCreatureAp = 41, displayCostAp = 47, boxAp = 36, type = nil, creature = nil},
    {changeOwnerAp = 74,spawnCreatureAp = 42, displayCostAp = 48, boxAp = 37, type = nil, creature = nil},
}


function select_units_in_columns()
    for index, col in ipairs(columns) do
        rownNo = math.random(ROWS_COUNT)
        for _, cr in ipairs(Creatures) do
            if cr.column == index and cr.Row == rownNo then
                col.type = cr
                ADD_OBJECT_TO_LEVEL("SPECBOX_CUSTOM", col.boxAp, cr.SpecialBoxId, PLAYER0)
                
                local level = math.random(cr.levelRange[1], cr.levelRange[2])
                print(cr.Creature_type)
                col.creature = ADD_CREATURE_TO_LEVEL(PLAYER_GOOD, cr.Creature_type, col.spawnCreatureAp, 1, level, 0)

                break
            end
        end
    end
end

function initialise()
    
    --REST RESET-BOX TIMER

    for _, cr in ipairs(Creatures) do
        SET_BOX_TOOLTIP(cr.SpecialBoxId, cr.BoxToolTip)    
    end

    SET_BOX_TOOLTIP(18, "START GAME")
    SET_BOX_TOOLTIP(19, "RESET ROUND, no money refund!")
    SET_BOX_TOOLTIP(20, "FREE IMP")

    QUICK_OBJECTIVE("This is a rudimentary Auto Chess/Auto Battle implementation for Dungeon Keeper -Use the special boxes to select your creature. -Watch your gold, you receive a small amount back each round, and you get a bonus for every creature of yours that survives. -If you want to save gold or have none left, you can fill your battle lines with Imps using the special box. -Each surviving creature deals damage to the enemy heart. There are up to 9 rounds with an increasing number of creatures. -If both hearts are still standing after 9 rounds, the Keeper with the most victories wins. -The opponent receives and places their creatures completely randomly. -You can select from randomly chosen creatures each round (their level is set at the beginning of the game and does not change between rounds). -If you get stuck, you can restart the round using the special box, but note that you won't get back the gold you spent in that round.")

    CONCEAL_MAP_RECT(PLAYER0, 133, 121, 100, 100, true)

    REVEAL_MAP_LOCATION(PLAYER0, "PLAYER0", 18)
    COMPUTER_PLAYER(PLAYER1, 0)
    --SET_COMPUTER_GLOBALS(PLAYER1, 0, 0, 0, 0, 0, 0, 0)
    
    START_MONEY(PLAYER0, 2000)

    --[[
    SET_CREATURE_INSTANCE(DRUID, 2, RANGED_HEAL, 2)
    SET_CREATURE_INSTANCE(DRUID, 3, SLOW, 3)
    SET_CREATURE_INSTANCE(DRUID, 5, RANGED_ARMOUR, 5)
    SET_CREATURE_INSTANCE(GHOST, 5, RANGED_REBOUND, 5)
    SET_CREATURE_INSTANCE(TIME_MAGE, 8, RANGED_SPEED, 6)
    SET_CREATURE_INSTANCE(IMP, 1, NULL, 1)
    MAGIC_AVAILABLE(PLAYER0, "POWER_IMP", 0, 0)
    MAGIC_AVAILABLE(PLAYER1, "POWER_IMP", 0, 0)
    MAGIC_AVAILABLE(PLAYER1, "POWER_HAND", 0, 0)
    MAGIC_AVAILABLE(PLAYER1, "POWER_SLAP", 0, 0)
    MAGIC_AVAILABLE(PLAYER0, "POWER_POSSESS", 0, 0)
    SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, DestroyOnLava, 1)
    SET_OBJECT_CONFIGURATION(CTA_ENSIGN, MaximumSize, 1)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Stand, 556)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Ambulate, 554)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Attack, 558)
    SET_CREATURE_CONFIGURATION(TUNNELLER, GotHit, 560)
    SET_CREATURE_CONFIGURATION(TUNNELLER, GotHit, 560)
    SET_CREATURE_CONFIGURATION(TUNNELLER, PowerGrab, 574)
    SET_CREATURE_CONFIGURATION(TUNNELLER, GotSlapped, 576)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Celebrate, 564)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Scream, 570)
    SET_CREATURE_CONFIGURATION(TUNNELLER, DropDead, 572)
    SET_CREATURE_CONFIGURATION(TUNNELLER, DeadSplat, 946)
    SET_CREATURE_CONFIGURATION(TUNNELLER, QuerySymbol, 154)
    SET_CREATURE_CONFIGURATION(TUNNELLER, HandSymbol, 222)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Foot, 9, 4)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Hit, 490, 1)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Happy, 488, 1)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Hurt, 490, 3)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Die, 493, 2)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Hang, 495, 1)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Drop, 4961, 4)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Slap, 490, 3)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Fight, 485, 3)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Health, 75)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Strength, 5)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Armour, 5)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Dexterity, 60)
    SET_CREATURE_CONFIGURATION(TUNNELLER, FearWounded, 0)
    SET_CREATURE_CONFIGURATION(TUNNELLER, FearStronger, 10000)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Defence, 7)
    SET_CREATURE_CONFIGURATION(TUNNELLER, Luck, 0)
    SET_CREATURE_CONFIGURATION(TUNNELLER, SlapsToKill, 5)
    SET_CREATURE_PROPERTY("TUNNELLER", "SPECIAL_DIGGER", 0)
    SET_CREATURE_FEAR(BILE_DEMON, 0)
    SET_CREATURE_FEAR(BUG, 0)
    SET_CREATURE_FEAR(DARK_MISTRESS, 0)
    SET_CREATURE_FEAR(DEMONSPAWN, 0)
    SET_CREATURE_FEAR(DRAGON, 0)
    SET_CREATURE_FEAR(DRUID, 0)
    SET_CREATURE_FEAR(FLY, 0)
    SET_CREATURE_FEAR(GHOST, 0)
    SET_CREATURE_FEAR(HELL_HOUND, 0)
    SET_CREATURE_FEAR(HORNY, 0)
    SET_CREATURE_FEAR(IMP, 0)
    SET_CREATURE_FEAR(ORC, 0)
    SET_CREATURE_FEAR(SKELETON, 0)
    SET_CREATURE_FEAR(SORCEROR, 0)
    SET_CREATURE_FEAR(SPIDER, 0)
    SET_CREATURE_FEAR(TENTACLE, 0)
    SET_CREATURE_FEAR(TIME_MAGE, 0)
    SET_CREATURE_FEAR(TROLL, 0)
    SET_CREATURE_FEAR(VAMPIRE, 0)

    SET_GAME_RULE(DungeonHeartHealHealth, 0)
    ]]
    SET_TIMER(PLAYER0, "TIMER6")

end


function damageHeart_effect(player)
    local location
    local effect
    if player == PLAYER0 then
        effect = "EFFECT_BALL_PUFF_BLUE"
        Game.player0heartEffectCounter = (Game.player0heartEffectCounter + 1) % 9
        location = Game.player0heartEffectCounter + 50
    else
        effect = "EFFECT_BALL_PUFF_RED"
        Game.player1heartEffectCounter = (Game.player1heartEffectCounter + 1) % 9
        location = Game.player1heartEffectCounter + 50
    end
    --ADD_HEART_HEALTH(player, -2000)
    CREATE_EFFECTS_LINE(location, player, 0, 3, 5, effect)

end

function damageHeart()
    -- Evaluation phase
    -- Process heart damage
    if PLAYER0.TOTAL_CREATURES == 0 then
        if PLAYER1.TOTAL_CREATURES > 0 then
            damageHeart_effect(PLAYER0)
        end

        ADD_TO_FLAG(Game.WINFLAG_FOR_COMPUTER, 1)
        SET_FLAG(Game.END_PASE, 1)
        CREATE_EFFECTS_LINE(COMBAT, PLAYER0, 0, 6, 10, EFFECTELEMENT_BLUE_SPARKLES_LARGE)
        CREATE_EFFECT(EFFECT_WORD_OF_POWER, PLAYER0)
        COMPUTE_FLAG(PLAYER3, FLAG6, SET, PLAYER1, HORNY, 0)
    end
    if PLAYER1.TOTAL_CREATURES == 0 then
        if PLAYER0.TOTAL_CREATURES > 0 then
            damageHeart_effect(PLAYER1)
        end
        processPlayerReward(PLAYER0.TOTAL_CREATURES)

        ADD_TO_FLAG(Game.WINFLAG_FOR_PLAYER, 1)
        SET_FLAG(Game.END_PASE, 1)
        ADD_HEART_HEALTH(PLAYER1, -1500)
        CREATE_EFFECTS_LINE(COMBAT, PLAYER1, 0, 6, 10, EFFECTELEMENT_RED_SPARKLES_LARGE)
        CREATE_EFFECT(EFFECT_WORD_OF_POWER, PLAYER1)
    end
    
end

function processPlayerReward(creatures_remaining)
    -- REWARD for PLAYER
    if (Game.SURVIVING_CREATURE_PLAYER_REWARD > 0) then
        ADD_GOLD_TO_PLAYER(PLAYER0, 100)
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 1) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 59, 100)
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 2) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 60, 100)
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 3) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 68, 100)
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 4) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 69, 100)
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 5) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 70, 100)
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 6) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 71, 100)
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 7) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 72, 100)
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 8) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 73, 100)
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD == 9) then
            CREATE_EFFECT("EFFECTELEMENT_PRICE", 50, 100)
            Game.SURVIVING_CREATURE_PLAYER_REWARD = 0
        end
        if (Game.SURVIVING_CREATURE_PLAYER_REWARD > 0) then
            Game.SURVIVING_CREATURE_PLAYER_REWARD = Game.SURVIVING_CREATURE_PLAYER_REWARD -1
        end
    end

end 

function start_fight_phase()

    ---- Fight phase
    --if Game.FIGHT_PHASE_ENDED == 0 then
    --    CHANGE_SLAB_TYPE(40, 40, BRIDGE_FRAME, MATCH)
    --    if Game.CTA_FLAGS == 0
    --        USE_POWER_AT_LOCATION(PLAYER0, 63, POWER_CALL_TO_ARMS, 3, 1)
    --        USE_POWER_AT_LOCATION(PLAYER1, 63, POWER_CALL_TO_ARMS, 3, 1)
    --        DISPLAY_COUNTDOWN(PLAYER0, TIMER5, 860, 1)
    --        SET_FLAG(Game.CTA_FLAGS, 1)
    --    end
    --    MAGIC_AVAILABLE(PLAYER0, POWER_CALL_TO_ARMS, 1, 1)
    --    MAGIC_AVAILABLE(PLAYER1, POWER_CALL_TO_ARMS, 1, 1)
    --    if PLAYER0, TIMER5 > 860)
    --    USE_POWER_AT_POS(PLAYER0,91,37,POWER_CAVE_IN,1,1)
    --        SET_PLAYER_MODIFIER(PLAYER0, SpellDamage, 500)
    --        SET_PLAYER_MODIFIER(PLAYER0, Strength, 500)
    --        SET_PLAYER_MODIFIER(PLAYER1, SpellDamage, 500)
    --        SET_PLAYER_MODIFIER(PLAYER1, Strength, 500)
    --    end
--
    --end
--
--
    --SET_GAME_RULE("BodyRemainsFor", 2000)
    --SET_CREATURE_CONFIGURATION("TUNNELLER",     "BaseSpeed", 96)
    --SET_CREATURE_CONFIGURATION("BILE_DEMON",    "BaseSpeed", 48)
    --SET_CREATURE_CONFIGURATION("BUG",           "BaseSpeed", 48)
    --SET_CREATURE_CONFIGURATION("DARK_MISTRESS", "BaseSpeed", 64)
    --SET_CREATURE_CONFIGURATION("DEMONSPAWN",    "BaseSpeed", 48)
    --SET_CREATURE_CONFIGURATION("DRAGON",        "BaseSpeed", 32)
    --SET_CREATURE_CONFIGURATION("DRUID",         "BaseSpeed", 32)
    --SET_CREATURE_CONFIGURATION("FLY",           "BaseSpeed", 128)
    --SET_CREATURE_CONFIGURATION("GHOST",         "BaseSpeed", 64)
    --SET_CREATURE_CONFIGURATION("HELL_HOUND",    "BaseSpeed", 96)
    --SET_CREATURE_CONFIGURATION("HORNY",         "BaseSpeed", 96)
    --SET_CREATURE_CONFIGURATION("ORC",           "BaseSpeed", 48)
    --SET_CREATURE_CONFIGURATION("SKELETON",      "BaseSpeed", 64)
    --SET_CREATURE_CONFIGURATION("SORCEROR",      "BaseSpeed", 32)
    --SET_CREATURE_CONFIGURATION("SPIDER",        "BaseSpeed", 48)
    --SET_CREATURE_CONFIGURATION("TENTACLE",      "BaseSpeed", 32)
    --SET_CREATURE_CONFIGURATION("TIME_MAGE",     "BaseSpeed", 32)
    --SET_CREATURE_CONFIGURATION("TROLL",         "BaseSpeed", 48)
    --SET_CREATURE_CONFIGURATION("VAMPIRE",       "BaseSpeed", 56)
    MAGIC_AVAILABLE(PLAYER0, "POWER_HAND", false, false)
end

function start_prep_phase()
    
    select_units_in_columns()

    --SET_PLAYER_MODIFIER(PLAYER0, SpellDamage, 100)
    --SET_PLAYER_MODIFIER(PLAYER0, Strength, 100)
    --SET_PLAYER_MODIFIER(PLAYER1, SpellDamage, 100)
    --SET_PLAYER_MODIFIER(PLAYER1, Strength, 100)
    --SET_TIMER(PLAYER0, TIMER5)
    --SET_FLAG(Game.CTA_FLAGS, 0)
    --DISPLAY_COUNTDOWN(PLAYER0, TIMER6, 1, 0)
    --MAGIC_AVAILABLE(PLAYER0, POWER_CALL_TO_ARMS, 0, 0)
    --MAGIC_AVAILABLE(PLAYER1, POWER_CALL_TO_ARMS, 0, 0)
    --SET_CREATURE_CONFIGURATION(TUNNELLER, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(BILE_DEMON, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(BUG, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(DARK_MISTRESS, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(DEMONSPAWN, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(DRAGON, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(DRUID, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(FLY, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(GHOST, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(HELL_HOUND, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(HORNY, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(ORC, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(SKELETON, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(SORCEROR, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(SPIDER, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(TENTACLE, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(TIME_MAGE, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(TROLL, BaseSpeed, 0)
    --SET_CREATURE_CONFIGURATION(VAMPIRE, BaseSpeed, 0)
    --MAGIC_AVAILABLE(PLAYER0, POWER_HAND, 1, 1)
    --SET_GAME_RULE(BodyRemainsFor, 1)
    -- SPECIAL ROUND RESTART
    

end

local function reset_round()
    USE_POWER(PLAYER_GOOD, POWER_HOLD_AUDIENCE, 1)
    --getCreatureByCriterion(PLAYER0, "ANY_CREATURE", "AT_ACTION_POINT[63]").TeleportCreature(20,"EFFECT_BALL_PUFF_RED")
    --getCreatureByCriterion(PLAYER1, "ANY_CREATURE", "AT_ACTION_POINT[63]").TeleportCreature(20,"EFFECT_BALL_PUFF_BLUE")
end

local function spawn_imp()
    --SET_FLAG(PLAYER0, FLAG4, 3)
    ADD_CREATURE_TO_LEVEL(PLAYER0, "TUNNELLER", 49, 1, 1, 0)
end

local function start_level()

    Game.Round = 1

    REVEAL_MAP_RECT(PLAYER0, 133, 121, 70, 70)
    start_prep_phase()
end

function special_activated (eventData,triggerData)

    if eventData.SpecialBoxId == 18 then --START GAME
        start_level()
    elseif eventData.SpecialBoxId == 19 then --"RESET ROUND, no money refund!"
        ADD_OBJECT_TO_LEVEL_AT_POS("SPECBOX_CUSTOM", 115, 139, 19, PLAYER0)
        reset_round()
    elseif eventData.SpecialBoxId == 20 then --"FREE IMP"
        ADD_OBJECT_TO_LEVEL_AT_POS("SPECBOX_CUSTOM", 115, 145, 20, PLAYER0)
        spawn_imp()
    else
        for _, cr in ipairs(Creatures) do
            if cr.SpecialBoxId == eventData.SpecialBoxId then
                if PLAYER0.MONEY >= cr.cost then
                    columns[cr.column].creature.owner = PLAYER0
                    PLAYER0:ADD_GOLD(-cr.cost)
                    break

                else
                    --not enough money, ignore box
                    break
                end
            end
        end
    end
end

function placeEnemyCreatures()
--TODO ask Shinthoras the logic behind this
    for i = 1, Game.Round, 1 do
        if PLAYER.TOTAL_CREATURES < Game.Round then
            local ap = math.random(10, 32)
            local cr = Creatures[ math.random( #Creatures ) ]
            local level = math.random(cr.levelRange[1], cr.levelRange[2])
            ADD_CREATURE_TO_LEVEL(PLAYER1, cr.Creature_type, ap, 1, level, 0)
        end
    end
end

function drawPrices()
    for index, col in ipairs(columns) do
        if col.creature == nil then
            return
        end
        CREATE_EFFECT("EFFECTELEMENT_PRICE", col.displayCostAp, col.type.cost)
    end
end

function game_end()
    --IF(Game.MaxCreatures == 10)
    --    HIDE_VARIABLE
    --    if Game.WINFLAG_FOR_COMPUTER > Game.WINFLAG_FOR_PLAYER)
    --        SET_HEART_HEALTH(PLAYER0, 0)
    --        CREATE_EFFECTS_LINE(PLAYER1, PLAYER0, 0, 6, 10, EFFECTELEMENT_BLUE_SPARKLES_LARGE)
    --        LOSE_GAME
    --        NEXT_COMMAND_REUSABLE
    --        KILL_CREATURE(ALL_PLAYERS, ANY_CREATURE, ANYWHERE, 10)
    --        SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, MaximumSize, 1)
    --        SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, Genre, Furniture)
    --    end
    --    if Game.WINFLAG_FOR_COMPUTER < Game.WINFLAG_FOR_PLAYER)
    --        SET_HEART_HEALTH(PLAYER1, 0)
    --        CREATE_EFFECTS_LINE(PLAYER0, PLAYER1, 0, 6, 10, EFFECTELEMENT_RED_SPARKLES_LARGE)
    --        WIN_GAME
    --        NEXT_COMMAND_REUSABLE
    --        KILL_CREATURE(ALL_PLAYERS, ANY_CREATURE, ANYWHERE, 10)
    --        SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, MaximumSize, 1)
    --        SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, Genre, Furniture)
    --    end
    --end
    --IF(PLAYER1, DUNGEON_DESTROYED == 1)
    --    CREATE_EFFECTS_LINE(PLAYER0, PLAYER1, 0, 6, 10, EFFECTELEMENT_RED_SPARKLES_LARGE)
    --    HIDE_VARIABLE
    --    WIN_GAME
    --    NEXT_COMMAND_REUSABLE
    --    KILL_CREATURE(ALL_PLAYERS, ANY_CREATURE, ANYWHERE, 10)
    --    SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, MaximumSize, 1)
    --    SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, Genre, Furniture)
    --end
    --IF(PLAYER0, HEART_HEALTH < 100)
    --    CREATE_EFFECTS_LINE(PLAYER1, PLAYER0, 0, 6, 10, EFFECTELEMENT_BLUE_SPARKLES_LARGE)
    --    HIDE_VARIABLE
    --    LOSE_GAME
    --    NEXT_COMMAND_REUSABLE
    --    KILL_CREATURE(ALL_PLAYERS, ANY_CREATURE, ANYWHERE, 10)
    --    SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, MaximumSize, 1)
    --    SET_OBJECT_CONFIGURATION(SPECBOX_CUSTOM, Genre, Furniture)
    --end
end

function OnGameStart()
    initialise()
    RegisterSpecialActivatedEvent("special_activated")
    RegisterTimerEvent("drawPrices",25,true)
end