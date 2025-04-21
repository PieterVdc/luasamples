

traps = {{name = "BOULDER",cost = 1  , available = false},
               {name = "ALARM",  cost = 100, available = false}
            }


local function trapPlaced(player,trapName)
    for index, trap in ipairs(traps) do
        if trap.name == trapName then
            Trap_available(player,trap.name,0,1)
        end
    end
end

local function update_gold()
    for index, trap in ipairs(traps) do
        if PLAYER0.MONEY >= trap.cost and trap.available == false then
            Trap_available(PLAYER0,trap.name,1,trap.cost)
            trap.available = true
        elseif PLAYER0.MONEY < trap.cost and trap.available == true then
            Trap_available(PLAYER0,trap.name,0,-trap.cost)
            trap.available = false
        end
    end
    Destroyed_heroheart()
    
end

--local dbg = require("lldebugger")

function Destroyed_heroheart()
    Quick_objective("You have exposed the remaining heroes. Kill them and this realm is yours.", PLAYER0)

    
    --dbg.start()

    local creatures = getThingsOfClass("Creature")
    
    for index, cr in ipairs(creatures) do
        if (cr.owner == PLAYER_GOOD) then
            local show_pos = cr.pos
            Reveal_map_rect(PLAYER0, show_pos.stl_x, show_pos.stl_y, 3, 3)
        end
    end
end

function OnGameStart()
    PLAYER0:ADD_GOLD(1000)
    RegisterTimerEvent(Destroyed_heroheart,100,true)
    --RegisterTrapPlacedEvent(trapPlaced)
    --RegisterOnConditionEvent(function() Set_game_rule("StunGoodEnemyChance", 50) end,
    --                        function() print(PLAYER0.CREATURES_CONVERTED) return (PLAYER0.CREATURES_CONVERTED >= 4) end)

                            
end