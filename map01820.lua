-- ********************************************
--
--              AutoChess map by Shinthoras
--              translated from DKscript to lua by qqluqq
--
-- ********************************************
-- battler where you can select your creatures and watch them fight against the enemy creatures
-- the enemy creatures are selected randomly and placed randomly
-- the player can select his creatures and place them in the battlefield


-- these are constants that are used in the script since they don't change they can just be local and don't need to be stored in the Game table
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

function OnGameStart()
    Initialise()
    RegisterSpecialActivatedEvent("special_activated")
    RegisterTimerEvent("drawPrices",25,true)
end

function Initialise()
    
    Game.columns = {
        {changeOwnerAp = 79,spawnCreatureAp = 62, displayCostAp = 43, boxAp = 61, type = nil, creature = nil},
        {changeOwnerAp = 78,spawnCreatureAp = 38, displayCostAp = 44, boxAp = 33, type = nil, creature = nil},
        {changeOwnerAp = 77,spawnCreatureAp = 39, displayCostAp = 45, boxAp = 34, type = nil, creature = nil},
        {changeOwnerAp = 76,spawnCreatureAp = 40, displayCostAp = 46, boxAp = 35, type = nil, creature = nil},
        {changeOwnerAp = 75,spawnCreatureAp = 41, displayCostAp = 47, boxAp = 36, type = nil, creature = nil},
        {changeOwnerAp = 74,spawnCreatureAp = 42, displayCostAp = 48, boxAp = 37, type = nil, creature = nil},
    }

    Game.BattlefieldCreatures = {}
    Game.Round = 0
    Game.player0heartEffectCounter = 0
    Game.player1heartEffectCounter = 0
    Game.BattleUnitCounter = 0

    for _, cr in ipairs(Creatures) do
        SetBoxTooltip(cr.SpecialBoxId, cr.BoxToolTip)
        
    end

    SetBoxTooltip(18, "START GAME")
    SetBoxTooltip(19, "RESET ROUND, no money refund!")
    SetBoxTooltip(20, "FREE IMP")

    QuickObjective("This is a rudimentary Auto Chess/Auto Battle implementation for Dungeon Keeper -Use the special boxes to select your creature. -Watch your gold, you receive a small amount back each round, and you get a bonus for every creature of yours that survives. -If you want to save gold or have none left, you can fill your battle lines with Imps using the special box. -Each surviving creature deals damage to the enemy heart. There are up to 9 rounds with an increasing number of creatures. -If both hearts are still standing after 9 rounds, the Keeper with the most victories wins. -The opponent receives and places their creatures completely randomly. -You can select from randomly chosen creatures each round (their level is set at the beginning of the game and does not change between rounds). -If you get stuck, you can restart the round using the special box, but note that you won't get back the gold you spent in that round.")

    ConcealMapRect(PLAYER0, 133, 121, 100, 100, true)

    RevealMapLocation(PLAYER0, "PLAYER0", 18)
    ComputerPlayer(PLAYER1, 0)
    --Set_computer_globals(PLAYER1, 0, 0, 0, 0, 0, 0, 0)
    
    StartMoney(PLAYER0, 2000)

    SetCreatureInstance("DRUID", 2, "RANGED_HEAL", 2)
    SetCreatureInstance("DRUID", 3, "SLOW", 3)
    SetCreatureInstance("DRUID", 5, "RANGED_ARMOUR", 5)
    SetCreatureInstance("GHOST", 5, "RANGED_REBOUND", 5)
    SetCreatureInstance("TIME_MAGE", 8, "RANGED_SPEED", 6)
    SetCreatureInstance("IMP", 1, "NULL", 1)
    MagicAvailable(PLAYER0, "POWER_IMP", false, false)
    MagicAvailable(PLAYER1, "POWER_IMP", false, false)
    MagicAvailable(PLAYER1, "POWER_HAND", false, false)
    MagicAvailable(PLAYER1, "POWER_SLAP", false, false)
    MagicAvailable(PLAYER0, "POWER_POSSESS", false, false)
 
    SetObjectConfiguration("SPECBOX_CUSTOM", "DestroyOnLava", 1)
    SetObjectConfiguration("CTA_ENSIGN", "MaximumSize", 1)
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Stand, 556)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Ambulate, 554)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Attack, 558)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, GotHit, 560)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, GotHit, 560)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, PowerGrab, 574)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, GotSlapped, 576)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Celebrate, 564)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Scream, 570)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, DropDead, 572)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, DeadSplat, 946)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, QuerySymbol, 154)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, HandSymbol, 222)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Foot, 9, 4)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Hit, 490, 1)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Happy, 488, 1)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Hurt, 490, 3)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Die, 493, 2)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Hang, 495, 1)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Drop, 4961, 4)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Slap, 490, 3)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Fight, 485, 3)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Health, 75)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Strength, 5)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Armour, 5)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Dexterity, 60)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, FearWounded, 0)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, FearStronger, 10000)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Defence, 7)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, Luck, 0)")
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, SlapsToKill, 5)")
    RunDKScriptCommand("Set_creature_property(\"TUNNELLER\", \"SPECIAL_DIGGER\", 0)")

    
    SetGameRule("DungeonHeartHealHealth", 0)

