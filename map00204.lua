-- ********************************************
--
--             Lua Limited Vision
--             by Trotim April 2025
--
-- ********************************************
-- On this map, the player's vision is restricted to only near their heart, their creatures, and their Alarm Traps.
-- This is achieved by, on every game tick, concealing the whole map, then revealing only chosen slabs.


function OnGameStart()
	QuickObjective("It's getting hard to see so deep down, Keeper. Explore the area. Use ALARM TRAPs to gain permanent vision.")
	
    My_setup()
end


function My_setup()
    SetGenerateSpeed(350)
	
    MaxCreatures(PLAYER0, 30)

    StartMoney(PLAYER0, 6000)

    AddCreatureToPool("FLY", 2)
    AddCreatureToPool("BUG", 8)
    AddCreatureToPool("SPIDER", 8)
    AddCreatureToPool("BILE_DEMON", 4)
    AddCreatureToPool("DEMONSPAWN", 8)
    AddCreatureToPool("SORCEROR", 8)
    AddCreatureToPool("ORC", 8)

    CreatureAvailable("ALL_PLAYERS", "FLY", true, 1)
    CreatureAvailable("ALL_PLAYERS", "BUG", true, 0)
    CreatureAvailable("ALL_PLAYERS", "SPIDER", true, 0)
    CreatureAvailable("ALL_PLAYERS", "BILE_DEMON", true, 0)
    CreatureAvailable("ALL_PLAYERS", "DEMONSPAWN", true, 0)
    CreatureAvailable("ALL_PLAYERS", "SORCEROR", true, 0)
    CreatureAvailable("ALL_PLAYERS", "ORC", true, 0)

    RoomAvailable("ALL_PLAYERS", "TREASURE", 2, true)
    RoomAvailable("ALL_PLAYERS", "LAIR", 2, true)
    RoomAvailable("ALL_PLAYERS", "GARDEN", 2, true)

    RoomAvailable("ALL_PLAYERS", "BRIDGE", 2, false)

    -- Have to find and claim these on the map.
    RoomAvailable("ALL_PLAYERS", "TRAINING", 3, false)
    RoomAvailable("ALL_PLAYERS", "RESEARCH", 3, false)
    RoomAvailable("ALL_PLAYERS", "WORKSHOP", 3, false)
    RoomAvailable("ALL_PLAYERS", "BARRACKS", 3, false)

    MagicAvailable("ALL_PLAYERS", "POWER_IMP", true, true)
    MagicAvailable("ALL_PLAYERS", "POWER_CALL_TO_ARMS", true, true)
    MagicAvailable("ALL_PLAYERS", "POWER_SPEED", true, false)
    MagicAvailable("ALL_PLAYERS", "POWER_HEAL_CREATURE", true, false)

    DoorAvailable("ALL_PLAYERS", "WOOD", true, 0)

    TrapAvailable("ALL_PLAYERS", "ALARM", true, 8)

    -- Make Alarm Traps easier to create in the Workshop.
    SetTrapConfiguration("ALARM","ManufactureRequired",9000)

    CreateParty("STEALER")
    AddToParty("STEALER", "THIEF", 1, 0, "STEAL_GOLD", 0)

    RegisterTimerEvent(Update_vision, 1, true)

    RegisterTimerEvent(Create_random_thieves, 1200, false)
    RegisterTimerEvent(Send_wave_one, 9000, false)
    RegisterTimerEvent(Send_wave_final, 11000, false)

    -- Gives killed hero creatures a chance to drop workshop crates
    -- That way, they get more Alarm Traps (and Lightning traps).
    RegisterCreatureDeathEvent(Drop_random_loot)
end


