-------------------------------------刃甲----------------------------------------------
-- 加载资源表
local assets =
{
    Asset("ANIM", "anim/dota_blade_mail.zip"),
    Asset("ATLAS", "images/inventoryimages/dota_blade_mail.xml"),
	Asset("IMAGE", "images/inventoryimages/dota_blade_mail.tex"),
}

-- 装备回调
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "dota_blade_mail", "swap_body")
end

-- 卸载回调
local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

--主函数
local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()	-- 添加变换组件
    inst.entity:AddAnimState()	-- 添加动画组件
--  inst.entity:AddSoundEmitter() -- 添加音效组件
    inst.entity:AddNetwork() -- 添加网络组件

	MakeInventoryPhysics(inst) -- 设置物品拥有一般物品栏物体的物理特性，对于放在物品栏里的物理Phiysics，让其可以放地上，具体代码在 standardcomponents.lua

	inst.AnimState:SetBank("dota_blade_mail") -- 设置动画属性 Bank
    inst.AnimState:SetBuild("dota_blade_mail") -- 设置动画属性 Build
    inst.AnimState:PlayAnimation("anim") -- 设置默认播放动画为anim

	inst:AddTag("sharp")
	inst:AddTag("dota_blade_mail")
    inst:AddTag("dota_equipment")
  --  inst:AddTag('hide_percentage')  --是否生效仍存疑

	---------------------- 主客机分界代码 -------------------------
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------------------------------------------------  

	inst:AddComponent("inspectable")	--可检查

    inst:AddComponent("inventoryitem")		-- 可放入物品栏
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dota_blade_mail.xml" -- 设置物品栏图片文档

	inst:AddComponent("armor")		--武器
    inst.components.armor:InitCondition(100, TUNING.DOTA.BLADE_MAIL_ABSORPTION)
    inst.components.armor.indestructible = true

	inst:AddComponent("equippable")		--装备
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("rechargeable") -- 冷却组件
	-- inst.components.rechargeable:SetOnDischargedFn(ondischarged)
	-- inst.components.rechargeable:SetOnChargedFn(oncharged)
	
	MakeHauntableLaunch(inst)	--可作祟

    return inst
end

return Prefab("dota_blade_mail", fn, assets, prefabs)