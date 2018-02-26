-- state
function intro_state3()
    local s={}
    local updateables={}
    local drawables={}
    
    local fg_c=9
    local sh_c=5

    add(drawables, tutils({text="why???!!!", centerx=true, bordered=false, shadowed=true, sh=sh_c, fg=fg_c, bg=7, y=20}))
    add(drawables, tutils({text="a r g h h h h h", centerx=true, bordered=true, shadowed=true, sh=2, fg=8, bg=7, y=89+15, blink=true, on_time=10}))

    add(drawables, tutils({text="(click to continue)", fg=5, x=50, y=119}))

    function billy(x,y)
        local anim_obj=anim()
        anim_obj:add(73,2,0.2,3,3)
    
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)
       
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
			curstate=menu_state()
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