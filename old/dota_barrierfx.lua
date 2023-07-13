-- Todo：待制作 先拿铥矿头的特效将就将就
local assets = {
	Asset("ANIM", "anim/forcefield.zip"),
}

local MAX_LIGHT_FRAME = 6

local function OnCreateFn(inst, owner)
    inst.entity:SetParent(owner.entity)
    inst.Transform:SetPosition(0, 0.2, 0)
end

-- local function OnUpdateLight(inst, dframes)
--     local done
--     if inst._islighton:value() then
--         local frame = inst._lightframe:value() + dframes
--         done = frame >= MAX_LIGHT_FRAME
--         inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
--     else
--         local frame = inst._lightframe:value() - dframes
--         done = frame <= 0
--         inst._lightframe:set_local(done and 0 or frame)
--     end

--     inst.Light:SetRadius(3 * inst._lightframe:value() / MAX_LIGHT_FRAME)

--     if done then
--         inst._lighttask:Cancel()
--         inst._lighttask = nil
--     end
-- end

-- local function OnLightDirty(inst)
--     if inst._lighttask == nil then
--         inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
--     end
--     OnUpdateLight(inst, 0)
-- end

local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    -- inst._islighton:set(false)
    -- inst._lightframe:set(inst._lightframe:value())
    -- OnLightDirty(inst)
    inst:DoTaskInTime(.6, inst.Remove)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:AddFollower()

    -- Todo：待制作 
    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("forcefield")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

	-- inst.SoundEmitter:PlaySound("dontstarve/wilson/forcefield_LP", "loop")

	-- inst.Light:SetRadius(0)
    -- inst.Light:SetIntensity(.9)
    -- inst.Light:SetFalloff(.9)
    -- inst.Light:SetColour(1, 1, 1)
    -- inst.Light:Enable(true)
    -- inst.Light:EnableClientModulation(true)

    -- inst._lightframe = net_tinybyte(inst.GUID, "forcefieldfx._lightframe", "lightdirty")
    -- inst._islighton = net_bool(inst.GUID, "forcefieldfx._islighton", "lightdirty")
    -- inst._lighttask = nil
    -- inst._islighton:set(true)

	-- inst:AddTag("FX")

	inst.entity:SetPristine()

	-- OnLightDirty(inst)

	if not TheWorld.ismastersim then
		-- inst:ListenForEvent("lightdirty", OnLightDirty)
		return inst
	end

	inst.kill_fx = kill_fx

	inst.persists = false

	inst:AddComponent("dotashield")
    inst.components.dotashield:SetOnCreateFn(OnCreateFn)

	inst:ListenForEvent("Remove", function()
		local owner = inst.components.dotashield.owner
		if owner.components.dotaattributes ~= nil then
			owner.components.dotaattributes:RemoveMagicShield("dota_barrierfx")
		end
		inst.kill_fx(inst)
	end)

	inst:DoTaskInTime(TUNING.DOTA.PIPE_OF_INSIGHT.BARRIER.DURATION, function()
		inst:PushEvent("Remove")
	end)

	return inst
end

local function fn2()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:AddFollower()

    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("forcefield")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.kill_fx = kill_fx

	inst.persists = false

	inst:AddComponent("dotashield")
    inst.components.dotashield:SetOnCreateFn(OnCreateFn)

	inst:ListenForEvent("Remove", function()
		local owner = inst.components.dotashield.owner
		if owner.components.dotaattributes ~= nil then
			owner.components.dotaattributes:RemoveMagicShield("dota_insulationfx")
		end
		inst.kill_fx(inst)
	end)

	inst:DoTaskInTime(TUNING.DOTA.HOOD_OF_DEFIANCE.INSULATION.DURATION, function()
		inst:PushEvent("Remove")
	end)

	return inst
end

local SHROUDDAMAGE = TUNING.DOTA.SHROUD.SHROUD.DAMAGE
local function ontakedamage(inst, owner, damage)
    if owner.components.dotaattributes ~= nil and damage < SHROUDDAMAGE then
        owner.components.dotaattributes:Mana_DoDelta(damage, nil, "dota_shroud")
    end
end
local function fn3()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:AddFollower()

    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("forcefield")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.kill_fx = kill_fx

	inst.persists = false

	inst:AddComponent("dotashield")
    inst.components.dotashield:SetOnCreateFn(OnCreateFn)
    inst.components.dotashield:SetOnTakedamageFn(ontakedamage)

	inst:ListenForEvent("Remove", function()
		local owner = inst.components.dotashield.owner
		if owner.components.dotaattributes ~= nil then
			owner.components.dotaattributes:RemoveMagicShield("dota_shroudfx")
		end
		inst.kill_fx(inst)
	end)

	inst:DoTaskInTime(TUNING.DOTA.SHROUD.SHROUD.DURATION, function()
		inst:PushEvent("Remove")
	end)

	return inst
end

return Prefab("dota_barrierfx", fn, assets),
    Prefab("dota_insulationfx", fn2, assets),
    Prefab("dota_shroudfx", fn3, assets)