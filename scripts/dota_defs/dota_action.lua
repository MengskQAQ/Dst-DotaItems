-----------------------------------------------------------------------
--此lua写法出自恒子大佬的能力勋章[workshop-1909182187]
--来源 scripts/medal_defs/medal_action.lua
-----------------------------------------------------------------------

--[[
-----actions-----自定义动作
{
	id,--动作ID
	str,--动作显示名字
	fn,--动作执行函数
	actiondata,--其他动作数据，诸如strfn、mindistance等，可参考actions.lua
	state,--关联SGstate,可以是字符串或者函数
	canqueuer,--兼容排队论 allclick为默认，rightclick为右键动作
}
-----component_actions-----动作和组件绑定
{
	type,--动作类型
		*SCENE--点击物品栏物品或世界上的物品时执行,比如采集
		*USEITEM--拿起某物品放到另一个物品上点击后执行，比如添加燃料
		*POINT--装备某手持武器或鼠标拎起某一物品时对地面执行，比如植物人种田
		*EQUIPPED--装备某物品时激活，比如装备火把点火
		*INVENTORY--物品栏右键执行，比如吃东西
	component,--绑定的组件
	tests,--尝试显示动作，可写多个绑定在同一个组件上的动作及尝试函数
}
-----old_actions-----修改老动作
{
	switch,--开关，用于确定是否需要修改
	id,--动作ID
	actiondata,--需要修改的动作数据，诸如strfn、fn等，可不写
	state,--关联SGstate,可以是字符串或者函数
}
--]]

-------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- 自定义动作 -----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

local easing = require("easing")

local HIGH_ACTION_PRIORITY = 10
local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME

local function ArriveAnywhere()
    return true
end

-- 增加玩家附加颜色
local function PushColour(inst, source, r, g, b, a)
    if inst.components.colouradder ~= nil then
        inst.components.colouradder:PushColour(source, r, g, b, a)
    else
        inst.AnimState:SetAddColour(r, g, b, a)
    end
end

-- 删除玩家附加颜色
local function PopColour(inst, source)
    if inst.components.colouradder ~= nil then
        inst.components.colouradder:PopColour(source)
    else
        inst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

local function StateFail(player)
	if player and player.components.dotacharacter then
		player.components.dotacharacter:SetActionStata(false)
	end
end
--获取指定表内的一条随机字符
--cvar：表，关键key，最小值，最大值
-- local function GetRandomStringFromTable(table, key, minnum ,maxnum)
-- 	local RandomKey = string.format(key..math.random(minnum,maxnum))
-- 	if table[RandomKey] ~= nil then
-- 		return table[RandomKey]
-- 	end
-- 	return nil
-- end

local function PlaySound(inst, sound, ...)
	if inst.SoundEmitter ~= nil and sound ~= nil then
		inst.SoundEmitter:PlaySound(sound, ...)
		-- SoundEmitter:PlaySound(emitter, event, name, volume, ...)
	end
end

local function GetRandomStringFromTable(table)
	local RandomKey = math.random(1,#table)
	return table[RandomKey] or nil
end

local function IsManaEnough(player, item, novoice)
	if item and item.manacost
	 and player.components.dotaattributes and player.components.dotaattributes.mana < item.manacost then
		if novoice == nil then
			PlaySound(player, "mengsk_dota2_sounds/ui/deny_mana", nil, BASE_VOICE_VOLUME)
			if player.components.talker ~= nil then
				player.components.talker:Say(GetRandomStringFromTable(STRINGS.DOTA.SPEECH.NOMANA) or "lack mana")
			end
		end
		return false
	end
	return true
end

local function IsManaEnough_Double(player, item)
	return item and item.manacost
		and player.replica.dotaattributes and player.replica.dotaattributes:GetMana_Double() >= item.manacost
end

local function PushEvent_MagicUse(inst, magic)
	TheWorld:PushEvent("dotaevent_magicuse", { inst = inst, pos = inst:GetPosition(), magic = magic })
end

local function PushEvent_MagicSingalTarget(inst, target, magic)
	TheWorld:PushEvent("dotaevent_magicsingal", { inst = inst, target = target, magic = magic })
end

local function ItemManaDelta(player, item, overtime, cause)
	if item and item.manacost and player and player.components.dotaattributes then
		player.components.dotaattributes:Mana_DoDelta(-item.manacost, overtime, cause)
	end
	PushEvent_MagicUse(player, string.upper(cause))
end

-- 如果属性系统关闭了, 就不再计算魔法值
if TUNING.DOTA.ATTRIBUTES_SYSTEM == 3 then
	IsManaEnough = function(player, item, novoice) return true end
	ItemManaDelta = function(player, mana, overtime, cause) end
	IsManaEnough_Double = function(player, item) return true end
end

local function PlaySound_CoolingDown(player)
	if player ~= nil and player.components.talker ~= nil then
		player.components.talker:Say(GetRandomStringFromTable(STRINGS.DOTA.SPEECH.COOLDOWN) or "Cooling down")
		PlaySound(player, "mengsk_dota2_sounds/ui/deny_cooldown", nil, BASE_VOICE_VOLUME)
	end
end

local function PlaySound_NoPoint(player)
	if player and player.components.talker ~= nil then
		player.components.talker:Say(GetRandomStringFromTable(STRINGS.DOTA.SPEECH.NOPOINT) or "no power point")
		PlaySound(player, "mengsk_dota2_sounds/ui/ui_general_deny", nil, BASE_VOICE_VOLUME)
	end
end

-- 标准动作检测-装备需激活，有对象
local function StandardTargetAndActivateActioniTest(act, tag)
	return act.doer ~= nil and act.doer:HasTag("player") and act.doer:HasTag(tag)
		and act.target ~= nil
		and act.target.components.health ~= nil and not act.target.components.health:IsDead()
		and act.target.components.combat ~= nil
end

-- 标准动作检测-装备无需激活
local function StandardInvobjectActioniTest(act, prefab)
	return act.doer ~= nil and act.doer:HasTag("player")
		and act.invobject ~= nil and act.invobject.prefab == prefab
		and act.invobject:HasTag("dota_canuse")
end

-- 让物品进入冷却，抛出反馈
local function RechargeCheck(inst, CD, player)
	if inst and inst.components.rechargeable ~= nil then
		-- 物品冷却未完成
		if not inst.components.rechargeable:IsCharged() then
			PlaySound_CoolingDown(player)
			return false
		end

		-- 物品有冷却共享
		if inst.components.dotasharedcooling and player.components.dotasharedcoolingable then
			local type = inst.components.dotasharedcooling:GetType()
			local time = player.components.dotasharedcoolingable:GetCoolingLeft(type)
			if time then
				inst.components.rechargeable:Discharge(time)
				PlaySound_CoolingDown(player)
				return false
			else
				player.components.dotasharedcoolingable:ApplyCoolingDown(type, CD)
				return true
			end
		else
			inst.components.rechargeable:Discharge(CD)
		end
		return true
	end
	return true	-- 此处默认返回值为true，因为希望该函数不会阻碍预期
end

local function FiniteusesAndRechargeCheck(inst, CD, player, usenum)
	if not inst then return false end
	local num = usenum or 1
	if inst.components.rechargeable and inst.components.finiteuses then

		if not inst.components.rechargeable:IsCharged() then
			PlaySound_CoolingDown(player)
			return false
		end

		if inst.components.finiteuses:GetUses() < num then
			PlaySound_NoPoint(player)
			return false
		end

		if not RechargeCheck(inst, CD, player) then
			return false
		end
		
		inst.components.finiteuses:Use(num)
		return true
	end
	return true	-- 此处默认返回值为true，因为希望该函数不会阻碍预期
end

local function AddDebuff(inst, debuffname, ...)
	if inst.components.debuffable ~= nil then
		inst.components.debuffable:AddDebuff(debuffname, debuffname, ...)
	end
end

-- 通过box寻找到玩家激活抖动物品
local function FindActivateItemByInvobject(inst, prefab)
	if inst.components.container ~= nil then
		inst = inst.components.container:FindItem(function(inst) return inst and inst.prefab == prefab and inst:HasTag("dota_activate") end)
	end
	return inst
end

-- 通过玩家寻找到激活的物品
local function FindActivateItemByDoer(owner, prefab)
	local equipped = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) -- 获取玩家装备栏的物品
	if equipped and equipped.components.container ~= nil then
		equipped = equipped.components.container:FindItem(function(inst) return inst and inst.prefab == prefab and inst:HasTag("dota_activate") end)
	end
	if equipped and equipped.prefab ~= prefab then
		return nil
	end
	return equipped
end

-- 改变playercontroller的接管状态
local function TakeOverPlayerController(inst, istakeover)
	if inst.components.playercontroller then
		inst.components.playercontroller:Dota_TakeOverAOETargeting(istakeover)
	end
end

-- 改变物品的激活状态
local function ChangeActivate(inst, target, novoice)
	if inst and inst.components.activatableitem then
		if novoice then
			inst.components.activatableitem:ChangeActivate(target, false)
		else
			inst.components.activatableitem:ChangeActivate(target, true)
		end
	end
end

local function UseOne(inst)
	if inst.components.stackable ~= nil then
		inst.components.stackable:Get(1):Remove()
	else
		inst:Remove()
	end
end

local function StateTest(inst, tag, state, mana)
	return inst:HasTag(tag)
		and not (inst.replica.dotaattributes ~= nil and inst.replica.dotaattributes:GetMana_Double() < mana)
		and not (inst.replica.dotacharacter ~= nil and inst.replica.dotacharacter:GetActivateItem() and not inst.replica.dotacharacter:GetActivateItem():HasTag("dota_charged"))
		and state or "dota_sg_nil"
end

local function ActionWalking(player)
	if player ~= nil and player.components.talker ~= nil then
		player.components.talker:Say("此物品未完成/Still working")
		return true
	end
	return false
end

local function ActionFailed(player)
	PlaySound(player, "mengsk_dota2_sounds/ui/ui_general_deny", nil, BASE_VOICE_VOLUME)
	return true
end

local function AoeActionFailed(player, item)
	ChangeActivate(item, player)
	SendModRPCToClient(CLIENT_MOD_RPC["DOTARPC"]["AOEINACTIVATE"], player.userid)
	-- if player.HUD ~= nil then
	-- 	player.HUD:Dota_EndReticule()
	-- end
	return true
end

local function AoeActionSucceed(player, item)
	SendModRPCToClient(CLIENT_MOD_RPC["DOTARPC"]["AOEINACTIVATE"], player.userid)
	-- if player.HUD ~= nil then
	-- 	player.HUD:Dota_EndReticule()
	-- end
end

-- local function StateActionFailed(player)
-- 	if player.components.dotacharacter then
-- 		player.components.dotacharacter:SetActionStata(false)
-- 		return true
-- 	end
-- 	return false
-- end

-- local function StateActionSucceed(player)
-- 	if player.components.dotacharacter then
-- 		player.components.dotacharacter:SetActionStata(true)
-- 		return true
-- 	end
-- 	return false
-- end

local CANT_TAGS = {"INLIMBO", "playerghost"}
local exceuce_tags = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "player"}

--自定义动作
local actions = {}

-----------------------------------------------激活装备-------------------------------------------------
-- 早知道一个动作那么麻烦，当初就分成2个动作了
actions.activateitem = {
	id = "ACTIVATEITEM",
	str = STRINGS.DOTA.NEWACTION.ACTIVATEITEM,
	fn = function(act)
		if act.invobject and act.invobject.components.activatableitem
		and act.doer and act.doer.components.inventory and act.doer.components.inventory:IsOpenedBy(act.doer) then
			if not act.invobject.components.activatableitem:IsActivate() then
				act.invobject.components.activatableitem:ResetAllItems(act.doer)
				if IsManaEnough(act.doer, act.invobject) then
					act.invobject.components.activatableitem:StartUsingItem(act.doer, false)
				end
			else
				act.invobject.components.activatableitem:StopUsingItem(act.doer, false)
			end
			return true
		end
		return ActionFailed(act.doer)
	end,
	pre_action_cb = function(act)

		if act.doer.HUD then
			local item = act.doer.HUD:Dota_GetActivateReticuleInv()
			if item ~= act.invobject and IsManaEnough_Double(act.doer, act.invobject) then
				act.doer.HUD:Dota_StartReticule(act.invobject)
			else
				act.doer.HUD:Dota_EndReticule()
			end
		end

		if act.doer.components.playercontroller then
			TakeOverPlayerController(act.doer, false)
			if act.invobject and act.invobject.components.aoetargeting then
				TakeOverPlayerController(act.doer, true)
			end
		end

	end,
	actiondata = {
		priority=6,
		rmb=true,
		instant=true,
		mount_valid=true, -- 骑牛
		encumbered_valid=true,
		strfn = function(act)
			return act.invobject and STRINGS.ACTIONS.ACTIVATEITEM[act.invobject.activatename] and act.invobject.activatename or "ACTIVATEITEM" or nil
		end,
	},
}
-------------------------------------------------dota_box-------------------------------------------------
actions.weardotaequip = {
	id = "WEARDOTAEQUIP",	-- 装备
	str = STRINGS.DOTA.NEWACTION.WEARDOTAEQUIP,
	fn = function(act)
		local equipped = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) -- 获取玩家装备栏的物品
		-- 物品不存在、装备栏没物品、装备栏的物品没容器组件则返回false
		if act.invobject == nil or equipped == nil or equipped.components.container == nil or not equipped:HasTag("dota_box") then
			return false
		end

		-- 获取box内可装备的格子
		local targetslot = equipped.components.container:GetSpecificDotaSlotForItem(act.invobject)
		if targetslot == nil then
			return false
		end
		-- 获取box里对应格子内的物品
		local cur_item = equipped.components.container:GetItemInSlot(targetslot)

		if cur_item == nil then	-- 如果格子里没其他物品
			local item = act.invobject.components.inventoryitem:RemoveFromOwner(equipped.components.container.acceptsstacks)
			equipped.components.container:GiveItem(item, targetslot, nil, false)
		else	-- 如果格子里有其他物品
			local item = act.invobject.components.inventoryitem:RemoveFromOwner(equipped.components.container.acceptsstacks)
			local old_item = equipped.components.container:RemoveItemBySlot(targetslot)
			if not equipped.components.container:GiveItem(item, targetslot, nil, false) then
				act.doer.components.inventory:GiveItem(item)
			end
			if old_item ~= nil then 
				if item.prevcontainer ~= nil then
					item.prevcontainer.inst.components.container:GiveItem(old_item, item.prevslot)
				else
					act.doer.components.inventory:GiveItem(old_item, item.prevslot)
				end
			end
			return true
		end
		return false
	end,
	actiondata = {
		priority=5,
		rmb=true,
		instant=true,
		mount_valid=true, -- 骑牛
		encumbered_valid=true,
	},
}
actions.takeoffdotaequip = {
	id = "TAKEOFFDOTAEQUIP", -- 脱下装备
	str = STRINGS.DOTA.NEWACTION.TAKEOFFDOTAEQUIP,
	fn = function(act)
		local equipped = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) -- 获取玩家装备栏的物品
		-- 物品不存在、装备栏没物品、装备栏的物品没容器组件则返回false
		if act.invobject == nil or act.invobject:HasTag("dota_box")
			or equipped == nil or equipped.components.container == nil or not equipped:HasTag("dota_box") then
			return false
		end
		
		-- 如果物品在box里，则执行脱下的操作
		if act.invobject.components.inventoryitem:IsHeldBy(equipped) then
			local item = equipped.components.container:RemoveItem(act.invobject) -- 移除box中的装备
			if item ~= nil then
				item.prevcontainer = nil
				item.prevslot = nil
				-- 装备还给玩家
				act.doer.components.inventory:GiveItem(item)--, nil, equipped:GetPosition())
				return true
			end
		end
		return false
	end,
	actiondata = {
		priority=5,
		rmb=true,
		instant=true,
		mount_valid=true,
		encumbered_valid=true,
	},
}
--------------------------------回城卷轴 or 远行鞋I or 飞鞋 or 远行鞋II or 大飞鞋---------------------------------------
local tpscroll_mana = TUNING.DOTA.TOWN_PORTAL_SCROLL.MANA

