local function on_equipped(self, isequipped)
    -- self.inst.replica.dotaitem:SetEquipStatus(isequipped)
    if isequipped then
        self.inst:AddTag("dota_canuse")
    else
        self.inst:RemoveTag("dota_canuse")
    end
end

local function on_ischarged(self, ischarged)
    if ischarged then
        self.inst:AddTag("dota_charged")
    else
        self.inst:RemoveTag("dota_charged")
    end
end

local DotaItem = Class(function(self, inst)
	self.inst = inst
	self.isequipped = false
    self.ischarged = true
end,
nil,
{
    isequipped = on_equipped,
    ischarged = on_ischarged,
})

function DotaItem:OnRemoveFromEntity()
    self.inst:RemoveTag("dota_canuse")
end

function DotaItem:Equipped()
	self.isequipped = true
end

function DotaItem:UnEquipped()
	self.isequipped = false
end

return DotaItem