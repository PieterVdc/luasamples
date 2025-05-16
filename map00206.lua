-- ********************************************
--
--        Custom Thing Update Function
--        by Trotim May 2025
--
-- ********************************************
-- Shows how to define custom objects with custom behaviors defined as Lua functions


function OnGameStart()
	QuickObjective("There is no Gold to mine in this land. However, magical GOLD STATUES will provide you a steady income. Explore to find more.")

    Setup()
    SetupTriggers()
end


function Setup()
    SetGenerateSpeed(1000)
	
    MaxCreatures(PLAYER0, 30)

    StartMoney(PLAYER0, 800)

    AddCreatureToPool("SPIDER", 4)
    AddCreatureToPool("DRAGON", 4)
    AddCreatureToPool("BILE_DEMON", 4)
    AddCreatureToPool("SORCEROR", 4)
    AddCreatureToPool("TROLL", 4)
    AddCreatureToPool("ORC", 4)
    AddCreatureToPool("MAIDEN", 4)
    AddCreatureToPool("DARK_MISTRESS", 4)

    CreatureAvailable("ALL_PLAYERS", "SPIDER", true, 0)
    CreatureAvailable("ALL_PLAYERS", "DRAGON", true, 0)
    CreatureAvailable("ALL_PLAYERS", "BILE_DEMON", true, 0)
    CreatureAvailable("ALL_PLAYERS", "SORCEROR", true, 0)
    CreatureAvailable("ALL_PLAYERS", "TROLL", true, 0)
    CreatureAvailable("ALL_PLAYERS", "ORC", true, 0)
    CreatureAvailable("ALL_PLAYERS", "MAIDEN", true, 0)
    CreatureAvailable("ALL_PLAYERS", "DARK_MISTRESS", true, 0)

    -- These rooms are always available.
    RoomAvailable("ALL_PLAYERS", "TREASURE", 2, true)
    RoomAvailable("ALL_PLAYERS", "LAIR", 2, true)
    RoomAvailable("ALL_PLAYERS", "GARDEN", 2, true)
    RoomAvailable("ALL_PLAYERS", "TRAINING", 2, true)
    RoomAvailable("ALL_PLAYERS", "RESEARCH", 2, true)
    RoomAvailable("ALL_PLAYERS", "WORKSHOP", 2, true)

    RoomAvailable("ALL_PLAYERS", "BRIDGE", 2, false)
    RoomAvailable("ALL_PLAYERS", "GUARD_POST", 2, false)
    RoomAvailable("ALL_PLAYERS", "BARRACKS", 2, false)
    RoomAvailable("ALL_PLAYERS", "TEMPLE", 2, false)
    RoomAvailable("ALL_PLAYERS", "TORTURE", 2, false)

    -- These spells are always available.
    MagicAvailable("ALL_PLAYERS", "POWER_IMP", true, true)
    MagicAvailable("ALL_PLAYERS", "POWER_SIGHT", true, true)
    MagicAvailable("ALL_PLAYERS", "POWER_CALL_TO_ARMS", true, true)

    MagicAvailable("ALL_PLAYERS", "POWER_SPEED", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_OBEY", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_HEAL_CREATURE", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_CONCEAL", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_HOLD_AUDIENCE", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_CHICKEN", true, false)

    TrapAvailable("ALL_PLAYERS", "LIGHTNING", true, 0)

    DoorAvailable("ALL_PLAYERS", "WOOD", true, 0)
end


function GetDistance(x1, y1, x2, y2)
    local x, y = x1-x2, y1-y2
    return math.sqrt(x*x+y*y)
end

-- As outlined by objects_UpdateFunction_template in \fxdata\lua\config-api\objects-templates.lua
-- Holy Candles heal all nearby Heroes by 10% HP per second and weaken Red creatures by 4% HP per second.
function UpdateHolyCandle(object)
    if PLAYER0.GAME_TURN % 20 == 0 then
        CreateEffect("EFFECT_ELECTRIC_BALLS", object.pos, 256)

        local creatures = GetCreatures()
        
        for index, creature in ipairs(creatures) do
            if GetDistance(object.pos.stl_x, object.pos.stl_y, creature.pos.stl_x, creature.pos.stl_y) <= 9 then
                if creature.owner == PLAYER_GOOD then
                    creature.health = math.min(creature.health + creature.max_health * 0.10, creature.max_health)
                    CreateEffect("EFFECTELEMENT_ELECTRIC_BALL1", creature.pos, 64)
                elseif creature.owner == PLAYER0 then
                    creature.health = math.max(creature.health - creature.max_health * 0.04, 1)
                    CreateEffect("EFFECT_BLOOD_HIT", creature.pos, 64)
                end
            end
        end
    end

    return 1
end


-- Gold Statues generate 15 Gold per second.
function UpdateGoldStatue(object)
    if PLAYER0.GAME_TURN % 20 == 0 then
        if GetSlab(object.pos.slb_x, object.pos.slb_y).owner == PLAYER0 then
            CreateEffect("EFFECTELEMENT_PRICE", object.pos, 15)
            PLAYER0:add_gold(15)
        end
    end

    return 1
end


-- Necronomicon creates 1 Skeleton every minute.
function UpdateNecronomicon(object)
    if PLAYER0.GAME_TURN % 1200 == 0 then
        if GetSlab(object.pos.slb_x, object.pos.slb_y).owner == PLAYER0 then
            CreateEffect("EFFECT_EXPLOSION_3", object.pos, 10)
            AddCreatureToLevel(PLAYER0, "SKELETON", object.pos, 1, 0, "JUMP")
        end
    end

    return 1
end


function SetupTriggers()
    RegisterTimerEvent(InfoStatues, 1200, false)
    RegisterOnActionPointEvent(InfoNecronomicon, 1, PLAYER0)
    RegisterTimerEvent(SendTunneller, 3600, false)
    RegisterTimerEvent(SendTunnellerTwo, 8400, false)
    RegisterTimerEvent(InfoFinalWave, 12600, false)
    RegisterTimerEvent(SendDND, 16200, false)
end


function InfoStatues()
    QuickInformation(1, "GOLD STATUES will generate 15 gold per second as long as they stand on your claimed land.")
end


function InfoNecronomicon()
    QuickInformation(2, "This NECRONOMICON will summon a new Skeleton for you every minute.")
end


function InfoHolyCandle()
    QuickInformation(3, "Stay away from HOLY CANDLES. They make nearby Heroes nigh undefeatable, and weaken your creatures.", Game.CandlePos)
end


function InfoHolyCandleTwo()
    QuickInformation(4, "Another HOLY CANDLE. Remember to help your creatures stay away from them.", Game.CandlePos)
end


function InfoFinalWave()
    QuickObjective("I can hear the clanking of rusty armour in the distance. Get ready for their final attack.")
end


function SendTunneller()
    CreateParty("Scouts")
    AddToParty("Scouts", "DWARFA", 1, 500, "ATTACK_DUNGEON_HEART", 0)
	AddToParty("Scouts", "THIEF", 1, 500, "ATTACK_DUNGEON_HEART", 0)

    local party = AddTunnellerPartyToLevel(PLAYER_GOOD, "Scouts", -2, "DUNGEON", 0, 1, 250)
    Game.CandleHolder = party[1]
    Game.CandleHolder:OnDeath(DropCandleOnDeath)
end


function DropCandleOnDeath()
    CreateEffect("EFFECT_BALL_PUFF_WHITE", Game.CandleHolder.pos, 64)
    AddObjectToLevel("HOLY_CANDLE", Game.CandleHolder.pos, 0)
    Game.CandlePos = Game.CandleHolder.pos

    RegisterTimerEvent(InfoHolyCandle, 100, false)
end


function SendTunnellerTwo()
    CreateParty("Vanguard")
	AddToParty("Vanguard", "ARCHER", 3, 500, "ATTACK_DUNGEON_HEART", 0)
	AddToParty("Vanguard", "ARCHER", 2, 500, "ATTACK_DUNGEON_HEART", 0)
    AddToParty("Vanguard", "BARBARIAN", 2, 500, "ATTACK_DUNGEON_HEART", 0)
    AddToParty("Vanguard", "BARBARIAN", 1, 500, "ATTACK_DUNGEON_HEART", 0)

    local party = AddTunnellerPartyToLevel(PLAYER_GOOD, "Vanguard", -2, "DUNGEON", 0, 3, 250)
    Game.CandleHolder = party[1]
    Game.CandleHolder:OnDeath(DropCandleOnDeathTwo)
end


function DropCandleOnDeathTwo()
    CreateEffect("EFFECT_BALL_PUFF_WHITE", Game.CandleHolder.pos, 64)
    AddObjectToLevel("HOLY_CANDLE", Game.CandleHolder.pos, 0)
    Game.CandlePos = Game.CandleHolder.pos

    RegisterTimerEvent(InfoHolyCandleTwo, 100, false)
end


function SendDND()
    CreateParty("DND")
    AddToParty("DND", "WIZARD", 5, 1000, "ATTACK_DUNGEON_HEART", 0)
    AddToParty("DND", "KNIGHT", 4, 1000, "ATTACK_DUNGEON_HEART", 0)
	AddToParty("DND", "ARCHER", 4, 1000, "ATTACK_DUNGEON_HEART", 0)
    AddToParty("DND", "FAIRY", 3, 1000, "ATTACK_DUNGEON_HEART", 0)

    AddTunnellerPartyToLevel(PLAYER_GOOD, "DND", -1, "DUNGEON", 0, 3, 500)

    -- Also teleport all remaining roaming heroes in case the player hasn't found them yet...
    local creatures = GetCreatures()
        
    for index, creature in ipairs(creatures) do
        if creature.owner == PLAYER_GOOD then
            creature:teleport(-1, "EFFECT_BALL_PUFF_WHITE")
        end
    end

    RegisterOnConditionEvent(function() WinGame(PLAYER0) end, function() return PLAYER_GOOD.TOTAL_CREATURES <= 0 end)
end