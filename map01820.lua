--AutoChess map by Shinthoras, translated from DKscript to lua by qqluqq


function initialise()
    PLAYER0.FLAG0 = 1
    PLAYER0.FLAG1 = 1
    PLAYER0.FLAG4 = 1
    PLAYER0.FLAG7 = 1
    PLAYER1.FLAG0 = 1
    PLAYER0.FLAG2 = 4
    PLAYER1.FLAG7 = 1
    --REST RESET-BOX TIMER

    --row1
    SET_BOX_TOOLTIP(0, "BILE DEMON")
    SET_BOX_TOOLTIP(1, "BUG")
    SET_BOX_TOOLTIP(2, "DARK MISTRESS")
    SET_BOX_TOOLTIP(3, "DEMONSPAWN")
    SET_BOX_TOOLTIP(4, "DRAGON")
    SET_BOX_TOOLTIP(5, "DRUID")
    --row2
    SET_BOX_TOOLTIP(6, "FLY")
    SET_BOX_TOOLTIP(7, "GHOST")
    SET_BOX_TOOLTIP(8, "HELL HOUND")
    SET_BOX_TOOLTIP(9, "HORNY")
    SET_BOX_TOOLTIP(10, "ORC")
    SET_BOX_TOOLTIP(11, "SKELETON")
    --row3
    SET_BOX_TOOLTIP(12, "WARLOCK")
    SET_BOX_TOOLTIP(13, "SPIDER")
    SET_BOX_TOOLTIP(14, "TENTACLE")
    SET_BOX_TOOLTIP(15, "TIME MAGE")
    SET_BOX_TOOLTIP(16, "TROLL")
    SET_BOX_TOOLTIP(17, "VAMPIRE")

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
    SET_FLAG(PLAYER0, FLAG5, 0)
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
IF(PLAYER3, FLAG2 > 0)
    ADD_GOLD_TO_PLAYER(PLAYER0, 100)
    IF(PLAYER3, FLAG2 == 1)
        CREATE_EFFECT(-41, 59, 100)
    ENDIF
    IF(PLAYER3, FLAG2 == 2)
        CREATE_EFFECT(-41, 60, 100)
    ENDIF
    IF(PLAYER3, FLAG2 == 3)
        CREATE_EFFECT(-41, 68, 100)
    ENDIF
    IF(PLAYER3, FLAG2 == 4)
        CREATE_EFFECT(-41, 69, 100)
    ENDIF
    IF(PLAYER3, FLAG2 == 5)
        CREATE_EFFECT(-41, 70, 100)
    ENDIF
    IF(PLAYER3, FLAG2 == 6)
        CREATE_EFFECT(-41, 71, 100)
    ENDIF
    IF(PLAYER3, FLAG2 == 7)
        CREATE_EFFECT(-41, 72, 100)
    ENDIF
    IF(PLAYER3, FLAG2 == 8)
        CREATE_EFFECT(-41, 73, 100)
    ENDIF
    IF(PLAYER3, FLAG2 == 9)
        CREATE_EFFECT(-41, 50, 100)
        SET_FLAG(PLAYER3, FLAG2, 0)
    ENDIF
    IF(PLAYER3, FLAG2 > 0)
        ADD_TO_FLAG(PLAYER3, FLAG2, -1)
    ENDIF
ENDIF