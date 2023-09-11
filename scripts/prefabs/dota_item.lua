-----------------------------------------------------------------------
-- 此lua写法出自恒子大佬的能力勋章[workshop-1909182187]
-- 来源 /scripts/functional_medal.lua
-----------------------------------------------------------------------

--[[
该架构目前提供的物品格式有

item = {
	name = string, 物品名称ID (必须)
    animname = string, 物品动画名 (必须)
	animzip = string, 物品动画文件 (必须)
	taglist = {}, 物品标签

	assets = {}, 物品额外加载的资源
	asset = {}, 启用此表时，仅加载此表的assets资源

	manacost = int, 消耗的魔法值
	healthcost = int, 消耗的生命值
	maxsize = int, 最大堆叠数量

	fuellevel = int, 燃料消耗组件
	deletefn = function(inst) end, 燃料耗尽时执行函数
	fueltype = FUELTYPE.YOURCHICES, 燃料填充种类

	onequipfn = function(inst,owner) end, 装备时执行函数
	onunequipfn = function(inst,owner) end, 卸下时执行函数

	client_extrafn = function(inst) end, 主客机函数
    extrafn = function(inst) end, 主机函数

	activatename = string, 对应的激活动作
	activatefn = function(inst, owner) end, 激活时执行函数
	inactivatefn = function(inst, owner) end, 取消激活时执行函数
	aoetargeting = {	激活时是否有范围显示
		reticuleprefab = string,
		pingprefab = string,
		targetfn = function() end,
		validcolour = { 1, .75, 0, 1 },
		invalidcolour = { .5, 0, 0, 1 },
		ease = bool,
		mouseenabled = bool,
		enabled = bool, 是否开启
	}, 

	fakeweapon = {	物品是否要内置虚拟武器
		name = string, 虚拟武器名称
		damage = int, 虚拟武器伤害
		range = int, 虚拟武器范围
		projectile = string, 虚拟武器投掷品
		tag = string, 虚拟武器标签
	}, 
	playerprox = {	物品是否具有光环
		range = int, 光环生效范围
		onnearfn = function(inst, player) end, 进入光环执行函数
		onfarfn = function(inst, player) end, 离开光环执行函数
	}, 
	notrechargerable = bool, 物品是否取消冷却组件
	sharedcoolingtype = string, 共享冷却组类别
}

]]--

local SHARINGCD = TUNING.DOTA.SHARINGCD	-- 是否启用共享冷却

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function MakeCertificate(def)
	local assets={
		Asset("ANIM", "anim/"..def.animzip..".zip"),
		Asset("ATLAS", "images/"..def.animzip.."/"..def.name..".xml"),
		Asset("ATLAS_BUILD", "images/"..def.animzip.."/"..def.name..".xml", 256),
	}
	if def.assets and #def.assets>0 then
		for _,v in ipairs(def.assets) do
			table.insert(assets, v)
		end
	end
	if def.asset and #def.asset>0 then
		assets = def.asset
	end