end


function select_units_in_columns()
    for index, col in ipairs(Game.columns) do
        rownNo = math.random(ROWS_COUNT)
        for _, cr in ipairs(Creatures) do
            if cr.column == index and cr.Row == rownNo then
                col.type = cr
                AddObjectToLevel("SPECBOX_CUSTOM", col.boxAp, cr.SpecialBoxId, PLAYER0)
                
                local level = math.random(cr.levelRange[1], cr.levelRange[2])
                print(cr.Creature_type)
                col.creature = AddCreatureToLevel(PLAYER_GOOD, cr.Creature_type, col.spawnCreatureAp, 1, level, "DEFAULT")

                break
            end
        end
    end
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
    AddHeartHealth(player, -2000,false)
    CreateEffectsLine(location, player, 0, 3, 5, effect)

end

function damageHeart()
    -- Evaluation phase
    -- Process heart damage
    if PLAYER0.TOTAL_CREATURES == 0 then
        if PLAYER1.TOTAL_CREATURES > 0 then
            damageHeart_effect(PLAYER0)
        end

        CreateEffectsLine("COMBAT", PLAYER0, 0, 6, 10, "EFFECTELEMENT_BLUE_SPARKLES_LARGE")
        CreateEffect("EFFECT_WORD_OF_POWER", PLAYER0,0)
    end
    if PLAYER1.TOTAL_CREATURES == 0 then
        if PLAYER0.TOTAL_CREATURES > 0 then
            damageHeart_effect(PLAYER1)
        end
        processPlayerReward()

        AddHeartHealth(PLAYER1, -1500,false)
        CreateEffectsLine("COMBAT", PLAYER1, 0, 6, 10, "EFFECTELEMENT_RED_SPARKLES_LARGE")
        CreateEffect("EFFECT_WORD_OF_POWER", PLAYER1,0)
    end
    
end

---creates price effect on the remaining creatures to indicate gold recieved for winning
---and adds said gold
function processPlayerReward()

    local counter = 0

    local creatures = GetThingsOfClass("Creature")
    
    for index, cr in ipairs(creatures) do
        counter = counter + 1
        --timer so only 1 effect per tick instead of all simultaniosly
        RegisterTimerEvent(function (eventData,triggerData) 
                                CreateEffect("EFFECTELEMENT_PRICE", triggerData.pos, 100)
                                PLAYER0:add_gold(100)
                            end,counter,false).triggerData.pos = cr.pos
    end


end

function kill_all_creatures()
    local creatures = GetCreatures()
    
    for index, cr in ipairs(creatures) do
        cr:kill()
    end
end

function end_battle()
    damageHeart()
    kill_all_creatures()
    start_prep_phase()
    Game.Round = Game.Round + 1
