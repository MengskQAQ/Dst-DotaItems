local DotaAttributes = Class(function(self, inst)
    self.inst = inst
    self._mana = net_float(inst.GUID, "dotaattributes._mana", "dotamanaDirty")              -- 魔法
    self._maxmana = net_float(inst.GUID, "dotaattributes._maxmana", "dotamaxmanaDirty")     -- 最大魔法
    self._attackspeed = net_float(inst.GUID, "dotaattributes._attackspeed")                 -- 攻速
end)

---------------------------------------------------------------------
function DotaAttributes:SetMana(mana)
    self._mana:set(mana)
end
function DotaAttributes:SetMaxMana(maxmana)
    self._maxmana:set(maxmana)
end
function DotaAttributes:SetAttackSpeed(attackspeed)
    self._attackspeed:set(attackspeed)
end
-----------------------------------------------------------------------
function DotaAttributes:GetMana()
    return self._mana:value()
end
function DotaAttributes:GetMana_Double()
    if self.inst.components.dotaattributes ~= nil then   -- 在主机直接读取component的值
        return self.inst.components.dotaattributes.mana
    else    -- 在客机读取网络变量的值
        return self._mana:value()
    end
end
function DotaAttributes:GetMaxMana()
    return self._maxmana:value()
end
function DotaAttributes:GetAttackSpeed()
    return self._attackspeed:value()
end


return DotaAttributes