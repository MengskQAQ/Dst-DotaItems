----------------------------------------------黯灭------------------------------------------------
-- 加载资源表
local assets =
{
    Asset("ANIM", "anim/dota_desolator.zip"),
	Asset("ANIM", "anim/swap_dota_desolator.zip"),
    Asset("ATLAS", "images/inventoryimages/dota_desolator.xml"),
	Asset("IMAGE", "images/inventoryimages/dota_desolator.tex"),
}

-- 激活减甲buff
local function ApplyDebuff(inst, data)
	local target = data ~= nil and data.target
	if target ~= nil then
        target:AddDebuff("buff_dota_corruption", "buff_dota_corruption")
	end
end

-- 装备回调
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_dota_desolator", "swap_dota_desolator") -- 以下三句都是设置动画表现的，不会对游戏实际内容产生影响，你可以试试去掉的效果
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst:ListenForEvent("onareaattackother", ApplyDebuff)   -- 参考阿比盖尔
end

-- 卸载回调
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry") -- 和上面的装备回调类似，可以试试去掉的结果
    owner.AnimState:Show("ARM_normal")
    inst:RemoveEventCallback("onareaattackother", ApplyDebuff)
end

local function fn()
    local inst = CreateEntity()

	inst.entity:AddTransform()	-- 添加变换组件
    inst.entity:AddAnimState()	-- 添加动画组件
--  inst.entity:AddSoundEmitter() -- 添加音效组件
    inst.entity:AddNetwork() -- 添加网络组件

	MakeInventoryPhysics(inst) -- 设置物品拥有一般物品栏物体的物理特性，对于放在物品栏里的物理Phiysics，让其可以放地上，具体代码在 standardcomponents.lua

	inst.AnimState:SetBank("dota_desolator") -- 设置动画属性 Bank
    inst.AnimState:SetBuild("dota_desolator") -- 设置动画属性 Build
    inst.AnimState:PlayAnimation("idle") -- 设置默认播放动画为idle

	inst:AddTag("sharp")
	inst:AddTag("weapon")
	inst:AddTag("dota_desolator")
    inst:AddTag("dota_equipment")

	---------------------- 主客机分界代码 -------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------------------------------------------------  

	inst:AddComponent("inspectable")	--可检查

    inst:AddComponent("inventoryitem")		-- 可放入物品栏
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dota_desolator.xml" -- 设置物品栏图片文档

	inst:AddComponent("weapon")		--武器
    inst.components.weapon:SetDamage(TUNING.DOTA.DESOLATOR_DAMAGE)

	inst:AddComponent("equippable")		--装备
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    --inst.components.equippable.walkspeedmult = TUNING.BATTLE_FURY_SPEED_MULT	-- 加速效果

	MakeHauntableLaunch(inst)	--可作祟

    return inst
end

return Prefab("dota_desolator", fn, assets, prefabs)