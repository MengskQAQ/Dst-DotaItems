local weight_health = 2
local weight_hunger = 1
local weight_sanity = 2
local weight_mana = 1/20

local weights_total = weight_health + weight_hunger + weight_sanity
local weights_health = weight_health / weights_total
local weights_hunger = weight_hunger / weights_total
local weights_sanity = weight_sanity / weights_total

AddComponentPostInit("edible", function(self)

    function self:Dota_GetMana(eater)

        local health = self:GetHealth(eater)
        local hunger = self:GetHunger(eater)
        local sanity = self:GetSanity(eater)
        
        local weights = weights_health * health + weights_hunger * hunger + weights_sanity * sanity

        if weights <= 0 then
            return 0
        end
    
        return math.log10(math.floor( weight_mana * weights * weights ) + 1)
    end
end)