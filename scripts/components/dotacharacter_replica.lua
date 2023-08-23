local DotaCharacter = Class(function(self, inst)
    self.inst = inst
    self._level = net_float(inst.GUID, "dotacharacter._level")          -- 等级
    self._maxlevel = net_float(inst.GUID, "dotacharacter._maxlevel")        -- 最大等级
    self._exp = net_float(inst.GUID, "dotacharacter._exp")            -- 经验
    self._maxexp = net_float(inst.GUID, "dotacharacter._maxexp")         -- 最大经验
    self._skillpoint = net_float(inst.GUID, "dotacharacter._skillpoint") --技能点
    -- self._mana = net_float(inst.GUID, "dotacharacter._mana")            -- 魔法
    -- self._maxmana = net_float(inst.GUID, "dotacharacter._maxmana")         -- 最大魔法
    self._strength = net_float(inst.GUID, "dotacharacter._strength")     -- 力量
    self._agility = net_float(inst.GUID, "dotacharacter._agility")      -- 敏捷
    self._intelligence = net_float(inst.GUID, "dotacharacter._intelligence") -- 智力

    self._activateitem = net_entity(inst.GUID, "dotacharacter._activateitem")
end)

---------------------------------------------------------------------
function DotaCharacter:SetLevel(level)
    if self.inst.components.dotacharacter then
        -- 更新网络变量，仅在主机执行
        level = level or 0
        self._level:set(level)
    end
end
function DotaCharacter:SetMaxLevel(maxlevel)
    self._maxlevel:set(maxlevel)
end
function DotaCharacter:SetExp(exp)
    self._exp:set(exp)
end
function DotaCharacter:SetMaxexp(maxexp)
    self._maxexp:set(maxexp)
end
-- function DotaCharacter:SetMana(mana)
--     self._mana:set(mana)
-- end
-- function DotaCharacter:SetMaxmana(maxmana)
--     self._maxmana:set(maxmana)
-- end
function DotaCharacter:SetSkillPoint(skillpoint)
    self._skillpoint:set(skillpoint)
end
function DotaCharacter:SetStrength(strength)
    self._strength:set(strength)
end
function DotaCharacter:SetAgility(agility)
    self._agility:set(agility)
end
function DotaCharacter:SetIntelligence(intelligence)
    self._intelligence:set(intelligence)
end

-----------------------------------------------------------------------
function DotaCharacter:GetLevel()
    if self.inst.components.dotacharacter ~= nil then
        -- 在主机直接读取component的值
        return self.inst.components.dotacharacter.level
    else
        -- 在客机读取网络变量的值
        return self._level:value()
    end
end
function DotaCharacter:GetMaxLevel()
    return self._maxlevel:value()
end
function DotaCharacter:GetExp()
    return self._exp:value()
end
function DotaCharacter:GetMaxexp()
    return self._maxexp:value()
end
-- function DotaCharacter:Getmana()
--     return self._mana:value()
-- end
-- function DotaCharacter:GetMaxmana()
--     return self._maxmana:value()
-- end
function DotaCharacter:GetSkillPoint()
    return self._skillpoint:value()
end
function DotaCharacter:GetStrength()
    return self._strength:value()
end
function DotaCharacter:GetAgility()
    return self._agility:value()
end
function DotaCharacter:GetIntelligence()
    return self._intelligence:value()
end

-----------------------------------------------------------------------

function DotaCharacter:SetActivateItem(item)
    self._activateitem:set(item)
    -- if TheWorld.ismastersim then
    --     SendModRPCToClient(CLIENT_MOD_RPC["DOTARPC"]["ItemActivate"], self.inst.userid, item ~= nil)
    -- end
end
function DotaCharacter:GetActivateItem()
    if self.inst.components.dotacharacter ~= nil then
        return self.inst.components.dotacharacter:GetActivateItem()
    else
        return self._activateitem:value()
    end
end
function DotaCharacter:StartAOETargetingUsing(inst)
    local item = inst or self:GetActivateItem()
    local playercontroller = ThePlayer and ThePlayer.components.playercontroller
	if playercontroller ~= nil then
		playercontroller:StartAOETargetingUsing(item)   -- 里面已经有item判空了
	end
end

return DotaCharacter