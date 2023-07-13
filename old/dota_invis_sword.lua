-------------------------------------------------------隐刀-----------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/dota_invis_sword.zip"),
	Asset("ANIM", "anim/swap_dota_invis_sword.zip"),
    Asset("ATLAS", "images/inventoryimages/dota_invis_sword.xml"),
	Asset("IMAGE", "images/inventoryimages/dota_invis_sword.tex"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_dota_invis_sword", "swap_dota_invis_sword") -- 设置动画表现
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

-- 卸载回调
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry") -- 和上面的装备回调类似，可以试试去掉的结果
    owner.AnimState:Show("ARM_normal")
end

local function onattack(inst, owner, target)	-- 对暗影生物造成额外伤害
	--local attacker = inst.components.inventoryitem.owner
    if target:HasTag("shadow") then
        target.components.health:DoDelta(-TUNING.DOTA.INVIA_SWORD_DAMAGE*TUNING.DOTA.INVIA_SWORD_SHADOWMULT)
    end
end

-- local function onuse(inst)
	-- local owner = inst.components.inventoryitem.owner
	-- if owner and owner:HasTag("player") then 	-- 判断是玩家
		-- if inst.components.rechargeable:IsCharged() then	-- cd转好时
			-- -- owner.components.talker:Say(math.random() < .5 and "我遁入阴影" or "敌人看不见我")
			-- -- owner.components.debuffable:AddDebuff("shadowwalkbuff", "shadowwalkbuff")	-- 具体buff处理在shadowwalkbuff.lua里面
			-- inst.components.rechargeable:Discharge(TUNING.DOTA.INVIA_SWORD_WALK_CD)		-- 进入冷却时间
		-- -- else
			-- -- owner.components.talker:Say(math.random(1,10) <= 5 and "冷却中" or "它还需要时间准备")
		-- end
	-- end
	-- return false
-- end

local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()	-- 添加变换组件
    inst.entity:AddAnimState()	-- 添加动画组件
--  inst.entity:AddSoundEmitter() -- 添加音效组件
    inst.entity:AddNetwork() -- 添加网络组件
	
	MakeInventoryPhysics(inst) -- 设置物品拥有一般物品栏物体的物理特性，对于放在物品栏里的物理Phiysics，让其可以放地上，具体代码在 standardcomponents.lua
	
	inst.AnimState:SetBank("dota_invis_sword") -- 设置动画属性 Bank
    inst.AnimState:SetBuild("dota_invis_sword") -- 设置动画属性 Build
    inst.AnimState:PlayAnimation("idle") -- 设置默认播放动画为idle
	
	inst:AddTag("shadow")
	inst:AddTag("sharp")	
	inst:AddTag("weapon")
	inst:AddTag("dota_invis_sword")
	inst:AddTag("dota_equipment")
	
	---------------------- 主客机分界代码 -------------------------
    inst.entity:SetPristine() 
    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------------------------------------------------  
	
	inst:AddComponent("inspectable")	--可检查
	
    inst:AddComponent("inventoryitem")		-- 可放入物品栏
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dota_invis_sword.xml" -- 设置物品栏图片文档
	
	inst:AddComponent("weapon")		--武器
    inst.components.weapon:SetDamage(TUNING.DOTA.INVIA_SWORD_DAMAGE)
	inst.components.weapon:SetOnAttack(onattack)
	
	-- inst:AddComponent("workable")
	-- inst.components.workable:SetWorkAction(ACTIONS.MINE)
	
	inst:AddComponent("equippable")		--装备
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	-- inst:AddComponent("useableitem")	--添加可使用组件
	-- inst.components.useableitem:SetOnUseFn(onuse)
	
	inst:AddComponent("rechargeable") -- 添加冷却组件
	
	MakeHauntableLaunch(inst)	--可作祟
	
    return inst
end

return Prefab("dota_invis_sword", fn, assets, prefabs)