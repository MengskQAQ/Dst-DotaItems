local assets =
{
    Asset("ANIM", "anim/lightning.zip"),
}

local LIGHTNING_MAX_DIST_SQ = 140*140

local function StartFX(inst)
	for i, v in ipairs(AllPlayers) do
		local distSq = v:GetDistanceSqToInst(inst)
		local k = math.max(0, math.min(1, distSq / LIGHTNING_MAX_DIST_SQ))
		local intensity = -(k-1)*(k-1)*(k-1)				--k * 0.8 * (k - 2) + 0.8

		--print("StartFX", k, intensity)
		if intensity > 0 then
			v:ScreenFlash(intensity <= 0.05 and 0.05 or intensity)
			v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 3)
		end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(2, 2, 2)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBank("lightning")
    inst.AnimState:SetBuild("lightning")
    inst.AnimState:PlayAnimation("anim")

    -- inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close", nil, nil, true)

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local sfx
    -- if not TheNet:IsDedicated() then
	-- 	inst:DoTaskInTime(0, PlayThunderSound)
	-- end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:DoTaskInTime(0, StartFX) -- so we can use the position to affect the screen flash

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:DoTaskInTime(.5, inst.Remove)

    return inst
end

return Prefab("dota_fx_lightning", fn, assets)
