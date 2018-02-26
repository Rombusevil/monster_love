-- state
function instructions_state()
    local s={}
    local drawables={}
    

    add(drawables, tutils({text="use         to move", x=9, y=5}))
    add(drawables, tutils({text="    w a s d        ", x=9, y=5, bordered=true, fg=8, bg=7}))
    add(drawables, tutils({text="use mouse to:      ", x=9, y=13}))

    local mx=30
    local my=24
    add(drawables, tutils({text="throw hook", x=8*3+mx, y=my-3 }))
    add(drawables, tutils({text="attack", x=8*3+mx, y=my+5}))


    add(drawables, tutils({text="- kill humans to deplete the ", x=1, y=53}))
    add(drawables, tutils({text="  anger bar.", x=1, y=60}))
    
    add(drawables, tutils({text="- escape from cops. they can", x=1, y=60+7}))
    add(drawables, tutils({text="  only be killed when in", x=1, y=60+14}))
    add(drawables, tutils({text="  desoriented mode =====>", x=1, y=60+21}))

    add(drawables, tutils({text="click to start", blink=true, on_time=15, centerx=true,y=110,fg=7,bg=1,shadowed=true, sh=6}))
    

    function desoriented_cop(x,y)
        local anim_obj=anim()
        anim_obj:add(53,2,0.2,1,1)
    
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)

        e._draw=e.draw
        e.des_tick=0
        function e:draw()
            fillp()
            rectfill(self.x-1, self.y-4, self.x+10, self.y+8, 13)
            self.des_tick+=1
            if(self.des_tick % 4 != 0) spr(26, self.x+5, self.y-3)
            self:_draw()
        end
       
        return e
    end

    add(drawables, desoriented_cop(102, 78))

    local consume_click=false
    s.update=function()
        if(btnp(5) or (stat(34)==1))then
            consume_click=true 
        elseif consume_click then
            sfx(14)
            curstate=game_state()
        end
    end

    s.draw=function()
        cls()
        fillp(0b0101101000011110)
        rectfill(0,0,127,127, 1)
        for d in all(drawables) do
            d:draw()
        end
        spr(64, mx, my , 3,3) -- mouse drawing
    end

    return s
end