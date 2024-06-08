local sf = require "levels.luasamples.sunfish"


local function sunFpos_to_stl(pos_x,pos_y)
    if Game.turn == true then
        return 10 + (pos_x * 3), 46 - (pos_y * 3)
    else
        return 31 - (pos_x * 3), 25 + (pos_y * 3)
    end
end



local function sfId_to_stl(sfId)
    local x = (sfId - sf.A1) % 10
    local y = -1 * math.floor((sfId - sf.A1) / 10)
    return sunFpos_to_stl(x,y)
end

local function sfId_to_pos(sfId)
    
    local x,y = sfId_to_stl(sfId)
    return {stl_x = x,stl_y = y}
end



local function sunFpos_to_sfId(x,y)
    if Game.turn == true then
        return 10 + y * 10 + x
    else
        return 91 -x -y*10
    end
end

local function pos_to_sfId(pos)
    local x = math.floor((pos.stl_x - 7) / 3)
    local y = math.floor((pos.stl_y - 22) / 3)
    return sunFpos_to_sfId(x,y)
end





local function get_creature_sfId(creature)
    
    for i,_ in pairs(Game.ThingSfpos) do

        if Game.ThingSfpos[i] == creature then
            return i
        end
    end
end

local function get_creature_at_sfId(sfId)
    if Game.turn then
        return Game.ThingSfpos[sfId]
    else
        return Game.ThingSfpos[119 - sfId]

    end
end

local function set_creature_at_sfId(sfId,creature)
    
    if Game.turn then
        Game.ThingSfpos[sfId] = creature
    else
        Game.ThingSfpos[119 - sfId] = creature
    end
end

--- comment
--- @param creature Creature
local function placeSpecialBoxes(creature)

    local moves = Game.sfpos:genMoves()

    local sfId = get_creature_sfId(creature)

    print("sfId" .. sfId)



    local num_moves = 0

    for _, move in pairs(moves) do
        if move[1] == sfId then
            ADD_OBJECT_TO_LEVEL("SPECBOX_CUSTOM",sfId_to_pos(move[2]),0)
            num_moves = num_moves +1
        end
    end
    if num_moves > 0 then
        MAGIC_AVAILABLE(creature.owner,"POWER_SLAP",false,false)
    end
end

local function unitSlapped()
    print("unitSlapped")
    Game.last_slapped_unit = GetTriggeringThing()

    print("unitSlapped" .. tostring(Game.currentTriggeringThing) )

    print(tostring(Game.last_slapped_unit))
    
    placeSpecialBoxes(Game.last_slapped_unit)
    
end

local function movePiece(move)
    local i, j = move[1], move[2]

    print(" move[2]" ..  move[2])

    local end_stl_x,end_stl_y     = sfId_to_stl(j)

    local cr_i = get_creature_at_sfId(i)
    local cr_j = get_creature_at_sfId(j)

    if cr_j ~= nil then
        print("kill" .. tostring(cr_j))
        cr_j:KillCreature()
    end

    cr_i:MoveThingTo(end_stl_x, end_stl_y)

    set_creature_at_sfId(j,cr_i)
    set_creature_at_sfId(i,nil)
    Game.sfpos = Game.sfpos:move(move)

    --pawn promotion
    if(move[2]<30 and (cr_i.model == "IMP" or cr_i.model == "TUNNELLER")) then
        local model
        if(cr_i.model == "IMP") then 
            model = "DARK_MISTRESS" 
        else 
            model = "WITCH" 
        end 
        queen = ADD_CREATURE_TO_LEVEL(cr_i.owner,model,sfId_to_pos(move[2]),1,10,0)
        queen:MakeThingZombie()
        set_creature_at_sfId(j,queen)
        queen:MoveThingTo(end_stl_x, end_stl_y)
        local trigger = CreateTrigger()
            TriggerRegisterThingEvent(trigger, queen, "powerCast")
            --TriggerAddCondition(trigger,function () return GetTriggeringSpellKind() == "POWER_SLAP" end)
            TriggerAddAction(trigger, unitSlapped)
        cr_i:KillCreature()
    end
    

end



local function cpu_turn()

    local move, score = sf.search(Game.sfpos)

     -- print(move, score)
     assert(score)
     if score <= -sf.MATE_VALUE then
        print("wibn")
         WIN_GAME(PLAYER0)
         return
     end
     if score >= sf.MATE_VALUE then
        print("lose")
         LOSE_GAME(PLAYER0)
         return
     end
    
     assert(move)
     movePiece(move)
    
     SendChatMessage(PLAYER0, "My move:" .. sf.render(119 - move[0 + sf.__1]) .. sf.render(119 - move[1 + sf.__1]))

     Game.turn = true
     MAGIC_AVAILABLE(PLAYER0,"POWER_SLAP",true,true)

end

local function special_activated()

    ---@type Thing
    local box = GetTriggeringThing()

    local objects = get_things_of_class("Object")
    for i,_ in pairs(objects) do

        if objects[i].model == "SPECBOX_CUSTOM" then
            if objects[i] ~= box then
                objects[i]:DeleteThing()
            end
            
        end
    end

    local move = {get_creature_sfId(Game.last_slapped_unit),pos_to_sfId(box.pos)}

    movePiece(move)

    print(Game.sfpos.board)

    Game.turn = false

    local trigger = CreateTrigger()
        TriggerRegisterTimerEvent(trigger,40,false)
        TriggerAddAction(trigger, cpu_turn)

    

end








function OnGameStart()

    Game.turn = true
    Game.ThingSfpos = {}

    ---@type Creature[]
    local creatures = get_things_of_class("Creature")

    for i,_ in pairs(creatures) do

        local cr = creatures[i]

        if(cr.owner == PLAYER_GOOD) then
            cr.orientation = 1024
            
        end
        cr:MakeThingZombie()

        Game.ThingSfpos[pos_to_sfId(cr.pos)] = cr
        
        local trigger = CreateTrigger()
            TriggerRegisterThingEvent(trigger, creatures[i], "powerCast")
            --TriggerAddCondition(trigger,function () return GetTriggeringSpellKind() == "POWER_SLAP" end)
            TriggerAddAction(trigger, unitSlapped)

    end

    local trigger = CreateTrigger()
        TriggerRegisterThingEvent(trigger, nil, "SpecialActivated")
        TriggerAddAction(trigger, special_activated)

    Game.sfpos = sf.Position.new(sf.initial, 0, { true, true }, { true, true }, 0, 0)


end