local dota_item_equipment = {}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------装备--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------标枪-------------------------------------------------
dota_item_equipment.dota_javelin = {
    name = "dota_javelin",
    animname = "dota_javelin",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddTrueStrike(TUNING.DOTA.JAVELIN.PIERCE.PROBABILITY, TUNING.DOTA.JAVELIN.PIERCE.DAMAGE, "javelin")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveTrueStrike(TUNING.DOTA.JAVELIN.PIERCE.PROBABILITY, TUNING.DOTA.JAVELIN.PIERCE.DAMAGE, "javelin")
	end,
}
-------------------------------------------------淬毒之珠-------------------------------------------------
dota_item_equipment.dota_orb_of_venom = {
    name = "dota_orb_of_venom",
    animname = "dota_orb_of_venom",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner:ListenForEvent("onattackother", inst.PoisonAttack)
	end,
	onunequipfn = function(inst,owner)
        owner:RemoveEventCallback("onattackother", inst.PoisonAttack)
	end,
    extrafn=function(inst)
        inst.PoisonAttack = function(_,data)
            if data and data.target.components.debuffable ~= nil then
                data.target.components.debuffable:AddDebuff("buff_dota_venom", "buff_dota_venom")
            end
        end
    end,
}
-------------------------------------------------大剑-------------------------------------------------
dota_item_equipment.dota_claymore = {
    name = "dota_claymore",
    animname = "dota_claymore",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.CLAYMORE.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.CLAYMORE.EXTRADAMAGE)
	end,
}
-------------------------------------------------短棍-------------------------------------------------
dota_item_equipment.dota_quarterstaff = {
    name = "dota_quarterstaff",
    animname = "dota_quarterstaff",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.QUARTERSTAFF.EXTRADAMAGE)
        owner.components.dotacharacter:AddDamageRange(TUNING.DOTA.QUARTERSTAFF.DAMAGERANGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.QUARTERSTAFF.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveDamageRange(TUNING.DOTA.QUARTERSTAFF.DAMAGERANGE)
	end,
}
-------------------------------------------------攻击之爪-------------------------------------------------
dota_item_equipment.dota_blades_of_attack = {
    name = "dota_blades_of_attack",
    animname = "dota_blades_of_attack",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.BLADES_OF_ATTACK.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.BLADES_OF_ATTACK.EXTRADAMAGE)
	end,
}
-------------------------------------------------加速手套-------------------------------------------------
dota_item_equipment.dota_gloves_of_haste = {
    name = "dota_gloves_of_haste",
    animname = "dota_gloves_of_haste",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.GLOVES_OF_HASTE.ATTACKSPEED)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.GLOVES_OF_HASTE.ATTACKSPEED)
	end,
}
-------------------------------------------------枯萎之石-------------------------------------------------
dota_item_equipment.dota_blight_stone = {
    name = "dota_blight_stone",
    animname = "dota_blight_stone",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner:ListenForEvent("onattackother", inst.BlightAttack)
	end,
	onunequipfn = function(inst,owner)
        owner:RemoveEventCallback("onattackother", inst.BlightAttack)
	end,
    extrafn=function(inst)
        inst.BlightAttack = function(_,data)
            if data and data.target.components.debuffable ~= nil then
                data.target.components.debuffable:AddDebuff("buff_dota_blight", "buff_dota_blight")
            end
        end
    end,
}
-------------------------------------------------阔剑-------------------------------------------------
dota_item_equipment.dota_broadsword = {
    name = "dota_broadsword",
    animname = "dota_broadsword",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.BROADSWORD.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.BROADSWORD.EXTRADAMAGE)
	end,
}
-------------------------------------------------秘银锤-------------------------------------------------
dota_item_equipment.dota_mithril_hammer = {
    name = "dota_mithril_hammer",
    animname = "dota_mithril_hammer",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.MITHRIL_HAMMER.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.MITHRIL_HAMMER.EXTRADAMAGE)
	end,
}
-------------------------------------------------凝魂之露-------------------------------------------------
dota_item_equipment.dota_infused_raindrop = {
    name = "dota_infused_raindrop",
    animname = "dota_infused_raindrop",
	animzip = "dota_equipment", 
	taglist = {
    },
    maxuses = TUNING.DOTA.INFUSED_RAINDROP.MAXUSE,
    onfinishedfn = function(inst)
        -- Todo:执行remove前需要将装备卸下吗？
        inst:Remove()
    end,
	onequipfn = function(inst,owner)
        owner.components.combat:Dota_SetInfused(true)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.INFUSED_RAINDROP.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.combat:Dota_SetInfused(false)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.INFUSED_RAINDROP.MANAREGEN)
	end,
    extrafn=function(inst)
        inst.UseOne = function()
            if inst.components.rechargeable then
                inst.components.rechargeable:SetCharge(TUNING.DOTA.INFUSED_RAINDROP.CD)
            end
            if inst.components.finiteuses ~= nil then
                inst.components.finiteuses:Use(1)
            end
        end
    end,
}
-------------------------------------------------闪电指套-------------------------------------------------
dota_item_equipment.dota_blitz_knuckles = {
    name = "dota_blitz_knuckles",
    animname = "dota_blitz_knuckles",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.BLITZ_KNUCKLES.ATTACKSPEED)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.BLITZ_KNUCKLES.ATTACKSPEED)
	end,
}
-------------------------------------------------守护指环-------------------------------------------------
dota_item_equipment.dota_ring_of_protection = {
    name = "dota_ring_of_protection",
    animname = "dota_ring_of_protection",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.RING_OF_PROTECTION.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.RING_OF_PROTECTION.EXTRAARMOR)
	end,
}
-------------------------------------------------锁子甲-------------------------------------------------
dota_item_equipment.dota_chainmail = {
    name = "dota_chainmail",
    animname = "dota_chainmail",
	animzip = "dota_equipment", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.CHAINMAIL.EXTRAARMOR)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.CHAINMAIL.EXTRAARMOR)
	end,
}
-------------------------------------------------铁意头盔-------------------------------------------------
dota_item_equipment.dota_helm_of_iron_will = {
    name = "dota_helm_of_iron_will",
    animname = "dota_helm_of_iron_will",
	animzip = "dota_equipment", 
	taglist = {
    },        
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraArmor(TUNING.DOTA.HELM_OF_IRON_WILL.EXTRAARMOR)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.HELM_OF_IRON_WILL.HEALTHREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraArmor(TUNING.DOTA.HELM_OF_IRON_WILL.EXTRAARMOR)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.HELM_OF_IRON_WILL.HEALTHREGEN)
	end,
}

-------------------------------------------压制之刃 or 补刀斧-------------------------------------------------
dota_item_equipment.dota_quelling_blade = {
    name = "dota_quelling_blade",
    animname = "dota_quelling_blade",
	animzip = "dota_equipment", 
    activatename = "DOTA_CHOP",
	taglist = {
    },
    sharedcoolingtype = "chop",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.QUELLING_BLADE.EXTRADAMAGE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.QUELLING_BLADE.EXTRADAMAGE)
	end,
}

return {dota_item_equipment = dota_item_equipment}