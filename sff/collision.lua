-- collision detection between bboxes

-- expects entities objects as arguments
function collides(ent1, ent2)
    local e1b=ent1.bounds
    local e2b=ent2.bounds
    
    if  ((e1b.xoff1 <= e2b.xoff2 and e1b.xoff2 >= e2b.xoff1)
    and (e1b.yoff1 <= e2b.yoff2 and e1b.yoff2 >= e2b.yoff1)) then 
        return true
    end

    return false
end

function wip_collides(x,y, ent)
    local eb=ent.bounds
    
    if  ((eb.xoff1 <= x+3 and eb.xoff2 >= x-3)
    and (eb.yoff1 <= y+3 and eb.yoff2 >= y-3)) then 
        return true
    end

    return false
end

function sides_c(hero, ent)
    local eb=ent.bounds
    local hb=hero.bounds
    local flip=hero.flipx

    local checkx=(eb.xoff1 <= hb.xoff2 and eb.xoff2 >= hb.xoff2)
    if(flip) checkx = (eb.xoff2 >= hb.xoff1 and eb.xoff1 <= hb.xoff1)

    return checkx and ((eb.yoff1 <= hb.yoff1 and eb.yoff2 >= hb.yoff1) or (eb.yoff1 <= hb.yoff2 and eb.yoff2 >= hb.yoff2))
end