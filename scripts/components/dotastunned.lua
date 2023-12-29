-------------------------------------------------眩晕特效----------------------------------------------
-- 全新状态

local DotaStunned = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("dota_canstun")

    self.total = 180
    self.current = 180
    self.sleeptime = 30

end)

function DotaStunned:OnRemoveFromEntity()
    self.inst:RemoveTag("dota_canstun")
end

local function StopUpdatingCharge(self)
    if self.updating then
        self.updating = false
        self.inst:StopUpdatingComponent(self)
    end
end

local function StartUpdatingCharge(self)
    if not self.updating then
        self.updating = true
        self.inst:StartUpdatingComponent(self)
    end
end

function DotaStunned:OnStune()
    if self.inst.brain ~= nil then
        self.inst.brain:Stop()
    end

    if self.inst.components.combat ~= nil then
        self.inst.components.combat:SetTarget(nil)
    end

    if self.inst.components.locomotor ~= nil then
        self.inst.components.locomotor:Stop()
    end

    self.inst:PushEvent("dotaevent_gotostunned")
    if self.inst.components.dotastunbar then
        self.inst.components.dotastunbar:Enable(true)
    end
end

function DotaStunned:OnWakeUp()
    if self.inst.brain ~= nil then
        self.inst.brain:Start()
    end

    self.inst:PushEvent("dotaevent_stunwake")
    if self.inst.components.dotastunbar then
        self.inst.components.dotastunbar:Enable(false)
    end
end

function DotaStunned:GetResistance()
    local resistance = 0
    if self.inst.components.dotaattributes then
        resistance = self.inst.components.dotaattributes.statusresistance:Get() or 0
    end
    return (1 - resistance)
end

function DotaStunned:CanBeStunned()
    return not self.inst:HasTag("dota_avatar")
end

function DotaStunned:GoToStunned(sleeptime)
    if self.inst.entity:IsVisible() and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) 
     and self:CanBeStunned() and sleeptime > 0
    then
        local sleeptime_tmp = sleeptime * self:GetResistance()
        if sleeptime_tmp > self:GetTimeToWake() then
            self:SetSleepTime(sleeptime_tmp)
            self:SetSleep(0)
        end
    end
end

function DotaStunned:WakeUp()
    if not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        self:OnWakeUp()
        StopUpdatingCharge(self)
    end
end

function DotaStunned:OnUpdate(dt)   -- 是否要刷帧检测来规避冰冻等控制效果打断眩晕
    self:SetSleep(self.sleeptime > 0 and self.current + dt * self.total / self.sleeptime or self.total, true)
end

function DotaStunned:SetSleep(val, overtime)
    val = math.clamp(val, 0, self.total)
    if self.current ~= val then
        local was_waked = self:IsWakeUp()
        self.current = val
        self.inst:PushEvent("dotaevent_stunchange", { newpercent = self:GetPercent(), overtime = overtime })
        if self:IsWakeUp() then
            StopUpdatingCharge(self)
            if not was_waked then
                self:OnWakeUp()
            end
        else
            StartUpdatingCharge(self)
            if was_waked then
                self:OnStune()
            end
        end
    end
end

function DotaStunned:SetSleepTime(t)
    if self.sleeptime ~= t then
        self.sleeptime = t
        StartUpdatingCharge(self)
    end
end

function DotaStunned:IsWakeUp()
    return self.current >= self.total
end

function DotaStunned:GetPercent()
    return self.current / self.total
end

function DotaStunned:GetSleepTime()
    return math.max(0, self.sleeptime)
end

function DotaStunned:GetTimeToWake()
    return self:IsWakeUp() and 0 or (1 - self:GetPercent()) * self:GetSleepTime()
end

function DotaStunned:OnSave()
    return not self:IsWakeUp() and {
        add_component_if_missing = true,
        sleeptime = self.sleeptime,
        current = self.current,
    } or {add_component_if_missing = true,}
end

function DotaStunned:OnLoad(data)
    if data.sleeptime ~= nil then
        self:SetSleepTime(data.sleeptime)
    end
    if data.current ~= nil then
        self:SetSleep(data.current)
    end
end

return DotaStunned