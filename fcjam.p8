pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- made with super-fast-framework

function bbox(w,h,xoff1,yoff1,xoff2,yoff2)
    local bbox={}
    bbox.offsets={xoff1 or 0,yoff1 or 0,xoff2 or 0,yoff2 or 0}
    bbox.w=w
    bbox.h=h
    bbox.xoff1=bbox.offsets[1]
    bbox.yoff1=bbox.offsets[2]
    bbox.xoff2=bbox.offsets[3]
    bbox.yoff2=bbox.offsets[4]
    function bbox:setx(x)
        self.xoff1=x+self.offsets[1]
        self.xoff2=x+self.w-self.offsets[3]
    end
    function bbox:sety(y)
        self.yoff1=y+self.offsets[2]
        self.yoff2=y+self.h-self.offsets[4]
    end
    function bbox:printbounds()
        rect(self.xoff1, self.yoff1, self.xoff2, self.yoff2, 8)
    end
    return bbox
end
function anim()
    local a={}
	a.list={}
	a.current=false
    a.tick=0
    function a:_get_fr(one_shot, callback)
		local anim=self.current
		local aspeed=anim.speed
		local fq=anim.fr_cant		
		local st=anim.first_fr
		local step=flr(self.tick)*anim.w
		local sp=st+step
		self.tick+=aspeed
		local new_step=flr(flr(self.tick)*anim.w)		
        if st+new_step >= st+(fq*anim.w) then 
            if one_shot then
                self.tick-=aspeed  
                callback()
            else
                self.tick=0
            end
        end
		return sp
    end
    function a:set_anim(idx)
        if (self.currentidx == nil or idx != self.currentidx) self.tick=0 
        self.current=self.list[idx]
        self.currentidx=idx
    end
	function a:add(first_fr, fr_cant, speed, zoomw, zoomh, one_shot, callback)
		local a={}
		a.first_fr=first_fr
		a.fr_cant=fr_cant
		a.speed=speed
		a.w=zoomw
        a.h=zoomh
        a.callback=callback or function()end
        a.one_shot=one_shot or false
		add(self.list, a)
	end
	function a:draw(x,y,flipx,flipy)
		local anim=self.current
		if( not anim )then
			rectfill(0,117, 128,128, 8)
			print("err: obj without animation!!!", 2, 119, 10)
			return
		end
		spr(self:_get_fr(self.current.one_shot, self.current.callback),x,y,anim.w,anim.h,flipx,flipy)
    end
    function a:done(callback)
    end
	return a
end
function entity(anim_obj)
    local e={}
    e.x=0
    e.y=0
    e.anim_obj=anim_obj
    e.debugbounds, e.flipx, e.flipy = false
    e.bounds=nil
    e.flickerer={}
    e.flickerer.timer=0
    e.flickerer.duration=0          
    e.flickerer.slowness=3
    e.flickerer.is_flickering=false 
    function e.flickerer:flicker()
        if(self.timer > self.duration) then
            self.timer=0 
            self.is_flickering=false
        else
            self.timer+=1
        end
    end
    function e:setx(x)
        self.x=x
        if(self.bounds != nil) self.bounds:setx(x)
    end
    function e:sety(y)
        self.y=y
        if(self.bounds != nil) self.bounds:sety(y)
    end
    function e:setpos(x,y)
        self:setx(x)
        self:sety(y)
    end
    function e:set_anim(idx)
		self.anim_obj:set_anim(idx)
    end
    function e:set_bounds(bounds)
        self.bounds = bounds
        self:setpos(self.x, self.y)
    end
    function e:flicker(duration)
        if(not self.flickerer.is_flickering)then
            self.flickerer.duration=duration
            self.flickerer.is_flickering=true
            self.flickerer:flicker()
        end
        return self.flickerer.is_flickering
    end
    function e:draw()
        if(self.flickerer.timer % self.flickerer.slowness == 0)then
            self.anim_obj:draw(self.x,self.y,self.flipx,self.flipy)
        end
        if(self.flickerer.is_flickering) self.flickerer:flicker()        
		if(self.debugbounds) self.bounds:printbounds()
    end
    return e
end

function timer(updatables, step, ticks, max_runs, func)
    local t={}
    t.tick=0
    t.step=step
    t.trigger_tick=ticks
    t.func=func
    t.count=0
    t.max=max_runs
    t.timers=updatables
    function t:update()
        self.tick+=self.step
        if(self.tick >= self.trigger_tick)then
            self.func()
            self.count+=1
            if(self.max>0 and self.count>=self.max and self.timers ~= nil)then
                del(self.timers,self) 
            else
                self.tick=0
            end
        end
    end
    function t:kill()
        del(self.timers, self)
    end
    add(updatables,t) 
    return t
