------------------------------------移速系统----------------------------------------
-- 如果按照最直接逻辑而言，应该修改 walkspeed 和 runspeed ，通过修改player_classified实现
-- 但是修改player_classified也不能完美解决mod兼容问题
-- 因为没有办法去解决其他mod直接修改数值的问题
-- 我不知道饥荒如何去hook一个参数的修改
-- 如果想要完美兼容，又要增加更多的复杂度
-- 所以退而求其次，仅仅考虑 externalspeedmultiplier 来同步移速
-- 因为这个参数的修改较为独立，几乎所有代码都会经过其api
-- 虽然这样对于一些mod的特效就不能完美兼容了，但这是最好的结果了
-----------------------------------------------------------------------------------
-- 公式推导：
-- 假设我们处于游戏内的某一时刻，
-- 显然此时 runspeed 是一个定量，设为 speed ，而游戏内的 externalspeedmultiplier 在此刻也是固定的，设为 mult
-- 我们可以获取属性系统提供的额外移速 extraspeed，设为 extra
-- 游戏内默认计算移速的函数形式： speed * mult
-- 我们期望的计算移速的函数形式： (speed + extra ) * mult
-- 在假设游戏这个计算公式不被改变的情况下，我们可以不改变speed，而去改变mult来实现速度的变化
-- 让改变speed的结果与改变mult的结果相同
-- 即： (speed + extra ) * mult = speed * multi'
-- 得： multi' = mult * ( 1 + extra/speed )
-- 于是我们得到修正后的 multi'

AddComponentPostInit("locomotor", function(self)

	self.date_canmove = true
	self.date_canmovelist = {}
	self.dota_extraspeed = 0
	
    local old_RecalculateExternalSpeedMultiplier = self.RecalculateExternalSpeedMultiplier	-- 获取原函数
    function self:RecalculateExternalSpeedMultiplier(sources)
		if self.runspeed <= 0 then return old_RecalculateExternalSpeedMultiplier(self, sources) end	-- runspeed不可控，所以遇到除法就得谨慎一点
		local mult = old_RecalculateExternalSpeedMultiplier(self, sources)
		-- print("[locomotor] dota_extraspeed: " .. self.dota_extraspeed .. "  runspeed: " .. self.runspeed .. "  mult: " .. mult)
		return mult * ( 1 + self.dota_extraspeed / self.runspeed )
    end

    -- 重新计算一下修正后的 mult，然后通过 player_classified 同步
    function self:Dota_UpdateRunSpeed(val)
		if val then
			self.dota_extraspeed = val
		else
			self.dota_extraspeed = self.inst.components.dotaattributes and self.inst.components.dotaattributes.extraspeed:Get()
		end
        self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
    end

    local old_walkforward = self.WalkForward
	function self:WalkForward(direct)
		if self.date_canmove then
			return old_walkforward(self, direct)
		end
    end

    local old_runforward = self.RunForward
	function self:RunForward(direct)
		if self.date_canmove then
			old_runforward(self, direct)
			if self.dotafly_height_override ~= 0 then
				local a,b,c = self.inst.Physics:GetMotorVel()
				local y = self.inst:GetPosition().y
				-- 起飞时设置的飞行高度
				local h = self.inst.components.dotafly and self.inst.components.dotafly:GetHeight()
				if y and h then
					self.inst.Physics:SetMotorVel(a, (h-y)*32, c)
				end
			end
		end
    end

	local old_update = self.OnUpdate
	function self:OnUpdate(dt)
		if self.date_canmove then
			return old_update(self, dt)
		end
	end
	
	function self:Dota_CanMove(val, source)
		source = source or "default"
		self.date_canmovelist[source] = val
		local tmp = true
		for k, v in pairs(self.date_canmovelist) do
			if not v then
				tmp = false
				break
			end
		end
        self.date_canmove = tmp
        if tmp then
            self:StartUpdatingInternal()
		else
			self:StopMoving()
        end
    end
end)