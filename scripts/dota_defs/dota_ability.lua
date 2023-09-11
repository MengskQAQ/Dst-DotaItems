-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- 被动 -----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local function PlaySound(inst, sound, ...)
	if inst.SoundEmitter ~= nil and sound ~= nil then
		inst.SoundEmitter:PlaySound(sound, ...)
		-- SoundEmitter:PlaySound(emitter, event, name, volume, ...)
	end
end
local function AddDebuff(inst, debuffname, ...)
	if inst.components.debuffable ~= nil then
		inst.components.debuffable:AddDebuff(debuffname, debuffname, ...)
	end
end

--Ability列表
local ability_defs={}

--------------------------------------------------- 巫师之刃 -------------------------------------------------
local function OnResetBlade(inst, target)
    inst.nobladetask = nil
	if target and target.components.dotacharacter then
		target.components.dotacharacter:AddTrueStrike(1, 0, "witch_blade")
	end
end

ability_defs.ability_dota_blade={
	name="ability_dota_blade",
	onattachedfn=function(inst, target)
		if target.components.dotacharacter then
            target.components.dotacharacter:AddTrueStrike(1, 0, "witch_blade")
        end

		if inst._onhitother == nil then
			inst._onhitother = function(owner, data)
				if inst.nobladetask == nil and data and data.target and data.target.components.debuffable then

					if owner then
						local intelligence = target.components.dotacharacter and target.components.dotacharacter.intelligence or 1
						local cdreduction = target.components.dotaattributes and target.components.dotaattributes.cdreduction:Get() or 0

						inst.nobladetask = inst:DoTaskInTime(TUNING.DOTA.WITCH_BLADE.BLADE.CD * (1 - cdreduction), OnResetBlade, target)

						if target.components.dotacharacter then
							target.components.dotacharacter:RemoveTrueStrike(1, 0, "witch_blade")
						end
						target:PushEvent("dotaevent_blade")
						data.target.components.debuffable:AddDebuff("buff_dota_blade", "buff_dota_blade", {intelligence = intelligence})
					end

                end
			end
		end
		inst:ListenForEvent("onhitother", inst._onhitother, target)
	end,
	onextendedfn=function(inst, target)
	end,
	ondetachedfn=function(inst, target)
		if inst.nobladetask ~= nil then
			inst.nobladetask:Cancel()
			inst.nobladetask = nil
		end

		if inst._onhitother ~= nil then
			inst:RemoveEventCallback("onhitother", inst._onhitother, target)
			inst._onhitother = nil
		end
		
		if target.components.dotacharacter then
			target.components.dotacharacter:RemoveTrueStrike(1, 0, "witch_blade")
		end
	end,
}
-------------------------------------------------回音战刃 or 连击刀-------------------------------------------------
local ECHO_CD = TUNING.DOTA.ECHO_SABRE.ECHO.CD
local function OnResetEcho(inst)
    inst.noechotask = nil
end

ability_defs.ability_dota_echo={
	name="ability_dota_echo",
	onattachedfn=function(inst, target)
		if inst._onhitother == nil then
			inst._onhitother = function(owner, data)
				if inst.noechotask == nil and data and data.target then
					local cdreduction = owner.components.dotaattributes.cdreduction:Get()
					inst.noechotask = inst:DoTaskInTime(ECHO_CD * cdreduction, OnResetEcho)
					AddDebuff(data.target, "buff_dota_echo")
					if owner and owner.components.combat then
						owner.components.combat:ResetCooldown()
						AddDebuff(owner, "buff_dota_echoattack")
						owner:PushEvent("dotaevent_echo")
					end
                end
			end
		end
		inst:ListenForEvent("onhitother", inst._onhitother, target)
	end,
	onextendedfn=function(inst, target)
	end,
	ondetachedfn=function(inst, target)
		if inst.noechotask ~= nil then
			inst.noechotask:Cancel()
			inst.noechotask = nil
		end

		if inst._onhitother ~= nil then
			inst:RemoveEventCallback("onhitother", inst._onhitother, target)
			inst._onhitother = nil
		end
	end,
}





return ability_defs