end

function tutils(args)
	local s={}
	s.private={}
	s.private.tick=0
	s.private.blink_speed=1
	s.height=10 
	s.text=args.text or ""
	s._x=args.x or 2
	s._y=args.y or 2
	s._fg=args.fg or 7
	s._bg=args.bg or 2
	s._sh=args.sh or 3 	
	s._bordered=args.bordered or false
	s._shadowed=args.shadowed or false
	s._centerx=args.centerx or false
	s._centery=args.centery or false
	s._blink=args.blink or false
	s._blink_on=args.on_time or 5
	s._blink_off=args.off_time or 5
	function s:draw()
		if self._centerx then self._x =  64-flr((#self.text*4)/2) end
		if self._centery then self._y = 64-(4/2) end
		if self._blink then 
			self.private.tick+=1
			local offtime=self._blink_on+self._blink_off 
			if(self.private.tick>offtime) then self.private.tick=0 end
			local blink_enabled_on = false
			if(self.private.tick<self._blink_on)then
				blink_enabled_on = true
			end
			if(not blink_enabled_on) then
				return
			end
		end
		local yoffset=1
		if self._bordered then 
			yoffset=2
		end
		if self._bordered then
			local x=max(self._x,1)
			local y=max(self._y,1)
			if(self._shadowed)then
				for i=-1, 1 do	
					print(self.text, x+i, self._y+2, self._sh)
				end
			end
			for i=-1, 1 do
				for j=-1, 1 do
					print(self.text, x+i, y+j, self._bg)
				end
			end
		elseif self._shadowed then
			print(self.text, self._x, self._y+1, self._sh)
		end
		print(self.text, self._x, self._y, self._fg)
    end
	return s
end

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
function circle_explo()
	local ex={}
	ex.circles={}
	function ex:explode(x,y)
		add(self.circles,{x=x,y=y,t=0,s=2})
	end
	function ex:multiexplode(x,y)
		local time=0
		add(self.circles,{x=x,y=y,t=time,s=rnd(2)+1 }) time-=2
		add(self.circles,{x=x+7,y=y-3,t=time,s=rnd(2)+1}) time-=2
		add(self.circles,{x=x-7,y=y+3,t=time,s=rnd(2)+1}) time-=2
		add(self.circles,{x=x,y=y,t=time,s=rnd(2)+1}) time-=2
		add(self.circles,{x=x+7,y=y+3,t=time,s=rnd(2)+1}) time-=2
		add(self.circles,{x=x-7,y=y-3,t=time,s=rnd(2)+1}) time-=2
		add(self.circles,{x=x,y=y,t=time,s=rnd(2)+1}) time-=2
	end
	function ex:update()
		for ex in all(self.circles) do
			ex.t+=ex.s
			if ex.t >= 20 then
				del(self.circles, ex)
			end
		end
	end
	function ex:draw()
		for ex in all(self.circles) do
			circ(ex.x,ex.y,ex.t/2,8+ex.t%3)
		end
	end
	return ex
end

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
    fillp() 
end
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
function menu_state()
    local state={}
	local texts={}
	music(0)
	add(texts, tutils({text="monster love",centerx=true,y=8,fg=8,bg=0,bordered=true,shadowed=true,sh=2}))
	add(texts, tutils({text="rombosaur studios",centerx=true,y=99,fg=9,sh=2,shadowed=true}))
	add(texts, tutils({text="made for the fantasy",centerx=true,y=60+10, fg=7,bg=1,shadowed=false, sh=7}))
	add(texts, tutils({text="console jam feb 2018" ,centerx=true,y=66+10, fg=7,bg=1,shadowed=false, sh=7}))
	add(texts, tutils({text="click to start", blink=true, on_time=15, centerx=true,y=88,fg=0,bg=1,shadowed=true, sh=7}))
	add(texts, tutils({text="v0.1", x=106, y=97}))
	local ypos = 111
	add(texts, tutils({text="  buttons  ", centerx=true, y=ypos, shadowed=true, fg=7, sh=0}))
    ypos+=10
	add(texts, tutils({text="  remap  ", centerx=true, y=ypos, shadowed=true, fg=7, sh=0}))
	local x1=28 
	local y1=128-19 
	local x2=128-x1-2 
	local y2=128 
	local frbkg=1
	local frfg=6
	local consume_click=false
	state.update=function()
		if(btnp(5) or (stat(34)==1))then
            consume_click=true 
		elseif consume_click then
			sfx(14)
			curstate=instructions_state()
        end
	end
	cls()
	state.draw=function()
		dance_bkg(10,frbkg)
		rectfill(3,2, 128-4, 104, 7)
		rectfill(2,3, 128-3, 103, 7)
		rectfill(4,3, 128-5, 103, 0)
		rectfill(3,4, 128-4, 102, 0)
		rectfill(5,4, 128-6, 102, frfg)
		rectfill(4,5, 128-5, 101, frfg)
		rectfill(25,97,  101, 111, frbkg)
		rectfill(24,98,  102, 111, frbkg)
		pset(23,104,frbkg)
		pset(103,104,frbkg)
        rectfill(x1,y1-1,  x2,y2+1, 0)
		rectfill(x1-1,y1,  x2+1,y2, 0)
		rectfill(x1,y1,  x2,y2, 6)
		local y=122
		rectfill(75-1,y+1-1, 120+1-8,y+1+1, 0)
		rectfill(121-1-8,y+1-1, 121+1-8,128+1, 0)
		rectfill(75,y+1, 120-8,y+1, 8)
		rectfill(121-8,y+1, 121-8,128, 8)
        for t in all(texts) do
            t:draw()
		end
	end
	return state
end
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
        anim_obj:add(0,2,0.2,1,1)  
        anim_obj:add(16,5,0.3,1,1) 
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)
        anim_obj:add(32,5,0.8,1,1,true,function() e.draw_wip=true end) 
        anim_obj:add(48,3,0.6,1,1,true,function() e.attacking=false end) 
        local bounds_obj=bbox(8,8)
        e:set_bounds(bounds_obj)
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
                        self:set_anim(2) 
                    else
                        self:set_anim(1) 
                    end
                end
                if btnp(4) or (stat(34)==1) and not self.attacking then 
                    self:set_anim(3)
                    self.state=self.states.wipping
                    self.mx=mousex
                    self.my=mousey
                    sfx(0)
                elseif btnp(5) or (stat(34)==2) then 
                    sfx(1)
                    self:set_anim(4)
                    self.attacking=true
                    for h in all(humans) do
                        if(sides_c(self, h)) h:hit() self.killed+=1 self.last_kill_tmr=0 kill_someone_hint=false sfx(2)
                    end
                end
                if(btn(0))then     
                    self:setx(self.x-self.speed)
                    self.flipx = true
                    self.left = true
                elseif(btn(1))then 
                    self:setx(self.x+self.speed)
                    self.flipx = false
                    self.right = true
                end
                if(btn(2))then          
                    self:sety(self.y-self.speed)
                    self.up = true
                elseif(btn(3))then  
                    self:sety(self.y+self.speed)
                    self.down = true
                end
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
                self.anger+=self.anger_step/2 
                sfx(15)
                if(self.anger > 100)then
                    self.anger = 100
                    kill_someone_hint=true
                end
            end
            circfill(self.x+3, self.y+7, 4, 9) 
            circfill(self.x+3, self.y+7, 3, 8) 
            circfill(self.x+3, self.y+7, 2,  0) 
            self.explo:update()
            self.explo:draw()
            self:_draw()
            circ(self.x+4, self.y+4, self.wip_length,  self.wip_radius_clr) 
            if self.draw_wip then
                local flipx=1
                local x0 = self.x+4
                local y0=self.y+4
                local sides = self.left or self.right
                local topbottom = self.up or self.down
                local dx = (self.x - self.mx)*-1
                local dy = (self.y - self.my)*-1
                local ang=atan2(dx,dy)
                if(dx <0) self.flipx=true else self.flipx=false
                local lx1=self.x+4+(cos(ang)*self.wip_length)
                local ly1=self.y+4+(sin(ang)*self.wip_length)
                local resolution=10
                local step=self.wip_length/resolution
                local curlen=step
                for i=1,resolution do 
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
                if not collides(target, square) then
                    local dista=sqrt( (target.x*target.x) + (target.y*target.y) )
                    local distb=sqrt( ((target.x-127)*(target.x-127)) + (target.y*target.y) )
                    local distc=sqrt( ((target.x-127)*(target.x-127)) + ((target.y-127)*(target.y-127)) )
                    local distd=sqrt( (target.x*target.x) + (target.y*target.y) )
                    self.destidx=4
                    if(dista >= distb and dista >= distc and dista >= distd)then
                        self.destidx=1
                    elseif(distb >= dista and distb >= distc and distb >= distd)then
                        self.destidx=2
                    elseif(distc >= dista and distc >= distb and distc >= distd)then
                        self.destidx=3
                    end
                    if(self.destsum)then
                        self.destidx+=self.destsum
                        self.destidx=(self.destidx % #self.dests)+1
                    end
                elseif (self.destx==-1 or self.desty==-1) then
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
                        self.destx=-1 self.desty=-1 
                    end
                else
                    self.dont_bust_my_chops=false
                end
            end
            circfill(self.x+3, self.y+7, 2,  0) 
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
        anim_obj:add(21,5,0.3,1,1) 
        anim_obj:add(37,4,0.5,1,1) 
        anim_obj:add(51,2,0.2,1,1) 
        anim_obj:add(53,2,0.2,1,1) 
        local e=entity(anim_obj)
        e:setpos(x,y)
        e:set_anim(1)
        local bounds_obj=bbox(8,8)
        e:set_bounds(bounds_obj)
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
                            self.des_tick=0
                            self:set_anim(2)
                            self.take_a_moment=true
                            self.take_a_moment_tmr=0
                        end
                    end
                    if(self.des_tick % 150 == 0 and not self.take_a_moment)then
                        sfx(4)
                        self:set_anim(4)
                        self.desoriented=true
                        self.des_tick=0
                        add(humans, self) 
                    end
                    self.sfx_fuse=true
                else
                    self.des_tick=0
                    self.take_a_moment_tmr+=1
                    if(self.take_a_moment_tmr > 10)then
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
            circfill(self.x+3, self.y+7, 2,  0) 
            circfill(self.x+3, self.y+7, 1,  8) 
            self:_draw()
        end
        function e:hit()
            if(self.desoriented)then
                shake=3
                self.alive=false
                target.score+=100
                target.anger-=target.anger_step
                self.explo:explode(self.x, self.y)
                spawn_human()
                spawn_human()
            end
        end
        return e
    end
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
        end
        return e
    end
    square=persecution_square(24,39) 
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
    for i=1,7 do
        spawn_human()
    end
    local first=true
    local lastHuman=0
    local gameover_fuse=false
    local alarm_sfx_fuse=true
    s.update=function()
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
        for h in all(humans) do
            if not h.alive then
                del(humans, h)
                del(drawables, h)
            end
        end
        h:gamepad()
        if(not(h.killed == lastHuman))then
            if(h.killed % 2 == 0)then
                lastHuman=h.killed
                spawn_human()
                spawn_human()
            end
            if(h.killed % 3 == 0)then
                add(drawables, police(64, 130, h))
                lastHuman=h.killed
            end
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
        rectfill(0,0, 127,8, 0)
        anger:draw()
        fillp()
        rectfill(anger_barx-1,1,  full_bar+1                    , 7, 7) 
        fillp(0b0101101001011010)
        rectfill(anger_barx  ,2,  full_bar                      , 6, 5) 
        fillp()
        rectfill(anger_barx  ,2,  anger_barx+h.anger/anger_div  , 6, 8) 
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
function gameover_state()
    local s={}
    local texts={}
    local frbkg=8
    local frfg=6
    music(-1)
    sfx(-1)
    local ty=15
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=10
    add(texts, tutils({text="                         " ,centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2}))ty+=10
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=10
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=10
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=20
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=10
    add(texts, tutils({text="press ❎ to restart", blink=true, on_time=15, centerx=true,y=110,fg=0,bg=1,bordered=false,shadowed=true,sh=7}))
    s.update=function()
        if(btnp(5)) curstate=game_state() 
    end
    cls()
    s.draw=function()
        dance_bkg(10,frbkg)
        local frame_x0=10	
        local frame_y0=10
        local frame_x1=128-frame_x0	
        local frame_y1=128-frame_y0
        rectfill(frame_x0  ,frame_y0-1, frame_x1, frame_y1  , 7)
        rectfill(frame_x0-1,frame_y0+1, frame_x1+1, frame_y1-1, 7)
        rectfill(frame_x0+1,frame_x0  , frame_x1-1, frame_y1-1, 0)
        rectfill(frame_x0  ,frame_x0+1, frame_x1  , frame_y1-2, 0)
        rectfill(frame_x0+2,frame_x0+1, frame_x1-2, frame_y1-2, frfg)
        rectfill(frame_x0+1,frame_x0+2, frame_x1-1, frame_y1-3, frfg)
        for t in all(texts) do
            t:draw()
        end
    end
    return s
end
function win_state()
    local s={}
    local texts={}
    local frbkg=11
    local frfg=6
    music(-1)
    sfx(-1)
    local ty=15
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=10
    add(texts, tutils({text="                         " ,centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2}))ty+=10
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=10
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=10
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=20
    add(texts, tutils({text="                         ",centerx=true,y=ty,fg=8,bg=0,bordered=true,shadowed=true,sh=2})) ty+=10
    add(texts, tutils({text="press ❎ to restart", blink=true, on_time=15, centerx=true,y=110,fg=0,bg=1,bordered=false,shadowed=true,sh=7}))
    s.update=function()
        if(btnp(5)) curstate=menu_state() 
    end
    cls()
    s.draw=function()
        dance_bkg(10,frbkg)
        local frame_x0=10	
        local frame_y0=10
        local frame_x1=128-frame_x0	
        local frame_y1=128-frame_y0
        rectfill(frame_x0  ,frame_y0-1, frame_x1, frame_y1  , 7)
        rectfill(frame_x0-1,frame_y0+1, frame_x1+1, frame_y1-1, 7)
        rectfill(frame_x0+1,frame_x0  , frame_x1-1, frame_y1-1, 0)
        rectfill(frame_x0  ,frame_x0+1, frame_x1  , frame_y1-2, 0)
        rectfill(frame_x0+2,frame_x0+1, frame_x1-2, frame_y1-2, frfg)
        rectfill(frame_x0+1,frame_x0+2, frame_x1-1, frame_y1-3, frfg)
        for t in all(texts) do
            t:draw()
        end
    end
    return s
end
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
        spr(64, mx, my , 3,3) 
    end
    return s
end
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
        line(20, 61, 107, 61, 7) 
        for d in all(drawables) do
            d:draw()
        end
    end
    return s
end
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
    local btmx=50
    local btmy=119
    add(drawables, tutils({text="click to continue", x=btmx, y=btmy, fg=8, bg=7, bordered=true}))
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
__gfx__
00333300003333000004444000444440000444000044444000444440000aaaa0000aaaa0000aaa0000aaaaa0000aaaa00ddddddddddddddddddddddddddddddd
00373700003737000044f700004f7f000047f7400447f700004f7f0000aaf70000af7f0000a7f7a00aa7f7a000af7f00dddddddddddddddddddddddddddddddd
0033330000333300004fff00004fff000f4fff00004fff00004fff0000afff0000afff000fafff0000afff0000afff00dddddddddddddddddddddddddddddddd
00133100011331100f0ff0f0000fff0000cff0f00f0ff000000fff000faff0f000afff000acffaf00faffa0000afff00dddddddddddddddddddddddddddddddd
011111100111111000cccc00000ccc00000ccc0000ccccf0000ccc0000cccc0000accc000aaccc0000ccccf000accc00dddddddddddddddddddddddddddddddd
0111111003555530000cc000000cc000000cc000000cc000000cc00000aee00000aee00000aee0000aaee0000aaee000dddddddddddddddddddddddddddddddd
0355553000500500000666000006600000065500006655000006600000eeee000a0ee000000ee50000eee500000ee000dddddddd0ddddddddddddddddddddddd
0050050000500500005506000005600000660000000005000005600000550e000005e00000ee0000000005000005e000ddddddddddddddddd0dddddddddddddd
000333000003330000333300003333000003330000011116001111100011111000111110000111100aaa000007070000dddddddddddddddddddddddddddddddd
00033700000373000037370000373700000373000011170600117f000117f7000117f70000117f000a8a000078787000ddddddddddddddddddddddd0dddddddd
0003330000033300003333000033330000033300001fff06001fff06011fff00011fff00001fff000a8a000078887000dddddddddddddddddddddddddddddddd
0003303000033000000330000003303000033000000ff0f0000ff060000ff006000ff0f0000ff000aaaaa00007870000dddddddddddddddddddddddddddddddd
00111100000113000001100000011100000113000011110000011f00000110600001110000011f66aa8aa00000700000dddddddddddddddddddddddddddddddd
03011000003110000001300000311000003110000f01a00000f1a0000001f60000f1a00000f1a000aaaaa00000000000dddddddddddddddddddddddddddddddd
000666000006600000065500006655000006600000066600000660000006550006665500000660000000000000000000dddddddddddddddddddddddddddddddd
005506000005600000660000000005000005600000550600000560000066000060000500000560000000000000000000ddddddddddddddd0dddddddddddddddd
003333000000000000000000000333000003330001111006011110000111100001111000000000000000000000000000dddddddd0ddddddddddddddddddddddd
003737000033330000333300000373000003370011f7006017f7000017f7000017f70000000770000000000000000000dddddddddddddddddddddddddddddddd
0033330000373700b03737000003b3000003330011ff06001fff00061fff00001fff0000077007700007700000000000dddddd0ddddddddddddddddddddd0ddd
00133100003333000133330000013100000111100ff060000ff000600ff000000ff000007007a007077a777000000000ddddddddddddddddddddddddddddd0dd
0011111001111110011111000001110000011100011f0000011006001110000011100000700a70070777a77000000000dddddddddddddddddddddddddddddddd
00111110b011110000111100000111000005550001100000011f60000f6000000f600000077007700007700000000000dddddddddddddddddddddddddddddddd
00b5553000555500005555000005550000050500065500000655000006560000065600000007700000000000000000000ddddddddddddddddddddddddddddddd
000505000005050000050500000505000005050060050000600500006005600060056000000000000000000000000000dddddddddddddddddddddddddddddddd
00033388003333a000333300001111000011110001111100000000000000000000000000000000000000000077700000dddddddddddddddddd0ddddddddddddd
00037310003737090073730a017f7000f17f700f017f7100011111000000000000000000000110000000000075700000dddddddddddddddddddddddddddddddd
00033310003333080033330a01fff0f011fff00101fff100017f71000000000000000000001881000007070077577000dddddddddddddddddddddddddddddddd
000331100013311001133109f0ff010001ff001000ff000001fff1000000000000000000018dd8100000700075757000dddddddddddddddddddddddddddddddd
0111110001111100011111990111100001111100001100000f11f0000000000000000000018dd8100887888055777000dddddddddddddddddddddddddddddddd
01111100011111000311190000110000001100000f11f000601100000000000000000000001881000887888000570057ddddddddddddddddd0dddddddddddddd
0355550003555500005885000065500000655000606600006066000000000000000000000001100000e7ee0000575757dddddddddddddddddddddddddddddddd
0050050000500500005005000600500006005000606600000066000000000000000000000000000000e7ee0000057575dddddddddddddddddddddd00ddddddd0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbbbbbbbb000000000000000aaaa00000000000000000000444400000000000000000000444400000000000000000000333300000000000000000
0000b00000000000000000000000000aaaaaaaaaaaa0000000000004444444444440000000000004444444444440000000000003333333333330000000000000
0000b000000000000000000000000aaaaaaaaaaaaaa0000000000444444444444440000000000444444444444440000000000333333333333330000000000000
000bbbbb3333300000000000000aaaaaaaaaaaafffaa0000000444444444444fff440000000444444444444fff440000000333333333333bbb33000000000000
00bbbbbb333333000000000000aaaaaaaaaaaaffffaaa00000444444444444ffff44400000444444444444ffff44400000333333333333bbbb33300000000000
0bbbbbbb33333333333300000aaaaaaaaaaaaffffffaaa000444444444444ffffff444000444444444444ffffff444000333333333333bbbbbb3330000000000
bbbbbbbb33333333000000000aaaaaaaaaafffffffffaaa00444ffffffffffffffff44400444ffffffffff9fffff44400333bbbbbbbbbb3bbbbb333000000000
bbbbbbbb3333333300000000aaaaafaaaaffffaaaaffaaa0444fff4444ffff4444ff4440444ffff4ff9ff9ff4fff4440333bbbb3bb3bb3bb3bbb333000000000
7bbbbbbb3333333700000000aaaafaf777ffff777fafaaaa44fff4f777ffff777f4f444444fffff444f99f444fff444433bbbbb333b33b333bbb333300000000
7bbbbbbb3333333700000000affffff7c7ffff7c7fffaaaa4ffffff717ffff717fff44444ffffffff449f44fffff44443bbbbbbbb333b33bbbbb333300000000
7bbbbbbb3333333700000000affffff777ffff777fffaaaa4ffffff777ffff777fff44444ffffff7174ff4717fff44443bbbbbb7173bb3717bbb333300000000
7bbbbbbb3333333700000000affffffffffffffffffffaaa4ffffffffffffffffffff4444ffff9ffffffffffff9ff4443bbbb3bbbbbbbbbbbb3bb33300000000
777777777777777700000000affffffffffffffffffffaaa4ffffffffffffffffffff4444fffff9999ffff9999fff4443bbbbb3333bbbb3333bbb33300000000
777777777777777700000000affffffffffffffffffffaaa4ffffffffffffffffffff4444ffffffffffffffffffff4443bbbbbbbbbbbbbbbbbbbb33300000000
777777777777777700000000aaffffffff9999fffffffaaa44ffffffff9999fffffff44444ffffffff9999fffffff44433bbbbbbbb3333bbbbbbb33300000000
777777777777777700000000aafffffffff99ffffffffaaa04fffffffff99ffffffff44004fff9fffff99fffff99f44003bbb3bbbbb33bbbbb33b33000000000
777777777777777700000000aa9ffffffffffffffffffaaa000ffffffffffffffffff400000ff99ff444444ff999f400000bb33bbbbbbbbbb333b30000000000
777777777777777700000000aa9ffffffffffffffffffaaa000ffffffffffffffffff000000fff9f47777774ff9ff000000bbb3bb777777bbb3bb00000000000
077777777777777000000000aa99ffffffffffffffff9aaa0000ffffffffffffffff00000000ffff41111114ffff00000000bbbbb111111bbbbb000000000000
077777777777777000000000aa999ffffffffffffff99aaa00000ffffffffffffff0000000000fff47777774fff0000000000bbbb777777bbbb0000000000000
007777777777770000000000aa9999ffffffffffff999aaa000000ffffffffffff000000000000fff4777774ff000000000000bbbb77777bbb00000000000000
000777777777700000000000aa99999ffffffffff9999aaa0000000ffffffffff00000000000000fff44444ff00000000000000bbbbbbbbbb000000000000000
000007777770000000000000aa9999999999999999999aa000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880000888888000000000000440000044440000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008008118008111111800000000004114000411114000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880008118008111111804444440004114000411114000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008118000888888000000000004114000044440000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008118000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0f0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1f1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2f2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3f3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f0c0d0e0f0d0e0f1d0c0d0e0f0f0d0e0f0c0d0e0f0d0e0f1d0c0d0e0f0c0d0e0f0c0d0e0f0d0e0f1d0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f1c1d1e1f1d1e1f2d1c1d1e1f1f1d1e1f1c1d1e1f1d1e1f2d1c1d1e1f1c1d1e1f1c1d1e1f1d1e1f2d1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2e2f2c2d2e2f2d2e2f3d2c2d2e2f2f2d2e2f2c2d2e2f2d2e2f3d2c2d2e2f2c2d2e2f2c2d2e2f2d2e2f3d2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f3c0c0d0e0f3e0c0d0c0d0e0f0f0d0e0f3c0c0d0e0f3e0c0d0c0d0e0f0c0d0e0f3c0c0d0e0f3e0c0d0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f1e1c1d1e1f0f1c1d1c1d1e1f1f1d1e1f1e1c1d1e1f0f1c1d1c1d1e1f1c1d1e1f1e1c1d1e1f0f1c1d1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2e2f0c2c2d2e2f1f2c2d2c2d2e2f2f2d2e2f0c2c2d2e2f1f2c2d2c2d2e2f2c2d2e2f0c2c2d2e2f1f2c2d2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3e3f1c3c3d3e3f2f3c3d3c3d3e3f3f3d3e3f1c3c3d3e3f2f3c3d3c3d3e3f3c3d3e3f1c3c3d3e3f2f3c3d3c3d3e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f0e0f0d0e0f0e0f2d0c0d0e0f0f0d0e0f0e0f0d0e0f0e0f2d0c0d0e0f0c0d0e0f0e0f0d0e0f0e0f2d0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f1e0c0d0e0f1e1f3d0c0d0e0f0f0d0e0f1e0c0d0e0f1e1f3d0c0d0e0f0c0d0e0f1e0c0d0e0f1e1f3d0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f2e1c1d1e1f2e2f1f1c1d1e1f1f1d1e1f2e1c1d1e1f2e2f1f1c1d1e1f1c1d1e1f2e1c1d1e1f2e2f1f1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2e2f3e2c2d2e2f3e3f2f2c2d2e2f2f2d2e2f3e2c2d2e2f3e3f2f2c2d2e2f2c2d2e2f3e2c2d2e2f3e3f2f2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3e3f3c3c3d3e3f3e3f3f3c3d3e3f3f3d3e3f3c3c3d3e3f3e3f3f3c3d3e3f3c3d3e3f3c3c3d3e3f3e3f3f3c3d3e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f3c3d3e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f0c0d0e0f0d0e0f1d0c0d0e0f0c0d0e0f0c0d0e0f0d0e0f1d0c0d0e0f0c0d0e0f0c0d0e0f0d0e0f1d0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f1c1d1e1f1d1e1f2d1c1d1e1f1c1d1e1f1c1d1e1f1d1e1f2d1c1d1e1f1c1d1e1f1c1d1e1f1d1e1f2d1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2e2f2c2d2e2f2d2e2f3d2c2d2e2f2c2d2e2f2c2d2e2f2d2e2f3d2c2d2e2f2c2d2e2f2c2d2e2f2d2e2f3d2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f3c0c0d0e0f3e0c0d0c0d0e0f0c0d0e0f3c0c0d0e0f3e0c0d0c0d0e0f0c0d0e0f3c0c0d0e0f3e0c0d0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f1e1c1d1e1f0f1c1d1c1d1e1f1c1d1e1f1e1c1d1e1f0f1c1d1c1d1e1f1c1d1e1f1e1c1d1e1f0f1c1d1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2e2f0c2c2d2e2f1f2c2d2c2d2e2f2c2d2e2f0c2c2d2e2f1f2c2d2c2d2e2f2c2d2e2f0c2c2d2e2f1f2c2d2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3e3f1c3c3d3e3f2f3c3d3c3d3e3f3c3d3e3f1c3c3d3e3f2f3c3d3c3d3e3f3c3d3e3f1c3c3d3e3f2f3c3d3c3d3e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f0e0f0d0e0f0e0f2d0c0d0e0f0c0d0e0f0e0f0d0e0f0e0f2d0c0d0e0f0c0d0e0f0e0f0d0e0f0e0f2d0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0e0f1e0c0d0e0f1e1f3d0c0d0e0f0c0d0e0f1e0c0d0e0f1e1f3d0c0d0e0f0c0d0e0f1e0c0d0e0f1e1f3d0c0d0e0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f2e1c1d1e1f2e2f1f1c1d1e1f1c1d1e1f2e1c1d1e1f2e2f1f1c1d1e1f1c1d1e1f2e1c1d1e1f2e2f1f1c1d1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2e2f3e2c2d2e2f3e3f2f2c2d2e2f2c2d2e2f3e2c2d2e2f3e3f2f2c2d2e2f2c2d2e2f3e2c2d2e2f3e3f2f2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3e3f3c3c3d3e3f3e3f3f3c3d3e3f3c3d3e3f3c3c3d3e3f3e3f3f3c3d3e3f3c3d3e3f3c3c3d3e3f3e3f3f3c3d3e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000265001650016500165003650066500b6501465020650326503a6503d6203c6503d650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000f6500e6500c6500765001650016000160001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b0502b0502c0502b05028050240502005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000b0501955008550095501105008650086500865016050205500e5500c6500c65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003525030200302300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001b2500000011250000000c2500c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00002e1500000024150000002b15000000291500000035150000002e150000001f15000000161500000016050000001605000000000000000000000000000000000000000000000000000000000000000000
001000002b3302b33000000000002b3302b33000000000002b3302b33000000000002b3302b330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000f1500f1500f150241002210000000161101d1502b1502715000000271502715024150000000000011150111501115000000000001d1501f15024150000001d150221501d15000000131500000013150
000d000027050350503c050290503705037050290503705035050270500000027050000002e05030050270502e05035050350502905037050370503a050000002905030050000002705000000000000000000000
01100000070500000007050000000000000000001500000000000000000b050000000b0500e050000000e05009050000000905000000001500000009050000000b05000000070500000000150090500b05000000
011000001f2700000013270000000000000000000000000000000000002325000000172501a250002001a25015250002002125000200002000020015250002002325000200132500020000200212501725000000
010800001c1001c1001c100000001c1321c1321c142000001c1001c1001c100000001c1321c1321c142000001c1321c1321c142000001c1001c1001c100000001c1001c1001c100000001c1321c1321c14200000
010800000000023152231521f15200000000000000000000000001c15200000000002310023100211521f10021152231001f1521c10024152231001315021100181501f100211501f1002b150231002815000000
000200000b6500b6500b6500a6500a6500c6500f6501165011650136501665021650276502b650346503f6503f600000000000000000000000000000000000000000000000000000000000000000000000000000
001000000f25000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 0a0b0c4c

