------------------------------------生命系统----------------------------------------
-- 有些mod的人物生命值是在人物初始化之后再计算的，也有一些升级mod会在升级后重置生命值
-- 因此涉及生命值的时候，我们想要正确更新生命时，这个问题就令人头疼
-- 当作者是通过科雷提供的接口改变生命值，那么兼容性可以很轻易地解决
-- 但当作者通过直接更改 self.maxhealth 来修改血量时，这个问题就很棘手
-- 会出现2种情况
-- 第一种：作者通过 基础值 + 附加值 的形式修改血量
-- 第二种：作者通过 现有血量 + 附加值 的形式修改血量（比如机器人）
-- 对于第一种，新的基础值 = 人物现有血量
-- 对于第二种，新的基础值 = 人物现有血量 - 装备加成血量
-- 在没去详细查看mod前，我们无法判断哪一种才是作者使用的方法，也没有方法去分辨两种情况
-- 甚至存在可能，装备加成与附加值相等，以至于我们无法分辨两者情况
-- 对于这种情况，我们不可能面面俱到，只能考虑一种情况
-- 如果多种情况同时存在时，只能手动指定一种兼容方式，或者放弃兼容
-------------------------------------------------------------------------------------
-- 虽然我很想兼容，但无能为力，因为无法强制要求每一位作者用相同的写法
-- 我只能想办法兼容做法相仿的mod
-------------------------------------------------------------------------------------
-- 为了保留其他mod的特色，我们尽量采用原函数进行结算，避免影响其他mod
-------------------------------------------------------------------------------------

local health_system = GetModConfigData("health_system")
local HEALTH_REGEN_TOTALTIME = TUNING.DOTA.HEALTH_REGEN_TOTALTIME
	
-- 特殊缩进
if not health_system then

-- 配置一个health，把暴露的额外接口全部放空，用于加载空的生命系统
AddComponentPostInit("health", function(self, inst)
	function self:Dota_SetCompatibility(amount) end
	function self:Dota_UpdateDefaultHealth(amount) end
	function self:Dota_SetMaxHealthWithPercent(amount) end
	function self:Dota_UpdateHealthRegen(regen, healthregenamp) end
	function self:Dota_UpdateHealthAMP(healedamp, decrhealedamp, decrhealthregenamp) end
	function self:DotaStartRegen(amount, period, interruptcurrentregen) end
	function self:DotaStopRegen() end
	function self:Dota_SetProtect(val) end
	function self:Dota_IsProtect() return false end
end)

else

