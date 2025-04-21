

local function initLevel()
    Set_generate_speed(400)

    Start_money(PLAYER0,2500)

    Max_creatures(PLAYER0,7)

    Add_creature_to_pool("FLY",3)
    Add_creature_to_pool("BUG",12)

    Creature_available(PLAYER0,"FLY",true,false)

    Room_available(PLAYER0,"TREASURE",true,true)
    Room_available(PLAYER0,"LAIR",true,false)
    Room_available(PLAYER0,"GARDEN",true,false)

    Magic_available(PLAYER0,"POWER_SLAP",true,true)
    Magic_available(PLAYER0,"POWER_HAND",true,true)
    Magic_available(PLAYER0,"POWER_IMP",true,false)

    Set_creature_max_level(PLAYER_GOOD,"KNIGHT",1)
    Set_creature_max_level(PLAYER_GOOD,"THIEF",1)

    local i = PLAYER0.CONTROLS.ARCHER

    Create_party("LANDLORD")
        Add_to_party("LANDLORD","KNIGHT",1,1000,"ATTACK_ENEMIES",0)

    Create_party("THIEVES")
        Add_to_party("THIEVES","THIEF",1,100,"ATTACK_ENEMIES",0)
end



local function dispInfo3Condition()
    
end

local function LairAvailCondition()
    return (PLAYER0.TOTAL_CREATURES >= 1) and (PLAYER0.TREASURE >= 9)
end

local function dispInfo3()
    Display_information(3)
end

local function treasure9()
    Display_information(4,PLAYER0)
    local trigger = CreateTrigger()
        TriggerRegisterTimerEvent(trigger, 1, true)
        TriggerAddCondition(trigger,Condition(dispInfo3Condition))
        TriggerAddAction(trigger, dispInfo3)
end

local function noMoreDiggers()
	Display_information(21)
	Magic_available(PLAYER0,"POWER_IMP",true,true)
	Tutorial_flash_button(21,-1)
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
        TriggerAddAction(triggerLairAvail, function () Room_available(PLAYER0,"LAIR",true,true)  end)

end



