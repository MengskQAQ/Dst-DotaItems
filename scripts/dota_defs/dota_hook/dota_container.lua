AddComponentPostInit("container", function(self)
	local old_GetSpecificSlotForItem = self.GetSpecificSlotForItem
	function self:GetSpecificSlotForItem(item)
		if self.inst and self.inst:HasTag("dota_box") and self.GetSpecificDotaSlotForItem then
			return self:GetSpecificDotaSlotForItem(item)
		end
		if old_GetSpecificSlotForItem then
			return oldGetSpecificSlotForItem(self,item)
		end
	end
	
	--新增函数用于获取可装备的格子，优先取空，满则取最后一个
	function self:GetSpecificDotaSlotForItem(item)
		if self.usespecificslotsforitems and self.itemtestfn ~= nil then
			for i = 1, self:GetNumSlots() do
				if self:itemtestfn(item, i) then
					--如果i是最后一格了，直接返回i
					if i>=self:GetNumSlots() then
						return i
					end
					--如果格子为空则返回空格子
					if self:GetItemInSlot(i)==nil then
						return i
					end
				end
			end
		end
	end
end)