AddComponentPostInit("health", function(self, inst)	
	self.dota_isextrehealth = false	-- 装备提供的额外血量是否已经纳入计算
	self.dota_lastmaxhealth = 100 -- 记录上一次调用SetMaxHealth时设置的最大血量 -- 用这个参数保证我们每次更新装备血量加成时的基础血量是不变的
	self.dota_extrehealth = 0	-- 装备提供的额外血量
	self.dota_compatibility = TUNING.DOTA.HEALTH_COMPATIBILITY or 1	-- 兼容性选择

	self.dota_healedamp = 0				-- 接受的治疗增强    
	self.dota_decrhealedamp = 0			-- 接受的治疗降低
	self.dota_healthregenamp = 0		-- 生命恢复增强
	self.dota_decrhealthregenamp = 0	-- 生命恢复降低
	self.dota_protect = false

	----------------------------------------------------
	------------------- SetMaxHealth -------------------
	----------------------------------------------------
	-- 我们可以通过设置元表来简化这部分函数，但这解决不了核心问题，仅可能在优化上有进步，但我甚至还没验证过
	-- 因此此处就不考虑元表，仅根据文件开头的阐述来写这个函数
    local old_SetMaxHealth = self.SetMaxHealth
	function self:SetMaxHealth(amount)
		if self.inst.components.dotaattributes ~= nil then
			self.dota_lastmaxhealth = amount	-- 记录调用SetMaxHealth时设置的值

			if self.maxhealth ~= self.dota_lastmaxhealth + self.dota_extrehealth then	-- 最大生命值与预期不符，触发修正部分
				-- self.dota_isextrehealth = false
				if self.dota_compatibility == 1 then	-- 兼容性选择
					self.dota_lastmaxhealth = self.maxhealth
					self.dota_extrehealth = 0
				elseif self.dota_compatibility == 2 then	-- 兼容性选择
					self.dota_lastmaxhealth = self.maxhealth - self.dota_extrehealth
					if self.dota_lastmaxhealth <= 0 then 
						self.dota_compatibility = 1 
						self.dota_lastmaxhealth = self.maxhealth
						self.dota_extrehealth = 0
					end
				else
					old_SetMaxHealth(self, amount)	-- 如果没有指定兼容性，那最好返回原函数避免报错出现
					return
				end
				-- 在更新了默认最大值后，重新执行一次函数，根据上部分的公式计算，此处理论上不会再触发这部分修正函数
				-- 但由于mod加载顺序的问题，可能由于其他低优先级mod同时修改该部分，导致循环触发卡机，该部分暂时存疑
				self:Dota_UpdateDefaultHealth()
				return
			end

			local extrehealth = self.inst.components.dotaattributes.extrahealth:Get()	-- 获取装备提供的额外血量
			if extrehealth ~= nil then 
				-- self.dota_isextrehealth = true	 -- 装备提供的额外血量已经纳入计算
				self.dota_extrehealth = extrehealth
				old_SetMaxHealth(self, amount + extrehealth)	-- 执行旧的函数，只不过加上了装备加成
				return
			end
		end
		if old_SetMaxHealth then
			old_SetMaxHealth(self, amount)
		end
	end

	----------------------------------------------------
	--------------------- DoDelta ----------------------
	----------------------------------------------------
    local old_DoDelta = self.DoDelta
	function self:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		if amount and amount > 0 then
			amount = amount * (1 + self.dota_healedamp) * (1 - self.dota_decrhealedamp) * (1 - self.dota_decrhealthregenamp)
		elseif self.dota_protect then
			return 0
		end
		if old_DoDelta then
			return old_DoDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		end
	end
	----------------------------------------------------
	---------------- Dota_LimitDelta -------------------
	----------------------------------------------------
	-- 为生物造成非致命伤害
	function self:Dota_LimitDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		if self.dota_protect then
			return 0
		end
		
		amount = math.min(amount, self.currenthealth - 1)
		if old_DoDelta then
			return old_DoDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		end
	end

	-- local old_SetVal = self.SetVal
	-- function self:SetVal(val, cause, afflicter)
		-- if self.inst:HasTag("player") then
			-- print("debug old_SetVal")
			-- if val then print(val) end
			-- if cause then print(cause) end
			-- if afflicter then print(afflicter) end
		-- end
		-- return old_SetVal(self, val, cause, afflicter)
	-- end
	----------------------------------------------------
	--------------- Dota_SetCompatibility --------------
	----------------------------------------------------
	-- 设置生命兼容性选项
	function self:Dota_SetCompatibility(amount)
		if amount ~= nil then self.dota_compatibility = amount end
	end

	----------------------------------------------------
	--------------- Dota_UpdateDefaultHealth --------------
	----------------------------------------------------
	-- 设置最大生命值基础值
	function self:Dota_UpdateDefaultHealth(amount)
		if amount then 
			self.dota_lastmaxhealth = amount
		end
		self:Dota_SetMaxHealthWithPercent(self.dota_lastmaxhealth)
	end

	----------------------------------------------------
	------------- Dota_SetMaxHealthWithPercent --------------
	----------------------------------------------------
	-- 设置最大生命值的同时等比例设置当前生命值
	function self:Dota_SetMaxHealthWithPercent(amount)
        local percent = self:GetPercent()
		self:SetMaxHealth(amount)
		self:SetPercent(percent)
	end

	----------------------------------------------------
	------------------ Dota_Update-----------------------
	----------------------------------------------------
	function self:Dota_UpdateHealthRegen(regen, healthregenamp)
		if healthregenamp ~= nil then
			self.dota_healthregenamp = healthregenamp
		elseif self.inst.components.dotaattributes ~= nil then
			self.dota_healthregenamp = self.inst.components.dotaattributes.healthregenamp:Get()
		end
		regen = regen or self.inst.components.dotaattributes.healthregen:Get() or 0
		if regen ~= 0 then
			local period = TUNING.DOTA.HEALTH_REGEN_INTERVAL
			local amount = (regen * period)/HEALTH_REGEN_TOTALTIME
			self.inst.components.health:DotaStartRegen(amount, period, false)
		else
			self.inst.components.health:DotaStopRegen()
		end
	end

	function self:Dota_UpdateHealthAMP(healedamp, decrhealedamp, decrhealthregenamp)
		if healedamp and decrhealedamp and decrhealthregenamp then
			self.dota_healedamp = healedamp				-- 接受的治疗增强    
			self.dota_decrhealedamp = decrhealedamp			-- 接受的治疗降低
			self.dota_decrhealthregenamp = decrhealthregenamp	-- 生命恢复降低
		elseif self.inst.components.dotaattributes ~= nil then
			self.dota_healedamp = self.inst.components.dotaattributes.healedamp:Get()				
			self.dota_decrhealedamp = self.inst.components.dotaattributes.decrhealedamp:Get()			
			self.dota_decrhealthregenamp = self.inst.components.dotaattributes.decrhealthregenamp:Get()	
		end
	end

	----------------------------------------------------
	------------------ DotaProtect ---------------------
	----------------------------------------------------
	function self:Dota_SetProtect(val)
		self.dota_protect = val
	end

	function self:Dota_IsProtect()
		return self.dota_protect
	end

	----------------------------------------------------
	------------------ DotaStartRegen ------------------
	----------------------------------------------------
	-- 官方代码，我们复制一份，防止其他mod也调用了startregen导致预期效果冲突
	local function DotaDoRegen(inst, self)
		if not self:IsDead() then
			self:DoDelta(self.dotaregen.amount, true, "dotaregen")
		end
	end
	
	function self:DotaStartRegen(amount, period, interruptcurrentregen)
		if interruptcurrentregen ~= false then
			self:DotaStopRegen()
		end
	
		if self.dotaregen == nil then
			self.dotaregen = {}
		end
		self.dotaregen.amount = amount * (1 + self.dota_healthregenamp)
		self.dotaregen.period = period
		-- print("[debug] [DotaDoRegen] amount:"..amount.." dota_healthregenamp:"..self.dota_healthregenamp.." period:"..period)
		if self.dotaregen.task == nil then
			self.dotaregen.task = self.inst:DoPeriodicTask(self.dotaregen.period, DotaDoRegen, nil, self)
		end
	end
	
	function self:DotaStopRegen()
		if self.dotaregen ~= nil then
			if self.dotaregen.task ~= nil then
				--print("   stopping task")
				self.dotaregen.task:Cancel()
				self.dotaregen.task = nil
			end
			self.dotaregen = nil
		end
	end

	----------------------------------------------------
	------------------- Save / Load --------------------
	----------------------------------------------------
	local old_OnSave = self.OnSave
    function self:OnSave()
		local data = old_OnSave(self)
		if data ~= nil then
			data.dota_compatibility = self.dota_compatibility
			-- data.dota_avatar = self.dota_avatar
		end
		return data
	end
	
	local old_OnLoad = self.OnLoad
	function self:OnLoad(data)
		if data and data.dota_compatibility ~= nil then
			self.dota_compatibility = data.dota_compatibility
		end
		-- if data and data.dota_avatar ~= nil then
		-- 	self.dota_avatar = data.dota_avatar
		-- end
		old_OnLoad(self, data)
	end

end)

-- -- 生命值刷新
-- local function HealthReflash(inst)
	-- if not inst:HasTag("playerghost") then	-- 当然了，幽灵刷新什么血量
		-- -- 部分角色在初始化时，后续升级时，都不会调用SetMaxHealth，我们不希望装备加成失败，所以确认一下此时的装备加成是否已经应用
		-- if not inst.components.health.dota_isextrehealth then	-- 当装备加成没有在SetMaxHealth中用上时
			-- local maxhealth = inst.components.health.maxhealth or 100	-- 获取原先的最大血量
			-- inst.components.health:Dota_UpdateDefaultHealth(maxhealth)	-- 重新输入这个值来计算一下计算装备加成
		-- end
		-- inst.components.health:ForceUpdateHUD(true)	-- 更新一下
	-- end
-- end

-- AddPlayerPostInit(function(inst)
	-- if GLOBAL.TheWorld.ismastersim then
		-- if inst.components.dotaattributes ~= nil then
			-- inst:DoTaskInTime(0.1, HealthReflash)	-- 在人物初始化0.1s后刷新一下生命值
		-- end
		-- return inst
	-- end
-- end)

end