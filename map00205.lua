-- ********************************************
--
--        Lua Keeper Spell Blizzard
--        by Trotim April 2025
--
-- ********************************************
-- This map showcases a new Keeper Spell: Blizzard


function OnGameStart()
	QuickObjective("An aggressive enemy Keeper wants to take this land from you. Delay his army until you're strong enough to take him.",PLAYER1)

    Setup()
    Setup_triggers()
end


function Setup()
    SetGenerateSpeed(400)
	
    MaxCreatures(PLAYER0, 30)
    MaxCreatures(PLAYER1, 15)

    StartMoney(PLAYER0, 20000)
    StartMoney(PLAYER1, 8000)

    ComputerPlayer(PLAYER1, 16)

    AddCreatureToPool("SPIDER", 6)
    AddCreatureToPool("DRAGON", 6)
    AddCreatureToPool("SORCEROR", 6)
    AddCreatureToPool("BILE_DEMON", 6)
    AddCreatureToPool("TROLL", 6)
    AddCreatureToPool("ORC", 12)
    AddCreatureToPool("MAIDEN", 6)
    AddCreatureToPool("DARK_MISTRESS", 12)
    AddCreatureToPool("HELL_HOUND", 12)
    AddCreatureToPool("SKELETON", 12)

    CreatureAvailable("ALL_PLAYERS", "SPIDER", true, 0)
    CreatureAvailable("ALL_PLAYERS", "SORCEROR", true, 0)
    CreatureAvailable("ALL_PLAYERS", "TROLL", true, 0)
    CreatureAvailable("ALL_PLAYERS", "ORC", true, 0)
    CreatureAvailable("ALL_PLAYERS", "MAIDEN", true, 0)
    CreatureAvailable("ALL_PLAYERS", "DARK_MISTRESS", true, 0)
    CreatureAvailable("ALL_PLAYERS", "HELL_HOUND", true, 0)

    CreatureAvailable("PLAYER0", "BILE_DEMON", true, 0)

    CreatureAvailable("PLAYER1", "DRAGON", true, 0)
    CreatureAvailable("PLAYER1", "SKELETON", true, 0)

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

    -- Rooms the player can claim.
    RoomAvailable("PLAYER0", "TEMPLE", 3, false)
    RoomAvailable("PLAYER0", "PRISON", 3, false)

    -- Rooms only for PLAYER1 (Blue).
    RoomAvailable("PLAYER1", "TEMPLE", 2, true)
    RoomAvailable("PLAYER1", "PRISON", 2, true)

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

    -- New spell unique to this map!
    MagicAvailable("PLAYER0", "POWER_BLIZZARD", true, true)

    TrapAvailable("ALL_PLAYERS", "POISON_GAS", true, 0)
    TrapAvailable("ALL_PLAYERS", "LIGHTNING", true, 0)
    TrapAvailable("ALL_PLAYERS", "WORD_OF_POWER", true, 0)

    DoorAvailable("ALL_PLAYERS", "WOOD", true, 0)
    DoorAvailable("ALL_PLAYERS", "STEEL", true, 0)
    DoorAvailable("ALL_PLAYERS", "MAGIC", true, 0)
end


function Get_distance(x1, y1, x2, y2)
    local x, y = x1-x2, y1-y2
    return math.sqrt(x*x+y*y)
end

Blizzard_distances = {
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    12
}
Blizzard_durations = {
    120,
    140,
    160,
    180,
    200,
    220,
    240,
    260,
    280
}

-- As outlined by Magic_power_UseFunction_template in templates.lua
function Magic_use_power_blizzard(player, power_kind, power_level, stl_x, stl_y, thing, is_free)
    if Game.BlizzardPower ~= nil then
        if player.GAME_TURN < Game.BlizzardStartTick + Blizzard_durations[Game.BlizzardPower] then
            return -1
        end
    end

    if PayForPower(player, power_kind, power_level, is_free) then
        CreateEffectAtPos("EFFECT_FALLING_ICE_BLOCKS", stl_x, stl_y, 1024)

        Game.BlizzardStartTick = player.GAME_TURN
        Game.BlizzardPlayer = player
        Game.BlizzardPower = power_level
        Game.BlizzardStlX = stl_x
        Game.BlizzardStlY = stl_y
        RegisterTimerEvent(function() Magic_blizzard_update(Game.BlizzardPlayer, Game.BlizzardPower, Game.BlizzardStlX, Game.BlizzardStlY) end, 1, false)

        return 1
    end
