function Example()
local defaultattackspeed = 0   -- 默认攻速
local attackspeedratio = math.max( 1 + defaultattackspeed, 0.1)
local tofloor = function(cvar)
    return math.floor(cvar + 0.5)   -- 向下取整
end
local IsMythMod = false
for _, mod in ipairs (KnownModIndex:GetModNames()) do
    if mod == "workshop-1699194522" then
        IsMythMod = true
    end
end
local function ServerResetAttackPerior(playerstates)
    if not playerstates.timeline then
        return
    end
    local oldonenter = playerstates.onenter
    playerstates.onenter = function(playerstates)
        if oldonenter then
            oldonenter(playerstates)
        end
        if playerstates:HasTag("dax_keydown") then
            playerstates.AnimState:SetDeltaTimeMultiplier(attackspeedratio)
            -- for k2, v2 in pairs(playerstates.timeline) do
            --     v2.FrameIndex = tofloor( v2.time / FRAMES )
            -- end
            -- for k3, v3 in pairs(playerstates.timeline) do
            --     v3.time = tofloor( v3.FrameIndex / attackspeedratio) * FRAMES
            -- end
            for k4, v4 in pairs(playerstates.timeline) do
                v4.time = tofloor( v4.time / attackspeedratio)
            end
            local combat = playerstates.components.combat
            if combat then
                if not playerstates.OldMinAttackPeriod then
                    playerstates.OldMinAttackPeriod = combat.min_attack_period
                end
                combat.min_attack_period = playerstates.OldMinAttackPeriod / attackspeedratio
            end
            local minattackperiod = combat.min_attack_period
            minattackperiod = math.max( minattackperiod, 6 * FRAMES)
            playerstates.sg:SetTimeout(minattackperiod)
            playerstates:PerformBufferedAction()
        end
    end
    local oldonexit = playerstates.onexit
    playerstates.onexit = function(playerstates)
        if oldonexit then
            oldonexit(playerstates)
        end
        if playerstates:HasTag("dax_keydown") then
            playerstates.sg:RemoveStateTag("busy")
            playerstates.sg:RemoveStateTag("attack")
            playerstates.sg:RemoveStateTag("abouttoattack")
            playerstates.AnimState:SetDeltaTimeMultiplier(1)
        end
    end
end
AddStategraphPostInit("wilson", function(player)
    local attack = player.states.attack
    if attack then
        ServerResetAttackPerior(attack)
    end
    local blowdart = player.states.blowdart
    if blowdart then
        ServerResetAttackPerior(blowdart)
    end
    local slingshot_shoot = player.states.slingshot_shoot
    if slingshot_shoot then
        ServerResetAttackPerior(slingshot_shoot)
    end
    local throw = player.states.throw
    if throw then
        ServerResetAttackPerior(throw) 
    end
    local attack_prop_pre = player.states.attack_prop_pre
    if attack_prop_pre then 
        ServerResetAttackPerior(attack_prop_pre) 
    end
    local multithrust_pre = player.states.multithrust_pre
    if multithrust_pre then
        ServerResetAttackPerior(multithrust_pre)
    end
    local helmsplitter_pre = player.states.helmsplitter_pre
    if helmsplitter_pre then 
        ServerResetAttackPerior(helmsplitter_pre) 
    end
    if IsMythMod then
        local myth_weapon_attack =player.states.myth_weapon_attack
        if myth_weapon_attack then
            ServerResetAttackPerior(myth_weapon_attack)
        end
        local madameweb_attack =player.states.madameweb_attack
        if madameweb_attack then
            ServerResetAttackPerior(madameweb_attack)
        end
    end
end)
local function ClientResetAttackPerior(playerstates)
    if not playerstates.timeline then 
        return 
    end
    local oldonenter = playerstates.onenter
    playerstates.onenter = function(playerstates)
        if oldonenter then
            oldonenter(playerstates)
        end
        if playerstates:HasTag("dax_keydown") then
            playerstates.AnimState:SetDeltaTimeMultiplier(attackspeedratio)
            for k4, v4 in pairs(playerstates.timeline) do
                v4.FrameIndex = tofloor(v4.time / FRAMES)
            end
            for k5, v5 in pairs(playerstates.timeline) do
                v5.time = tofloor(v5.FrameIndex / attackspeedratio) * FRAMES
            end
            local combat = playerstates.replica.combat
            if combat then
                if not playerstates.OldMinAttackPeriod then
                    playerstates.OldMinAttackPeriod = combat:MinAttackPeriod() or 0.4
                end
                combat:SetMinAttackPeriod(playerstates.OldMinAttackPeriod / attackspeedratio)
            end
            local attackspeedmulti = playerstates.OldMinAttackPeriod / attackspeedratio
            attackspeedmulti = math.max	(attackspeedmulti, 6 * FRAMES)
            playerstates.sg:SetTimeout(attackspeedmulti)
        end
    end
    local oldonexit = playerstates.onexit
    playerstates.onexit = function(playerstates)
        if oldonexit then
            oldonexit(playerstates)
        end
        if playerstates:HasTag("dax_keydown") then
            playerstates.sg:RemoveStateTag("busy")
            playerstates.sg:RemoveStateTag("attack")
            playerstates.sg:RemoveStateTag("abouttoattack")
            playerstates.AnimState:SetDeltaTimeMultiplier(1)
        end
    end
