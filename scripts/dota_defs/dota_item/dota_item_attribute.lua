local dota_item_attribute = {}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------属性--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------法师长袍-------------------------------------------------
dota_item_attribute.dota_robe_of_the_magi = {
    name = "dota_robe_of_the_magi",
    animname = "dota_robe_of_the_magi",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.ROBE_OF_THE_MAGI.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.ROBE_OF_THE_MAGI.INTELLIGENCE)
	end,
}
-------------------------------------------------欢欣之刃-------------------------------------------------
dota_item_attribute.dota_blade_of_alacrity = {
    name = "dota_blade_of_alacrity",
    animname = "dota_blade_of_alacrity",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.BLADE_OF_ALACRITY.AGILITY)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.BLADE_OF_ALACRITY.AGILITY)
	end,
}
-------------------------------------------------精灵布带-------------------------------------------------
dota_item_attribute.dota_band_of_elvenskin = {
    name = "dota_band_of_elvenskin",
    animname = "dota_band_of_elvenskin",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.BAND_OF_ELVENSKIN.AGILITY)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.BAND_OF_ELVENSKIN.AGILITY)
	end,
}
-------------------------------------------------力量手套-------------------------------------------------
dota_item_attribute.dota_gauntlets_of_strength = {
    name = "dota_gauntlets_of_strength",
    animname = "dota_gauntlets_of_strength",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.GAUNTLETS_OF_STRENGTH.STRENGTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.GAUNTLETS_OF_STRENGTH.STRENGTH)
	end,
}
-------------------------------------------------力量腰带-------------------------------------------------
dota_item_attribute.dota_belt_of_strength = {
    name = "dota_belt_of_strength",
    animname = "dota_belt_of_strength",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.GAUNTLETS_OF_STRENGTH.STRENGTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.GAUNTLETS_OF_STRENGTH.STRENGTH)
	end,
}
-------------------------------------------------敏捷便鞋-------------------------------------------------
dota_item_attribute.dota_slippers_of_agility = {
    name = "dota_slippers_of_agility",
    animname = "dota_slippers_of_agility",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.SLIPPERS_OF.AGILITY.AGILITY)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.SLIPPERS_OF.AGILITY.AGILITY)
	end,
}
-------------------------------------------------魔力法杖-------------------------------------------------
dota_item_attribute.dota_staff_of_wizardry = {
    name = "dota_staff_of_wizardry",
    animname = "dota_staff_of_wizardry",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.STAFF_OF_WIZARDRY.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.STAFF_OF_WIZARDRY.INTELLIGENCE)
	end,
}
-------------------------------------------------食人魔之斧-------------------------------------------------
dota_item_attribute.dota_ogre_axe = {
    name = "dota_ogre_axe",
    animname = "dota_ogre_axe",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.OGRE_AXE.STRENGTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.OGRE_AXE.STRENGTH)
	end,
}
-------------------------------------------------铁树枝干-------------------------------------------------
local function plant(inst, growtime)
    local sapling = SpawnPrefab(inst._spawn_prefab or "pinecone_sapling")
    sapling:StartGrowing()
    sapling.Transform:SetPosition(inst.Transform:GetWorldPosition())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst:Remove()
end
local LEIF_TAGS = { "leif" }
local function ondeploy(inst, pt, deployer)
    -- inst = inst.components.stackable:Get()
    inst.Physics:Teleport(pt:Get())
    local timeToGrow = GetRandomWithVariance(TUNING.PINECONE_GROWTIME.base, TUNING.PINECONE_GROWTIME.random)
    plant(inst, timeToGrow)

    --tell any nearby leifs to chill out
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.LEIF_PINECONE_CHILL_RADIUS, LEIF_TAGS)

    local played_sound = false
    for i, v in ipairs(ents) do
        local chill_chance =
            v:GetDistanceSqToPoint(pt:Get()) < TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS * TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS
            and TUNING.LEIF_PINECONE_CHILL_CHANCE_CLOSE
            or TUNING.LEIF_PINECONE_CHILL_CHANCE_FAR

        if math.random() < chill_chance then
            if v.components.sleeper ~= nil then
                v.components.sleeper:GoToSleep(1000)
                AwardPlayerAchievement( "pacify_forest", deployer )
            end
        elseif not played_sound then
            v.SoundEmitter:PlaySound("dontstarve/creatures/leif/taunt_VO")
            played_sound = true
        end
    end
end

dota_item_attribute.dota_iron_branch = {
    name = "dota_iron_branch",
    animname = "dota_iron_branch",
	animzip = "dota_attribute",
	prefabs = {
		"pinecone_sapling",
		"winter_tree",
	},
	taglist = {
		"deployedplant",
		"cattoy",
		"treeseed",
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.IRON_BRANCH.ATTRIBUTES)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.IRON_BRANCH.ATTRIBUTES)
	end,
	extrafn=function(inst)
		inst._spawn_prefab = "pinecone_sapling"

		inst:AddComponent("fuel")	-- 紧急火源（
        inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

		inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
        inst.components.deployable.ondeploy = ondeploy

		inst:AddComponent("forcecompostable")
        inst.components.forcecompostable.brown = true

		inst:AddComponent("winter_treeseed")
		inst.components.winter_treeseed:SetTree("winter_tree")
	end,
}
-------------------------------------------------王冠-------------------------------------------------
dota_item_attribute.dota_crown = {
    name = "dota_crown",
    animname = "dota_crown",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.CROWN.ATTRIBUTES)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.CROWN.ATTRIBUTES)
	end,
}
-------------------------------------------------圆环-------------------------------------------------
dota_item_attribute.dota_circlet = {
    name = "dota_circlet",
    animname = "dota_circlet",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.CIRCLET.ATTRIBUTES)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.CIRCLET.ATTRIBUTES)
	end,
}
-------------------------------------------------智力斗篷-------------------------------------------------
dota_item_attribute.dota_mantle_of_intelligence = {
    name = "dota_mantle_of_intelligence",
    animname = "dota_mantle_of_intelligence",
	animzip = "dota_attribute", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.MANTLE_OF.INTELLIGENCE.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.MANTLE_OF.INTELLIGENCE.INTELLIGENCE)
	end,
}

return {dota_item_attribute = dota_item_attribute}