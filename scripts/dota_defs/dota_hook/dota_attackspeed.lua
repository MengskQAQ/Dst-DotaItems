-------------------------------------------------攻速系统-------------------------------------------------
-- hook了攻击动作的SG播放速度，让玩家的攻速可以被改变
-- 由于采取的是白名单制，只有位于 sg_states 表中的SG才会改变，其他mod独特的攻击动作必须主动添加才可以兼容
-- 与智力跳buff实现方式相仿，因此智力跳buff也会增加攻速
-- BUG：这个写法当攻速达到一个上限时，会丢失sg里的timeline，还是需要考虑一下限制最高速度等方法规避这个bug

local sg_states = {
    attack = true,
    blowdart = true,
    slingshot_shoot = true,
    throw = true,
    attack_prop_pre = true,
    myth_weapon_attack = true,
    madameweb_attack = true,
}

local ATTACKSPEED = TUNING.DOTA.ECHO_SABRE.ECHO.ATTACKSPEED

local function ServerResetAttackPerior(state)
    if not state.timeline then return end

    local old_onenter = state.onenter
    state.onenter = function(inst, ...)
        if old_onenter then
            old_onenter(inst, ...)
        end

        if inst:HasTag("dotaattributes") then
            local attackspeed = inst.components.dotaattributes.attackspeed:Get()
            if inst:HasTag("dota_echo") then
                attackspeed = math.max(ATTACKSPEED, attackspeed)
            end
            inst.AnimState:SetDeltaTimeMultiplier(attackspeed)
            for _, v in pairs(state.timeline) do
                v.dota_astime = v.dota_astime or v.time
                v.time = v.time / attackspeed
            end
				-- local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
				-- cooldown = math.max( cooldown, 6 * FRAMES)
				-- inst.sg:SetTimeout(cooldown)
				-- inst:PerformBufferedAction()
			-- end
        end

    end
    local old_onexit = state.onexit
    state.onexit = function(inst, ...)
        if old_onexit then
            old_onexit(inst, ...)
        end
        if inst:HasTag("dotaattributes") then
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("attack")
            inst.sg:RemoveStateTag("abouttoattack")
            for _, v in pairs(state.timeline) do
                v.time = v.dota_astime or v.time
                v.dota_astime = nil
            end
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end
    end
end

AddStategraphPostInit("wilson", function(sg)
    for k, v in pairs(sg_states) do
        if v then
            local statename = sg.states[k]
            if statename then
                ServerResetAttackPerior(statename)
            end
        end
    end
end)

local function ClientResetAttackPerior(state)
    if not state.timeline then 
        return 
    end
    local old_onenter = state.onenter
    state.onenter = function(inst, ...)
        if old_onenter then
            old_onenter(inst, ...)
        end

        if inst:HasTag("dotaattributes") then
            local attackspeed = inst.replica.dotaattributes:GetAttackSpeed()
			-- if attackspeed ~= 1 then
            if inst:HasTag("dota_echo") then
                attackspeed = math.max(ATTACKSPEED, attackspeed)
            end
            -- print("debug ".. attackspeed)
            inst.AnimState:SetDeltaTimeMultiplier(attackspeed)
            for _, v in pairs(state.timeline) do
                v.dota_astime = v.dota_astime or v.time
                v.time = v.time / attackspeed
            end
				-- local cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
				-- cooldown = math.max( cooldown, 6 * FRAMES)
				-- inst.sg:SetTimeout(cooldown)
			-- end

            -- 回音战刃 or 连击刀
            -- if inst.sg.statemem.dota_echo > 0 then
            --     inst.sg.statemem.dota_echo = inst.sg.statemem.dota_echo - 1
            --     for k, v in ipairs(state.timeline) do   -- TODO:  可能导致bug
            --         v.time = k/4 * FRAMES -- 顺序执行完所有判定
            --     end
            --     inst.sg:SetTimeout(0.5 * FRAMES + 1 * FRAMES) -- 极限间隔，然后加一点容错
            -- end

        end
    end

    local old_onexit = state.onexit
    state.onexit = function(inst, ...)
        if old_onexit then
            old_onexit(inst, ...)
        end
        if inst:HasTag("dotaattributes") then
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("attack")
            inst.sg:RemoveStateTag("abouttoattack")
            for _, v in pairs(state.timeline) do
                v.time = v.dota_astime or v.time
                v.dota_astime = nil
            end
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end
    end
end
AddStategraphPostInit("wilson_client", function(sg)
    for k, v in pairs(sg_states) do
        if v then
            local statename = sg.states[k]
            if statename then
                ClientResetAttackPerior(statename)
            end
        end
    end
end)