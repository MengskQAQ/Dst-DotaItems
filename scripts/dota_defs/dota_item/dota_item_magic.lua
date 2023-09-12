local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local dota_item_magic = {}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------法器--------------------------------------------------
--------------------------------------------------------------------------------------------------------

------------------------------------------eul的神圣法杖 or 吹风----------------------------------------------
dota_item_magic.dota_euls_scepter_of_divinity = {
    name = "dota_euls_scepter_of_divinity",
    animname = "dota_euls_scepter_of_divinity",
	animzip = "dota_magic", 
    activatename = "DOTA_CYCLONE",
    sharedcoolingtype = "cyclone",
    manacost = TUNING.DOTA.EULS.CYCLONE.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.EULS.INTELLIGENCE)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.EULS.MANAREGEN)
        owner.components.dotacharacter:AddExtraSpeed("euls", TUNING.DOTA.EULS.EXTRASPEED, "euls")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.EULS.INTELLIGENCE)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.EULS.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraSpeed("euls", "euls")
	end,
}
-------------------------------------------------阿哈利姆神杖-------------------------------------------------
dota_item_magic.dota_aghanims_scepter = {
    name = "dota_aghanims_scepter",
    animname = "dota_aghanims_scepter",
	animzip = "dota_magic", 
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.AGHANIMS_SCEPTER.ATTRIBUTES)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.AGHANIMS_SCEPTER.EXTRAHEALTH)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.AGHANIMS_SCEPTER.MAXMANA)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.AGHANIMS_SCEPTER.ATTRIBUTES)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.AGHANIMS_SCEPTER.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.AGHANIMS_SCEPTER.MAXMANA)
	end,
}
-------------------------------------------------阿托斯之棍-------------------------------------------------
dota_item_magic.dota_rod_of_atos = {
    name = "dota_rod_of_atos",
    animname = "dota_rod_of_atos",
	animzip = "dota_magic", 
    activatename = "DOTA_CRIPPLE",
    sharedcoolingtype = "rod",
    manacost = TUNING.DOTA.ROD_OF_ATOS.CRIPPLE.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.ROD_OF_ATOS.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.ROD_OF_ATOS.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.ROD_OF_ATOS.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.ROD_OF_ATOS.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.ROD_OF_ATOS.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.ROD_OF_ATOS.INTELLIGENCE)
	end,
    fakeweapon = {
        name = "FakeWeapon_Rod",
        damage = 0,
        range = TUNING.DOTA.ROD_OF_ATOS.CRIPPLE.SPELLRANGE,
        projectile = "dota_projectile_cripple",
        tag = "fakeweapon_rod",
    },
}
-------------------------------------------------达贡之神力1 or 大根-------------------------------------------------
dota_item_magic.dota_dagon_level1 = {
    name = "dota_dagon_level1",
    animname = "dota_dagon_level1",
	animzip = "dota_magic", 
    activatename = "DOTA_BURST1",
    sharedcoolingtype = "dagon",
    manacost = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL1,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
}
-------------------------------------------------达贡之神力2-------------------------------------------------
dota_item_magic.dota_dagon_level2 = {
    name = "dota_dagon_level2",
    animname = "dota_dagon_level2",
	animzip = "dota_magic", 
    activatename = "DOTA_BURST2",
    sharedcoolingtype = "dagon",
    manacost = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL2,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(2 + TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:AddAgility(2 + TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:AddIntelligence(2 + TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(2 + TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(2 + TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(2 + TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
}
-------------------------------------------------达贡之神力3-------------------------------------------------
dota_item_magic.dota_dagon_level3 = {
    name = "dota_dagon_level3",
    animname = "dota_dagon_level3",
	animzip = "dota_magic", 
    activatename = "DOTA_BURST3",
    sharedcoolingtype = "dagon",
    manacost = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL3,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(4 + TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:AddAgility(4 + TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:AddIntelligence(4 + TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(4 + TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(4 + TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(4 + TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
}
-------------------------------------------------达贡之神力4-------------------------------------------------
dota_item_magic.dota_dagon_level4 = {
    name = "dota_dagon_level4",
    animname = "dota_dagon_level4",
	animzip = "dota_magic", 
    activatename = "DOTA_BURST4",
    sharedcoolingtype = "dagon",
    manacost = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL4,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(6 + TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:AddAgility(6 + TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:AddIntelligence(6 + TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(6 + TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(6 + TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(6 + TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
}
-------------------------------------------------达贡之神力5-------------------------------------------------
dota_item_magic.dota_dagon_level5 = {
    name = "dota_dagon_level5",
    animname = "dota_dagon_level5",
	animzip = "dota_magic", 
    activatename = "DOTA_BURST5",
    sharedcoolingtype = "dagon",
    manacost = TUNING.DOTA.DAGON_ENERGY.BURST.MANA.LEVEL5,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(8 + TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:AddAgility(8 + TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:AddIntelligence(8 + TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(8 + TUNING.DOTA.DAGON_ENERGY.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(8 + TUNING.DOTA.DAGON_ENERGY.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(8 + TUNING.DOTA.DAGON_ENERGY.INTELLIGENCE)
	end,
}
-------------------------------------------------纷争面纱-------------------------------------------------
dota_item_magic.dota_veil_of_discord = {  -- TODO: 待制作(这个怎么做呢)
    name = "dota_veil_of_discord",
    animname = "dota_veil_of_discord",
	animzip = "dota_magic", 
    activatename = "DOTA_WEAKNESS",
    sharedcoolingtype = "veil",
    manacost = TUNING.DOTA.VEIL_OF_DISCORD.WEAKNESS.MANA,
	onequipfn = function(inst,owner)
        -- PlaySound(target, "mengsk_dota2_sounds/items/veil_of_discord", nil, BASE_VOICE_VOLUME)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.VEIL_OF_DISCORD.ATTRIBUTES)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.VEIL_OF_DISCORD.ATTRIBUTES)
    end,
    playerprox = {
        range = TUNING.DOTA.VEIL_OF_DISCORD.AURA.RANGE,
        onnearfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:AddManaRegen("aura", TUNING.DOTA.VEIL_OF_DISCORD.AURA.MANAREGEN, "veil")
            end
        end,
        onfarfn = function(inst, player)
            if player.components.dotaattributes ~= nil then
                player.components.dotaattributes:RemoveManaRegen("aura", "veil")
            end
        end
    },
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
-------------------------------------------------风之杖 or 大吹风-------------------------------------------------
dota_item_magic.dota_wind_waker = {
    name = "dota_wind_waker",
    animname = "dota_wind_waker",
	animzip = "dota_magic", 
    manacost = TUNING.DOTA.EULS.CYCLONE.MANA,
    activatename = "DOTA_CYCLONEPLUS",
    sharedcoolingtype = "cyclone",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.WIND_WAKER.INTELLIGENCE)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.WIND_WAKER.MANAREGEN)
        owner.components.dotacharacter:AddExtraSpeed("wind", TUNING.DOTA.WIND_WAKER.EXTRASPEED, "wind")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.WIND_WAKER.INTELLIGENCE)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.WIND_WAKER.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraSpeed("wind", "wind")
	end,
}
-------------------------------------------------缚灵索-------------------------------------------------
local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

dota_item_magic.dota_gleipnir = {
    name = "dota_gleipnir",
    animname = "dota_gleipnir",
	animzip = "dota_magic", 
    sharedcoolingtype = "rod",
    activatename = "DOTA_CHAINS",
    manacost = TUNING.DOTA.GLEIPNIR.ETERNAL.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.GLEIPNIR.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.GLEIPNIR.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.GLEIPNIR.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.GLEIPNIR.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.GLEIPNIR.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.GLEIPNIR.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.GLEIPNIR.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.GLEIPNIR.EXTRADAMAGE)
	end,
    aoetargeting = {
        reticuleprefab = "reticuleaoe",
        pingprefab = "reticuleaoeping",
        -- targetfn = ReticuleTargetFn,
        validcolour = { 1, .75, 0, 1 },
        invalidcolour = { .5, 0, 0, 1 },
        ease = true,
        mouseenabled = true,
    },
    fakeweapon = {
        name = "FakeWeapon_Eternal",
        damage = 0,
        range = TUNING.DOTA.GLEIPNIR.ETERNAL.SPELLRANGE,
        projectile = "dota_projectile_eternal",
        tag = "fakeweapon_eternal",
    },
}
-------------------------------------------------玲珑心-------------------------------------------------
dota_item_magic.dota_octarine_core = {
    name = "dota_octarine_core",
    animname = "dota_octarine_core",
	animzip = "dota_magic", 
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.OCTARINE_CORE.EXTRAHEALTH)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.OCTARINE_CORE.MAXMANA)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.OCTARINE_CORE.MANAREGEN)
        owner.components.dotacharacter:AddExtraSpellRange(TUNING.DOTA.OCTARINE_CORE.SPELLRANGE, "core")
        owner.components.dotacharacter:AddCDReduction(TUNING.DOTA.OCTARINE_CORE.REDUCTION)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.OCTARINE_CORE.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.OCTARINE_CORE.MAXMANA)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.OCTARINE_CORE.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraSpellRange(TUNING.DOTA.OCTARINE_CORE.SPELLRANGE, "core")
        owner.components.dotacharacter:RemoveCDReduction(TUNING.DOTA.OCTARINE_CORE.REDUCTION)
    end,
}
-------------------------------------------------刷新球-------------------------------------------------
dota_item_magic.dota_refresher_orb = {
    name = "dota_refresher_orb",
    animname = "dota_refresher_orb",
	animzip = "dota_magic", 
    sharedcoolingtype = "orb",
    manacost = TUNING.DOTA.REFRESHER_ORB.RESETCOOLDOWNS.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.REFRESHER_ORB.HEALTHREGEN)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.REFRESHER_ORB.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.REFRESHER_ORB.HEALTHREGEN)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.REFRESHER_ORB.MANAREGEN)
	end,
}
-------------------------------------------------微光披风-------------------------------------------------
dota_item_magic.dota_glimmer_cape = {
    name = "dota_glimmer_cape",
    animname = "dota_glimmer_cape",
	animzip = "dota_magic", 
    manacost = TUNING.DOTA.GLIMMER_CAPE.GLIMMER.MANA,
    activatename = "DOTA_GLIMMER",
    sharedcoolingtype = "cape",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddSpellResistance(TUNING.DOTA.GLIMMER_CAPE.SPELLRESIS)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveSpellResistance(TUNING.DOTA.GLIMMER_CAPE.SPELLRESIS)
	end,
}
-------------------------------------------------巫师之刃-------------------------------------------------
dota_item_magic.dota_witch_blade = {
    name = "dota_witch_blade",
    animname = "dota_witch_blade",
	animzip = "dota_magic", 
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.WITCH_BLADE.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.WITCH_BLADE.EXTRAARMOR)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.WITCH_BLADE.ATTACKSPEED)
        owner.components.dotacharacter:AddAbility(inst, "ability_dota_blade", "ability_dota_blade")
        owner:ListenForEvent("dotaevent_blade", inst._onrecharger)
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.WITCH_BLADE.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.WITCH_BLADE.EXTRAARMOR)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.WITCH_BLADE.ATTACKSPEED)
        owner.components.dotacharacter:RemoveAbility(inst, "ability_dota_blade")
        owner:RemoveEventCallback("dotaevent_blade", inst._onrecharger)
    end,
    extrafn=function(inst)
        inst._onrecharger = function(owner)
            if inst and inst.components.rechargeable ~= nil then	-- 装备cd结束
                -- local cdreduction = owner and owner.components.dotaattributes and owner.components.dotaattributes.cdreduction:Get() or 0
                inst.components.rechargeable:Discharge(TUNING.DOTA.WITCH_BLADE.BLADE.CD)
			end
        end
    end,
}
-------------------------------------------------邪恶镰刀 or 羊刀-------------------------------------------------
dota_item_magic.dota_scythe_of_vyse = {
    name = "dota_scythe_of_vyse",
    animname = "dota_scythe_of_vyse",
	animzip = "dota_magic", 
    manacost = TUNING.DOTA.SCYTHE_OF_VYSE.HEX.MANA,
    activatename = "DOTA_HEX",
    sharedcoolingtype = "hex",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.SCYTHE_OF_VYSE.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.SCYTHE_OF_VYSE.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.SCYTHE_OF_VYSE.INTELLIGENCE)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.SCYTHE_OF_VYSE.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.SCYTHE_OF_VYSE.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.SCYTHE_OF_VYSE.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.SCYTHE_OF_VYSE.INTELLIGENCE)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.SCYTHE_OF_VYSE.MANAREGEN)
	end,
}
-------------------------------------------------炎阳纹章 or 大勋章-------------------------------------------------
dota_item_magic.dota_solar_crest = {
    name = "dota_solar_crest",
    animname = "dota_solar_crest",
	animzip = "dota_magic", 
    activatename = "DOTA_SHINE",
    sharedcoolingtype = "crest",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.SOLAR_CREST.ATTRIBUTES)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.SOLAR_CREST.MANAREGEN)
        owner.components.dotacharacter:AddExtraSpeed("solar", TUNING.DOTA.SOLAR_CREST.EXTRASPEED, "solar")
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.SOLAR_CREST.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.SOLAR_CREST.ATTRIBUTES)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.SOLAR_CREST.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraSpeed("solar", "solar")
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.SOLAR_CREST.EXTRAARMOR)
	end,
}
-------------------------------------------------以太透镜-------------------------------------------------
dota_item_magic.dota_aether_lens = {
    name = "dota_aether_lens",
    animname = "dota_aether_lens",
	animzip = "dota_magic", 
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.AETHER_LENS.MAXMANA)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.AETHER_LENS.MANAREGEN)
        owner.components.dotacharacter:AddExtraSpellRange(TUNING.DOTA.OCTARINE_CORE.SPELLRANGE, "core")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.AETHER_LENS.MAXMANA)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.AETHER_LENS.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraSpellRange(TUNING.DOTA.OCTARINE_CORE.SPELLRANGE, "core")
	end,
}
-------------------------------------------------原力法杖 or 推推棒-------------------------------------------------
dota_item_magic.dota_force_staff = {
    name = "dota_force_staff",
    animname = "dota_force_staff",
	animzip = "dota_magic", 
    manacost = TUNING.DOTA.FORCE_STAFF.FORCE.MANA,
    activatename = "DOTA_FORCE",
    sharedcoolingtype = "force",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.FORCE_STAFF.INTELLIGENCE)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.FORCE_STAFF.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.FORCE_STAFF.INTELLIGENCE)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.FORCE_STAFF.EXTRAHEALTH)
	end,
}
-------------------------------------------------紫怨-------------------------------------------------
dota_item_magic.dota_orchid_malevolence = {
    name = "dota_orchid_malevolence",
    animname = "dota_orchid_malevolence",
	animzip = "dota_magic", 
    activatename = "DOTA_BURNX",
    sharedcoolingtype = "burnx",
    manacost = TUNING.DOTA.ORCHID_MALEVOLENCE.BURNX.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.ORCHID_MALEVOLENCE.MANAREGEN)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.ORCHID_MALEVOLENCE.ATTACKSPEED)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.ORCHID_MALEVOLENCE.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.ORCHID_MALEVOLENCE.MANAREGEN)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.ORCHID_MALEVOLENCE.ATTACKSPEED)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.ORCHID_MALEVOLENCE.EXTRADAMAGE)
	end,
}

return {dota_item_magic = dota_item_magic}