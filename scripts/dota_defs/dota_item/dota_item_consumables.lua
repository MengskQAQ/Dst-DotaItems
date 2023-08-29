local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local dota_item_consumables = {}

--------------------------------------------------------------------------------------------------------
-------------------------------------------------消耗品--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------回城卷轴-------------------------------------------------
local function activatefn(inst, owner)
    if not owner:HasTag("town_portal_scroll") then owner:AddTag("town_portal_scroll") end
end
local function inactivatefn(inst, owner)
    if owner:HasTag("town_portal_scroll") then owner:RemoveTag("town_portal_scroll") end
end
dota_item_consumables.dota_town_portal_scroll = {
    name = "dota_town_portal_scroll",
    animname = "dota_town_portal_scroll",
    animzip = "dota_consumables",
	taglist = {
		"dota_tpcooldown",
    },
    activatename = "DOTA_TPSCROLL",
    sharedcoolingtype = "tpscroll",
    maxsize = TUNING.DOTA.TOWN_PORTAL_SCROLL.MAXSIZE,
    manacost = TUNING.DOTA.TOWN_PORTAL_SCROLL.MANA,
    activatefn = function(inst, owner)
        if not owner:HasTag("town_portal_scroll") then owner:AddTag("town_portal_scroll") end
    end,
    inactivatefn = function(inst, owner)
        if owner:HasTag("town_portal_scroll") then owner:RemoveTag("town_portal_scroll") end
    end,
}
-------------------------------------------------净化药水 or 小蓝-------------------------------------------------
dota_item_consumables.dota_clarity = {
    name = "dota_clarity",
    animname = "dota_clarity",
    animzip = "dota_consumables",
	maxsize = TUNING.DOTA.CLARITY_CAST.MAXSIZE,
    --maxuses = TUNING.DOTA.CLARITY_CAST.MAXUSE, -- 次数耐久
}
-------------------------------------------------仙灵之火-------------------------------------------------
dota_item_consumables.dota_faerie_fire = {
    name = "dota_faerie_fire",
    animname = "dota_faerie_fire",
    animzip = "dota_consumables",
	-- maxsize = 1,
    -- maxuses = TUNING.DOTA.TOWN_PORTAL_SCROLL.MAXUSE, -- 次数耐久
}
-------------------------------------------------侦查守卫-------------------------------------------------
local function ondeploy(inst, pt, deployer)
    -- inst = inst.components.stackable:Get()
    inst.Physics:Teleport(pt:Get())

    local ward = SpawnPrefab(inst._spawn_prefab or "sentryward")
    ward.Transform:SetPosition(inst.Transform:GetWorldPosition())
    ward.SoundEmitter:PlaySound("mengsk_dota2_sounds/items/ward_activate")

    inst:Remove()
end

dota_item_consumables.dota_observer_ward = {
    name = "dota_observer_ward",
    animname = "dota_observer_ward",
    animzip = "dota_consumables",
    extrafn=function(inst)
		inst._spawn_prefab = "dota_sentryward"

		inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.DEFAULT)
        inst.components.deployable.ondeploy = ondeploy
	end,
}
-------------------------------------------------岗哨守卫-------------------------------------------------
dota_item_consumables.dota_sentry_ward = {
    name = "dota_sentry_ward",
    animname = "dota_sentry_ward",
    animzip = "dota_consumables",
    extrafn=function(inst)
		inst._spawn_prefab = "dota_sentryward"

		inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.DEFAULT)
        inst.components.deployable.ondeploy = ondeploy
	end,
}
-------------------------------------------------诡计之雾-------------------------------------------------
dota_item_consumables.dota_smoke_of_deceit = {
    name = "dota_smoke_of_deceit",
    animname = "dota_smoke_of_deceit",
    animzip = "dota_consumables",
    maxsize = 1,
}
------------------------------------------------阿哈利姆魔晶----------------------------------------------
dota_item_consumables.dota_aghanims_shard = {
    name = "dota_aghanims_shard",
    animname = "dota_aghanims_shard",
    animzip = "dota_consumables",
}
-------------------------------------------------魔法芒果-------------------------------------------------
dota_item_consumables.dota_enchanted_mango = {
    name = "dota_enchanted_mango",
    animname = "dota_enchanted_mango",
    animzip = "dota_consumables",
	maxsize = TUNING.DOTA.ENCHANTED_MANGO.MAXSIZE,
    onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.ENCHANTED_MANGO.HEALTHREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.ENCHANTED_MANGO.HEALTHREGEN)
	end,
}
---------------------------------------------------魔瓶 or 瓶子---------------------------------------------------
local levelimages = {
    {level = 1 , image = "dota_bottle_empty",   buff = nil},
    {level = 2 , image = "dota_bottle_small",   buff = "buff_dota_regenerate"},
    {level = 3 , image = "dota_bottle_medium",  buff = "buff_dota_regenerate"},
    {level = 4 , image = "dota_bottle",         buff = "buff_dota_regenerate"},
}

