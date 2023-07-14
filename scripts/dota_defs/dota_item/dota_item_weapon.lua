local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local dota_item_weapon = {}
local function PlaySound(inst, sound, ...)
	if inst and inst.SoundEmitter ~= nil and sound ~= nil then
		inst.SoundEmitter:PlaySound(sound, ...)
		-- SoundEmitter:PlaySound(emitter, event, name, volume, ...)
	end
end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------兵刃--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------黯灭-------------------------------------------------
local function OnHitOther_Desolator(inst, data)
    local target = data ~= nil and data.target
    if target ~= nil and target.components.debuffable ~= nil then
        target:AddDebuff("buff_dota_corruption", "buff_dota_corruption")
        PlaySound(inst, "mengsk_dota2_sounds/items/deso_target", "desolator", BASE_VOICE_VOLUME)
    end
end

dota_item_weapon.dota_desolator = {
    name = "dota_desolator",
    animname = "dota_desolator",
    animzip = "dota_weapon",
    taglist = {
    },
    onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.DESOLATOR.EXTRADAMAGE)
        -- inst:ListenForEvent("onareaattackother", OnHitOther_Desolator)
        owner:ListenForEvent("onhitother", OnHitOther_Desolator)
    end,
    onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.DESOLATOR.EXTRADAMAGE)
        -- inst:RemoveEventCallback("onareaattackother", OnHitOther_Desolator)
        owner:RemoveEventCallback("onhitother", OnHitOther_Desolator)
    end,
}
-------------------------------------------------白银之锋-------------------------------------------------
dota_item_weapon.dota_silver_edge = {
    name = "dota_silver_edge",
    animname = "dota_silver_edge",
    animzip = "dota_weapon",
    taglist = {
    },
    sharedcoolingtype = "invis",
    manacost = TUNING.DOTA.SILVER_EDGE.WALK.MANA,
    onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.SILVER_EDGE.EXTRADAMAGE)
        owner.components.dotacharacter:AddCritical(TUNING.DOTA.SILVER_EDGE.CRITICAL.CHANCE,TUNING.DOTA.SILVER_EDGE.CRITICAL.DAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.SILVER_EDGE.ATTACKSPEED)
    end,
    onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.SILVER_EDGE.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveCritical(TUNING.DOTA.SILVER_EDGE.CRITICAL.CHANCE,TUNING.DOTA.SILVER_EDGE.CRITICAL.DAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.SILVER_EDGE.ATTACKSPEED)
    end,
}
-------------------------------------------------代达罗斯之殇 or 大炮-------------------------------------------------
local function DaedalusSoundEmitter(owner, data)
	if data and data.weapon and data.weapon == "daedalus" then
		PlaySound(owner, "mengsk_dota2_sounds/items/daedelus", "daedelus", BASE_VOICE_VOLUME)
	end
end

