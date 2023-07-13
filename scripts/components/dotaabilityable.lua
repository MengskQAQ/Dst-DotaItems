--------------------------------------------- 唯一被动 巫师之刃 / 英灵胸针 ----------------------------------------------
local function onenable(self, enable)
    if enable then
        self.inst:AddTag("dota_witchblade")
    else
        self.inst:RemoveTag("dota_witchblade")
    end
end

local DotaAbilityAble = Class(function(self, inst)
    self.inst = inst
    self.enable = false
    self.abilities = {}
end,
nil,
{
    enable = onenable,
})

function DotaAbilityAble:IsEnabled()
    return self.enable
end

function DotaAbilityAble:Enable(enable)
    self.enable = enable
    if not enable then
        self:EndActivate()
    end
end

function DotaAbilityAble:HasAbility(name)
    return self.abilities[name] ~= nil
end

function DotaAbilityAble:GetAbility(name)
    local ability = self.abilities[name]
    return ability ~= nil and ability.inst or nil
end

local function RegisterAbility(self, name, ent, data)
    if ent.components.dotaability ~= nil then
        self.abilities[name] =
        {
            inst = ent,
            onremove = function(debuff)
							self.abilities[name] = nil
							if self.ondebuffremoved ~= nil then
								self.ondebuffremoved(self.inst, name, debuff)
							end
						end,
        }
        self.inst:ListenForEvent("onremove", self.abilities[name].onremove, ent)
        ent.persists = false
        ent.components.dotaability:AttachTo(name, self.inst, data)
		if self.ondebuffadded ~= nil then
			self.ondebuffadded(self.inst, name, ent, data)
		end
    else
        ent:Remove()
    end
end

function DotaAbilityAble:ActivateAbility(name, prefab, data)
    if self.enable then
		if self.abilities[name] == nil then
			local ent = SpawnPrefab(prefab)
			if ent ~= nil then
				RegisterAbility(self, name, ent, data)
			end
			return ent
		end
    end
end

function DotaAbilityAble:EndActivate(name)
    local ability = self.abilities[name]
    if ability ~= nil then
        self.abilities[name] = nil
        self.inst:RemoveEventCallback("onremove", ability.onremove, ability.inst)
		if self.ondebuffremoved ~= nil then
			self.ondebuffremoved(self.inst, name, ability.inst)
		end
        if ability.inst.components.ability ~= nil then
            ability.inst.components.ability:OnDetach()
        else
            ability.inst:Remove()
        end
    end
end

function DotaAbilityAble:CreateAbility()

end

function DotaAbilityAble:OnSave()

end

function DotaAbilityAble:OnLoad(data)

end

return DotaAbilityAble