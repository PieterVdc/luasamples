-- ********************************************
--
--                  Lua Sample Rogueville
--                  by Trotim April 2025
--
-- ********************************************
-- This map showcases some randomization of terrain and what's available to the player.
-- Lua lets us do more than old level script DRAW_FROM and RANDOMIZE_FLAG could, and is easier to set up.


function OnGameStart()
	Quick_objective("You are surrounded by rooms that will continuously send heroes. Destroy them, and defeat the Lord whose harebrained idea this was.")

    Setup()
    Setup_gold_seam_spots()
    Setup_triggers()
end


function Setup()
    Set_generate_speed(400)
	
    Max_creatures(PLAYER0, 50)

    Start_money(PLAYER0, 10000)

    -- Start heroes easier than normal.
    Run_DKScript_command("SET_PLAYER_MODIFIER(PLAYER_GOOD, Health, 60)")

    Add_creature_to_pool("SPIDER", 4)
    Add_creature_to_pool("DRAGON", 4)
    Add_creature_to_pool("SORCEROR", 4)
    Add_creature_to_pool("BILE_DEMON", 4)
    Add_creature_to_pool("TROLL", 4)
    Add_creature_to_pool("ORC", 8)
    Add_creature_to_pool("MAIDEN", 4)
    Add_creature_to_pool("TENTACLE", 8)
    Add_creature_to_pool("DARK_MISTRESS", 8)
    Add_creature_to_pool("HELL_HOUND", 8)

    Creature_available("ALL_PLAYERS", "SPIDER", true, 0)
    Creature_available("ALL_PLAYERS", "DRAGON", true, 0)
    Creature_available("ALL_PLAYERS", "SORCEROR", true, 0)
    Creature_available("ALL_PLAYERS", "BILE_DEMON", true, 0)
    Creature_available("ALL_PLAYERS", "TROLL", true, 0)
    Creature_available("ALL_PLAYERS", "ORC", true, 0)
    Creature_available("ALL_PLAYERS", "MAIDEN", true, 0)
    Creature_available("ALL_PLAYERS", "TENTACLE", true, 0)
    Creature_available("ALL_PLAYERS", "DARK_MISTRESS", true, 0)
    Creature_available("ALL_PLAYERS", "HELL_HOUND", true, 0)

    -- These rooms are always available.
    Room_available("ALL_PLAYERS", "TREASURE", 2, true)
    Room_available("ALL_PLAYERS", "LAIR", 2, true)
    Room_available("ALL_PLAYERS", "GARDEN", 2, true)
    Room_available("ALL_PLAYERS", "TRAINING", 2, true)
    Room_available("ALL_PLAYERS", "RESEARCH", 2, true)
    Room_available("ALL_PLAYERS", "WORKSHOP", 2, true)
    Room_available("ALL_PLAYERS", "BRIDGE", 2, false)

    -- Pre-placed hero room types you can steal for yourself.
    Room_available("ALL_PLAYERS", "GUARD_POST", 3, false)
    Room_available("ALL_PLAYERS", "BARRACKS", 3, false)

    -- 3/5 of these rooms will be available.
    local advancedRooms = {
        "PRISON",
        "TORTURE",
        "TEMPLE",
        "GRAVEYARD",
        "SCAVENGER",
    }

    local picks = 3
    repeat
        local randomIndex = math.random(#advancedRooms)
        local room = advancedRooms[randomIndex]
        print(room)
        if room ~= nil then
            Room_available("ALL_PLAYERS", room, 2, false)
            table.remove(advancedRooms, randomIndex)
            picks = picks - 1
        end
    until picks <= 0

    -- These spells are always available.
    Magic_available("ALL_PLAYERS", "POWER_IMP", true, true)
    Magic_available("ALL_PLAYERS", "POWER_SIGHT", true, true)
    Magic_available("ALL_PLAYERS", "POWER_CALL_TO_ARMS", true, true)

    -- 8/16 of these spells will be available.
    local randomSpells = {
        "POWER_SPEED",
        "POWER_HEAL_CREATURE",
        "POWER_OBEY",
        "POWER_TIME_BOMB",
        "POWER_HOLD_AUDIENCE",
        "POWER_LIGHTNING",
        "POWER_CONCEAL",
        "POWER_PROTECT",
        "POWER_DISEASE",
        "POWER_CHICKEN",
        "POWER_CAVE_IN",
        "POWER_REBOUND",
        "POWER_FREEZE",
        "POWER_SLOW",
        "POWER_FLIGHT",
        "POWER_VISION",
    }

    picks = 8
    repeat
        local randomIndex = math.random(#randomSpells)
        local magic = randomSpells[randomIndex]
        print(magic)
        if magic ~= nil then
            Magic_available("ALL_PLAYERS", randomSpells[math.random(#randomSpells)], true, false)
            table.remove(randomSpells, randomIndex)
            picks = picks - 1
        end
    until picks <= 0

    -- 4/7 of these traps will be available.
    local randomTraps = {
        "ALARM",
        "POISON_GAS",
        "LIGHTNING",
        "LAVA",
        "BOULDER",
        "WORD_OF_POWER",
        "TNT",
    }

    picks = 4
    repeat
        local randomIndex = math.random(#randomTraps)
        local trap = randomTraps[randomIndex]
        if trap ~= nil then
            Trap_available("ALL_PLAYERS", randomTraps[math.random(#randomTraps)], true, 0)
            table.remove(randomTraps, randomIndex)
            picks = picks - 1
        end
    until picks <= 0

    -- 3/6 of these doors will be available.
    local randomDoors = {
        "WOOD",
        "BRACED",
        "STEEL",
        "MAGIC",
        "SECRET",
        "MIDAS",
    }

    picks = 3
    repeat
        local randomIndex = math.random(#randomDoors)
        local door = randomDoors[randomIndex]
        if door ~= nil then
            Door_available("ALL_PLAYERS", randomDoors[math.random(#randomDoors)], true, 0)
            randomDoors[randomIndex] = nil
            table.remove(randomDoors, randomIndex)
            picks = picks - 1
        end
    until picks <= 0
end


-- Randomly replace a bunch of eligible dirt slabs with gold.
function Setup_gold_seam_spots()
    for x = 1, 83, 1 do -- Map size width
        for y = 1, 83, 1 do -- Map size height
            if Get_slab(x, y).kind == "DIRT" then
                -- Out of around 3000 dirt slabs on this map, a 1% chance to spawn dense gold will make around 30.
                if math.random(1,100) <= 1 then
                    Place_gold_seam_dense(x, y)
                end
            end
        end
    end
end


-- Changes the chosen slab into dense gold, reveals it on the map, and spawns a bunch more gold nearby.
function Place_gold_seam_dense(slab_x, slab_y)
    Change_slab_type(slab_x, slab_y, "DENSE_GOLD", "NONE")
    Reveal_map_rect(PLAYER0, slab_x * 3 + 1, slab_y * 3 + 1, 3, 3) -- Reveal_map_rect uses subtile coordinates

    for x_offset = -1, 1, 1 do
        for y_offset = -1, 1, 1 do
            -- Each dense gold vein that has spawned can spawn more regular gold around itself.
            -- In a 3x3 block, each dirt slab has a 50% chance to become regular gold.
            if math.random(1,100) <= 50 then
                local near_x = slab_x + x_offset
                local near_y = slab_y + y_offset

                if Get_slab(near_x, near_y).kind == "DIRT" then
                    Place_gold_seam_veins(near_x, near_y)
                end
            end
        end
    end
end


-- Changes the chosen slab into regular gold, reveals it on the map, and maybe spawns a little more gold nearby.
function Place_gold_seam_veins(slab_x, slab_y)
    Change_slab_type(slab_x, slab_y, "GOLD", "NONE")
    Reveal_map_rect(PLAYER0, slab_x * 3 + 1, slab_y * 3 + 1, 3, 3) -- Reveal_map_rect uses subtile coordinates

    for x_offset = -1, 1, 1 do
        for y_offset = -1, 1, 1 do
            -- These offshoots of regular gold have a 10% chance to keep spreading.
            if math.random(1,100) <= 10 then
                local near_x = slab_x + x_offset
                local near_y = slab_y + y_offset

                if Get_slab(near_x, near_y).kind == "DIRT" then
                    Place_gold_seam_veins(near_x, near_y)
                end
            end
        end
    end
end


function Setup_triggers()
    -- Every 400 game ticks (20 seconds), spawn random heroes in random rooms.
    -- When the Lord of the Land spawns, we will save his creature in Game.lord.
    -- The Game.lord variable will no longer be nil, and the Do_hero_room_spawning action won't happen anymore.
    local spawnTimer = RegisterTimerEvent(Do_hero_room_spawning, 400, true)
    TriggerAddCondition(spawnTimer, function() return Game.lord == nil end)

    RegisterTimerEvent(Info_randomness, 300, false)
    RegisterTimerEvent(Info_gold, 600, false)
    RegisterTimerEvent(Start_hero_tunnellers, 3000, false)
    RegisterTimerEvent(Send_more_tunnellers, 12000, false)

    -- Save the amount of slabs of each room PLAYER_GOOD starts with.
    -- If that number gets smaller, we know the player has claimed or destroyed one, and can send them a message.
    Game.heroStartSlabsTreasure = PLAYER_GOOD.TREASURE
    Game.heroStartSlabsResearch = PLAYER_GOOD.RESEARCH
    Game.heroStartSlabsBarracks = PLAYER_GOOD.BARRACKS

    RegisterOnConditionEvent(Info_claiming_rooms, Claimed_hero_room)
end


function Claimed_hero_room()
    if (PLAYER_GOOD.TREASURE < Game.heroStartSlabsTreasure
        or PLAYER_GOOD.RESEARCH < Game.heroStartSlabsResearch
        or PLAYER_GOOD.BARRACKS < Game.heroStartSlabsBarracks)
        then return true
    end

    return false
end


function Info_randomness()
    Quick_information(1, "The rooms, magic, traps and doors available to you are randomized each time you play this map.")
end


function Info_gold()
    Quick_information(2, "Also randomized is the placement of the gold veins, and which heroes come from where.")
end


function Info_claiming_rooms()
    Quick_information(3, "Claiming an enemy room will stop heroes coming from there. Keep it up, or a lot of power will concentrate elsewhere...")
end


function Start_hero_tunnellers()
    Add_tunneller_to_level(PLAYER_GOOD, -1, "DUNGEON", 0, 1, 250)
    Add_tunneller_to_level(PLAYER_GOOD, -2, "ACTION_POINT", 1, 1, 250)
    Add_tunneller_to_level(PLAYER_GOOD, -3, "DUNGEON", 0, 1, 250)
end


function Send_more_tunnellers()
    Add_tunneller_to_level(PLAYER_GOOD, -1, "DUNGEON", 0, 4, 250)
    Add_tunneller_to_level(PLAYER_GOOD, -2, "DUNGEON", 0, 4, 250)
    Add_tunneller_to_level(PLAYER_GOOD, -3, "DUNGEON", 0, 4, 250)

    -- After 12000 game ticks (10 minutes), slow down how quickly new creatures enter the player's dungeon.
    -- And reset hero health back to normal (up from 60%).
    Set_generate_speed(800)
    Run_DKScript_command("SET_PLAYER_MODIFIER(PLAYER_GOOD, Health, 100)")
end


-- We'll spawn heroes on random slabs of specific kinds: Barracks, Library, and Treasure Room.
-- This helper function checks whether a given slab belongs to White and is one of those 3.
-- Otherwise, it returns false. This way, we can filter out the slabs we don't want.
function Slab_is_hero_room(slb_x, slb_y)
    if Get_slab(slb_x, slb_y).owner ~= PLAYER_GOOD then return false end
    if Get_slab(slb_x, slb_y).kind == "BARRACK_AREA" then return true end
    if Get_slab(slb_x, slb_y).kind == "BOOK_SHELVES" then return true end
    if Get_slab(slb_x, slb_y).kind == "TREASURY_AREA" then return true end
    return false
end


-- Every 400 game ticks (20 seconds), spawn random heroes in random rooms.
function Do_hero_room_spawning()
    -- Get a random Hero room slab by first making a table that stores every eligible slab.
    -- We loop through all map slabs from 1,1 to 83,83 by looping through both x and y.
    local heroRoomSlabLocations = {}
    for x = 1, 83, 1 do -- Map size width
        for y = 1, 83, 1 do -- Map size height
            if Slab_is_hero_room(x, y) then
                table.insert(heroRoomSlabLocations, {slb_x = x, slb_y = y})
            end
        end
    end

    -- If our table is not empty, we can fetch a random slab from it.
    if #heroRoomSlabLocations ~= 0 then
        local randPos = heroRoomSlabLocations[math.random(#heroRoomSlabLocations)]
        local randPosLocation = {stl_x = randPos.slb_x * 3 + 1, stl_y = randPos.slb_y * 3 + 1} -- Slab coordinates converted to subtile location format
    
        -- Some math to make Hero levels and carried gold get higher the longer the game goes on.
        -- The gold amount doesn't increase by much, hopefully forcing the player to finish the level before the heroes get out of hand.
        local heroLevel = math.floor(math.sqrt(math.random(1, PLAYER0.GAME_TURN / 1000)))
        heroLevel = math.min(heroLevel, 10)
        local heroGold = math.floor(math.random(0,200) * heroLevel / 50) * 50
        local hero = nil

        -- Different room types spawn different creatures. Slab names are from fxdata\terrain.cfg.
        local slabKind = Get_slab(randPos.slb_x, randPos.slb_y).kind

        if slabKind == "BARRACK_AREA" then
            local barracksHeroes = { "BARBARIAN", "BARBARIAN", "ARCHER", "ARCHER", "SAMURAI" } -- 2/5 chance for Barbarian, 2/5 chance for Archer, 1/5 chance for Samurai
            hero = Add_creature_to_level(PLAYER_GOOD, barracksHeroes[math.random(#barracksHeroes)], randPosLocation, heroLevel, heroGold)
        elseif slabKind == "BOOK_SHELVES" then
            local libraryHeroes = { "WIZARD", "WITCH", "MONK", "DRUID", "TIME_MAGE"}
            hero = Add_creature_to_level(PLAYER_GOOD, libraryHeroes[math.random(#libraryHeroes)], randPosLocation, heroLevel, heroGold)
        elseif slabKind == "TREASURY_AREA" then
            local treasureHeroes = { "THIEF", "DWARFA", "GIANT", "FAIRY"}
            hero = Add_creature_to_level(PLAYER_GOOD, treasureHeroes[math.random(#treasureHeroes)], randPosLocation, heroLevel, heroGold)
        end

        -- Make sure our hero spawned correctly before trying to do more things to them.
        if hero ~= nil then
            Create_effect("EFFECT_BALL_PUFF_WHITE", {hero.pos.stl_x, hero.pos.stl_y}, 2)
            Use_spell_on_creature(hero, "SPELL_ARMOUR", 1)
        end
    else
        -- Out of hero rooms as our heroRoomSlabLocations table was empty.
        -- That means they've all been claimed (or destroyed) by the player.
        Spawn_final_wave()
    end
end


function Spawn_final_wave()
    Quick_objective("Out of soldiers, Lord Coney is resorting to peasants for meat shields. End this, Keeper.")

    local heroLevel = math.ceil(math.sqrt(PLAYER0.GAME_TURN / 1000))
    heroLevel = math.min(heroLevel, 10)

    Create_party("FINAL")
    Add_to_party("FINAL", "KNIGHT", heroLevel, 5000, "ATTACK_DUNGEON_HEART", 2000)

    -- Give our Knight some randomized support.
    for i = 1, 3, 1 do
        local partyOptions = { "ARCHER", "WIZARD", "FAIRY", "WITCH", "DRUID", "TIME_MAGE"}
        local partyPick = partyOptions[math.random(#partyOptions)]
        local supportLevel = math.max(1, heroLevel - 2)
        Add_to_party("FINAL", partyPick, supportLevel, 500, "DEFEND_PARTY", 2000)
    end

    local party = Add_party_to_level(PLAYER_GOOD, "FINAL", -math.random(1,3))

    -- Save our Knight as a global variable in Game for later and so it doesn't get lost when saving and loading the game.
    -- This also turns off the repeating Do_hero_room_spawning timer as it checks for Game.lord == nil.
    Game.lord = party[1]

    RegisterTimerEvent(Spawn_lord_peasants, 200, false)
    RegisterCreatureDeathEvent(function() Win_game(PLAYER0) end, Game.lord)
end


-- Periodically make the Knight heal and spawn a Thief as a little showcase of creature specific scripting.
function Spawn_lord_peasants()
    if Game.lord:isValid() then
        Create_effect("EFFECT_BALL_PUFF_WHITE", Game.lord.pos, 2)
        Use_spell_on_creature(Game.lord, "SPELL_HEAL", 1)
        local thiefLevel = math.max(1, math.floor(Game.lord.level / 2))
        Add_creature_to_level(PLAYER_GOOD, "THIEF", Game.lord.pos, thiefLevel, 0)

        RegisterTimerEvent(Spawn_lord_peasants, 200, false)
    end
end