end

function start_fight_phase()

    ---- Fight phase
    ChangeSlabType(40, 40, "BRIDGE_FRAME", "MATCH")

    UsePowerAtLocation(PLAYER0, 63, "POWER_CALL_TO_ARMS", 3, true)
    UsePowerAtLocation(PLAYER1, 63, "POWER_CALL_TO_ARMS", 3, true)

    MagicAvailable(PLAYER0, "POWER_CALL_TO_ARMS", true, true)
    MagicAvailable(PLAYER1, "POWER_CALL_TO_ARMS", true, true)
    UsePowerAtPos(PLAYER0,91,37,"POWER_CAVE_IN", 1, true)
    --SET_PLAYER_MODIFIER(PLAYER0, "SpellDamage", 500)
    --SET_PLAYER_MODIFIER(PLAYER0, "Strength", 500)
    --SET_PLAYER_MODIFIER(PLAYER1, "SpellDamage", 500)
    --SET_PLAYER_MODIFIER(PLAYER1, "Strength", 500)

    RunDKScriptCommand("Set_game_rule(\"BodyRemainsFor\", 2000)")
    RunDKScriptCommand("Set_creature_configuration(\"TUNNELLER\",     \"BaseSpeed\", 96)")
    RunDKScriptCommand("Set_creature_configuration(\"BILE_DEMON\",    \"BaseSpeed\", 48)")
    RunDKScriptCommand("Set_creature_configuration(\"BUG\",           \"BaseSpeed\", 48)")
    RunDKScriptCommand("Set_creature_configuration(\"DARK_MISTRESS\", \"BaseSpeed\", 64)")
    RunDKScriptCommand("Set_creature_configuration(\"DEMONSPAWN\",    \"BaseSpeed\", 48)")
    RunDKScriptCommand("Set_creature_configuration(\"DRAGON\",        \"BaseSpeed\", 32)")
    RunDKScriptCommand("Set_creature_configuration(\"DRUID\",         \"BaseSpeed\", 32)")
    RunDKScriptCommand("Set_creature_configuration(\"FLY\",           \"BaseSpeed\", 128)")
    RunDKScriptCommand("Set_creature_configuration(\"GHOST\",         \"BaseSpeed\", 64)")
    RunDKScriptCommand("Set_creature_configuration(\"HELL_HOUND\",    \"BaseSpeed\", 96)")
    RunDKScriptCommand("Set_creature_configuration(\"HORNY\",         \"BaseSpeed\", 96)")
    RunDKScriptCommand("Set_creature_configuration(\"ORC\",           \"BaseSpeed\", 48)")
    RunDKScriptCommand("Set_creature_configuration(\"SKELETON\",      \"BaseSpeed\", 64)")
    RunDKScriptCommand("Set_creature_configuration(\"SORCEROR\",      \"BaseSpeed\", 32)")
    RunDKScriptCommand("Set_creature_configuration(\"SPIDER\",        \"BaseSpeed\", 48)")
    RunDKScriptCommand("Set_creature_configuration(\"TENTACLE\",      \"BaseSpeed\", 32)")
    RunDKScriptCommand("Set_creature_configuration(\"TIME_MAGE\",     \"BaseSpeed\", 32)")
    RunDKScriptCommand("Set_creature_configuration(\"TROLL\",         \"BaseSpeed\", 48)")
    RunDKScriptCommand("Set_creature_configuration(\"VAMPIRE\",       \"BaseSpeed\", 56)")
    MagicAvailable(PLAYER0, "POWER_HAND", false, false)

    RegisterOnConditionEvent("end_battle",function ()
                                return PLAYER0.TOTAL_CREATURES == 0 or PLAYER1.TOTAL_CREATURES == 0
                            end)
end

