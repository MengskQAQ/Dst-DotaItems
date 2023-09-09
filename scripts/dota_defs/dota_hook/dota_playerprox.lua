-- 官方的光环效果在多个物品反复开关时会出现buff不符合预期的现象，我们需要修改一下组件
-- 虽然不能完美解决，但起码消除了一部分不稳定的现象

local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "player"}	
local function AllEntitiesExpectPlayers(inst, self)
    local x, y, z = inst.Transform:GetWorldPosition()
    local entities = TheSim:FindEntities(x, y, z, self.near, { "_combat" }, exclude_tags)  -- 检索 self.near 范围内的实体
    
    local closeentities = {}
    for i, entity in ipairs(entities) do
        closeentities[entity] = true -- 存放范围内实体至临时表
        if self.closeentities[entity] then   -- 如果实体已经在总表，说明计算过 onnear ，则设为空
            self.closeentities[entity] = nil
        else
            if self.onnear ~= nil then  -- 如果实体没有在总表，说明没有计算过 onnear ，计算一次
                self.onnear(inst, entity)
            end
        end
    end

    local farsq = self.far * self.far
    for entity in pairs(self.closeentities) do   -- 遍历总表中的实体
        if entity.entity:IsVisible() and
            entity:GetDistanceSqToPoint(x, y, z) < farsq then   -- 判断总表中的实体是否还在 self.far 内
                closeentities[entity] = true     -- 在范围内就在表中继续存放
        else
            if self.onfar ~= nil then   -- 在范围外就计算 onfar
                self.onfar(inst, entity)
            end
        end
    end

    self.closeentities = closeentities    -- 刷新一下表
    self.isclose = not IsTableEmpty(self.closeentities)  -- 计算一下表元素
end

AddComponentPostInit("playerprox", function(self)
    self.closeentities = {}
    self.dota_activate = true
    self.dota_isdotaitem = false

    self.TargetModes.AllEntitiesExpectPlayers = AllEntitiesExpectPlayers

    local old_OnEntityWake = self.OnEntityWake
    function self:OnEntityWake()
        if self.dota_activate then
            old_OnEntityWake(self)
        else
            self:ForceUpdate()
            self:Stop()
        end
    end

    local old_OnRemoveEntity = self.OnRemoveEntity
    local old_OnRemoveFromEntity = self.OnRemoveFromEntity
    function self:OnRemoveEntity()
        if self.dota_isdotaitem then
            self:Dota_OnDeActivate()
        end
        old_OnRemoveEntity(self)
    end
    function self:OnRemoveFromEntity()
        if self.dota_isdotaitem then
            self:Dota_OnDeActivate()
        end
        old_OnRemoveFromEntity(self)
    end

    -- Bug: 多个同种光环生效时，执行onfar函数会会导致光环效果消失，需要再次激活
    function self:Dota_OnDeActivate()
        if self.isclose and self.onfar ~= nil then
            for player in pairs(self.closeplayers) do
                if player:IsValid() then
                    self.onfar(self.inst, player)
                end
            end
        end
    end

    function self:Dota_IsDotaItem(val)
        if val ~= nil then
            self.dota_isdotaitem = val
        end
        return self.dota_isdotaitem
    end

    function self:Dota_SetActivateStatus(val, update)
        if not val then
            self.dota_activate = false
            if update then
                self:ForceUpdate()
            end
            self:Stop()
            self:Dota_OnDeActivate()
        else
            self.dota_activate = true
            self:Schedule()
            if update then
                self:ForceUpdate()
            end
        end
    end

end)