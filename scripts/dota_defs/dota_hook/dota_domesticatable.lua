------------------------------------------支配头盔 and (统御头盔 or 大支配)-------------------------------------------------
-- 让被支配的生物不会掉驯化值

AddComponentPostInit("domesticatable", function(self)
    self.dota_dominate = false

    local old_CheckForChanges = self.CheckForChanges
	function self:CheckForChanges()
		if self.inst.components.hunger:GetPercent() <= 0 
		 and self.domestication <= 0
         and self.dota_dominate then 
			return
		end
        if old_CheckForChanges then
			return old_CheckForChanges(self)
		end
    end

    function self:Dota_SetDominateStatus(status)
        if status ~= nil then self.dota_dominate = status 
        else self.dota_dominate = true end
    end

    local old_OnSave = self.OnSave
    function self:OnSave()
		local data = old_OnSave(self)
		if data ~= nil then
			data.dota_dominate = self.dota_dominate
		end
		return data
	end
	
	local old_OnLoad = self.OnLoad
	function self:OnLoad(data, newents)
		if data and data.dota_dominate ~= nil then
			self.dota_dominate = data.dota_dominate
		end
		old_OnLoad(self, data, newents)
	end

end)