dota_item_weapon.dota_daedalus = {
    name = "dota_daedalus",
    animname = "dota_daedalus",
	animzip = "dota_weapon",
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.DAEDALUS.EXTRADAMAGE)
        owner.components.dotacharacter:AddCritical(TUNING.DOTA.DAEDALUS.CRITICAL.CHANCE,TUNING.DOTA.DAEDALUS.CRITICAL.DAMAGE, "daedalus")
        owner:ListenForEvent("dotaevent_truestrike", DaedalusSoundEmitter)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.DAEDALUS.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveCritical(TUNING.DOTA.DAEDALUS.CRITICAL.CHANCE,TUNING.DOTA.DAEDALUS.CRITICAL.DAMAGE, "daedalus")
        owner:RemoveEventCallback("dotaevent_truestrike", DaedalusSoundEmitter)
    end,
}
-------------------------------------------------否决坠饰-------------------------------------------------
local NULLIFY_RANGE = TUNING.DOTA.NULLIFIER.NULLIFY.SPELLRANGE
dota_item_weapon.dota_nullifier = {
    name = "dota_nullifier",
    animname = "dota_nullifier",
    animzip = "dota_weapon",
    taglist = {
    },
    activatename = "DOTA_NULLIFY",
    sharedcoolingtype = "nullify",
    manacost = TUNING.DOTA.NULLIFIER.NULLIFY.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.NULLIFIER.EXTRADAMAGE)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.NULLIFIER.EXTRAARMOR)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.NULLIFIER.HEALTHREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.NULLIFIER.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.NULLIFIER.EXTRAARMOR)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.NULLIFIER.HEALTHREGEN)
	end,
    fakeweapon = {
        name = "FakeWeapon_nullifier",
        damage = 0,
        range = NULLIFY_RANGE,
        projectile = "dota_projectile_nullifier",
        tag = "nullifier",
    },
}
-------------------------------------------------蝴蝶-------------------------------------------------
dota_item_weapon.dota_butterfly = {
    name = "dota_butterfly",
    animname = "dota_butterfly",
	animzip = "dota_weapon",
	taglist = {
    },
    sharedcoolingtype = "butter",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.BUTTERFLY.AGILITY)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.BUTTERFLY.EXTRADAMAGE)
        owner.components.dotacharacter:AddDodgeChance(TUNING.DOTA.BUTTERFLY.DODGECHANCE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.BUTTERFLY.ATTACKSPEED)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.BUTTERFLY.AGILITY)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.BUTTERFLY.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveDodgeChance(TUNING.DOTA.BUTTERFLY.DODGECHANCE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.BUTTERFLY.ATTACKSPEED)
	end,
}
-------------------------------------------------辉耀-------------------------------------------------
local burn_tick = TUNING.DOTA.RADIANCE.BURN.TICK
local burn_distance = TUNING.DOTA.RADIANCE.BURN.RANGE
local burn_damage = TUNING.DOTA.RADIANCE.BURN.DAMAGE
dota_item_weapon.dota_radiance = {
    name = "dota_radiance", -- 思路：进入领域后的生物根据计时器受到伤害，计时器挂载在物品上使用playerprox?，挂载在生物身上需要另外使用计时器
    animname = "dota_radiance",
    animzip = "dota_weapon",
    onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.RADIANCE.EXTRADAMAGE)
        owner.components.dotacharacter:AddDodgeChance(TUNING.DOTA.RADIANCE.DODGECHANCE)
        inst.updateburn(inst.burnstata, owner)
    end,
    onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.RADIANCE.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveDodgeChance(TUNING.DOTA.RADIANCE.DODGECHANCE)
        inst.updateburn(false, owner)
    end,
    extrafn=function(inst)
        inst.burnstata = true
        inst.updateburn = function(val, owner)
            if val then
                if inst.burntask == nil then
                    inst.burntask = inst:DoPeriodicTask(burn_tick, function()
                        local x, y, z = inst.Transform:GetWorldPosition()
                        local ents = TheSim:FindEntities(x, y, z, burn_distance, { "_combat" }, { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "player"}) --攻击范围
                        for _,ent in ipairs(ents) do
                            if ent ~= owner 
                             and owner.components.combat:IsValidTarget(ent)
                             and ent.components.combat ~= nil
                             and (owner.components.leader ~= nil and not owner.components.leader:IsFollower(ent))
                             then
                                inst:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = "dotamagic" }) -- 推送事件给服务器来计算其它实体的血量以及通知其它玩家，当前多少实体正在被攻击
                                ent.components.combat:GetAttacked(owner, burn_damage, inst, "dotamagic")
                                if ent.components.debuffable ~= nil then
                                    ent.components.debuffable:AddDebuff("buff_dota_burn", "buff_dota_burn")
                                end
                            end
                        end
                    end)
                end
                if owner.SoundEmitter ~= nil then
                    owner.SoundEmitter:KillSound("dota_radiance")
                    owner.SoundEmitter:PlaySound("mengsk_dota2_sounds/items/radiance_loop", "dota_radiance", BASE_VOICE_VOLUME)	-- 需要平滑声音，降低音量
                end
                if inst.components.inventoryitem then --切换贴图
                	inst.components.inventoryitem:ChangeImageName("dota_radiance")
                end
            else
                if inst.burntask ~= nil then
                    inst.burntask:Cancel()
                    inst.burntask = nil
                end
                if owner.SoundEmitter ~= nil then
                    owner.SoundEmitter:KillSound("dota_radiance")
                end
                if inst.components.inventoryitem then --切换贴图
                	inst.components.inventoryitem:ChangeImageName("dota_radiance_off")
                end
            end
        end
    end,
    -- onsavefn=function(inst,data)
        -- return {burnstata = inst.burnstata}
    -- end,
    -- onloadfn=function(inst,data)
        -- if data.burnstata ~= nil then
            -- inst.burnstata = data.burnstata
        -- end
    -- end,
}
-------------------------------------------------金箍棒-------------------------------------------------
local function MKBSoundEmitter(owner, data)
    if data and data.weapon and data.weapon == "mkb" then
		PlaySound(owner, "mengsk_dota2_sounds/items/mkb_pierce", "mkb_pierce", BASE_VOICE_VOLUME)
	end
