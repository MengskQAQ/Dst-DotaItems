local dota_item_accessories = {}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------配件--------------------------------------------------
--------------------------------------------------------------------------------------------------------

---------------------------------------------动力鞋 or 假腿-------------------------------------------------
dota_item_accessories.dota_power_treads = {
    name = "dota_power_treads",
    animname = "dota_power_treads",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        if inst.primary == 1 then owner.components.dotacharacter:AddStrength(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
        elseif inst.primary == 2 then owner.components.dotacharacter:AddAgility(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
        elseif inst.primary == 3 then owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
        end
        owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.POWER_TREADS.EXTRASPEED, "treads")
	end,
	onunequipfn = function(inst,owner)
        if inst.primary == 1 then owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
        elseif inst.primary == 2 then owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
        elseif inst.primary == 3 then owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
        end
        owner.components.dotacharacter:RemoveExtraSpeed("boot", "treads")
	end,
    extrafn = function(inst)
        inst.primary = 3    -- 主属性(1-力量；2-敏捷；3-智力)
        inst.changeprimary = function(inst, owner)
            if inst.primary < 3 then inst.primary = inst.primary + 1
            elseif inst.primary == 3 then inst.primary = 1 end
            if inst.primary == 1 then 
                owner.components.dotacharacter:AddStrength(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
                owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
				if inst.components.inventoryitem then --切换贴图
					inst.components.inventoryitem:ChangeImageName("dota_power_treads_str")
				end
            elseif inst.primary == 2 then 
                owner.components.dotacharacter:AddAgility(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
                owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
                if inst.components.inventoryitem then --切换贴图
					inst.components.inventoryitem:ChangeImageName("dota_power_treads_agi")
				end
            elseif inst.primary == 3 then 
                owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
                owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.POWER_TREADS.ATTRIBUTES)
                if inst.components.inventoryitem then --切换贴图
					inst.components.inventoryitem:ChangeImageName("dota_power_treads_int")
				end
            end
        end
    end,
}
-------------------------------------------------疯狂面具-------------------------------------------------
dota_item_accessories.dota_mask_of_madness = {
    name = "dota_mask_of_madness",
    animname = "dota_mask_of_madness",
	animzip = "dota_accessories", 
	taglist = {
    },
    manacost = TUNING.DOTA.MASK_OF_MADNESS.BERSERK.MANA,
    sharedcoolingtype = "mask",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.MASK_OF_MADNESS.EXTRADAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.MASK_OF_MADNESS.ATTACKSPEED)
        owner.components.dotacharacter:AddLifesteal(TUNING.DOTA.MASK_OF_MADNESS.LIFESTEAL)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.MASK_OF_MADNESS.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.MASK_OF_MADNESS.ATTACKSPEED)
        owner.components.dotacharacter:RemoveLifesteal(TUNING.DOTA.MASK_OF_MADNESS.LIFESTEAL)
    end,
}
-------------------------------------------------腐蚀之球-------------------------------------------------
dota_item_accessories.dota_orb_of_corrosion = {
    name = "dota_orb_of_corrosion",
    animname = "dota_orb_of_corrosion",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner:ListenForEvent("onattackother", inst.CorrosionAttack)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.ORB_OF_CORROSION.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner:RemoveEventCallback("onattackother", inst.CorrosionAttack)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.ORB_OF_CORROSION.EXTRAHEALTH)
	end,
    extrafn=function(inst)
        inst.CorrosionAttack = function(_,data)
			-- print("debug dota_orb_of_corrosion 1 " .. data.target.prefab)
            if data and data.target.components.debuffable ~= nil then
				-- print("debug dota_orb_of_corrosion 2")
                data.target.components.debuffable:AddDebuff("buff_dota_corrosion", "buff_dota_corrosion")
            end
        end
    end,
}
-------------------------------------------------护腕-------------------------------------------------
dota_item_accessories.dota_bracer = {
    name = "dota_bracer",
    animname = "dota_bracer",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.BRACER.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.BRACER.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.BRACER.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.BRACER.EXTRADAMAGE)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.BRACER.HEALTHREGEN)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.BRACER.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.BRACER.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.BRACER.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.BRACER.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.BRACER.HEALTHREGEN)
    end,
}
-------------------------------------------------坚韧球-------------------------------------------------
dota_item_accessories.dota_perseverance = {
    name = "dota_perseverance",
    animname = "dota_perseverance",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.PERSEVERANCE.HEALTHREGEN)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.PERSEVERANCE.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.PERSEVERANCE.HEALTHREGEN)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.PERSEVERANCE.MANAREGEN)
	end,
}
-------------------------------------------------空灵挂件-------------------------------------------------
dota_item_accessories.dota_null_talisman = {
    name = "dota_null_talisman",
    animname = "dota_null_talisman",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.NULL_TALISMAN.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.NULL_TALISMAN.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.NULL_TALISMAN.INTELLIGENCE)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.NULL_TALISMAN.MAXMANA)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.NULL_TALISMAN.MANAREGEN)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.NULL_TALISMAN.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.NULL_TALISMAN.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.NULL_TALISMAN.INTELLIGENCE)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.NULL_TALISMAN.MAXMANA)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.NULL_TALISMAN.MANAREGEN)
    end,
}
-------------------------------------------------空明杖-------------------------------------------------
dota_item_accessories.dota_oblivion_staff = {
    name = "dota_oblivion_staff",
    animname = "dota_oblivion_staff",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.OBLIVION_STAFF.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.OBLIVION_STAFF.EXTRADAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.OBLIVION_STAFF.ATTACKSPEED)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.OBLIVION_STAFF.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.OBLIVION_STAFF.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.OBLIVION_STAFF.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.OBLIVION_STAFF.ATTACKSPEED)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.OBLIVION_STAFF.MANAREGEN)
	end,
}
-------------------------------------------------猎鹰战刃-------------------------------------------------
dota_item_accessories.dota_falcon_blade = {
    name = "dota_falcon_blade",
    animname = "dota_falcon_blade",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.FALCON_BLADE.EXTRAHEALTH)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.FALCON_BLADE.MANAREGEN)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.FALCON_BLADE.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.FALCON_BLADE.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.FALCON_BLADE.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.FALCON_BLADE.EXTRADAMAGE)
	end,
}
-------------------------------------------------灵魂之戒-------------------------------------------------
dota_item_accessories.dota_soul_ring = {
    name = "dota_soul_ring",
    animname = "dota_soul_ring",
	animzip = "dota_accessories", 
	taglist = {
    },
    healthcost = TUNING.DOTA.SOUL_RING.SACRIFICE.HEALTH,
    sharedcoolingtype = "ring",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.SOUL_RING.STRENGTH)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.SOUL_RING.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.SOUL_RING.STRENGTH)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.SOUL_RING.EXTRAARMOR)
	end,
}
--------------------------------------------迈达斯之手 or 点金手----------------------------------------------
dota_item_accessories.dota_hand_of_midas = {
    name = "dota_hand_of_midas",
    animname = "dota_hand_of_midas",
	animzip = "dota_accessories",
    prefabs = {"goldnugget",},  -- 话说是不是这里加好像影响不到action
	taglist = {},
    activatename = "DOTA_TRANSMUTE",
    sharedcoolingtype = "midas",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.HAND_OF_MIDAS.ATTACKSPEED)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.HAND_OF_MIDAS.ATTACKSPEED)
	end,
}
-------------------------------------------------魔杖-------------------------------------------------
local GETPOINT = TUNING.DOTA.MAGIC_WAND.GETPOINT or 1
local MAGIC_WAND_RANGE = TUNING.DOTA.MAGIC_WAND.RANGE
local function EmptyFunction(inst)
end
local function OnMagicUse(inst, owner, data)
    local victim = data and data.inst
    if (victim ~= nil and owner:IsNear(victim, MAGIC_WAND_RANGE))
     or ( data and data.pos and (distsq(owner:GetPosition(), data.pos) > (MAGIC_WAND_RANGE * MAGIC_WAND_RANGE)) )
    then
        local uses = inst.components.finiteuses and inst.components.finiteuses:GetUses() --当前耐久
        local total = inst.components.finiteuses and inst.components.finiteuses.total --耐久上限
        inst.components.finiteuses:SetUses(math.min(uses + GETPOINT, total))
    end
