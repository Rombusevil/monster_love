-- state
-- points_object.kills = h.killed
-- points_object.wipped = h.wipped
-- points_object.score = h.score
function outro_state(points_obj)
    local s={}
    local updateables={}
    local drawables={}
    
    sfx(11)
    local fg_c=9
    local sh_c=5
    camera(0,0)
    add(drawables, tutils({text="done!", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=20}))
    add(drawables, tutils({text="we can go now...", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=20+9}))

    add(drawables, tutils({text="everything ok honey?", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=89}))
    
    local btmx=35
    local btmy=119
    add(drawables, tutils({text="click here to continue", x=btmx, y=btmy, fg=8, bg=7, bordered=true}))

    function linda(x,y)
        local anim_obj=anim()
        anim_obj:add(112,3,0.3,1,1)
    
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)

        e._draw=e.draw
        
        e.facex=x
        e.facey=y
        e.x=x+8
        e.y=y+16

        function e:draw()
            spr(67, self.facex,self.facey,3,3)
            self:_draw()
        end
        
        return e
    end
    add(drawables, linda(52,52))

    local consume_click=false
    s.update=function()
        for u in all(updateables) do
            u:update()
        end

        if(btnp(5) or (stat(34)==1) and (mousex >= btmx and mousex<=btmx+68 and mousey >= btmy and mousey <= btmy+5))then
            consume_click=true 
        elseif consume_click then
            curstate=points_state(points_obj, true)
            sfx(14)
        end
    end

    s.draw=function()
        fillp(0b0101101000011110)
        rectfill(0,0,127,127, 1)
        fillp()
        rectfill(0,52, 127, 76, 2)
        for d in all(drawables) do
            d:draw()
        end
    end

    return s
end