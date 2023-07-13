---------------------------天神下凡buff-------------------------------

local function OnAttached(inst, target)		--触发buff
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) -- in case of loading
			
	target.AnimState:SetMultColour(0.95, 0.76, 0.1, 1)	-- 调整rgba至金黄色效果
	
    if not target:HasTag("dota_avatar") then
        target:AddTag("dota_avatar")
    end

	if target.components.health ~= nil  then	--上帝模式
        target.components.health:SetInvincible(true)
    end
	
    local Scale = target.Transform:GetScale()   -- 调整模型大小
	if Scale then 
	    target.Transform:SetScale(Scale*TUNING.DOTA.BLACK_KING_BAR_SCALE, Scale*TUNING.DOTA.BLACK_KING_BAR_SCALE, Scale*TUNING.DOTA.BLACK_KING_BAR_SCALE)
    end

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)	
end

--Todo: 是否要考虑bkb期间上下线的save和load问题？
local function OnDetached(inst, target)	--消除buff
    if target:HasTag("dota_avatar") then
        target:RemoveTag("dota_avatar")
    end

	if target.components.health ~= nil and target.components.health:IsInvincible() then	--移除上帝模式
        target.components.health:SetInvincible(false)
    end

    local Scale = target.Transform:GetScale()   -- 恢复模型大小
	if Scale and Scale > 1 then
	    target.Transform:SetScale(Scale/TUNING.DOTA.BLACK_KING_BAR_SCALE, Scale/TUNING.DOTA.BLACK_KING_BAR_SCALE, Scale/TUNING.DOTA.BLACK_KING_BAR_SCALE)
    end

	target.AnimState:SetMultColour(1, 1, 1, 1)	--恢复rbga
	inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "timer_dota_avatar" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)	-- 重复使用buff时
    inst.components.timer:StopTimer("timer_dota_avatar")
    inst.components.timer:StartTimer("timer_dota_avatar", TUNING.DOTA.BLACK_KING_BAR_DURATION)
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
    inst.components.timer:StartTimer("timer_dota_avatar", TUNING.DOTA.BLACK_KING_BAR_DURATION)	--设置buff持续时长
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("buff_dota_avatar", fn)