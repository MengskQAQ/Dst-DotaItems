local manabadge = require("widgets/dota_manabadge")
local Text = require('widgets/text')

-------------------------------------------魔法值UI---------------------------------------
AddClassPostConstruct("widgets/statusdisplays", function(self)
	if self.owner:HasTag("dotaattributes") then
		self.dota_manabadge = self:AddChild(manabadge(self.owner))

		self.owner:DoTaskInTime(0.5, function()
			local x1 ,y1, z1 = self.stomach:GetPosition():Get()
			local x2 ,y2, z2 = self.brain:GetPosition():Get()		
			local x3 ,y3, z3 = self.heart:GetPosition():Get()		
			if y2 == y1 or  y2 == y3 then --开了三维mod
				self.dota_manabadge:SetModEnable(true, self.stomach:GetPosition() + Vector3(x1-x2, 0, 0))
			else
				self.dota_manabadge:SetModEnable(false, self.stomach:GetPosition() + Vector3(x1-x3, 0, 0))
			end
		end)


		--死亡时候的隐藏
		local old_SetGhostMode = self.SetGhostMode
		function self:SetGhostMode(ghostmode,...)
			old_SetGhostMode(self,ghostmode,...)
			if ghostmode then		
				if self.dota_manabadge ~= nil then 
					self.dota_manabadge:Hide()
				end
			else
				if self.dota_manabadge ~= nil then
					self.dota_manabadge:Show()
				end
		    end
	    end

	end
end)

-------------------------------------------让消耗的生命/魔法显示在物品上----------------------------------------
AddClassPostConstruct("widgets/itemtile", function(self)
    if self.item:HasTag("dota_equipment") and self.item:HasTag("dota_needmana") 
	 and self.item.manacost ~= nil
	then
        self.dota_manacost = self:AddChild(Text(NUMBERFONT, 40, nil, {0, 0, 255, 1}))
        self.dota_manacost:SetPosition(16, -16, 0)	-- -.5, -40, 0
    	self.dota_manacost:SetString(tostring(self.item.manacost))
	end

	if self.item:HasTag("dota_equipment") and self.item:HasTag("dota_needhealth") 
	 and self.item.healthcost ~= nil
    then
	   self.dota_healthcost = self:AddChild(Text(NUMBERFONT, 40, nil, {255, 0, 0, 1}))
	   self.dota_healthcost:SetPosition(-16, -16, 0)
	   self.dota_healthcost:SetString(tostring(self.item.healthcost))
    end
end)