

local function initLevel()
    SET_GENERATE_SPEED(400)

    START_MONEY(PLAYER0,2500)

    MAX_CREATURES(PLAYER0,7)

    ADD_CREATURE_TO_POOL("FLY",3)
    ADD_CREATURE_TO_POOL("BUG",12)

    CREATURE_AVAILABLE(PLAYER0,"FLY",true,false)

    ROOM_AVAILABLE(PLAYER0,"TREASURE",true,true)
    ROOM_AVAILABLE(PLAYER0,"LAIR",true,false)
    ROOM_AVAILABLE(PLAYER0,"GARDEN",true,false)

    MAGIC_AVAILABLE(PLAYER0,"POWER_SLAP",true,true)
    MAGIC_AVAILABLE(PLAYER0,"POWER_HAND",true,true)
    MAGIC_AVAILABLE(PLAYER0,"POWER_IMP",true,false)

    SET_CREATURE_MAX_LEVEL(PLAYER_GOOD,"KNIGHT",1)
    SET_CREATURE_MAX_LEVEL(PLAYER_GOOD,"THIEF",1)

    local i = PLAYER0.CONTROLS.ARCHER

    CREATE_PARTY("LANDLORD")
        ADD_TO_PARTY("LANDLORD","KNIGHT",1,1000,"ATTACK_ENEMIES",0)

    CREATE_PARTY("THIEVES")
        ADD_TO_PARTY("THIEVES","THIEF",1,100,"ATTACK_ENEMIES",0)
end



local function dispInfo3Condition()
    
end

local function LairAvailCondition()
    return (PLAYER0.TOTAL_CREATURES >= 1) and (PLAYER0.TREASURE >= 9)
end

local function dispInfo3()
    DISPLAY_INFORMATION(3)
end

local function treasure9()
    DISPLAY_INFORMATION(4,PLAYER0)
    local trigger = CreateTrigger()
        TriggerRegisterTimerEvent(trigger, 1, true)
        TriggerAddCondition(trigger,Condition(dispInfo3Condition))
        TriggerAddAction(trigger, dispInfo3)
end

local function noMoreDiggers()
	DISPLAY_INFORMATION(21)
	MAGIC_AVAILABLE(PLAYER0,"POWER_IMP",true,true)
	TUTORIAL_FLASH_BUTTON(21,-1)
end


function Setup()
    initLevel()

    local trigger = CreateTrigger()
        TriggerRegisterThingEvent(trigger, 1, true)
        TriggerAddCondition(trigger,dispInfo3Condition)
        TriggerAddAction(trigger, dispInfo3)

    local trigger2 = CreateTrigger()
        TriggerRegisterTimerEvent(trigger2, 125, false)
        TriggerAddAction(trigger2, treasure9)

    local trigger3 = CreateTrigger()
        TriggerRegisterVariableEvent(trigger3, PLAYER0,"TREASURE",">=",9)
        TriggerAddAction(trigger3, treasure9)

    local triggerNoMoreDiggers = CreateTrigger()
        TriggerRegisterVariableEvent(triggerNoMoreDiggers, PLAYER0,"CONTROLS.TOTAL_DIGGERS","=",0)
        TriggerAddAction(triggerNoMoreDiggers, noMoreDiggers)

    local triggerLairAvail = CreateTrigger()
        TriggerRegisterTimerEvent(triggerLairAvail, 1, true)
        TriggerAddCondition(triggerLairAvail,function () return (PLAYER0.TREASURE >= 1) and (PLAYER0.GAME_TURN > 175)  end)
        TriggerAddAction(triggerLairAvail, function () ROOM_AVAILABLE(PLAYER0,"LAIR",true,true)  end)

end