end
dota_item_accessories.dota_magic_wand = {
    name = "dota_magic_wand",
    animname = "dota_magic_wand",
	animzip = "dota_accessories", 
	taglist = {
    },
    maxuses = TUNING.DOTA.MAGIC_WAND.MAXPOINTS, --次数耐久
    notstartfull = true,
    onfinishedfn = EmptyFunction,--耐久用完执行的函数
    activatename = "DOTA_MAGICCHARGEPLUS",
    sharedcoolingtype = "wand",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.MAGIC_WAND.ATTRIBUTES)
        if inst._onmagicusefn == nil then
            inst._onmagicusefn = function(src, data) OnMagicUse(inst, owner, data) end
            inst:ListenForEvent("dota_magicuse", inst._onmagicusefn, TheWorld)
        end
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.MAGIC_WAND.ATTRIBUTES)
        if inst._onmagicusefn == nil then
            inst._onmagicusefn = function(src, data) OnMagicUse(inst, owner, data) end
            inst:ListenForEvent("dota_magicuse", inst._onmagicusefn, TheWorld)
        end
	end,
}
-------------------------------------------------统御头盔-------------------------------------------------
local function dominatefn1(owner, target)
    if target.components.health ~= nil and target.components.health.maxhealth < TUNING.DOTA.HELM_OF_THE_OVERLORD.DOMINATE.BASEHEALTH then
        target.components.health:Dota_SetMaxHealthWithPercent(TUNING.DOTA.HELM_OF_THE_OVERLORD.DOMINATE.BASEHEALTH)
    end
    if target.components.dotaattributes ~= nil then
        target.components.dotaattributes.extradamage:SetModifier("item", TUNING.DOTA.HELM_OF_THE_OVERLORD.DOMINATE.EXTRADAMAGE, "helm")
        target.components.dotaattributes:AddHealthRegen("item", TUNING.DOTA.HELM_OF_THE_OVERLORD.DOMINATE.HEALTHREGEN, "helm")
        target.components.dotaattributes:AddManaRegen("item", TUNING.DOTA.HELM_OF_THE_OVERLORD.DOMINATE.MANAREGEN, "helm")
        target.components.dotaattributes:AddExtraArmor("item", TUNING.DOTA.HELM_OF_THE_OVERLORD.DOMINATE.EXTRAARMOR, "helm")
    end
