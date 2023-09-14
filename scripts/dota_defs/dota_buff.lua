local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local function PlaySound(inst, sound, ...)
	if inst.SoundEmitter ~= nil and sound ~= nil then
		inst.SoundEmitter:PlaySound(sound, ...)
		-- SoundEmitter:PlaySound(emitter, event, name, volume, ...)
	end
end
local function AddTag(inst, tag)
	if not inst:HasTag(tag) then inst:AddTag(tag) end
end
local function RemoveTag(inst, tag)
	if inst:HasTag(tag) then inst:RemoveTag(tag) end
end
local function PushEvent_MagicSingalTarget(inst, target, magic)
	TheWorld:PushEvent("dotaevent_magicsingal", { inst = inst, target = target, magic = magic })
end
-- name--buff名
-- duration--buff持续时间
-- prefabs--prefabs列表
-- onattachedfn--添加buff函数
-- onextendedfn--延长buff函数
-- ondetachedfn--解除buff函数

--Buff列表
local buff_defs={}

---------------------------------------------------净化药水 or 小蓝-------------------------------------------------
local function claritytick(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") and 
	 target.components.dotaattributes ~= nil
	then
		target.components.dotaattributes:Mana_DoDelta(TUNING.DOTA.CLARITY_CAST.MANA_REGEN, nil, "clarity")
	else
		inst.components.debuff:Stop()
	end
end

buff_defs.buff_dota_clarity={
	name="buff_dota_clarity",
	duration=TUNING.DOTA.CLARITY_CAST.DURATION,
	onattachedfn=function(inst, target)
		if inst._onblocked == nil then
			inst._onblocked = function(owner, data)
				if data.attacker ~= nil and data.original_damage ~= nil and data.original_damage > 0 then
					inst.components.debuff:Stop()
				end
			end
		end
		inst.claritytask = inst:DoPeriodicTask(TUNING.DOTA.CLARITY_CAST.MANA_REGEN_INTERVAL, claritytick, nil, target)
		inst:ListenForEvent("blocked", inst._onblocked, target)
		inst:ListenForEvent("attacked", inst._onblocked, target)
		PlaySound(target, "mengsk_dota2_sounds/items/clarity_potion", nil, BASE_VOICE_VOLUME)
	end,
	onextendedfn=function(inst, target)
		inst.claritytask:Cancel()
    	inst.claritytask = inst:DoPeriodicTask(TUNING.DOTA.CLARITY_CAST.MANA_REGEN_INTERVAL, claritytick, nil, target)
	end,
	ondetachedfn=function(inst, target)
		if inst._onblocked ~= nil then
			inst:RemoveEventCallback("blocked", inst._onblocked, target)
			inst:RemoveEventCallback("attacked", inst._onblocked, target)
			inst._onblocked = nil
		end
		inst.claritytask:Cancel()
	end,
}
-------------------------------------------------诡计之雾-------------------------------------------------
local SHADOW_COLOUR = { 0.3, 0.3, 0.3, 0.4 }

local function PushColour(inst, source, r, g, b, a)
    if inst.components.colouradder ~= nil then
        inst.components.colouradder:PushColour(source, r, g, b, a)
    else
        inst.AnimState:SetAddColour(r, g, b, a)
    end
end

local function PopColour(inst, source)
    if inst.components.colouradder ~= nil then
        inst.components.colouradder:PopColour(source)
    else
        inst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

buff_defs.buff_dota_smoke={
	name="buff_dota_smoke",
	duration=TUNING.DOTA.SMOKE_OF_DECEIT.DURATION,
	onattachedfn=function(inst, target)
		-- TODO：要不要挂载playerprox来刷新状态呢？
		if inst._onattackother == nil then
			inst._onattackother = function(attacker, data)
				if attacker ~= nil then
					inst.components.debuff:Stop()
				end
			end
			inst:ListenForEvent("onattackother", inst._onattackother, target)
		end
		
		-- target.AnimState:SetMultColour(0.3, 0.3, 0.3, 0.4)	-- 调整rgba至半透明效果	-- TODO:暂定，并入GotoShadow仍在考虑
		PushColour(target, "buff_dota_smoke", SHADOW_COLOUR[1], SHADOW_COLOUR[2], SHADOW_COLOUR[3] ,SHADOW_COLOUR[4])
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_smoke", 1+TUNING.DOTA.SMOKE_OF_DECEIT.SPEEDMULTI)
		end
	end,
	ondetachedfn=function(inst, target)
		if inst._onattackother ~= nil then
			inst:RemoveEventCallback("onattackother", inst._onattackother, target)
			inst._onattackother = nil
		end
		PopColour(target, "buff_dota_smoke")
		-- target.AnimState:SetMultColour(1, 1, 1, 1)	--恢复rbga
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_smoke")
		end
	end,
}
-------------------------------------------------显影之尘 or 粉-------------------------------------------------
buff_defs.buff_dota_dust={
	name="buff_dota_dust",
	duration=TUNING.DOTA.DUST_OF_APPEARANCE.DURATION,
	onattachedfn=function(inst, target)
		AddTag(target, "dota_appeared")
		if target.components.health ~= nil and not target.components.health:IsDead() and not target:HasTag("playerghost") then
			target.components.health:DoDelta(-1, nil, "buff_dota_dust")	-- 减1滴血打断部分动作
		end
	end,
	onextendedfn=function(inst, target)
		if target.components.health ~= nil and not target.components.health:IsDead() and not target:HasTag("playerghost") then
			target.components.health:DoDelta(-1, nil, "buff_dota_dust")
		end
	end,
	ondetachedfn=function(inst, target)
		RemoveTag(target, "dota_appeared")
	end,
}
-------------------------------------------------树之祭祀 or 吃树-------------------------------------------------
local function devoutick(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(TUNING.DOTA.TANGO.DEVOU.HEALTHREGEN, nil, "devou")
	else
		inst.components.debuff:Stop()
	end
end

buff_defs.buff_dota_devou={
	name="buff_dota_devou",
	duration=TUNING.DOTA.TANGO.DEVOU.DURATION,
	onattachedfn=function(inst, target)
		inst.devoutask = inst:DoPeriodicTask(TUNING.DOTA.TANGO.DEVOU.INTERVAL, devoutick, nil, target)
	end,
	onextendedfn=function(inst, target)
		inst.devoutask:Cancel()
    	inst.devoutask = inst:DoPeriodicTask(TUNING.DOTA.TANGO.DEVOU.INTERVAL, devoutick, nil, target)
	end,
	ondetachedfn=function(inst, target)
		inst.devoutask:Cancel()
	end,
}
-------------------------------------------------治疗药膏-------------------------------------------------
local function salvetick(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(TUNING.DOTA.HEALING_SALVE.HEALTHREGEN, nil, "salve")
	else
		inst.components.debuff:Stop()
	end
end

buff_defs.buff_dota_salve={
	name="buff_dota_salve",
	duration=TUNING.DOTA.HEALING_SALVE.DURATION,
	onattachedfn=function(inst, target)
		if inst._onblocked == nil then
			inst._onblocked = function(owner, data)
				if data.attacker ~= nil and data.original_damage ~= nil and data.original_damage > 0 then
					inst.components.debuff:Stop()
				end
			end
		end
		inst.salvetask = inst:DoPeriodicTask(TUNING.DOTA.HEALING_SALVE.INTERVAL, salvetick, nil, target)
		inst:ListenForEvent("blocked", inst._onblocked, target)
		inst:ListenForEvent("attacked", inst._onblocked, target)
	end,
	onextendedfn=function(inst, target)
		inst.salvetask:Cancel()
    	inst.salvetask = inst:DoPeriodicTask(TUNING.DOTA.HEALING_SALVE.INTERVAL, salvetick, nil, target)
	end,
	ondetachedfn=function(inst, target)
		if inst._onblocked ~= nil then
			inst:RemoveEventCallback("blocked", inst._onblocked, target)
			inst:RemoveEventCallback("attacked", inst._onblocked, target)
			inst._onblocked = nil
		end
		inst.salvetask:Cancel()
	end,
}
-------------------------------------------------淬毒之珠-------------------------------------------------
local function venomtick(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(-TUNING.DOTA.ORB_OF_VENOM.DAMAGE, nil, "venom")
	else
		inst.components.debuff:Stop()
	end
end

buff_defs.buff_dota_venom={
	name="buff_dota_venom",
	duration=TUNING.DOTA.ORB_OF_VENOM.DURATION,
	onattachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_venom", 1 - TUNING.DOTA.ORB_OF_VENOM.SPEEDMULTI)
		end
		inst.venomtask = inst:DoPeriodicTask(TUNING.DOTA.ORB_OF_VENOM.INTERVAL, venomtick, nil, target)
	end,
	onextendedfn=function(inst, target)
		inst.venomtask:Cancel()
    	inst.venomtask = inst:DoPeriodicTask(TUNING.DOTA.ORB_OF_VENOM.INTERVAL, venomtick, nil, target)
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_venom")
		end
		inst.venomtask:Cancel()
	end,
}
-------------------------------------------------枯萎之石-------------------------------------------------
buff_defs.buff_dota_blight={
	name="buff_dota_blight",
	duration=TUNING.DOTA.BLIGHT_STONE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.BLIGHT_STONE.LESSERARMOR, "buff_dota_blight")
		end
	end,
	onextendedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", -TUNING.DOTA.BLIGHT_STONE.LESSERARMOR, "buff_dota_blight")
			target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.BLIGHT_STONE.LESSERARMOR, "buff_dota_blight")
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_blight")
		end
	end,
}
-------------------------------------------------暗影护符-------------------------------------------------
local function GoToShadow(inst, target, source)
	if target.components.dotainvisible ~= nil then
		target.components.dotainvisible:GoToShadow(source)
	end
end

local function LeaveShadow(target, source)
	if target.components.dotainvisible ~= nil then
		target.components.dotainvisible:OutOfShadow(source)
	end
end

buff_defs.buff_dota_fading={
	name="buff_dota_fading",
	duration=TUNING.DOTA.SHADOW_AMULET.DURATION,
	onattachedfn=function(inst, target)
		if inst.fadingtimer ~= nil then
			inst.fadingtimer:Cancel()
		end
		inst.fadingtimer = inst:DoTaskInTime(TUNING.DOTA.SHADOW_AMULET.FADING, GoToShadow, target, "buff_dota_fading")

        inst:ListenForEvent("newstate", function(target, data)
			if data and target 
			 and data.statename ~= "funnyidle" 
			 and data.statename ~= "idle" 
			 and data.statename ~= target.customidlestate
			then
				inst.components.debuff:Stop()
			end
        end, target)
	end,
	onextendedfn=function(inst, target)
		LeaveShadow(target, "buff_dota_fading")
		if inst.fadingtimer ~= nil then
			inst.fadingtimer:Cancel()
		end
		inst.fadingtimer = inst:DoTaskInTime(TUNING.DOTA.SHADOW_AMULET.FADING, GoToShadow, target, "buff_dota_fading")
	end,
	ondetachedfn=function(inst, target)
		if inst.fadingtimer ~= nil then
			inst.fadingtimer:Cancel()
			inst.fadingtimer = nil
		end
		LeaveShadow(target, "buff_dota_fading")
	end,
}
--------------------------------------------疯狂面具 or 疯脸------------------------------------------------
buff_defs.buff_dota_berserk={
	name="buff_dota_berserk",
	duration=TUNING.DOTA.MASK_OF_MADNESS.BERSERK.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.MASK_OF_MADNESS.BERSERK.LESSERARMOR, "buff_dota_berserk")
			target.components.dotaattributes:AddExtraSpeed("buff", TUNING.DOTA.MASK_OF_MADNESS.BERSERK.SPEED, "buff_dota_berserk")
			target.components.dotaattributes:AddAttackSpeed("buff", TUNING.DOTA.MASK_OF_MADNESS.BERSERK.ATTACKSPEED, "buff_dota_berserk")
		end
	end,
	-- onextendedfn=function(inst, target)
	-- 	if target.components.dotaattributes ~= nil then
	-- 		target.components.dotaattributes:RemoveExtraArmor("buff", -TUNING.DOTA.MASK_OF_MADNESS.BERSERK.LESSERARMOR, "buff_dota_berserk")
	-- 		target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.MASK_OF_MADNESS.BERSERK.LESSERARMOR, "buff_dota_berserk")
	-- 	end
	-- end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_berserk")
			target.components.dotaattributes:RemoveExtraSpeed("buff", "buff_dota_berserk")
			target.components.dotaattributes:RemoveAttackSpeed("buff", "buff_dota_berserk")
		end
	end,
}
-------------------------------------------------腐蚀之球-------------------------------------------------
local function corrosiontick(inst, target, damage)
-- print("debug buff_dota_corrosion corrosiontick 0 ")
	if target.components.health ~= nil
	 and not target.components.health:IsDead()
	 and not target:HasTag("playerghost") then
		-- print("debug buff_dota_corrosion corrosiontick 1 ")
		target.components.health:DoDelta(-damage, nil, "corrosion")
	else
		inst.components.debuff:Stop()
	end
