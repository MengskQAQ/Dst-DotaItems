local DotaSharedCooling = Class(function(self, inst)
	self.inst = inst
    self.type = nil
    self.inst:AddTag("dota_sharedcooling")
end,
nil,
{
})

function DotaSharedCooling:OnRemoveFromEntity()
    self.inst:RemoveTag("dota_sharedcooling")
end

function DotaSharedCooling:GetType()
    return self.type
end

function DotaSharedCooling:SetType(type)
    self.type = type
end

return DotaSharedCooling