--这个隐身效果会影响tag和移速
--受影响的tag有：shadow，scarytoprey，notarget
--如果发生bug时，可能是这几个因素导致的

local function OnAttached(inst, target)		--触发buff
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) -- in case of loading
		
	RemovePhysicsColliders(target)	--去除碰撞体积
	
	target.components.locomotor:SetExternalSpeedMultiplier(inst, "dota_shadowwalk", (1+TUNING.DOTA.INVIA_SWORD_WALK_SPEEDMULT))	-- 加速效果
	
	target.AnimState:SetMultColour(0.3, 0.3, 0.3, 0.4)	-- 调整rgba至半透明效果
    
    if not target:HasTag("dota_appeared") then
        local x,y,z = target.Transform:GetWorldPosition()	--清除仇恨 --修改自龙蝇客栈龙威茶
        local ents = TheSim:FindEntities(x,y,z, 20, { "_combat" }, { "player" })
        for _,v in ipairs(ents) do
            if v.components.combat:HasTarget() 
            and v.components.combat:IsRecentTarget(target) --仅消除目标为持有者的仇恨
            and not v:HasTag("detection")	--敌人不具备反隐tag
            then
                v.components.combat:DropTarget()
            end
        end
    end
	
    if target.IsHasTagShadow == nil then target.IsHasTagShadow = true end
    if target.IsHasTagNotarget == nil then target.IsHasTagNotarget = true end
    if target.IsHasTagScarytoprey == nil then target.IsHasTagScarytoprey = true end
	if not target:HasTag("shadow") then	--添加伪隐身效果tag
        target.IsHasTagShadow = false
        target:AddTag("shadow")
    end
	if not target:HasTag("notarget") then
        target.IsHasTagNotarget = false
        target:AddTag("notarget")
    end
	if target:HasTag("scarytoprey") then
        target.IsHasTagScarytoprey = false
        target:RemoveTag("scarytoprey")
    end

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
	
	--大隐刀需要修改此处
	inst:ListenForEvent("onhitother", function(player,data)
		inst.components.debuff:Stop()
		if data and data.target then
			local enemy = data.target
			enemy.components.health:DoDelta(-TUNING.DOTA.INVIA_SWORD_WALK_BONUS_DAMAGE)
		end
    end, target)
end

local function OnDetached(inst, target)	--消除buff
    --需要确认player是否本身具有这些tag
	target.components.locomotor:RemoveExternalSpeedMultiplier(target, "dota_shadowwalk")	--恢复速度
	if not target.IsHasTagShadow then   target:RemoveTag("shadow")    end --恢复tag
	if not target.IsHasTagNotarget then   target:RemoveTag("notarget")    end
    if not target.IsHasTagScarytoprey then   target:AddTag("scarytoprey")    end
	target.AnimState:SetMultColour(1, 1, 1, 1)	--恢复rbga
	inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "timer_dota_shadowwalk" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)	-- 重复使用buff时
    inst.components.timer:StopTimer("timer_dota_shadowwalk")
    inst.components.timer:StartTimer("timer_dota_shadowwalk", TUNING.DOTA.INVIA_SWORD_WALK_DURATION)
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
    inst.components.timer:StartTimer("timer_dota_shadowwalk", TUNING.DOTA.INVIA_SWORD_WALK_DURATION)	--设置buff持续时长
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("buff_dota_shadowwalk", fn)