end

dota_item_weapon.dota_monkey_king_bar = {
    name = "dota_monkey_king_bar",
    animname = "dota_monkey_king_bar",
	animzip = "dota_weapon",
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.MONKEY_KING_BAR.EXTRADAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.MONKEY_KING_BAR.ATTACKSPEED)
        owner.components.dotacharacter:AddTrueStrike(TUNING.DOTA.MONKEY_KING_BAR.PIERCE.CHANCE,TUNING.DOTA.MONKEY_KING_BAR.PIERCE.DAMAGE,"mkb")
        owner:ListenForEvent("dotaevent_truestrike", MKBSoundEmitter)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.MONKEY_KING_BAR.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.MONKEY_KING_BAR.ATTACKSPEED)
        owner.components.dotacharacter:RemoveTrueStrike(TUNING.DOTA.MONKEY_KING_BAR.PIERCE.CHANCE,TUNING.DOTA.MONKEY_KING_BAR.PIERCE.DAMAGE,"mkb")
        owner:RemoveEventCallback("dotaevent_truestrike", MKBSoundEmitter)
    end,
}
-------------------------------------------------狂战斧-------------------------------------------------
local BATTLE_FURY_CLEAVA_RANGE = TUNING.DOTA.BATTLE_FURY.CLEAVA.RANGE
local BATTLE_FURY_CLEAVA_MULTIPLE = TUNING.DOTA.BATTLE_FURY.CLEAVA.MULTIPLE
local BATTLE_FURY_CLEAVA_ANGLE = TUNING.DOTA.BATTLE_FURY.CLEAVA.ANGLE

