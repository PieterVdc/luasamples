-- ********************************************
--
--              Lua Sample Magmadam
--              by Trotim April 2025
--
-- ********************************************
-- On this map, digging certain gold slabs triggers lava to flood the map, turning dirt slabs and wall slabs into lava slabs.
-- It will create explosion effects and kill nearby enemy Heroes as it travels.
-- Slab manipulation via Lua script can be much more advanced than regular Dungeon Keeper level script.


function OnGameStart()
	Quick_objective_with_pos("A single seam of gold is holding back this pool of lava. Dig it up, Keeper.", 55, 73)
	
    My_setup()
end


function My_setup()
    Set_generate_speed(200)
	
    Max_creatures(PLAYER0, 15)

    Start_money(PLAYER0, 10000)

    Add_creature_to_pool("FLY", 1)
    Add_creature_to_pool("DEMONSPAWN", 8)
    Add_creature_to_pool("HELL_HOUND", 8)

    Creature_available("ALL_PLAYERS", "FLY", true, 1)
    Creature_available("ALL_PLAYERS", "DEMONSPAWN", true, 0)
    Creature_available("ALL_PLAYERS", "HELL_HOUND", true, 1)

    Room_available("ALL_PLAYERS", "TREASURE", 2, true)
    Room_available("ALL_PLAYERS", "LAIR", 2, true)
    Room_available("ALL_PLAYERS", "GARDEN", 2, true)
    Room_available("ALL_PLAYERS", "TRAINING", 2, true)

    Room_available("ALL_PLAYERS", "BRIDGE", 2, false)

    Magic_available("ALL_PLAYERS", "POWER_IMP", true, true)
    Magic_available("ALL_PLAYERS", "POWER_SIGHT", true, true)
    Magic_available("ALL_PLAYERS", "POWER_CALL_TO_ARMS", true, true)
    Magic_available("ALL_PLAYERS", "POWER_SPEED", true, true)

    -- This sets the Hell Hound attraction requirement (Scavenger Room) to NULL i.e. none.
    -- They will always come through the Entrance to our dungeon.
    Run_DKScript_command("SET_CREATURE_CONFIGURATION(HELL_HOUND, EntranceRoom, NULL)")

    Create_heart_trigger()
    Create_lava_triggers()
end


function Create_heart_trigger()
    -- Simple trigger to end the game and spawn pretty effects when the White Dungeon Heart is destroyed.
    RegisterOnConditionEvent(Heart_destroyed, function() return PLAYER_GOOD.DUNGEON_DESTROYED >= 1 end)
end


-- Let's make the explosion of the Dungeon Heart more spectacular.
function Heart_destroyed()
    -- First, a list of all the positions near the Dungeon Heart we want to create extra effects on:
    local heartEffectPositions = {
        {94,22},
        {95,20},
        {97,19},
        {99,20},
        {100,22},
        {99,24},
        {97,25},
        {95,24}
    }
    -- This will create a nice circle around where the Heart used to be.
    -- These coordinates are in SUBTILES.
    -- Dungeon Keeper maps are made up of slabs, and each slab is split further into 3x3 subtiles.

    -- Our Heart is at 32,7 in x,y. The slab at 32,7 contains the subtiles
    --      96,21    97,21   98,21
    --      96,22    97,22   98,22
    --      96,23    97,23   98,23

    -- Converting slab coordinates into subtile coordinates is as easy as multiplying by 3.
    -- Just add 1 if you want to stay in the center subtile, otherwise you'll get the top left.
    -- The Heart at slab 32,7 also occupies the subtile 97,22.
    
    -- Now, let's loop through the heartEffectPositions and create an effect on each.
    for index, value in ipairs(heartEffectPositions) do
        Create_effect_at_pos("EFFECT_COLOURFUL_FIRE_CIRCLE", value[1], value[2], 2)
    end
    -- As the Lua ipairs function goes down the list, it will run its functions once for each entry.
    -- index will start at 1 and increase by 1 each time.
    -- value will start at our first entry and go down 1 each time. It is the same as heartEffectPositions[index].
    -- That means on the first run of this for loop, value is {94,22}.
    -- The second run, value is {95,20}. Third is {97,19}, then {99,20}, and so on.
    -- value[1] will get the first number, our x coordinate, and value[2] the second one, our y coordinate.

    Win_game(PLAYER0)
end


-- A little helper function to make the slab coordinate to subtile coordinate conversion easy.
-- We'll use it in the big Lava_spread function later.
-- It can be given a parameter so you will return different results based on what you give it.
function Slab_to_subtile(slabPosition)
    return slabPosition * 3 + 1
end


-- These 3 triggers will activate as soon as the slab we're checking changes to anything but its starting kind (type).
-- i.e. Lava_unleashed checks whether the slab on x 18 and y 24 is not Gold anymore.
function Create_lava_triggers()

    RegisterOnConditionEvent(Lava_unleashed, function() return (Get_slab(18, 24).kind ~= "GOLD") end)
    RegisterOnConditionEvent(Lava_unleashed_2, function() return (Get_slab(18, 20).kind ~= "GOLD") end)
    RegisterOnConditionEvent(Lava_unleashed_3, function() return (Get_slab(31, 35).kind ~= "DENSE_GOLD") end)

    -- Other slab variables we could access are slab.owner, slab.revealed, and slab.style (texture).
