-- ********************************************
--
--              Lua Sample Magmadam
--              by Trotim April 2025
--
-- ********************************************
-- On this map, the player's vision is constantly reset to simulate a "fog of war" like in other RTS games.


function OnGameStart()
	Quick_objective("It's getting hard to see so deep down, Keeper. Explore the area. Use ALARM TRAPs to gain permanent vision.")
	
    My_setup()
end


function My_setup()
    Set_generate_speed(350)
	
    Max_creatures(PLAYER0, 30)

    Start_money(PLAYER0, 6000)

    Add_creature_to_pool("FLY", 2)
    Add_creature_to_pool("BUG", 8)
    Add_creature_to_pool("SPIDER", 8)
    Add_creature_to_pool("BILE_DEMON", 4)
    Add_creature_to_pool("DEMONSPAWN", 8)
    Add_creature_to_pool("SORCEROR", 8)
    Add_creature_to_pool("ORC", 8)

    Creature_available("ALL_PLAYERS", "FLY", true, 1)
    Creature_available("ALL_PLAYERS", "BUG", true, 0)
    Creature_available("ALL_PLAYERS", "SPIDER", true, 0)
    Creature_available("ALL_PLAYERS", "BILE_DEMON", true, 0)
    Creature_available("ALL_PLAYERS", "DEMONSPAWN", true, 0)
    Creature_available("ALL_PLAYERS", "SORCEROR", true, 0)
    Creature_available("ALL_PLAYERS", "ORC", true, 0)

    Room_available("ALL_PLAYERS", "TREASURE", 2, true)
    Room_available("ALL_PLAYERS", "LAIR", 2, true)
    Room_available("ALL_PLAYERS", "GARDEN", 2, true)

    Room_available("ALL_PLAYERS", "BRIDGE", 2, false)

    -- Have to find and claim these on the map.
    Room_available("ALL_PLAYERS", "TRAINING", 3, false)
    Room_available("ALL_PLAYERS", "RESEARCH", 3, false)
    Room_available("ALL_PLAYERS", "WORKSHOP", 3, false)
    Room_available("ALL_PLAYERS", "BARRACKS", 3, false)

    Magic_available("ALL_PLAYERS", "POWER_IMP", true, true)
    Magic_available("ALL_PLAYERS", "POWER_CALL_TO_ARMS", true, true)
    Magic_available("ALL_PLAYERS", "POWER_SPEED", true, false)
    Magic_available("ALL_PLAYERS", "POWER_HEAL_CREATURE", true, false)

    Door_available("ALL_PLAYERS", "WOOD", true, 0)

    Trap_available("ALL_PLAYERS", "ALARM", true, 8)

    Set_trap_configuration("ALARM","ManufactureRequired",9000)

    Create_party("STEALER")
    Add_to_party("STEALER", "THIEF", 1, 0, "STEAL_GOLD", 0)

    RegisterTimerEvent(Update_vision, 1, true)
    RegisterTimerEvent(Create_random_thieves, 1200, false)

    RegisterTimerEvent(Send_wave_one, 9000, false)
    RegisterTimerEvent(Send_wave_final, 11000, false)

    RegisterUnitDeathEvent(Drop_random_loot)
end


function Update_vision()
    Conceal_map_rect(PLAYER0, 61, 61, 122, 122, true)

    local creatures = Get_things_of_class("Creature")
    for index, creature in ipairs(creatures) do
        if creature.owner == PLAYER0 then
            Reveal_map_rect(PLAYER0, creature.pos.stl_x, creature.pos.stl_y, 21, 21)
        end
    end

    local objects = Get_things_of_class("Object")
    for index, object in ipairs(objects) do
        if object.model == "SOUL_CONTAINER" then
            Reveal_map_rect(PLAYER0, object.pos.stl_x, object.pos.stl_y, 24, 24)
        end
    end

    local traps = Get_things_of_class("Trap")
    for index, trap in ipairs(traps) do
        if trap.model == "ALARM" then
            Reveal_map_rect(PLAYER0, trap.pos.stl_x, trap.pos.stl_y, 30, 30)
        end
    end
end


function Create_random_thieves()
    local gateThief = Add_party_to_level(PLAYER_GOOD, "STEALER", -math.random(1,2))

    local spawnTimer = RegisterTimerEvent(Create_random_thieves, 900 + math.random(0, 600), false)
    TriggerAddCondition(spawnTimer, function() return Game.lord == nil end)
end


function Slab_is_walkable(slb_x, slb_y)
    if Get_slab(slb_x, slb_y).kind == "PATH" then return true end
    if Get_slab(slb_x, slb_y).kind == "PRETTY_PATH" then return true end
    if Get_slab(slb_x, slb_y).kind == "WATER" then return true end

    return false
end


function Drop_random_loot(eventData, triggerData)
    print(eventData.unit.owner)
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
    Quick_objective("I hope you're prepared, Keeper. The Lord and his lackeys are on their way.")

    Create_party("ONE")
    Add_to_party("ONE", "BARBARIAN", 6, 0, "ATTACK_DUNGEON_HEART", 0)
    Add_to_party("ONE", "BARBARIAN", 5, 0, "ATTACK_DUNGEON_HEART", 0)
	Add_to_party("ONE", "ARCHER", 4, 0, "ATTACK_DUNGEON_HEART", 0)
	Add_to_party("ONE", "ARCHER", 4, 0, "ATTACK_DUNGEON_HEART", 0)

    Add_party_to_level(PLAYER_GOOD, "ONE", -3)
end


function Send_wave_final()
    Change_slab_type(24, 8, "PATH", "NONE")
    Change_slab_type(25, 8, "PATH", "NONE")

    Create_effect_at_pos("EFFECT_EXPLOSION_4", 75, 27.5, 3)
    Create_effect_at_pos("EFFECT_DIRT_RUBBLE_BIG", 73, 25, 8)
    Create_effect_at_pos("EFFECT_DIRT_RUBBLE_BIG", 76, 25, 8)

    Create_party("FINAL")
    Add_to_party("FINAL", "KNIGHT", 5, 3000, "ATTACK_DUNGEON_HEART", 0)
	Add_to_party("FINAL", "ARCHER", 5, 0, "ATTACK_DUNGEON_HEART", 0)
	Add_to_party("FINAL", "ARCHER", 5, 0, "ATTACK_DUNGEON_HEART", 0)
    Add_to_party("FINAL", "MONK", 3, 0, "ATTACK_DUNGEON_HEART", 0)
    Add_to_party("FINAL", "MONK", 3, 0, "ATTACK_DUNGEON_HEART", 0)

    local party = Add_party_to_level(PLAYER_GOOD, "FINAL", -4)

    Game.lord = party[1]

    RegisterUnitDeathEvent(function() Win_game(PLAYER0) end, Game.lord)
end