---------------------------------------------跳刀------------------------------------------

-- 加载资源表
local assets =
{
    Asset("ANIM", "anim/dota_blink_dagger.zip"),
	Asset("ANIM", "anim/swap_dota_blink_dagger.zip"),
    Asset("ATLAS", "images/inventoryimages/dota_blink_dagger.xml"),
	Asset("IMAGE", "images/inventoryimages/dota_blink_dagger.tex"),
}

local function onblink(inst, pt, caster)
	inst.components.rechargeable:Discharge(TUNING.DOTA.BLINK_DAGGER_BLINK_CD)		--冷却时间
end

-- local function ondischarged(inst)	--冷却时间去除传送组件
	-- if inst.components.blinkdagger ~= nil then
		-- inst:RemoveComponent("blinkdagger")
	-- end
-- end

-- local function oncharged(inst)	--冷却时间结束添加传送组件
	-- if inst.components.blinkdagger == nil then
		-- inst:AddComponent("blinkdagger")
		-- inst.components.blinkdagger.onblinkfn = onblink
	-- end
-- end

--写法来自orangestaff，作用未知
local function NoHoles(pt)
    return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local BLINKFOCUS_MUST_TAGS = { "blinkfocus" }

local function blinkstaff_reticuletargetfn()
    local player = ThePlayer
    local rotation = player.Transform:GetRotation()
    local pos = player:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.CONTROLLER_BLINKFOCUS_DISTANCE, BLINKFOCUS_MUST_TAGS)
    for _, v in ipairs(ents) do
        local epos = v:GetPosition()
        if distsq(pos, epos) > TUNING.CONTROLLER_BLINKFOCUS_DISTANCESQ_MIN then
            local angletoepos = player:GetAngleToPoint(epos)
            local angleto = math.abs(anglediff(rotation, angletoepos))
            if angleto < TUNING.CONTROLLER_BLINKFOCUS_ANGLE then
                return epos
            end
        end
    end
    rotation = rotation * DEGREES
    for r = 13, 1, -1 do
        local numtries = 2 * PI * r
        local offset = FindWalkableOffset(pos, rotation, r, numtries, false, true, NoHoles)
        if offset ~= nil then
            pos.x = pos.x + offset.x
            pos.y = 0
            pos.z = pos.z + offset.z
            return pos
        end
    end
end

-- 添加受击惩罚cd
local CanBlinkBagger = function(inst, data)
	local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)	-- 获取手部武器
	if weapon ~= nil and weapon.components.rechargeable ~= nil then
		if weapon.components.rechargeable:IsCharged() then
			weapon.components.rechargeable:Discharge(TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_CD)		
		elseif (weapon.components.rechargeable:GetTimeToCharge() <= TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_CD) then
			weapon.components.rechargeable:SetCharge(0)
			weapon.components.rechargeable:Discharge(TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_CD)
		end
	end
end

-- 装备回调
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_dota_blink_dagger", "swap_dota_blink_dagger")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	owner:ListenForEvent("attacked", CanBlinkBagger)
end

-- 卸载回调
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	owner:RemoveEventCallback("attacked", CanBlinkBagger)
end

--主函数
local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()	-- 添加变换组件
    inst.entity:AddAnimState()	-- 添加动画组件
--  inst.entity:AddSoundEmitter() -- 添加音效组件
    inst.entity:AddNetwork() -- 添加网络组件

	MakeInventoryPhysics(inst) -- 设置物品拥有一般物品栏物体的物理特性，对于放在物品栏里的物理Phiysics，让其可以放地上，具体代码在 standardcomponents.lua

	inst.AnimState:SetBank("dota_blink_dagger") -- 设置动画属性 Bank
    inst.AnimState:SetBuild("dota_blink_dagger") -- 设置动画属性 Build
    inst.AnimState:PlayAnimation("idle") -- 设置默认播放动画为idle

	inst:AddTag("sharp")
	inst:AddTag("dota_blink_dagger")
    inst:AddTag("dota_equipment")
	
	inst:AddComponent("reticule")	--寻找可用传送点????
    inst.components.reticule.targetfn = blinkstaff_reticuletargetfn	--似乎是处理传送后主客机之间的position问题
    inst.components.reticule.ease = true

	---------------------- 主客机分界代码 -------------------------
    inst.entity:SetPristine() 
    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------------------------------------------------  

	inst:AddComponent("inspectable")	--可检查

    inst:AddComponent("inventoryitem")		-- 可放入物品栏
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dota_blink_dagger.xml" -- 设置物品栏图片文档

	inst:AddComponent("weapon")		--武器
    inst.components.weapon:SetDamage(TUNING.DOTA.BLINK_DAGGER_DAMAGE)

	inst:AddComponent("equippable")		--装备
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.DOTA.BLINK_DAGGER_SPEED_MULT + 1	-- 加速效果

	inst:AddComponent("blinkdagger")	--传送组件
    inst.components.blinkdagger.onblinkfn = onblink
	inst.components.blinkdagger:SetMaxDistance(TUNING.DOTA.BLINK_DAGGER_BLINK_MAX_DISTANCE)
	inst.components.blinkdagger:SetPenDistance(TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_DISTANCE)
	
	inst:AddComponent("rechargeable") -- 冷却组件
	-- inst.components.rechargeable:SetOnDischargedFn(ondischarged)
	-- inst.components.rechargeable:SetOnChargedFn(oncharged)
	
	MakeHauntableLaunch(inst)	--可作祟

    return inst
end

return Prefab("dota_blink_dagger", fn, assets, prefabs)