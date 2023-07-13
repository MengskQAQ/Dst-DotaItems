local dota_item_protect = {}
local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME

--------------------------------------------------------------------------------------------------------
--------------------------------------------------防具--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------赤红甲-------------------------------------------------
dota_item_protect.dota_crimson_guard = {
    name = "dota_crimson_guard",
    animname = "dota_crimson_guard",
	animzip = "dota_protect", 
	taglist = {
    },
    sharedcoolingtype = "crimson",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.CRIMSON_GUARD.EXTRAHEALTH)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.CRIMSON_GUARD.HEALTHREGEN)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.CRIMSON_GUARD.EXTRAARMOR)
        owner.components.dotacharacter:AddBlock(TUNING.DOTA.CRIMSON_GUARD.BLOCK.CHANCE, TUNING.DOTA.CRIMSON_GUARD.BLOCK.DAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.CRIMSON_GUARD.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.CRIMSON_GUARD.HEALTHREGEN)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.CRIMSON_GUARD.EXTRAARMOR)
        owner.components.dotacharacter:RemoveBlock(TUNING.DOTA.CRIMSON_GUARD.BLOCK.CHANCE, TUNING.DOTA.CRIMSON_GUARD.BLOCK.DAMAGE)
	end,
}
-------------------------------------------------黑黄杖-------------------------------------------------
dota_item_protect.dota_black_king_bar = {
    name = "dota_black_king_bar",
    animname = "dota_black_king_bar",
	animzip = "dota_protect", 
	taglist = {
    },
    sharedcoolingtype = "bkb",
    manacost = TUNING.DOTA.BLACK_KING_BAR.AVATAR.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.BLACK_KING_BAR.STRENGTH)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.BLACK_KING_BAR.EXTRADAMAGE)  
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.BLACK_KING_BAR.STRENGTH)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.BLACK_KING_BAR.EXTRADAMAGE)
	end,
}
-------------------------------------------------幻影斧 or 分身斧-------------------------------------------------
dota_item_protect.dota_manta_style = {
    name = "dota_manta_style",
    animname = "dota_manta_style",
	animzip = "dota_protect", 
	taglist = {
    },
    sharedcoolingtype = "manta",
    manacost = TUNING.DOTA.MANTA_STYLE.MIRROR.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.MANTA_STYLE.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.MANTA_STYLE.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.MANTA_STYLE.INTELLIGENCE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.MANTA_STYLE.ATTACKSPEED)
        if owner.components.locomotor ~= nil then
            owner.components.locomotor:SetExternalSpeedMultiplier(inst, "dota_manta_style", (1+TUNING.DOTA.MANTA_STYLE.SPEEDMULTI))
        end
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.MANTA_STYLE.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.MANTA_STYLE.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.MANTA_STYLE.INTELLIGENCE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.MANTA_STYLE.ATTACKSPEED)
        if owner.components.locomotor ~= nil then
            owner.components.locomotor:RemoveExternalSpeedMultiplier(inst, "dota_manta_style")
        end
	end,
}
-------------------------------------------------飓风长戟-------------------------------------------------
dota_item_protect.dota_hurricane_pike = {
    name = "dota_hurricane_pike",
    animname = "dota_hurricane_pike",
	animzip = "dota_protect", 
	taglist = {
    },
    activatename = "DOTA_THRUST",
    sharedcoolingtype = "force",
    manacost = TUNING.DOTA.HURRICANE_PIKE.THRUST.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.HURRICANE_PIKE.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.HURRICANE_PIKE.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.HURRICANE_PIKE.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.HURRICANE_PIKE.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.HURRICANE_PIKE.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.HURRICANE_PIKE.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.HURRICANE_PIKE.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.HURRICANE_PIKE.EXTRAHEALTH)
	end,
}
-------------------------------------------------恐鳌之心-------------------------------------------------
dota_item_protect.dota_heart_of_tarrasque = {
    name = "dota_heart_of_tarrasque",
    animname = "dota_heart_of_tarrasque",
	animzip = "dota_protect", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.HEART_OF_TARRASQUE.STRENGTH)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.HEART_OF_TARRASQUE.HEALTHREGEN)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.HEART_OF_TARRASQUE.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.HEART_OF_TARRASQUE.STRENGTH)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.HEART_OF_TARRASQUE.HEALTHREGEN)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.HEART_OF_TARRASQUE.EXTRAHEALTH)
	end,
}
-------------------------------------------------林肯法球-------------------------------------------------
dota_item_protect.dota_linkens_sphere = {
    name = "dota_linkens_sphere",
    animname = "dota_linkens_sphere",
	animzip = "dota_protect", 
	taglist = {
    },
    onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.LINKENS_SPHERE.ATTRIBUTES)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.LINKENS_SPHERE.HEALTHREGEN)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.LINKENS_SPHERE.MANAREGEN)
        -- PlaySound(act.doer, "mengsk_dota2_sounds/items/linkens_sphere")
    end,
    onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.LINKENS_SPHERE.ATTRIBUTES)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.LINKENS_SPHERE.HEALTHREGEN)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.LINKENS_SPHERE.MANAREGEN)
    end,
}
-------------------------------------------------强袭胸甲-------------------------------------------------
dota_item_protect.dota_assault_cuirass = {
    name = "dota_assault_cuirass",
    animname = "dota_assault_cuirass",
	animzip = "dota_protect", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.ASSAULT_CUIRASS.EXTRAARMOR)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.ASSAULT_CUIRASS.ATTACKSPEED)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.ASSAULT_CUIRASS.EXTRAARMOR)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.ASSAULT_CUIRASS.ATTACKSPEED)
	end,
    playerprox = {
        range = TUNING.DOTA.ASSAULT_CUIRASS.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddExtraArmor("aura", TUNING.DOTA.ASSAULT_CUIRASS.AURA.EXTRAARMOR, "assault")
                player.components.dotaattributes:AddAttackSpeed("aura", TUNING.DOTA.ASSAULT_CUIRASS.AURA.ATTACKSPEED, "assault")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveExtraArmor("aura", "assault")
                player.components.dotaattributes:RemoveAttackSpeed("aura", "assault")
            end
        end
    },
}
-------------------------------------------------清莲宝珠 or 莲花-------------------------------------------------
dota_item_protect.dota_lotus_orb = {
    name = "dota_lotus_orb",
    animname = "dota_lotus_orb",
	animzip = "dota_protect", 
	taglist = {
    },
    activatename = "DOTA_SHELL",
    sharedcoolingtype = "lotus",
    manacost = TUNING.DOTA.LOTUS_ORB.SHELL.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.LOTUS_ORB.EXTRAARMOR)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.LOTUS_ORB.HEALTHREGEN)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.LOTUS_ORB.MAXMANA)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.LOTUS_ORB.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.LOTUS_ORB.EXTRAARMOR)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.LOTUS_ORB.HEALTHREGEN)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.LOTUS_ORB.MAXMANA)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.LOTUS_ORB.MANAREGEN)
	end,
}
-------------------------------------------------刃甲-------------------------------------------------
dota_item_protect.dota_blade_mail = {
    name = "dota_blade_mail",
    animname = "dota_blade_mail",
	animzip = "dota_protect", 
	taglist = {
    },
    sharedcoolingtype = "dr",
    manacost = TUNING.DOTA.BLADE_MAIL.RETURN.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.BLADE_MAIL.EXTRADAMAGE)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.BLADE_MAIL.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.BLADE_MAIL.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.BLADE_MAIL.EXTRAARMOR)
	end,
}
-------------------------------------------------挑战头巾-------------------------------------------------
dota_item_protect.dota_hood_of_defiance = {
    name = "dota_hood_of_defiance",
    animname = "dota_hood_of_defiance",
	animzip = "dota_protect", 
	taglist = {
    },
    sharedcoolingtype = "hood",
    manacost = TUNING.DOTA.HOOD_OF_DEFIANCE.INSULATION.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.HOOD_OF_DEFIANCE.HEALTHREGEN)
        owner.components.dotacharacter:AddSpellResistance(TUNING.DOTA.HOOD_OF_DEFIANCE.SPELLRESIS)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.HOOD_OF_DEFIANCE.HEALTHREGEN)
        owner.components.dotacharacter:RemoveSpellResistance(TUNING.DOTA.HOOD_OF_DEFIANCE.SPELLRESIS)
    end,
}
-------------------------------------------------希瓦的守护 or 冰甲-------------------------------------------------
dota_item_protect.dota_shivas_guard = {
    name = "dota_shivas_guard",
    animname = "dota_shivas_guard",
	animzip = "dota_protect", 
	taglist = {
    },
    sharedcoolingtype = "shivas",
    manacost = TUNING.DOTA.MASK_OF_MADNESS.BERSERK.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.SHIVAS_GUARD.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.SHIVAS_GUARD.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.SHIVAS_GUARD.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.SHIVAS_GUARD.EXTRAARMOR)
	end,
    playerprox = {
        range = TUNING.DOTA.SHIVAS_GUARD.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes.decrspelllifestealamp:SetModifier("aura", TUNING.DOTA.SHIVAS_GUARD.AURA.DECREASE, "shivas")
                player.components.dotaattributes.decrlifestealamp:SetModifier("aura", TUNING.DOTA.SHIVAS_GUARD.AURA.DECREASE, "shivas")
                player.components.dotaattributes:AddAttackSpeed("aura", TUNING.DOTA.SHIVAS_GUARD.AURA.ATTACKSPEED, "shivas")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes.decrspelllifestealamp:RemoveModifier("aura", "shivas")
                player.components.dotaattributes.decrlifestealamp:RemoveModifier("aura", "shivas")
                player.components.dotaattributes:RemoveAttackSpeed("aura", "shivas")
            end
        end
    },
}
-------------------------------------------------先锋盾-------------------------------------------------
dota_item_protect.dota_vanguard = {
    name = "dota_vanguard",
    animname = "dota_vanguard",
	animzip = "dota_protect", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.VANGUARD.EXTRAHEALTH)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.VANGUARD.HEALTHREGEN)
        owner.components.dotacharacter:AddBlock(TUNING.DOTA.VANGUARD.BLOCK.CHANCE, TUNING.DOTA.VANGUARD.BLOCK.DAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.VANGUARD.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.VANGUARD.HEALTHREGEN)
        owner.components.dotacharacter:RemoveBlock(TUNING.DOTA.VANGUARD.BLOCK.CHANCE, TUNING.DOTA.VANGUARD.BLOCK.DAMAGE)
	end,
}
-------------------------------------------------血精石-------------------------------------------------
dota_item_protect.dota_bloodstone = {
    name = "dota_bloodstone",
    animname = "dota_bloodstone",
	animzip = "dota_protect", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.BLOODSTONE.MAXMANA)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.BLOODSTONE.EXTRAHEALTH)
        owner.components.dotacharacter:AddSpellLifesteal(TUNING.DOTA.BLOODSTONE.SPELLLIFESTEAL)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.BLOODSTONE.MAXMANA)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.BLOODSTONE.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveSpellLifesteal(TUNING.DOTA.BLOODSTONE.SPELLLIFESTEAL)
	end,
}
-------------------------------------------------永恒之盘 or 盘子-------------------------------------------------
local function onchargedfn(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner and inst:HasTag("dota_canuse") then
        owner:ListenForEvent("healthdelta", inst.breakercombot)
    end
end

local function ondischargedfn(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner and inst:HasTag("dota_canuse") then
        owner:RemoveEventCallback("healthdelta", inst.breakercombot)
    end
end

dota_item_protect.dota_aeon_disk = {
    name = "dota_aeon_disk",
    animname = "dota_aeon_disk",
	animzip = "dota_protect", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.AEON_DISK.MAXMANA)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.AEON_DISK.EXTRAHEALTH)
        if inst.components.rechargeable ~= nil and inst.components.rechargeable:IsCharged() then
            onchargedfn(inst)
        end
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.AEON_DISK.MAXMANA)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.AEON_DISK.EXTRAHEALTH)
        if inst.components.rechargeable ~= nil and inst.components.rechargeable:IsCharged() then
            ondischargedfn(inst)
        end
	end,
    onchargedfn=onchargedfn,
    ondischargedfn = ondischargedfn,
	extrafn=function(inst)
		inst.breakercombot = function(owner, data)
		    if owner.components.health ~= nil and not owner.components.health:IsDead() 
				and data and data.newpercent < 0.2 and owner.components.debuffable ~= nil then  
			   inst.components.rechargeable:Discharge(TUNING.DOTA.AEON_DISK.BREAKER.CD)
			   owner.components.debuffable:AddDebuff("buff_dota_breaker", "buff_dota_breaker")
			end
		end
	end,
}
-------------------------------------------------永世法衣-------------------------------------------------
dota_item_protect.dota_eternal_shroud = {
    name = "dota_eternal_shroud",
    animname = "dota_eternal_shroud",
	animzip = "dota_protect", 
	taglist = {
    },
    sharedcoolingtype = "hood",
    manacost = TUNING.DOTA.SHROUD.SHROUD.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddSpellResistance(TUNING.DOTA.SHROUD.SPELLRESIS)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.SHROUD.HEALTHREGEN)
        owner.components.dotacharacter:AddSpellLifesteal(TUNING.DOTA.SHROUD.SPELLLIFESTEAL)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveSpellResistance(TUNING.DOTA.SHROUD.SPELLRESIS)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.SHROUD.HEALTHREGEN)
        owner.components.dotacharacter:RemoveSpellLifesteal(TUNING.DOTA.SHROUD.SPELLLIFESTEAL)
	end,
}
-------------------------------------------------振魂石-------------------------------------------------
dota_item_protect.dota_soul_booster = {
    name = "dota_soul_booster",
    animname = "dota_soul_booster",
	animzip = "dota_protect", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.SOUL_BOOSTER.MAXMANA)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.SOUL_BOOSTER.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.SOUL_BOOSTER.MAXMANA)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.SOUL_BOOSTER.EXTRAHEALTH)
	end,
}

return {dota_item_protect = dota_item_protect}