local function OnHitOther_Fury(inst, data)
    if data and data.target and data.damage then
        PlaySound(data.inst, "mengsk_dota2_sounds/items/blade_fury", nil, BASE_VOICE_VOLUME) -- 这个特殊音效怪怪的
        local target = data.target
        local damage = data.damage
        local x, y, z = target.Transform:GetWorldPosition()	-- 获取被攻击对象的世界坐标
        local ents = TheSim:FindEntities(x, y, z, BATTLE_FURY_CLEAVA_RANGE, { "_combat" }, { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "player"}) --攻击范围	 -- 通过 TheSim:FindEntities() 函数查找周围的实体
        for _, ent in ipairs(ents) do	 -- 遍历找到的实体
            -- local angle = math.abs(anglediff(inst.Transform:GetRotation(), inst:GetAngleToPoint(ents:GetPosition())))	--取自woetox.lua的296行函数，形成三角形分裂范围
            if ent ~= target
             and ent ~= inst
             and inst.components.combat:IsValidTarget(ent)
             and ((math.abs(anglediff(inst.Transform:GetRotation(), inst:GetAngleToPoint(ent:GetPosition())))) <= BATTLE_FURY_CLEAVA_ANGLE)
             and (inst.components.leader ~= nil
             and not inst.components.leader:IsFollower(ent)) then
                inst:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = nil }) -- 推送事件给服务器来计算其它实体的血量以及通知其它玩家，当前多少实体正在被攻击
                ent.components.combat:GetAttacked(inst, 0, inst, nil)	-- 给予实体伤害，这里的伤害值传多少就是多少,因为仅仅为了仇恨和动画，仅传0伤害
                ent.components.health:DoDelta( -damage * BATTLE_FURY_CLEAVA_MULTIPLE, nil, "dota_cleava", nil, nil, true) --为了无视护甲，但又要播放sg，所以用了2个函数计算伤害
            end
        end
    end
end
dota_item_weapon.dota_battle_fury = {
    name = "dota_battle_fury",
    animname = "dota_battle_fury",
    animzip = "dota_weapon",
    taglist = {
    },
    activatename = "DOTA_CHOP",
    sharedcoolingtype = "chop",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.BATTLE_FURY.EXTRADAMAGE)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.BATTLE_FURY.HEALTHREGEN)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.BATTLE_FURY.MANAREGEN)
        owner:ListenForEvent("onhitother", OnHitOther_Fury)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.BATTLE_FURY.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.BATTLE_FURY.HEALTHREGEN)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.BATTLE_FURY.MANAREGEN)
        owner:RemoveEventCallback("onhitother", OnHitOther_Fury)
	end,
    extrafn=function(inst)
    end,
}
-------------------------------------------------莫尔迪基安的臂章-------------------------------------------------
dota_item_weapon.dota_armlet_of_mordiggian = {
    name = "dota_armlet_of_mordiggian",
    animname = "dota_armlet_of_mordiggian",
	animzip = "dota_weapon",
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.ARMLET.EXTRADAMAGE)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.ARMLET.HEALTHREGEN)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.ARMLET.ATTACKSPEED)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.ARMLET.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.ARMLET.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.ARMLET.HEALTHREGEN)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.ARMLET.ATTACKSPEED)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.ARMLET.EXTRAARMOR)
	end,
}
-------------------------------------------------深渊之刃 or 大晕-------------------------------------------------
dota_item_weapon.dota_abyssal_blade = {
    name = "dota_abyssal_blade",
    animname = "dota_abyssal_blade",
	animzip = "dota_weapon",
	taglist = {
    },
    activatename = "DOTA_OVERWHELM",
    sharedcoolingtype = "overwhelm",
    manacost = TUNING.DOTA.ABYSSAL_BLADE.OVERWHELM.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.ABYSSAL_BLADE.HEALTHREGEN)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.ABYSSAL_BLADE.STRENGTH)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.ABYSSAL_BLADE.EXTRAHEALTH)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.ABYSSAL_BLADE.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.ABYSSAL_BLADE.HEALTHREGEN)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.ABYSSAL_BLADE.STRENGTH)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.ABYSSAL_BLADE.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.ABYSSAL_BLADE.EXTRADAMAGE)
	end,
}
-------------------------------------------------圣剑-------------------------------------------------
dota_item_weapon.dota_divine_rapier = {
    name = "dota_divine_rapier",
    animname = "dota_divine_rapier",
	animzip = "dota_weapon",
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.DIVINE_RAPIER.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.DIVINE_RAPIER.EXTRADAMAGE)
	end,
}
-------------------------------------------------水晶剑-------------------------------------------------
dota_item_weapon.dota_crystalys = {
    name = "dota_crystalys",
    animname = "dota_crystalys",
	animzip = "dota_weapon",
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.CRYSTALYS.EXTRADAMAGE)
        owner.components.dotacharacter:AddCritical(TUNING.DOTA.CRYSTALYS.CRITICAL.CHANCE,TUNING.DOTA.CRYSTALYS.CRITICAL.DAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.CRYSTALYS.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveCritical(TUNING.DOTA.CRYSTALYS.CRITICAL.CHANCE,TUNING.DOTA.CRYSTALYS.CRITICAL.DAMAGE)
	end,
}
-------------------------------------------------碎颅锤 or 晕锤-------------------------------------------------
local function BashSoundEmitter(owner, data)
    if data and data.weapon and data.weapon == "bash" then
		PlaySound(owner, "mengsk_dota2_sounds/items/skull_basher", "skull_basher", BASE_VOICE_VOLUME)
	end
