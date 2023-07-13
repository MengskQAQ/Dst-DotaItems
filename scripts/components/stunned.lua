-------------------------------------------------眩晕特效----------------------------------------------
-- 全新状态


local Stunned = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("canstun")
    self.isstunned = false
    self.testperiod = 4
    self.lasttransitiontime = GetTime()
    self.lasttesttime = GetTime()
    self.stuntestfn = DefaultStunTest
    self.waketestfn = DefaultWakeTest
    self:StartTesting()
    self.resistance = 1
    self.sleepiness = 0
    self.wearofftime = 5
    self.hibernate = false
    --self.fxchildren = {}

    --these are for diminishing returns (mainly bosses), so nil for default
    --self.diminishingreturns = false
    --self.extraresist = 0
    --self.diminishingtask = nil

end)

function Stunned:OnRemoveFromEntity()
    self.inst:RemoveTag("canstun")
    if self.testtask ~= nil then
        self.testtask:Cancel()
    end
    if self.wearofftask ~= nil then
        self.wearofftask:Cancel()
    end
    if self.diminishingtask ~= nil then
        self.diminishingtask:Cancel()
    end
end

function Stunned:SetDefaultTests()
    self.stuntestfn = DefaultStunTest
    self.waketestfn = DefaultWakeTest
end

function Stunned:StopTesting()
    if self.testtask ~= nil then
        self.testtask:Cancel()
        self.testtask = nil
    end
end

function DefaultStunTest(inst)
    return true
end

function DefaultWakeTest(inst)
    return true
end

local function ShouldStun(inst)
    local faint = inst.components.stunned
    if faint == nil then
        return
    end
    faint.lasttesttime = GetTime()
    if faint.stuntestfn ~= nil and faint.stuntestfn(inst) then
        faint:GoToStun()
    end
end

local function ShouldWakeUp(inst)
    local faint = inst.components.stunned
    if faint == nil then
        return
    elseif faint.hibernate then
        faint:StopTesting()
    else
        faint.lasttesttime = GetTime()
        if faint.waketestfn ~= nil and faint.waketestfn(inst) then
            faint:WakeUp()
        end
    end
end

local function WearOff(inst)
    local faint = inst.components.stunned
    if faint == nil then
        return
    elseif faint.sleepiness > 1 then
        faint.sleepiness = faint.sleepiness - 1
    elseif faint.sleepiness > 0 then
        faint.sleepiness = 0
        if faint.wearofftask ~= nil then
            faint.wearofftask:Cancel()
            faint.wearofftask = nil
        end
    end
end

-----------------------------------------------------------------------------------------------------

function Stunned:SetWakeTest(fn, time)
    self.waketestfn = fn
    self:StartTesting(time)
end

function Stunned:SetStunTest(fn)
    self.stuntestfn = fn
    self:StartTesting()
end

function Stunned:OnEntityStun()
    self:StopTesting()
end

function Stunned:OnEntityWake()
    self:StartTesting()
end

function Stunned:SetResistance(resist)
    self.resistance = resist
end

function Stunned:StartTesting(time)
    if self.isstunned then
        self:SetTest(ShouldWakeUp, time)
    else
        self:SetTest(ShouldStun)
    end
end

function Stunned:IsStunned()
    return self.isstunned
end

function Stunned:IsHibernating()
    return self.hibernate
end

function Stunned:GetTimeAwake()
    return self.isasleep and 0 or GetTime() - self.lasttransitiontime
end

function Stunned:GetTimeStun()
    return self.isasleep and GetTime() - self.lasttransitiontime or 0
end

function Stunned:GetDebugString()
    return string.format("%s for %2.2f / %2.2f Sleepy: %d/%d -- Multiplier: %2.2f (Decay: %2.2f)",
            self.isasleep and "SLEEPING" or "AWAKE",
            self.isasleep and self:GetTimeAsleep() or self:GetTimeAwake(),
            self.lasttesttime + self.testtime - GetTime(),
            self.sleepiness,
            self.resistance,
            self:GetSleepTimeMultiplier(),
            self.diminishingtask ~= nil and GetTaskRemaining(self.diminishingtask) or 0)
end

--V2C: not passing self because we also don't cancel this task on removal
local function OnGoToStun(inst, time)
    if inst.components.sleeper ~= nil then
        inst.components.sleeper:GoToSleep(time)
    end
end

function Stunned:AddSleepiness(sleepiness, time)
    self.sleepiness = self.sleepiness + sleepiness
    if self.isasleep or self.sleepiness > self.resistance then
        self:GoToSleep(time)
    elseif self.sleepiness == self.resistance then
        self.inst:DoTaskInTime(self.resistance, OnGoToStun, time)
    elseif self.wearofftask == nil then
        self.wearofftask = self.inst:DoPeriodicTask(self.wearofftime, WearOff)
    end
end

local function DecayExtraResist(inst, self)
    self:SetExtraResist(self.extraresist - .1)
end

function Stunned:SetExtraResist(resist)
    self.extraresist = math.clamp(resist, 0, self.wearofftime)
    if self.extraresist > 0 then
        if self.diminishingtask == nil then
            self.diminishingtask = self.inst:DoPeriodicTask(30, DecayExtraResist, nil, self)
        end
    elseif self.diminishingtask ~= nil then
        self.diminishingtask:Cancel()
        self.diminishingtask = nil
    end
end

function Stunned:GetSleepTimeMultiplier()
    return self.extraresist ~= nil and math.max(.2, 1 - self.extraresist * .1) or 1
end

function Stunned:GoToSleep(sleeptime)
    if self.inst.entity:IsVisible() and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        local wasasleep = self.isasleep
        self.lasttransitiontime = GetTime()
        self.isasleep = true
        if self.wearofftask ~= nil then
            self.wearofftask:Cancel()
            self.wearofftask = nil
        end

        if self.inst.brain ~= nil then
            self.inst.brain:Stop()
        end

        if self.inst.components.combat ~= nil then
            self.inst.components.combat:SetTarget(nil)
        end

        if self.inst.components.locomotor ~= nil and not (self.inst.sg ~= nil and self.inst.sg:HasStateTag("nosleep")) then
            self.inst.components.locomotor:Stop()
        end

        if not wasasleep then
            self.inst:PushEvent("gotosleep")
            if self.diminishingreturns then
                self:SetExtraResist((self.extraresist or 0) + 1)
            end
        end

        self:SetWakeTest(self.waketestfn, sleeptime ~= nil and sleeptime * self:GetSleepTimeMultiplier() or sleeptime)
    end
end

function Stunned:SetTest(fn, time)
    if self.testtask ~= nil then
        self.testtask:Cancel()
        self.testtask = nil
    end

    if fn ~= nil then
        --some randomness on testing times
        self.testtime = math.max(0, self.testperiod + math.random() - .5)
        self.testtask = self.inst:DoPeriodicTask(self.testtime, fn, time)
    end
end

function Stunned:WakeUp()
    self.hibernate = false
    if self.isasleep and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        self.lasttransitiontime = GetTime()
        self.isasleep = false
        self.sleepiness = 0

        if self.inst.brain ~= nil then
            self.inst.brain:Start()
        end

        self.inst:PushEvent("onwakeup")
        self:SetSleepTest(self.sleeptestfn)
    end
end

function Stunned:OnSave()
    return self.extraresist ~= nil
        and self.extraresist > 0
        and { extraresist = math.floor(self.extraresist * 10) * .1 }
        or nil
end

function Stunned:OnLoad(data)
    if data.extraresist ~= nil then
        self:SetExtraResist(data.extraresist)
    end
end

return Stunned