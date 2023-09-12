local dota_item_assisted = {}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------辅助--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------奥术鞋 or 秘法鞋-------------------------------------------------
dota_item_assisted.dota_arcane_boots = {
    name = "dota_arcane_boots",
    animname = "dota_arcane_boots",
	animzip = "dota_assisted", 
    sharedcoolingtype = "arcene",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.ARCANE_BOOTS.EXTRASPEED, "arcane")
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.ARCANE_BOOTS.MAXMANA)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraSpeed("boot", "arcane")
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.ARCANE_BOOTS.MAXMANA)
	end,
}
-------------------------------------------------洞察烟斗  or 笛子-------------------------------------------------
dota_item_assisted.dota_pipe_of_insight = {
    name = "dota_pipe_of_insight",
    animname = "dota_pipe_of_insight",
	animzip = "dota_assisted", 
    sharedcoolingtype = "pipe",
    manacost = TUNING.DOTA.PIPE_OF_INSIGHT.BARRIER.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.PIPE_OF_INSIGHT.HEALTHREGEN)
        owner.components.dotacharacter:AddSpellResistance(TUNING.DOTA.PIPE_OF_INSIGHT.SPELLRESIS)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.PIPE_OF_INSIGHT.HEALTHREGEN)
        owner.components.dotacharacter:RemoveSpellResistance(TUNING.DOTA.PIPE_OF_INSIGHT.SPELLRESIS)
	end,
    playerprox = {
        range = TUNING.DOTA.PIPE_OF_INSIGHT.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddHealthRegen("aura", TUNING.DOTA.PIPE_OF_INSIGHT.AURA.HEALTHREGEN, "pipe")
                player.components.dotaattributes.spellresistance:SetModifier("aura", TUNING.DOTA.PIPE_OF_INSIGHT.AURA.SPELLRESIS, "pipe")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveHealthRegen("aura", "pipe")
                player.components.dotaattributes.spellresistance:RemoveModifier("aura", "pipe")
            end
        end
    },
}
-------------------------------------------------弗拉迪米尔的祭品-------------------------------------------------
dota_item_assisted.dota_vladmirs_offering = {
    name = "dota_vladmirs_offering",
    animname = "dota_vladmirs_offering",
	animzip = "dota_assisted",
    playerprox = {
        range = TUNING.DOTA.VLADMIRS_OFFERING.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddExtraArmor("aura", TUNING.DOTA.VLADMIRS_OFFERING.AURA.EXTRAARMOR, "offering")
                player.components.dotaattributes:AddManaRegen("aura", TUNING.DOTA.VLADMIRS_OFFERING.AURA.MANAREGEN, "offering")
                player.components.dotaattributes.lifesteal:SetModifier("aura", TUNING.DOTA.VLADMIRS_OFFERING.AURA.LIFESTEAL, "offering")
            end
            if player.components.combat ~= nil and player.components.combat.damagemultiplier then
                player.components.combat.damagemultiplier = player.components.combat.damagemultiplier + TUNING.DOTA.VLADMIRS_OFFERING.AURA.DAMAGEMULTI
            elseif player.components.combat ~= nil then
                player.components.combat.damagemultiplier = 1 + TUNING.DOTA.VLADMIRS_OFFERING.AURA.DAMAGEMULTI
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveExtraArmor("aura", "offering")
                player.components.dotaattributes:RemoveManaRegen("aura", "offering")
                player.components.dotaattributes.lifesteal:RemoveModifier("aura", "offering")
            end
            if player.components.combat ~= nil and player.components.combat.damagemultiplier then
                player.components.combat.damagemultiplier = player.components.combat.damagemultiplier - TUNING.DOTA.VLADMIRS_OFFERING.AURA.DAMAGEMULTI
            end
        end
    },
}
-------------------------------------------------恢复头巾-------------------------------------------------
dota_item_assisted.dota_headdress = {
    name = "dota_headdress",
    animname = "dota_headdress",
	animzip = "dota_assisted",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.HEADDRESS.HEALTHREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.HEADDRESS.HEALTHREGEN)
	end,
    playerprox = {
        range = TUNING.DOTA.HEADDRESS.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddHealthRegen("aura", TUNING.DOTA.HEADDRESS.AURA.HEALTHREGEN, "headdress")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveHealthRegen("aura", "headdress")
            end
        end
    },
}
-------------------------------------------------魂之灵瓮 or 大骨灰-------------------------------------------------
local SPIRIT_VESSEL_RANGE = TUNING.DOTA.SPIRIT_VESSEL.RELEASE.RANGE
local function EmptyFunction(inst) end

