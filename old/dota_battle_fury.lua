--------------------------------狂战斧-------------------------------------
-- 加载资源表
local assets =
{
    Asset("ANIM", "anim/dota_battle_fury.zip"),
	Asset("ANIM", "anim/swap_dota_battle_fury.zip"),
    Asset("ATLAS", "images/inventoryimages/dota_battle_fury.xml"),
	Asset("IMAGE", "images/inventoryimages/dota_battle_fury.tex"),
}

local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "shadowminion" }	--分裂攻击排除对象
if not TheNet:GetPVPEnabled() then
    table.insert(exclude_tags, "player")
end

local function IsChopTree(inst,data)		--源自官方的bushhat
--	inst.isduringchoptree = not inst.isduringchoptree
--	if inst.isduringchoptree then
	local fury = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
--	inst.components.talker:Say(fury.isduringchoptree and "砍伐完了" or "砍伐未完")
	if fury ~= nil and fury.isduringchoptree then
		fury.isduringchoptree = not fury.isduringchoptree
		fury.components.tool:SetAction(ACTIONS.CHOP, TUNING.DOTA.BATTLE_FURY_CHOP)	--恢复至原效率
		fury.components.rechargeable:Discharge(TUNING.DOTA.BATTLE_FURY_CHOP_CD)		--冷却时间
			
		--end
--		inst.isduringchoptree = not inst.isduringchoptree
	end
end

-- local function OnTickCleava(inst, owner)
-- 	if owner.components.debuffable then
-- 		owner.components.debuffable:AddDebuff("buff_dota_avatar", "buff_dota_avatar")
-- 	end
-- end

-- 装备回调
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_dota_battle_fury", "swap_dota_battle_fury") -- 以下三句都是设置动画表现的，不会对游戏实际内容产生影响，你可以试试去掉的效果
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
--    owner.DynamicShadow:SetSize(1.7, 1) -- 设置阴影大小，你可以仔细观察装备荷叶伞时，人物脚下的阴影变化
	owner:ListenForEvent("working",IsChopTree)

	owner.components.debuffable:AddDebuff("buff_dota_avatar", "buff_dota_avatar")

	-- if inst.task_cleava ~= nil then
	-- 	inst.task_cleava:Cancel()
	-- end

	-- inst.task_cleava = inst:DoPeriodicTask(TUNING.DOTA.BATTLE_FURY_CLEAVA_DURATION, OnTickCleava, nil, owner)
end

-- 卸载回调
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry") -- 和上面的装备回调类似，可以试试去掉的结果
    owner.AnimState:Show("ARM_normal")
--    owner.DynamicShadow:SetSize(1.3, 0.6)

	if inst.isduringchoptree then
		inst.isduringchoptree = not inst.isduringchoptree
		inst.components.tool:SetAction(ACTIONS.CHOP, TUNING.DOTA.BATTLE_FURY_CHOP)
	end
	
	owner:RemoveEventCallback("working",IsChopTree)

	-- if inst.task_cleava ~= nil then
	-- 	inst.task_cleava:Cancel()
	-- end
	owner.components.debuffable:RemoveDebuff("buff_dota_avatar")
end

local function onuse(inst)
	local owner = inst.components.inventoryitem.owner
	if owner then
		if inst.components.rechargeable:IsCharged() then	--cd转好时
			inst.isduringchoptree = not inst.isduringchoptree
			if inst.isduringchoptree then
				inst.components.tool:SetAction(ACTIONS.CHOP, 99)	--提升效率至99
			else
				inst.components.tool:SetAction(ACTIONS.CHOP, TUNING.DOTA.BATTLE_FURY_CHOP)	--取消主动技能
			end
			owner.components.talker:Say(inst.isduringchoptree and "砍伐" or "取消砍伐")
		else
			owner.components.talker:Say(math.random(1,10) <= 5 and "冷却中" or "它还需要时间准备")
		end
	end
	return false
end

-- 未来放在装备栏里要添加的砍树动作绑定
-- local function onequipon()
-- 	inst:AddComponent("spellcaster")
-- 	inst.components.spellcaster:SetSpellFn(cleave_func)
-- 	inst.components.spellcaster.canuseontargets = true
-- 	inst.components.spellcaster.canusefrominventory = true
-- 	inst.components.spellcaster.canonlyuseonworkable = true
-- end

local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()	-- 添加变换组件
    inst.entity:AddAnimState()	-- 添加动画组件
--  inst.entity:AddSoundEmitter() -- 添加音效组件
    inst.entity:AddNetwork() -- 添加网络组件
	
	MakeInventoryPhysics(inst) -- 设置物品拥有一般物品栏物体的物理特性，对于放在物品栏里的物理Phiysics，让其可以放地上，具体代码在 standardcomponents.lua
	
	inst.AnimState:SetBank("dota_battle_fury") -- 设置动画属性 Bank
    inst.AnimState:SetBuild("dota_battle_fury") -- 设置动画属性 Build
    inst.AnimState:PlayAnimation("idle") -- 设置默认播放动画为idle

	inst:AddTag("sharp")
	inst:AddTag("weapon")
	inst:AddTag("tool")
    inst:AddTag("possessable_axe")
	inst:AddTag("dota_battle_fury")
	inst:AddTag("dota_equipment")
	
	
	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})	--取自axe.lua，作用存疑
	
	---------------------- 主客机分界代码 -------------------------
    inst.entity:SetPristine() 
    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------------------------------------------------  
	
	inst:AddTag("isduringchoptree")	--用于记录砍树状态	--想法源自卡尼猫windyknife.lua
	
	inst:AddComponent("inspectable")	--可检查
	
    inst:AddComponent("inventoryitem")		-- 可放入物品栏
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dota_battle_fury.xml" -- 设置物品栏图片文档
	
	inst:AddComponent("weapon")		--武器
    inst.components.weapon:SetDamage(TUNING.DOTA.BATTLE_FURY_DAMAGE)
	
	inst:AddComponent("equippable")		--装备
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    --inst.components.equippable.walkspeedmult = TUNING.BATTLE_FURY_SPEED_MULT	-- 加速效果
	
	inst:AddComponent("tool")	--工具
    inst.components.tool:SetAction(ACTIONS.CHOP, TUNING.DOTA.BATTLE_FURY_CHOP)		--拥有砍树
	
	inst:AddComponent("useableitem")	--添加可使用组件
	inst.components.useableitem:SetOnUseFn(onuse)

	inst:AddComponent("rechargeable") -- 添加冷却组件
	
	MakeHauntableLaunch(inst)	--可作祟
	
    return inst
end

return Prefab("dota_battle_fury", fn, assets, prefabs)