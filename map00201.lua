-- ********************************************
--
--           Lua Basics and Triggers
--           by Trotim Apr 2025
--
-- ********************************************
-- Fully commented simple example map using only Lua instead of old DK level script.


-- OnGameStart() is a built-in function.
-- It happens when the level has finished loading and the map is about to start.
function OnGameStart()
	-- For example, showing the initial objective text to the player as soon as they enter their Dungeon Heart.
	Quick_objective("Lord von Lua rules over this meagre realm. Head NORTH and make short work of him.", PLAYER_GOOD)
	
	-- My_setup() is our own function we made ourselves. You'll find it right below this one.
	-- Since it's run by the OnGameStart() function, everything we define in My_setup() will also happen when the game starts.
    My_setup()
end


function My_setup()
	-- The following should all be very familiar if you've seen Dungeon Keeper level scripts before.
	-- We set how long it takes for creatures to come out of Entrance portals.
    -- 350 game ticks is 17.5 seconds. Each real time second has 20 game ticks.
    Set_generate_speed(350)
	
	-- ...set the maximum amount of creatures Player0 can have.
    -- Player0 is Red. Player1 Blue, Player2 Green, Player3 Yellow.
    -- There's also PLAYER_GOOD (White, for Heroes) and PLAYER_NEUTRAL (rainbow).
    -- KeeperFX additionally adds Player4 (Purple), Player5 (Black), Player6 (Orange).
    Max_creatures(PLAYER0, 16)

    -- Set the amount of gold at the start of the level.
    Start_money(PLAYER0, 16000)

    -- Add creatures to the total creature pool that can be attracted by all Keepers.
    Add_creature_to_pool("FLY", 1)
    Add_creature_to_pool("SORCEROR", 4)
    Add_creature_to_pool("BUG", 2)
    Add_creature_to_pool("DEMONSPAWN", 4)
    Add_creature_to_pool("BILE_DEMON", 1)
    Add_creature_to_pool("TROLL", 4)

    -- Then, make those creatures actually available on a per player basis.
    Creature_available("ALL_PLAYERS", "FLY", true, 0)
    Creature_available("ALL_PLAYERS", "BUG", true, 0)
    Creature_available("ALL_PLAYERS", "SORCEROR", true, 0)
    Creature_available("ALL_PLAYERS", "DEMONSPAWN", true, 0)
    Creature_available("ALL_PLAYERS", "BILE_DEMON", true, 0)
    Creature_available("ALL_PLAYERS", "TROLL", true, 0)

    -- We have all these rooms available from the start.
    Room_available("ALL_PLAYERS", "TREASURE", 2, true)
    Room_available("ALL_PLAYERS", "LAIR", 2, true)
    Room_available("ALL_PLAYERS", "GARDEN", 2, true)
    Room_available("ALL_PLAYERS", "TRAINING", 2, true)
    Room_available("ALL_PLAYERS", "RESEARCH", 2, true)
    Room_available("ALL_PLAYERS", "WORKSHOP", 2, true)

    -- The Bridge is set to false and won't be available right away.
    -- With can_be_available set to 2, it will be available when researched or claimed.
    Room_available("ALL_PLAYERS", "BRIDGE", 2, false)

    -- The Guard Post can't be researched, but will become available when claimed on the map.
    Room_available("ALL_PLAYERS", "GUARD_POST", 3, false)

    -- Here's all the Keeper spells. Imp, Sight, and Call to Arms are available from the start.
    -- Speed and Heal can be researched.
    Magic_available("ALL_PLAYERS", "POWER_IMP", true, true)
    Magic_available("ALL_PLAYERS", "POWER_SIGHT", true, true)
    Magic_available("ALL_PLAYERS", "POWER_CALL_TO_ARMS", true, true)
    Magic_available("ALL_PLAYERS", "POWER_SPEED", true, false)
    Magic_available("ALL_PLAYERS", "POWER_HEAL_CREATURE", true, false)

    -- Make some traps available since we enabled the Workshop earlier.
    Trap_available("ALL_PLAYERS", "POISON_GAS", true, 0)
    Trap_available("ALL_PLAYERS", "LIGHTNING", true, 0)

    -- And the Wooden Door.
    Door_available("ALL_PLAYERS", "WOOD", true, 0)

	-- Run_DKScript_command can be useful in case a Lua equivalent is not (yet) available.
	-- We'll spawn a lone Knight as the final fight of the level.
    -- Let's give Knights more health to make the Lord of the Land more fearsome.
    -- A Knight's normal HP is 950 at level 1. Raising it to 1500 sounds good.
    Run_DKScript_command("SET_CREATURE_CONFIGURATION(KNIGHT, Health, 1500)")

	-- We'll spawn some hero waves. Let's make a custom variable that will keep track of how many we have sent.
    -- By making it part of Game, it will be saved when the player saves the game.
    -- We can use variables we assign to Game for the rest of the level. It will stay around.
	Game.waveNumber = 1

	-- We will write the following functions ourselves. You can find them right below this block.
    My_hero_parties()
    My_create_triggers()