-- local function OnResetRelease(victim)
    -- victim.dota_noreleasetask = nil
-- end

local function OnEntityDeath(inst, owner, range, data)
    local victim = data and data.inst
    if victim ~= nil and data
     -- and victim.dota_noreleasetask == nil
     and victim:IsValid() 
     and (victim == owner 
        or (not owner.components.health:IsDead() 
         and victim:HasTag("epic")
         and (victim.components.health:IsDead() or data.explosive)
         and owner:IsNear(victim, range))
        )
    then
        -- victim.dota_noreleasetask = victim:DoTaskInTime(5, OnResetRelease) -- 防止多个骨灰同时增加点数
		local uses = inst.components.finiteuses and inst.components.finiteuses:GetUses() --当前耐久
        local total = inst.components.finiteuses and inst.components.finiteuses.total --耐久上限
		if total >= uses then
            inst.components.finiteuses:SetUses(math.min(uses + 1, total))
        end
    end	
end

dota_item_assisted.dota_spirit_vessel = {
    name = "dota_spirit_vessel",
    animname = "dota_spirit_vessel",
	animzip = "dota_assisted", 
    maxuses = TUNING.DOTA.SPIRIT_VESSEL.RELEASE.MAXUSES, --次数耐久
    notstartfull = true,
    onfinishedfn = EmptyFunction,--耐久用完执行的函数
    activatename = "DOTA_RELEASE",
    sharedcoolingtype = "release",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.SPIRIT_VESSEL.ATTRIBUTES)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.SPIRIT_VESSEL.EXTRAHEALTH)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.SPIRIT_VESSEL.EXTRAARMOR)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.SPIRIT_VESSEL.MANAREGEN)
        if inst._onentitydeathfn == nil then
            inst._onentitydeathfn = function(src, data) OnEntityDeath(inst, owner, SPIRIT_VESSEL_RANGE, data) end
            inst:ListenForEvent("entity_death", inst._onentitydeathfn, TheWorld)
        end
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.SPIRIT_VESSEL.ATTRIBUTES)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.SPIRIT_VESSEL.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.SPIRIT_VESSEL.EXTRAARMOR)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.SPIRIT_VESSEL.MANAREGEN)
        if inst._onentitydeathfn ~= nil then
            inst:RemoveEventCallback("entity_death", inst._onentitydeathfn, TheWorld)
            inst._onentitydeathfn = nil
        end
	end,
}
-------------------------------------------------影之灵龛 or 骨灰-------------------------------------------------
local URN_OF_SHADOWS_RANGE = TUNING.DOTA.URN_OF_SHADOWS.RELEASE.RANGE
dota_item_assisted.dota_urn_of_shadows = {
    name = "dota_urn_of_shadows",
    animname = "dota_urn_of_shadows",
	animzip = "dota_assisted", 
	maxuses = TUNING.DOTA.URN_OF_SHADOWS.RELEASE.MAXUSES, --次数耐久
    notstartfull = true,
    onfinishedfn = EmptyFunction,--耐久用完执行的函数
    activatename = "DOTA_RELEASEPLUS",
    sharedcoolingtype = "release",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.URN_OF_SHADOWS.ATTRIBUTES)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.URN_OF_SHADOWS.EXTRAARMOR)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.URN_OF_SHADOWS.MANAREGEN)
        if inst._onentitydeathfn == nil then
            inst._onentitydeathfn = function(src, data) OnEntityDeath(inst, owner, URN_OF_SHADOWS_RANGE, data) end
            inst:ListenForEvent("entity_death", inst._onentitydeathfn, TheWorld)
        end
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.URN_OF_SHADOWS.ATTRIBUTES)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.URN_OF_SHADOWS.EXTRAARMOR)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.URN_OF_SHADOWS.MANAREGEN)
        if inst._onentitydeathfn ~= nil then
            inst:RemoveEventCallback("entity_death", inst._onentitydeathfn, TheWorld)
            inst._onentitydeathfn = nil
        end
	end,

}
-------------------------------------------------静谧之鞋 or 绿鞋-------------------------------------------------
local function gotocharge(owner, inst)
    inst.components.rechargeable:Discharge(TUNING.DOTA.TRANQUIL_BOOTS.CD)