end


-- Lava spread to start when the first gold slab is dug out.
function Lava_unleashed()
    -- We save some coordinates for our Lava_spread function to use.
    Game.lavaPosition = {slb_x = 18, slb_y = 24}
    RegisterTimerEvent(function() Lava_spread(Game.lavaPosition) end, 10, false)
end


-- Lava spread to start when player reached the last slab of the first gold vein.
function Lava_unleashed_2()
    Game.lavaPosition2 = {slb_x = 18, slb_y = 20}
    RegisterTimerEvent(function() Lava_spread(Game.lavaPosition2) end, 10, false)
    -- When the flow of lava has nearly finished, give Bridge so the player can go win the level.
    RegisterTimerEvent(Give_bridge, 300, false)
end


function Give_bridge()
    Quick_objective_with_pos("Destroy the Heroes' Dungeon Heart for a colorful explosion!", 97, 22)
    Room_available("ALL_PLAYERS", "BRIDGE", 2, true)
    Tutorial_flash_button(18, 0)
    Add_heart_health("PLAYER_GOOD", -29000, false)
end


-- Optional lava spread near the bottom of the level leading to Gems.
function Lava_unleashed_3()
    Game.lavaPosition3 = {slb_x = 31, slb_y = 35}
    RegisterTimerEvent(function() Lava_spread(Game.lavaPosition3) end, 10, false)
end


-- Big function that takes care of the actual lava spreading behavior.
-- We take fromSlabPosition, which is a x,y coordinate.
-- We then nest 2 for loops.
--
-- First, we have an outer loop of x_offset. x_offset will shift x by -1, 0, and 1.
-- That way, we get fromSlabPosition.x - 1, fromSlabPosition.x, and fromSlabPosition + 1.
-- We check the slab to the left, our starting slab, and the slab to the right.
--
-- Then the inner loop for y_offset. Again it will shift y by -1, 0, and 1.
-- When we're doing the slab to the left, we will also do the slab above and below the slab to the left.
-- When we're doing the starting slab, we will also do the slab above and below the starting slab.
-- And when we're doing the slab to the right, we will also do the slab above and below the slab to the right.
--
-- It's a 3x3 square with our starting fromSlabPosition in the middle.
function Lava_spread(fromSlabPosition)
    for x_offset = -1, 1, 1 do
        for y_offset = -1, 1, 1 do
            local lava_x = fromSlabPosition.slb_x + x_offset
            local lava_y = fromSlabPosition.slb_y + y_offset
            
            -- If we come across a slab we want to turn into lava, we turn it into lava, create some effects,
            -- and reveal the turned slab to the player so they can see what's happening.
            if Lava_can_spread_to_slab_type(lava_x, lava_y) then
                Change_slab_type(lava_x, lava_y, "LAVA", "NONE")
                Create_effect_at_pos("EFFECT_EXPLOSION_4", Slab_to_subtile(lava_x), Slab_to_subtile(lava_y), 1)
                Create_effect_at_pos("EFFECT_DIRT_RUBBLE_BIG", Slab_to_subtile(lava_x), Slab_to_subtile(lava_y), 5)
                Reveal_map_rect(PLAYER0, Slab_to_subtile(lava_x), Slab_to_subtile(lava_y), 5, 5)
                
                -- Another ipairs loop, this time going over all creatures on the map.
                -- If the creature is within 5 subtiles of our flowing lava, and belong to White, kill them.
                local creatures = Get_things_of_class("Creature")
    
                for index, creature in ipairs(creatures) do
                    local distance = Get_distance(creature.pos.stl_x, creature.pos.stl_y, Slab_to_subtile(lava_x), Slab_to_subtile(lava_y))
                    if distance <= 5 and creature.owner == PLAYER_GOOD then
                        creature:Kill_creature()
                    end
                end
                
                -- If we successfully turned a slab into lava, repeat!
                -- We call Lava_spread again in 10 game ticks starting on the newly formed lava slab.
                -- It will keep going until it ends up in a spot where no slab can turn into lava.
                RegisterTimerEvent(function() Lava_spread({slb_x = lava_x, slb_y = lava_y}) end, 10, false)
            end
        end
    end
end


-- Lava is only allowed to turn specific slab kinds into lava.
-- We reject everything else by only returning true when the kind matches one we want.
function Lava_can_spread_to_slab_type(slab_x, slab_y)
    if Get_slab(slab_x, slab_y).kind == "DIRT" then return true end
    if Get_slab(slab_x, slab_y).kind == "TORCH_DIRT" then return true end
    if Get_slab(slab_x, slab_y).kind == "DRAPE_WALL" then return true end
    if Get_slab(slab_x, slab_y).kind == "TORCH_WALL" then return true end
    if Get_slab(slab_x, slab_y).kind == "TWINS_WALL" then return true end
    if Get_slab(slab_x, slab_y).kind == "WOMAN_WALL" then return true end
    if Get_slab(slab_x, slab_y).kind == "PAIR_WALL" then return true end

    return false
end


-- Little helper function to check how far away a creature is from the flowing lava.
-- Thanks Pythagoras!
function Get_distance(x1, y1, x2, y2)
    local x, y = x1-x2, y1-y2
    return math.sqrt(x*x+y*y)
end
