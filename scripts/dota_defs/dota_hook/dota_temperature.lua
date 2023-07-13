-------------------------------------------------斯嘉蒂之眼  or 冰眼-------------------------------------------------
AddComponentPostInit("temperature", function(self)
    -- 让隔热制冷效果考虑dotabox里的装备
    local old_GetInsulation = self.GetInsulation
    function self:GetInsulation()
        local winterInsulation = 0
        local summerInsulation = 0
        local a,b = old_GetInsulation(self)
        if self.inst.components.inventory ~= nil then
            local equipped = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY)
            if equipped ~= nil then
                if equipped.components.insulator ~= nil then
                    local insulationValue, insulationType = equipped.components.insulator:GetInsulation()
                    if insulationType == SEASONS.WINTER then
                        winterInsulation = winterInsulation + insulationValue
                    elseif insulationType == SEASONS.SUMMER then
                        summerInsulation = summerInsulation + insulationValue
                    else
                        print(equipped, " has invalid insulation type: ", insulationType)
                    end
                end
                if equipped.components.container ~= nil and equipped:HasTag("dota_box") then
                    for i = 1, equipped.components.container.numslots do
                        local item = equipped.components.container.slots[i]
                        if item ~= nil and item.components.insulator ~= nil then
                            local insulationValue, insulationType = item.components.insulator:GetInsulation()
                            if insulationType == SEASONS.WINTER then
                                winterInsulation = winterInsulation + insulationValue
                            elseif insulationType == SEASONS.SUMMER then
                                summerInsulation = summerInsulation + insulationValue
                            else
                                print(item, " has invalid insulation type: ", insulationType)
                            end
                        end
                    end
                end
            end
        end
        return math.max(0, a + winterInsulation), math.max(0, b + summerInsulation)
    end

    -- 提供一个免疫过热过冷的方法
    local old_SetTemperature =  self.SetTemperature
	function self:SetTemperature(value,...)
		if value > (self.overheattemp - 10 ) and self.inst:HasTag("dota_nooverheat") then
            value = self.overheattemp - 10
        elseif value < 15 and self.inst:HasTag("dota_nosubcool") then
            value = 15
	    end
		return old_SetTemperature(self,value,...)
	end
end)