function start_prep_phase()
    Game.BattleUnitCounter = 0
    placeEnemyCreature()
    select_units_in_columns()
    ChangeSlabType(40, 40, "LIBRARY_WALL", "MATCH")

    RunDKScriptCommand("SET_PLAYER_MODIFIER(PLAYER0, SpellDamage, 100)")
    RunDKScriptCommand("SET_PLAYER_MODIFIER(PLAYER0, Strength, 100)")
    RunDKScriptCommand("SET_PLAYER_MODIFIER(PLAYER1, SpellDamage, 100)")
    RunDKScriptCommand("SET_PLAYER_MODIFIER(PLAYER1, Strength, 100)")
    MagicAvailable(PLAYER0, "POWER_CALL_TO_ARMS", false, false)
    MagicAvailable(PLAYER1, "POWER_CALL_TO_ARMS", false, false)
    RunDKScriptCommand("Set_creature_configuration(TUNNELLER, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(BILE_DEMON, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(BUG, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(DARK_MISTRESS, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(DEMONSPAWN, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(DRAGON, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(DRUID, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(FLY, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(GHOST, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(HELL_HOUND, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(HORNY, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(ORC, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(SKELETON, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(SORCEROR, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(SPIDER, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(TENTACLE, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(TIME_MAGE, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(TROLL, BaseSpeed, 0)")
    RunDKScriptCommand("Set_creature_configuration(VAMPIRE, BaseSpeed, 0)")
    MagicAvailable(PLAYER0, "POWER_HAND", true, true)
    RunDKScriptCommand("Set_game_rule(BodyRemainsFor, 1)")
    

end

local function reset_round()
    UsePower(PLAYER_GOOD, "POWER_HOLD_AUDIENCE", true)
    --getCreatureByCriterion(PLAYER0, "ANY_CREATURE", "AT_ACTION_POINT[63]").TeleportCreature(20,"EFFECT_BALL_PUFF_RED")
    --getCreatureByCriterion(PLAYER1, "ANY_CREATURE", "AT_ACTION_POINT[63]").TeleportCreature(20,"EFFECT_BALL_PUFF_BLUE")
end

local function spawn_imp()
    --SET_FLAG(PLAYER0, FLAG4, 3)
    AddCreatureToLevel(PLAYER0, "TUNNELLER", 49, 1, 1, "DEFAULT")
end

local function start_level()

    Game.Round = 1

    RevealMapRect(PLAYER0, 133, 121, 70, 70)
    start_prep_phase()
end

function unit_placed_in_battlefield()
    print('unit_placed_in_battlefield')

    Game.BattleUnitCounter = Game.BattleUnitCounter + 1

    if Game.BattleUnitCounter == Game.Round then
        start_fight_phase()
    else
        placeEnemyCreature()
        select_units_in_columns()
    end
end

local function clear_special_boxes_and_non_selected_units()
    local objects = GetThingsOfClass("Object")
    for index, ob in ipairs(objects) do
        if ob.model == "SPECBOX_CUSTOM" then
            ob:delete()
        end
    end

    local creatures = GetCreatures()
    
    for index, cr in ipairs(creatures) do
        if cr.owner == PLAYER_GOOD then
            cr:kill()
        end
    end
end

local function unit_select_special(cr)

    if PLAYER0.MONEY >= cr.cost then
        Game.columns[cr.column].creature.owner = PLAYER0
        PLAYER0:add_gold(-cr.cost)
        table.insert(Game.BattlefieldCreatures,Game.columns[cr.column].creature)
        clear_special_boxes_and_non_selected_units()
        RegisterOnConditionEvent("unit_placed_in_battlefield",function ()
                                                            return CountCreaturesAtActionPoint(63,PLAYER0,"ANY_CREATURE") == Game.BattleUnitCounter + 1
                                                        end)
    end
end

