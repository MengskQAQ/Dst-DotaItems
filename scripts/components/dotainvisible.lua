-------------------------------------------------隐身特效----------------------------------------------
local DotaInvisible = Class(function(self, inst)
    self.inst = inst
    self.shadowtask = {}
    self.shadowstate = {}
    self.isinvisible = false
    self.colour = { 0.3, 0.3, 0.3, 0.4 }
    self.source = "dotainvisible"
end,
nil,
{
})

function DotaInvisible:GetCurrentColour()
    return unpack(self.colour)
end

function DotaInvisible:IsInvisible()
    return self.isinvisible
end
-- AnimState:SetMultColour
-- AnimState:SetDeltaTimeMultiplier
function DotaInvisible:PushColour(r, g, b, a) -- TODO：用这个的话表现不好，究竟要不要直接改透明度呢
    if r == nil and g == nil and b == nil and a == nil then
        r, g, b, a = self.colour[1], self.colour[2], self.colour[3], self.colour[4]
    end
    if self.inst.components.colouradder ~= nil then
        self.inst.components.colouradder:PushColour(self.source, r, g, b, a)
    else
        self.inst.AnimState:SetAddColour(r, g, b, a)
    end
end

function DotaInvisible:PopColour()
    if self.inst.components.colouradder ~= nil then
        self.inst.components.colouradder:PopColour(self.source)
    else
        self.inst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

function DotaInvisible:Activate()
    if self.isinvisible then return end
    self.isinvisible = true
    RemovePhysicsColliders(self.inst)	--去除碰撞体积
    self:PushColour()	-- 透明效果
    if not self.inst:HasTag("dota_appeared") then
        local x,y,z = self.inst.Transform:GetWorldPosition()	--清除仇恨
        local ents = TheSim:FindEntities(x,y,z, 20, { "_combat" }, { "player" })
        for _,v in ipairs(ents) do
            if v.components.combat:HasTarget()
             and v.components.combat:IsRecentTarget(self.inst) --仅消除目标为持有者的仇恨
             and not v:HasTag("dota_detection")	--敌人不具备反隐tag
             then
                v.components.combat:DropTarget()
            end
        end
    end
    
    -- 祈祷第一次使用这个组件时人物不要有什么功能改变了这几个tag
    if self.inst.Dota_IsHasTagShadow == nil then self.inst.Dota_IsHasTagShadow = true end
    if self.inst.Dota_IsHasTagNotarget == nil then self.inst.Dota_IsHasTagNotarget = true end
    if self.inst.Dota_IsHasTagScarytoprey == nil then self.inst.Dota_IsHasTagScarytoprey = true end
    if not self.inst:HasTag("shadow") then	--添加伪隐身效果tag
        self.inst.Dota_IsHasTagShadow = false
        self.inst:AddTag("shadow")
    end
    if not self.inst:HasTag("notarget") then
        self.inst.Dota_IsHasTagNotarget = false
        self.inst:AddTag("notarget")
    end
    if self.inst:HasTag("scarytoprey") then
        self.inst.Dota_IsHasTagScarytoprey = false
        self.inst:RemoveTag("scarytoprey")
    end
end

function DotaInvisible:DeActivate()
    if not self.isinvisible then return end
    self.isinvisible = false
    ChangeToCharacterPhysics(self.inst)
    self:PopColour()
	if not self.inst.Dota_IsHasTagShadow then   self.inst:RemoveTag("shadow")    end --恢复tag
	if not self.inst.Dota_IsHasTagNotarget then   self.inst:RemoveTag("notarget")    end
    if not self.inst.Dota_IsHasTagScarytoprey then   self.inst:AddTag("scarytoprey")    end
end

function DotaInvisible:InitShadowState()
    for _, v in pairs(self.shadowstate) do
        if v and not self:IsInvisible() then
            self:Activate()
            return
        end
    end
    if self:IsInvisible() then
        self:DeActivate()
    end
end

function DotaInvisible:SetTaskState(source, val)
    self.shadowstate[source] = val
    self:InitShadowState()
    if not val and self.shadowtask[source] ~= nil then
        self.shadowtask[source]:Cancel()
        self.shadowtask[source] = nil
    end
end

function DotaInvisible:GoToShadow(source, time)
    if source ~= nil then
        self:SetTaskState(source, true)
        if time ~= nil then
            if self.shadowtask[source] ~= nil then
                self.shadowtask[source]:Cancel()
            end
            self.shadowtask[source] = self.inst:DoTaskInTime(time, function() self:SetTaskState(source, false) end)
        end
    end
end

function DotaInvisible:OutOfShadow(source)
    if source ~= nil then
        if self.shadowtask[source] ~= nil then
            self.shadowtask[source]:Cancel()
            self.shadowtask[source] = nil
        end
        self:SetTaskState(source, false)
    end
end

function DotaInvisible:GetDebugString()
    local str = string.format("Current Colour: (%.2f, %.2f, %.2f, %.2f)", self.colour[1], self.colour[2], self.colour[3], self.colour[4])
    str = str..string.format("\n\t State:")
    for k, v in pairs(self.shadowstate) do
        str = str..string.format("\n\t%s: %d", tostring(k), v)
    end
    str = str..string.format("\n\t Task:")
    for k, v in pairs(self.shadowtask) do
        if v ~= nil then
            str = str..string.format("\n\t%s", tostring(k))
        end
    end
    return str
end

function DotaInvisible:OnSave()
    return {isinvisible = self.isinvisible}
end

function DotaInvisible:OnLoad(data)
    if data.isinvisible ~= nil then
        self.isinvisible = data.isinvisible
    end
    if self:IsInvisible() then
        self:DeActivate()
    end
end

return DotaInvisible