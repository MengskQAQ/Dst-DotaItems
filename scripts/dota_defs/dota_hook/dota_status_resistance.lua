------------------------------------状态抗性系统----------------------------------------
-- 总所周知，饥荒拥有多种负面状态，有 
-- pinnable 固定，像钢羊痰液
-- freezable 冰冻，像冰杖
-- fossilizable 石化，一般只在熔炉里出现，暂不考虑
-- sleeper 睡眠，像帐篷？
-- grogginess 昏昏沉沉，比如月灵攻击，熊大或者排箫
-- 事件ridersleep 针对的是骑行状态。比如骑牛，暂不考虑
-- 显然负面状态不止上面这些，不过总而言之，我们尽量让状态抗性能够减免这些负面状态的持续时间
-------------------------------------------------------------------------------------

AddComponentPostInit("pinnable", function(self)
	----------------------------------------------------
	------------------ RemainingRatio ------------------
	----------------------------------------------------
    -- 此函数用于计算控制的剩余时间比例
    -- 旧函数为：
    -- function self:RemainingRatio()
    --     local remaining = self.wearofftime - ( GetTime() - self.last_stuck_time )
    --     remaining = remaining - self.attacks_since_pinned * TUNING.PINNABLE_ATTACK_WEAR_OFF
    --     return remaining / self.wearofftime
    -- end
    --
    -- 公式推导过程: 
    -- 设 a = GetTime() - self.last_stuck_time
    --    b = self.attacks_since_pinned * TUNING.PINNABLE_ATTACK_WEAR_OFF
    --    x = self.wearofftime                                             -- 总控制时间
    --    y = 1- self.inst.components.dotaattributes.statusresistance      -- (1-状态抗性)
    -- 
    -- 所以原函数返回值 (x - a - b)/x
    --    期望的返回值 (xy -a -b)/xy ，即 控制时间x缩短为xy
    -- 得(xy -a -b)/xy = (x - a - b)/x + (xy -a -b)/xy - (x - a - b)/x
    --                 = 原函数返回值 - (a + b)(1 - y)/xy

    local old_RemainingRatio = self.RemainingRatio
    function self:RemainingRatio()
        if self.inst.components.dotaattributes ~= nil then
            local statusresistance = self.inst.components.dotaattributes.statusresistance:Get()
            if statusresistance == 1 then return 0 end  -- 因为公司中存在除法，所以对于01的处理要格外注意
            local remainratio = old_RemainingRatio(self) -- 原函数返回值
            local ab = GetTime() - self.last_stuck_time + self.attacks_since_pinned * TUNING.PINNABLE_ATTACK_WEAR_OFF
            return remainratio - ab * statusresistance/self.wearofftime * (1 - statusresistance)    -- 根据上面的推导写返回值
        end
        if old_RemainingRatio then
            return old_RemainingRatio(self)
        end
    end
end)

AddComponentPostInit("freezable", function(self)
	----------------------------------------------------
	---------------- ResolveWearOffTime ----------------
	----------------------------------------------------
    -- 这个函数用于输出状态的持续时间
    -- 所以简单地处理一下输出值就好了
    local old_ResolveWearOffTime = self.ResolveWearOffTime
    function self:ResolveWearOffTime(t)
        if self.inst.components.dotaattributes ~= nil then
            local oldWearOffTime = old_ResolveWearOffTime(self, t)
            local statusresistance = self.inst.components.dotaattributes.statusresistance:Get()
            return oldWearOffTime * (1 - statusresistance)
        end
        if old_ResolveWearOffTime then
            return old_ResolveWearOffTime(self,t)
        end        
    end
end)

AddComponentPostInit("sleeper", function(self)
	----------------------------------------------------
	--------------------- GoToSleep --------------------
	----------------------------------------------------
    -- 有没有可能其他mod的特殊功能会用到睡眠时间，导致出现bug呢？
    -- 这个sleeper需不需要用到状态抗性也是个问题，能否区分sleeper中的正负面呢
    local old_GoToSleep = self.GoToSleep
    function self:GoToSleep(sleeptime)
        if self.inst.components.dotaattributes ~= nil and sleeptime ~= nil then
            local statusresistance = self.inst.components.dotaattributes.statusresistance:Get()
            sleeptime = sleeptime * (1 - statusresistance)
            return old_GoToSleep(self, sleeptime)
        end
        if old_GoToSleep then
            return old_GoToSleep(self, sleeptime)
        end
    end
end)