end
local function dominator_onremovefn(inst)
    if inst.components.dominate ~= nil then
        inst.components.dominate:StopDominate()
    end
end

dota_item_accessories.dota_helm_of_the_overlord = {
    name = "dota_helm_of_the_overlord",
    animname = "dota_helm_of_the_overlord",
	animzip = "dota_accessories", 
	taglist = {
        "dota_dominator",
    },
    activatename = "DOTA_DOMINATE",
    sharedcoolingtype = "dominate",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.HELM_OF_THE_OVERLORD.ATTRIBUTES)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.HELM_OF_THE_OVERLORD.HEALTHREGEN)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.HELM_OF_THE_OVERLORD.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.HELM_OF_THE_OVERLORD.ATTRIBUTES)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.HELM_OF_THE_OVERLORD.HEALTHREGEN)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.HELM_OF_THE_OVERLORD.EXTRAARMOR)
	end,
    extrafn=function(inst)
        inst:AddComponent("dominate")   -- 支配功能
        inst.components.dominate:SetDominateFn(dominatefn1)
        inst.components.dominate:SetSoundFX("mengsk_dota2_sounds/items/hotd")

        inst:ListenForEvent("onremove", dominator_onremovefn)
    end,
    playerprox = {
        range = TUNING.DOTA.HELM_OF_THE_OVERLORD.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddExtraArmor("aura", TUNING.DOTA.HELM_OF_THE_OVERLORD.AURA.EXTRAARMOR, "overlord")
                player.components.dotaattributes:AddManaRegen("aura", TUNING.DOTA.HELM_OF_THE_OVERLORD.AURA.MANAREGEN, "overlord")
                player.components.dotaattributes.lifesteal:SetModifier("aura", TUNING.DOTA.HELM_OF_THE_OVERLORD.AURA.LIFESTEAL, "overlord")
            end
            if player.components.combat ~= nil and player.components.combat.damagemultiplier then
                player.components.combat.damagemultiplier = player.components.combat.damagemultiplier + TUNING.DOTA.HELM_OF_THE_OVERLORD.AURA.DAMAGEMULTI
            elseif player.components.combat ~= nil then
                player.components.combat.damagemultiplier = 1 + TUNING.DOTA.HELM_OF_THE_OVERLORD.AURA.DAMAGEMULTI
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveExtraArmor("aura", "overlord")
                player.components.dotaattributes:RemoveManaRegen("aura", "overlord")
                player.components.dotaattributes.lifesteal:RemoveModifier("aura", "overlord")
            end
            if player.components.combat ~= nil and player.components.combat.damagemultiplier then
                player.components.combat.damagemultiplier = player.components.combat.damagemultiplier - TUNING.DOTA.HELM_OF_THE_OVERLORD.AURA.DAMAGEMULTI
            end
        end
    },
}
-------------------------------------------------相位鞋-------------------------------------------------
dota_item_accessories.dota_phase_boots = {
    name = "dota_phase_boots",
    animname = "dota_phase_boots",
	animzip = "dota_accessories", 
	taglist = {
    },
    sharedcoolingtype = "phase",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.PHASE_BOOTS.EXTRADAMAGE)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.PHASE_BOOTS.EXTRAARMOR)
        owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.PHASE_BOOTS.EXTRASPEED, "phase")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.PHASE_BOOTS.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.PHASE_BOOTS.EXTRAARMOR)
        owner.components.dotacharacter:RemoveExtraSpeed("boot", "phase")
	end,
}
-------------------------------------------------银月之晶-------------------------------------------------
dota_item_accessories.dota_moon_shard = {
    name = "dota_moon_shard",
    animname = "dota_moon_shard",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.MOON_SHARD.ATTACKSPEED)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.MOON_SHARD.ATTACKSPEED)
	end,
}
-------------------------------------------------远行鞋I or 飞鞋-------------------------------------------------
dota_item_accessories.dota_boots_of_travel_level1 = {
    name = "dota_boots_of_travel_level1",
    animname = "dota_boots_of_travel_level1",
	animzip = "dota_accessories", 
	taglist = {
		"dota_tpcooldown",
    },
    activatename = "DOTA_TPSCROLL",
    sharedcoolingtype = "tpscroll",
    manacost = TUNING.DOTA.TOWN_PORTAL_SCROLL.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.BOOTS_OF_TRAVEL_LEVEL1.EXTRASPEED, "travel1")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraSpeed("boot", "travel1")
	end,
    activatefn = function(inst, owner)
        if not owner:HasTag("boots_of_travel_level1") then owner:AddTag("boots_of_travel_level1") end
    end,
    inactivatefn = function(inst, owner)
        if owner:HasTag("boots_of_travel_level1") then owner:RemoveTag("boots_of_travel_level1") end
    end,
}
-------------------------------------------------远行鞋II or 大飞鞋-------------------------------------------------
dota_item_accessories.dota_boots_of_travel_level2 = {
    name = "dota_boots_of_travel_level2",
    animname = "dota_boots_of_travel_level2",
	animzip = "dota_accessories", 
	taglist = {
		"dota_tpcooldown",
    },
    activatename = "DOTA_TPSCROLL",
    sharedcoolingtype = "tpscroll",
    manacost = TUNING.DOTA.TOWN_PORTAL_SCROLL.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.BOOTS_OF_TRAVEL_LEVEL2.EXTRASPEED, "travel2")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraSpeed("boot", "travel2")
	end,
    activatefn = function(inst, owner)
        if not owner:HasTag("boots_of_travel_level2") then owner:AddTag("boots_of_travel_level2") end
    end,
    inactivatefn = function(inst, owner)
        if owner:HasTag("boots_of_travel_level2") then owner:RemoveTag("boots_of_travel_level2") end
    end,
}
-------------------------------------------------怨灵系带-------------------------------------------------
dota_item_accessories.dota_wraith_band = {
    name = "dota_wraith_band",
    animname = "dota_wraith_band",
	animzip = "dota_accessories", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.WRAITH_BAND.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.WRAITH_BAND.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.WRAITH_BAND.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.WRAITH_BAND.EXTRAARMOR)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.WRAITH_BAND.ATTACKSPEED)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.WRAITH_BAND.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.WRAITH_BAND.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.WRAITH_BAND.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.WRAITH_BAND.EXTRAARMOR)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.WRAITH_BAND.ATTACKSPEED)
    end,
}
-------------------------------------------------支配头盔-------------------------------------------------
local function dominatefn2(owner, target)
    if target.components.health ~= nil and target.components.health.maxhealth < TUNING.DOTA.HELM_OF_THE_DOMINATOR.DOMINATE.BASEHEALTH then
        target.components.health:Dota_SetMaxHealthWithPercent(TUNING.DOTA.HELM_OF_THE_DOMINATOR.DOMINATE.BASEHEALTH)
    end
    if target.components.dotaattributes ~= nil then
        target.components.dotaattributes.extradamage:SetModifier("item", TUNING.DOTA.HELM_OF_THE_DOMINATOR.DOMINATE.EXTRADAMAGE, "helm")
        target.components.dotaattributes:AddHealthRegen("item", TUNING.DOTA.HELM_OF_THE_DOMINATOR.DOMINATE.HEALTHREGEN, "helm")
        target.components.dotaattributes:AddManaRegen("item", TUNING.DOTA.HELM_OF_THE_DOMINATOR.DOMINATE.MANAREGEN, "helm")
        target.components.dotaattributes:AddExtraArmor("item", TUNING.DOTA.HELM_OF_THE_DOMINATOR.DOMINATE.EXTRAARMOR, "helm")
    end
end

dota_item_accessories.dota_helm_of_the_dominator = {
    name = "dota_helm_of_the_dominator",
    animname = "dota_helm_of_the_dominator",
	animzip = "dota_accessories", 
	taglist = {
        "dota_dominator",
    },
    activatename = "DOTA_DOMINATE",
    sharedcoolingtype = "dominate",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.HELM_OF_THE_DOMINATOR.ATTRIBUTES)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.HELM_OF_THE_DOMINATOR.EXTRAARMOR)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.HELM_OF_THE_DOMINATOR.HEALTHREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.HELM_OF_THE_DOMINATOR.ATTRIBUTES)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.HELM_OF_THE_DOMINATOR.EXTRAARMOR)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.HELM_OF_THE_DOMINATOR.HEALTHREGEN)
	end,
    extrafn=function(inst)
        inst:AddComponent("dominate")
        inst.components.dominate:SetDominateFn(dominatefn2)
        inst.components.dominate:SetSoundFX("mengsk_dota2_sounds/items/hotd")

        inst:ListenForEvent("onremove", dominator_onremovefn)
    end,
}

return {dota_item_accessories = dota_item_accessories}