---------------------------分裂攻击buff-------------------------------

local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "player"}	--分裂攻击排除对象
-- if not TheNet:GetPVPEnabled() then   --不确定buff能不能添加Net组件，暂时就不添加了
--     table.insert(exclude_tags, "player")
-- end

local function OnHitOther(inst, data)
    if data and data.target and data.damage then
        local target = data.target
        local damage = data.damage
        local x, y, z = target.Transform:GetWorldPosition()	-- 获取被攻击对象的世界坐标
        local ents = TheSim:FindEntities(x, y, z, TUNING.DOTA.BATTLE_FURY_CLEAVA_RANGE, { "_combat" }, exclude_tags) --攻击范围	 -- 通过 TheSim:FindEntities() 函数查找周围的实体
        for i, ent in ipairs(ents) do	 -- 遍历找到的实体
			local angleto = math.abs(anglediff(inst.Transform:GetRotation(), inst:GetAngleToPoint(ent:GetPosition())))	--取自woetox.lua的296行函数，形成三角形分裂范围
            if ent ~= target
				and ent ~= inst
				and inst.components.combat:IsValidTarget(ent)
				and (inst.components.leader ~= nil
				and angleto <= TUNING.DOTA.BATTLE_FURY_CLEAVA_ANGLE
				and not inst.components.leader:IsFollower(ent)) then
                    inst:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = nil }) -- 推送事件给服务器来计算其它实体的血量以及通知其它玩家，当前多少实体正在被攻击
					ent.components.combat:GetAttacked(inst, 0, inst, nil)	-- 给予实体伤害，这里的伤害值传多少就是多少,因为仅仅为了仇恨和动画，仅传0伤害
					ent.components.health:DoDelta(-damage*TUNING.DOTA.BATTLE_FURY_CLEAVA_MULTIPLE, nil, "buff_cleava", nil, nil, true) --为了无视护甲，但又要播放sg，所以用了2个函数计算伤害
				--	owner.components.talker:Say(tostring(angleto))	--debug
            end
        end
    end
end

local function OnAttached(inst, target)		--触发buff
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) -- in case of loading

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

	inst:ListenForEvent("onhitother", OnHitOther)
end

local function OnDetached(inst, target)	--消除buff
    inst:RemoveEventCallback("onhitother", OnHitOther)
	inst:Remove()
end

-- local function OnTimerDone(inst, data)
--     if data.name == "timer_dota_cleava" then
--         inst.components.debuff:Stop()
--     end
-- end

-- local function OnExtended(inst, target)	-- 重复使用buff时
--     inst.components.timer:StopTimer("timer_dota_cleava")
--     inst.components.timer:StartTimer("timer_dota_cleava", TUNING.DOTA.BATTLE_FURY_CLEAVA_DURATION)
-- end

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
    -- inst.components.debuff:SetExtendedFn(OnExtended)
    inst.components.debuff.keepondespawn = true

    -- inst:AddComponent("timer")
    -- inst.components.timer:StartTimer("timer_dota_cleava", TUNING.DOTA.INVIA_SWORD_WALK_DURATION)	--设置buff持续时长
    -- inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("buff_dota_shadowwalk", fn)