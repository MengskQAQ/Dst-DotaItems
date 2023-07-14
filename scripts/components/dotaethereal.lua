-------------------------------------------------虚无特效----------------------------------------------
-------------------------------------------------虚灵之刃-------------------------------------------------

-- TODO：考虑bloom代替color

local DotaEthereal = Class(function(self, inst)
    self.inst = inst
    self.ghosttask = {}
    self.ghoststate = {}
    self.isethereal = false
    self.colour = { 0.0, 1.0, 0.0, 0.4 }
    self.source = "dotaethereal"
end)

function DotaEthereal:GetCurrentColour()
    return unpack(self.colour)
end

function DotaEthereal:IsEthereal()
    return self.isethereal
end

function DotaEthereal:PushColour(r, g, b, a)
    if r == nil and g == nil and b == nil and a == nil then
        r, g, b, a = self.colour[1], self.colour[2], self.colour[3], self.colour[4]
    end
    if self.inst.components.colouradder ~= nil then
        self.inst.components.colouradder:PushColour(self.source, r, g, b, a)
    else
        self.inst.AnimState:SetAddColour(r, g, b, a)
    end
end

function DotaEthereal:PopColour()
    if self.inst.components.colouradder ~= nil then
        self.inst.components.colouradder:PopColour(self.source)
    else
        self.inst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

function DotaEthereal:Activate()
    if self.isethereal then return end
    self.isethereal = true
    self:PushColour()
    if self.inst.components.dotaattributes ~= nil then
        self.inst.components.dotaattributes.spellweak:SetModifier("buff", TUNING.DOTA.GHOST_SCEPTER.GHOSTFORM.SPELLWEAK, "dotaethereal")
    end
    if self.inst.components.combat ~= nil then
        self.inst.components.combat:Dota_SetEthereal(true)
    end
end

function DotaEthereal:DeActivate()
    if not self.isethereal then return end
    self.isethereal = false
    self:PopColour()
    if self.inst.components.dotaattributes ~= nil then
        self.inst.components.dotaattributes.spellweak:RemoveModifier("buff", "dotaethereal")
    end
    if self.inst.components.combat ~= nil then
        self.inst.components.combat:Dota_SetEthereal(false)
    end
end

function DotaEthereal:InitGhostState(val)
    if val and not self:IsEthereal() then
        self:Activate()
    end

    if not val and self:IsEthereal() then
        local tmp = false
        for _, v in pairs(self.ghoststate) do
            if v then
                tmp = true
                break
            end
        end
        if not tmp then
            self:DeActivate()
        end
    end
end

function DotaEthereal:SetTaskState(source, val)
    self.ghoststate[source] = val
    self:InitGhostState(val)
    if not val and self.ghosttask[source] ~= nil then
        self.ghosttask[source]:Cancel()
        self.ghosttask[source] = nil
    end
end

function DotaEthereal:GoToGhostForm(source, time)
    if source ~= nil then
        self:SetTaskState(source, true)
        if time ~= nil then
            if self.ghosttask[source] ~= nil then
                self.ghosttask[source]:Cancel()
            end
            self.ghosttask[source] = self.inst:DoTaskInTime(time, function() self:SetTaskState(source, false) end)
        end
    end
end

function DotaEthereal:OutOfGhostForm(source)
    if source ~= nil then
        self:SetTaskState(source, false)
        if self.ghosttask[source] ~= nil then
            self.ghosttask[source]:Cancel()
            self.ghosttask[source] = nil
        end
    end
end

function DotaEthereal:GetDebugString()
    local str = string.format("Current Colour: (%.2f, %.2f, %.2f, %.2f)", self.colour[1], self.colour[2], self.colour[3], self.colour[4])
    str = str..string.format("\n\t State:")
    for k, v in pairs(self.ghoststate) do
        str = str..string.format("\n\t%s: %d", tostring(k), v)
    end
    str = str..string.format("\n\t Task:")
    for k, v in pairs(self.ghosttask) do
        if v ~= nil then
            str = str..string.format("\n\t%s", tostring(k))
        end
    end
    return str
end

function DotaEthereal:OnSave()
    return {isethereal = self.isethereal}
end

function DotaEthereal:OnLoad(data)
    if data.isethereal ~= nil then
        self.isethereal = data.isethereal
    end
    if self:IsEthereal() then
        self:DeActivate()
    end
end

return DotaEthereal