function special_activated (eventData,triggerData)

    if eventData.SpecialBoxId == 18 then --START GAME
        start_level()
    elseif eventData.SpecialBoxId == 19 then --"RESET ROUND, no money refund!"
        AddObjectToLevelAtPos("SPECBOX_CUSTOM", 115, 139, 19, PLAYER0)
        reset_round()
    elseif eventData.SpecialBoxId == 20 then --"FREE IMP"
        AddObjectToLevelAtPos("SPECBOX_CUSTOM", 115, 145, 20, PLAYER0)
        spawn_imp()
    else
        for _, cr in ipairs(Creatures) do
            if cr.SpecialBoxId == eventData.SpecialBoxId then
                unit_select_special(cr)
            end
        end
    end
end

function placeEnemyCreature()
    if PLAYER1.TOTAL_CREATURES < Game.Round then
        local ap = math.random(10, 32)
        local cr = Creatures[ math.random( #Creatures ) ]
        local level = math.random(cr.levelRange[1], cr.levelRange[2])
        table.insert(Game.BattlefieldCreatures,AddCreatureToLevel(PLAYER1, cr.Creature_type, ap, 1, level, "DEFAULT"))
    end
end

function drawPrices()
    for index, col in ipairs(Game.columns) do
        if col.creature == nil then
            return
        end
        CreateEffect("EFFECTELEMENT_PRICE", col.displayCostAp, col.type.cost)
    end
end

function game_end()
    --IF(Game.MaxCreatures == 10)
    --    Hide_variable
    --    if Game.WINFLAG_FOR_COMPUTER > Game.WINFLAG_FOR_PLAYER)
    --        SET_HEART_HEALTH(PLAYER0, 0)
    --        Create_effects_line(PLAYER1, PLAYER0, 0, 6, 10, EFFECTELEMENT_BLUE_SPARKLES_LARGE)
    --        Lose_game
    --        NEXT_COMMAND_REUSABLE
    --        KILL_CREATURE(ALL_PLAYERS, ANY_CREATURE, ANYWHERE, 10)
    --        Set_object_configuration(SPECBOX_CUSTOM, MaximumSize, 1)
    --        Set_object_configuration(SPECBOX_CUSTOM, Genre, Furniture)
    --    end
    --    if Game.WINFLAG_FOR_COMPUTER < Game.WINFLAG_FOR_PLAYER)
    --        SET_HEART_HEALTH(PLAYER1, 0)
    --        Create_effects_line(PLAYER0, PLAYER1, 0, 6, 10, EFFECTELEMENT_RED_SPARKLES_LARGE)
    --        Win_game
    --        NEXT_COMMAND_REUSABLE
    --        KILL_CREATURE(ALL_PLAYERS, ANY_CREATURE, ANYWHERE, 10)
    --        Set_object_configuration(SPECBOX_CUSTOM, MaximumSize, 1)
    --        Set_object_configuration(SPECBOX_CUSTOM, Genre, Furniture)
    --    end
    --end
    --IF(PLAYER1, DUNGEON_DESTROYED == 1)
    --    Create_effects_line(PLAYER0, PLAYER1, 0, 6, 10, EFFECTELEMENT_RED_SPARKLES_LARGE)
    --    Hide_variable
    --    Win_game
    --    NEXT_COMMAND_REUSABLE
    --    KILL_CREATURE(ALL_PLAYERS, ANY_CREATURE, ANYWHERE, 10)
    --    Set_object_configuration(SPECBOX_CUSTOM, MaximumSize, 1)
    --    Set_object_configuration(SPECBOX_CUSTOM, Genre, Furniture)
    --end
    --IF(PLAYER0, HEART_HEALTH < 100)
    --    Create_effects_line(PLAYER1, PLAYER0, 0, 6, 10, EFFECTELEMENT_BLUE_SPARKLES_LARGE)
    --    Hide_variable
    --    Lose_game
    --    NEXT_COMMAND_REUSABLE
    --    KILL_CREATURE(ALL_PLAYERS, ANY_CREATURE, ANYWHERE, 10)
    --    Set_object_configuration(SPECBOX_CUSTOM, MaximumSize, 1)
    --    Set_object_configuration(SPECBOX_CUSTOM, Genre, Furniture)
    --end
end

