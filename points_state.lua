-- state
-- points_object.kills = h.killed
-- points_object.wipped = h.wipped
-- points_object.score = h.score
function points_state(points_obj, won)
    local s={}
    local updateables={}
    local drawables={}

    if(not won)then
        sfx(8)
    else
        sfx(9)
    end


    camera(0,0)
    
    add(drawables, tutils({text="thanks for playing!"       , shadowed=true, bordered=true, bg=1, sh=9, fg=8, centerx=true, y=10}))
    add(drawables, tutils({text="made with sff by @rmbsevl" , shadowed=true, bordered=true, bg=1, sh=9, fg=8, centerx=true, y=17}))

    add(drawables, tutils({text="kills:    ", centerx=true, y=30+10}))
    add(drawables, tutils({text="        "..points_obj.kills, centerx=true, y=30+10}))

    add(drawables, tutils({text=" wips:    ",centerx=true, y=30+17}))
    add(drawables, tutils({text="        "..points_obj.wipped,centerx=true, y=30+17}))

    add(drawables, tutils({text="score:    ", centerx=true, y=30+24}))
    add(drawables, tutils({text="        "..points_obj.score, centerx=true, y=30+24}))

    local final=points_obj.kills+points_obj.wipped+points_obj.score
    add(drawables, tutils({text="final score:    ", centerx=true, y=30+34}))
    add(drawables, tutils({text="              "..final, centerx=true, y=30+34}))

    local btmx=70
    local btmy=112
    add(drawables, tutils({text="back to menu", x=btmx, y=btmy, fg=8, bg=7, bordered=true}))

    local consume_click=false
    s.update=function()
        if((stat(34)==1) and (mousex >= btmx and mousex<=btmx+48 and mousey >= btmy and mousey <= btmy+5))then
            -- clicked on back to menu
            consume_click=true 
        elseif consume_click then
            curstate=menu_state()
            sfx(14)
        end

        for u in all(updateables) do
            u:update()
        end
    end

    s.draw=function()
        fillp(0b0101101000011110)
        rectfill(0,0,127,127, 1)

        line(20, 61, 107, 61, 7) -- dividing line

        for d in all(drawables) do
            d:draw()
        end
    end

    return s
end