end
AddStategraphPostInit("wilson_client", function(player)
    local attack = player.states.attack
    if attack then
        ClientResetAttackPerior(attack)
    end
    local blowdart = player.states.blowdart
    if blowdart then
        ClientResetAttackPerior(blowdart)
    end
    local slingshot_shoot = player.states.slingshot_shoot
    if slingshot_shoot then
        ClientResetAttackPerior(slingshot_shoot)
    end
    local throw = player.states.throw
    if throw then
        ClientResetAttackPerior(throw)
    end
    local attack_prop_pre = player.states.attack_prop_pre
    if attack_prop_pre then
        ClientResetAttackPerior(attack_prop_pre)
    end
    if IsMythMod then
        local myth_weapon_attack = player.states.myth_weapon_attack
        if myth_weapon_attack then
            ClientResetAttackPerior(myth_weapon_attack)
        end
        local madameweb_attack = player.states.madameweb_attack
        if madameweb_attack then
            ClientResetAttackPerior(madameweb_attack)
        end
    end
end)
end

----------------------------------------------------------------------------------------------------- 恒子的方案
if GetModConfigData("super_attack_speed") then
    TUNING.WILSON_ATTACK_PERIOD = 0.2
    AddStategraphPostInit("wilson", function(sg)
        local _attack_onenter = sg.states["attack"].onenter
        sg.states["attack"].onenter = function(inst)
            _attack_onenter(inst)

            inst.sg:SetTimeout(0.2 + 0.5 * FRAMES)
        end

        table.insert(sg.states["attack"].timeline, 1, TimeEvent(4 * FRAMES, function(inst)
            if not (inst.sg.statemem.isbeaver or
                    inst.sg.statemem.ismoose or
                    -- inst.sg.statemem.iswhip or
                    -- inst.sg.statemem.ispocketwatch or
                    inst.sg.statemem.isbook) and
                inst.sg.statemem.projectiledelay == nil then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end))

        --------------------------------------------------------------------------

        local _slingshot_shoot_onenter = sg.states["slingshot_shoot"].onenter
        sg.states["slingshot_shoot"].onenter = function(inst)
            _slingshot_shoot_onenter(inst)

            inst.sg:SetTimeout(0.2 + 0.5 * FRAMES)
        end
        table.insert(sg.states["slingshot_shoot"].timeline, 1, TimeEvent(2 * FRAMES, function(inst)
            if inst.sg.statemem.chained then
                local buffaction = inst:GetBufferedAction()
                local target = buffaction ~= nil and buffaction.target or nil
                if not (target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target)) then
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle")
                end
            end
        end))
        table.insert(sg.states["slingshot_shoot"].timeline, 2, TimeEvent(3 * FRAMES, function(inst)
            if inst.sg.statemem.chained then
                inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")
            end
        end))
        table.insert(sg.states["slingshot_shoot"].timeline, 3, TimeEvent(4 * FRAMES, function(inst)
            if inst.sg.statemem.chained then
                local buffaction = inst:GetBufferedAction()
                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip ~= nil and equip.components.weapon ~= nil and equip.components.weapon.projectile ~= nil then
                    local target = buffaction ~= nil and buffaction.target or nil
                    if target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target) then
                        inst.sg.statemem.abouttoattack = false
                        inst:PerformBufferedAction()
                        inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
                    else
                        inst:ClearBufferedAction()
                        inst.sg:GoToState("idle")
                    end
                else -- out of ammo
                    inst:ClearBufferedAction()
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_SLINGHSOT_OUT_OF_AMMO"))
                    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
                end
            end
        end))
    end)
    AddStategraphPostInit("wilson_client", function(sg)
        local _attack_onenter = sg.states["attack"].onenter
        sg.states["attack"].onenter = function(inst)
            _attack_onenter(inst)

            inst.sg:SetTimeout(0.2 + 0.5 * FRAMES)
        end

        table.insert(sg.states["attack"].timeline, 1, TimeEvent(4 * FRAMES, function(inst)
            if not (inst.sg.statemem.isbeaver or
                    inst.sg.statemem.ismoose or
                    -- inst.sg.statemem.iswhip or
                    -- inst.sg.statemem.ispocketwatch or
                    inst.sg.statemem.isbook) and
                inst.sg.statemem.projectiledelay == nil then
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end))
    end)
