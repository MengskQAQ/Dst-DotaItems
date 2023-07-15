-----------------------------------------------------------------------
-- 此lua写法出自恒子大佬的能力勋章[workshop-1909182187]
-- 来源 \scripts\prefabs\multivariate_certificate.lua
-----------------------------------------------------------------------

-- TODO：有一点需要考虑，要不要hook Inventory组件让这个装备栏的物品无法被击落？

require "prefabutil"

local assets =  -- TODO: 更换素材
{
    Asset("ANIM", "anim/dota_box.zip"),
    Asset("ATLAS", "images/dota_box.xml"),
	Asset("IMAGE", "images/dota_box.tex"),
}
-- 初始化box内格子
local function dota_list_init(num)
 	local equip_list = {}   -- 镶嵌位
	local slotnum = num or 6    -- 格子数
	for i = 1, slotnum do
		equip_list[i] = {item = nil}
	end
	return equip_list
end
-- 读取容器内道具
local function getDotaList(inst)
	local items = nil
	if inst.components.container then
		items = inst.components.container:FindItems(function(_) return true end)
	end
	return items
end
-- 执行列表内的装备函数
local function doDotaListOnEquipFn(inst, item, owner)
	if item and item.components.equippable then
		-- 对装备自身生效
		local onequipfn = item.components.equippable.onequipfn
		if onequipfn ~= nil then
			onequipfn(item,owner)
		end
		-- 对box生效
		if item.onequipwithrhfn then
			item.onequipwithrhfn(inst,item,owner)	--(inst是box,item是装备,owner是佩戴者)
		end
	end
end
--执行列表内的卸下函数
local function doDotaListOnUnequipFn(inst,item,owner)
	if item and item.components.equippable then
		-- 对装备自身生效
		local onunequipfn = item.components.equippable.onunequipfn
		if onunequipfn ~= nil then
			onunequipfn(item,owner)
		end
		-- 对box生效
		if item.onunequipwithrhfn then
			item.onunequipwithrhfn(inst,item,owner)
		end
	end
end
-- 取出道具
local function itemloseFn(inst,data)
	if data ~= nil then
		if inst.components.equippable:IsEquipped() then
			local owner = inst.components.inventoryitem.owner
			if owner ~= nil then
				doDotaListOnUnequipFn(inst, inst.equip_list[data.slot].item, owner)
			end
		end
		inst.equip_list[data.slot].item = nil
	end
end
-- 存入道具
local function itemgetfn(inst,data)
	if data ~= nil then
		inst.equip_list[data.slot].item = data.item
		if inst.components.equippable:IsEquipped() then
			local owner = inst.components.inventoryitem.owner
			if owner ~= nil then
				doDotaListOnEquipFn(inst,inst.equip_list[data.slot].item,owner)
			end
		end
	end
end
-- 打开容器
local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end
-- 关闭容器
local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end
-- 掉落
local function ondropped(inst)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end
local function blinkdaggercheck(inst)
	for i = 1, inst.components.container.numslots do
		local item = inst.components.container.slots[i]
		if item and (item.prefab == "dota_blink_dagger" 
		 or item.prefab == "dota_swift_blink" 
		 or item.prefab == "dota_arcane_blink" 
		 or item.prefab == "dota_overwhelming_blink" )
		 then
			return true
		end
	end
	return false
	-- inst.components.container:FindItem(function(item) 
		-- if item and (item.prefab == "dota_blink_dagger" 
		 -- or item.prefab == "dota_swift_blink" 
		 -- or item.prefab == "dota_arcane_blink" 
		 -- or item.prefab == "dota_overwhelming_blink" )
		 -- then
			-- return true
		-- end
		-- return false
		-- end)
end
-- 装备
local function onequipfn(inst,owner)
	inst.components.container:Open(owner)
	local items = nil
	local itemSlot = 1
	inst.equip_list = dota_list_init(inst.slotnum) -- 初始化镶嵌位
	items = getDotaList(inst)
	
	if items ~= nil then
		-- 第一次装备的时候挂个延迟，免得加载后部分数据不能及时生效
		if not inst.isfirstequip then
			inst:DoTaskInTime(0.3, function()
				for _, v in ipairs(items) do
					itemSlot = inst.components.container:GetItemSlot(v)
					inst.equip_list[itemSlot].item = v
					doDotaListOnEquipFn(inst, v, owner)
				end
			end)
			inst.isfirstequip=true
		else
			for _, v in ipairs(items) do
				itemSlot = inst.components.container:GetItemSlot(v)
				inst.equip_list[itemSlot].item = v
				doDotaListOnEquipFn(inst, v, owner)
			end
		end
	end

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end
-- 卸下
local function onunequipfn(inst,owner)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
	if #inst.equip_list >0 then
		for _, v in ipairs(inst.equip_list) do
			if v.item ~= nil then
				doDotaListOnUnequipFn(inst,v.item,owner)
			end
		end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.equip_list=dota_list_init(6) -- 初始化镶嵌位
    inst.slotnum=6 -- 记录格子数量
    
    inst.AnimState:SetBank("dota_box")
    inst.AnimState:SetBuild("dota_box")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("dota_box")
    
    MakeInventoryFloatable(inst,"med",0.1,0.65)
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "dota_box"
    inst.components.inventoryitem.atlasname = "images/dota_box.xml"
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequipfn)
    inst.components.equippable:SetOnUnequip(onunequipfn)
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("dota_box")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    
	inst.blinkdaggercheck = blinkdaggercheck

    inst:ListenForEvent("itemlose", itemloseFn)
    inst:ListenForEvent("itemget", itemgetfn)

    return inst
end

return Prefab("dota_box", fn, assets, prefabs)