local function ActionCanMaphop(doer)
	if doer:HasTag("dota_tpscroll") then
		local rider = doer.replica.rider
        if rider == nil or not rider:IsRiding() then
            return true
        end
	end
    return false
end

local function TPRechargeAndSGCheck(inst, CD, player)
	if player and RechargeCheck(inst, CD, player) then
		return player.sg ~= nil and player.sg.currentstate.name == "dota_sg_portal_jumpin_pre"
	end
	return false
end

-- 假如传送距离平方小于3，那么不予传送，避免客户端延迟同步时导致距离选取错误
local tpdissq = 9
local function TpDestCheck(act)
	local act_pos = act:GetActionPoint()
	if act_pos and act.doer:GetDistanceSqToPoint(act_pos.x, act_pos.y, act_pos.z) > tpdissq then
		return true
	end
	act.doer.sg:GoToState("idle")
	PlaySound(act.doer, "mengsk_dota2_sounds/ui/ui_general_deny", nil, BASE_VOICE_VOLUME)
	return false
end

local function TPSCROLL(act, item, shouldremove, hud)
	local act_pos = act:GetActionPoint()
	ChangeActivate(item, act.doer)
	act.doer.sg:GoToState("portal_jumpin", {dest = act_pos,})	-- TODO
	if shouldremove then
		UseOne(item)
	end
	if hud and act.doer.HUD ~= nil and act.doer.HUD:IsMapScreenOpen() then
		GLOBAL.TheFrontEnd:PopScreen()
	end
	if act.doer.components.dotaattributes then
		act.doer.components.dotaattributes:Mana_DoDelta(-tpscroll_mana, nil, "dota_tpscroll")
	end
	PushEvent_MagicUse(act.doer, "DOTA_TPSCROLL")
	return true
end

actions.tpscroll = {
	id = "DOTA_TPSCROLL",
	str = STRINGS.DOTA.NEWACTION.DOTA_TPSCROLL,
	fn = function(act)
		if act.doer ~= nil and ActionCanMaphop(act.doer) then
			if not TpDestCheck(act) then return true end
			local item = nil
			item = FindActivateItemByDoer(act.doer, "dota_boots_of_travel_level2")	-- 飞鞋优先
			if item ~= nil then
				if not IsManaEnough(act.doer, item) then return true end
				if not TPRechargeAndSGCheck(item, TUNING.DOTA.BOOTS_OF_TRAVEL_LEVEL2.CD, act.doer) then return true end
				return TPSCROLL(act, item, false, false)
			end
			item = FindActivateItemByDoer(act.doer, "dota_boots_of_travel_level1")
			if item ~= nil then
				if not IsManaEnough(act.doer, item) then return true end
				if not TPRechargeAndSGCheck(item, TUNING.DOTA.BOOTS_OF_TRAVEL_LEVEL1.CD, act.doer) then return true end
				return TPSCROLL(act, item, false, false)
			end
			item = FindActivateItemByDoer(act.doer, "dota_town_portal_scroll")
			if item ~= nil then
				if not IsManaEnough(act.doer, item) then return true end
				if not TPRechargeAndSGCheck(item, TUNING.DOTA.TOWN_PORTAL_SCROLL.CD, act.doer) then return true end
				return TPSCROLL(act, item, true, false)
			end
		end
		return false
	end,
	state = function(inst, action)
		return StateTest(inst, "dota_tpscroll", "dota_sg_portal_jumpin_pre", tpscroll_mana)
		-- return inst:HasTag("dota_tpscroll") and inst.replica.dotaattributes and inst.replica.dotaattributes:GetMana_Double() > tpscroll_mana and "portal_jumpin_pre" or "dota_sg_nil"
	end,
	actiondata = {
		priority=9, -- 小恶魔优先级为10，会导致和小恶魔之间的冲突，可以考虑用rpc的方式规避冲突，不过我们暂时用降低优先级这种方法
		rmb=true,
		distance=36,
		mount_valid=true,
	},
}

actions.tpscroll_map = {
	id = "DOTA_TPSCROLL_MAP",
	str = STRINGS.DOTA.NEWACTION.DOTA_TPSCROLL,
	fn = function(act)
		if act.doer ~= nil and ActionCanMaphop(act.doer) then
			if not TpDestCheck(act) then return true end
			local item = nil
			item = FindActivateItemByDoer(act.doer, "dota_boots_of_travel_level2")
			if item ~= nil then
				if not IsManaEnough(act.doer, item) then return true end
				if not TPRechargeAndSGCheck(item, TUNING.DOTA.BOOTS_OF_TRAVEL_LEVEL2.CD, act.doer) then return true end
				return TPSCROLL(act, item, false, true)
			end
			item = FindActivateItemByDoer(act.doer, "dota_boots_of_travel_level1")
			if item ~= nil then
				if not IsManaEnough(act.doer, item) then return true end
				if not TPRechargeAndSGCheck(item, TUNING.DOTA.BOOTS_OF_TRAVEL_LEVEL1.CD, act.doer) then return true end
				return TPSCROLL(act, item, false, true)
			end
			item = FindActivateItemByDoer(act.doer, "dota_town_portal_scroll")
			if item ~= nil then
				if not IsManaEnough(act.doer, item) then return true end
				if not TPRechargeAndSGCheck(item, TUNING.DOTA.TOWN_PORTAL_SCROLL.CD, act.doer) then return true end
				return TPSCROLL(act, item, true, true)
			end
		end
		return false
	end,
	state = function(inst, action)	--TODO
		return StateTest(inst, "dota_tpscroll", "dota_sg_portal_jumpin_pre", tpscroll_mana)
	end,
	actiondata = {
		priority=9, -- 小恶魔优先级为10，会导致和小恶魔之间的冲突，可以考虑用rpc的方式规避冲突，这样似乎能降低性能损耗，不过我们先尝试一下这种方法
		customarrivecheck=ArriveAnywhere,
		rmb=true,
		mount_valid=true,
		map_action=true,
		-- stroverridefn=nil,	-- TODO
	},
}
-------------------------------------------------净化药水 or 小蓝-------------------------------------------------
actions.clarity = {
	id = "DOTA_CLARITY",
	str = STRINGS.DOTA.NEWACTION.DOTA_CLARITY,
	fn = function(act)
		if act.doer ~= nil and act.doer:HasTag("player") and act.invobject ~= nil and act.invobject.prefab == "dota_clarity" then
			AddDebuff(act.doer, "buff_dota_clarity")
			UseOne(act.invobject)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=8,
		mount_valid=true,
	},
}
-------------------------------------------------仙灵之火-------------------------------------------------
actions.faeriefire = {
	id = "DOTA_FAERIEFIRE",
	str = STRINGS.DOTA.NEWACTION.DOTA_FAERIEFIRE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_faerie_fire") then
			if act.doer.components.health ~= nil then
				act.doer.components.health:DoDelta(TUNING.DOTA.FAERIE_FIRE.HEALTH, nil, "faeriefire")
				PlaySound(act.doer, "mengsk_dota2_sounds/items/faerie_spark", nil, BASE_VOICE_VOLUME)
			end
			UseOne(act.invobject)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
	},
}
-------------------------------------------------诡计之雾-------------------------------------------------
actions.smoke = {
	id = "DOTA_SMOKE",
	str = STRINGS.DOTA.NEWACTION.DOTA_SMOKE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_smoke_of_deceit") then
			AddDebuff(act.doer, "buff_dota_smoke")
			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.SMOKE_OF_DECEIT.RANGE, { "player" }, CANT_TAGS)
			for _, ent in ipairs(ents) do
				AddDebuff(ent, "buff_dota_smoke")
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/smoke_of_deceit", nil, BASE_VOICE_VOLUME)
			UseOne(act.invobject)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
	},
}
-------------------------------------------------魔法芒果-------------------------------------------------
actions.mango = {
	id = "DOTA_MANGO",
	str = STRINGS.DOTA.NEWACTION.DOTA_MANGO,
	fn = function(act)
		if act.doer ~= nil and act.doer:HasTag("player") and act.invobject ~= nil and act.invobject.prefab == "dota_enchanted_mango"
		 and act.doer.components.dotaattributes ~= nil then 	
			act.doer.components.dotaattributes:Mana_DoDelta(TUNING.DOTA.ENCHANTED_MANGO.MANA, nil, "enchanted_mango")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/mango", nil, BASE_VOICE_VOLUME)
			UseOne(act.invobject)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
	},
}
---------------------------------------------------魔瓶 or 瓶子---------------------------------------------------
actions.regenerate = {
	id = "DOTA_REGENERATE",
	str = STRINGS.DOTA.NEWACTION.DOTA_REGENERATE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_bottle") and act.invobject.components.dotabottle ~= nil then
			if not RechargeCheck(act.invobject, TUNING.DOTA.BOTTLE.REGENERATE.CD, act.doer) then return true end
			act.invobject.components.dotabottle:Drink(act.doer)
			PlaySound(act.doer, "mengsk_dota2_sounds/ui/bottle_pour", nil, BASE_VOICE_VOLUME)
			-- PlaySound(act.doer, "mengsk_dota2_sounds/ui/bottle_corked", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
	},
}

actions.bottlerune = {
	id = "DOTA_BOTTLERUNE",
	str = STRINGS.DOTA.NEWACTION.DOTA_BOTTLERUNE,
	fn = function(act)
		if act.target and act.target:HasTag("dota_rune") and act.invobject and act.invobject.prefab == "dota_bottle" then
			if act.invobject.components.dotabottle then
				PlaySound(act.invobject, "mengsk_dota2_sounds/ui/bottle_corked", nil, BASE_VOICE_VOLUME)
				act.invobject.components.dotabottle:StoreRune(act.target)
				return true
			end
		end
		return false
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
	},
}
-------------------------------------------------树之祭祀 or 吃树-------------------------------------------------
local function isplant(inst)
	return	inst:HasTag("plant") and not inst:HasTag("burnt")
	 and not (inst.components.diseaseable ~= nil and inst:HasTag("diseased"))
	 and inst.components.workable ~= nil and inst.components.workable.action == ACTIONS.CHOP
	 and inst:HasTag("chop_workable")
end

actions.tango = {
	id = "DOTA_TANGO",
	str = STRINGS.DOTA.NEWACTION.DOTA_TANGO,
	fn = function(act)
		if act.target ~= nil and isplant(act.target)
		 and act.doer ~= nil and act.doer:HasTag("dota_tango") then
			local item = FindActivateItemByDoer(act.doer, "dota_tango")
			if item == nil then return ActionFailed(act.doer) end
			if act.target.components.workable:CanBeWorked() then
				act.target.components.workable:SetWorkLeft(1)
				act.target.components.workable:WorkedBy(act.doer, 1)
				-- 我们当然可以模仿workable里去推送事件，这样走原生函数有可能因为一些mod的树木不能销毁而出现bug，不过我们先这样处理
				AddDebuff(act.doer, "buff_dota_devou")
				PlaySound(act.doer, "mengsk_dota2_sounds/items/tango", nil, BASE_VOICE_VOLUME)
				ChangeActivate(item, act.doer)
				UseOne(item)
				return true
			end
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
		distance = TUNING.DOTA.TANGO.DEVOU.SPELLRANGE,
	},
}
-------------------------------------------------显影之尘 or 粉-------------------------------------------------
actions.dust = {
	id = "DOTA_DUST",
	str = STRINGS.DOTA.NEWACTION.DOTA_DUST,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_dust_of_appearance") then 	
			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.DUST_OF_APPEARANCE.RANGE, { "_combat" }, { "player", "INLIMBO" })
			for _, ent in ipairs(ents) do
				AddDebuff(ent, "buff_dota_dust")
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/dust_of_appearance", nil, BASE_VOICE_VOLUME)
			UseOne(act.invobject)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
	},
}
-------------------------------------------------知识之书-------------------------------------------------
actions.tome = {
	id = "DOTA_TOME",
	str = STRINGS.DOTA.NEWACTION.DOTA_TOME,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_tome_of_knowledge") and act.doer.components.dotacharacter then
			if act.doer.dota_tome_of_knowledge == nil then	-- 用一个 components 来记录会不会好点？
				act.doer.dota_tome_of_knowledge = 0
			else
				act.doer.dota_tome_of_knowledge = act.doer.dota_tome_of_knowledge + 1
			end
			local num = act.doer.dota_tome_of_knowledge
			act.doer.components.dotacharacter:DeltaExp(TUNING.DOTA.TOME_OF_KNOWLEDGE.EXP + num * TUNING.DOTA.TOME_OF_KNOWLEDGE.EXTREXP)
			PlaySound(act.doer, "mengsk_dota2_sounds/items/tome_of_knowledge", nil, BASE_VOICE_VOLUME)
			UseOne(act.invobject)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
	},
}
-------------------------------------------------治疗药膏-------------------------------------------------
actions.salve = {
	id = "DOTA_SALVE",
	str = STRINGS.DOTA.NEWACTION.DOTA_SALVE,
	fn = function(act)
		if act.doer ~= nil and act.doer:HasTag("player") and act.invobject ~= nil and act.invobject.prefab == "dota_healing_salve" then
			AddDebuff(act.doer, "buff_dota_salve")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/healing_salve", nil, BASE_VOICE_VOLUME)
			UseOne(act.invobject)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=true,
	},
}
-------------------------------------------------压制之刃 or 补刀斧 and 狂战斧-------------------------------------------------
actions.chop = {
	id = "DOTA_CHOP",
	str = STRINGS.DOTA.NEWACTION.DOTA_CHOP,
	fn = function(act)
		if act.target ~= nil and isplant(act.target) and act.target.components.workable:CanBeWorked() 
		 and act.doer ~= nil and act.doer:HasTag("dota_chop") then
			local item = FindActivateItemByDoer(act.doer, "dota_quelling_blade")
			if item ~= nil then 
				if not RechargeCheck(item, TUNING.DOTA.QUELLING_BLADE.CHOP.CD, act.doer) then return true end	-- 装备cd结束
			else
				item = FindActivateItemByDoer(act.doer, "dota_battle_fury")
				if not RechargeCheck(item, TUNING.DOTA.BATTLE_FURY.CHOP.CD, act.doer) then return true end	-- 装备cd结束
			end
			if item == nil then return ActionFailed(act.doer) end
			act.target.components.workable:SetWorkLeft(1)
			act.target.components.workable:WorkedBy(act.doer, 1)
			-- PlaySound(act.doer, "mengsk_dota2_sounds/items/blade_fury", nil, BASE_VOICE_VOLUME) -- 这个特殊音效怪怪的
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.QUELLING_BLADE.CHOP.SPELLRANGE,
	},
}
-------------------------------------------------暗影护符-------------------------------------------------
actions.fading = {
	id = "DOTA_FADING",
	str = STRINGS.DOTA.NEWACTION.DOTA_FADING,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_shadow_amulet") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.SHADOW_AMULET.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_fading")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------魔棒-------------------------------------------------
