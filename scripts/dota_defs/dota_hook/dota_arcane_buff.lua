-----------------------------------------------------------------------
-- 此lua写法出自老王天天写bug的晓美焰[workshop-1837053004]
-- 来源 /modmain/snowpea.lua
-----------------------------------------------------------------------

-------------------------------------------------秘奥闪光 or 智力跳-------------------------------------------------

-- Linking
local links = {} -- key = AnimState, value = Entity
local function GetEntity(anim)
	return anim ~= nil and links[anim]
end

local function NewLink(anim, inst)
	if inst:IsValid() then
		links[anim] = inst
		inst:ListenForEvent("onremove", function() links[anim] = nil end)
	end
end

local old_add = Entity.AddAnimState
---@diagnostic disable-next-line: duplicate-set-field
Entity.AddAnimState = function(ent, ...)
    local inst = Ents[ent:GetGUID()] -- Get lua instance
    if GetEntity(inst and inst.AnimState) then
    	links[inst.AnimState] = nil
    end
    local anim = old_add(ent, ...)
    NewLink(anim, inst)
    return anim
end

function AnimState.Dota_UpdateDeltaTimeMultiplier(anim, val)
	local inst = GetEntity(anim)
	if inst then
		inst.dota_arcane_timemult = val or 1
		anim:SetDeltaTimeMultiplier(inst.dota_orginial_timemult or 1)
	end
end

-- Hooks
local old_set = AnimState.SetDeltaTimeMultiplier
function AnimState.SetDeltaTimeMultiplier(anim, val, ...)
	local inst = GetEntity(anim)
	local arcane_buff = 1
	if inst then
		arcane_buff = inst.dota_arcane_timemult or 1
		inst.dota_orginial_timemult = val
	end
	return old_set(anim, val * arcane_buff, ...)
end

-- [STATEGRAPH]
local REDUCTION = TUNING.DOTA.ARCANE_BLINK.ARCANE.REDUCTION
AddGlobalClassPostConstruct("stategraph", "StateGraphInstance", function(self)
	function self:Dota_GetStateTimeMult()
		return self.inst and self.inst:HasTag("buff_dota_arcane") and REDUCTION or 1
	end

	function self:Dota_RescaleTimeline(val)
		local timeline = self.currentstate and self.currentstate.timeline
		if timeline ~= nil then
			for _,v in pairs(timeline)do
				if val and val ~= 1 then	-- 需要更改为新的时间序列
					v.dota_time = v.dota_time or v.time	-- 记录原有的时间序列
					v.time = v.time/val		-- 更新时间
				else			-- 需要恢复成原有时间序列
					v.time = v.dota_time or v.time	-- 根据记录的时间序列恢复
					v.dota_time = nil		-- 清除记录的时间序列
				end
			end
		end
	end

	local old_SetTimeout = self.SetTimeout
	function self:SetTimeout(time, ...)
		if time then
			return old_SetTimeout(self, time/self:Dota_GetStateTimeMult(), ...)
		else
			return old_SetTimeout(self, time, ...)
		end
	end

	local old_Update = self.Update
	function self:Update(...)
		local mult = self:Dota_GetStateTimeMult()
		if mult ~= 1 then
			self:Dota_RescaleTimeline(mult)
		end
		local time_to_sleep = old_Update(self, ...)
		if mult ~= 1 then
			self:Dota_RescaleTimeline(nil)
		end
		return time_to_sleep
	end
end)