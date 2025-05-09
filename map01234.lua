local function initLevel()
	SetGenerateSpeed(300)
	StartMoney(PLAYER0,7000)
	MaxCreatures(PLAYER0,30)

	AddCreatureToPool("FLY",2)
	AddCreatureToPool("BUG",2)
	AddCreatureToPool("DEMONSPAWN",4)
	AddCreatureToPool("TROLL",4)
	AddCreatureToPool("SPIDER",4)
	AddCreatureToPool("HELL_HOUND",2)
	AddCreatureToPool("TENTACLE",4)
	AddCreatureToPool("SORCEROR",4)
	AddCreatureToPool("ORC",4)
	AddCreatureToPool("DARK_MISTRESS",4)
	AddCreatureToPool("GIANT",4)

	CreatureAvailable(PLAYER0,"FLY",true,0)
	CreatureAvailable(PLAYER0,"BUG",true,0)
	CreatureAvailable(PLAYER0,"DEMONSPAWN",true,0)
	CreatureAvailable(PLAYER0,"TROLL",true,0)
	CreatureAvailable(PLAYER0,"SPIDER",true,0)
	CreatureAvailable(PLAYER0,"HELL_HOUND",true,0)
	CreatureAvailable(PLAYER0,"TENTACLE",true,0)
	CreatureAvailable(PLAYER0,"SORCEROR",true,0)
	CreatureAvailable(PLAYER0,"ORC",true,0)
	CreatureAvailable(PLAYER0,"DARK_MISTRESS",true,0)
	CreatureAvailable(PLAYER0,"GIANT",true,0)

	RoomAvailable(PLAYER0,"TREASURE",1,true)
	RoomAvailable(PLAYER0,"LAIR",1,true)
	RoomAvailable(PLAYER0,"GARDEN",1,true)
	RoomAvailable(PLAYER0,"TRAINING",1,false)
	RoomAvailable(PLAYER0,"RESEARCH",1,false)
	RoomAvailable(PLAYER0,"BRIDGE",1,false)
	RoomAvailable(PLAYER0,"WORKSHOP",1,false)
	RoomAvailable(PLAYER0,"PRISON",1,false)
	RoomAvailable(PLAYER0,"TORTURE",1,false)
	RoomAvailable(PLAYER0,"BARRACKS",1,false)
	RoomAvailable(PLAYER0,"TEMPLE",1,false)
	RoomAvailable(PLAYER0,"GRAVEYARD",1,false)

	MagicAvailable(PLAYER0,"POWER_HAND",true,true)
	MagicAvailable(PLAYER0,"POWER_SLAP",true,true)
	MagicAvailable(PLAYER0,"POWER_POSSESS",true,true)
	MagicAvailable(PLAYER0,"POWER_IMP",true,true)
	MagicAvailable(PLAYER0,"POWER_SIGHT",true,false)
	MagicAvailable(PLAYER0,"POWER_SPEED",true,false)
	MagicAvailable(PLAYER0,"POWER_OBEY",true,false)
	MagicAvailable(PLAYER0,"POWER_CALL_TO_ARMS",true,false)
	MagicAvailable(PLAYER0,"POWER_CONCEAL",true,false)
	MagicAvailable(PLAYER0,"POWER_HOLD_AUDIENCE",true,false)
	MagicAvailable(PLAYER0,"POWER_HEAL_CREATURE",true,false)
	MagicAvailable(PLAYER0,"POWER_LIGHTNING",true,false)
	MagicAvailable(PLAYER0,"POWER_PROTECT",true,false)

	TrapAvailable(PLAYER0,"ALARM",true,0)
	TrapAvailable(PLAYER0,"POISON_GAS",true,0)
	TrapAvailable(PLAYER0,"LIGHTNING",true,0)
	TrapAvailable(PLAYER0,"BOULDER",true,0)
	TrapAvailable(PLAYER0,"WORD_OF_POWER",true,0)

	DoorAvailable(PLAYER0,"BRACED",true,0)
	DoorAvailable(PLAYER0,"STEEL",true,0)
	DoorAvailable(PLAYER0,"MAGIC",true,0)
	
	CreateParty("DIGGER")
		AddToParty("DIGGER","THIEF",1,500,"ATTACK_ENEMIES",0)

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
	CreateParty(partyname)
		AddToParty(partyname,partytype1,Game.wavenumber,500,"ATTACK_ENEMIES",0)
		AddToParty(partyname,partytype2,Game.wavenumber,500,"ATTACK_ENEMIES",0)
	
	-- add some more based on how long we've been playing
	local partyamount = Game.wavenumber + math.floor(PLAYER0.GAME_TURN / 2000)
	partyamount = math.min(partyamount, 30)
	for i=1,partyamount do
		local partypick = partytypes[math.random(#partytypes)]
		local randomlevel = math.random(Game.wavenumber/2,Game.wavenumber)
		AddToParty(partyname,partypick,randomlevel,randomlevel*200,"ATTACK_ENEMIES",0)
	end
	
	QuickMessage("My " .. partytype1 .. " & " .. partytype2 .. " are coming! (Wave " .. Game.wavenumber .. ")", PLAYER_GOOD)
	
	-- Add_party_to_level kept giving me wrong argument errors idk
	AddTunnellerPartyToLevel(PLAYER_GOOD,partyname,-1,"DUNGEON",0,Game.wavenumber,500)
	
	Game.wavenumber = Game.wavenumber + 1
end

function diggerSpawn()
	AddTunnellerPartyToLevel(PLAYER_GOOD,"DIGGER",-1,"DUNGEON_HEART",0,1,500)
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
	RegisterOnConditionEvent(function() WinGame(PLAYER0) end,
							 function() return (PLAYER_GOOD.TOTAL_CREATURES <= 0) and (Game.wavenumber >= 10) end)

end