end

dota_item_weapon.dota_skull_basher = {
    name = "dota_skull_basher",
    animname = "dota_skull_basher",
	animzip = "dota_weapon",
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.SKULL_BASHER.STRENGTH)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.SKULL_BASHER.EXTRADAMAGE)
        owner.components.dotacharacter:AddTrueStrike(TUNING.DOTA.SKULL_BASHER.BASH.CHANCE,TUNING.DOTA.SKULL_BASHER.BASH.DAMAGE,"bash")
        owner:ListenForEvent("dotaevent_truestrike", BashSoundEmitter)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.SKULL_BASHER.STRENGTH)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.SKULL_BASHER.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveTrueStrike(TUNING.DOTA.SKULL_BASHER.BASH.CHANCE,TUNING.DOTA.SKULL_BASHER.BASH.DAMAGE,"bash")
        owner:RemoveEventCallback("dotaevent_truestrike", BashSoundEmitter)
    end,
}
-------------------------------------------------虚灵之刃-------------------------------------------------
local ETHEREAL_RANGE = TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.SPELLRANGE
dota_item_weapon.dota_ethereal_blade = {
    name = "dota_ethereal_blade",
    animname = "dota_ethereal_blade",
	animzip = "dota_weapon",
	taglist = {
    },
    activatename = "DOTA_ETHEREAL",
    sharedcoolingtype = "ethereal",
    manacost = TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.ETHEREAL_BLADE.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.ETHEREAL_BLADE.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.ETHEREAL_BLADE.INTELLIGENCE)
        owner.components.dotacharacter:AddSpellDamageAMP(TUNING.DOTA.ETHEREAL_BLADE.SPELLDAMAGEAMP)
        owner.components.dotacharacter:AddSpellLifestealAMP(TUNING.DOTA.ETHEREAL_BLADE.SPELLLIFESTEALAMP)
        owner.components.dotacharacter:AddManaRegenAMP(TUNING.DOTA.ETHEREAL_BLADE.MANAREGENAMP)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.ETHEREAL_BLADE.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.ETHEREAL_BLADE.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.ETHEREAL_BLADE.INTELLIGENCE)
        owner.components.dotacharacter:RemoveSpellDamageAMP(TUNING.DOTA.ETHEREAL_BLADE.SPELLDAMAGEAMP)
        owner.components.dotacharacter:RemoveSpellLifestealAMP(TUNING.DOTA.ETHEREAL_BLADE.SPELLLIFESTEALAMP)
        owner.components.dotacharacter:RemoveManaRegenAMP(TUNING.DOTA.ETHEREAL_BLADE.MANAREGENAMP)
	end,
    fakeweapon = {
        name = "FakeWeapon_etherealblade",
        damage = 0,
        range = ETHEREAL_RANGE,
        projectile = "dota_projectile_ethereal",
        tag = "etherealblade",
    },
}
-------------------------------------------------血棘 or 大紫怨-------------------------------------------------
dota_item_weapon.dota_bloodthorn = {
    name = "dota_bloodthorn",
    animname = "dota_bloodthorn",
	animzip = "dota_weapon",
	taglist = {
    },
	activatename = "DOTA_REND",
    sharedcoolingtype = "DOTA_REND",
    manacost = TUNING.DOTA.BLOODTHORN.REND.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.BLOODTHORN.INTELLIGENCE)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.BLOODTHORN.MANAREGEN)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.BLOODTHORN.EXTRADAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.BLOODTHORN.ATTACKSPEED)
        owner.components.dotacharacter:AddSpellResistance(TUNING.DOTA.BLOODTHORN.SPELLRESIS)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.BLOODTHORN.INTELLIGENCE)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.BLOODTHORN.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.BLOODTHORN.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.BLOODTHORN.ATTACKSPEED)
        owner.components.dotacharacter:RemoveSpellResistance(TUNING.DOTA.BLOODTHORN.SPELLRESIS)
	end,
}
-------------------------------------------------英灵胸针-------------------------------------------------
dota_item_weapon.dota_revenants_brooch = {
    name = "dota_revenants_brooch",
    animname = "dota_revenants_brooch",
	animzip = "dota_weapon",
	taglist = {
    },
    sharedcoolingtype = "brooth",
    manacost = TUNING.DOTA.REVENANTS_BROOCH.PROVINCE.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.REVENANTS_BROOCH.INTELLIGENCE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.REVENANTS_BROOCH.ATTACKSPEED)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.REVENANTS_BROOCH.EXTRAARMOR)
        owner.components.dotacharacter:AddAbility(inst, "ability_dota_blade", "ability_dota_blade")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.REVENANTS_BROOCH.INTELLIGENCE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.REVENANTS_BROOCH.ATTACKSPEED)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.REVENANTS_BROOCH.EXTRAARMOR)
        owner.components.dotacharacter:RemoveAbility(inst, "ability_dota_blade")
	end,
    extrafn=function(inst)
    end,
}
-------------------------------------------------隐刀-------------------------------------------------
dota_item_weapon.dota_invis_sword = {
    name = "dota_invis_sword",
    animname = "dota_invis_sword",
	animzip = "dota_weapon",
	taglist = {
    },
    sharedcoolingtype = "invis",
    manacost = TUNING.DOTA.INVIS_SWORD.WALK.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.INVIS_SWORD.EXTRADAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.INVIS_SWORD.ATTACKSPEED)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.INVIS_SWORD.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.INVIS_SWORD.ATTACKSPEED)
	end,
}
-------------------------------------------------陨星锤-------------------------------------------------
dota_item_weapon.dota_meteor_hammer = {
    name = "dota_meteor_hammer",
    animname = "dota_meteor_hammer",
	animzip = "dota_weapon",
	taglist = {
    },
    activatename = "DOTA_METEOR",
    sharedcoolingtype = "mrteor",
    manacost = TUNING.DOTA.METEOR_HAMMER.METEOR.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.METEOR_HAMMER.ATTRIBUTES)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.METEOR_HAMMER.HEALTHREGEN)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.METEOR_HAMMER.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.METEOR_HAMMER.ATTRIBUTES)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.METEOR_HAMMER.HEALTHREGEN)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.METEOR_HAMMER.MANAREGEN)
	end,
    aoetargeting = {
        reticuleprefab = "reticuleaoe",
        pingprefab = "reticuleaoeping",
        -- targetfn = ReticuleTargetFn,
        validcolour = { 1, .75, 0, 1 },
        invalidcolour = { .5, 0, 0, 1 },
        ease = true,
        mouseenabled = true,
    }
}
-------------------------------------------------散魂剑-------------------------------------------------
dota_item_weapon.dota_disperser = {
    name = "dota_disperser",
    animname = "dota_disperser",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.DISPERSER.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.DISPERSER.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.DISPERSER.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.DISPERSER.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.DISPERSER.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.DISPERSER.EXTRADAMAGE)
	end,
}

return {dota_item_weapon = dota_item_weapon}