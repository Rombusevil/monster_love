pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- made with super-fast-framework

--<*sff/entity.lua
--<*sff/timer.lua
--<*sff/tutils.lua
--<*sff/collision.lua
--<*sff/explosions.lua

--<*visual.lua
--<*menu_state.lua
--<*game_state.lua
--<*win_state.lua
--<*instructions_state.lua
--<*intro_state1.lua
--<*intro_state2.lua
--<*intro_state3.lua
--<*points_state.lua
--<*outro_state.lua

poke(0x5F2D, 1) -- enables mouse
function _init()
    music(0)
    curstate=intro_state1()
    -- curstate=menu_state()
    -- curstate=game_state()
    
    tick=0 -- all purpose tick counter
end

function _update()
    tick+=1
    curstate.update()
    mousex=stat(32)
    mousey=stat(33)
end

function _draw()
    curstate.draw()
    spr(41, mousex-3, mousey-3) --mouse
end