end


function Magic_blizzard_update(player, power_level, stl_x, stl_y)
    if player.GAME_TURN > Game.BlizzardStartTick + Blizzard_durations[power_level] then
        return
    end

    RegisterTimerEvent(function() Magic_blizzard_update(Game.BlizzardPlayer, Game.BlizzardPower, Game.BlizzardStlX, Game.BlizzardStlY) end, 1, false)

    if player.GAME_TURN % 7 == 0 then
        for i = 1, power_level, 1 do
            local effectStlRadiusX = math.random(-Blizzard_distances[power_level] + 2, Blizzard_distances[power_level] - 2)
            local effectStlRadiusY = math.random(-Blizzard_distances[power_level] + 2, Blizzard_distances[power_level] - 2)
            local effectStlX = math.max(1, stl_x + effectStlRadiusX)
            effectStlX = math.min(251, effectStlX)
            local effectStlY = math.max(1, stl_y + effectStlRadiusY)
            effectStlY = math.min(119, effectStlY)
    
            CreateEffectAtPos("EFFECTELEMENT_ENTRANCE_MIST", effectStlX, effectStlY, 128)
            CreateEffectAtPos("EFFECT_FALLING_ICE_BLOCKS", effectStlX, effectStlY, 1024)
        end

        local creatures = GetCreatures()
        
        for index, creature in ipairs(creatures) do
            if Get_distance(stl_x, stl_y, creature.pos.stl_x, creature.pos.stl_y) <= Blizzard_distances[power_level] then
                creature.health = math.max(1, creature.health - 1)
    
                if creature.orientation ~= 1024 then -- In lieu of being able to check already frozen state
                    CreateEffectAtPos("EFFECT_FALLING_ICE_BLOCKS", creature.pos.stl_x, creature.pos.stl_y, 1024)
                    UseSpellOnCreature(creature, "SPELL_FREEZE", 0)
                    creature.orientation = 1024
                end
            end
        end
    end
end


function Setup_triggers()
    RegisterTimerEvent(Info_blizzard, 300, false)

    RegisterOnActionPointEvent(Info_blizzard_gems, 1, PLAYER1)
    RegisterOnActionPointEvent(Info_blizzard_enemy, 2, PLAYER1)
    RegisterThingDamageEvent(Info_blizzard_battle)
    RegisterDungeonDestroyedEvent(function() WinGame(PLAYER0) end, PLAYER1)
    --RegisterOnConditionEvent(function() Win_game(PLAYER0) end, function() return PLAYER1.DUNGEON_DESTROYED >= 1 end)
end


function Info_blizzard()
    QuickInformation(1, "New spell: BLIZZARD\nUnleash a freezing snowstorm over an area for a limited time.")
    TutorialFlashButton(24, 0)
end


function Info_blizzard_gems()
    QuickInformation(2, "Consider casting BLIZZARD on enemy workers to slow them down.", 1)
    RevealMapLocation(PLAYER0, 1, 12)
end


function Info_blizzard_enemy()
    QuickInformation(3, "The enemy Keeper is already pushing into your half of this realm. BLIZZARD his Imps. Use that time to reinforce your walls.", 2)
    RevealMapLocation(PLAYER0, 2, 15)
end


function Info_blizzard_battle(eventData, triggerData)
    if Game.shownBattlePos == nil and eventData.thing.owner == PLAYER_GOOD then
        Game.shownBattlePos = eventData.thing.pos
        QuickInformationWithPos(4, "The enemy Keeper is fighting Heroes. Use BLIZZARD to turn the tide in the Heroes' favor.", Game.shownBattlePos.stl_x, Game.shownBattlePos.stl_y)
        RevealMapRect(PLAYER0, Game.shownBattlePos.stl_x, Game.shownBattlePos.stl_y, 18, 18)
    end
end