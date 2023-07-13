---------------------------伤害反弹buff-------------------------------
local function OnBlocked(owner, data)
--  owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_scalemail")
    if data.attacker ~= nil
     and data.original_damage ~= nil
     and not (data.attacker.components.health ~= nil and data.attacker.components.health:IsDead())
     and (data.weapon == nil or ((data.weapon.components.weapon == nil or data.weapon.components.weapon.projectile == nil) and data.weapon.components.projectile == nil))
     and not data.redirected
     and not data.attacker:HasTag("thorny") then
        owner:PushEvent("onareaattackother", { target = data.attacker, weapon = nil, stimuli = nil }) -- 推送事件给服务器来计算其它实体的血量以及通知其它玩家，当前多少实体正在被攻击
        data.attacker.components.combat:GetAttacked(owner, TUNING.DOTA.BLADE_MAIL_DAMAGE_RETURN_RATIO*data.original_damage, nil, nil)
    end
end

local function OnAttached(inst, target)		--触发buff
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) -- in case of loading

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

    inst:ListenForEvent("blocked", OnBlocked, target)   --????
    inst:ListenForEvent("attacked", OnBlocked, target)
end

local function OnDetached(inst, target)	--消除buff
    inst:RemoveEventCallback("blocked", OnBlocked, target)
    inst:RemoveEventCallback("attacked", OnBlocked, target)
	inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "timer_dota_damage_return" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)	-- 重复使用buff时
    inst.components.timer:StopTimer("timer_dota_damage_return")
    inst.components.timer:StartTimer("timer_dota_damage_return", TUNING.DOTA.BLADE_MAIL_DAMAGE_RETURN_DURATION)
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
    inst.components.timer:StartTimer("timer_dota_damage_return", TUNING.DOTA.BLADE_MAIL_DAMAGE_RETURN_DURATION)	--设置buff持续时长
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("buff_dota_damage_return", fn)