end


-- For organization purposes, we can split scripts into multiple functions.
-- These lines could also be in My_setup() but it can be nice to have discrete blocks of script for different things.
-- Here, we define some hero parties to spawn later.
function My_hero_parties()
    -- The "Scouts" party will have 2 Thieves of level 1 with 500 gold, and 1 Archer of level 1 with 250 gold.
    Create_party("Scouts")
    Add_to_party("Scouts", "THIEF", 1, 500, "ATTACK_DUNGEON_HEART", 0)
	Add_to_party("Scouts", "THIEF", 1, 500, "ATTACK_DUNGEON_HEART", 0)
	Add_to_party("Scouts", "ARCHER", 1, 250, "ATTACK_DUNGEON_HEART", 0)

    -- The "Landlord" party will have just the 1 Knight of level 3 with 0 gold.
    -- This party will wait an extra 1000 game ticks (50 seconds) before attacking.
    Create_party("Landlord")
    Add_to_party("Landlord", "KNIGHT", 3, 0, "ATTACK_DUNGEON_HEART", 1000)
end


-- Let's set up some triggers.
-- When a specific EVENT happens, an ACTION will happen.
function My_create_triggers()
    -- One type of event is an action point event.
    -- Here, when the player reaches action point 1, our function Found_hero_heart will run.
    -- This works like IF_ACTION_POINT in old level script.
    RegisterOnActionPointEvent(Found_hero_heart, 1, PLAYER0)

    -- We can also create a trigger that will fire when a time has been reached.
    -- This will run our own custom function Start_waves when 6000 game ticks (5 minutes) have passed.
    -- Since the last argument is "false", the timer event will only happen once at 6000 ticks and never again.
    -- If it were "true", the timer would loop, happening at 6000, 12000, 18000, etc.
    RegisterTimerEvent(Start_waves, 6000, false)

    -- Triggers can also have CONDITIONS.
    -- The ACTION will only happen if the CONDITION is true.
    -- Here, we wait until the player's total creature count is greater than 4.
    -- Then, we spawn a tunneller party from Hero Gate 1.
    -- Our Spawn_tunneller function that does so can be found below.
    RegisterOnConditionEvent(Spawn_tunneller, function() return (PLAYER0.TOTAL_CREATURES > 4) end)

    -- Players hold a lot of information. It can be accessed via PLAYER0.(name of variable).
    -- PLAYER0.MONEY, PLAYER0.CREATURES_SACRIFICED, PLAYER0.SKELETONS_RAISED, PLAYER0.SAMURAI...

    -- Another Trigger example.
    -- Here we define: if the Hero Dungeon Heart is destroyed, win the game.
    -- Above, we put our condition inside a "function() ... end" block to quickly define a short function.
    -- That's the same way our big function blocks are set up, just in one line rather than a separate text block.
    -- We do that with both our condition and action here as both are simple.
    RegisterOnConditionEvent(function() Win_game(PLAYER0) end, function() return (PLAYER_GOOD.DUNGEON_DESTROYED >= 1) end)
end


function Spawn_tunneller()
    -- Spawn a Hero party consisting of the "Scouts" party we defined in My_hero_parties()
    -- at -1, that is Hero Gate 1,
    -- going for the dungeon of player 0 (red),
    -- led by a level 1 tunneller that carries 250 gold.
    Add_tunneller_party_to_level(PLAYER_GOOD,"Scouts",-1,"DUNGEON",0,1,250)

    -- Let's warn the player.
    -- Use message slot 1 to send the player a glowing green i message that says the following:
    Quick_information(1,"There are Heroes nearby, Keeper...")
