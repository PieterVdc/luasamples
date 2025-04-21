local function initLevel()
	Set_generate_speed(300)
	Start_money(PLAYER0,7000)
	Max_creatures(PLAYER0,30)

	Add_creature_to_pool("FLY",2)
	Add_creature_to_pool("BUG",2)
	Add_creature_to_pool("DEMONSPAWN",4)
	Add_creature_to_pool("TROLL",4)
	Add_creature_to_pool("SPIDER",4)
	Add_creature_to_pool("HELL_HOUND",2)
	Add_creature_to_pool("TENTACLE",4)
	Add_creature_to_pool("SORCEROR",4)
	Add_creature_to_pool("ORC",4)
	Add_creature_to_pool("DARK_MISTRESS",4)
	Add_creature_to_pool("GIANT",4)

	Creature_available(PLAYER0,"FLY",true,0)
	Creature_available(PLAYER0,"BUG",true,0)
	Creature_available(PLAYER0,"DEMONSPAWN",true,0)
	Creature_available(PLAYER0,"TROLL",true,0)
	Creature_available(PLAYER0,"SPIDER",true,0)
	Creature_available(PLAYER0,"HELL_HOUND",true,0)
	Creature_available(PLAYER0,"TENTACLE",true,0)
	Creature_available(PLAYER0,"SORCEROR",true,0)
	Creature_available(PLAYER0,"ORC",true,0)
	Creature_available(PLAYER0,"DARK_MISTRESS",true,0)
	Creature_available(PLAYER0,"GIANT",true,0)

	Room_available(PLAYER0,"TREASURE",1,true)
	Room_available(PLAYER0,"LAIR",1,true)
	Room_available(PLAYER0,"GARDEN",1,true)
	Room_available(PLAYER0,"TRAINING",1,false)
	Room_available(PLAYER0,"RESEARCH",1,false)
	Room_available(PLAYER0,"BRIDGE",1,false)
	Room_available(PLAYER0,"WORKSHOP",1,false)
	Room_available(PLAYER0,"PRISON",1,false)
	Room_available(PLAYER0,"TORTURE",1,false)
	Room_available(PLAYER0,"BARRACKS",1,false)
	Room_available(PLAYER0,"TEMPLE",1,false)
	Room_available(PLAYER0,"GRAVEYARD",1,false)
	Room_available(PLAYER0,1,false)

	Magic_available(PLAYER0,"POWER_HAND",true,true)
	Magic_available(PLAYER0,"POWER_SLAP",true,true)
	Magic_available(PLAYER0,"POWER_POSSESS",true,true)
	Magic_available(PLAYER0,"POWER_IMP",true,true)
	Magic_available(PLAYER0,"POWER_SIGHT",true,false)
	Magic_available(PLAYER0,"POWER_SPEED",true,false)
	Magic_available(PLAYER0,"POWER_OBEY",true,false)
	Magic_available(PLAYER0,"POWER_CALL_TO_ARMS",true,false)
	Magic_available(PLAYER0,"POWER_CONCEAL",true,false)
	Magic_available(PLAYER0,"POWER_HOLD_AUDIENCE",true,false)
	Magic_available(PLAYER0,"POWER_HEAL_CREATURE",true,false)
	Magic_available(PLAYER0,"POWER_LIGHTNING",true,false)
	Magic_available(PLAYER0,"POWER_PROTECT",true,false)

	Trap_available(PLAYER0,"ALARM",true,0)
	Trap_available(PLAYER0,"POISON_GAS",true,0)
	Trap_available(PLAYER0,"LIGHTNING",true,0)
	Trap_available(PLAYER0,"BOULDER",true,0)
	Trap_available(PLAYER0,"WORD_OF_POWER",true,0)

	Door_available(PLAYER0,"BRACED",true,0)
	Door_available(PLAYER0,"STEEL",true,0)
	Door_available(PLAYER0,"MAGIC",true,0)
	
	Create_party("DIGGER")
		Add_to_party("DIGGER","THIEF",1,500,"ATTACK_ENEMIES",0)

	Game.wavenumber = 0
end


function partySpawn()
	-- limit Game.wavenumber between 1 and 10
	Game.wavenumber = math.max(Game.wavenumber, 1)
	Game.wavenumber = math.min(Game.wavenumber, 10)
	
	-- set up 2 random options for each party, picked from this table
	local partyoptions = {"THIEF", "ARCHER", "DWARFA", "WIZARD", "BARBARIAN", "MONK", "FAIRY", "GIANT", "SAMURAI", "WITCH", "DRUID", "TIME_MAGE"}
	local partytype1 = partyoptions[math.random(#partyoptions)]
	local partytype2 = partyoptions[math.random(#partyoptions)]
	local partytypes = {partytype1, partytype1, partytype2} -- deliberately weighted pick so that type1 shows up 66% of the time, type2 33%
	
	-- initialize party with at least 1 of each type
	local partyname = "PARTY" .. Game.wavenumber
	Create_party(partyname)
		Add_to_party(partyname,partytype1,Game.wavenumber,500,"ATTACK_ENEMIES",0)
		Add_to_party(partyname,partytype2,Game.wavenumber,500,"ATTACK_ENEMIES",0)
	
	-- add some more based on how long we've been playing
	local partyamount = Game.wavenumber + math.floor(PLAYER0.game_turn / 2000)
	partyamount = math.min(partyamount, 30)
	for i=1,partyamount do
		local partypick = partytypes[math.random(#partytypes)]
		local randomlevel = math.random(Game.wavenumber/2,Game.wavenumber)
		Add_to_party(partyname,partypick,randomlevel,randomlevel*200,"ATTACK_ENEMIES",0)
	end
	
	Quick_message("My " .. partytype1 .. " & " .. partytype2 .. " are coming! (Wave " .. Game.wavenumber .. ")", PLAYER_GOOD)
	
	-- Add_party_to_level kept giving me wrong argument errors idk
	Add_tunneller_party_to_level(PLAYER_GOOD,partyname,-1,"DUNGEON",0,Game.wavenumber,500)
	
	Game.wavenumber = Game.wavenumber + 1
end

function diggerSpawn()
	Add_tunneller_party_to_level(PLAYER_GOOD,"DIGGER",-1,"DUNGEON_HEART",0,1,500)
end

-- This function runs as soon as the level begins
function OnGameStart()
    initLevel()
	-- spawn small tunneller party after 3000 turns. only once
	RegisterTimerEvent(diggerSpawn,3000,false)
	
	-- keep spawning randomly generated parties every 4800 turns. loops
	local party_spawn_timer = RegisterTimerEvent(partySpawn,4800,true)
		TriggerAddCondition(party_spawn_timer, function() return (Game.wavenumber < 10) end) -- only up to wave 10
		
	-- win when wave 10 has spawned and no more heroes are on the map
	RegisterOnConditionEvent(function() Win_game(PLAYER0) end,
							 function() return (PLAYER_GOOD.TOTAL_CREATURES <= 0) and (Game.wavenumber >= 0) end)

end
