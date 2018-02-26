-- prints 4 blocks in the entire screen that dances
-- implements drawable interface
local tick_dance=0
local step_dance=0

function dance_bkg(delay,color)
    local sp=delay
    local pat=0b1110010110110101
    tick_dance+=1
    if(tick_dance>=sp)then
        tick_dance=0
        step_dance+=1
        if(step_dance>=16)then step_dance = 0 end
    end
    fillp(bxor(shl(pat,step_dance), shr(pat,16-step_dance)))
    rectfill(0,0,64,64,color)
    rectfill(64,64,128,128,color)

    fillp(bxor(shr(pat,step_dance), shl(pat,16-step_dance)))
    rectfill(64,0,128,64,color)
    rectfill(0,64,64,128,color)
    
    fillp() -- resets fill pattern
end

-- setup shake to a value > 0 and call this func on every update
local shake=0
function cam_shake()
    if (shake>0) then
        if (shake>0.1) then
            shake*=0.9
        else
            shake=0
        end
        camera(rnd()*shake,rnd()*shake)
    end
end