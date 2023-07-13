local DotaItem = Class(function(self, inst)
	self.inst = inst
	self._isequipped = net_bool(inst.GUID, "dotaitem._level")
end)

function DotaItem:SetEquipStatus(isequipped)
    if self.inst.components.dotaitem then
        self._isequipped:set(isequipped)
    end
    self:UpdateEquipStatus()
end

function DotaItem:UpdateEquipStatus()
    if self._isequipped:value() then
        if not self.inst:HasTag("dota_canuse") then
            self.inst:AddTag("dota_canuse")
        end
    else
        if self.inst:HasTag("dota_canuse") then
            self.inst:RemoveTag("dota_canuse")
        end
    end
end

return DotaItem