function Update_vision()
    ConcealMapRect(PLAYER0, 61, 61, 122, 122, true)

    local creatures = GetCreatures()
    for index, creature in ipairs(creatures) do
        if creature.owner == PLAYER0 then
            RevealMapRect(PLAYER0, creature.pos.stl_x, creature.pos.stl_y, 21, 21)
        end
    end

    local objects = GetThingsOfClass("Object")
    for index, object in ipairs(objects) do
        if object.model == "SOUL_CONTAINER" then
            RevealMapRect(PLAYER0, object.pos.stl_x, object.pos.stl_y, 24, 24)
        end
    end

    local traps = GetThingsOfClass("Trap")
    for index, trap in ipairs(traps) do
        if trap.model == "ALARM" then
            RevealMapRect(PLAYER0, trap.pos.stl_x, trap.pos.stl_y, 30, 30)
        end
    end
end


function Create_random_thieves()
    local gateThief = AddPartyToLevel(PLAYER_GOOD, "STEALER", -math.random(1,2))

    local spawnTimer = RegisterTimerEvent(Create_random_thieves, 900 + math.random(0, 600), false)
    TriggerAddCondition(spawnTimer, function() return Game.lord == nil end)
end


function Slab_is_walkable(slb_x, slb_y)
    if GetSlab(slb_x, slb_y).kind == "PATH" then return true end
    if GetSlab(slb_x, slb_y).kind == "PRETTY_PATH" then return true end
    if GetSlab(slb_x, slb_y).kind == "WATER" then return true end

    return false
end


function Drop_random_loot(eventData, triggerData)
    if eventData.unit.owner == PLAYER_GOOD then
        local pos = eventData.unit.pos

        -- 40% chance to drop a workshop box.
        if math.random(1,100) <= 40 then
            -- 20% chance for it to be a Lightning Trap, otherwise it's an Alarm Trap.
            if math.random(1,100) <= 20 then
                Add_object_to_level("WRKBOX_LIGHTNG", pos, 0)
            else
                Add_object_to_level("WRKBOX_ALARM", pos, 0)
            end
        end
    end
end


function Send_wave_one()
    QuickObjective("I hope you're prepared, Keeper. The Lord and his lackeys are on their way.")

    CreateParty("ONE")
    AddToParty("ONE", "BARBARIAN", 6, 0, "ATTACK_DUNGEON_HEART", 0)
    AddToParty("ONE", "BARBARIAN", 5, 0, "ATTACK_DUNGEON_HEART", 0)
	AddToParty("ONE", "ARCHER", 4, 0, "ATTACK_DUNGEON_HEART", 0)
	AddToParty("ONE", "ARCHER", 4, 0, "ATTACK_DUNGEON_HEART", 0)

    AddPartyToLevel(PLAYER_GOOD, "ONE", -3)
end


function Send_wave_final()
    ChangeSlabType(24, 8, "PATH", "NONE")
    ChangeSlabType(25, 8, "PATH", "NONE")

    CreateEffectAtPos("EFFECT_EXPLOSION_4", 75, 27.5, 3)
    CreateEffectAtPos("EFFECT_DIRT_RUBBLE_BIG", 73, 25, 8)
    CreateEffectAtPos("EFFECT_DIRT_RUBBLE_BIG", 76, 25, 8)

    CreateParty("FINAL")
    AddToParty("FINAL", "KNIGHT", 5, 3000, "ATTACK_DUNGEON_HEART", 0)
	AddToParty("FINAL", "ARCHER", 5, 0, "ATTACK_DUNGEON_HEART", 0)
	AddToParty("FINAL", "ARCHER", 5, 0, "ATTACK_DUNGEON_HEART", 0)
    AddToParty("FINAL", "MONK", 3, 0, "ATTACK_DUNGEON_HEART", 0)
    AddToParty("FINAL", "MONK", 3, 0, "ATTACK_DUNGEON_HEART", 0)

    local party = AddPartyToLevel(PLAYER_GOOD, "FINAL", -4)

    Game.lord = party[1]

    RegisterCreatureDeathEvent(function() WinGame(PLAYER0) end, Game.lord)
end