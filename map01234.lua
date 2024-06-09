local function initLevel()
	SET_GENERATE_SPEED(300)
	START_MONEY(PLAYER0,7000)
	MAX_CREATURES(PLAYER0,30)

	ADD_CREATURE_TO_POOL("FLY",2)
	ADD_CREATURE_TO_POOL("BUG",2)
	ADD_CREATURE_TO_POOL("DEMONSPAWN",4)
	ADD_CREATURE_TO_POOL("TROLL",4)
	ADD_CREATURE_TO_POOL("SPIDER",4)
	ADD_CREATURE_TO_POOL("HELL_HOUND",2)
	ADD_CREATURE_TO_POOL("TENTACLE",4)
	ADD_CREATURE_TO_POOL("SORCEROR",4)
	ADD_CREATURE_TO_POOL("ORC",4)
	ADD_CREATURE_TO_POOL("DARK_MISTRESS",4)
	ADD_CREATURE_TO_POOL("GIANT",4)

	CREATURE_AVAILABLE(PLAYER0,"FLY",true,0)
	CREATURE_AVAILABLE(PLAYER0,"BUG",true,0)
	CREATURE_AVAILABLE(PLAYER0,"DEMONSPAWN",true,0)
	CREATURE_AVAILABLE(PLAYER0,"TROLL",true,0)
	CREATURE_AVAILABLE(PLAYER0,"SPIDER",true,0)
	CREATURE_AVAILABLE(PLAYER0,"HELL_HOUND",true,0)
	CREATURE_AVAILABLE(PLAYER0,"TENTACLE",true,0)
	CREATURE_AVAILABLE(PLAYER0,"SORCEROR",true,0)
	CREATURE_AVAILABLE(PLAYER0,"ORC",true,0)
	CREATURE_AVAILABLE(PLAYER0,"DARK_MISTRESS",true,0)
	CREATURE_AVAILABLE(PLAYER0,"GIANT",true,0)

	ROOM_AVAILABLE(PLAYER0,"TREASURE",true,true)
	ROOM_AVAILABLE(PLAYER0,"LAIR",true,true)
	ROOM_AVAILABLE(PLAYER0,"GARDEN",true,true)
	ROOM_AVAILABLE(PLAYER0,"TRAINING",true,false)
	ROOM_AVAILABLE(PLAYER0,"RESEARCH",true,false)
	ROOM_AVAILABLE(PLAYER0,"BRIDGE",true,false)
	ROOM_AVAILABLE(PLAYER0,"WORKSHOP",true,false)
	ROOM_AVAILABLE(PLAYER0,"PRISON",true,false)
	ROOM_AVAILABLE(PLAYER0,"TORTURE",true,false)
	ROOM_AVAILABLE(PLAYER0,"BARRACKS",true,false)
	ROOM_AVAILABLE(PLAYER0,"TEMPLE",true,false)
	ROOM_AVAILABLE(PLAYER0,"GRAVEYARD",true,false)
	ROOM_AVAILABLE(PLAYER0,"SCAVENGER",true,false)

	MAGIC_AVAILABLE(PLAYER0,"POWER_HAND",true,true)
	MAGIC_AVAILABLE(PLAYER0,"POWER_SLAP",true,true)
	MAGIC_AVAILABLE(PLAYER0,"POWER_POSSESS",true,true)
	MAGIC_AVAILABLE(PLAYER0,"POWER_IMP",true,true)
	MAGIC_AVAILABLE(PLAYER0,"POWER_SIGHT",true,false)
	MAGIC_AVAILABLE(PLAYER0,"POWER_SPEED",true,false)
	MAGIC_AVAILABLE(PLAYER0,"POWER_OBEY",true,false)
	MAGIC_AVAILABLE(PLAYER0,"POWER_CALL_TO_ARMS",true,false)
	MAGIC_AVAILABLE(PLAYER0,"POWER_CONCEAL",true,false)
	MAGIC_AVAILABLE(PLAYER0,"POWER_HOLD_AUDIENCE",true,false)
	MAGIC_AVAILABLE(PLAYER0,"POWER_HEAL_CREATURE",true,false)
	MAGIC_AVAILABLE(PLAYER0,"POWER_LIGHTNING",true,false)
	MAGIC_AVAILABLE(PLAYER0,"POWER_PROTECT",true,false)

	TRAP_AVAILABLE(PLAYER0,"ALARM",true,0)
	TRAP_AVAILABLE(PLAYER0,"POISON_GAS",true,0)
	TRAP_AVAILABLE(PLAYER0,"LIGHTNING",true,0)
	TRAP_AVAILABLE(PLAYER0,"BOULDER",true,0)
	TRAP_AVAILABLE(PLAYER0,"WORD_OF_POWER",true,0)

	DOOR_AVAILABLE(PLAYER0,"BRACED",true,0)
	DOOR_AVAILABLE(PLAYER0,"STEEL",true,0)
	DOOR_AVAILABLE(PLAYER0,"MAGIC",true,0)
	
	CREATE_PARTY("DIGGER")
		ADD_TO_PARTY("DIGGER","THIEF",1,500,"ATTACK_ENEMIES",0)

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
	CREATE_PARTY(partyname)
		ADD_TO_PARTY(partyname,partytype1,Game.wavenumber,500,"ATTACK_ENEMIES",0)
		ADD_TO_PARTY(partyname,partytype2,Game.wavenumber,500,"ATTACK_ENEMIES",0)
	
	-- add some more based on how long we've been playing
	local partyamount = Game.wavenumber + math.floor(PLAYER0.game_turn / 2000)
	partyamount = math.min(partyamount, 30)
	for i=1,partyamount do
		local partypick = partytypes[math.random(#partytypes)]
		local randomlevel = math.random(Game.wavenumber/2,Game.wavenumber)
		ADD_TO_PARTY(partyname,partypick,randomlevel,randomlevel*200,"ATTACK_ENEMIES",0)
	end
	
	SendChatMessage(PLAYER_GOOD, "My " .. partytype1 .. " & " .. partytype2 .. " are coming! (Wave " .. Game.wavenumber .. ")")
	
	-- ADD_PARTY_TO_LEVEL kept giving me wrong argument errors idk
	ADD_TUNNELLER_PARTY_TO_LEVEL(PLAYER_GOOD,partyname,-1,"DUNGEON",0,Game.wavenumber,500)
	
	Game.wavenumber = Game.wavenumber + 1
end

function diggerSpawn()
	ADD_TUNNELLER_PARTY_TO_LEVEL(PLAYER_GOOD,"DIGGER",-1,"DUNGEON_HEART",0,1,500)
end

-- This function runs as soon as the level begins
function OnGameStart()
    initLevel()
	
	-- spawn small tunneller party after 3000 turns. only once
	local first_digger = CreateTrigger()
        TriggerRegisterTimerEvent(first_digger, 3000, false) -- false for one time only
        TriggerAddAction(first_digger, diggerSpawn)
	
	-- keep spawning randomly generated parties every 4800 turns. loops
	local party_spawn_timer = CreateTrigger()
        TriggerRegisterTimerEvent(party_spawn_timer, 4800, true) -- true for repeating timer
		TriggerAddCondition(party_spawn_timer, function() return (Game.wavenumber < 10) end) -- only up to wave 10
        TriggerAddAction(party_spawn_timer, partySpawn)
		
	-- win when wave 10 has spawned and no more heroes are on the map
	local triggerWin = CreateTrigger()
        TriggerRegisterTimerEvent(triggerWin, 20, true) -- check every 20 turns
        TriggerAddCondition(triggerWin, function() return (PLAYER_GOOD.TOTAL_CREATURES <= 0) and (Game.wavenumber >= 10) end)
        TriggerAddAction(triggerWin, function() WIN_GAME(PLAYER0) end)

end