AddComponentPostInit("grogginess", function(self)
    self.dota_oldwearoffduration = TUNING.GROGGINESS_WEAR_OFF_DURATION  -- 我们用一个变量记录角色原先的 wearoffduration
    ----------------------------------------------------
	------------------- AddGrogginess ------------------
	----------------------------------------------------
    -- 本来想修改onupdate的内容，但考虑到性能问题，还是选择了这个函数，这会导致如果mod作者用自定义函数就会导致状态抗性无法应用
    -- 角色的睡眠函数同时受睡眠值和睡眠持续时间的影响，大概是因为蘑菇蛋糕带来的睡眠抵抗值，所以才会由两者同时控制
    -- 睡眠值>抵抗值 角色睡眠，进入睡眠状态，时间为睡眠持续时间（knockoutduration）
    -- 睡眠值<=抵抗值 角色昏沉，时间为持续睡眠时间（knockoutduration）
    -- 已睡眠时间>持续睡眠时间 角色苏醒，进入昏沉状态，时间为昏沉时间（wearoffduration）
    local old_AddGrogginess = self.AddGrogginess
    function self:AddGrogginess(grogginess, knockoutduration)
        if self.inst.components.dotaattributes ~= nil then
            local statusresistance = self.inst.components.dotaattributes.statusresistance:Get()
            local duration = knockoutduration and (knockoutduration * (1 - statusresistance))   -- 让睡眠持续时间应用抗性
            grogginess = grogginess * (1 - statusresistance)    -- 让睡眠值应用抗性
            if self.inst.components.grogginess.wearoffduration ~= self.dota_oldwearoffduration * (1 - statusresistance) then -- 修改onupdate里的数值
                self.inst.components.grogginess.wearoffduration = self.dota_oldwearoffduration * (1 - statusresistance)  -- 让睡眠结束后的昏沉阶段应用抗性
            end
            return old_AddGrogginess(self, grogginess, duration)
        end
        if old_AddGrogginess then
            return old_AddGrogginess(self, grogginess, knockoutduration)
        end
    end

    ----------------------------------------------------
	---------------- SetWearOffDuration ----------------
	----------------------------------------------------
    -- 如果不是默认的wearoffduration值，我们记录一下
    -- 当然了，我们在此处假设其他mod不会直接修改wearoffduration这个值
    -- 如果修改的话，又要增加一部分性能消耗，或者更改onupdate，这是我们不希望看到的，等遇到了再做考虑
    local old_SetWearOffDuration = self.SetWearOffDuration 
    function self:SetWearOffDuration(duration)
        if self.inst.components.dotaattributes ~= nil then
            self.dota_oldwearoffduration = duration
            return old_AddGrogginess(self, duration)
        end
        if old_SetWearOffDuration then
            return old_AddGrogginess(self, duration)
        end
    end
end)

AddComponentPostInit("combat", function(self)
    ----------------------------------------------------
	------------------ BlankOutAttacks -----------------
	----------------------------------------------------
    -- 这个应该也要计算状态抗性
    local old_BlankOutAttacks = self.BlankOutAttacks 
    function self:BlankOutAttacks(fortime)
        if self.inst.components.dotaattributes ~= nil then
            local statusresistance = self.inst.components.dotaattributes.statusresistance:Get()
            fortime = fortime * (1 - statusresistance)
        end
        old_BlankOutAttacks(self, fortime)
    end
end)

-- AddPrefabPostInit("leif", function(inst)
--     local function OnHitOther(inst, other)
--         other:PushEvent("knockback", {
--             knocker = inst, -- 攻击者
--             radius = 200, -- 击飞范围
--             strengthmult = 1 -- 力量倍率
--         })
--     end
--     if inst.components.combat ~= nil then
--         inst.components.combat.onhitotherfn = OnHitOther
--     end
-- end)

----------------------------------------------------
--------------------- knockback --------------------
----------------------------------------------------
-- 特意考虑了击退抗性
-- 设动画播放长度 L ，且速度为1，得原始时间L
-- 获取状态抗性X，得到期望时间：(1-X)L
-- 期望速度=长度/期望时间 = 1/(1-X)

local function KnockbackReset(state, timeout)
    local old_onenter = state.onenter
    state.onenter = function(inst, ...)

        if inst:HasTag("dota_avatar") then  -- TODO：此处的bkb效果应独立放在bkb的文件里，不应混淆在一起
            return
        end

        if old_onenter then
            old_onenter(inst, ...)
        end

        if inst:HasTag("dotaattributes") then
            local statusresistance = inst.components.dotaattributes.statusresistance:Get() or 0
            local multiplier = statusresistance ~= 1 and ( 1/(1-statusresistance) ) or 1
            inst.AnimState:SetDeltaTimeMultiplier(multiplier)
            -- if state.timeline then   --没什么必要改这个，只有一个timeline里涉及了一个声音的播放
                -- for _, v in pairs(state.timeline) do
                    -- v.time = v.time * (1 - statusresistance)
                -- end
            -- end
            if timeout then
                inst.sg:SetTimeout(timeout * FRAMES * (1-statusresistance))
            end
        end

    end
    local old_onexit = state.onexit
    state.onexit = function(inst, ...)
        if old_onexit then
            old_onexit(inst, ...)
        end
        if inst:HasTag("dotaattributes") then
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end
    end
