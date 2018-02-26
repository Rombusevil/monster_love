-- state
function intro_state2()
    local s={}
    local updateables={}
    local drawables={}
    
    local fg_c=9
    local sh_c=5
    add(drawables, tutils({text="it has been 16 minutes ...", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=20}))
    add(drawables, tutils({text="why is she taking so long?", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=89}))

    add(drawables, tutils({text="(click to continue)", fg=5, x=50, y=119}))

    function billy(x,y)
        local anim_obj=anim()
        anim_obj:add(115,3,0.3,1,1)
    
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)

        e._draw=e.draw
        
        e.facex=x
        e.facey=y
        e.x=x+8
        e.y=y+16

        function e:draw()
            spr(70, self.facex,self.facey,3,3)
            self:_draw()
        end
        
        return e
    end
    add(drawables, billy(52,52))

    local consume_click=false
    s.update=function()
        for u in all(updateables) do
            u:update()
        end

        if(btnp(5) or (stat(34)==1))then
            consume_click=true 
        elseif consume_click then
            sfx(14)
			curstate=intro_state3()
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