AddComponentPostInit("eater", function(self)
    local old_Eat = self.Eat
    function self:Eat(food, feeder)
        old_Eat(self, food, feeder)
        if self:PrefersToEat(food) then
            if self.inst.components.dotaattributes ~= nil then
                local mana_delta = food.components.edible:Dota_GetMana(self.inst)
                self.inst.components.dotaattributes:Mana_DoDelta(mana_delta, nil, food.prefab)
            end
        end
    end
end)