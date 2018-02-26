function game_state()
    local s={}
    local updateables={}
    local drawables={}
    local humans={}
    
    local anger=tutils({text="anger", fg=8, bg=7, bordered=true, x=2, y=2})
    local points_dimmed=tutils({text="00000", fg=5, bordered=false, x=107, y=2})
    local points=tutils({text="0", fg=7, bordered=false, x=123, y=2})
    local kill_someone=tutils({text="kill someone!!!", fg=7, sh=5, shadowed=true, centerx=true, y=115, blink=true, on_time=12})

    local first_digit=points._x
    local human_hitted=false
    local kill_someone_hint=false

    music(-1)

    function hero(x,y)
        local anim_obj=anim()
        anim_obj:add(0,2,0.2,1,1)  --idle
        anim_obj:add(16,5,0.3,1,1) --run
        
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)
        
        anim_obj:add(32,5,0.8,1,1,true,function() e.draw_wip=true end) --wip
        anim_obj:add(48,3,0.6,1,1,true,function() e.attacking=false end) --attack

        local bounds_obj=bbox(8,8)
        e:set_bounds(bounds_obj)
        -- e.debugbounds=true

        e.states = {moovable=1, attacking=2, wipping=3}
        e.speed = 1
        e.state = e.states.moovable
        e.attacking=false
        e.hits=3
        e.anger=100
        e.anger_step=7

        e.up   = false
        e.down = false
        e.right= false
        e.left = false
        e.killed=0
        e.wipped=0
        e.score=0
        e.last_kill_tmr=0

        function e:gamepad()
            if self.state==self.states.moovable then
                self.up=false self.down=false self.right=false self.left=false
                
                if not self.attacking then
                    if btn(0) or btn(1) or btn(2) or btn(3) then 
                        self:set_anim(2) -- running
                    else
                        self:set_anim(1) -- idle
                    end
                end

                if btnp(4) or (stat(34)==1) and not self.attacking then -- "O" wip
                    self:set_anim(3)
                    self.state=self.states.wipping
                    self.mx=mousex
                    self.my=mousey
                    sfx(0)
                elseif btnp(5) or (stat(34)==2) then -- "X" attack
                    sfx(1)
                    self:set_anim(4)
                    self.attacking=true

                    for h in all(humans) do
                        if(sides_c(self, h)) h:hit() self.killed+=1 self.last_kill_tmr=0 kill_someone_hint=false sfx(2)
                    end
                end

                --[[ MOVEMENT ]]--    
                if(btn(0))then     --left
                    self:setx(self.x-self.speed)
                    self.flipx = true
                    self.left = true
                elseif(btn(1))then --right
                    self:setx(self.x+self.speed)
                    self.flipx = false
                    self.right = true
                end
                
                if(btn(2))then          --up
                    self:sety(self.y-self.speed)
                    self.up = true
                elseif(btn(3))then  --down
                    self:sety(self.y+self.speed)
                    self.down = true
                end
                --[[ END MOVEMENT ]]--
            end
        end

        e._draw=e.draw
        e.wip_tick=0
        e.cos45=0.73
        e.sin45=0.69
        e.explo=circle_explo()
        e.mx=0
        e.my=0
        e.wip_length=40
        e.wip_radius_clr=6
        function e:draw()
            self.last_kill_tmr+=1
            if(self.last_kill_tmr % 50 == 0) then
                self.anger+=self.anger_step/2 -- te aumenta la anger pq no mataste a nadie in a long time
                sfx(15)
                if(self.anger > 100)then
                    self.anger = 100
                    kill_someone_hint=true
                end
            end

            -- circfill(self.x+3, self.y+7, 5, 10) -- red
            circfill(self.x+3, self.y+7, 4, 9) -- red
            circfill(self.x+3, self.y+7, 3, 8) -- red
            circfill(self.x+3, self.y+7, 2,  0) -- shadow
            self.explo:update()
            self.explo:draw()
            self:_draw()

            circ(self.x+4, self.y+4, self.wip_length,  self.wip_radius_clr) -- reach

            if self.draw_wip then
                local flipx=1
                local x0 = self.x+4
                local y0=self.y+4

                local sides = self.left or self.right
                local topbottom = self.up or self.down
                -- if(self.flipx or false) flipx=-1 x0=self.x-1
 
                local dx = (self.x - self.mx)*-1
                local dy = (self.y - self.my)*-1
                local ang=atan2(dx,dy)
                if(dx <0) self.flipx=true else self.flipx=false

                local lx1=self.x+4+(cos(ang)*self.wip_length)
                -- if(not self.flip) lx1+=3
                local ly1=self.y+4+(sin(ang)*self.wip_length)
                -- if(ly1 < self.y) ly1+=3

                local resolution=10
                local step=self.wip_length/resolution
                local curlen=step
                for i=1,resolution do -- check "resolution" parts of wip_length for collition
                    if not human_hitted then
                        local xx=self.x+(cos(ang)*curlen)
                        local yy=self.y+(sin(ang)*curlen)
                        for human in all(humans) do
                            if(not human_hitted)then
                                printh(human_hitted)
                                if wip_collides(xx,yy, human) then
                                    sfx(5)
                                    shake=2
                                    human.pause=true
                                    human_hitted=human
                                    human_hitted.hitx=xx
                                    human_hitted.hity=yy
                                    self.score+=10
                                    self.explo:explode(xx,yy)
                                    self.wipped+=1
                                    if(self.wipped % 5==0)then
                                        -- increase reach every X hits
                                        self.wip_length+=5
                                        self.wip_radius_clr+=1
                                    end
                                end
                            end
                        end
                        curlen+=step
                    end
                end

                if(human_hitted)then
                    line(x0, y0,  human_hitted.hitx, human_hitted.hity,  11)
                else
                    -- full lenght wip line
                    line(x0, y0,  lx1,ly1,  11)
                end
                
                self.wip_tick+=1
                if self.wip_tick >= 5 then
                    self.draw_wip=false
                    self.wip_tick=0
                    self.state=self.states.moovable 
                    if(human_hitted)then
                        local dx=human_hitted.x-3
                        local dy=human_hitted.y-3
                        if (self.x > dx) dx+=7
                        if (self.y > dy) dy+=7
                        self:setpos(dx, dy)
                    end
                    human_hitted=false
                end
            end
        end

        function e:hurt()
            if(not self.flickerer.is_flickering)then
                sfx(3)
                self:flicker(50)
                self.explo:multiexplode(self.x+4, self.y+4)
                shake=5
                self.hits-=1
                if(self.hits<=0)then
                    -- goto game over
                    local pobject={}
                    pobject.kills = self.killed
                    pobject.wipped = self.wipped
                    pobject.score =  self.score
                    curstate=points_state(pobject)
                end

                return true
            else
                return false
            end
        end
    
        return e
    end

    function human1(x,y,first_frm,target)
        local anim_obj=anim()
        anim_obj:add(first_frm,5,0.3,1,1)
    
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)
    
        local bounds_obj=bbox(8,8)
        e:set_bounds(bounds_obj)
        -- e.debugbounds=true
    
        e._draw=e.draw
        e.speed=0.5+rnd(0.9)
        e.dir=1
        e.destx=-1
        e.desty=-1
        e.destidx=3
        e.dests={{x=2,y=12},{x=120,y=12},{x=120,y=120},{x=2,y=120}}
        e.destsum=0
        e.dont_bust_my_chops=false
        e.dir=1
        e.pause=false
        e.pause_tick=0
        e.alive=true
        if(rnd(1)>0.5) e.destsum=2

        function e:draw()
            if not self.pause then
                self.pause_tick=0
                -- a    b
                -- +----+
                -- |    |
                -- |    |
                -- +----+
                -- d    c
                if not collides(target, square) then
                    -- distance from the target to screen borders
                    local dista=sqrt( (target.x*target.x) + (target.y*target.y) )
                    local distb=sqrt( ((target.x-127)*(target.x-127)) + (target.y*target.y) )
                    local distc=sqrt( ((target.x-127)*(target.x-127)) + ((target.y-127)*(target.y-127)) )
                    local distd=sqrt( (target.x*target.x) + (target.y*target.y) )

                    -- by default GOTO D
                    self.destidx=4

                    if(dista >= distb and dista >= distc and dista >= distd)then
                        -- GOTO A
                        self.destidx=1
                    elseif(distb >= dista and distb >= distc and distb >= distd)then
                        -- GOTO B
                        self.destidx=2
                    elseif(distc >= dista and distc >= distb and distc >= distd)then
                        -- GOTO C
                        self.destidx=3
                    end

                    -- a little bit of random here, so that all humans dont go to the same corner
                    if(self.destsum)then
                        self.destidx+=self.destsum
                        self.destidx=(self.destidx % #self.dests)+1
                    end

                elseif (self.destx==-1 or self.desty==-1) then
                    -- change corner
                    self.dont_bust_my_chops=true
                    self.destx=0 self.desty=0
                    self.destidx+=self.destsum
                    self.destidx=(self.destidx % #self.dests)+1
                end
                
                self.destx=self.dests[self.destidx].x
                self.desty=self.dests[self.destidx].y

                local deltax=(self.x-self.destx)*-1
                local deltay=(self.y-self.desty)*-1
                local ang=atan2(deltax,deltay)
                
                if(deltax <0) self.flipx=true else self.flipx=false

                self:setx(self.x+(cos(ang)*self.speed))
                self:sety(self.y+(sin(ang)*self.speed))

                if not self.dont_bust_my_chops then
                    if( (self.x >= self.destx-3 and self.x <= self.destx+3)
                    and (self.y >= self.desty-3 and self.y <= self.desty+3))
                    then
                        self.destsum+=1
                        self.destx=-1 self.desty=-1 -- mark to change corners 
                    end
                else
                    self.dont_bust_my_chops=false
                end
            
            end

            circfill(self.x+3, self.y+7, 2,  0) -- shadow
            self:_draw()

            if self.pause then
                if(self.pause_tick % 4 != 0) spr(26, self.x+5, self.y-3)
                self.pause_tick+=1
                if self.pause_tick >= 20 then
                    self.pause=false
                end
            end
        end

        function e:hit()
            shake=4
            self.alive=false
            target.score+=25
            target.anger-=target.anger_step
        end

        return e
    end

    function police(x,y, target)
        local anim_obj=anim()
        anim_obj:add(21,5,0.3,1,1) --run
        anim_obj:add(37,4,0.5,1,1) --attack
        anim_obj:add(51,2,0.2,1,1) --celebrate
        anim_obj:add(53,2,0.2,1,1) --desoriented
    
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)
    
        local bounds_obj=bbox(8,8)
        e:set_bounds(bounds_obj)
        -- e.debugbounds=true

        e.speed=rnd(0.3) + 0.3 
        e._draw=e.draw
        e.take_a_moment=false
        e.desoriented=false
        e.des_tick=0
        e.alive=true
        e.explo=circle_explo()
        e.ran_desor=rnd(9)
        e.sfx_fuse=true
        function e:draw()
            self.explo:update()
            self.explo:draw()

            self.des_tick+=1
            if(self.desoriented)then
                -- show alert icon
                if(self.des_tick % 4 != 0) spr(26, self.x+5, self.y-3)

                if(self.des_tick % 50 == 0)then
                    self.des_tick = 0
                    self.desoriented = false
                    self:set_anim(1)
                    del(humans, self)
                end
            else
                if(not self.take_a_moment)then
                    local reachedx=false
                    local reachedy=false

                    if(abs(self.x-target.x) >5)then
                        if(self.x < target.x)then
                            self:setx(self.x+self.speed)
                            self.flipx=false
                        elseif(self.x > target.x)then
                            self:setx(self.x-self.speed)
                            self.flipx=true
                        end
                    else
                        reachedx=true
                    end

                    if(abs(self.y-target.y) >5)then
                        if(self.y < target.y)then
                            self:sety(self.y+self.speed)
                        elseif(self.y > target.y)then
                            self:sety(self.y-self.speed)
                        end
                    else
                        reachedy=true
                    end

                    if(reachedx and reachedy)then
                        if(target:hurt())then
                            --celebrate
                            self.des_tick=0
                            self:set_anim(2)
                            self.take_a_moment=true
                            self.take_a_moment_tmr=0
                        end
                    end

                    -- every 100 ticks, desorient the cop
                    if(self.des_tick % 150 == 0 and not self.take_a_moment)then
                        sfx(4)
                        self:set_anim(4)
                        self.desoriented=true
                        self.des_tick=0
                        add(humans, self) -- added to the group so that hero can kill him here
                    end
                    self.sfx_fuse=true
                else
                    self.des_tick=0
                    self.take_a_moment_tmr+=1
                    if(self.take_a_moment_tmr > 10)then
                        --celebrate
                        self:set_anim(3)
                    end

                    if(self.sfx_fuse)then 
                        self.sfx_fuse=false
                        sfx(6)
                    end

                    if(self.take_a_moment_tmr > 50)then
                        self.take_a_moment=false
                        self:set_anim(1)
                    end
                end
            end
            circfill(self.x+3, self.y+7, 2,  0) -- shadow
            circfill(self.x+3, self.y+7, 1,  8) -- shadow
            self:_draw()
        end

        function e:hit()
            if(self.desoriented)then
                -- TODO: el police no sale de humans, pq dsp de estar desoriented lo podés matar si lo tocás
                shake=3
                self.alive=false
                target.score+=100
                target.anger-=target.anger_step
                self.explo:explode(self.x, self.y)

                -- spawns 2 humans
                spawn_human()
                spawn_human()
            end
        end
    
        return e
    end

    -- for triggering persecution
    function persecution_square(x,y)
        local anim_obj=anim()
        anim_obj:add(1,1,0.1,1,1)
    
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)
    
        local bounds_obj=bbox(80,50)
        e:set_bounds(bounds_obj)
    
        e._draw=e.draw
        function e:draw()
            -- self:_draw() -- I don't want to draw anything
            -- self.bounds:printbounds()
        end

        return e
    end

    square=persecution_square(24,39) -- add(drawables, square)
    
    local enemy_types={man=2, woman=7}

    local h=hero(50,50)
    add(drawables, h)

    function spawn_human()
        local gender = enemy_types.woman
        if(rnd(1)>0.5) gender=enemy_types.man
        nh=human1(rnd(120), rnd(120), gender, h)
        add(drawables, nh)
        add(humans, nh)
    end

    -- spawns starting humans
    for i=1,7 do
        spawn_human()
    end

    local first=true
    local lastHuman=0
    local gameover_fuse=false
    local alarm_sfx_fuse=true
    s.update=function()
        -- win condition
        if(h.anger <= 0)then
            local pobject={}
            pobject.kills = h.killed
            pobject.wipped = h.wipped
            pobject.score = h.score
            curstate=outro_state(pobject)
            return
        end

        if(kill_someone_hint)then
            if(alarm_sfx_fuse) tick=0 alarm_sfx_fuse=false
            if(tick % 30 == 0)then
                sfx(7)
            end
        else
            alarm_sfx_fuse=true
        end

        -- kill humans that deserve to die
        for h in all(humans) do
            if not h.alive then
                del(humans, h)
                del(drawables, h)
            end
        end

        h:gamepad()

        if(not(h.killed == lastHuman))then
            -- spawn human for X kills
            if(h.killed % 2 == 0)then
                lastHuman=h.killed
                spawn_human()
                spawn_human()
            end
            -- spawn cop for x kills
            if(h.killed % 3 == 0)then
                add(drawables, police(64, 130, h))
                lastHuman=h.killed
            end

            -- mando un cop cuando matas al primero
            if(h.killed==1 and first) add(drawables, police(3, 129, h)) first=false
        end

        for u in all(updateables) do
            u:update()
        end

        cam_shake()
    end

    local anger_size=40
    local anger_div=100/anger_size
    local anger_barx=23
    local full_bar=anger_barx+100/anger_div
    s.draw=function()
        cls()
        rectfill(0,0, 127,127, 6)
        map(0,0,0,0)
        for d in all(drawables) do
            d:draw()
        end
        
        -- hud ---------------------
        --fillp(0b0011110000111100)
        rectfill(0,0, 127,8, 0)
        anger:draw()

        fillp()
        rectfill(anger_barx-1,1,  full_bar+1                    , 7, 7) -- white border
        fillp(0b0101101001011010)
        rectfill(anger_barx  ,2,  full_bar                      , 6, 5) -- grayed out
        fillp()
        rectfill(anger_barx  ,2,  anger_barx+h.anger/anger_div  , 6, 8) -- anger meter

        points_dimmed:draw()
        points.text=h.score
        if(h.score > 0)then
            if(h.score > 9999)then 
                points._x=first_digit - 4*4
                points_dimmed.text=""
            elseif(h.score > 999)then 
                points._x=first_digit - 3*4
                points_dimmed.text="0"
            elseif(h.score > 99)then 
                points._x=first_digit - 2*4
                points_dimmed.text="00"
            elseif(h.score > 9)then 
                points._x=first_digit - 4
                points_dimmed.text="000"
            end
        end
        points:draw()
        
        -- hero lives
        local xpos=70
        for i=1,h.hits do
            spr(27, xpos, 2)
            xpos+=6
        end

        if(kill_someone_hint)then
            kill_someone:draw()
        end
    end

    return s
end