local function MagicTickHeal(item, doer, target, health, mana, reason)
	local outhealamp = doer.components.dotaattributes and doer.components.dotaattributes.outhealamp:Get() or 0
	if item.components.finiteuses then
		local uses = item.components.finiteuses:GetUses() --当前耐久
		item.components.finiteuses:Use(uses)
		if uses > 0 and target.components.health and not target.components.health:IsDead() then 	
			target.components.health:DoDelta( health * uses * (1 + outhealamp) , nil, reason )
		end
		if uses > 0 and target.components.dotaattributes then
			target.components.dotaattributes:Mana_DoDelta( mana * uses * (1 + outhealamp), nil, reason )
		end
	end
end

local MAGIC_STICK_HEALTH = TUNING.DOTA.MAGIC_STICK.HEAL
local MAGIC_STICK_MANA = TUNING.DOTA.MAGIC_STICK.MANA
actions.magiccharge = {
	id = "DOTA_MAGICCHARGE",
	str = STRINGS.DOTA.NEWACTION.DOTA_MAGICCHARGE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_magic_stick") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.MAGIC_STICK.CD, act.doer) then return true end
			MagicTickHeal(act.invobject, act.doer, act.doer, MAGIC_STICK_HEALTH, MAGIC_STICK_MANA, "magiccharge")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/magic_stick_activate", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------魔杖-------------------------------------------------
local MAGIC_WAND_HEALTH = TUNING.DOTA.MAGIC_WAND.HEAL
local MAGIC_WAND_MANA = TUNING.DOTA.MAGIC_WAND.MANA
actions.magicchargeplus = {
	id = "DOTA_MAGICCHARGEPLUS",
	str = STRINGS.DOTA.NEWACTION.DOTA_MAGICCHARGEPLUS,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_magic_wand") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.MAGIC_WAND.CD, act.doer) then return true end
			MagicTickHeal(act.invobject, act.doer, act.doer, MAGIC_WAND_HEALTH, MAGIC_WAND_MANA, "magicchargeplus")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/magic_stick_activate", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
--------------------------------------------闪烁匕首 or 跳刀----------------------------------------------
--------------------------------------------迅疾闪光 or 敏捷跳--------------------------------------------
--------------------------------------------秘奥闪光 or 智力跳--------------------------------------------
--------------------------------------------盛势闪光 or 力量跳--------------------------------------------
actions.blink = {
	id = "DOTA_BLINK",
	str = STRINGS.DOTA.NEWACTION.DOTA_BLINK,
	fn = function(act)
		if act.invobject ~= nil and act.invobject.components.blinkdagger ~= nil
		 and act.doer ~= nil and act.doer:HasTag("dota_blink") then
			local item = FindActivateItemByDoer(act.doer, "dota_blink_dagger")
						or FindActivateItemByDoer(act.doer, "dota_swift_blink") 
						or FindActivateItemByDoer(act.doer, "dota_arcane_blink") 
						or FindActivateItemByDoer(act.doer, "dota_overwhelming_blink") 
			if item and item.components.blinkdagger ~= nil then
				if not RechargeCheck(item, TUNING.DOTA.BLINK_DAGGER.BLINK.CD, act.doer) then return true end -- 装备cd结束方可使用blink
				ChangeActivate(item, act.doer)
				return item.components.blinkdagger:Blink(act:GetActionPoint(), act.doer)
			end
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		rmb=true,
		distance=50, 	--动作最小触发距离
		mount_valid=false,
	},
}
--------------------------------------------幽魂权杖 or 绿杖-----------------------------------------------
actions.ghostform = {
	id = "DOTA_GHOSTFORM",
	str = STRINGS.DOTA.NEWACTION.DOTA_GHOSTFORM,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_ghost_scepter") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.GHOST_SCEPTER.GHOSTFORM.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_ghostform")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/item_ghost_sceptre", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
---------------------------------------------动力鞋 or 假腿-------------------------------------------------
actions.toggle = {
	id = "DOTA_TOGGLE",
	str = STRINGS.DOTA.NEWACTION.DOTA_TOGGLE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_power_treads") and act.invobject.changeprimary then
			if not RechargeCheck(act.invobject, TUNING.DOTA.POWER_TREADS.CD, act.doer) then return true end
			act.invobject:changeprimary(act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
--------------------------------------------疯狂面具 or 疯脸------------------------------------------------
local berserk_mana = TUNING.DOTA.MASK_OF_MADNESS.BERSERK.MANA
actions.berserk = {
	id = "DOTA_BERSERK",
	str = STRINGS.DOTA.NEWACTION.DOTA_BERSERK,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_mask_of_madness") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.MASK_OF_MADNESS.BERSERK.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_berserk")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/mask_of_madness", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_berserk")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------灵魂之戒 or 魂戒-------------------------------------------------
actions.sacrifice = {
	id = "DOTA_SACRIFICE",
	str = STRINGS.DOTA.NEWACTION.DOTA_SACRIFICE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_soul_ring") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.SOUL_RING.SACRIFICE.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_sacrifice")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/soul_ring", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
--------------------------------------------迈达斯之手 or 点金手----------------------------------------------
local TRANSMUTE_HEALTH_LIMIT = TUNING.DOTA.HAND_OF_MIDAS.TRANSMUTE.HEALTHLIMIT

-- 取自pigking，让物品抛出
local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

actions.transmute = {
	id = "DOTA_TRANSMUTE",
	str = STRINGS.DOTA.NEWACTION.DOTA_TRANSMUTE,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_transmute")
		 and not act.target:HasTag("player")
		 and not act.target:HasTag("companion") 
		 and (act.target.components.health.currenthealth <= TRANSMUTE_HEALTH_LIMIT)
		--  and (act.target.components.leader ~= nil and not act.target.components.leader:IsFollower(act.doer))
		--  and (act.target.components.follower ~= nil and act.target.components.follower.leader ~= nil and not act.target.components.follower.leader:HasTag("player"))
		then
			local item = FindActivateItemByDoer(act.doer, "dota_hand_of_midas")
			if item == nil then return ActionFailed(act.doer) end

			if not RechargeCheck(item, TUNING.DOTA.HAND_OF_MIDAS.TRANSMUTE.CD, act.doer) then return true end
			-- 生成黄金
			local x, y, z = act.target.Transform:GetWorldPosition()
			y = 2.5

			local angle
			if act.doer ~= nil and act.doer:IsValid() then
				angle = 180 - act.doer:GetAngleToPoint(x, 0, z)
			else
				local down = TheCamera:GetDownVec()
				angle = math.atan2(down.z, down.x) / DEGREES
			end

			act.target.components.health:SetVal(0, "dota_transmute", nil)	-- TODO: 所有生物都可以这样致死吗？

			-- 先生成余数的黄金
			local nug = SpawnPrefab("goldnugget")
			local gold = TUNING.DOTA.HAND_OF_MIDAS.TRANSMUTE.GOLD
			local maxsize = nug.components.stackable.maxsize
			local a = math.floor(gold/maxsize)	-- 整数部分
			local b = math.floor(gold%maxsize)	-- 余数部分
			b = math.max(b, 1)	-- 确保有一个保底黄金
			nug.Transform:SetPosition(x, y, z)
			nug.components.stackable:SetStackSize(b)
			launchitem(nug, angle)

			-- 再生成整数的黄金
			if a >= 1 then
				for i = 1, a do
					local nugs = SpawnPrefab("goldnugget")
					nugs.Transform:SetPosition(x, y, z)
					nugs.components.stackable:SetStackSize(maxsize)
					launchitem(nug, angle)
				end
			end

			PlaySound(act.doer, "mengsk_dota2_sounds/items/item_handofmidas", nil, BASE_VOICE_VOLUME)
			ChangeActivate(item, act.doer)
			PushEvent_MagicUse(act.doer, "DOTA_TRANSMUTE")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.HAND_OF_MIDAS.TRANSMUTE.SPELLRANGE,
	},
}
------------------------------------------支配头盔 and (统御头盔 or 大支配)-------------------------------------------------
actions.dominate = {
	id = "DOTA_DOMINATE",
	str = STRINGS.DOTA.NEWACTION.DOTA_DOMINATE,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_dominate") then
			local item = FindActivateItemByDoer(act.doer, "dota_helm_of_the_dominator") 
						or FindActivateItemByDoer(act.doer, "dota_helm_of_the_overlord")
			if item == nil then return ActionFailed(act.doer) end
			if item.components.dominate ~= nil then
				if not RechargeCheck(item, TUNING.DOTA.HELM_OF_THE_DOMINATOR.DOMINATE.CD, act.doer) then return true end
				if item.components.dominate:CanDominate(act.doer) and item.components.dominate:CanBeDominate(act.target) then
					if not item.components.dominate:DoDominate(act.doer, act.target) then return ActionFailed(act.doer) end
					ChangeActivate(item, act.doer)
					return true
				end
				return ActionFailed(act.doer)
		    end
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.HELM_OF_THE_DOMINATOR.DOMINATE.SPELLRANGE,
	},
}
-------------------------------------------------相位鞋-------------------------------------------------
actions.phase = {
	id = "DOTA_PHASE",
	str = STRINGS.DOTA.NEWACTION.DOTA_PHASE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_phase_boots") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.PHASE_BOOTS.PHASE.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_phase")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/phase_boots_activate", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------奥术鞋 or 秘法鞋-------------------------------------------------
