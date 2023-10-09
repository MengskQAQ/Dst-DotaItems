-- 女武神（歌唱值计算额外攻击）
AddComponentPostInit("singinginspiration", function(self)
	local old_OnHitOther = self.OnHitOther
	function self:OnHitOther(data)
        if old_OnHitOther then
			old_OnHitOther(self, data)
		end
        if self.inst.components.dotaattributes ~= nil then
            local delta = (self.inst.components.dotaattributes.extradamage:Get() * TUNING.INSPIRATION_GAIN_RATE) * (1 - self:GetPercent())

            if data.target and data.target:HasTag("epic") then
                delta = delta * TUNING.INSPIRATION_GAIN_EPIC_BONUS --3
            end
            self:DoDelta(delta)
        end
    end
end)