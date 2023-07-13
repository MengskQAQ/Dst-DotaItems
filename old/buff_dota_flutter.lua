---------------------------振翅buff-------------------------------

local function OnAttached(inst, target)		--触发buff
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) -- in case of loading

    if target.components.locomotor ~= nil then
        target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_flutter", (1+TUNING.DOTA.BUTTERFLY_FLUTTER_SPEEDMULTI))
    end
	
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function OnDetached(inst, target)	--消除buff
    if target.components.locomotor ~= nil then
        target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_flutter")
    end
	inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "timer_dota_flutter" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)	-- 重复使用buff时
    inst.components.timer:StopTimer("timer_dota_flutter")
    inst.components.timer:StartTimer("timer_dota_flutter", TUNING.DOTA.BUTTERFLY_FLUTTER_SPEEDMULTI)
end

local function fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        -- Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    -- inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetExtendedFn(OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("timer_dota_flutter", TUNING.DOTA.BUTTERFLY_FLUTTER_DURATION)	--设置buff持续时长
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("buff_dota_flutter", fn)