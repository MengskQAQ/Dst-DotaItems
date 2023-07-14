-- TODO：待制作，让食物拥有魔法回复效果
AddComponentPostInit("edible", function(self)
    function self:Dota_GetMana(eater)
        local health = math.max(self:GetHealth(eater), 1)
        local hunger = math.max(self:GetHunger(eater), 1)
        local sanity = math.max(self:GetSanity(eater), 1)
        
        local mana = math.sqrt(health) 
        + math.sqrt(hunger) 
        + math.sqrt(sanity) 
        + math.log(health) 
        + math.log(hunger) 
        + math.log(sanity)

        return math.floor(mana / 3)
    end
end)