end


-- Above in My_create_triggers() we set up a timer that runs Start_waves after 6000 game ticks.
function Start_waves()
    -- Create a new timer.
	-- Every 4000 ticks (200 seconds), our own custom function Spawn_hero_wave will happen.
	-- Since the 3rd argument is "true", the timer event will happen over and over, at 4000, 8000, 12000...
    local spawnWaveTimer = RegisterTimerEvent(Spawn_hero_wave, 4000, true)

    -- This time, we assigned it the local variable SpawnWaveTimer.
    -- That lets us do additional things to the timer we just set up.
    -- When this function block ends, the local variable will go away. It is not saved.
    -- That's fine because we only need it for the next line. We don't need to refer to it again elsewhere later.

	-- Adding conditions to triggers lets us limit whether or not they will run.
	-- When the SpawnWaveTimer event happens, but one of its conditions is not met, it won't run its action (Spawn_hero_wave).
    -- Our Hero waves will keep spawning as long as the White Dungeon Heart has not been destroyed.
    TriggerAddCondition(spawnWaveTimer, function() return (PLAYER_GOOD.DUNGEON_DESTROYED < 1) end)
end


-- Found_hero_heart is the action of the first trigger we set up in My_create_triggers().
-- Check again above to see what makes it happen.
function Found_hero_heart()
    Quick_objective("Lord von Lua has arrived! Defeat him and destroy the Dungeon Heart!", PLAYER_GOOD)

    -- We add the "Landlord" hero party to the level.
    -- By assigning it to a variable, we can keep track of the party and the creatures in it, and do things to them.
    local knightParty = Add_party_to_level(PLAYER_GOOD, "Landlord", -3)

    -- The first (and only) member of our "Landlord" party is our Knight.
    -- By saving him to a variable, we can do additional things to him, and keep track of his status.
    -- We make this one a Game variable so it gets saved for later use.
    -- knightParty can be local since we only needed it to grab our Knight creature. We don't need to do anything else to the party later.
    -- If there was more than 1 creature in the party, they'd be saved as knightParty[2], knightParty[3], etc.
    Game.finalKnight = knightParty[1]

    -- We can cast spells on him. Spell names can be found in your KeeperFX folder /fxdata/magic.cfg.
    Use_spell_on_creature(Game.finalKnight,"SPELL_FLIGHT",0)
    Use_spell_on_creature(Game.finalKnight,"SPELL_ARMOUR",0)

    -- And create a new trigger.
    -- Its event will happen when he specifically dies and run our custom function Killed_final_knight.
    RegisterCreatureDeathEvent(Killed_final_knight, Game.finalKnight)
end


-- When Game.finalKnight dies, let's do something at his location.
-- Turns out he was a Vampire in disguise all along!
function Killed_final_knight()
    -- We can make the zoom eye button of the objective message go to exactly where he died.
    Quick_objective_with_pos("Lord von Lua was a Vampire all along! Make him pay for his treachery!", Game.finalKnight.pos.stl_x, Game.finalKnight.pos.stl_y)

    -- We can quickly set up a new party and add it to the level where the Knight died.
    Create_party("Final")
    Add_to_party("Final", "VAMPIRE", 3, 5000, "ATTACK_DUNGEON_HEART", 1000)
    local finalParty = Add_party_to_level(PLAYER_GOOD, "Final", Game.finalKnight.pos)

    -- Save the new Vampire to a variable and add a new trigger to fire when the Vampire dies.
    Game.finalVampire = finalParty[1]
    RegisterCreatureDeathEvent(Killed_final_vampire, Game.finalVampire)

    -- At this point we will have been fighting him for a while.
    -- By setting the Vampire's health to 0.5 times his max health, Lord von Lua will appear wounded.
    Game.finalVampire.health = Game.finalVampire.max_health * 0.5

    -- We want to make it look like the Knight has turned into a Vampire.
    -- But right now, the Knight would still play his full death animation. We just spawn a Vampire on top.
    -- We can remove the Knight entirely to stop the animation and leave no corpse.
    -- Luckily, we still have him saved as a variable!
    Game.finalKnight:delete_thing()