end

buff_defs.buff_dota_corrosion={
	name="buff_dota_corrosion",
	duration=TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.DURATION,
	onattachedfn=function(inst, target)
		-- print("debug buff_dota_corrosion onattachedfn ")
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.LESSERARMOR, "buff_dota_corrosion")
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_corrosion", 1+TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.SPEEDMULTI)
		end
		local damage = TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.DAMAGE
		inst.corrosiontask = inst:DoPeriodicTask(TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.TICK, corrosiontick, nil, target, damage)
	end,
	
	onextendedfn=function(inst, target)
		-- if target.components.dotaattributes ~= nil then
		-- 	target.components.dotaattributes:RemoveExtraArmor("buff", -TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.LESSERARMOR, "buff_dota_corrosion")
		-- 	target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.LESSERARMOR, "buff_dota_corrosion")
		-- end
		-- print("debug buff_dota_corrosion onextendedfn ")
		-- local damage = TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.DAMAGE
		-- inst.corrosiontask:Cancel()
    	-- inst.corrosiontask = inst:DoPeriodicTask(TUNING.DOTA.ORB_OF_CORROSION.CORRUPTION.TICK, corrosiontick, nil, target, damage)
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_corrosion")
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_corrosion")
		end
		inst.corrosiontask:Cancel()
	end,
}
-------------------------------------------------灵魂之戒-------------------------------------------------
buff_defs.buff_dota_sacrifice={
	name="buff_dota_sacrifice",
	duration=TUNING.DOTA.SOUL_RING.SACRIFICE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.health ~= nil and not target.components.health:IsDead() and not target:HasTag("playerghost") then
			local delta = TUNING.DOTA.SOUL_RING.SACRIFICE.HEALTH
			if delta > target.components.health.currenthealth then 
				target.components.health:SetVal(1, "buff_dota_sacrifice", nil)	-- 不致死
			else
				target.components.health:DoDelta(-delta, nil, "buff_dota_sacrifice")
			end
	   	end
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:Mana_DoDelta(TUNING.DOTA.SOUL_RING.SACRIFICE.MANA)
			target.components.dotaattributes:AddMaxMana("buff", TUNING.DOTA.SOUL_RING.SACRIFICE.MANA, "buff_dota_sacrifice")
		end
	end,
	onextendedfn=function(inst, target)
		if target.components.health ~= nil and not target.components.health:IsDead() and not target:HasTag("playerghost") then
			local delta = TUNING.DOTA.SOUL_RING.SACRIFICE.HEALTH
			if delta > target.components.health.currenthealth then 
				target.components.health:SetVal(1, "buff_dota_sacrifice", nil)	-- 不致死
			else
				target.components.health:DoDelta(-delta, nil, "buff_dota_sacrifice")
			end
	   	end
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:Mana_DoDelta(TUNING.DOTA.SOUL_RING.SACRIFICE.MANA)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveMaxMana("buff", "buff_dota_sacrifice")
			target.components.dotaattributes:Mana_DoDelta(0)	-- 我们需要设置0来处理一下当前魔法值超过最大魔法值的情况
		end
	end,
}
-------------------------------------------------相位鞋-------------------------------------------------
buff_defs.buff_dota_phase={
	name="buff_dota_phase",
	duration=TUNING.DOTA.PHASE_BOOTS.PHASE.DURATION,
	onattachedfn=function(inst, target)
		RemovePhysicsColliders(target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_phase", 1+TUNING.DOTA.PHASE_BOOTS.PHASE.SPEEDMULTI)
		end
	end,
	ondetachedfn=function(inst, target)
		ChangeToCharacterPhysics(target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_phase")
		end
	end,
}
-------------------------------------------------影之灵龛 or 骨灰------------------------------------------
local function releasetick_positive(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(TUNING.DOTA.URN_OF_SHADOWS.RELEASE.HEALTH, nil, "release")
	else
		inst.components.debuff:Stop()
	end
end
local function releasetick_negtive(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(-TUNING.DOTA.URN_OF_SHADOWS.RELEASE.DAMAGE, nil, "release")
	else
		inst.components.debuff:Stop()
	end
end

buff_defs.buff_dota_release_positive={
	name="buff_dota_release_positive",
	duration=TUNING.DOTA.URN_OF_SHADOWS.RELEASE.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		PlaySound(target, "mengsk_dota2_sounds/items/urn_of_shadows", nil, BASE_VOICE_VOLUME)
		inst.bladetask = inst:DoPeriodicTask(TUNING.DOTA.URN_OF_SHADOWS.RELEASE.TICK, releasetick_positive, nil, target)
	end,
	ondetachedfn=function(inst, target)
		inst.bladetask:Cancel()
	end,
}
buff_defs.buff_dota_release_negtive={
	name="buff_dota_release_negtive",
	duration=TUNING.DOTA.URN_OF_SHADOWS.RELEASE.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		PlaySound(target, "mengsk_dota2_sounds/items/urn_of_shadows", nil, BASE_VOICE_VOLUME)
		inst.bladetask = inst:DoPeriodicTask(TUNING.DOTA.URN_OF_SHADOWS.RELEASE.TICK, releasetick_negtive, nil, target)
	end,
	ondetachedfn=function(inst, target)
		inst.bladetask:Cancel()
	end,
}
-------------------------------------------------魂之灵瓮 or 大骨灰----------------------------------------
local function releaseplustick_positive(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(TUNING.DOTA.SPIRIT_VESSEL.RELEASE.HEALTH, nil, "releaseplus")
	else
		inst.components.debuff:Stop()
	end
end
local function releaseplustick_negtive(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(-TUNING.DOTA.SPIRIT_VESSEL.RELEASE.DAMAGE, nil, "releaseplus")
	else
		inst.components.debuff:Stop()
	end
end

buff_defs.buff_dota_releaseplus_positive={
	name="buff_dota_releaseplus_positive",
	duration=TUNING.DOTA.SPIRIT_VESSEL.RELEASE.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		PlaySound(target, "mengsk_dota2_sounds/items/spirit_vessel_ally", nil, BASE_VOICE_VOLUME)
		inst.bladetask = inst:DoPeriodicTask(TUNING.DOTA.SPIRIT_VESSEL.RELEASE.TICK, releaseplustick_positive, nil, target)
	end,
	ondetachedfn=function(inst, target)
		inst.bladetask:Cancel()
	end,
}
buff_defs.buff_dota_releaseplus_negtive={
	name="buff_dota_releaseplus_negtive",
	duration=TUNING.DOTA.SPIRIT_VESSEL.RELEASE.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		PlaySound(target, "mengsk_dota2_sounds/items/spirit_vessel_enemy", nil, BASE_VOICE_VOLUME)
		inst.bladetask = inst:DoPeriodicTask(TUNING.DOTA.SPIRIT_VESSEL.RELEASE.TICK, releaseplustick_negtive, nil, target)
	end,
	ondetachedfn=function(inst, target)
		inst.bladetask:Cancel()
	end,
}
-------------------------------------------------宽容之靴 or 大绿鞋-------------------------------------------------
buff_defs.buff_dota_endurance={
	name="buff_dota_endurance",
	duration=TUNING.DOTA.BOOTS_OF_BEARING.ENDURANCE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_endurance", 1+TUNING.DOTA.BOOTS_OF_BEARING.ENDURANCE.SPEEDMULTI)
		end
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddAttackSpeed("buff", TUNING.DOTA.BOOTS_OF_BEARING.ENDURANCE.ATTACKSPEED, "buff_dota_endurance")
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_endurance")
		end
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveAttackSpeed("buff", "buff_dota_endurance")
		end
	end,
}
-------------------------------------------------韧鼓-------------------------------------------------
buff_defs.buff_dota_endurancedrum={
	name="buff_dota_endurancedrum",
	duration=TUNING.DOTA.DRUM_OF_ENDURANCE.ENDURANCE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_endurancedrum", 1+TUNING.DOTA.DRUM_OF_ENDURANCE.ENDURANCE.SPEEDMULTI)
		end
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddAttackSpeed("buff", TUNING.DOTA.DRUM_OF_ENDURANCE.ENDURANCE.ATTACKSPEED, "buff_dota_endurancedrum")
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_endurancedrum")
		end
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveAttackSpeed("buff", "buff_dota_endurancedrum")
		end
	end,
}
-------------------------------------------------勇气勋章-------------------------------------------------
buff_defs.buff_dota_valor_negtive={
	name="buff_dota_valor_negtive",
	duration=TUNING.DOTA.MEDALLION_OF_COURAGE.VALOR.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.MEDALLION_OF_COURAGE.VALOR.EXTRAARMOR, "buff_dota_valor_negtive")
		end
		PlaySound(target, "mengsk_dota2_sounds/items/medallion_of_courage", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_valor_negtive")
		end
	end,
}
buff_defs.buff_dota_valor_positive={
	name="buff_dota_valor_positive",
	duration=TUNING.DOTA.MEDALLION_OF_COURAGE.VALOR.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddExtraArmor("buff", TUNING.DOTA.MEDALLION_OF_COURAGE.VALOR.EXTRAARMOR, "buff_dota_valor_positive")
		end
		PlaySound(target, "mengsk_dota2_sounds/items/star_emblem_ally", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_valor_positive")
		end
	end,
}
-------------------------------------------------微光披风------------------------------------------------- 
buff_defs.buff_dota_glimmer={
	name="buff_dota_glimmer",
	duration=TUNING.DOTA.GLIMMER_CAPE.GLIMMER.DURATION,
	onattachedfn=function(inst, target)
		if inst.fadetimer ~= nil then
			inst.fadetimer:Cancel()
		end
		inst.fadetimer = inst:DoTaskInTime(TUNING.DOTA.GLIMMER_CAPE.GLIMMER.FADING, GoToShadow, target, "buff_dota_glimmer")

		if inst._onattackother == nil then
			inst._onattackother = function(attacker, data)
				LeaveShadow(attacker, "buff_dota_glimmer")
				if inst.fadetimer ~= nil then
					inst.fadetimer:Cancel()
				end
				inst.fadetimer = inst:DoTaskInTime(TUNING.DOTA.GLIMMER_CAPE.GLIMMER.FADING, GoToShadow, attacker, "buff_dota_glimmer")
			end
		end
		inst:ListenForEvent("onattackother", inst._onattackother, target)
	end,
	onextendedfn=function(inst, target)
		LeaveShadow(target, "buff_dota_glimmer")
		if inst.fadetimer ~= nil then
			inst.fadetimer:Cancel()
		end
		inst.fadetimer = inst:DoTaskInTime(TUNING.DOTA.GLIMMER_CAPE.GLIMMER.FADING, GoToShadow, target, "buff_dota_glimmer")
	end,
	ondetachedfn=function(inst, target)
		if inst.fadetimer ~= nil then
			inst.fadetimer:Cancel()
			inst.fadetimer = nil
		end
		if inst._onattackother ~= nil then
			inst:RemoveEventCallback("onattackother", inst._onattackother, target)
			inst._onattackother = nil
		end
		LeaveShadow(target, "buff_dota_glimmer")
	end,
}
-------------------------------------------------巫师之刃------------------------------------------------- 
local function bladetick(inst, target, intelligence)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(-TUNING.DOTA.WITCH_BLADE.BLADE.DAMAGEMULTI * intelligence, nil, "blade")
	else
		inst.components.debuff:Stop()
	end
end

buff_defs.buff_dota_blade={
	name="buff_dota_blade",
	duration=TUNING.DOTA.WITCH_BLADE.BLADE.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_blade", 1+TUNING.DOTA.WITCH_BLADE.BLADE.SPEEDMULTI)
		end
		local intelligence = 1
		if data and data.intelligence then intelligence = data.intelligence end
		inst.bladetask = inst:DoPeriodicTask(TUNING.DOTA.WITCH_BLADE.BLADE.TICK, bladetick, nil, target, intelligence)
		PlaySound(target, "mengsk_dota2_sounds/items/witch_blade", nil, BASE_VOICE_VOLUME)
	end,
	onextendedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/witch_blade", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_blade")
		end
		inst.bladetask:Cancel()
	end,
}
-------------------------------------------------炎阳纹章 or 大勋章-------------------------------------------------
buff_defs.buff_dota_valor_self={
	name="buff_dota_valor_self",
	duration=TUNING.DOTA.SOLAR_CREST.SHINE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.SOLAR_CREST.EXTRAARMOR, "buff_dota_valor_self")
		end
		PlaySound(target, "mengsk_dota2_sounds/items/star_emblem_enemy", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_valor_self")
		end
	end,
}
buff_defs.buff_dota_shine_negtive={
	name="buff_dota_shine_negtive",
	duration=TUNING.DOTA.SOLAR_CREST.SHINE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.SOLAR_CREST.SHINE.EXTRAARMOR, "buff_dota_shine_negtive")
			target.components.dotaattributes:AddAttackSpeed("buff", -TUNING.DOTA.SOLAR_CREST.SHINE.ATTACKSPEED, "buff_dota_shine_negtive")
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_shine_negtive", 1-TUNING.DOTA.SOLAR_CREST.SHINE.SPEEDMULTI)
		end
		PlaySound(target, "mengsk_dota2_sounds/items/star_emblem_enemy", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_shine_negtive")
			target.components.dotaattributes:RemoveAttackSpeed("buff", "buff_dota_shine_negtive")
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_shine_negtive")
		end
	end,
}
buff_defs.buff_dota_shine_positive={
	name="buff_dota_shine_positive",
	duration=TUNING.DOTA.SOLAR_CREST.SHINE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddExtraArmor("buff", TUNING.DOTA.SOLAR_CREST.SHINE.EXTRAARMOR, "buff_dota_shine_positive")
			target.components.dotaattributes:AddAttackSpeed("buff", TUNING.DOTA.SOLAR_CREST.SHINE.ATTACKSPEED, "buff_dota_shine_positive")
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_shine_positive", 1+TUNING.DOTA.SOLAR_CREST.SHINE.SPEEDMULTI)
		end
		PlaySound(target, "mengsk_dota2_sounds/items/star_emblem_ally", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_shine_positive")
			target.components.dotaattributes:RemoveAttackSpeed("buff", "buff_dota_shine_positive")
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_shine_positive")
		end
	end,
}
-- -------------------------------------------------原力法杖 or 推推棒-------------------------------------------------
-- buff_defs.buff_dota_force={	-- SetMotorVelOverride 在buff很难实现，涉及到update的性能问题，buff不适合处理这种频率
-- 	name="buff_dota_force",
-- 	duration=TUNING.DOTA.FORCE_STAFF.FORCE.DURATION,
-- 	onattachedfn=function(inst, target) end,
-- 	ondetachedfn=function(inst, target) end,
-- }
-------------------------------------------------赤红甲-------------------------------------------------
buff_defs.buff_dota_guard={
	name="buff_dota_guard",
	duration=TUNING.DOTA.CRIMSON_GUARD.GUARD.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotacharacter ~= nil then
			target.components.dotacharacter:AddBlock(1, 75)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotacharacter ~= nil then
			target.components.dotacharacter:RemoveBlock(1, 75)
		end
	end,
}
-------------------------------------------------飓风长戟-------------------------------------------------
-- buff_defs.buff_dota_thrust={
-- 	name="buff_dota_thrust",
-- 	duration=TUNING.DOTA.HURRICANE_PIKE.THRUST.DURATION,
-- 	onattachedfn=function(inst, target)
-- 		local speed = TUNING.DOTA.HURRICANE_PIKE.THRUST.SPEED
-- 		target.Physics:SetMotorVelOverride(-speed, 0, 0)
-- 	end,
-- 	ondetachedfn=function(inst, target)
-- 		target.Physics:ClearMotorVelOverride()
-- 	end,
-- }
-------------------------------------------------清莲宝珠 or 莲花-------------------------------------------------
buff_defs.buff_dota_shell={
	name="buff_dota_shell",
	duration=TUNING.DOTA.LOTUS_ORB.SHELL.DURATION,
	onattachedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/lotus_cast", nil, BASE_VOICE_VOLUME)
		-- 	PlaySound(target, "mengsk_dota2_sounds/items/lotus_activate")
	end,
	ondetachedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/lotus_end", nil, BASE_VOICE_VOLUME)
	end,
}
-------------------------------------------------刃甲-------------------------------------------------
buff_defs.buff_dota_return={
	name="buff_dota_return",
	duration=TUNING.DOTA.BLADE_MAIL.RETURN.DURATION,
	onattachedfn=function(inst, target)
		if inst._onblocked == nil then
			inst._onblocked = function(owner, data)
				if data.attacker ~= nil and data.attacker.components.health ~= nil and not data.attacker.components.health:IsDead() 
				 and data.attacker.components.combat ~= nil and data.original_damage ~= nil and data.original_damage > 0 then
					data.attacker.components.combat:GetAttacked(target, data.original_damage * TUNING.DOTA.BLADE_MAIL.RETURN.RATIO, nil, "return")
					PlaySound(data.attacker, "mengsk_dota2_sounds/items/blade_mail_damage", nil, BASE_VOICE_VOLUME)
				end
			end
		end
		inst:ListenForEvent("blocked", inst._onblocked, target)
		inst:ListenForEvent("attacked", inst._onblocked, target)
		PlaySound(target, "mengsk_dota2_sounds/items/dota_item_blade_mail", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if inst._onblocked ~= nil then
			inst:RemoveEventCallback("blocked", inst._onblocked, target)
			inst:RemoveEventCallback("attacked", inst._onblocked, target)
			inst._onblocked = nil
		end
	end,
}
-------------------------------------------------永恒之盘 or 盘子-------------------------------------------------
buff_defs.buff_dota_breaker={
	name="buff_dota_breaker",
	duration=TUNING.DOTA.AEON_DISK.BREAKER.DURATION,	-- TODO：待制作
	onattachedfn=function(inst, target)
		local shield = SpawnPrefab("dota_fx_disk")
		inst.shield = shield
		if target.components.health ~= nil and not target.components.health:IsDead() then
			target.components.health:Dota_SetProtect(true)
		end
		PlaySound(target, "mengsk_dota2_sounds/items/combo_breaker", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.health ~= nil then
			target.components.health:Dota_SetProtect(false)
		end
		inst.shield.kill_fx()
	end,
}
-------------------------------------------------黯灭-------------------------------------------------
buff_defs.buff_dota_corruption={
	name="buff_dota_corruption",
	duration=TUNING.DOTA.DESOLATOR.CORRUPTION.DURATION,
	onattachedfn=function(inst, target)
		if target and target:IsValid() and not target.inlimbo 
		 and target.components.combat
		 and target.components.health and not target.components.health:IsDead() 
		 and target.components.dotaattributes then
			target.components.dotaattributes:AddExtraArmor("buff", -TUNING.DOTA.DESOLATOR.CORRUPTION.EXTRAARMOR, "buff_dota_corruption")
		end
		-- if inst.decaytimer ~= nil then
			-- inst.decaytimer:Cancel() 
		-- end
		-- inst.decaytimer = inst:DoTaskInTime(TUNING.DOTA.DESOLATOR.CORRUPTION.DURATION, function() inst.components.debuff:Stop() end)
	end,
	-- onextendedfn=function(inst, target)
		-- if inst.decaytimer ~= nil then 
			-- inst.decaytimer:Cancel() 
		-- end
		-- inst.decaytimer = inst:DoTaskInTime(TUNING.DOTA.DESOLATOR.CORRUPTION.DURATION, function() inst.components.debuff:Stop() end)
	-- end,
	ondetachedfn=function(inst, target)
		-- if inst.decaytimer ~= nil then
			-- inst.decaytimer:Cancel()
			-- inst.decaytimer = nil
		-- end
		if target ~= nil and target:IsValid() and target.components.combat ~= nil and target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveExtraArmor("buff", "buff_dota_corruption")
		end
	end,
}
-------------------------------------------------白银之锋 or 大隐刀-------------------------------------------------
buff_defs.buff_dota_walkplus={
	name="buff_dota_walkplus",
	duration=TUNING.DOTA.SILVER_EDGE.WALK.DURATION,
	onattachedfn=function(inst, target)
		GoToShadow(inst, target, "buff_dota_walkplus")
		if inst._onattackother == nil then
			inst._onattackother = function(attacker, data)
				if data and data.target ~= nil and data.target.components.combat ~= nil
				 and data.target.components.health ~= nil and not data.target.components.health:IsDead() then
					data.target.components.combat:GetAttacked(target, TUNING.DOTA.SILVER_EDGE.WALK.DAMAGE, nil, "dota_accuracy")
				end
				PlaySound(attacker, "mengsk_dota2_sounds/items/silver_edge_target", nil, BASE_VOICE_VOLUME)
				inst.components.debuff:Stop()
			end
			inst:ListenForEvent("onattackother", inst._onattackother, target)
		end
	end,
	ondetachedfn=function(inst, target)
		LeaveShadow(target, "buff_dota_walkplus")
		if inst._onattackother ~= nil then
			inst:RemoveEventCallback("onattackother", inst._onattackother, target)
			inst._onattackother = nil
		end
	end,
}
-------------------------------------------------隐刀-------------------------------------------------
buff_defs.buff_dota_walk={
	name="buff_dota_walk",
	duration=TUNING.DOTA.SILVER_EDGE.WALK.DURATION,
	onattachedfn=function(inst, target)
		GoToShadow(inst, target, "buff_dota_walk")
		if inst._onattackother == nil then
			inst._onattackother = function(attacker, data)
				if data and data.target ~= nil and data.target.components.combat ~= nil
				 and data.target.components.health ~= nil and not data.target.components.health:IsDead() then
					data.target.components.combat:GetAttacked(target, TUNING.DOTA.INVIS_SWORD.WALK.DAMAGE, nil, "dota_accuracy")
				end
				inst.components.debuff:Stop()
			end
			inst:ListenForEvent("onattackother", inst._onattackother, target)
		end
	end,
	ondetachedfn=function(inst, target)
		LeaveShadow(target, "buff_dota_walk")
		if inst._onattackother ~= nil then
			inst:RemoveEventCallback("onattackother", inst._onattackother, target)
			inst._onattackother = nil
		end
	end,
}
-------------------------------------------------蝴蝶-------------------------------------------------
buff_defs.buff_dota_flutter={
	name="buff_dota_flutter",
	duration=TUNING.DOTA.SILVER_EDGE.WALK.DURATION,
	onattachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_flutter", (1 + TUNING.DOTA.BUTTERFLY.FLUTTER.SPEEDMULTI))
		end
		PlaySound(target, "mengsk_dota2_sounds/items/butterfly", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_flutter")
		end
	end,
}
-------------------------------------------------莫尔迪基安的臂章-------------------------------------------------
-- TODO：待制作，想复刻是不是要用到update函数？
-------------------------------------------------迅疾闪光 or 敏捷跳-------------------------------------------------
buff_defs.buff_dota_swift={
	name="buff_dota_swift",
	duration=TUNING.DOTA.SWIFT_BLINK.SWIFT.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotacharacter ~= nil then
			target.components.dotacharacter:AddAgility(TUNING.DOTA.SWIFT_BLINK.SWIFT.AGILITY)
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_swift", 1+TUNING.DOTA.SWIFT_BLINK.SWIFT.SPEEDMULTI)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotacharacter ~= nil then
			target.components.dotacharacter:RemoveAgility(TUNING.DOTA.SWIFT_BLINK.SWIFT.AGILITY)
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_swift")
		end
	end,
}
-------------------------------------------------秘奥闪光 or 智力跳-------------------------------------------------
buff_defs.buff_dota_arcane={
	name="buff_dota_arcane",
	duration=TUNING.DOTA.ARCANE_BLINK.ARCANE.DURATION,
	onattachedfn=function(inst, target)
		AddTag(target, "buff_dota_arcane")
		if target.AnimState then
			target.AnimState:Dota_UpdateDeltaTimeMultiplier(TUNING.DOTA.ARCANE_BLINK.ARCANE.REDUCTION)
		end
	end,
	ondetachedfn=function(inst, target)
		RemoveTag(target, "buff_dota_arcane")
		if target.AnimState then
			target.AnimState:Dota_UpdateDeltaTimeMultiplier(nil)
		end
	end,
}
-------------------------------------------------盛势闪光 or 力量跳-------------------------------------------------
buff_defs.buff_dota_overwhelming={
	name="buff_dota_overwhelming",
	duration=TUNING.DOTA.OVERWHELMING_BLINK.OVERWHELMING.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddAttackSpeed("buff", TUNING.DOTA.OVERWHELMING_BLINK.OVERWHELMING.ATTACKSPEED, "buff_dota_overwhelming")
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_swift", 1+TUNING.DOTA.OVERWHELMING_BLINK.OVERWHELMING.SPEEDMULTI)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveAttackSpeed("buff", "buff_dota_overwhelming")
		end
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_swift")
		end
	end,
}
-------------------------------------------------天堂之戟-------------------------------------------------
buff_defs.buff_dota_disarm={
	name="buff_dota_disarm",
	duration=TUNING.DOTA.HEAVENS_HALBERD.DISARM.DURATION,
	onattachedfn=function(inst, target)
		if target.components.combat ~= nil then
			target.components.combat:BlankOutAttacks(TUNING.DOTA.HEAVENS_HALBERD.DISARM.DURATION)
		end
	end,
	onextendedfn=function(inst, target)
		if target.components.combat ~= nil then
			target.components.combat:BlankOutAttacks(TUNING.DOTA.HEAVENS_HALBERD.DISARM.DURATION)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.combat and target.components.combat.blanktask ~= nil then
			target.components.combat.blanktask:Cancel()
			target.components.combat.blanktask = nil
			target.components.combat.canattack = true
		end
	end,
}
-------------------------------------------------撒旦之邪力 or 大吸-------------------------------------------------
buff_defs.buff_dota_rage={
	name="buff_dota_rage",
	duration=TUNING.DOTA.SATANIC.RAGE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotacharacter ~= nil then
			target.components.dotacharacter:AddLifesteal(TUNING.DOTA.SATANIC.RAGE.LIFESTEAL)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotacharacter ~= nil then
			target.components.dotacharacter:AddLifesteal(TUNING.DOTA.SATANIC.RAGE.LIFESTEAL)
		end
	end,
}
-------------------------------------------------净魂之刃 or 散失-------------------------------------------------
buff_defs.buff_dota_inhibit={
	name="buff_dota_inhibit",
	duration=TUNING.DOTA.DIFFUSAL_BLADE.INHIBIT.DURATION,
	onattachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_inhibit", 1+TUNING.DOTA.DIFFUSAL_BLADE.INHIBIT.SPEEDMULTI)
		end
		PlaySound(target, "mengsk_dota2_sounds/items/item_diffusalblade", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_inhibit")
		end
	end,
}
-------------------------------------------------雷神之锤 or 大雷锤 or 大电锤-------------------------------------------------
local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "player"}
local STATIC_CHANCE = TUNING.DOTA.MJOLLNIR.STATIC.CHANCE
local STATIC_RANGE = TUNING.DOTA.MJOLLNIR.STATIC.RANGE
local STATIC_NUMBER = TUNING.DOTA.MJOLLNIR.STATIC.NUMBER
local STATIC_DAMAGE = TUNING.DOTA.MJOLLNIR.STATIC.DAMAGE
local STATIC_INTERVAL = TUNING.DOTA.MJOLLNIR.STATIC.INTERVAL
buff_defs.buff_dota_lighting={
	name="buff_dota_lighting",
	duration=TUNING.DOTA.MJOLLNIR.STATIC.DURATION,
	onattachedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/item_mjoll_on", nil, BASE_VOICE_VOLUME)
		if inst._onblocked == nil then
			inst._onblocked = function(owner, data)
				if data and inst.readylight
				 and data.attacker ~= nil and data.original_damage ~= nil and data.original_damage > 0
				 and math.random(0,1) <= STATIC_CHANCE then
					inst.readylight = false
					inst:DoTaskInTime(STATIC_INTERVAL, function() inst.readylight = true end)

					if owner.SoundEmitter ~= nil then
						owner.SoundEmitter:PlaySound("mengsk_dota2_sounds/items/item_mael_lightning_chain", nil, BASE_VOICE_VOLUME)
					end

					local count = 0
					local x, y, z = target.Transform:GetWorldPosition()
					local ents = TheSim:FindEntities(x, y, z, STATIC_RANGE, { "_combat" }, exclude_tags)
					for _, ent in ipairs(ents) do	 -- 遍历找到的实体
						if ent ~= owner
						 and (owner.components.combat ~= nil and owner.components.combat:IsValidTarget(ent))
						 and (owner.components.leader ~= nil and not owner.components.leader:IsFollower(ent))
						 then
							local proj = SpawnPrefab("dota_projectile_static")
							proj.Transform:SetPosition(owner.Transform:GetWorldPosition())
							proj.components.projectile:Throw(owner, ent, owner)

							count = count + 1
							if (count <= STATIC_NUMBER) then
								break
							end

						end
					end
				end
			end
		end
		inst:ListenForEvent("blocked", inst._onblocked, target)
		inst:ListenForEvent("attacked", inst._onblocked, target)
	end,
	onextendedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/item_mjoll_loop", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/item_mjoll_off", nil, BASE_VOICE_VOLUME)
		if inst._onblocked ~= nil then
			inst:RemoveEventCallback("blocked", inst._onblocked, target)
			inst:RemoveEventCallback("attacked", inst._onblocked, target)
			inst._onblocked = nil
		end
	end,
}
--------------------------------------------幽魂权杖 or 绿杖-----------------------------------------------
buff_defs.buff_dota_ghostform={
	name="buff_dota_ghostform",
	duration=TUNING.DOTA.GHOST_SCEPTER.GHOSTFORM.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaethereal ~= nil then
			target.components.dotaethereal:GoToGhostForm("buff_dota_ghostform")
		end
	end,
	-- onextendedfn=function(inst, target)
	-- end,
	ondetachedfn=function(inst, target)
		if target.components.dotaethereal ~= nil then
			target.components.dotaethereal:OutOfGhostForm("buff_dota_ghostform")
		end
	end,
}
-------------------------------------------------阿托斯之棍-------------------------------------------------
buff_defs.buff_dota_cripple={
	name="buff_dota_cripple",
	duration=TUNING.DOTA.ROD_OF_ATOS.CRIPPLE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:Dota_CanMove(false)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			if target.components.locomotor:HasDestination() then
				target.components.locomotor:FindPath()
			end
			target.components.locomotor:Dota_CanMove(true)
		end
	end,
}
-------------------------------------------------缚灵索-------------------------------------------------
buff_defs.buff_dota_eternal={
	name="buff_dota_eternal",
	duration=TUNING.DOTA.GLEIPNIR.ETERNAL.DURATION,
	onattachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:Dota_CanMove(false)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			if target.components.locomotor:HasDestination() then
				target.components.locomotor:FindPath()
			end
			target.components.locomotor:Dota_CanMove(true)
		end
	end,
}
-------------------------------------------------斯嘉蒂之眼  or 冰眼-------------------------------------------------
buff_defs.buff_dota_skadi={
	name="buff_dota_skadi",
	duration=TUNING.DOTA.EYE_OF_SKADI.COLD.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:AddDecrHealthRegenAMP("buff", TUNING.DOTA.EYE_OF_SKADI.COLD.DECREASE, "buff_dota_skadi")
			target.components.dotaattributes:AddAttackSpeed("buff", -TUNING.DOTA.EYE_OF_SKADI.COLD.ATTACKSPEED, "buff_dota_skadi")
		end
		if target.components.locomotor then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_skadi", 1+TUNING.DOTA.EYE_OF_SKADI.COLD.SPEEDMULTI)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:RemoveDecrHealthRegenAMP("buff", "buff_dota_skadi")
			target.components.dotaattributes:RemoveAttackSpeed("buff", "buff_dota_skadi")
		end
		if target.components.locomotor then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_skadi")
		end
	end,
}
-------------------------------------------------黑黄杖 or BKB-------------------------------------------------
buff_defs.buff_dota_avatar={
	name="buff_dota_avatar",
	duration=TUNING.DOTA.BLACK_KING_BAR.AVATAR.DURATION,
	onattachedfn=function(inst, target)
		AddTag(target, "dota_avatar")
		PushColour(target, "dota_avatar", 0.95, 0.76, 0.1, 1)
		if target.components.combat ~= nil then
			target.components.combat:Dota_SetAvatar(true)
		end
		if target.components.dotaattributes then
			target.components.dotaattributes.statusresistance:SetModifier("buff", 1.0, "buff_dota_avatar")
		end
		PlaySound(target, "mengsk_dota2_sounds/items/black_king_bar", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		PopColour(target, "dota_avatar")
		RemoveTag(target, "dota_avatar")
		if target.components.combat ~= nil then
			target.components.combat:Dota_SetAvatar(false)
		end
		if target.components.dotaattributes then
			target.components.dotaattributes.statusresistance:RemoveModifier("buff", "buff_dota_avatar")
		end
	end,
}
-------------------------------------------------虚灵之刃-------------------------------------------------
buff_defs.buff_dota_ethereal={
	name="buff_dota_ethereal",
	duration=TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.DURATION,
	onattachedfn=function(inst, target)
		if not target:HasTag("player") and target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_ethereal", 1-TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.SPEEDMULTI)
		end
		if target.components.dotaethereal ~= nil then
			target.components.dotaethereal:GoToGhostForm("buff_dota_ethereal")
		end
	end,
	-- onextendedfn=function(inst, target)
	-- end,
	ondetachedfn=function(inst, target)
		if not target:HasTag("player") and target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_ethereal")
		end
		if target.components.dotaethereal ~= nil then
			target.components.dotaethereal:OutOfGhostForm("buff_dota_ethereal")
		end
	end,
}
-------------------------------------------------辉耀-------------------------------------------------
buff_defs.buff_dota_burn={
	name="buff_dota_burn",
	duration=TUNING.DOTA.RADIANCE.BURN.TICK * 2,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes.misschance:SetModifier("buff", TUNING.DOTA.RADIANCE.BURN.MISSCHANCE, "buff_dota_burn")
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes.misschance:RemoveModifier("buff", "buff_dota_burn")
		end
	end,
}
------------------------------------------eul的神圣法杖 or 吹风----------------------------------------------
buff_defs.buff_dota_cyclone={
	name="buff_dota_cyclone",
	duration=TUNING.DOTA.EULS.CYCLONE.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		inst.attacker = data and data.attacker
		if not target.components.dotafly then target:AddComponent("dotafly") end
		if target.components.dotafly ~= nil then
			target.components.dotafly:Fly()
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotafly ~= nil then
			target.components.dotafly:Land()
		end
		if not target:HasTag("player") and target.components.combat ~= nil then
			target.components.combat:GetAttacked(inst.attacker or inst, TUNING.DOTA.EULS.CYCLONE.DAMAGE, inst, "dotamagic")
			PushEvent_MagicSingalTarget(inst.attacker or inst, target, "dota_cyclone")
		end
	end,
}
-------------------------------------------------风之杖 or 大吹风-------------------------------------------------
buff_defs.buff_dota_cycloneplus={
	name="buff_dota_cycloneplus",
	duration=TUNING.DOTA.EULS.CYCLONE.DURATION,
	onattachedfn=function(inst, target)
		if not target.components.dotafly then target:AddComponent("dotafly") end
		if target.components.dotafly ~= nil then
			target.components.dotafly:Fly(true)
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotafly ~= nil then
			target.components.dotafly:Land(true)
		end
		if not target:HasTag("player") and target.components.combat ~= nil then
			target.components.combat:GetAttacked(inst.attacker or inst, TUNING.DOTA.EULS.CYCLONE.DAMAGE, inst, "dotamagic")
			PushEvent_MagicSingalTarget(inst.attacker or inst, target, "dota_cycloneplus")
		end
	end,
}
-------------------------------------------------紫怨-------------------------------------------------
buff_defs.buff_dota_burnx={
	name="buff_dota_burnx",
	duration=TUNING.DOTA.ORCHID_MALEVOLENCE.BURNX.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		inst.damage = 0
		inst.attacker = data and data.attacker
		if inst._onblocked == nil then
			inst._onblocked = function(owner, data_)
				if data_.attacker ~= nil and data_.original_damage ~= nil and data_.original_damage > 0 then
					inst.damage = inst.damage + data_.original_damage
				end
			end
		end
		inst:ListenForEvent("blocked", inst._onblocked, target)
		inst:ListenForEvent("attacked", inst._onblocked, target)
		PlaySound(target, "mengsk_dota2_sounds/items/orchid", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if inst._onblocked ~= nil then
			inst:RemoveEventCallback("blocked", inst._onblocked, target)
			inst:RemoveEventCallback("attacked", inst._onblocked, target)
			inst._onblocked = nil
		end
		if target.components.combat ~= nil then
			target.components.combat:GetAttacked(inst.attacker or inst, inst.damage * TUNING.DOTA.ORCHID_MALEVOLENCE.BURNX.DAMAGERATIO, inst, "electric")
		end
	end,
}
-------------------------------------------------血棘 or 大紫怨-------------------------------------------------
buff_defs.buff_dota_rend={
	name="buff_dota_rend",
	duration=TUNING.DOTA.BLOODTHORN.REND.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		inst.damage = 0
		inst.attacker = data and data.attacker
		if inst._onblocked == nil then
			inst._onblocked = function(owner, data_)
				if data_.attacker ~= nil and data_.original_damage ~= nil and data_.original_damage > 0 then
					inst.damage = inst.damage + data_.original_damage
				end
			end
		end
		inst:ListenForEvent("blocked", inst._onblocked, target)
		inst:ListenForEvent("attacked", inst._onblocked, target)
		PlaySound(target, "mengsk_dota2_sounds/items/bloodthorn", nil, BASE_VOICE_VOLUME)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes.accuracy:SetModifier("buff", TUNING.DOTA.BLOODTHORN.REND.ACCURACY, "buff_dota_rend")
		end
	end,
	ondetachedfn=function(inst, target)
		if inst._onblocked ~= nil then
			inst:RemoveEventCallback("blocked", inst._onblocked, target)
			inst:RemoveEventCallback("attacked", inst._onblocked, target)
			inst._onblocked = nil
		end
		if target.components.combat ~= nil then
			target.components.combat:GetAttacked(inst.attacker or inst, inst.damage * TUNING.DOTA.BLOODTHORN.REND.DAMAGERATIO, inst, "electric")
		end
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes.misschance:RemoveModifier("buff", "buff_dota_rend")
		end
	end,
}
-------------------------------------------------回音战刃 or 连击刀-------------------------------------------------
buff_defs.buff_dota_echo={
	name="buff_dota_echo",
	duration=TUNING.DOTA.ECHO_SABRE.ECHO.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_echo", (1+TUNING.DOTA.ECHO_SABRE.ECHO.SPEEDMULTI))
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_echo")
		end
	end,
}

local ECHO_CD = math.max(TUNING.DOTA.ECHO_SABRE.ECHO.CD - 1, 1)
buff_defs.buff_dota_echoattack={
	name="buff_dota_echoattack",
	duration=ECHO_CD,
	onattachedfn=function(inst, target)
		AddTag(target, "dota_echo")
		if inst._onhitother == nil then
			inst._onhitother = function(owner, data)
				inst.components.debuff:Stop()
				if data and data.target and data.target.components.debuffable then
					data.target.components.debuffable:AddDebuff("buff_dota_echo", "buff_dota_echo")
				end
			end
		end
		inst:ListenForEvent("onhitother", inst._onhitother, target)
	end,
	ondetachedfn=function(inst, target)
		RemoveTag(target, "dota_echo")
		if inst._onhitother ~= nil then
			inst:RemoveEventCallback("onhitother", inst._onhitother, target)
			inst._onhitother = nil
		end
	end,
}
-------------------------------------------------血精石-------------------------------------------------
buff_defs.buff_dota_bloodpact={
	name="buff_dota_bloodpact",
	duration=TUNING.DOTA.BLOODSTONE.BLOODPACT.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes then
			target.components.dotaattributes.spelllifesteal:SetModifier("buff", TUNING.DOTA.BLOODSTONE.BLOODPACT.SPELLLIFESTEAL, "buff_dota_bloodpact")
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes then
			target.components.dotaattributes.spelllifesteal:RemoveModifier("buff", "buff_dota_bloodpact")
		end
	end,
}

buff_defs.buff_dota_bloodpactcd={
	name="buff_dota_bloodpactcd",
	duration=math.max(1, TUNING.DOTA.BLOODSTONE.BLOODPACT.DURATION - 1),
	onattachedfn=function(inst, target)
		AddTag(target, "bloodpactcd")
	end,
	ondetachedfn=function(inst, target)
		RemoveTag(target, "bloodpactcd")
	end,
}
-------------------------------------------------英灵胸针-------------------------------------------------
-- Bug：反复进入服务器时，由于debuffable里的save-load写法，会让hitcount一直重置，bug影响不大，暂不修复
buff_defs.buff_dota_province={
	name="buff_dota_province",
	duration=TUNING.DOTA.REVENANTS_BROOCH.PROVINCE.DURATION,
	onattachedfn=function(inst, target)
		inst.hitcount = 0
		if inst._onattackother == nil then
			inst._onattackother = function(owner, data)
				if data and data.target then
					inst.hitcount = inst.hitcount + 1
				end
				if inst.hitcount >= TUNING.DOTA.REVENANTS_BROOCH.PROVINCE.NUM then
					inst.components.debuff:Stop()
				end
			end
		end
		inst:ListenForEvent("onattackother", inst._onattackother, target)

		if target.components.dotacharacter then
            target.components.dotacharacter:AddTrueStrike(1, 0, "province")
        end

		if target.components.combat then
			target.components.combat.dota_provincefn = true
		end
	end,
	onextendedfn=function(inst, target)
		inst.hitcount = 0
	end,
	ondetachedfn=function(inst, target)
		if inst._onattackother ~= nil then
			inst:RemoveEventCallback("onattackother", inst._onattackother, target)
			inst._onattackother = nil
		end

		if target.components.dotacharacter then
			target.components.dotacharacter:RemoveTrueStrike(1, 0, "province")
		end

		if target.components.combat then
			target.components.combat.dota_provincefn = nil
		end
	end,
}
-------------------------------------------------否决坠饰-------------------------------------------------
buff_defs.buff_dota_nullifier={
	name="buff_dota_nullifier",
	duration=TUNING.DOTA.NULLIFIER.NULLIFY.DURATION,
	onattachedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/nullifier_target", nil, BASE_VOICE_VOLUME)
		if inst._onattacked == nil then
			inst._onattacked = function(owner, data)
				if data and data.attacker -- and data.original_damage > 0	-- 部分武器的 original_damage 为nil
				 and data.stimuli ~= "dotamagic" and data.stimuli ~= "electric"
				 and owner.components.debuffable then
					owner.components.debuffable:AddDebuff("buff_dota_nullifier_speed", "buff_dota_nullifier_speed")
				end
			end
		end
		inst:ListenForEvent("attacked", inst._onattacked, target)
	end,
	ondetachedfn=function(inst, target)
		if inst._onattacked ~= nil then
			inst:RemoveEventCallback("attacked", inst._onattacked, target)
			inst._onattacked = nil
		end
	end,
}

buff_defs.buff_dota_nullifier_speed={
	name="buff_dota_nullifier_speed",
	duration=TUNING.DOTA.NULLIFIER.NULLIFY.SPEEDDURATION,
	onattachedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/nullifier_slow", nil, BASE_VOICE_VOLUME)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_nullifier_speed", 1+TUNING.DOTA.NULLIFIER.NULLIFY.SPEEDMULTI)
		end
	end,
	onextendedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/items/nullifier_slow", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_nullifier_speed")
		end
	end,
}
-------------------------------------------------邪恶镰刀 or 羊刀-------------------------------------------------
buff_defs.dota_hex={
	name="dota_hex",
	duration=TUNING.DOTA.SCYTHE_OF_VYSE.HEX.DURATION,
	onattachedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/plus/scythe_of_vyse", nil, BASE_VOICE_VOLUME)
		if target.brain ~= nil then
			target.brain:Stop()
		end
	end,
	onextendedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/plus/scythe_of_vyse", nil, BASE_VOICE_VOLUME)
	end,
	ondetachedfn=function(inst, target)
		PlaySound(target, "mengsk_dota2_sounds/plus/scythe_of_vyse", nil, BASE_VOICE_VOLUME)
		if target.brain ~= nil then
			target.brain:Start()
		end
	end,
}
-------------------------------------------------纷争面纱-------------------------------------------------
buff_defs.buff_dota_weakness={
	name="buff_dota_weakness",
	duration=TUNING.DOTA.VEIL_OF_DISCORD.WEAKNESS.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes.spellweak:SetModifier("buff", TUNING.DOTA.VEIL_OF_DISCORD.WEAKNESS.SPELLWEAK, "buff_dota_weakness")
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes.spellweak:RemoveModifier("buff", "buff_dota_weakness")
		end
	end,
}

---------------------------------------------------魔瓶 or 瓶子---------------------------------------------------
local regenerate_ration = TUNING.DOTA.BOTTLE.REGENERATE.DURATION / TUNING.DOTA.BOTTLE.REGENERATE.INTERVAL
local regenerate_health = TUNING.DOTA.BOTTLE.REGENERATE.HEALTH / regenerate_ration
local regenerate_mana = TUNING.DOTA.BOTTLE.REGENERATE.MANA / regenerate_ration
local function regeneratetick(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(regenerate_health, nil, "regenerate")
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:Mana_DoDelta(regenerate_mana, nil, "regenerate")
		end
	end
end

buff_defs.buff_dota_regenerate={
	name="buff_dota_regenerate",
	duration=TUNING.DOTA.BOTTLE.REGENERATE.DURATION,
	onattachedfn=function(inst, target)
		inst.regeneratetask = inst:DoPeriodicTask(TUNING.DOTA.BOTTLE.REGENERATE.INTERVAL, regeneratetick, nil, target)
	end,
	onextendedfn=function(inst, target)
		inst.regeneratetask:Cancel()
    	inst.regeneratetask = inst:DoPeriodicTask(TUNING.DOTA.BOTTLE.REGENERATE.INTERVAL, regeneratetick, nil, target)
	end,
	ondetachedfn=function(inst, target)
		inst.regeneratetask:Cancel()
	end,
}

buff_defs.buff_dota_rune_arcane={
	name="buff_dota_rune_arcane",
	duration=TUNING.DOTA.BOTTLE.RUNE.ARCANE.DURATION,
	onattachedfn=function(inst, target)
	end,
	ondetachedfn=function(inst, target)
	end,
}

-- 取自pigking，让物品抛出
local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end
buff_defs.buff_dota_rune_bounty={
	name="buff_dota_rune_bounty",
	duration=0.1,
	onattachedfn=function(inst, target)
		local x, y, z = target.Transform:GetWorldPosition()
		y = 2.5
		local down = TheCamera:GetDownVec()
		local angle = math.atan2(down.z, down.x) / DEGREES


		-- 先生成余数的黄金
		local nug = SpawnPrefab("goldnugget")
		local gold = TUNING.DOTA.BOTTLE.RUNE.BOUNTY.GOLD
		local maxsize = nug.components.stackable.maxsize
		local a = math.floor(gold/maxsize)	-- 整数部分
		local b = math.floor(gold%maxsize)	-- 余数部分
		b = math.max(b, 1)	-- 确保有一个保底黄金
		nug.Transform:SetPosition(x, y, z)
		nug.components.stackable:SetStackSize(b)
		launchitem(nug, angle)

		-- 再生成整数的黄金
		if a >= 1 then
			for i = 1, a do
				local nugs = SpawnPrefab("goldnugget")
				nugs.Transform:SetPosition(x, y, z)
				nugs.components.stackable:SetStackSize(maxsize)
				launchitem(nug, angle)
			end
		end
	end,
}

buff_defs.buff_dota_rune_double={
	name="buff_dota_rune_double",
	duration=TUNING.DOTA.BOTTLE.RUNE.DOUBLE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotacharacter then
			local damage = target.components.dotacharacter.extradamage
			target.components.dotaattributes.extradamage:SetModifier("buff", damage, "buff_dota_rune_double")
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotacharacter then
			target.components.dotaattributes.extradamage:RemoveModifier("buff", "buff_dota_rune_double")
		end
	end,
}

buff_defs.buff_dota_rune_haste={
	name="buff_dota_rune_haste",
	duration=TUNING.DOTA.BOTTLE.RUNE.HASTE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.dotacharacter then
			target.components.dotacharacter:AddExtraSpeed("buff", TUNING.DOTA.BOTTLE.RUNE.HASTE.EXTRASPEED, "haste")
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.dotacharacter then
			target.components.dotacharacter:RemoveExtraSpeed("buff", "haste")
		end
	end,
}

buff_defs.buff_dota_rune_illusion={
	name="buff_dota_rune_illusion",
	duration=TUNING.DOTA.BOTTLE.RUNE.ILLUSION.DURATION,	-- 0
	onattachedfn=function(inst, target)

	end,
	ondetachedfn=function(inst, target)

	end,
}

buff_defs.buff_dota_rune_invisbility={
	name="buff_dota_rune_invisbility",
	duration=TUNING.DOTA.BOTTLE.RUNE.INVISBILITY.DURATION,
	onattachedfn=function(inst, target)
		if inst.fadingtimer ~= nil then
			inst.fadingtimer:Cancel()
		end
		inst.fadingtimer = inst:DoTaskInTime(TUNING.DOTA.BOTTLE.RUNE.INVISBILITY.FADING, GoToShadow, target, "buff_dota_rune_invisbility")
	end,
	onextendedfn=function(inst, target)
		LeaveShadow(target, "buff_dota_rune_invisbility")
		if inst.fadingtimer ~= nil then
			inst.fadingtimer:Cancel()
		end
		inst.fadingtimer = inst:DoTaskInTime(TUNING.DOTA.BOTTLE.RUNE.INVISBILITY.FADING, GoToShadow, target, "buff_dota_rune_invisbility")
	end,
	ondetachedfn=function(inst, target)
		if inst.fadingtimer ~= nil then
			inst.fadingtimer:Cancel()
			inst.fadingtimer = nil
		end
		LeaveShadow(target, "buff_dota_rune_invisbility")
	end,
}

local function runeregentick(inst, target)
	if target.components.health ~= nil and
	 not target.components.health:IsDead() and
	 not target:HasTag("playerghost") then
		target.components.health:DoDelta(inst.health, nil, "rune_regen")
		if target.components.dotaattributes ~= nil then
			target.components.dotaattributes:Mana_DoDelta(inst.mana, nil, "rune_regen")
		end
	end
end

buff_defs.buff_dota_rune_regeneration={
	name="buff_dota_rune_regeneration",
	duration=TUNING.DOTA.BOTTLE.RUNE.REGENERATION.DURATION,
	onattachedfn=function(inst, target)
		inst.health = target.compoents.health and (target.components.health.maxhealth * TUNING.DOTA.BOTTLE.RUNE.REGENERATION.MAXRATIO)
		inst.mana = target.compoents.dotaattributes and (target.components.dotaattributes.maxmana * TUNING.DOTA.BOTTLE.RUNE.REGENERATION.MAXRATIO)
		if inst.regeneratetask ~= nil then
			inst.regeneratetask:Cancel()
			inst.regeneratetask = nil
		end
		inst.regeneratetask = inst:DoPeriodicTask(TUNING.DOTA.BOTTLE.RUNE.REGENERATION.INTERVAL, runeregentick, nil, target)
	end,
	ondetachedfn=function(inst, target)
		if inst.regeneratetask ~= nil then
			inst.regeneratetask:Cancel()
			inst.regeneratetask = nil
		end
	end,
}

buff_defs.buff_dota_rune_shield={
	name="buff_dota_rune_shield",
	duration=TUNING.DOTA.BOTTLE.RUNE.SHIELD.DURATION,
	onattachedfn=function(inst, target)

	end,
	ondetachedfn=function(inst, target)

	end,
}

buff_defs.buff_dota_rune_water={
	name="buff_dota_rune_water",
	duration=0.1,
	onattachedfn=function(inst, target)
		if target.components.health ~= nil and not target.components.health:IsDead() and
		not target:HasTag("playerghost") then
		   target.components.health:DoDelta(TUNING.DOTA.BOTTLE.RUNE.SHIELD.HEALTH, nil, "rune_water")
		   if target.components.dotaattributes ~= nil then
			   target.components.dotaattributes:Mana_DoDelta(TUNING.DOTA.BOTTLE.RUNE.SHIELD.MANA, nil, "rune_water")
		   end
	   end
	end,
}

buff_defs.buff_dota_rune_wisdom={
	name="buff_dota_rune_wisdom",
	duration=0.1,
	onattachedfn=function(inst, target)

	end,
	ondetachedfn=function(inst, target)

	end,
}
-------------------------------------------------血腥榴弹-------------------------------------------------
local function grenadetick(inst, target, damage)
	if target.components.health ~= nil
		and not target.components.health:IsDead()
		and not target:HasTag("playerghost") then
		target.components.health:DoDelta(-damage, nil, "dotamagic")
	else
		inst.components.debuff:Stop()
	end
end
	
buff_defs.buff_dota_grenade={
	name="buff_dota_grenade",
	duration=TUNING.DOTA.BLOOD_GRENADE.GRENADE.DURATION,
	onattachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_grenade", 1+TUNING.DOTA.BLOOD_GRENADE.GRENADE.SPEEDMULTI)
		end
		local damage = TUNING.DOTA.BLOOD_GRENADE.GRENADE.PERDAMAGE
		inst.grenadetask = inst:DoPeriodicTask(TUNING.DOTA.BLOOD_GRENADE.GRENADE.TICK, grenadetick, nil, target, damage)
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_grenade")
		end
		inst.grenadetask:Cancel()
	end,
}
-------------------------------------------------灵匣-------------------------------------------------
buff_defs.buff_dota_empowerspell={
	name="buff_dota_empowerspell",
	duration=TUNING.DOTA.PHYLACTERY.EMPOWERSPELL.DURATION,
	onattachedfn=function(inst, target, followsymbol, followoffset, data)
		if target.components.locomotor ~= nil then
			target.components.locomotor:SetExternalSpeedMultiplier(inst, "buff_dota_empowerspell", (1+TUNING.DOTA.PHYLACTERY.EMPOWERSPELL.SPEEDMULTI))
		end
	end,
	ondetachedfn=function(inst, target)
		if target.components.locomotor ~= nil then
			target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "buff_dota_empowerspell")
		end
	end,
}

return buff_defs