end 


AddStategraphPostInit("wilson", function(sg)
    local parry_knockback = sg.states.parry_knockback
    if parry_knockback then
        KnockbackReset(parry_knockback, 6)
    end

    -- 击退开始
    local knockback = sg.states.knockback
    if knockback then
        KnockbackReset(knockback)
    end

    -- 击退中途
    local knockback_pst = sg.states.knockback_pst
    if knockback_pst then
        KnockbackReset(knockback_pst)
    end

    -- 击退尾声
    local knockbacklanded = sg.states.knockbacklanded
    if knockbacklanded then
        KnockbackReset(knockbacklanded)
    end
end)

----------------------------------------------------
----------------------- yawn -----------------------
----------------------------------------------------
-- 关于打哈欠，暂时不归入状态抗性考虑

----------------------------------------------------
-------------------- toolbroke ---------------------
----------------------------------------------------
-- 装备损坏的强控，应该没必要吧

----------------------------------------------------
------------------ mindcontroller ------------------
----------------------------------------------------
-- 影织者的精神控制通过 debuff 里的 update 控制状态时长
-- 而负责计时的参数刚好被科雷放出来了
-- 因此我们可以非常便捷地把状态抗性应用上去

AddPrefabPostInit("mindcontroller", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0.1, function()
        local parent = inst.entity:GetParent()
        if parent and parent.components and parent.components.dotaattributes 
        and inst.countdown
        then
            local statusresistance = parent.components.dotaattributes.statusresistance:Get() or 0
            inst.countdown = math.max(3.5, math.floor(inst.countdown * (1 - statusresistance)))
        end
    end)
end)

local function MindControllerReset(state, timeout)
    local old_onenter = state.onenter
    state.onenter = function(inst, ...)

        if inst:HasTag("dota_avatar") then  -- TODO：此处的bkb效果应独立放在bkb的文件里，不应混淆在一起
            return
        end

        if old_onenter then
            old_onenter(inst, ...)
        end

        if inst:HasTag("dotaattributes") then
            local statusresistance = inst.components.dotaattributes.statusresistance:Get() or 0
            local multiplier = statusresistance ~= 1 and ( 1/(1-statusresistance) ) or 1
            inst.AnimState:SetDeltaTimeMultiplier(multiplier)

            if timeout then
                inst.sg:SetTimeout(timeout * FRAMES * (1-statusresistance))
            end
        end

    end
    local old_onexit = state.onexit
    state.onexit = function(inst, ...)
        if old_onexit then
            old_onexit(inst, ...)
        end
        if inst:HasTag("dotaattributes") then
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end
    end
end 

AddStategraphPostInit("wilson", function(sg)
    local mindcontrolled = sg.states.mindcontrolled
    if mindcontrolled then
        MindControllerReset(mindcontrolled)
    end

    local mindcontrolled_loop = sg.states.mindcontrolled_loop
    if mindcontrolled_loop then
        MindControllerReset(mindcontrolled_loop, 3)
    end

    local mindcontrolled_pst = sg.states.mindcontrolled_pst
    if mindcontrolled_pst then
        MindControllerReset(mindcontrolled_pst, 6)
    end
end)

----------------------------------------------------
----------------------- spit -----------------------
----------------------------------------------------
-- 这个 sg 与 devoured 相对应。暗影生物吞下时触发 devoured
-- 但实际上控制伤害效果由 spit 控制
-- 但状态抗性会导致类似巫医加速诅咒结算的特性出现
-- TODO：更改状态抗性导致伤害结算加快的特性

local function SpitReset(state)
    if not state.timeline then 
        return 
    end

    local old_onenter = state.onenter
    state.onenter = function(inst, ...)
        if old_onenter then
            old_onenter(inst, ...)
        end

        local player = inst.sg.statemem.devoured
        if player and player:HasTag("dotaattributes") then
            local statusresistance = player.components.dotaattributes.statusresistance:Get() or 0
            local multiplier = statusresistance ~= 1 and ( 1/(1-statusresistance) ) or 1
            inst.AnimState:SetDeltaTimeMultiplier(multiplier)
            for _, v in pairs(state.timeline) do
                v.dota_srtime = v.dota_srtime or v.time
                v.time = v.time * (1 - statusresistance)
            end
        end
    end

    local old_onexit = state.onexit
    state.onexit = function(inst, ...)
        if old_onexit then
            old_onexit(inst, ...)
        end
        for _, v in pairs(state.timeline) do
            v.time = v.dota_srtime or v.time
            v.dota_srtime = nil
        end
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end
end

AddStategraphPostInit("shadowthrall_horns", function(sg)
    local spit = sg.states.spit
    if spit then
        SpitReset(spit)
    end
end)