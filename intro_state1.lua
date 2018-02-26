-- state
function intro_state1()
    local s={}
    local updateables={}
    local drawables={}
    
    local fg_c=9
    local sh_c=5
    add(drawables, tutils({text="i'm almost ready to go", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=20}))
    add(drawables, tutils({text="to the movies...", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=20+9}))

    add(drawables, tutils({text="i just need...", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=89}))
    add(drawables, tutils({text="o n e  m o r e  m i n u t e!!!", centerx=true, 
        bordered=true, shadowed=true, sh=2, fg=8, bg=7, y=89+15, blink=true, on_time=10}))


    add(drawables, tutils({text="(click to continue)", fg=5, x=50, y=119}))

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

        if(btnp(5) or (stat(34)==1))then
            consume_click=true 
        elseif consume_click then
            sfx(14)
			curstate=intro_state2()
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