local runestates = {
    {rune = "dota_rune_arcane",       level = 4, image = "dota_rune_arcane", 		buff = "buff_dota_rune_arcane"},    -- 奥术
    {rune = "dota_rune_bounty",       level = 3, image = "dota_rune_bounty", 		buff = "buff_dota_rune_bounty"},    -- 赏金
    {rune = "dota_rune_double",       level = 4, image = "dota_rune_double", 		buff = "buff_dota_rune_double"},    -- 双倍伤害
    {rune = "dota_rune_haste",        level = 4, image = "dota_rune_haste", 		buff = "buff_dota_rune_haste"},    -- 急速
    {rune = "dota_rune_illusion",     level = 4, image = "dota_rune_illusion", 		buff = "buff_dota_rune_illusion"},    -- 幻象
    {rune = "dota_rune_invisbility",  level = 4, image = "dota_rune_invisbility",	buff = "buff_dota_rune_invisbility"},    -- 隐身
    {rune = "dota_rune_regeneration", level = 4, image = "dota_rune_regeneration",	buff = "buff_dota_rune_regeneration"},    -- 恢复
    {rune = "dota_rune_shield",       level = 4, image = "dota_rune_shield", 		buff = "buff_dota_rune_shield"},    -- 护盾
    {rune = "dota_rune_water",        level = 4, image = "dota_rune_water", 		buff = "buff_dota_rune_water"},    -- 圣水
    {rune = "dota_rune_wisdom",       level = 4, image = "dota_rune_wisdom", 		buff = "buff_dota_rune_wisdom"},    -- 智慧
}

dota_item_consumables.dota_bottle = {
    name = "dota_bottle",
    animname = "dota_bottle",
    animzip = "dota_consumables",
    taglist = {
        "monkeyqueenbribe",
    },
    onequipfn = function(inst,owner)
        inst.components.dotabottle:UpdateImage()
	end,
    extrafn=function(inst)
        inst:AddComponent("timer")
        inst:AddComponent("dotabottle")
        inst.components.dotabottle:SetImages(levelimages)
        inst.components.dotabottle:SetStates(runestates)
		inst:AddComponent("tradable")
    end,
}
--------------------------------------------树之祭祀 or 吃树----------------------------------------------
dota_item_consumables.dota_tango = {
    name = "dota_tango",
    animname = "dota_tango",
    animzip = "dota_consumables",
	maxsize = TUNING.DOTA.TANGO.MAXSIZE,
	activatename = "DOTA_TANGO", -- DOTA_TANGO
    -- extrafn=function(inst)
    --     inst:AddComponent("tool")
    -- end,
	-- onequipfn = function(inst,owner)
        -- owner.components.dotacharacter:AddExtraDamage(0)
	-- end,
	-- onunequipfn = function(inst,owner)
        -- owner.components.dotacharacter:RemoveExtraDamage(0)
	-- end,
}
-------------------------------------------------显影之尘 or 粉-------------------------------------------------
dota_item_consumables.dota_dust_of_appearance = {
    name = "dota_dust_of_appearance",
    animname = "dota_dust_of_appearance",
    animzip = "dota_consumables",
    maxsize = TUNING.DOTA.DUST_OF_APPEARANCE.MAXSIZE,
}
-------------------------------------------------知识之书-------------------------------------------------
dota_item_consumables.dota_tome_of_knowledge = {
    name = "dota_tome_of_knowledge",
    animname = "dota_tome_of_knowledge",
    animzip = "dota_consumables",
    maxsize = 1,
}
-------------------------------------------------治疗药膏-------------------------------------------------
dota_item_consumables.dota_healing_salve = {
    name = "dota_healing_salve",
    animname = "dota_healing_salve",
    animzip = "dota_consumables",
    maxsize = TUNING.DOTA.HEALING_SALVE.MAXSIZE,
}
-------------------------------------------------血腥榴弹-------------------------------------------------
dota_item_consumables.dota_blood_grenade = {
    name = "dota_blood_grenade",
    animname = "dota_blood_grenade",
    animzip = "dota_consumables",
    maxsize = TUNING.DOTA.BLOOD_GRENADE.MAXSIZE,
	healthcost = TUNING.DOTA.BLOOD_GRENADE.GRENADE.HEALTH,
    activatename = "DOTA_GRENADE",
    aoetargeting = {
        reticuleprefab = "reticuleaoe",
        pingprefab = "reticuleaoeping",
        -- targetfn = ReticuleTargetFn,
        validcolour = { 1, .75, 0, 1 },
        invalidcolour = { .5, 0, 0, 1 },
        ease = true,
        mouseenabled = true,
    },
}

return {dota_item_consumables = dota_item_consumables}