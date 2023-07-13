-------------------------------------------------玲珑心-------------------------------------------------
AddComponentPostInit("rechargeable", function(self)
	local old_SetChargeTime = self.SetChargeTime
	function self:SetChargeTime(t)
		if self.inst.components.inventoryitem then
			local owner = self.inst.components.inventoryitem:GetGrandOwner()
			if owner and owner.components.dotaattributes then
				t = t * (1 - owner.components.dotaattributes.cdreduction:Get())
			end
		end
		if old_SetChargeTime then
			old_SetChargeTime(self, t)
		end
	end

	function self:Dota_SetMinTime(time)
		if self:GetTimeToCharge() < time then
			self:Discharge(time)
		end
	end

	-- Todo:以后需要修改update，让装备不在装备栏中增加冷却或暂停冷却
end)