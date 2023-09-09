-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- 被动 -----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-- 废案
AddComponentPostInit("debuffable", function(self)
 
    self.dota_abilities = {}

    function self:Dota_AddAbility(ability, equipment, data)
        if not self:Dota_HasAbility(ability) then
            self.dota_abilities[ability] = {}
        end
        self.dota_abilities[ability][equipment] = true
        self:AddDebuff(ability, ability, data)
    end

    function self:Dota_RemoveAbility(ability, equipment)
        if not self:Dota_HasAbility(ability) or not equipment then
            return
        end
        self.dota_abilities[ability][equipment] = false
        local tmp = false
        for _, v in pairs(self.dota_abilities[ability]) do
            if v then
                tmp = true
                break
            end
        end
        if not tmp then
            self:RemoveDebuff(ability)
        end
    end

    function self:Dota_HasAbility(ability)
        return self.dota_abilities[ability] ~= nil
    end
end)