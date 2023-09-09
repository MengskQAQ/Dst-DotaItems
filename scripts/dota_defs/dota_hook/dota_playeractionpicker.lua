-- 获取装备栏位上的action
-- 让客户端能够识别到放在装备box里的物品的右键动作
-- 逆天，官方天天改代码，每次都要让人重新读一次

-----------------------------------------------激活装备-------------------------------------------------

AddComponentPostInit("playeractionpicker", function(self)
	self.dota_disable_click = false

	local old_GetLeftClickActions = self.GetLeftClickActions	-- 获取原函数
	function self:GetLeftClickActions(position, target, ...)
		if self.dota_disable_click then
			return {}
		end
		return old_GetLeftClickActions(self, position, target, ...)
	end

    local old_GetRightClickActions = self.GetRightClickActions	-- 获取原函数
	function self:GetRightClickActions(position, target, ...)
		if self.dota_disable_click then
			return {}
		end

		if self.disable_right_click then	-- 当然了，得兼容游戏本身
			return {}
		end

		local actions = old_GetRightClickActions(self, position, target, ...)	-- 这是原函数的返回值
		local equipitem = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT) -- or EQUIPSLOTS.HANDS)
		if (actions == nil or #actions <= 0) and equipitem ~= nil and equipitem:IsValid() then
			local alwayspassable, allowwater--, deployradius
			local aoetargeting = equipitem.components.aoetargeting
			if aoetargeting ~= nil and aoetargeting:IsEnabled() then
				alwayspassable = equipitem.components.aoetargeting.alwaysvalid
				allowwater = equipitem.components.aoetargeting.allowwater
				--deployradius = item.components.aoetargeting.deployradius
			end
			alwayspassable = alwayspassable or equipitem:HasTag("allow_action_on_impassable")
			if alwayspassable or self.map:IsPassableAtPoint(position.x, 0, position.z, allowwater) 
			 and (target == nil or target:HasTag("walkableplatform") or target:HasTag("walkableperipheral"))
			then
				actions = self:GetPointActions(position, equipitem, true, target)
			end
		end

		return actions or {}
	end
end)