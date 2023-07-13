AddComponentPostInit("inventory", function(self)
    function self:FindDotaItem(fn)
        local equipped = self:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) -- 获取玩家装备栏的物品
        if equipped ~= nil and fn(equipped) then
            return equipped
        end

        if equipped ~= nil and equipped.components.container ~= nil and equipped.components.container.canbeopened then
            for i = 1, equipped.components.container.numslots do
                local item = equipped.components.container.slots[i]
                if item ~= nil and fn(item) then
                    return item
                end
            end
        end
    end

    function self:ForEachDotaItem(fn, ...)
        local equipped = self:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) -- 获取玩家装备栏的物品
        if equipped ~= nil then
            fn(equipped, ...)
        end
		
        if equipped ~= nil and equipped.components.container ~= nil and equipped.components.container.canbeopened then
			for i = 1, equipped.components.container.numslots do
                local item = equipped.components.container.slots[i]
                if item ~= nil then
                    fn(item, ...)
                end
            end
        end
    end
end)