end

-- 两者方案的区别是不是涉及个体与全体的区别？
----------------------------------------------------------------------------------------------------- 老王的方案

local TAG = "homura_snowpea_debuff"
local SNOWPEA = HOMURA_GLOBALS.SNOWPEA
-- [USERDATA]

-- Linking
local links = {} -- key = AnimState, value = Entity
local function GetEntity(anim)
	return anim ~= nil and links[anim]
end

local function NewLink(anim, inst)
	if inst:IsValid() then
		links[anim] = inst
		inst:ListenForEvent("onremove", function() links[anim] = nil end)
	end
end

local old_add = Entity.AddAnimState
Entity.AddAnimState = function(ent, ...)
    local inst = Ents[ent:GetGUID()] -- Get lua instance
    if GetEntity(inst and inst.AnimState) then
    	links[inst.AnimState] = nil
    end
    local anim = old_add(ent, ...)
    NewLink(anim, inst)
    return anim
end

-- Mod interfaces
function AnimState.Homura_GetBaseDeltaTimeMultiplier(anim)
	local inst = GetEntity(anim)
	return inst and inst:HasTag(TAG) and (1 - SNOWPEA.debuffeffect) or 1
end

function AnimState.Homura_RefreshDeltaTimeMultiplier(anim)
	local inst = GetEntity(anim)
	if inst then 
		anim:SetDeltaTimeMultiplier(inst.homura_AnimState_timemult or 1)
	end
end

-- Hooks
local old_set = AnimState.SetDeltaTimeMultiplier
function AnimState.SetDeltaTimeMultiplier(anim, val, ...)
	local inst = GetEntity(anim)
	if inst then
		inst.homura_AnimState_timemult = val
	end
	return old_set(anim, val* anim:Homura_GetBaseDeltaTimeMultiplier(), ...)
end

-- [STATEGRAPH]

local function GetStateTimeMult(self)
	local inst = self.inst
	if inst ~= nil and inst:HasTag("homura_snowpea_debuff") then
		return (1 - SNOWPEA.debuffeffect)
	else
		return 1
	end
end

local function RescaleTimeline(self, val)
	local timeline = self.currentstate and self.currentstate.timeline
	if timeline ~= nil then
		for _,v in pairs(timeline)do
			if val == nil or val == 1 then
				v.time = v.homura_time or v.time
				v.homura_time = nil
			else
				v.homura_time = v.homura_time or v.time
				v.time = v.time/val
			end
		end
	end
end

AddGlobalClassPostConstruct("stategraph", "StateGraphInstance", function(self)
	-- interface for other mods
	self.Homura_GetStateTimeMult = GetStateTimeMult
	self.Homura_RescaleTimeline = RescaleTimeline

	-- Hooks
	local old_SetTimeout = self.SetTimeout
	function self:SetTimeout(time, ...)
		if time then
			return old_SetTimeout(self, time/self:Homura_GetStateTimeMult(), ...)
		else
			return old_SetTimeout(self, time, ...)
		end
	end

	local old_Update = self.Update
	function self:Update(...)
		local mult = self:Homura_GetStateTimeMult()
		if mult ~= 1 then
			self:Homura_RescaleTimeline(mult)
		end
		local time_to_sleep = old_Update(self, ...)
		-- if time_to_sleep ~= nil then
		-- 	time_to_sleep = time_to_sleep/mult
		-- end
		if mult ~= 1 then
			self:Homura_RescaleTimeline(1)
		end
		return time_to_sleep
	end
end)

-- [COMPONENT]

local function GetOffset(inst)
    local rider = inst.replica.rider
    return Vector3(1.0, rider and rider:IsRiding() and 3.75 or 1.75, 0)
end

AddPlayerPostInit(function(inst)
	inst:AddComponent("homura_snowpea_puff")
	inst.components.homura_snowpea_puff:SetOffsetFn(GetOffset)
end)

AddComponentPostInit("highlight", function(self)
	local old_highlight = self.Highlight
	function self:Highlight(r,g,b)
		if r == nil and self.inst:HasTag("homura_snowpea_debuff") then
			return old_highlight(self, 0, 0.16, 0.4)
		end
		return old_highlight(self, r, g, b)
	end
end)