--	print("[debug]" .. def.name .. "  assert:" .. def.animzip.."/"..def.name..".xml")
	--存储函数
	local prefabs = {}
	if def.prefabs and #def.prefabs>0 then
		for _,v in ipairs(def.prefabs) do
			table.insert(prefabs, v)
		end
	else
		prefabs = nil
	end

	--加载/储存函数
	local function onsavefn(inst,data)
		if def.onsavefn then
			def.onsavefn(inst,data)
		end
	end
	local function onloadfn(inst,data)
		if def.onloadfn then
			def.onloadfn(inst,data)
		end
	end

	-- 冷却函数
	local function onchargedfn(inst)
		-- if not inst:HasTag("dota_charged") then
		-- 	inst:AddTag("dota_charged")
		-- end
		if inst.components.dotaitem then
			inst.components.dotaitem.ischarged = true
		end
		if def.onchargedfn then
			def.onchargedfn(inst)
		end
	end
	local function ondischargedfn(inst)
		-- if inst:HasTag("dota_charged") then
		-- 	inst:RemoveTag("dota_charged")
		-- end
		if inst.components.dotaitem then
			inst.components.dotaitem.ischarged = false
		end
		if def.dischargedfn then
			def.dischargedfn(inst)
		end
	end

	
	--虚拟武器
	local function EquipWeapons(inst)
		if def.fakeweapon then
			if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
				local fakeweapon = CreateEntity()
				fakeweapon.name = def.fakeweapon.name
				--[[Non-networked entity]]
				fakeweapon.entity:AddTransform()
				fakeweapon:AddComponent("weapon")
				fakeweapon.components.weapon:SetDamage(def.fakeweapon.damage)
				fakeweapon.components.weapon:SetRange(def.fakeweapon.range)
				fakeweapon.components.weapon:SetProjectile(def.fakeweapon.projectile)
				fakeweapon:AddComponent("inventoryitem")
				fakeweapon.persists = false
				fakeweapon.components.inventoryitem:SetOnDroppedFn(fakeweapon.Remove)
				fakeweapon:AddComponent("equippable")
				fakeweapon:AddTag(def.fakeweapon.tag)
				fakeweapon:AddTag("fakeweapon")
				fakeweapon:AddTag("nosteal")
		
				inst.components.inventory:GiveItem(fakeweapon)
				inst.fakeweapon = fakeweapon
			end
		end
	end

	--装备函数
	local function onequipfn(inst,owner)
		--inst.components.dotaitem:Equipped()
        if not inst:HasTag("dota_canuse") then
            inst:AddTag("dota_canuse")
        end

		if owner.components.dotacharacter and def.onequipfn then
			def.onequipfn(inst,owner)
		end

		if SHARINGCD and def.sharedcoolingtype then
			if owner.components.dotasharedcoolingable then
				owner.components.dotasharedcoolingable:TrackEquipment(inst)
			end
		end

		if def.fakeweapon then
			if inst.fakeweapon == nil then
				inst.EquipWeapons(inst)
			end
		end

		if def.playerprox then
			if inst.components.playerprox then
				inst.components.playerprox:Dota_SetActivateStatus(true, true)
			end
		end
	end
	--卸下函数
	local function onunequipfn(inst,owner)
		--inst.components.dotaitem:UnEquipped()
        if inst:HasTag("dota_canuse") then
            inst:RemoveTag("dota_canuse")
        end
		if owner.components.dotacharacter and def.onunequipfn then
			def.onunequipfn(inst,owner)
		end

		if inst.components.activatableitem ~= nil and inst.components.activatableitem:IsActivate() then
			inst.components.activatableitem:StopUsingItem(owner)
		end

		if SHARINGCD and def.sharedcoolingtype then
			if owner.components.dotasharedcoolingable then
				owner.components.dotasharedcoolingable:UnTrackEquipment(inst)
			end
		end

		if def.playerprox then
			if inst.components.playerprox then
				inst.components.playerprox:Dota_SetActivateStatus(false, true)
			end
		end
	end

	-- 激活函数
	local function activatefn(inst, owner)
		if def.activatefn then
			def.activatefn(inst, owner)
		end
	end
	local function inactivatefn(inst, owner)
		-- if def.aoetargeting then
			-- if inst.components.aoetargeting then
				-- inst.components.aoetargeting:StopTargeting()
			-- end
		-- end
		if def.inactivatefn then
			def.inactivatefn(inst, owner)
		end
	end

	--初始化
	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(def.animzip)
		inst.AnimState:SetBuild(def.animzip)
		inst.AnimState:PlayAnimation(def.animname)

		inst:AddTag("nosteal")
		inst:AddTag("stronggrip")
		inst:AddTag("meteor_protection")
		inst:AddTag("dota_equipment")
		inst:AddTag(def.name)

		if def.activatename then
			inst:AddTag("dota_needactivate")
			inst.activatename =  string.upper( def.activatename )	-- 我们定义动作key值到客户端，便于客户端显示动作名称
		end

		if def.manacost then	-- 这部分用于客户端显示消耗的魔法值
			inst:AddTag("dota_needmana")	
			inst.manacost = def.manacost
		end

		if def.healthcost then	-- 这部分用于客户端显示消耗的生命值
			inst:AddTag("dota_needhealth")
			inst.healthcost = def.healthcost
		end

		-- 范围显示
		if def.aoetargeting then
			inst:AddComponent("aoetargeting")
			inst.components.aoetargeting.reticule.reticuleprefab = def.aoetargeting.reticuleprefab or "reticuleaoe"
			inst.components.aoetargeting.reticule.pingprefab = def.aoetargeting.pingprefab or "reticuleaoeping"
			inst.components.aoetargeting.reticule.targetfn = def.aoetargeting.targetfn or ReticuleTargetFn
			inst.components.aoetargeting.reticule.validcolour = def.aoetargeting.validcolour or { 1, .75, 0, 1 }
			inst.components.aoetargeting.reticule.invalidcolour = def.aoetargeting.invalidcolour or { .5, 0, 0, 1 }
			inst.components.aoetargeting.reticule.ease = def.aoetargeting.ease or true
			inst.components.aoetargeting.reticule.mouseenabled = def.aoetargeting.mouseenabled or true
			inst.components.aoetargeting:SetEnabled(def.aoetargeting.enabled or true)
		end

		--添加标签
		if def.taglist and #def.taglist>0 then
			for _,v in ipairs(def.taglist) do
				inst:AddTag(v)
			end
		end

		--主客机额外扩展函数
		if def.client_extrafn then
			def.client_extrafn(inst)
		end

		inst.foleysound = "dontstarve/movement/foley/jewlery"

		MakeInventoryFloatable(inst,"med",0.1,0.65)	-- TODO：存疑

		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("inspectable")

		inst:AddComponent("dotaitem")

		if def.fakeweapon then
			inst:AddComponent("inventory")
			inst.EquipWeapons = EquipWeapons
        	EquipWeapons(inst)
		end

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = def.name
		inst.components.inventoryitem.atlasname = "images/"..def.animzip.."/"..def.name..".xml"
		inst.components.inventoryitem.keepondeath = true
		inst.components.inventoryitem.keepondrown = true

		inst:AddComponent("equippable")
		inst.components.equippable.equipslot = EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY or EQUIPSLOTS.HANDS
		inst.components.equippable:SetOnEquip(onequipfn)
		inst.components.equippable:SetOnUnequip(onunequipfn)
		inst.onequipwithrhfn=def.onequipwithrhfn
		inst.onunequipwithrhfn=def.onunequipwithrhfn

		-- 冷却组件
		if not def.notrechargerable then
			inst:AddComponent("rechargeable")
			inst.components.rechargeable:SetOnChargedFn(onchargedfn)
			inst.components.rechargeable:SetOnDischargedFn(ondischargedfn)
		end

		-- 装备激活
		if def.activatename then
			inst:AddComponent("activatableitem")
			inst.components.activatableitem:SetActivateFn(activatefn)
			inst.components.activatableitem:SetInActivatefn(inactivatefn)
		end

		-- 堆叠数量
		if def.maxsize then
			inst:AddComponent("stackable")
    		inst.components.stackable.maxsize = def.maxsize
		end

		--添加燃料消耗组件
		if def.fuellevel then
			inst:AddComponent("fueled")
			inst.components.fueled:InitializeFuelLevel(def.fuellevel)
			if def.deletefn then
				inst.components.fueled:SetDepletedFn(def.deletefn)
			else
				inst.components.fueled:SetDepletedFn(inst.Remove)
			end
			if def.fueltype then
				inst.components.fueled.fueltype = def.fueltype --燃料修复
				inst.components.fueled.accepting = true
			end
		end

		--添加使用次数耐久组件
		if def.maxuses then
			inst:AddComponent("finiteuses")
			inst.components.finiteuses:SetMaxUses(def.maxuses)
			if def.notstartfull then
				inst.components.finiteuses:SetUses(0)
			else
				inst.components.finiteuses:SetUses(def.maxuses)
			end
			if def.onfinishedfn then
				inst.components.finiteuses:SetOnFinished(def.onfinishedfn)
			else
				inst.components.finiteuses:SetOnFinished(inst.Remove)
			end
		end
		
		-- 共享冷却
		if SHARINGCD and def.sharedcoolingtype then
			inst:AddComponent("dotasharedcooling")
			inst.components.dotasharedcooling:SetType(def.sharedcoolingtype)
		end

		-- 光环
		if def.playerprox then
			inst:AddComponent("playerprox")
			inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
			inst.components.playerprox:SetDist(def.playerprox.range, def.playerprox.range)
			inst.components.playerprox:SetOnPlayerNear(def.playerprox.onnearfn)
			inst.components.playerprox:SetOnPlayerFar(def.playerprox.onfarfn)
			inst.components.playerprox:Dota_IsDotaItem(true)
			inst.components.playerprox:Dota_SetActivateStatus(false, false)	-- 设置光环默认为false
		end

		--主机额外扩展函数
		if def.extrafn then
			def.extrafn(inst)
		end

		inst.OnSave = onsavefn
		inst.OnLoad = onloadfn

		MakeHauntableLaunch(inst)

		return inst
	end

	return Prefab(def.name, fn, assets, prefabs)
end

local certificates={}
local dota_item_list = {
	dota_item_accessories = true,
	dota_item_assisted = true,
	dota_item_attribute = true,
	dota_item_consumables = true,
	dota_item_equipment = true,
	dota_item_magic = true,
	dota_item_mysteryshop = true,
	dota_item_other = true,
	dota_item_precious = true,
	dota_item_protect = true,
	dota_item_weapon = true,
	dota_item_roshan = true,
}
for k, v in pairs(dota_item_list) do
	if v then
		local tmp_table = require("dota_defs/dota_item/" .. tostring(k))[k]
    	for _, equip in pairs(tmp_table) do
			table.insert(certificates, MakeCertificate(equip))
		end
	end
end

return unpack(certificates)