actions.replenish = {
	id = "DOTA_REPLENISH",
	str = STRINGS.DOTA.NEWACTION.DOTA_REPLENISH,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_arcane_boots") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.ARCANE_BOOTS.REPLENISH.CD, act.doer) then return true end
	
			local outhealamp = act.doer.components.dotaattributes ~= nil and act.doer.components.dotaattributes.outhealamp:Get() or 0
			local delta = (1 + outhealamp) * TUNING.DOTA.ARCANE_BOOTS.REPLENISH.MANA

			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.ARCANE_BOOTS.REPLENISH.RANGE, { "player" }, CANT_TAGS)
			for _, ent in ipairs(ents) do
				if ent.components.dotaattributes ~= nil then 	
					ent.components.dotaattributes:Mana_DoDelta(delta, nil, "dota_replenish")
				end
			end

			PlaySound(act.doer, "mengsk_dota2_sounds/items/dota_item_arcane_boots", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------洞察烟斗 or 笛子-------------------------------------------------
local barrier_mana = TUNING.DOTA.PIPE_OF_INSIGHT.BARRIER.MANA
actions.barrier = {
	id = "DOTA_BARRIER",
	str = STRINGS.DOTA.NEWACTION.DOTA_BARRIER,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_pipe_of_insight") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.PIPE_OF_INSIGHT.BARRIER.CD, act.doer) then return true end

			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.PIPE_OF_INSIGHT.BARRIER.RANGE, { "player" }, CANT_TAGS)
			for _, ent in ipairs(ents) do
				if ent.components.dotaattributes ~= nil then 
					ent.components.dotaattributes:CreateMagicShield("dota_shield_barrierfx")
				end
			end
			
			PlaySound(act.doer, "mengsk_dota2_sounds/items/pipe", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_barrier")
			return true

			-- 考虑到特效需要prefabs，因此护盾的运算挂载于护盾实体上。该方法更佳在处理特效方面更直接，因为两者可以一起处理。
			-- 具体的实现方法如下：
			-- 生成过程：生成护盾实体-护盾实体添加 shield-components 计算护盾-护盾实体在 action 内记录至 dotaattributes-components
			-- 结算过程：damage经由 dotaattributes-components 重定位至 shield-components 进行重计算，耗尽时通过 pushevent 与实体通信，删除实体
			
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------魂之灵瓮 or 大骨灰-------------------------------------------------
actions.release = {
	id = "DOTA_RELEASE",
	str = STRINGS.DOTA.NEWACTION.DOTA_RELEASE,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_release") then
			local item = FindActivateItemByDoer(act.doer, "dota_spirit_vessel")
			if item == nil then return ActionFailed(act.doer) end
			if not FiniteusesAndRechargeCheck(item, TUNING.DOTA.SPIRIT_VESSEL.RELEASE.CD, act.doer, 1) then return true end
			if act.target:HasTag("player") and not act.target:HasTag("playerghost") then
				AddDebuff(act.target, "buff_dota_releaseplus_positive")
			else
				AddDebuff(act.target, "buff_dota_releaseplus_negtive")
				PushEvent_MagicSingalTarget(act.doer, act.target, "DOTA_RELEASE")
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/spirit_vessel_cast", nil, BASE_VOICE_VOLUME)
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.SPIRIT_VESSEL.RELEASE.SPELLRANGE,
	},
}
-------------------------------------------------影之灵龛 or 骨灰-------------------------------------------------
actions.releaseplus = {
	id = "DOTA_RELEASEPLUS",
	str = STRINGS.DOTA.NEWACTION.DOTA_RELEASEPLUS,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_releaseplus") then
			local item = FindActivateItemByDoer(act.doer, "dota_urn_of_shadows")
			if item == nil then return ActionFailed(act.doer) end
			if not FiniteusesAndRechargeCheck(item, TUNING.DOTA.URN_OF_SHADOWS.RELEASE.CD, act.doer, 1) then return true end
			if act.target:HasTag("player") and not act.target:HasTag("playerghost") then
				AddDebuff(act.target, "buff_dota_release_positive")
			else
				AddDebuff(act.target, "buff_dota_release_negtive")
				PushEvent_MagicSingalTarget(act.doer, act.target, "DOTA_RELEASEPLUS")
			end
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.URN_OF_SHADOWS.RELEASE.SPELLRANGE,
	},
}
-------------------------------------------------宽容之靴 or 大绿鞋-------------------------------------------------
actions.endurance = {
	id = "DOTA_ENDURANCE",
	str = STRINGS.DOTA.NEWACTION.DOTA_ENDURANCE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_boots_of_bearing") then
			if not FiniteusesAndRechargeCheck(act.invobject, TUNING.DOTA.BOOTS_OF_BEARING.ENDURANCE.CD, act.doer, 1) then return true end

			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.BOOTS_OF_BEARING.ENDURANCE.RANGE, { "player" }, CANT_TAGS)
			for _, ent in ipairs(ents) do
				AddDebuff(ent, "buff_dota_endurance")
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/item_drum", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------梅肯斯姆-------------------------------------------------
actions.restore = {
	id = "DOTA_RESTORE",
	str = STRINGS.DOTA.NEWACTION.DOTA_RESTORE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_mekansm") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.MEKANSM.RESTORE.CD, act.doer) then return true end

			local outhealamp = act.doer.components.dotaattributes ~= nil and act.doer.components.dotaattributes.outhealamp:Get() or 0
			local delta = (1 + outhealamp) * TUNING.DOTA.MEKANSM.RESTORE.HEALTH
			
			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.MEKANSM.RESTORE.RANGE, { "player" }, CANT_TAGS)
			for _, ent in ipairs(ents) do
				if ent.components.health ~= nil and not ent.components.health:IsDead() then 	
					ent.components.health:DoDelta(delta, nil, "restore")
				end
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/mek_cast", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------韧鼓 or 战鼓-------------------------------------------------
actions.endurancedrum = {
	id = "DOTA_ENDURANCEDRUM",
	str = STRINGS.DOTA.NEWACTION.DOTA_ENDURANCEDRUM,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_drum_of_endurance") then
			if not FiniteusesAndRechargeCheck(act.invobject, TUNING.DOTA.DRUM_OF_ENDURANCE.ENDURANCE.CD, act.doer, 1) then return true end

			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.DRUM_OF_ENDURANCE.ENDURANCE.RANGE, { "player" }, CANT_TAGS)
			for _, ent in ipairs(ents) do
				AddDebuff(ent, "buff_dota_endurancedrum")
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/item_drum", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------圣洁吊坠-------------------------------------------------
local HOLY_LOCKET_HEALTH = TUNING.DOTA.HOLY_LOCKET.CHARGE.HEAL
local HOLY_LOCKET_MANA = TUNING.DOTA.HOLY_LOCKET.CHARGE.MANA
actions.charge = {
	id = "DOTA_CHARGE",
	str = STRINGS.DOTA.NEWACTION.DOTA_CHARGE,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_charge") then
			local item = FindActivateItemByDoer(act.doer, "dota_holy_locket")
			if item == nil then return ActionFailed(act.doer) end
			if not RechargeCheck(item, TUNING.DOTA.HOLY_LOCKET.CHARGE.CD, act.doer) then return true end
			MagicTickHeal(item, act.doer, act.target, HOLY_LOCKET_HEALTH, HOLY_LOCKET_MANA, "dota_charge")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.HOLY_LOCKET.CHARGE.SPELLRANGE,
	},
}
-------------------------------------------------卫士胫甲 or 大鞋-------------------------------------------------
actions.mend = {
	id = "DOTA_MEND",
	str = STRINGS.DOTA.NEWACTION.DOTA_MEND,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_guardian_greaves") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.GUARDIAN_GREAVES.MEND.CD, act.doer) then return true end

			local outhealamp = act.doer.components.dotaattributes ~= nil and act.doer.components.dotaattributes.outhealamp:Get() or 0
			local health = (1 + outhealamp) * TUNING.DOTA.GUARDIAN_GREAVES.MEND.HEALTH
			local mana = (1 + outhealamp) * TUNING.DOTA.GUARDIAN_GREAVES.MEND.MANA
			
			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.DRUM_OF_ENDURANCE.ENDURANCE.RANGE, { "player" }, CANT_TAGS)
			for _, ent in ipairs(ents) do
				if ent.components.health ~= nil and not ent.components.health:IsDead() then
					ent.components.health:DoDelta(health, nil, "mend")
					if ent.components.dotaattributes ~= nil then	
						ent.components.dotaattributes:Mana_DoDelta(mana, nil, "mend")
					end
				end
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/guardian_greaves", nil, BASE_VOICE_VOLUME)
			-- TODO:驱散效果待制作
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------勇气勋章-------------------------------------------------	
actions.valor = {
	id = "DOTA_VALOR",
	str = STRINGS.DOTA.NEWACTION.DOTA_VALOR,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_valor") and (act.doer ~= act.target) then
			local item = FindActivateItemByDoer(act.doer, "dota_medallion_of_courage")
			if item == nil then return ActionFailed(act.doer) end
			if not RechargeCheck(item, TUNING.DOTA.MEDALLION_OF_COURAGE.VALOR.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_valor_negtive")
			if act.target:HasTag("player") and not act.target:HasTag("playerghost") then
				AddDebuff(act.target, "buff_dota_valor_positive")
			else
				AddDebuff(act.target, "buff_dota_valor_negtive")
			end
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.MEDALLION_OF_COURAGE.VALOR.SPELLRANGE,
	},
}
-------------------------------------------------怨灵之契-------------------------------------------------
local reprisal_mana = TUNING.DOTA.WRAITH_PACT.REPRISAL.MANA
actions.reprisal = {
	id = "DOTA_REPRISAL",
	str = STRINGS.DOTA.NEWACTION.DOTA_REPRISAL,
	fn = function(act)	-- TODO: 待制作
		if StandardInvobjectActioniTest(act, "dota_wraith_pact") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.WRAITH_PACT.REPRISAL.CD, act.doer) then return true end

			local pos = act.doer:GetPosition()

			local elite = SpawnPrefab("pigelitefighter"..math.random(4))
			elite.Transform:SetPosition(pos.x, (act.doer.components.rider ~= nil and act.doer.components.rider:IsRiding()) and 3 or 0, pos.z)
			elite.components.follower:SetLeader(act.doer)

			local theta = math.random() * PI2
			local offset = FindWalkableOffset(pos, theta, 2.5, 16, true, true, nil, false, true)
							or FindWalkableOffset(pos, theta, 2.5, 16, false, false, nil, false, true)
							or Vector3(0, 0, 0)

			pos.x, pos.y, pos.z = pos.x + offset.x, 0, pos.z + offset.z
			elite.sg:GoToState("spawnin", { dest = pos })

			if not elite.components.timer then elite:AddComponent("timer") end
			if elite.components.timer:TimerExists("despawn_timer") then
				elite.components.timer:StopTimer("despawn_timer")
			end
			elite.components.timer:StartTimer("despawn_timer", TUNING.DOTA.WRAITH_PACT.REPRISAL.DURATION)

			if elite.components.health then
				local maxhealth = elite.components.health.maxhealth
				elite.components.health:SetMaxHealth(4 * maxhealth)
			end

			ItemManaDelta(act.doer, act.invobject, nil ,"dota_reprisal")
			return true
	   end
	   return ActionFailed(act.doer)
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/wraith_totem_spawn", nil, BASE_VOICE_VOLUME)
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/wraith_totem_pulse", nil, BASE_VOICE_VOLUME)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
------------------------------------------eul的神圣法杖 or 吹风----------------------------------------------
local cyclone_mana = TUNING.DOTA.EULS.CYCLONE.MANA
actions.cyclone = {
	id = "DOTA_CYCLONE",
	str = STRINGS.DOTA.NEWACTION.DOTA_CYCLONE,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_cyclone")
		and (act.doer == act.target or not act.target:HasTag("player")) then
			local item = FindActivateItemByDoer(act.doer, "dota_euls_scepter_of_divinity")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.EULS.CYCLONE.CD, act.doer) then return true end
			AddDebuff(act.target, "buff_dota_cyclone", {attacker = act.doer})
			ChangeActivate(item, act.doer)
			PlaySound(act.doer, "mengsk_dota2_sounds/items/dota_item_cyclone", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, item, nil ,"dota_cyclone")
			return true
	   end
	   return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.EULS.CYCLONE.SPELLRANGE,
	},
}
-------------------------------------------------阿托斯之棍-------------------------------------------------
local cripple_mana = TUNING.DOTA.ROD_OF_ATOS.CRIPPLE.MANA
actions.cripple = {
	id = "DOTA_CRIPPLE",
	str = STRINGS.DOTA.NEWACTION.DOTA_CRIPPLE,
	fn = function(act)	-- 想要让阿托斯特效表现出来，就虚拟武器投出投掷物
						-- 大致流程为： 
						-- 1.创建虚拟远程武器 
						-- 2.虚拟远程武器执行攻击代码，通过 weapon-components 内的 LaunchProjectile-api 投掷 bomb-prefeb
						-- 3.触发 bomb-prefeb 的 complexprojectile-components 内的 Launch-api 开始渲染投掷轨迹
						-- 4.bomb-prefeb 位置达到临界值， complexprojectile-components 渲染结束， 执行 Hit-api
						-- 5.bomb-prefeb 执行命中部分，流程结束
						-- (饥荒里那么多种远程武器的实现方法是为了什么？)

		if StandardTargetAndActivateActioniTest(act, "dota_cripple") then
			local item = FindActivateItemByDoer(act.doer, "dota_rod_of_atos")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.ROD_OF_ATOS.CRIPPLE.CD, act.doer) then return true end

			if item.fakeweapon == nil then item.EquipWeapons(item) end	-- 创建虚拟武器
			if act.doer.components.combat ~= nil and item.fakeweapon then
				item.fakeweapon.components.weapon:LaunchProjectile(act.doer, act.target)
			end

			PlaySound(act.doer, "mengsk_dota2_sounds/items/rod_of_atos", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, item, nil ,"dota_cripple")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.ROD_OF_ATOS.CRIPPLE.SPELLRANGE,
	},
}
-------------------------------------------------达贡之神力 or 大根-------------------------------------------------
local burst1_mana = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL1
local burst2_mana = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL2
local burst3_mana = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL3
local burst4_mana = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL4
local burst5_mana = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL5

local function DoLishtingStrike(inst, attacker, damage, weapon)
    if inst.components.combat ~= nil then
		SpawnPrefab("dota_fx_lightning").Transform:SetPosition(inst.Transform:GetWorldPosition())	-- TODO：将官方的闪电替换成大根特效
		PlaySound(attacker, "mengsk_dota2_sounds/items/dagon", nil, BASE_VOICE_VOLUME)
		inst.components.combat:GetAttacked(attacker, damage, weapon, "dotamagic")
		PushEvent_MagicSingalTarget(attacker, inst, "DOTA_RELEASEPLUS")
    end
	-- if inst.components.burnable ~= nil then	-- 点燃
	-- 	inst.components.burnable:Ignite()
	-- end
end

actions.burst1 = {
	id = "DOTA_BURST1",
	str = STRINGS.DOTA.NEWACTION.DOTA_BURST1,
	fn = function(act)	-- TODO: 待制作
		if StandardTargetAndActivateActioniTest(act, "dota_burst1") then
			local item = FindActivateItemByDoer(act.doer, "dota_dagon_level1")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.DAGON_ENERGY.BURST.CD.LEVEL1, act.doer) then return true end
			DoLishtingStrike(act.target, act.doer, TUNING.DOTA.DAGON_ENERGY.BURST.DAMAGE.LEVEL1, item)	-- TODO：技能伤害增强究竟放在这还是combat里呢？
			ItemManaDelta(act.doer, item, nil ,"dota_burst1")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		distance=TUNING.DOTA.DAGON_ENERGY.BURST.SPELLRANGE.LEVEL1,
		mount_valid=false,
	},
}
actions.burst2 = {
	id = "DOTA_BURST2",
	str = STRINGS.DOTA.NEWACTION.DOTA_BURST2,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_burst2") then
			local item = FindActivateItemByDoer(act.doer, "dota_dagon_level2")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.DAGON_ENERGY.BURST.CD.LEVEL2, act.doer) then return true end
			DoLishtingStrike(act.target, act.doer, TUNING.DOTA.DAGON_ENERGY.BURST.DAMAGE.LEVEL2, item)	-- TODO：技能伤害增强究竟放在这还是combat里呢？
			ItemManaDelta(act.doer, item, nil ,"dota_burst2")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		distance=TUNING.DOTA.DAGON_ENERGY.BURST.SPELLRANGE.LEVEL2,
		mount_valid=false,
	},
}
actions.burst3 = {
	id = "DOTA_BURST3",
	str = STRINGS.DOTA.NEWACTION.DOTA_BURST3,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_burst3") then
			local item = FindActivateItemByDoer(act.doer, "dota_dagon_level3")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.DAGON_ENERGY.BURST.CD.LEVEL3, act.doer) then return true end
			DoLishtingStrike(act.target, act.doer, TUNING.DOTA.DAGON_ENERGY.BURST.DAMAGE.LEVEL3, item)	-- TODO：技能伤害增强究竟放在这还是combat里呢？
			ItemManaDelta(act.doer, item, nil ,"dota_burst3")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		distance=TUNING.DOTA.DAGON_ENERGY.BURST.SPELLRANGE.LEVEL3,
		mount_valid=false,
	},
}
actions.burst4 = {
	id = "DOTA_BURST4",
	str = STRINGS.DOTA.NEWACTION.DOTA_BURST4,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_burst4") then
			local item = FindActivateItemByDoer(act.doer, "dota_dagon_level4")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.DAGON_ENERGY.BURST.CD.LEVEL4, act.doer) then return true end
			DoLishtingStrike(act.target, act.doer, TUNING.DOTA.DAGON_ENERGY.BURST.DAMAGE.LEVEL4, item)	-- TODO：技能伤害增强究竟放在这还是combat里呢？
			ItemManaDelta(act.doer, item, nil ,"dota_burst4")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		distance=TUNING.DOTA.DAGON_ENERGY.BURST.SPELLRANGE.LEVEL4,
		mount_valid=false,
	},
}
actions.burst5 = {
	id = "DOTA_BURST5",
	str = STRINGS.DOTA.NEWACTION.DOTA_BURST5,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_burst5") then
			local item = FindActivateItemByDoer(act.doer, "dota_dagon_level5")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.DAGON_ENERGY.BURST.CD.LEVEL5, act.doer) then return true end
			DoLishtingStrike(act.target, act.doer, TUNING.DOTA.DAGON_ENERGY.BURST.DAMAGE.LEVEL5, item)	-- TODO：技能伤害增强究竟放在这还是combat里呢？
			ItemManaDelta(act.doer, item, nil ,"dota_burst5")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		distance=TUNING.DOTA.DAGON_ENERGY.BURST.SPELLRANGE.LEVEL5,
		mount_valid=false,
	},
}
-------------------------------------------------风之杖 or 大吹风-------------------------------------------------
local cycloneplus_mana = TUNING.DOTA.EULS.CYCLONE.MANA
actions.cycloneplus = {
	id = "DOTA_CYCLONEPLUS",
	str = STRINGS.DOTA.NEWACTION.DOTA_CYCLONEPLUS,
	fn = function(act)	-- TODO: 待制作
		if StandardTargetAndActivateActioniTest(act, "dota_cycloneplus") then
			local item = FindActivateItemByDoer(act.doer, "dota_wind_waker")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.WIND_WAKER.CD, act.doer) then return true end
			
			if act.target == act.doer then
				AddDebuff(act.target, "buff_dota_cycloneplus")
			else
				AddDebuff(act.target, "buff_dota_cyclone", {attacker = act.doer})
			end

			ChangeActivate(item, act.doer)
			PlaySound(act.doer, "mengsk_dota2_sounds/items/dota_item_cyclone", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, item, nil ,"dota_cyclone")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.EULS.CYCLONE.SPELLRANGE,
	},
}
-------------------------------------------------缚灵索-------------------------------------------------
local chains_mana = TUNING.DOTA.GLEIPNIR.ETERNAL.MANA
actions.chains = {
	id = "DOTA_CHAINS",
	str = STRINGS.DOTA.NEWACTION.DOTA_CHAINS,
	fn = function(act)	-- TODO: 待制作
		if act.doer ~= nil and act.doer:HasTag("player") and act.doer:HasTag("dota_chains") then
			local item = FindActivateItemByDoer(act.doer, "dota_gleipnir")
			if item == nil then return AoeActionFailed(act.doer, item) end
			if not IsManaEnough(act.doer, item) then return AoeActionFailed(act.doer, item) end
			if not RechargeCheck(item, TUNING.DOTA.GLEIPNIR.ETERNAL.CD, act.doer) then return AoeActionFailed(act.doer, item) end

			if item.fakeweapon == nil then item.EquipWeapons(item) end	-- 创建虚拟武器

			local pos = act:GetActionPoint() or act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.GLEIPNIR.ETERNAL.RANGE, { "_combat" }, exceuce_tags)
			for _, ent in ipairs(ents) do
				if item.fakeweapon then
					item.fakeweapon.components.weapon:LaunchProjectile(act.doer, ent)
				end
			end

			PlaySound(act.doer, "mengsk_dota2_sounds/items/rod_of_atos", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, item, nil ,"dota_cripple")
			ChangeActivate(item, act.doer)
			AoeActionSucceed(act.doer, item)
			-- TakeOverPlayerController(act.doer, false)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.GLEIPNIR.ETERNAL.SPELLRANGE,
	},
}
-------------------------------------------------刷新球-------------------------------------------------
local resetcooldowns_mana = TUNING.DOTA.REFRESHER_ORB.RESETCOOLDOWNS.MANA
local function resetcooldownsfn(inst)
	if inst.components.rechargeable and not inst.components.rechargeable:IsCharged() 
	 and inst.prefab ~= "dota_refresher_orb" -- 刷新碎片刷刷新（确信
	 then 
		inst.components.rechargeable:SetCharge(inst.components.rechargeable.total, true)
	end
