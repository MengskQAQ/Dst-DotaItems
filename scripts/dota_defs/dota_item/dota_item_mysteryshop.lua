local dota_item_mysteryshop = {}

--------------------------------------------------------------------------------------------------------
------------------------------------------------神秘商店-------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------板甲-------------------------------------------------
dota_item_mysteryshop.dota_platemail = {
    name = "dota_platemail",
    animname = "dota_platemail",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.PLATEMAIL.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.PLATEMAIL.EXTRAARMOR)
	end,
}
-------------------------------------------------恶魔刀锋-------------------------------------------------
dota_item_mysteryshop.dota_demon_edge = {
    name = "dota_demon_edge",
    animname = "dota_demon_edge",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.DEMON_EDGE.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.DEMON_EDGE.EXTRADAMAGE)
	end,
}
-------------------------------------------------活力之球-------------------------------------------------
dota_item_mysteryshop.dota_vitality_booster = {
    name = "dota_vitality_booster",
    animname = "dota_vitality_booster",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.VITALITY_BOOSTER.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.VITALITY_BOOSTER.EXTRAHEALTH)
	end,
}
-------------------------------------------------精气之球-------------------------------------------------
dota_item_mysteryshop.dota_point_booster = {
    name = "dota_point_booster",
    animname = "dota_point_booster",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.POINT_BOOSTER.EXTRAHEALTH)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.POINT_BOOSTER.MAXMANA)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.POINT_BOOSTER.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.POINT_BOOSTER.MAXMANA)
    end,
}
-------------------------------------------------能量之球-------------------------------------------------
dota_item_mysteryshop.dota_energy_booster = {
    name = "dota_energy_booster",
    animname = "dota_energy_booster",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.ENERGY_BOOSTER.MAXMANA)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.ENERGY_BOOSTER.MAXMANA)
	end,
}
-------------------------------------------------极限法球-------------------------------------------------
dota_item_mysteryshop.dota_ultimate_orb = {
    name = "dota_ultimate_orb",
    animname = "dota_ultimate_orb",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.ULTIMATE_ORB.ATTRIBUTES)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.ULTIMATE_ORB.ATTRIBUTES)
 	end,
}
-------------------------------------------------掠夺者之斧-------------------------------------------------
dota_item_mysteryshop.dota_reaver = {
    name = "dota_reaver",
    animname = "dota_reaver",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:Add(TUNING.DOTA.ITEM_NAME.item)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:Remove(TUNING.DOTA.ITEM_NAME.item)
	end,
}
-------------------------------------------------闪避护符-------------------------------------------------
dota_item_mysteryshop.dota_talisman_of_evasion = {
    name = "dota_talisman_of_evasion",
    animname = "dota_talisman_of_evasion",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddDodgeChance(TUNING.DOTA.TALISMAN_OF_EVASION.DODGECHANCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveDodgeChance(TUNING.DOTA.TALISMAN_OF_EVASION.DODGECHANCE)
	end,
}
-------------------------------------------------神秘法杖-------------------------------------------------
dota_item_mysteryshop.dota_mystic_staff = {
    name = "dota_mystic_staff",
    animname = "dota_mystic_staff",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.MYSTIC_STAFF.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.MYSTIC_STAFF.INTELLIGENCE)
	end,
}
-------------------------------------------------圣者遗物-------------------------------------------------
dota_item_mysteryshop.dota_sacred_relic = {
    name = "dota_sacred_relic",
    animname = "dota_sacred_relic",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.SACRED_RELIC.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.SACRED_RELIC.EXTRADAMAGE)
	end,
}
-------------------------------------------------虚无宝石-------------------------------------------------
dota_item_mysteryshop.dota_void_stone = {
    name = "dota_void_stone",
    animname = "dota_void_stone",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.VOID_STONE.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.VOID_STONE.MANAREGEN)
	end,
}
-------------------------------------------------治疗指环-------------------------------------------------
dota_item_mysteryshop.dota_ring_of_health = {
    name = "dota_ring_of_health",
    animname = "dota_ring_of_health",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.RING_OF_HEALTH.HEALTHREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.RING_OF_HEALTH.HEALTHREGEN)
	end,
}
-------------------------------------------------鹰歌弓-------------------------------------------------
dota_item_mysteryshop.dota_eaglesong = {
    name = "dota_eaglesong",
    animname = "dota_eaglesong",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.EAGLESONG.AGILITY)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.EAGLESONG.AGILITY)
	end,
}
-------------------------------------------------振奋宝石-------------------------------------------------
dota_item_mysteryshop.dota_hyperstone = {
    name = "dota_hyperstone",
    animname = "dota_hyperstone",
	animzip = "dota_mysteryshop", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.HYPERSTONE.ATTACKSPEED)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.HYPERSTONE.ATTACKSPEED)
	end,
}

return {dota_item_mysteryshop = dota_item_mysteryshop}