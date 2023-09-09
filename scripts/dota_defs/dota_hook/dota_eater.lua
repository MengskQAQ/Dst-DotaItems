-- 角色吃东西的时候，可以回复一定量的魔法值，具体回复数值在 dota_edible 里定义
AddComponentPostInit("eater", function(self)
    local old_Eat = self.Eat
    function self:Eat(food, feeder)
        old_Eat(self, food, feeder)
        if self:PrefersToEat(food) and self.inst.components.dotaattributes then
            local mana_delta = food.components.edible:Dota_GetMana(self.inst)
            self.inst.components.dotaattributes:Mana_DoDelta(mana_delta, nil, food.prefab)
        end
    end
end)