end

actions.resetcooldowns = {
	id = "DOTA_RESETCOOLDOWNS",
	str = STRINGS.DOTA.NEWACTION.DOTA_RESETCOOLDOWNS,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_refresher_orb") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.REFRESHER_ORB.RESETCOOLDOWNS.CD, act.doer) then return true end
			if act.doer.components.dotasharedcoolingable then
				act.doer.components.dotasharedcoolingable:ResetCoolingDown()
			end
			if act.doer.components.inventory then
				act.doer.components.inventory:ForEachItem(resetcooldownsfn)
			end
			for _, v in pairs(act.doer.components.inventory.equipslots) do	-- 遍历装备栏
				if v.components.container ~= nil and v.components.container.canbeopened then
					v.components.container:ForEachItem(resetcooldownsfn)
				end
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/refresher", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_resetcooldowns")
			return true
		 end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------微光披风------------------------------------------------- 
local glimmer_mana = TUNING.DOTA.GLIMMER_CAPE.GLIMMER.MANA
actions.glimmer = {
	id = "DOTA_GLIMMER",
	str = STRINGS.DOTA.NEWACTION.DOTA_GLIMMER,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_glimmer") and
		 act.target:HasTag("player") and not act.target:HasTag("playerghost") then
			local item = FindActivateItemByDoer(act.doer, "dota_glimmer_cape")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.GLIMMER_CAPE.GLIMMER.CD, act.doer) then return true end
			AddDebuff(act.target, "buff_dota_glimmer")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/glimmer_cape", nil, BASE_VOICE_VOLUME)
			ChangeActivate(item, act.doer)
			ItemManaDelta(act.doer, item, nil ,"dota_glimmer")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.GLIMMER_CAPE.GLIMMER.SPELLRANGE,
	},
}
-------------------------------------------------邪恶镰刀 or 羊刀-------------------------------------------------
local hex_mana = TUNING.DOTA.SCYTHE_OF_VYSE.HEX.MANA
actions.hex = {
	id = "DOTA_HEX",
	str = STRINGS.DOTA.NEWACTION.DOTA_HEX,
	fn = function(act)	-- TODO: 待制作
		if StandardTargetAndActivateActioniTest(act, "dota_hex") then
			local item = FindActivateItemByDoer(act.doer, "dota_scythe_of_vyse")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.SCYTHE_OF_VYSE.HEX.CD, act.doer) then return true end
			AddDebuff(act.target, "buff_dota_hex")
			PushEvent_MagicSingalTarget(act.doer, act.target, "dota_hex")
			ItemManaDelta(act.doer, item, nil ,"dota_hex")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.SCYTHE_OF_VYSE.HEX.SPELLRANGE,
	},
}
-------------------------------------------------炎阳纹章 or 大勋章-------------------------------------------------
actions.shine = {
	id = "DOTA_SHINE",
	str = STRINGS.DOTA.NEWACTION.DOTA_SHINE,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_shine") and (act.target ~= act.doer) then
			local item = FindActivateItemByDoer(act.doer, "dota_solar_crest")
			if item == nil then return ActionFailed(act.doer) end
			if not RechargeCheck(item, TUNING.DOTA.SOLAR_CREST.SHINE.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_valor_self")
			if act.target:HasTag("player") and not act.target:HasTag("playerghost") then
				AddDebuff(act.target, "buff_dota_shine_positive")
			else
				AddDebuff(act.target, "buff_dota_shine_negtive")
			end
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.SOLAR_CREST.SHINE.SPELLRANGE,
	},
}
-------------------------------------------------原力法杖 or 推推棒-------------------------------------------------
local force_mana = TUNING.DOTA.FORCE_STAFF.FORCE.MANA
local function UpdateForce(inst, creature)
	if creature.inst:IsValid() and creature.inst.entity:IsVisible() and creature.speed ~= nil then
		-- if creature.inst.components.locomotor ~= nil then
			-- creature.inst.components.locomotor:Stop()
			-- creature.inst.components.locomotor:ResetPath()
			-- -- creature.inst.components.locomotor:Clear()
		-- end
		RemovePhysicsColliders(creature.inst)
		creature.inst.Physics:SetMotorVelOverride(creature.speed, 0, 0)
	end
end

local function TimeoutForce(inst, creature, task, source)
    task:Cancel()
	ChangeToCharacterPhysics(creature.inst)
	if creature.inst.components.locomotor ~= nil then
		-- if creature.inst.components.locomotor.directdrive then
			-- print(creature.inst.prefab .. "   directdrive: " .. creature.inst.components.locomotor.directdrive)
		-- end
		if creature.inst.components.locomotor:HasDestination() then
			creature.inst.components.locomotor:FindPath()
		end
		creature.inst.components.locomotor:Dota_CanMove(true, source)
	end
	-- if creature.inst.components.playercontroller ~= nil then
		-- creature.inst.components.playercontroller:Enable(true)
	-- end
	if creature.speed ~= nil then
		creature.inst.Physics:ClearMotorVelOverride()
		creature.inst.Physics:Stop()
	end
	
end

local function DoForce(inst, fx)
	local FORCE_DURATION = TUNING.DOTA.FORCE_STAFF.FORCE.DURATION
	local FORCE_SPEED = TUNING.DOTA.FORCE_STAFF.FORCE.SPEED
	local creature = {inst = inst, speed = FORCE_SPEED}
	-- if inst.components.playercontroller ~= nil then
		-- inst.components.playercontroller:Enable(false)
	-- end
	if creature.inst.components.locomotor ~= nil then
		creature.inst.components.locomotor:Dota_CanMove(false, "force")
		-- creature.inst.components.locomotor:Clear()
	end
	inst:DoTaskInTime(FORCE_DURATION, TimeoutForce, creature,
            inst:DoPeriodicTask(0, UpdateForce, nil, creature),
			"force"
	)
	if fx then
		for k=0,30 do
			inst:DoTaskInTime(FRAMES*math.ceil(2+k/5),function()
				local a=SpawnPrefab("alterguardian_lasertrail")
				local pos1=inst:GetPosition()
				a.Transform:SetPosition(pos1.x,pos1.y,pos1.z)
			end)
		end
	end
end