end


function Killed_final_vampire()
    Quick_objective("Lord von Lua lies before you, bloodied and beaten. Enjoy your victory, Keeper.", PLAYER_GOOD)

    -- Destroy the White Dungeon Heart to save some time.
    -- Internally called SOUL_CONTAINER, hearts have 30000 HP by default.
    Add_heart_health("PLAYER_GOOD", -30000, false)
end


-- We will spawn hero waves from Hero Gate 1 (in the south east corner) every 4000 ticks (200 seconds).
-- Let's generate a party of random creatures, and scale the party's size based on how many creatures the player has.
function Spawn_hero_wave()
	-- First, get how many creatures the player has...
    local partySize = PLAYER0.TOTAL_CREATURES
	-- ... and divide by 2. If the player has 12 creatures, we will send 6 heroes.
	partySize = partySize / 2
	-- ...but let's never make it more than 7. Lua's math library has math.min, which returns the smaller of the 2 numbers.
	partySize = math.min(partySize, 7)
	
	-- Next, make a list of creature types we want to pick from.
	local partyOptions = {"THIEF", "ARCHER", "DWARFA", "MONK", "BARBARIAN", "GIANT"}
	
	-- We give each hero party we generate a unique name.
    -- In Lua, the .. adds multiple different text variables (strings) together.
    -- We defined a custom variable Game.waveNumber all the way back in My_setup().
    -- If our custom variable Game.waveNumber is 1, we will create PARTY1. If it is 7, we will create PARTY7.
    local partyName = "PARTY" .. Game.waveNumber
	Create_party(partyName)
	
	-- Using a for loop, we can repeat script commands.
	-- Our temporary variable i will go from 1 up to partySize. If partySize is 8, i will be 1, 2, 3, 4, 5, 6, 7, 8.
	-- Each time, it will execute all of the commands in the loop.
	-- It is finished when we have added partySize number of creatures to our party.
	for i=1, partySize do
		-- First, pick a random creature type from the list we defined earlier.
		local partyPick = partyOptions[math.random(#partyOptions)]

		-- The # gives us the length of the list. How many things are in it? In this case 6.
		-- By asking for math.random(#partyOptions), we will get a number between 1 and 6.
        -- If we ask for partyOptions[1], we will get "THIEF". partyOptions[2] is "ARCHER". And so on.
		
		-- Finally, we add a creature of type partyPick to our party named partyName.
		-- It will be level 1, hold 200 gold, and go "ATTACK_ENEMIES" after a delay of 0 ticks.
		Add_to_party(partyName,partyPick,1,200,"ATTACK_ENEMIES",0)
	end
	
	-- Now that the party is generated, let's put it on the map!
    -- We'll make them appear at either Hero Gate 1 or 2.
    -- Note the minus in front of math.random. For Add_tunneller_party_to_level, Hero Gate IDs are negative numbers.
    -- (Action Point IDs are positive numbers.)
    local randomGate = -math.random(1, 2)

	-- We spawn a tunneller party for the Hero player at Hero gate randomGate that goes to player 0's dungeon.
	-- The tunneller's level will be equal to Game.waveNumber so we can see how many waves we've sent.
    -- Note the -randomGate (since positive IDs are Action Points, and negative IDs are Hero Gates).
	Add_tunneller_party_to_level(PLAYER_GOOD,partyName,randomGate,"DUNGEON",0,Game.waveNumber,500)

    -- Let's warn the player about this.
    -- We can assign text to a variable and have the displayed message be different.
    -- If we picked gate 1, let's call it south east. Gate 2 is north west.
    local gateLocationText = ""
    if randomGate == -1 then
        gateLocationText = "south east"
    else
        gateLocationText = "north west"
    end
    
    -- By using .. we can add these pieces of text together.
    Quick_information(2,"Another band of naive heroes is attacking from " .. gateLocationText .. "!", randomGate)
    -- The information message's eye button will zoom to randomGate - the number we selected earlier.
    -- That will be the same number Add_tunneller_party_to_level used above.

    -- We sent a hero wave so let's increase our waveNumber variable by 1.
	-- If we just sent PARTY1, the next will be PARTY2, then PARTY3, and so on.
	Game.waveNumber = Game.waveNumber + 1
end