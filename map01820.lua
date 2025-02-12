--AutoChess map by Shinthoras, translated from DKscript to lua by qqluqq

local Creatures = {
    {Creature_type = "BILE_DEMON",   BoxToolTip = "BILE DEMON",    SpecialBoxId = 0,  Row = 1, column = 1, cost = 250 , levelRange = {2,8} },
    {Creature_type = "BUG",          BoxToolTip = "BUG",           SpecialBoxId = 1,  Row = 1, column = 2, cost = 50  , levelRange = {6,10}},
    {Creature_type = "DARK_MISTRES", BoxToolTip = "DARK MISTRES",  SpecialBoxId = 2,  Row = 1, column = 3, cost = 450 , levelRange = {4,8} },
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


local columns = {
    {changeOwnerAp = 79,spawnCreatureAp = 62, displayCostAp = 43},
    {changeOwnerAp = 78,spawnCreatureAp = 38, displayCostAp = 44},
    {changeOwnerAp = 77,spawnCreatureAp = 39, displayCostAp = 45},
    {changeOwnerAp = 76,spawnCreatureAp = 40, displayCostAp = 46},
    {changeOwnerAp = 75,spawnCreatureAp = 41, displayCostAp = 47},
    {changeOwnerAp = 74,spawnCreatureAp = 42, displayCostAp = 48},
}


function initialise()
    Game.FIGHT_PHASE_ENDED = 1
    Game.PREPARNG_PHASE = 1
    Game.CREATURE_RANDOM = 1
    Game.Round = 1
    Game.PREPARING_COUNTDOWN  = 1
    Game.PLAYER_COLLUM_CREATURE_RANDOM  = 4
    Game.BOX_AND_FREE = 1
    Game.DESTROY_BOXES_TIMER = 0
    --REST RESET-BOX TIMER

    for _, cr in ipairs(Creatures) do
        SET_BOX_TOOLTIP(cr.SpecialBoxId, cr.BoxToolTip)    
    end

    SET_BOX_TOOLTIP(18, "START GAME")
    SET_BOX_TOOLTIP(19, "RESET ROUND, no money refund!")
    SET_BOX_TOOLTIP(20, "FREE IMP")

    QUICK_OBJECTIVE(1, "This is a rudimentary Auto Chess/Auto Battle implementation for Dungeon Keeper -Use the special boxes to select your creature. -Watch your gold, you receive a small amount back each round, and you get a bonus for every creature of yours that survives. -If you want to save gold or have none left, you can fill your battle lines with Imps using the special box. -Each surviving creature deals damage to the enemy heart. There are up to 9 rounds with an increasing number of creatures. -If both hearts are still standing after 9 rounds, the Keeper with the most victories wins. -The opponent receives and places their creatures completely randomly. -You can select from randomly chosen creatures each round (their level is set at the beginning of the game and does not change between rounds). -If you get stuck, you can restart the round using the special box, but note that you won't get back the gold you spent in that round.")

    CONCEAL_MAP_RECT(PLAYER0, 133, 121, 100, 100, 1)
    REVEAL_MAP_LOCATION(PLAYER0, PLAYER0, 18)
    SET_CREATURE_INSTANCE(DRUID, 2, RANGED_HEAL, 2)
    SET_CREATURE_INSTANCE(DRUID, 3, SLOW, 3)
    SET_CREATURE_INSTANCE(DRUID, 5, RANGED_ARMOUR, 5)
    SET_CREATURE_INSTANCE(GHOST, 5, RANGED_REBOUND, 5)
    SET_CREATURE_INSTANCE(TIME_MAGE, 8, RANGED_SPEED, 6)
    SET_CREATURE_INSTANCE(IMP, 1, NULL, 1)
    MAGIC_AVAILABLE(PLAYER0, POWER_IMP, 0, 0)
    MAGIC_AVAILABLE(PLAYER1, POWER_IMP, 0, 0)
    MAGIC_AVAILABLE(PLAYER1, POWER_HAND, 0, 0)
    MAGIC_AVAILABLE(PLAYER1, POWER_SLAP, 0, 0)
    MAGIC_AVAILABLE(PLAYER0, POWER_POSSESS, 0, 0)
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
    SET_CREATURE_PROPERTY(TUNNELLER, SPECIAL_DIGGER, 0)
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
    SET_TIMER(PLAYER0, TIMER6)

end


function damageHeart(player)
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
    ADD_HEART_HEALTH(player, -2000)
    CREATE_EFFECTS_LINE(location, player, 0, 3, 5, effect)

end

function processPlayerReward(creatures_remaining)
-- REWARD for PLAYER
IF(Game.SURVIVING_CREATURE_PLAYER_REWARD > 0)
    ADD_GOLD_TO_PLAYER(PLAYER0, 100)
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 1)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 59, 100)
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 2)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 60, 100)
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 3)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 68, 100)
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 4)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 69, 100)
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 5)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 70, 100)
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 6)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 71, 100)
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 7)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 72, 100)
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 8)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 73, 100)
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD == 9)
        CREATE_EFFECT("EFFECTELEMENT_PRICE", 50, 100)
        Game.SURVIVING_CREATURE_PLAYER_REWARD = 0
    ENDIF
    IF(Game.SURVIVING_CREATURE_PLAYER_REWARD > 0)
        Game.SURVIVING_CREATURE_PLAYER_REWARD = Game.SURVIVING_CREATURE_PLAYER_REWARD -1
    ENDIF
ENDIF

end 

function prepPhase()

end



function activateCreatureBoxes ()

    boxId = 0
    for _, cr in ipairs(Creatures) do
        if cr.SpecialBoxId == boxId then
            if(PLAYER0.MONEY >= cr.cost) then
                creature = getCreatureByCriterion("ALL_PLAYERS", "ANY_CREATURE", "AT_ACTION_POINT[" .. cr.changeOwnerAp .. "]")
                creature.owner = PLAYER0
                break
            else
                --not enough money, ignore box
                break
            end

            
        end
    end


    -- Replace Reset- and FREE-IMP-Box
    IF(PLAYER0, BOX19_ACTIVATED == 2)
        NEXT_COMMAND_REUSABLE
        ADD_OBJECT_TO_LEVEL_AT_POS(SPECBOX_CUSTOM, 115, 139, 19, PLAYER0) --"RESET ROUND, no money refund!"
        ADD_OBJECT_TO_LEVEL_AT_POS(SPECBOX_CUSTOM, 115, 145, 20, PLAYER0)--"FREE IMP"
        NEXT_COMMAND_REUSABLE
        SET_FLAG(PLAYER0, BOX19_ACTIVATED, 0)
    ENDIF
    IF(PLAYER0, BOX20_ACTIVATED == 2)
        NEXT_COMMAND_REUSABLE
        ADD_OBJECT_TO_LEVEL_AT_POS(SPECBOX_CUSTOM, 115, 145, 20, PLAYER0)--"FREE IMP"
        NEXT_COMMAND_REUSABLE
        SET_FLAG(PLAYER0, BOX20_ACTIVATED, 0)
    ENDIF
end



function placeEnemyCreatures()
--TODO ask Shinthoras the logic behind this
    for i = 1, Game.Round, 1 do
        if PLAYER.TOTAL_CREATURES < Game.Round then
            local ap = math.random(10, 32)
            local level = math.random(5, 9)
            local type = Creatures[ math.random( #Creatures ) ].Creature_type
            ADD_CREATURE_TO_LEVEL(PLAYER1, type, ap, 1, level, 0)
        end
    end

end