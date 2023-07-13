---------------------------连环闪电buff-------------------------------

local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "player"}	--连环闪电攻击排除对象
-- if not TheNet:GetPVPEnabled() then   --不确定buff能不能添加Net组件，暂时就不添加了
--     table.insert(exclude_tags, "player")
-- end

--获取连环闪电的下一个目标
local function GetNextTarget(inst, target)
    local targetlist = {}
    local x, y, z = target.Transform:GetWorldPosition()	-- 获取被攻击对象的世界坐标
    local ents = TheSim:FindEntities(x, y, z, TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_DISTANCE, { "_combat" }, exclude_tags) --攻击范围	 -- 通过 TheSim:FindEntities() 函数查找周围的实体
    for i, ent in ipairs(ents) do	 -- 遍历找到的实体
        if ent ~= target
         and ent ~= inst
         and inst.components.combat:IsValidTarget(ent)
         and (inst.components.leader ~= nil and not inst.components.leader:IsFollower(ent)) 
         then
            table.insert(targetlist, ent)
        end
    end
    if #targetlist > 0 then
        return targetlist[math.random(1,#targetlist)]
    end
    return nil
end

local function ChainLighting(inst, target, num)
    local nexttarget = GetNextTarget(inst, target)
    if nexttarget ~= nil then
        inst:PushEvent("onareaattackother", { target = target, weapon = inst, stimuli = "electric" }) -- 推送事件给服务器来计算其它实体的血量以及通知其它玩家，当前多少实体正在被攻击
        target.components.combat:GetAttacked(inst, TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_DAMAGE, inst, "electric")	-- 给予实体伤害，考虑防御
------------此处应该增加fx特效和prefabs特效
    end
    num = num + 1
    if num <= TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_NUMBER then
        inst:DoTaskInTime(TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_INTERVAL, ChainLighting, inst, nexttarget, num)
    end
end

local function UpdateChainLightingCD(inst)
    inst.ischainlifhtingready = true
end

--攻击时概率触发连锁闪电
local function OnHitOther(inst, data)
    if data and data.target and data.damage
     and (inst.ischainlifhtingready or math.random(0,1) <= 0.5) --第一次触发时可能 ischainlifhtingready 没有加载，所以加一个额外条件
     and math.random(0,1) <= TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_CHANCE
     then
        inst.ischainlifhtingready = false
        local target = data.target
        inst:PushEvent("onareaattackother", { target = target, weapon = inst, stimuli = "electric" }) -- 推送事件给服务器来计算其它实体的血量以及通知其它玩家，当前多少实体正在被攻击
        target.components.combat:GetAttacked(inst, TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_DAMAGE, inst, "electric")	-- 给予实体伤害，考虑防御
-------------此处应该增加fx特效和prefabs特效

        -- inst:DoPeriodicTask(0.3, LightingNextTarget)

        -- local target = GetNextTarget(inst,target)
        -- -- (0,0.3) (0.3,0.6) (0.9,1.2)
        -- for i = 1, TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_NUMBER, 1 do
        local num = 0
        inst:DoTaskInTime(TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_CD, UpdateChainLightingCD, inst)
        inst:DoTaskInTime(TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_INTERVAL, ChainLighting, inst, target, num)
        -- end
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
--     if data.name == "timer_dota_chain_lighting" then
--         inst.components.debuff:Stop()
--     end
-- end

-- local function OnExtended(inst, target)	-- 重复使用buff时
--     inst.components.timer:StopTimer("timer_dota_chain_lighting")
--     inst.components.timer:StartTimer("timer_dota_chain_lighting", TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_DURATION)
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
    -- inst.components.timer:StartTimer("timer_dota_chain_lighting", TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_DURATION)	--设置buff持续时长
    -- inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("buff_dota_chain_lighting", fn)