end

dota_item_assisted.dota_tranquil_boots = {
    name = "dota_tranquil_boots",
    animname = "dota_tranquil_boots",
	animzip = "dota_assisted", 
	onequipfn = function(inst,owner)
        if inst.components.rechargeable:IsCharged() then
            owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.TRANQUIL_BOOTS.EXTRASPEED, "tranquil")
            owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.TRANQUIL_BOOTS.HEALTHREGEN)
        else
            owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.TRANQUIL_BOOTS.BASESPEED, "tranquil")
        end
        owner:ListenForEvent("onattackother", gotocharge, inst)
        owner:ListenForEvent("attacked", gotocharge, inst)
	end,
	onunequipfn = function(inst,owner)
		owner.components.dotacharacter:RemoveExtraSpeed("boot", "tranquil")
		owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.TRANQUIL_BOOTS.HEALTHREGEN)
		
        owner:RemoveEventCallback("onattackother", gotocharge, inst)
        owner:RemoveEventCallback("attacked", gotocharge, inst)
	end,
    onchargedfn=function(inst)
        local owner = inst.components.inventoryitem:GetGrandOwner()
        if owner and inst:HasTag("dota_canuse") and owner.components.dotacharacter ~= nil then
            owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.TRANQUIL_BOOTS.EXTRASPEED, "tranquil")
            owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.TRANQUIL_BOOTS.HEALTHREGEN)
        end
    end,
    ondischargedfn=function(inst)
        local owner = inst.components.inventoryitem:GetGrandOwner()
        if owner and inst:HasTag("dota_canuse") and owner.components.dotacharacter ~= nil then
            owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.TRANQUIL_BOOTS.HEALTHREGEN)
            owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.TRANQUIL_BOOTS.BASESPEED, "tranquil")
        end
    end,
}
-------------------------------------------------宽容之靴 or 大绿鞋-------------------------------------------------
dota_item_assisted.dota_boots_of_bearing = {
    name = "dota_boots_of_bearing",
    animname = "dota_boots_of_bearing",
	animzip = "dota_assisted", 
    maxuses = TUNING.DOTA.BOOTS_OF_BEARING.ENDURANCE.MAXPOINTS, --次数耐久
    onfinishedfn=function(inst)--耐久用完执行的函数
	end,
    sharedcoolingtype = "drum",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.BOOTS_OF_BEARING.STRENGTH)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.BOOTS_OF_BEARING.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.BOOTS_OF_BEARING.EXTRASPEED, "bearing")
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.BOOTS_OF_BEARING.HEALTHREGEN)

        if inst.recharge_task then
			inst.recharge_task:Cancel()
			inst.recharge_task = nil
		end
        inst.recharge_task = inst:DoPeriodicTask(TUNING.DOTA.BOOTS_OF_BEARING.ENDURANCE.POINTCD, function() -- 虽然有点浪费，不过没什么好方法去做到
            local uses = inst.components.finiteuses and inst.components.finiteuses:GetUses() --当前耐久
            local total = inst.components.finiteuses and inst.components.finiteuses.total --耐久上限
            if total >= uses then
                inst.components.finiteuses:SetUses(math.min(uses + 1, total))
            end
        end)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.BOOTS_OF_BEARING.STRENGTH)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.BOOTS_OF_BEARING.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraSpeed("boot", "bearing")
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.BOOTS_OF_BEARING.HEALTHREGEN)

        if inst.recharge_task then
			inst.recharge_task:Cancel()
			inst.recharge_task = nil
		end
    end,
    playerprox = {
        range = TUNING.DOTA.BOOTS_OF_BEARING.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddExtraSpeed("aura", TUNING.DOTA.BOOTS_OF_BEARING.AURA.EXTRASPEED, "bear")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveExtraSpeed("aura", "bear")
            end
        end
    },
}
-------------------------------------------------梅肯斯姆-------------------------------------------------
dota_item_assisted.dota_mekansm = {
    name = "dota_mekansm",
    animname = "dota_mekansm",
	animzip = "dota_assisted", 
    sharedcoolingtype = "mekansm",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.MEKANSM.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.MEKANSM.EXTRAARMOR)
	end,
    playerprox = {
        range = TUNING.DOTA.MEKANSM.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddHealthRegen("aura", TUNING.DOTA.MEKANSM.AURA.HEALTHREGEN, "bear")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveHealthRegen("aura", "bear")
            end
        end
    },
}
-------------------------------------------------韧鼓-------------------------------------------------
dota_item_assisted.dota_drum_of_endurance = {
    name = "dota_drum_of_endurance",
    animname = "dota_drum_of_endurance",
	animzip = "dota_assisted", 
    sharedcoolingtype = "drum",
    maxuses = TUNING.DOTA.DRUM_OF_ENDURANCE.ENDURANCE.MAXPOINTS, --次数耐久
    onfinishedfn=function(inst)--耐久用完执行的函数
	end,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.DRUM_OF_ENDURANCE.STRENGTH)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.DRUM_OF_ENDURANCE.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.DRUM_OF_ENDURANCE.STRENGTH)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.DRUM_OF_ENDURANCE.INTELLIGENCE)
	end,
    playerprox = {
        range = TUNING.DOTA.DRUM_OF_ENDURANCE.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddExtraSpeed("aura", TUNING.DOTA.DRUM_OF_ENDURANCE.AURA.EXTRASPEED, "drum")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveExtraSpeed("aura", "drum")
            end
        end
    },
}
-------------------------------------------------圣洁吊坠-------------------------------------------------
dota_item_assisted.dota_holy_locket = {
    name = "dota_holy_locket",
    animname = "dota_holy_locket",
	animzip = "dota_assisted", 
    activatename = "DOTA_CHARGE",
    sharedcoolingtype = "wand",
    maxuses = TUNING.DOTA.HOLY_LOCKET.CHARGE.MAXPOINTS, --次数耐久
    notstartfull = true,
    onfinishedfn=function(inst)--耐久用完执行的函数
	end,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.HOLY_LOCKET.EXTRAHEALTH)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.HOLY_LOCKET.MAXMANA)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.HOLY_LOCKET.ATTRIBUTES)
        owner.components.dotacharacter:AddOutHealAMP(TUNING.DOTA.HOLY_LOCKET.OUTHEALAMP)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.HOLY_LOCKET.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.HOLY_LOCKET.MAXMANA)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.HOLY_LOCKET.ATTRIBUTES)
        owner.components.dotacharacter:RemoveOutHealAMP(TUNING.DOTA.HOLY_LOCKET.OUTHEALAMP)
	end,
    playerprox = {
        range = TUNING.DOTA.HOLY_LOCKET.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddHealthRegen("aura", TUNING.DOTA.HOLY_LOCKET.AURA.HEALTHREGEN, "locket")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveHealthRegen("aura", "locket")
            end
        end
    },
}
-------------------------------------------------王者之戒-------------------------------------------------
dota_item_assisted.dota_ring_of_basilius = {
    name = "dota_ring_of_basilius",
    animname = "dota_ring_of_basilius",
	animzip = "dota_assisted", 
    playerprox = {
        range = TUNING.DOTA.RING_OF_BASILIUS.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddHealthRegen("aura", TUNING.DOTA.RING_OF_BASILIUS.AURA.MANAREGEN, "ring")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveManaRegen("aura", "ring")
            end
        end
    },
}
-------------------------------------------------卫士胫甲 or 大鞋-------------------------------------------------
dota_item_assisted.dota_guardian_greaves = {
    name = "dota_guardian_greaves",
    animname = "dota_guardian_greaves",
	animzip = "dota_assisted", 
    sharedcoolingtype = "greaves",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.GUARDIAN_GREAVES.MAXMANA)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.GUARDIAN_GREAVES.EXTRAARMOR)
        owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.GUARDIAN_GREAVES.EXTRASPEED, "guardia")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.GUARDIAN_GREAVES.MAXMANA)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.GUARDIAN_GREAVES.EXTRAARMOR)
        owner.components.dotacharacter:RemoveExtraSpeed("boot", "guardia")
	end,
    playerprox = {
        range = TUNING.DOTA.GUARDIAN_GREAVES.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddManaRegen("aura", TUNING.DOTA.GUARDIAN_GREAVES.AURA.HEALTHREGEN, "greaves")
                player.components.dotaattributes:AddExtraArmor("aura", TUNING.DOTA.GUARDIAN_GREAVES.AURA.EXTRAARMOR, "greaves")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveHealthRegen("aura", "greaves")
                player.components.dotaattributes:RemoveExtraArmor("aura", "greaves")
            end
        end
    },
}
-------------------------------------------------玄冥盾牌-------------------------------------------------
dota_item_assisted.dota_buckler = {
    name = "dota_buckler",
    animname = "dota_buckler",
	animzip = "dota_assisted", 
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.BUCKLER.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.BUCKLER.EXTRAARMOR)
	end,
    playerprox = {
        range = TUNING.DOTA.BUCKLER.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddExtraArmor("aura", TUNING.DOTA.BUCKLER.AURA.EXTRAARMOR, "buckler")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveExtraArmor("aura", "buckler")
            end
        end
    },
}
-------------------------------------------------勇气勋章-------------------------------------------------
dota_item_assisted.dota_medallion_of_courage = {
    name = "dota_medallion_of_courage",
    animname = "dota_medallion_of_courage",
	animzip = "dota_assisted", 
    activatename = "DOTA_VALOR",
    sharedcoolingtype = "crest",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.MEDALLION_OF_COURAGE.MANAREGEN)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.MEDALLION_OF_COURAGE.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.MEDALLION_OF_COURAGE.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.MEDALLION_OF_COURAGE.EXTRAARMOR)
	end,
}
-------------------------------------------------怨灵之契-------------------------------------------------
dota_item_assisted.dota_wraith_pact = {
    name = "dota_wraith_pact",
    animname = "dota_wraith_pact",
	animzip = "dota_assisted", 
    sharedcoolingtype = "wraith",
    manacost = TUNING.DOTA.WRAITH_PACT.REPRISAL.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.WRAITH_PACT.EXTRAHEALTH)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.WRAITH_PACT.MAXMANA)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.WRAITH_PACT.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.WRAITH_PACT.MAXMANA)
    end,
    playerprox = {
        range = TUNING.DOTA.WRAITH_PACT.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddExtraArmor("aura", TUNING.DOTA.WRAITH_PACT.AURA.EXTRAARMOR, "pact")
                player.components.dotaattributes:AddManaRegen("aura", TUNING.DOTA.WRAITH_PACT.AURA.MANAREGEN, "pact")
                player.components.dotaattributes.lifesteal:SetModifier("aura", TUNING.DOTA.WRAITH_PACT.AURA.LIFESTEAL, "pact")
            end
            if player.components.combat ~= nil and player.components.combat.damagemultiplier then
                player.components.combat.damagemultiplier = player.components.combat.damagemultiplier + TUNING.DOTA.WRAITH_PACT.AURA.DAMAGEMULTI
            elseif player.components.combat ~= nil then
                player.components.combat.damagemultiplier = 1 + TUNING.DOTA.WRAITH_PACT.AURA.DAMAGEMULTI
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveExtraArmor("aura", "pact")
                player.components.dotaattributes:RemoveManaRegen("aura", "pact")
                player.components.dotaattributes.lifesteal:RemoveModifier("aura", "pact")
            end
            if player.components.combat ~= nil and player.components.combat.damagemultiplier then
                player.components.combat.damagemultiplier = player.components.combat.damagemultiplier - TUNING.DOTA.WRAITH_PACT.AURA.DAMAGEMULTI
            end
        end
    },
}
-------------------------------------------------长盾-------------------------------------------------
dota_item_assisted.dota_pavise = {
    name = "dota_pavise",
    animname = "dota_pavise",
	animzip = "dota_assisted", 
    manacost = TUNING.DOTA.PAVISE.PROTECT.MANA,
    activatename = "DOTA_PROTECT",
    sharedcoolingtype = "protect",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.PAVISE.EXTRAHEALTH)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.PAVISE.MANAREGEN)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.PAVISE.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.PAVISE.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.PAVISE.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.PAVISE.EXTRAARMOR)
	end,
}

return {dota_item_assisted = dota_item_assisted}