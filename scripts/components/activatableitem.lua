-----------------------------------------------激活装备-------------------------------------------------
local function onactivate(self, activate)
    if activate then
        self.inst:AddTag("dota_activate")
    else
        self.inst:RemoveTag("dota_activate")
    end
end


local ActivatableItem = Class(function(self, inst)
	self.inst = inst
	self.onusefn = nil
	self.activatefn = nil
	self.inactivatefn = nil
	self.activate = false
	self.inactivateevents = nil
	self.presound = "mengsk_dota2_sounds/ui/buttonclick"
    self.postsound = "mengsk_dota2_sounds/ui/buttonrollover"
end,
nil,
{
    activate = onactivate,
})

function ActivatableItem:OnRemoveFromEntity()
    self.inst:RemoveTag("dota_activate")
end

function ActivatableItem:SetActivateFn(fn)
	self.activatefn = fn
end

function ActivatableItem:SetInActivatefn(fn)
	self.inactivatefn = fn
end

function ActivatableItem:IsActivate()
    return self.activate
end

function ActivatableItem:ResetAllItems(owner)
	if owner.components.inventory ~= nil then
		local equipped = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) -- 获取玩家装备栏的物品
		if equipped:HasTag("dota_box") and equipped.components.container ~= nil then
			for i = 1, equipped.components.container.numslots do
				local item = equipped.components.container.slots[i]
				if item ~= nil and item:HasTag("dota_activate")
					and item.components.activatableitem ~= nil then
					item.components.activatableitem:StopUsingItem(owner, true)
				end
			end
		end
	end
end

function ActivatableItem:StartUsingItem(owner, novoice)
	self.activate = true

	if self.inst.activatename ~= nil then
		local tag = string.lower(self.inst.activatename)
		if not owner:HasTag(tag) then owner:AddTag(tag) end
	end

	if owner.components.dotacharacter ~= nil then
		owner.components.dotacharacter:SetActivateItem(self.inst)
	end

	if not novoice and self.presound ~= "" then
		owner.SoundEmitter:PlaySound(self.presound)
	end

	if self.activatefn then
		self.activatefn(self.inst, owner)
	end

	owner:PushEvent("dotaevent_activate", {item = self.inst, novoice = novoice})

	if self.inactivateevents then
		self.inactivateevents(self.inst)
	end
	return self.activate
end

function ActivatableItem:StopUsingItem(owner, novoice)
	self.activate = false

	if self.inst.activatename ~= nil then
		local tag = string.lower(self.inst.activatename)	-- 什么反复横跳
		if owner:HasTag(tag) then owner:RemoveTag(tag) end
	end

	if not novoice and self.postsound ~= "" then
		owner.SoundEmitter:PlaySound(self.postsound)
	end

	if owner.components.dotacharacter ~= nil then
		owner.components.dotacharacter:SetActivateItem(nil)
	end

	if self.inactivatefn then
		self.inactivatefn(self.inst, owner)
	end

	owner:PushEvent("dotaevent_inactivate", {item = self.inst, novoice = novoice})
end

function ActivatableItem:ChangeActivate(owner, novoice)
	if self.activate == true then
		self:StopUsingItem(owner, novoice)
	elseif self.activate == false then
		self:ResetAllItems(owner)
		self:StartUsingItem(owner, novoice)
	else
		return false
	end
	return true
end

return ActivatableItem