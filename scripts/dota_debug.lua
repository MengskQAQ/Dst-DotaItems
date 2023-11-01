local function SetOpener(self, opener)
    self.classified.Network:SetClassifiedTarget(opener or self.inst)
    if self.inst.components.container ~= nil then
        for k, v in pairs(self.inst.components.container.slots) do
            if v and v.replica.inventoryitem then
                v.replica.inventoryitem:SetOwner(self.inst)
            end
        end
    else
        --Shouldn't be reachable.
        assert(false)
    end
end

AddClassPostConstruct("components/container_replica", function(self)
    function self:AddOpener(opener)
        local opencount = self.inst.components.container.opencount
        if opencount == 1 then
            --standard logic.
            SetOpener(self, opener)
        elseif opencount > 1 then
            self.classified.Network:SetClassifiedTarget(nil)
            if self.inst.components.container ~= nil then
                for k, v in pairs(self.inst.components.container.slots) do
                    v.replica.inventoryitem:SetOwner(self.inst)
                end
            end
        end
        self.openers[opener] = self.inst:SpawnChild("container_opener")
        self.openers[opener].Network:SetClassifiedTarget(opener)
    end
end)

AddClassPostConstruct("components/container_replica", function(self)
    function self:AddOpener(opener)
        local opencount = self.inst.components.container.opencount
        if opencount == 1 then
            --standard logic.
            SetOpener(self, opener)
        elseif opencount > 1 then
            self.classified.Network:SetClassifiedTarget(nil)
            if self.inst.components.container ~= nil then
                for k, v in pairs(self.inst.components.container.slots) do
                    v.replica.inventoryitem:SetOwner(self.inst)
                end
            end
        end
        self.openers[opener] = self.inst:SpawnChild("container_opener")
        self.openers[opener].Network:SetClassifiedTarget(opener)
    end

    function self:RemoveOpener(opener)
        local opencount = self.inst.components.container.opencount
        if opencount == 0 then
            SetOpener(self, nil)
        elseif opencount == 1 then
            SetOpener(self, table.getkeys(self.inst.components.container.openlist)[1])
        elseif opencount > 1 then
            self.classified.Network:SetClassifiedTarget(nil)
            if self.inst.components.container ~= nil then
                for k, v in pairs(self.inst.components.container.slots) do
                    v.replica.inventoryitem:SetOwner(self.inst)
                end
            end
        end
        if self.openers[opener] then
            self.openers[opener]:Remove()
            self.openers[opener] = nil
        end
    end
end)