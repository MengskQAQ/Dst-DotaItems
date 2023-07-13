------------------------------------------------漩涡----------------------------------------------------
-- 加载资源表
local assets =
{
    Asset("ANIM", "anim/dota_maelstrom.zip"),
	Asset("ANIM", "anim/swap_dota_maelstrom.zip"),
    Asset("ATLAS", "images/inventoryimages/dota_maelstrom.xml"),
	Asset("IMAGE", "images/inventoryimages/dota_maelstrom.tex"),
}

-- local function ondischarged(inst)   end
-- local function oncharged(inst)  end

-- 装备回调
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_dota_maelstrom", "swap_dota_maelstrom")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.components.debuffable:AddDebuff("buff_dota_chain_lighting", "buff_dota_chain_lighting")
end

-- 卸载回调
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.components.debuffable:RemoveDebuff("buff_dota_chain_lighting")
end

--主函数
local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()	-- 添加变换组件
    inst.entity:AddAnimState()	-- 添加动画组件
--  inst.entity:AddSoundEmitter() -- 添加音效组件
    inst.entity:AddNetwork() -- 添加网络组件

	MakeInventoryPhysics(inst) -- 设置物品拥有一般物品栏物体的物理特性，对于放在物品栏里的物理Phiysics，让其可以放地上，具体代码在 standardcomponents.lua

	inst.AnimState:SetBank("dota_maelstrom") -- 设置动画属性 Bank
    inst.AnimState:SetBuild("dota_maelstrom") -- 设置动画属性 Build
    inst.AnimState:PlayAnimation("idle") -- 设置默认播放动画为idle

	inst:AddTag("sharp")
	inst:AddTag("dota_maelstrom")
    inst:AddTag("dota_equipment")
    
	---------------------- 主客机分界代码 -------------------------
    inst.entity:SetPristine() 
    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------------------------------------------------  

	inst:AddComponent("inspectable")	--可检查

    inst:AddComponent("inventoryitem")		-- 可放入物品栏
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dota_maelstrom.xml" -- 设置物品栏图片文档

	inst:AddComponent("weapon")		--武器
    inst.components.weapon:SetDamage(TUNING.DOTA.BUTTERFLY_DAMAGE)

	inst:AddComponent("equippable")		--装备
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.DOTA.BUTTERFLY_SPEEDMULTI + 1	-- 加速效果
	
	-- inst:AddComponent("rechargeable") -- 冷却组件
	-- inst.components.rechargeable:SetOnDischargedFn(ondischarged)
	-- inst.components.rechargeable:SetOnChargedFn(oncharged)
	
	MakeHauntableLaunch(inst)	--可作祟

    return inst
end

return Prefab("dota_maelstrom", fn, assets, prefabs)