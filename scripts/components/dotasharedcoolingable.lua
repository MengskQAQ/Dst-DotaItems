local DotaSharedCoolingAble = Class(function(self, inst)
	self.inst = inst
    self.trackitem = {}
    self.timers = {}
    self.inst:AddTag("dota_sharedcoolingable")
end,
nil,
{
})

function DotaSharedCoolingAble:OnRemoveFromEntity()
    self.inst:RemoveTag("dota_sharedcoolingable")
    for k, v in pairs(self.timers) do
        if v.timer ~= nil then
            v.timer:Cancel()
        end
    end
end

function DotaSharedCoolingAble:IsPaused(type)
    return self:CoolingExists(type) and self.timers[type].paused
end

function DotaSharedCoolingAble:CoolingExists(type)
    return self.timers[type] ~= nil
end

local function OnTimerDone(inst, self, type)
    self:EndCoolingDown(type)
    inst:PushEvent("coolingdownend", { type = type })
end

function DotaSharedCoolingAble:ApplyCoolingDown(type, time, paused)
    if self:CoolingExists(type) then
        return false
    end

    if self.inst.components.dotaattributes then
        time = time * (1 - self.inst.components.dotaattributes.cdreduction:Get())
    end

    self.timers[type] =
    {
        timer = self.inst:DoTaskInTime(time, OnTimerDone, self, type),
        timeleft = time,
        end_time = GetTime() + time,
        paused = false,
    }

    if paused then
        self:PauseCoolingDown(type)
    end

    if self.trackitem[type] then
        for k, v in pairs(self.trackitem[type]) do
            if v.components.rechargeable ~= nil then
                v.components.rechargeable:Dota_SetMinTime(time)
            end
        end
    end

    return true
end

function DotaSharedCoolingAble:EndCoolingDown(type)
    if not self:CoolingExists(type) then
        return
    end

    if self.timers[type].timer ~= nil then
        self.timers[type].timer:Cancel()
        self.timers[type].timer = nil
    end
    self.timers[type] = nil
end

function DotaSharedCoolingAble:PauseCoolingDown(type)
    if not self:CoolingExists(type) or self:IsPaused(type) then
        return
    end

    self:GetCoolingLeft(type)

    self.timers[type].paused = true
    self.timers[type].timer:Cancel()
    self.timers[type].timer = nil
end

function DotaSharedCoolingAble:ResumeCoolingDown(type)
    if not self:IsPaused(type) then
        return
    end

    self.timers[type].paused = false
    self.timers[type].timer = self.inst:DoTaskInTime(self.timers[type].timeleft, OnTimerDone, self, name)
    self.timers[type].end_time = GetTime() + self.timers[type].timeleft
	return true
end

function DotaSharedCoolingAble:GetCoolingLeft(type)
    if not self:CoolingExists(type) then
        return false
    elseif not self:IsPaused(type) then
        self.timers[type].timeleft = self.timers[type].end_time - GetTime()
    end
    return self.timers[type].timeleft
end

function DotaSharedCoolingAble:SetCoolingLeft(type, time)
    if not self:CoolingExists(type) then
        return
    elseif self:IsPaused(type) then
        self.timers[type].timeleft = math.max(0, time)
    else
        self:PauseCoolingDown(type)
        self.timers[type].timeleft = math.max(0, time)
        self:ResumeCoolingDown(type)
    end
end

function DotaSharedCoolingAble:ResetCoolingDown()
    for type, data in pairs(self.timers) do
        if self.timers[type] ~= nil then
            self.timers[type].timer:Cancel()
            self.timers[type].timer = nil
        end
        self.timers[type] = nil
    end

    for type, equips in pairs(self.trackitem) do
        for _, equip in pairs(equips) do
            if equip and equip.prefab ~= "dota_refresher_orb"
             and equip.components.rechargeable and not equip.components.rechargeable:IsCharged() then
                equip.components.rechargeable:SetCharge(equip.components.rechargeable.total, true)
            end
        end
    end
end

function DotaSharedCoolingAble:TrackEquipment(prefab)
    if self.trackitem == nil then
        self.trackitem = {}
    end
    if prefab.components.dotasharedcooling then
        local type = prefab.components.dotasharedcooling:GetType()
        if self.trackitem[type] == nil then
            self.trackitem[type] = {}
        end
        table.insert(self.trackitem[type], prefab)
        if self:CoolingExists(type) then
            if prefab.components.rechargeable ~= nil then
                local time = self:GetCoolingLeft(type)
                prefab.components.rechargeable:Dota_SetMinTime(time)
            end
        end
    end
end

function DotaSharedCoolingAble:UnTrackEquipment(prefab)
    if prefab.components.dotasharedcooling then
        local type = prefab.components.dotasharedcooling:GetType()
        local index
        for i, v in ipairs(self.trackitem[type]) do
            if v == prefab then
                index = i
                break
            end
        end
        if index then
            table.remove(self.trackitem[type], index)
        end
    end
end

function DotaSharedCoolingAble:IsTracked(prefab)
    local index
    if prefab.components.dotasharedcooling then
        local type = prefab.components.dotasharedcooling:GetType()
        if self.trackitem[type] ~= nil then
            for i, v in ipairs(self.trackitem[type]) do
                if v == prefab then
                    index = i
                    break
                end
            end
        end
    end
    return index
end


function DotaSharedCoolingAble:OnSave()
    local data = {}
    for k, v in pairs(self.timers) do
        data[k] =
        {
            timeleft = self:GetCoolingLeft(k),
            paused = v.paused,
        }
    end
    return next(data) ~= nil and { timers = data } or nil
end

function DotaSharedCoolingAble:OnLoad(data)
    if data.timers ~= nil then
        for k, v in pairs(data.timers) do
            self:EndCoolingDown(k)
            self:ApplyCoolingDown(k, v.timeleft, v.paused)
        end
    end
end

function DotaSharedCoolingAble:LongUpdate(dt)
    for k, v in pairs(self.timers) do
        self:SetCoolingLeft(k, self:GetCoolingLeft(k) - dt)
    end
end

function DotaSharedCoolingAble:TransferComponent(newinst)
    local newcomponent = newinst.components.timer

    for k, v in pairs(self.timers) do
        newcomponent:ApplyCoolingDown(k, self:GetCoolingLeft(k), v.paused)
    end

end

return DotaSharedCoolingAble