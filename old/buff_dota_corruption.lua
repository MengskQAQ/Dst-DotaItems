------------------------------------ 减甲buff -----------------------------

-- local function do_hit_fx(inst)
-- 	local fx = SpawnPrefab("abigail_vex_hit")
-- 	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
-- end

-- local function on_target_attacked(inst, target, data)
-- 	if data ~= nil and data.attacker ~= nil and data.attacker:HasTag("ghostlyfriend") then
-- 		inst.hitevent:push()
-- 	end
-- end

local function buff_OnExtended(inst)
	if inst.decaytimer ~= nil then
		inst.decaytimer:Cancel()
	end
	inst.decaytimer = inst:DoTaskInTime(TUNING.DOTA.DESOLATOR_CORRUPTION_DURATION, function() inst.components.debuff:Stop() end)
end

local function buff_OnAttached(inst, target)
	if target ~= nil and target:IsValid() and not target.inlimbo and target.components.combat ~= nil and target.components.health ~= nil and not target.components.health:IsDead() then
		target.components.combat.externaldamagetakenmultipliers:SetModifier(inst, TUNING.DOTA.DESOLATOR_CORRUPTION)

		inst.entity:SetParent(target.entity)
		inst.Transform:SetPosition(0, 0, 0)
		-- local s = (1 / target.Transform:GetScale()) * (target:HasTag("largecreature") and 1.6 or 1.2)
		-- if s ~= 1 and s ~= 0 then
		-- 	inst.Transform:SetScale(s, s, s)
		-- end

		-- inst:ListenForEvent("attacked", inst._on_target_attacked, target)
	end

	buff_OnExtended(inst)

    inst:ListenForEvent("death", function() inst.components.debuff:Stop() end, target)
end

local function buff_OnDetached(inst, target)
	if inst.decaytimer ~= nil then
		inst.decaytimer:Cancel()
		inst.decaytimer = nil

		if target ~= nil and target:IsValid() and target.components.combat ~= nil then
			target.components.combat.externaldamagetakenmultipliers:RemoveModifier(inst)
		end

		-- inst.AnimState:PushAnimation("vex_debuff_pst", false)
		-- inst:ListenForEvent("animqueueover", inst.Remove)
	end
end

local function fn()
    local inst = CreateEntity()

    -- inst.entity:AddTransform()
    -- inst.entity:AddAnimState()
    -- inst.entity:AddNetwork()

	-- inst.AnimState:SetBank("abigail_debuff_fx")
	-- inst.AnimState:SetBuild("abigail_debuff_fx")

	-- inst.AnimState:PlayAnimation("vex_debuff_pre")
	-- inst.AnimState:PushAnimation("vex_debuff_loop", true)
	-- inst.AnimState:SetFinalOffset(3)

	-- inst:AddTag("FX")


	-- inst.hitevent = net_event(inst.GUID, "abigail_vex_debuff.hitevent")

	-- if not TheNet:IsDedicated() then
    --     inst:ListenForEvent("abigail_vex_debuff.hitevent", do_hit_fx)
	-- end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst:AddTag("CLASSIFIED")

    inst.persists = false
	-- inst._on_target_attacked = function(target, data) on_target_attacked(inst, target, data) end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(buff_OnDetached)
    inst.components.debuff:SetExtendedFn(buff_OnExtended)

	return inst
end

return Prefab("buff_dota_corruption", fn)