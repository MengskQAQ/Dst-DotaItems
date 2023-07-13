-------------------------------------------------护盾特效----------------------------------------------
local DotaShield = Class(function(self, inst)
	self.inst = inst
	self.owner = inst

	self.health = 10
	self.maxhealth = 10

    -- self.destroytime = nil
end,
nil,
{
})

function DotaShield:SetMaxHealth(amount)
	self.maxhealth = amount
end

function DotaShield:SetOnFinishedFn(fn)
	self.onfinished = fn
end

function DotaShield:SetOnTakedamageFn(fn)
	self.ontakedamage = fn
end

function DotaShield:SetOnCreateFn(fn)
	self.oncreated = fn
end

function DotaShield:CreateShield(owner)
	self.owner = owner
	self:ResetShield()
	if self.oncreated ~= nil then
		self.oncreated(self.inst, self.owner)
	end
end

function DotaShield:GetPercent()
	return self.health / self.maxhealth
end

function DotaShield:ResetShield()
	self.health = self.maxhealth
end

function DotaShield:ApplyDamage(damage)
	local leftover_damage = damage - self.health
	self:TakeDamage(damage)
	if leftover_damage <= 0 then
		return 0
	else
		return leftover_damage
	end
end

function DotaShield:TakeDamage(damage)
    local new_health = self.health - damage

	if self.ontakedamage ~= nil then
		self.ontakedamage(self.inst, self.owner, damage)
	end

	self.health = math.min(new_health, self.maxhealth)

	if self.health <= 0 then
		self.health = 0
		if self.onfinished ~= nil then
			self.onfinished()
		end
		self.inst:PushEvent("Remove")
	end
end

return DotaShield