actions.force = {
	id = "DOTA_FORCE",
	str = STRINGS.DOTA.NEWACTION.DOTA_FORCE,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_force") then
			local item = FindActivateItemByDoer(act.doer, "dota_force_staff")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.FORCE_STAFF.FORCE.CD, act.doer) then return true end

			DoForce(act.target, true)
			PlaySound(act.doer, "mengsk_dota2_sounds/items/force_staff", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, item, nil ,"dota_force")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	-- state = "dota_sg_nil",
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.FORCE_STAFF.FORCE.SPELLRANGE,
	},
}
-------------------------------------------------紫怨-------------------------------------------------
local burnx_mana = TUNING.DOTA.ORCHID_MALEVOLENCE.BURNX.MANA
actions.burnx = {
	id = "DOTA_BURNX",
	str = STRINGS.DOTA.NEWACTION.DOTA_BURNX,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_burnx") then
			local item = FindActivateItemByDoer(act.doer, "dota_orchid_malevolence")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.ORCHID_MALEVOLENCE.BURNX.CD, act.doer) then return true end
			AddDebuff(act.target, "buff_dota_burnx", {attacker = act.doer})
			PushEvent_MagicSingalTarget(act.doer, act.target, "dota_burnx")
			ItemManaDelta(act.doer, item, nil ,"dota_burnx")
			ChangeActivate(item, act.doer)
			return true
	   end
	   return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.ORCHID_MALEVOLENCE.BURNX.SPELLRANGE,
	},
}
-------------------------------------------------赤红甲-------------------------------------------------
actions.guard = {
	id = "DOTA_GUARD",
	str = STRINGS.DOTA.NEWACTION.DOTA_GUARD,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_crimson_guard") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.CRIMSON_GUARD.GUARD.CD, act.doer) then return true end

			local pos = act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.CRIMSON_GUARD.GUARD.RANGE, { "player" }, CANT_TAGS)
			for _, ent in ipairs(ents) do
				AddDebuff(ent, "buff_dota_guard")
			end
			-- TODO：驱散效果待制作
			PlaySound(act.doer, "mengsk_dota2_sounds/items/crimson_guard", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------黑黄杖 or BKB-------------------------------------------------
local avatar_mana = TUNING.DOTA.BLACK_KING_BAR.AVATAR.MANA
actions.avatar = {
	id = "DOTA_AVATAR",
	str = STRINGS.DOTA.NEWACTION.DOTA_AVATAR,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_black_king_bar")then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.BLACK_KING_BAR.AVATAR.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_avatar")
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_avatar")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------幻影斧 or 分身斧-------------------------------------------------
local mirror_mana = TUNING.DOTA.MANTA_STYLE.MIRROR.MANA
actions.mirror = {
	id = "DOTA_MIRROR",
	str = STRINGS.DOTA.NEWACTION.DOTA_MIRROR,
	fn = function(act)	-- TODO: 待制作
		-- if not IsManaEnough(act.doer, mirror_mana) then return true end
		-- ItemManaDelta(act.doer, -mirror_mana, nil ,"dota_mirror")
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/manta", nil, BASE_VOICE_VOLUME)
		return ActionWalking(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------飓风长戟 or 大推推-------------------------------------------------
local thrust_mana = TUNING.DOTA.HURRICANE_PIKE.THRUST.MANA
local function DoThrust(inst, fx)
	local THRUST_DURATION = TUNING.DOTA.HURRICANE_PIKE.THRUST.DURATION
	local THRUST_SPEED = -TUNING.DOTA.HURRICANE_PIKE.THRUST.SPEED
	local creature = {inst = inst, speed = THRUST_SPEED}
	if creature.inst.components.locomotor ~= nil then
		creature.inst.components.locomotor:Dota_CanMove(false, "thrust")
		-- creature.inst.components.locomotor:Clear()
	end
	inst:DoTaskInTime(THRUST_DURATION, TimeoutForce, creature,
            inst:DoPeriodicTask(0, UpdateForce, nil, creature),
			"thrust"
	)
	if fx then
		for k=0,30 do
			inst:DoTaskInTime(FRAMES*math.ceil(2+k/5),function()
				local a=SpawnPrefab("alterguardian_lasertrail")
				local pos1=inst:GetPosition()
				a.Transform:SetPosition(pos1.x,pos1.y,pos1.z)
			end)
		end
	end
end

actions.thrust = {
	id = "DOTA_THRUST",
	str = STRINGS.DOTA.NEWACTION.DOTA_THRUST,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_thrust") then
			local item = FindActivateItemByDoer(act.doer, "dota_hurricane_pike")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.HURRICANE_PIKE.THRUST.CD, act.doer) then return true end

			if not act.target:HasTag("player") and act.doer:GetDistanceSqToInst(act.target) < 1 then	-- 与敌人的距离平方小于1
				-- TODO:当然我们需要计算一下玩家和角色的角度再传入，以后再做
				local x1, y1, z1 = act.doer.Transform:GetWorldPosition()
				local x2, y2, z2 = act.target.Transform:GetWorldPosition()
				act.doer:ForceFacePoint(x2, 0, z2)
				DoThrust(act.doer, true)
				act.target:ForceFacePoint(x1, 0, z1)
				DoThrust(act.target, true)
				PlaySound(act.doer, "mengsk_dota2_sounds/items/hurricane_pike", nil, BASE_VOICE_VOLUME)
			else
				DoForce(act.target, true)
				PlaySound(act.doer, "mengsk_dota2_sounds/items/force_staff", nil, BASE_VOICE_VOLUME)
			end
			ItemManaDelta(act.doer, item, nil ,"dota_thrust")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	-- state = "dota_sg_nil",
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.HURRICANE_PIKE.THRUST.SPELLRANGE,
	},
}
-------------------------------------------------林肯法球-------------------------------------------------
actions.mirror = {
	id = "DOTA_MIRROR",
	str = STRINGS.DOTA.NEWACTION.DOTA_MIRROR,
	fn = function(act)	-- TODO: 待制作
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/linkens_sphere", nil, BASE_VOICE_VOLUME)
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/linkens_target", nil, BASE_VOICE_VOLUME)
		return ActionWalking(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.LINKENS_SPHERE.BLOCK.SPELLRANGE,
	},
}
-------------------------------------------------清莲宝珠 or 莲花-------------------------------------------------
local shell_mana = TUNING.DOTA.LOTUS_ORB.SHELL.MANA
actions.shell = {
	id = "DOTA_SHELL",
	str = STRINGS.DOTA.NEWACTION.DOTA_SHELL,
	fn = function(act)	-- TODO: 待制作
		if StandardTargetAndActivateActioniTest(act, "dota_shell") and act.target:HasTag("player") then
			local item = FindActivateItemByDoer(act.doer, "dota_lotus_orb")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.LOTUS_ORB.SHELL.CD, act.doer) then return true end
			AddDebuff(act.target, "buff_dota_shell")
			ItemManaDelta(act.doer, item, nil ,"dota_shell")
			return true
	   end
	   return ActionWalking(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.LOTUS_ORB.SHELL.SPELLRANGE,
	},
}
-------------------------------------------------刃甲-------------------------------------------------
local return_mana = TUNING.DOTA.BLADE_MAIL.RETURN.MANA
actions.damagereturn = {	-- return怎么是保留词啊（恼
	id = "DOTA_RETURN",
	str = STRINGS.DOTA.NEWACTION.DOTA_RETURN,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_blade_mail") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.BLADE_MAIL.RETURN.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_return")
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_return")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------挑战头巾-------------------------------------------------
local insulation_mana = TUNING.DOTA.HOOD_OF_DEFIANCE.INSULATION.MANA
actions.insulation = {
	id = "DOTA_INSULATION",
	str = STRINGS.DOTA.NEWACTION.DOTA_INSULATION,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_hood_of_defiance") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.HOOD_OF_DEFIANCE.INSULATION.CD, act.doer) then return true end
			if act.doer.components.dotaattributes ~= nil then 
				act.doer.components.dotaattributes:CreateMagicShield("dota_shield_insulationfx")
			end
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_insulation")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------希瓦的守护 or 冰甲-------------------------------------------------
local blast_mana = TUNING.DOTA.MASK_OF_MADNESS.BERSERK.MANA
actions.blast = {
	id = "DOTA_BLAST",
	str = STRINGS.DOTA.NEWACTION.DOTA_BLAST,
	fn = function(act)	-- TODO: 待制作
		-- if not IsManaEnough(act.doer, blast_mana) then return true end
		-- ItemManaDelta(act.doer, -blast_mana, nil ,"dota_blast")
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/shivas_guard", nil, BASE_VOICE_VOLUME)
		return ActionWalking(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------血精石-------------------------------------------------
actions.bloodpact = {
	id = "DOTA_BLOODPACT",
	str = STRINGS.DOTA.NEWACTION.DOTA_BLOODPACT,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_bloodstone") then
			if act.doer:HasTag("bloodpactcd") then PlaySound_CoolingDown(act.doer) return true end	-- 疲惫值
			if not RechargeCheck(act.invobject, TUNING.DOTA.BLOODSTONE.BLOODPACT.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_bloodpact")
			AddDebuff(act.doer, "buff_dota_bloodpactcd")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/bloodstone_cast", nil, BASE_VOICE_VOLUME)
			return true
	   end
	   return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------永世法衣-------------------------------------------------
local shroud_mana = TUNING.DOTA.SHROUD.SHROUD.MANA
actions.shroud = {
	id = "DOTA_SHROUD",
	str = STRINGS.DOTA.NEWACTION.DOTA_SHROUD,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_eternal_shroud") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.SHROUD.SHROUD.CD, act.doer) then return true end
			if act.doer.components.dotaattributes ~= nil then 
				act.doer.components.dotaattributes:CreateMagicShield("dota_shield_shroudfx")
			end
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_shroud")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------白银之锋 or 大隐刀-------------------------------------------------
local walkplus_mana = TUNING.DOTA.SILVER_EDGE.WALK.MANA
actions.walkplus = {
	id = "DOTA_WALKPLUS",
	str = STRINGS.DOTA.NEWACTION.DOTA_WALK,
	fn = function(act)	-- TODO: 待制作
		if StandardInvobjectActioniTest(act, "dota_silver_edge") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.SILVER_EDGE.WALK.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_walkplus")
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_walkplus")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------否决坠饰-------------------------------------------------
local nullify_mana = TUNING.DOTA.NULLIFIER.NULLIFY.MANA
actions.nullify = {
	id = "DOTA_NULLIFY",
	str = STRINGS.DOTA.NEWACTION.DOTA_NULLIFY,
	fn = function(act)	-- TODO: 待制作
		if StandardTargetAndActivateActioniTest(act, "dota_nullify") then
			local item = FindActivateItemByDoer(act.doer, "dota_nullifier")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.NULLIFIER.NULLIFY.CD, act.doer) then return true end

			if item.fakeweapon == nil then item.EquipWeapons(item) end	-- 创建虚拟武器
			if act.doer.components.combat and item.fakeweapon then
				item.fakeweapon.components.weapon:LaunchProjectile(act.doer, act.target)
			end

			ItemManaDelta(act.doer, item, nil ,"dota_nullify")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.NULLIFIER.NULLIFY.SPELLRANGE,
	},
}
-------------------------------------------------蝴蝶-------------------------------------------------
actions.flutter = {
	id = "DOTA_FLUTTER",
	str = STRINGS.DOTA.NEWACTION.DOTA_FLUTTER,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_butterfly") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.BUTTERFLY.FLUTTER.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_flutter")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------辉耀-------------------------------------------------
actions.burn = {
	id = "DOTA_BURN",
	str = STRINGS.DOTA.NEWACTION.DOTA_BURN,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_radiance") then
			if act.invobject.burnstata ~= nil then
				if act.invobject.burnstata == true then
					act.invobject.burnstata = false
					act.invobject.updateburn(false ,act.doer)
				elseif act.invobject.burnstata == false then
					act.invobject.burnstata = true
					act.invobject.updateburn(true, act.doer)
				end
			end
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------莫尔迪基安的臂章-------------------------------------------------
actions.unholy = {
	id = "DOTA_UNHOLY",
	str = STRINGS.DOTA.NEWACTION.DOTA_UNHOLY,
	fn = function(act)	-- TODO: 待制作
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/item_armlet_activate", nil, BASE_VOICE_VOLUME)
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/item_armlet_deactivate", nil, BASE_VOICE_VOLUME)
		return ActionWalking(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------深渊之刃 or 大晕-------------------------------------------------
local overwhelm_mana = TUNING.DOTA.ABYSSAL_BLADE.OVERWHELM.MANA
actions.overwhelm = {
	id = "DOTA_OVERWHELM",
	str = STRINGS.DOTA.NEWACTION.DOTA_OVERWHELM,
	fn = function(act)	-- TODO: 待制作
		-- if not IsManaEnough(act.doer, overwhelm_mana) then return true end
		-- ItemManaDelta(act.doer, -overwhelm_mana, nil ,"dota_overwhelm")
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/abyssal_blade", nil, BASE_VOICE_VOLUME)
		return ActionWalking(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.ABYSSAL_BLADE.OVERWHELM.SPELLRANGE,
	},
}
-------------------------------------------------虚灵之刃-------------------------------------------------
local ethereal_mana = TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.MANA
actions.ethereal = {
	id = "DOTA_ETHEREAL",
	str = STRINGS.DOTA.NEWACTION.DOTA_ETHEREAL,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_ethereal") then
			local item = FindActivateItemByDoer(act.doer, "dota_ethereal_blade")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.CD, act.doer) then return true end

			if item.fakeweapon == nil then item.EquipWeapons(item) end	-- 创建虚拟武器
			if act.doer.components.combat and item.fakeweapon then
				item.fakeweapon.components.weapon:LaunchProjectile(act.doer, act.target)
			end

			ItemManaDelta(act.doer, item, nil ,"dota_ethereal")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.SPELLRANGE,
	},
}
-------------------------------------------------血棘 or 大紫怨-------------------------------------------------
local rend_mana = TUNING.DOTA.BLOODTHORN.REND.MANA
actions.rend = {
	id = "DOTA_REND",
	str = STRINGS.DOTA.NEWACTION.DOTA_REND,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_rend") then
			print(1)
		   local item = FindActivateItemByDoer(act.doer, "dota_bloodthorn")
		   if item == nil then return ActionFailed(act.doer) end
		   print(2)
		   if not IsManaEnough(act.doer, item) then return true end
		   if not RechargeCheck(item, TUNING.DOTA.BLOODTHORN.REND.CD, act.doer) then return true end
		   AddDebuff(act.target, "buff_dota_rend", {attacker = act.doer})
		   PushEvent_MagicSingalTarget(act.doer, act.target, "dota_rend")
		   ItemManaDelta(act.doer, item, nil ,"dota_rend")
		   ChangeActivate(item, act.doer)
		   return true
	  end
	  return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------英灵胸针-------------------------------------------------
local province_mana = TUNING.DOTA.REVENANTS_BROOCH.PROVINCE.MANA
actions.province = {
	id = "DOTA_PROVINCE",
	str = STRINGS.DOTA.NEWACTION.DOTA_PROVINCE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_revenants_brooch") then
		   if not IsManaEnough(act.doer, act.invobject) then return true end
		   if not RechargeCheck(act.invobject,  TUNING.DOTA.REVENANTS_BROOCH.PROVINCE.CD, act.doer) then return true end
		   AddDebuff(act.doer, "buff_dota_province")
		   ItemManaDelta(act.doer, act.invobject, nil ,"dota_province")
		   return true
	   end
	   return ActionFailed(act.doer)
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/brooch_cast", nil, BASE_VOICE_VOLUME)
		-- PlaySound(act.doer, "mengsk_dota2_sounds/items/brooch_target", nil, BASE_VOICE_VOLUME)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------隐刀-------------------------------------------------
local walk_mana = TUNING.DOTA.INVIS_SWORD.WALK.MANA
actions.walk = {
	id = "DOTA_WALK",
	str = STRINGS.DOTA.NEWACTION.DOTA_WALK,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_invis_sword") then
			if not IsManaEnough(act.doer, act.invobject) then return true end
			if not RechargeCheck(act.invobject, TUNING.DOTA.SILVER_EDGE.WALK.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_walk")
			ItemManaDelta(act.doer, act.invobject, nil ,"dota_walk")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------陨星锤-------------------------------------------------
local meteor_mana = TUNING.DOTA.METEOR_HAMMER.METEOR.MANA
local meteor_range = TUNING.DOTA.METEOR_HAMMER.METEOR.RANGE

local function MeteorLaunch(x, y, z, mod)
	-- 随机位置
	local theta = math.random() * 2 * PI
	local radius = easing.outSine(math.random(), math.random() * meteor_range, meteor_range, 1)
	local fan_offset = FindValidPositionByFan(theta, radius, 30,
		function(offset)
			return TheWorld.Map:IsPassableAtPoint(x + offset.x, y + offset.y, z + offset.z)
		end) or Vector3(0,0,0)
	local meteor = SpawnPrefab("shadowmeteor")
	meteor.Transform:SetPosition(x + fan_offset.x, y + fan_offset.y, z + fan_offset.z)

	if mod == nil then
		mod = 1
	end

	-- 随机大小
	local peripheral = radius > TUNING.METEOR_SHOWER_SPAWN_RADIUS - TUNING.METEOR_SHOWER_CLEANUP_BUFFER
	local rand = not peripheral and math.random() or 1
	if rand <= TUNING.METEOR_LARGE_CHANCE then
		meteor:SetSize("large", mod)
	elseif rand <= TUNING.METEOR_MEDIUM_CHANCE then
		meteor:SetSize("medium", mod)
	else
		meteor:SetSize("small", mod)
	end
	meteor:SetPeripheral(peripheral)
end

local function MeteorShower(inst, x, y, z)
	local num = math.random(5,15)	-- 流星数量
	inst:StartThread(function()
		for k = 0, num-1 do
			MeteorLaunch(x, y, z, 1)
			Sleep(.3 + math.random() * .2)
		end
	end)
end

actions.meteor = {
	id = "DOTA_METEOR",
	str = STRINGS.DOTA.NEWACTION.DOTA_METEOR,
	fn = function(act)
		if act.doer and act.doer:HasTag("player") and act.doer:HasTag("dota_meteor") then
			local item = FindActivateItemByDoer(act.doer, "dota_meteor_hammer")
			if item == nil then return AoeActionFailed(act.doer, item) end
			if not IsManaEnough(act.doer, item) then return AoeActionFailed(act.doer, item) end
			if not RechargeCheck(item, TUNING.DOTA.METEOR_HAMMER.METEOR.CD, act.doer) then return AoeActionFailed(act.doer, item) end
			local x, y, z = act:GetActionPoint():Get()
			MeteorShower(act.doer, x, y, z)
			ItemManaDelta(act.doer, item, nil ,"dota_meteor")
			ChangeActivate(item, act.doer)
			AoeActionSucceed(act.doer, item)
			-- TakeOverPlayerController(act.doer, false)
			return true
		end
		return ActionFailed(act.doer)
	-- PlaySound(act.doer, "mengsk_dota2_sounds/items/meteor_fall", nil, BASE_VOICE_VOLUME)
	-- PlaySound(act.doer, "mengsk_dota2_sounds/items/meteor_hammer_channel", nil, BASE_VOICE_VOLUME)
	-- PlaySound(act.doer, "mengsk_dota2_sounds/items/meteor_impact", nil, BASE_VOICE_VOLUME)
	end,
	state = function(inst, action)
		return StateTest(inst, "dota_meteor", "dota_sg_meteor", meteor_mana)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.METEOR_HAMMER.METEOR.SPELLRANGE,
	},
}
-------------------------------------------------天堂之戟-------------------------------------------------
local disarm_mana = TUNING.DOTA.HEAVENS_HALBERD.DISARM.MANA
actions.disarm = {
	id = "DOTA_DISARM",
	str = STRINGS.DOTA.NEWACTION.DOTA_DISARM,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_disarm") then
			local item = FindActivateItemByDoer(act.doer, "dota_heavens_halberd")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.HEAVENS_HALBERD.DISARM.CD, act.doer) then return true end
			-- if act.target.components.debuffable ~= nil then
			-- 	act.target.components.debuffable:AddDebuff("buff_dota_disarm", "buff_dota_disarm")
			-- end
			if act.target.components.combat ~= nil then
				act.target.components.combat:BlankOutAttacks(TUNING.DOTA.HEAVENS_HALBERD.DISARM.DURATION)
			end
			PushEvent_MagicSingalTarget(act.doer, act.target, "dota_disarm")
			ChangeActivate(item, act.doer)
			PlaySound(act.doer, "mengsk_dota2_sounds/items/heavens_halberd", nil, BASE_VOICE_VOLUME)
			ItemManaDelta(act.doer, item, nil ,"dota_disarm")
			return true
		end
		return ActionWalking(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.HEAVENS_HALBERD.DISARM.SPELLRANGE,
	},
}
-------------------------------------------------撒旦之邪力 or 大吸-------------------------------------------------
actions.rage = {
	id = "DOTA_RAGE",
	str = STRINGS.DOTA.NEWACTION.DOTA_RAGE,
	fn = function(act)
		if StandardInvobjectActioniTest(act, "dota_satanic") then
			if not RechargeCheck(act.invobject, TUNING.DOTA.SATANIC.RAGE.CD, act.doer) then return true end
			AddDebuff(act.doer, "buff_dota_rage")
			PlaySound(act.doer, "mengsk_dota2_sounds/items/item_satanic", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------净魂之刃 or 散失-------------------------------------------------
actions.inhibit = {
	id = "DOTA_INHIBIT",
	str = STRINGS.DOTA.NEWACTION.DOTA_INHIBIT,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_inhibit") then
			local item = FindActivateItemByDoer(act.doer, "dota_diffusal_blade")
			if item == nil then return ActionFailed(act.doer) end
			if not RechargeCheck(act.invobject, TUNING.DOTA.DIFFUSAL_BLADE.INHIBIT.CD, act.doer) then return true end
			AddDebuff(act.target, "buff_dota_inhibit")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.DIFFUSAL_BLADE.INHIBIT.SPELLRANGE,
	},
}
-------------------------------------------------雷神之锤 or 大雷锤 or 大电锤-------------------------------------------------	
local lighting_mana = TUNING.DOTA.MJOLLNIR.STATIC.MANA
actions.lighting = {
	id = "DOTA_LIGHTING",
	str = STRINGS.DOTA.NEWACTION.DOTA_LIGHTING,
	fn = function(act)	-- TODO: 待制作
		if StandardTargetAndActivateActioniTest(act, "dota_lighting") then
			local item = FindActivateItemByDoer(act.doer, "dota_mjollnir")
			if item == nil then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.MJOLLNIR.STATIC.CD, act.doer) then return true end
			AddDebuff(act.target, "buff_dota_lighting")
			ItemManaDelta(act.doer, item, nil ,"dota_lighting")
			ChangeActivate(item, act.doer)
			return true
		end
		return ActionWalking(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.MJOLLNIR.STATIC.SPELLRANGE,
	},
}
-------------------------------------------------奶酪-------------------------------------------------
actions.fondue = {
	id = "DOTA_FONDUE",
	str = STRINGS.DOTA.NEWACTION.DOTA_FONDUE,
	fn = function(act)	--
		if StandardInvobjectActioniTest(act, "dota_cheese") then
			if act.doer.components.health ~= nil and not act.doer.components.health:IsDead() then
				act.doer.components.health:DoDelta(TUNING.DOTA.CHEESE.HEALTH, nil, "cheese")
			end
			if act.doer.components.dotaattributes ~= nil then
				act.doer.components.dotaattributes:Mana_DoDelta(TUNING.DOTA.CHEESE.MANA, nil, "cheese")
			end
			if act.doer.components.hunger ~= nil then
				act.doer.components.hunger:DoDelta(TUNING.DOTA.CHEESE.HUNGER, nil, true)
			end
			PlaySound(act.doer, "mengsk_dota2_sounds/items/cheese", nil, BASE_VOICE_VOLUME)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
	},
}
-------------------------------------------------纷争面纱-------------------------------------------------
actions.weakness = {
	id = "DOTA_WEAKNESS",
	str = STRINGS.DOTA.NEWACTION.DOTA_WEAKNESS,
	fn = function(act)	-- TODO: 待制作
		if act.doer ~= nil and act.doer:HasTag("player") and act.doer:HasTag("dota_weakness") then
			local item = FindActivateItemByDoer(act.doer, "dota_veil_of_discord")
			if item == nil then return AoeActionFailed(act.doer, item) end
			if not IsManaEnough(act.doer, item) then return AoeActionFailed(act.doer, item) end
			if not RechargeCheck(item, TUNING.DOTA.VEIL_OF_DISCORD.WEAKNESS.CD, act.doer) then return AoeActionFailed(act.doer, item) end

			local pos = act:GetActionPoint() or act.doer:GetPosition()
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.DOTA.VEIL_OF_DISCORD.WEAKNESS.RANGE, { "_combat" }, exceuce_tags)
			for _, ent in ipairs(ents) do
				AddDebuff(ent, "buff_dota_weakness")
			end

			ItemManaDelta(act.doer, item, nil ,"dota_weakness")
			ChangeActivate(item, act.doer)
			AoeActionSucceed(act.doer, item)
			-- TakeOverPlayerController(act.doer, false)
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.VEIL_OF_DISCORD.WEAKNESS.SPELLRANGE,
	},
}
-------------------------------------------------血腥榴弹-------------------------------------------------
local grenade_health = TUNING.DOTA.BLOOD_GRENADE.GRENADE.HEALTH
local grenade_range = TUNING.DOTA.BLOOD_GRENADE.GRENADE.RANGE
local grenade_damage = TUNING.DOTA.BLOOD_GRENADE.GRENADE.DAMAGE
local function Grenade_OnHit(inst, attacker, target)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, grenade_range, "_combat", exceuce_tags)
    for _, ent in ipairs(ents) do
		if ent.components.combat ~= nil then
			inst.components.combat:GetAttacked(attacker, grenade_damage, nil, "dotamagic")
		end
		AddDebuff(ent, "buff_dota_grenade")
	end
	SpawnPrefab("bomb_lunarplant_explode_fx").Transform:SetPosition(x, y, z)
	inst:Remove()
end
actions.grenade = {
	id = "DOTA_GRENADE",
	str = STRINGS.DOTA.NEWACTION.DOTA_GRENADE,
	fn = function(act)
		if act.doer ~= nil and act.doer:HasTag("player") and act.doer:HasTag("dota_grenade") then
			local item = FindActivateItemByDoer(act.doer, "dota_blood_grenade") 
			if item == nil then return AoeActionFailed(act.doer, item) end
			if not RechargeCheck(item, TUNING.DOTA.BLOOD_GRENADE.GRENADE.CD, act.doer) then return AoeActionFailed(act.doer, item) end
			UseOne(item)

			local bomb = SpawnPrefab("dota_projectile_grenade")
			local projectile = act.doer.components.inventory:DropItem(bomb, false)	-- 此处用了 SetPosition ,并检测了 bomb
			if projectile and projectile.components.complexprojectile then
				local pos = nil
				if act.target then
					pos = act.target:GetPosition()
					projectile.components.complexprojectile.targetoffset = {x=0,y=1.5,z=0}
				else
					pos = act:GetActionPoint()
				end
				projectile.components.complexprojectile:Launch(pos, act.doer)
				-- projectile.components.complexprojectile:SetOnHit(Grenade_OnHit)
			end
			
			act.doer.components.health:DoDelta(-grenade_health, nil, "dota_grenade")	-- 可致死
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=2,
		mount_valid=true,
		distance = TUNING.DOTA.BLOOD_GRENADE.GRENADE.SPELLRANGE,
	},
}
-------------------------------------------------长盾------------------------------------------------- 
local protect_mana = TUNING.DOTA.PAVISE.PROTECT.MANA
actions.protect = {
	id = "DOTA_PROTECT",
	str = STRINGS.DOTA.NEWACTION.DOTA_PROTECT,
	fn = function(act)
		if StandardTargetAndActivateActioniTest(act, "dota_pavise") and
		 act.target:HasTag("player") and not act.target:HasTag("playerghost") then
			local item = FindActivateItemByDoer(act.doer, "dota_pavise")
			if item == nil then return ActionFailed(act.doer) end
			if not act.target.components.dotaattributes then return ActionFailed(act.doer) end
			if not IsManaEnough(act.doer, item) then return true end
			if not RechargeCheck(item, TUNING.DOTA.PAVISE.PROTECT.CD, act.doer) then return true end
			act.target.components.dotaattributes:CreateNormalShield("dota_shield_protectfx")
			ChangeActivate(item, act.doer)
			ItemManaDelta(act.doer, item, nil ,"dota_protect")
			return true
		end
		return ActionFailed(act.doer)
	end,
	actiondata = {
		priority=7,
		mount_valid=false,
		distance = TUNING.DOTA.PAVISE.PROTECT.SPELLRANGE,
	},
}
-------------------------------------------------------------------------------------------------------------------
----------------------------------------------- 动作与组件绑定 -----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

local function StandardAOEtargetingTest(inst, pos)
	return (inst.components.aoetargeting == nil or inst.components.aoetargeting:IsEnabled())
	 and (inst.components.aoetargeting ~= nil
	  and inst.components.aoetargeting.alwaysvalid 
	  or (TheWorld.Map:IsAboveGroundAtPoint(pos:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pos)))
end

local function StandardPrefabAndDoerTest(inst, prefab, doer)
	return inst.prefab == prefab and inst:HasTag("dota_canuse") and doer:HasTag("player") and not doer:HasTag("playerghost")
end

local component_actions = {
	{
		type = "INVENTORY",
		component = "inventoryitem",
		tests = { -- 自己使用的	--默认是右键，所以不用right参数
			-----------------------------------------------激活装备-------------------------------------------------
			{
				action = "ACTIVATEITEM",
				testfn = function(inst, doer, actions, right)
					local equipped = (inst ~= nil and doer.replica.inventory ~= nil) and doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) or nil
					if inst:HasTag("dota_needactivate")
					 and ((inst.replica.equippable ~= nil and inst.replica.equippable:IsEquipped())
					 or (equipped ~= nil and equipped.replica.container ~= nil and equipped.replica.container:IsHolding(inst)))
--					 or (inst:HasTag("dota_canuse")))
					 and doer.replica.inventory ~= nil 
					 and doer.replica.inventory:IsOpenedBy(doer) 
					 then
						return true
					end
					return false
				end,
			},
			-------------------------------------------------dota_box-------------------------------------------------
			{	-- 装备至box
				action = "WEARDOTAEQUIP",
				testfn = function(inst, doer, actions, instright)
					if not inst:HasTag("dota_equipment") then return false end	-- dota系物品
					-- local iscd = inst._isequipedcd and inst._isequipedcd:value()
					-- if iscd then return false end -- 处于操作冷却
					if doer.replica.inventory ~= nil then	-- 玩家有库存组件
						local dota_item = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) -- 获取玩家装备栏物品
						-- 如果装备栏有物品，并且物品有容器，并且容器是由玩家打开的
						if dota_item ~= nil and dota_item:HasTag("dota_box") and dota_item.replica.container ~= nil and dota_item.replica.container:IsOpenedBy(doer) then
							--如果这个容器可以装物品
							if dota_item.replica.container:CanTakeItemInSlot(inst) then
								return true
							end
						end
					end
					return false
				end,
			},
			{	-- 脱下box内装备
				action = "TAKEOFFDOTAEQUIP",
				testfn = function(inst, doer, actions, right)
					if not inst:HasTag("dota_equipment") then return false end	-- dota系物品
					-- if inst:HasTag("dota_box") then return false end
					-- local iscd = inst._isequipedcd and inst._isequipedcd:value()
					-- if iscd then return false end -- 处于操作冷却
					local equipped = (inst ~= nil and doer.replica.inventory ~= nil) and doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) or nil
					if equipped ~= nil and equipped:HasTag("dota_box") 
					 and equipped.replica.container ~= nil and equipped.replica.container:IsHolding(inst) then
						return true
					end
					return false
				end,
			},
			-------------------------------------------------净化药水 or 小蓝-------------------------------------------------
			{
				action = "DOTA_CLARITY",
				testfn = function(inst, doer, target, actions, right)
					return StandardPrefabAndDoerTest(inst, "dota_clarity", doer)
				end,
			},
			-------------------------------------------------魔法芒果-------------------------------------------------
			{
				action = "DOTA_MANGO",
				testfn = function(inst, doer, target, actions, right)
					return StandardPrefabAndDoerTest(inst, "dota_enchanted_mango", doer)
				end,
			},
			-------------------------------------------------治疗药膏-------------------------------------------------
			{
				action = "DOTA_SALVE",
				testfn = function(inst, doer, target, actions, right)
					return StandardPrefabAndDoerTest(inst, "dota_healing_salve", doer)
				end,
			},
			-------------------------------------------------仙灵之火-------------------------------------------------
			{
				action = "DOTA_FAERIEFIRE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_faerie_fire", doer)
				end,
			},
			-------------------------------------------------诡计之雾-------------------------------------------------
			{
				action = "DOTA_SMOKE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_smoke_of_deceit", doer)
				end,
			},
			---------------------------------------------------魔瓶 or 瓶子---------------------------------------------------
			{
				action = "DOTA_REGENERATE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_bottle", doer)
				end,
			},
			-------------------------------------------------显影之尘 or 粉-------------------------------------------------
			{
				action = "DOTA_DUST",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_dust_of_appearance", doer)
				end,
			},
			-------------------------------------------------知识之书-------------------------------------------------
			{
				action = "DOTA_TOME",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_tome_of_knowledge", doer)
				end,
			},
			-------------------------------------------------魔棒-------------------------------------------------
			{
				action = "DOTA_MAGICCHARGE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_magic_stick", doer)
				end,
			},
			-------------------------------------------------魔杖-------------------------------------------------
			{
				action = "DOTA_MAGICCHARGEPLUS",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_magic_wand", doer)
				end,
			},
			--------------------------------------------幽魂权杖 or 绿杖-----------------------------------------------
			{
				action = "DOTA_GHOSTFORM",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_ghost_scepter", doer)
				end,
			},
			-------------------------------------------------暗影护符-------------------------------------------------	
			{
				action = "DOTA_FADING",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_shadow_amulet", doer)
				end,
			},
			-----------------------------------------------动力鞋 or 假腿---------------------------------------------
			{
				action = "DOTA_TOGGLE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_power_treads", doer)
				end,
			},
			--------------------------------------------疯狂面具 or 疯脸------------------------------------------------
			{
				action = "DOTA_BERSERK",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_mask_of_madness", doer)
				end,
			},
			-------------------------------------------------灵魂之戒 or 魂戒-------------------------------------------------
			{
				action = "DOTA_SACRIFICE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_soul_ring", doer)
				end,
			},
			-------------------------------------------------相位鞋-------------------------------------------------
			{
				action = "DOTA_PHASE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_phase_boots", doer)
				end,
			},
			-------------------------------------------------奥术鞋 or 秘法鞋-------------------------------------------------
			{
				action = "DOTA_REPLENISH",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_arcane_boots", doer)
				end,
			},
			-------------------------------------------------洞察烟斗 or 笛子-------------------------------------------------
			{
				action = "DOTA_BARRIER",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_pipe_of_insight", doer)
				end,
			},
			-------------------------------------------------宽容之靴 or 大绿鞋-------------------------------------------------
			{
				action = "DOTA_ENDURANCE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_boots_of_bearing", doer)
				end,
			},
			-------------------------------------------------梅肯斯姆-------------------------------------------------
			{
				action = "DOTA_RESTORE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_mekansm", doer)
				end,
			},
			-------------------------------------------------韧鼓 or 战鼓-------------------------------------------------
			{
				action = "DOTA_ENDURANCEDRUM",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_drum_of_endurance", doer)
				end,
			},
			-------------------------------------------------卫士胫甲 or 大鞋-------------------------------------------------
			{
				action = "DOTA_MEND",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_guardian_greaves", doer)
				end,
			},
			-------------------------------------------------怨灵之契------------------------------------------------- 
			{
				action = "DOTA_REPRISAL",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_wraith_pact", doer)
				end,
			},
			-------------------------------------------------刷新球-------------------------------------------------
			{
				action = "DOTA_RESETCOOLDOWNS",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_refresher_orb", doer)
				end,
			},		
			-------------------------------------------------赤红甲-------------------------------------------------
			{
				action = "DOTA_GUARD",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_crimson_guard", doer)
				end,
			},		
			-------------------------------------------------黑黄杖 or BKB-----------------------------------------
			{
				action = "DOTA_AVATAR",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_black_king_bar", doer)
				end,
			},
			-------------------------------------------------幻影斧 or 分身斧-------------------------------------------------	
			{
				action = "DOTA_MIRROR",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_manta_style", doer)
				end,
			},
			-------------------------------------------------刃甲-------------------------------------------------
			{
				action = "DOTA_RETURN",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_blade_mail", doer)
				end,
			},
			-------------------------------------------------挑战头巾-------------------------------------------------
			{
				action = "DOTA_INSULATION",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_hood_of_defiance", doer)
				end,
			},
			-------------------------------------------------希瓦的守护 or 冰甲-------------------------------------------------
			{
				action = "DOTA_BLAST",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_shivas_guard", doer)
				end,
			},
			-------------------------------------------------血精石-------------------------------------------------
			{
				action = "DOTA_BLOODPACT",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_bloodstone", doer)
				end,
			},
			-------------------------------------------------永世法衣-------------------------------------------------
			{
				action = "DOTA_SHROUD",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_eternal_shroud", doer)
				end,
			},
			-------------------------------------------------白银之锋 or 大隐刀-------------------------------------------------
			{
				action = "DOTA_WALKPLUS",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_silver_edge", doer)
				end,
			},
			-------------------------------------------------蝴蝶-------------------------------------------------
			{
				action = "DOTA_FLUTTER",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_butterfly", doer)
				end,
			},
			-------------------------------------------------辉耀-------------------------------------------------
			{
				action = "DOTA_BURN",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_radiance", doer)
				end,
			},
			-------------------------------------------------莫尔迪基安的臂章-------------------------------------------------
			{
				action = "DOTA_UNHOLY",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_armlet_of_mordiggian", doer)
				end,
			},
			-------------------------------------------------英灵胸针-------------------------------------------------
			{
				action = "DOTA_PROVINCE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_revenants_brooch", doer)
				end,
			},
			-------------------------------------------------隐刀-------------------------------------------------
			{
				action = "DOTA_WALK",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_invis_sword", doer)
				end,
			},
			-------------------------------------------------撒旦之邪力 or 大吸-------------------------------------------------
			{
				action = "DOTA_RAGE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_satanic", doer)
				end,
			},
			-------------------------------------------------奶酪-------------------------------------------------
			{
				action = "DOTA_FONDUE",
				testfn = function(inst,doer,actions,right)
					return StandardPrefabAndDoerTest(inst, "dota_cheese", doer)
				end,
			},
		},
	},
	{	-- 给队友用的
		type = "USEITEM",
		component = "inventoryitem",
		tests = {
			-------------------------------------------------净化药水 or 小蓝-------------------------------------------------
			{
				action = "DOTA_CLARITY",
				testfn = function(inst, doer, target, actions, right)
					if inst.prefab == "dota_clarity" and target:HasTag("player") and not target:HasTag("playerghost") then
						return right
					end
					return false
				end,
			},
			-------------------------------------------------魔法芒果-------------------------------------------------
			{
				action = "DOTA_MANGO",
				testfn = function(inst, doer, target, actions, right)
					if inst.prefab == "dota_enchanted_mango" and target:HasTag("player") and not target:HasTag("playerghost") then
						return right
					end
					return false
				end,
			},
			-------------------------------------------------治疗药膏-------------------------------------------------
			{
				action = "DOTA_SALVE",
				testfn = function(inst, doer, target, actions, right)
					if inst.prefab == "dota_healing_salve" and target:HasTag("player") and not target:HasTag("playerghost") 
					 and target.replica.health ~= nil and target.replica.health:CanHeal() then	-- 是否有必要呢？
						return right -- and target.replica.dotaattributes ~= nil
					end
					return false
				end,
			},
			---------------------------------------------------魔瓶 or 瓶子---------------------------------------------------
			{
				action = "DOTA_BOTTLERUNE",
				testfn = function(inst, doer, target, actions, right)
					if inst.prefab == "dota_bottle" and target:HasTag("dota_rune") then
						return right
					end
					return false
				end,
			},
		},
	},
	{	-- 需要激活的
		type = "SCENE",
		component = "workable",
		tests = {
			-------------------------------------------------树之祭祀 or 吃树-------------------------------------------------
			{
				action = "DOTA_TANGO", -- DOTA_TANGO
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_tango") 
					 and doer:HasTag("player") and not doer:HasTag("playerghost") 	-- dota_tango
					 and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) --骑牛时不能用
					 and inst:HasTag("plant") and not inst:HasTag("burnt") and inst:HasTag("chop_workable") 
					 and right
				end,
			},
			----------------------------------------压制之刃 or 补刀斧 and 狂战斧-----------------------------------------
			{
				action = "DOTA_CHOP",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_chop") 
					 and doer:HasTag("player") and not doer:HasTag("playerghost")
					 and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) --骑牛时不能用
					 and inst:HasTag("plant") and not inst:HasTag("burnt") and inst:HasTag("chop_workable") 
					 and right
				end,
			},
		},
	},
	{	-- 需要激活的
		type = "SCENE",
		component = "combat",	-- 挂载在combat应该不会造成太大损耗吧
		tests = {
			------------------------------------------支配头盔 and (统御头盔 or 大支配)-------------------------------------------------
			{
				action = "DOTA_DOMINATE",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_dominate") and right
					and not (inst:HasTag("player") or inst:HasTag("ghost"))
					and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
					and not (inst.replica.follower ~= nil and inst.replica.follower:GetLeader())	-- 对象没有跟随者（ NTR哒咩
				end,
			},
			--------------------------------------------迈达斯之手 or 点金手----------------------------------------------
			{
				action = "DOTA_TRANSMUTE",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_transmute") and right
						and not IsEntityDead(inst, true) 
						-- and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
						and not inst:HasTag("player")
				end,
			},
			-------------------------------------------------圣洁吊坠-------------------------------------------------
			{
				action = "DOTA_CHARGE",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_charge") and right
						and inst:HasTag("player") and not inst:HasTag("ghost")
						and not IsEntityDead(inst, true) and inst.replica.combat ~= nil
				end,
			},
			-------------------------------------------------魂之灵瓮 or 大骨灰-------------------------------------------------
			{
				action = "DOTA_RELEASE",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_release") and right
						-- and ((inst:HasTag("player") and not inst:HasTag("ghost")) 
						-- 	or (inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)))
						and not IsEntityDead(inst, true)
				end,
			},
			-------------------------------------------------影之灵龛 or 骨灰-------------------------------------------------
			{
				action = "DOTA_RELEASEPLUS",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_releaseplus") and right
						-- and ((inst:HasTag("player") and not inst:HasTag("ghost")) 
						-- 	or (inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)))
						and not IsEntityDead(inst, true)
				end,
			},
			-------------------------------------------------勇气勋章-------------------------------------------------
			{
				action = "DOTA_VALOR",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_valor") and right
						and (inst ~= doer)
						-- and ((inst:HasTag("player") and not inst:HasTag("ghost")) 
						-- 	or (inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)))
						and not IsEntityDead(inst, true)
				end,
			},
			------------------------------------------eul的神圣法杖 or 吹风----------------------------------------------
			{
				action = "DOTA_CYCLONE",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_cyclone") and right
						and (inst:HasTag("player") and inst == doer)
						and ((inst:HasTag("player")) 
							or (inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)))
						and not IsEntityDead(inst, true)
				end,
			},
			-------------------------------------------------阿托斯之棍-------------------------------------------------
			{
				action = "DOTA_CRIPPLE",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_cripple") and right
						and not IsEntityDead(inst, true) 
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------达贡之神力 or 大根-------------------------------------------------
			{
				action = "DOTA_BURST1",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_burst1") and right and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			{
				action = "DOTA_BURST2",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_burst2") and right and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			{
				action = "DOTA_BURST3",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_burst3") and right and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			{
				action = "DOTA_BURST4",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_burst4") and right and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			{
				action = "DOTA_BURST5",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_burst5") and right and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------风之杖 or 大吹风-------------------------------------------------
			{
				action = "DOTA_CYCLONEPLUS",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_cycloneplus") and right
						and not IsEntityDead(inst, true) 
						and not inst:HasTag("wall")
				end,
			},
			-------------------------------------------------微光披风-------------------------------------------------
			{
				action = "DOTA_GLIMMER",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_glimmer") and right
						and inst:HasTag("player") and not inst:HasTag("ghost")
						and not IsEntityDead(inst, true) and inst.replica.combat ~= nil
				end,
			},
			-------------------------------------------------邪恶镰刀 or 羊刀-------------------------------------------------
			{
				action = "DOTA_HEX",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_hex") and right 
						and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------炎阳纹章 or 大勋章-------------------------------------------------
			{
				action = "DOTA_SHINE",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_shine") and right
						and ((inst:HasTag("player") and not inst:HasTag("ghost") and inst ~= doer) 
							or (inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)))
						and not IsEntityDead(inst, true)
				end,
			},
			-------------------------------------------------原力法杖 or 推推棒-------------------------------------------------
			{
				action = "DOTA_FORCE",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_force") and right
						and ((inst:HasTag("player") and not inst:HasTag("ghost")) 
							or (inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)))
						and not IsEntityDead(inst, true)
				end,
			},
			-------------------------------------------------紫怨-------------------------------------------------
			{
				action = "DOTA_BURNX",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_burnx") and right 
						and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------飓风长戟 or 大推推-------------------------------------------------
			{
				action = "DOTA_THRUST",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_thrust") and right
						and ((inst:HasTag("player") and not inst:HasTag("ghost")) 
							or (inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)))
						and not IsEntityDead(inst, true)
				end,
			},
			-------------------------------------------------清莲宝珠 or 莲花-------------------------------------------------
			{
				action = "DOTA_SHELL",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_shell") and right
						and inst:HasTag("player") and not inst:HasTag("ghost")
						and not IsEntityDead(inst, true) and inst.replica.combat ~= nil
				end,
			},
			-------------------------------------------------否决坠饰-------------------------------------------------
			{
				action = "DOTA_NULLIFY",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_nullify") and right 
						and not inst:HasTag("player")
						and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------深渊之刃 or 大晕-------------------------------------------------
			{
				action = "DOTA_OVERWHELM",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_overwhelm") and right 
						and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------虚灵之刃-------------------------------------------------
			{
				action = "DOTA_ETHEREAL",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_ethereal") and right 
						and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------血棘 or 大紫怨-------------------------------------------------
			{
				action = "DOTA_REND",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_rend") and right 
						and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------天堂之戟-------------------------------------------------
			{
				action = "DOTA_DISARM",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_disarm") and right 
						and not IsEntityDead(inst, true)  
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------净魂之刃 or 散失-------------------------------------------------			
			{
				action = "DOTA_INHIBIT",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_inhibit") and right 
						and not IsEntityDead(inst, true)
						and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
				end,
			},
			-------------------------------------------------雷神之锤 or 大雷锤 or 大电锤-------------------------------------------------		
			{
				action = "DOTA_LIGHTING",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_lighting") and right
						and inst:HasTag("player") and not inst:HasTag("ghost")
						and not IsEntityDead(inst, true) and inst.replica.combat ~= nil
				end,
			},
			-------------------------------------------------长盾-------------------------------------------------
			{
				action = "DOTA_PROTECT",
				testfn = function(inst, doer, actions, right)
					return doer:HasTag("dota_protect") and right
						and inst:HasTag("player") and not inst:HasTag("ghost")
						and not IsEntityDead(inst, true) and inst.replica.combat ~= nil
				end,
			},
		},
	},
	{	
		type = "POINT",
		component = "blinkdagger",
		tests = {
			--------------------------------------------闪烁匕首 or 跳刀----------------------------------------------
			{
				action = "DOTA_BLINK",
				testfn = function(inst, doer, pos, actions, right, target)
					if not doer:HasTag("dota_blink") then return false end
					local x,y,z = pos:Get()
					if right
					 and (TheWorld.Map:IsAboveGroundAtPoint(x,y,z) or TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil)
					 --and not TheWorld.Map:IsGroundTargetBlocked(pos)
					 and not doer:HasTag("steeringboat")
					 and not doer:HasTag("rotatingboat")
					 then
						return true
					end
					return false
				end,
			},
		},
	},
	{
		type = "POINT",
		component = "inventoryitem",
		tests = {
			-------------------------------------------------回城卷轴-------------------------------------------------
			{
				action = "DOTA_TPSCROLL",
				testfn = function(inst, doer, pos, actions, right, target)
					if not doer:HasTag("dota_tpscroll") then return false end
					local x,y,z = pos:Get()
					if right
					--  and (TheWorld.Map:IsAboveGroundAtPoint(x,y,z) or TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil)
					--  and not TheWorld.Map:IsGroundTargetBlocked(pos)
					 and not doer:HasTag("steeringboat")
					 and not doer:HasTag("rotatingboat")
					 then
						return true
					end
					return false
				end,
			},
			-------------------------------------------------陨星锤-------------------------------------------------
			{
				action = "DOTA_METEOR",
				testfn = function(inst, doer, pos, actions, right, target)
					if doer:HasTag("dota_meteor") and doer.replica.dotacharacter then
						local item = doer.replica.dotacharacter:GetActivateItem()
						return StandardAOEtargetingTest(item, pos)
					end
					return false
				end,
			},
			-------------------------------------------------缚灵索-------------------------------------------------
			{
				action = "DOTA_CHAINS",
				testfn = function(inst, doer, pos, actions, right, target)
					if doer:HasTag("dota_chains") and doer.replica.dotacharacter then
						local item = doer.replica.dotacharacter:GetActivateItem()
						return StandardAOEtargetingTest(item, pos)
					end
					return false
				end,
			},
			-------------------------------------------------纷争面纱-----------------------------------------------
			{
				action = "DOTA_WEAKNESS",
				testfn = function(inst, doer, pos, actions, right, target)
					if doer:HasTag("dota_weakness") and doer.replica.dotacharacter then
						local item = doer.replica.dotacharacter:GetActivateItem()
						return StandardAOEtargetingTest(item, pos)
					end
					return false
				end,
			},
			-------------------------------------------------血腥榴弹-------------------------------------------------
			{
				action = "DOTA_GRENADE",
				testfn = function(inst, doer, pos, actions, right, target)
					if doer:HasTag("dota_grenade") and doer.replica.dotacharacter then
						local item = doer.replica.dotacharacter:GetActivateItem()
						return StandardAOEtargetingTest(item, pos)
					end
					return false
				end,
			},


			
		},
	},
}

local old_EQUIP_fn = ACTIONS.EQUIP.fn
local old_UNEQUIP_fn = ACTIONS.UNEQUIP.fn
local old_PICKUP_fn = ACTIONS.PICKUP.fn
local old_DROP_fn = ACTIONS.DROP.fn
local old_STORE_fn = ACTIONS.STORE.fn
local old_CONSTRUCT_fn = ACTIONS.CONSTRUCT.fn

-- --修改老动作
local old_actions = {
-- 	------------------------------------------------- dota_box -------------------------------------------------
	{	
		switch = false,-- 造成闪退bug
		id = "EQUIP",
		actiondata = {
			fn = function(act)
				if act.invobject:HasTag("dota_box") and act.invobject._isequipedcd:value() then
					return false
				end
				return old_EQUIP_fn(act)
			end,
		},
	},
	{	
		switch = false,	-- 造成闪退bug
		id = "UNEQUIP",
		actiondata = {
			fn = function(act)
				if act.invobject:HasTag("dota_box") and act.invobject._isequipedcd:value() then
					return false
				end
				return old_UNEQUIP_fn(act)
			end,
		},
	},
	{	
		switch = false,
		id = "PICKUP",
		actiondata = {
			fn = function(act)
				print(1111)
				if act.target:HasTag("dota_box") and act.target._isequipedcd:value() then
					return false
				end
				return old_PICKUP_fn(act)
			end,
		},
	},
	{	
		switch = false,
		id = "DROP",
		actiondata = {
			fn = function(act)
				if act.invobject:HasTag("dota_box") and act.invobject._isequipedcd:value() then
					return false
				end
				return old_DROP_fn(act)
			end,
		},
	},
	{	
		switch = false,
		id = "STORE",
		actiondata = {
			fn = function(act)
				if act.invobject:HasTag("dota_box") and act.invobject._isequipedcd:value() then
					return false
				end
				return old_STORE_fn(act)
			end,
		},
	},
	{	
		switch = false,
		id = "CONSTRUCT",
		actiondata = {
			fn = function(act)
				if act.invobject:HasTag("dota_box") and act.invobject._isequipedcd:value() then
					return false
				end
				return old_CONSTRUCT_fn(act)
			end,
		},
	},
	
	
}

return {
	actions = actions,
	component_actions = component_actions,
	old_actions = old_actions,
}