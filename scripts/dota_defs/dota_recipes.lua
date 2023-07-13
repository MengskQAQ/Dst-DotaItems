--[[
{
	name,--配方名，一般情况下和需要合成的道具同名
	ingredients,--配方，这边为了区分不同难度的配方，做了嵌套{{正常难度},{简易难度}}，只填一个视为不做难度区分
	tab,--合成栏(已废弃)
	level,--解锁科技
	--placer,--建筑类科技放置时显示的贴图、占位等/也可以配List用于添加更多额外参数，比如不可分解{no_deconstruction = true}
	min_spacing,--最小间距，不填默认为3.2
	nounlock,--不解锁配方，只能在满足科技条件的情况下制作(分类默认都算专属科技站,不需要额外添加了)
	numtogive,--一次性制作的数量，不填默认为1
	builder_tag,--制作者需要拥有的标签
	atlas,--需要用到的图集文件(.xml)，不填默认用images/name.xml
	image,--物品贴图(.tex)，不填默认用name.tex
	testfn,--尝试放下物品时的函数，可用于判断坐标点是否符合预期
	product,--实际合成道具，不填默认取name
	build_mode,--建造模式,水上还是陆地(默认为陆地BUILDMODE.LAND,水上为BUILDMODE.WATER)
	build_distance,--建造距离(玩家距离建造点的距离)
	filters,--制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}

	--扩展字段
	placer,--建筑类科技放置时显示的贴图、占位等
	filter,--制作栏分类
	description,--覆盖原来的配方描述
	canbuild,--制作物品是否满足条件的回调函数,支持参数(recipe, self.inst, pt, rotation),return 结果,原因
	sg_state,--自定义制作物品的动作(比如吹气球就可以调用吹的动作)
	no_deconstruction,--填true则不可分解(也可以用function)
	require_special_event,--特殊活动(比如冬季盛宴限定之类的)
	dropitem,--制作后直接掉落物品
	actionstr,--把"制作"改成其他的文字
	manufactured,--填true则表示是用制作站制作的，而不是用builder组件来制作(比如万圣节的药水台就是用这个)
}

]]--

--------------------------------------------------------------------------------------------------------------
-------------------------------------------------自定义配方表--------------------------------------------------
--------------------------------------------------------------------------------------------------------------
local dota_recipes={
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------消耗品--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------回城卷轴-------------------------------------------------
    {
        name = "dota_town_portal_scroll",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.TOWN_PORTAL_SCROLL.GOLD),
			},
        },
    },
    -------------------------------------------------净化药水 or 小蓝-------------------------------------------------
    {
        name = "dota_clarity",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.CLARITY_CAST.GOLD),
			},
        },
    },
    -------------------------------------------------仙灵之火-------------------------------------------------
    {
        name = "dota_faerie_fire",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.FAERIE_FIRE.GOLD),
			},
        },
    },
    -------------------------------------------------侦查守卫-------------------------------------------------
    {
        name = "dota_observer_ward",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.OBSERVER_WARD.GOLD),
			},
        },
    },
    -------------------------------------------------岗哨守卫-------------------------------------------------
    {
        name = "dota_sentry_ward",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SENTRY_WARD.GOLD),
			},
        },
    },
    -------------------------------------------------诡计之雾-------------------------------------------------
    {
        name = "dota_dust_of_appearance",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SMOKE_OF_DECEIT.GOLD),
			},
        },
    },
    ------------------------------------------------阿哈利姆魔晶----------------------------------------------
    {
        name = "dota_aghanims_shard",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.AGHANIMS_SHARD.GOLD),
			},
        },
    },
    -------------------------------------------------魔法芒果-------------------------------------------------
    {
        name = "dota_enchanted_mango",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ENCHANTED_MANGO.GOLD),
			},
        },
    },
    ---------------------------------------------------魔瓶 or 瓶子---------------------------------------------------
    {
        name = "dota_bottle",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BOTTLE.GOLD),
			},
        },
    },
    -------------------------------------------------树之祭祀 or 吃树-------------------------------------------------
    {
        name = "dota_tango",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.TANGO.GOLD),
			},
        },
    },
    -------------------------------------------------显影之尘 or 粉-------------------------------------------------
    {
        name = "dota_dust_of_appearance",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DUST_OF_APPEARANCE.GOLD),
			},
        },
    },
    -- -------------------------------------------------知识之书-------------------------------------------------
    -- {
    --     name = "dota_tome_of_knowledge",
    --     dotatype = "dota_consumables",
    --     ingredients = {
	-- 		{
	-- 			Ingredient("goldnugget", TUNING.DOTA.TOME_OF_KNOWLEDGE.GOLD),
	-- 		},
    --     },
    -- },
    -------------------------------------------------治疗药膏-------------------------------------------------
    {
        name = "dota_healing_salve",
        dotatype = "dota_consumables",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HEALING_SALVE.GOLD),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------属性--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------法师长袍-------------------------------------------------
    {
        name = "dota_robe_of_the_magi",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ROBE_OF_THE_MAGI.GOLD),
			},
        },
    },
    -------------------------------------------------欢欣之刃-------------------------------------------------
    {
        name = "dota_blade_of_alacrity",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLADE_OF_ALACRITY.GOLD),
			},
        },
    },
    -------------------------------------------------精灵布带-------------------------------------------------
    {
        name = "dota_band_of_elvenskin",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BAND_OF_ELVENSKIN.GOLD),
			},
        },
    },
    -------------------------------------------------力量手套-------------------------------------------------
    {
        name = "dota_gauntlets_of_strength",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.GAUNTLETS_OF_STRENGTH.GOLD),
			},
        },
    },
    -------------------------------------------------力量腰带-------------------------------------------------
    {
        name = "dota_belt_of_strength",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BELT_OF_STRENGTH.GOLD),
			},
        },
    },
    -------------------------------------------------敏捷便鞋-------------------------------------------------
    {
        name = "dota_slippers_of_agility",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SLIPPERS_OF_AGILITY.GOLD),
			},
        },
    },
    -------------------------------------------------魔力法杖-------------------------------------------------
    {
        name = "dota_staff_of_wizardry",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.STAFF_OF_WIZARDRY.GOLD),
			},
        },
    },
    -------------------------------------------------食人魔之斧-------------------------------------------------
    {
        name = "dota_ogre_axe",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.OGRE_AXE.GOLD),
			},
        },
    },
    -------------------------------------------------铁树枝干-------------------------------------------------
    {
        name = "dota_iron_branch",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.IRON_BRANCH.GOLD),
			},
        },
    },
    -------------------------------------------------王冠-------------------------------------------------
    {
        name = "dota_crown",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.CROWN.GOLD),
			},
        },
    },
    -------------------------------------------------圆环-------------------------------------------------
    {
        name = "dota_circlet",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.CIRCLET.GOLD),
			},
        },
    },
    -------------------------------------------------智力斗篷-------------------------------------------------
    {
        name = "dota_mantle_of_intelligence",
        dotatype = "dota_attribute",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MANTLE_OF_INTELLIGENCE.GOLD),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------装备--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------标枪-------------------------------------------------
    {
        name = "dota_javelin",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.JAVELIN.GOLD),
			},
        },
    },
    -------------------------------------------------淬毒之珠-------------------------------------------------
    {
        name = "dota_orb_of_venom",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ORB_OF_VENOM.GOLD),
			},
        },
    },
    -------------------------------------------------大剑-------------------------------------------------
    {
        name = "dota_claymore",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.CLAYMORE.GOLD),
			},
        },
    },
    -------------------------------------------------短棍-------------------------------------------------
    {
        name = "dota_quarterstaff",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.QUARTERSTAFF.GOLD),
			},
        },
    },
    -------------------------------------------------攻击之爪-------------------------------------------------
    {
        name = "dota_blades_of_attack",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLADES_OF_ATTACK.GOLD),
			},
        },
    },
    -------------------------------------------------加速手套-------------------------------------------------
    {
        name = "dota_gloves_of_haste",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.GLOVES_OF_HASTE.GOLD),
			},
        },
    },
    -------------------------------------------------枯萎之石-------------------------------------------------
    {
        name = "dota_blight_stone",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLIGHT_STONE.GOLD),
			},
        },
    },
    -------------------------------------------------阔剑-------------------------------------------------
    {
        name = "dota_broadsword",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BROADSWORD.GOLD),
			},
        },
    },
    -------------------------------------------------秘银锤-------------------------------------------------
    {
        name = "dota_mithril_hammer",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MITHRIL_HAMMER.GOLD),
			},
        },
    },
    -------------------------------------------------凝魂之露-------------------------------------------------
    {
        name = "dota_infused_raindrop",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.INFUSED_RAINDROP.GOLD),
			},
        },
    },
    -------------------------------------------------闪电指套-------------------------------------------------
    {
        name = "dota_blitz_knuckles",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLITZ_KNUCKLES.GOLD),
			},
        },
    },
    -------------------------------------------------守护指环-------------------------------------------------
    {
        name = "dota_ring_of_protection",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.RING_OF_PROTECTION.GOLD),
			},
        },
    },
    -------------------------------------------------锁子甲-------------------------------------------------
    {
        name = "dota_chainmail",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.CHAINMAIL.GOLD),
			},
        },
    },
    -------------------------------------------------铁意头盔-------------------------------------------------
    {
        name = "dota_helm_of_iron_will",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HELM_OF_IRON_WILL.GOLD),
			},
        },
    },
    -------------------------------------------------压制之刃 or 补刀斧-------------------------------------------------
    {
        name = "dota_quelling_blade",
        dotatype = "dota_equipment",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.QUELLING_BLADE.GOLD),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------其他--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------暗影护符-------------------------------------------------
    {
        name = "dota_shadow_amulet",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SHADOW_AMULET.GOLD),
			},
        },
    },
    -------------------------------------------------风灵之纹-------------------------------------------------
    {
        name = "dota_wind_lace",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.WIND_LACE.GOLD),
			},
        },
    },
    -------------------------------------------------回复戒指-------------------------------------------------
    {
        name = "dota_ring_of_regen",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.RING_OF_REGEN.GOLD),
			},
        },
    },
    -------------------------------------------------抗魔斗篷-------------------------------------------------
    {
        name = "dota_cloak",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.CLOAK.GOLD),
			},
        },
    },
    -------------------------------------------------毛毛帽-------------------------------------------------
    {
        name = "dota_fluffy_hat",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.FLUFFY_HAT.GOLD),
			},
        },
    },
    -------------------------------------------------魔棒-------------------------------------------------
    {
        name = "dota_magic_stick",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MAGIC_STICK.GOLD),
			},
        },
    },
    -------------------------------------------------闪烁匕首 or 跳刀-------------------------------------------------
    {
        name = "dota_blink_dagger",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLINK_DAGGER.GOLD),
			},
        },
    },
    -------------------------------------------------速度之靴 or 鞋子-------------------------------------------------
    {
        name = "dota_boots_of_speed",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BOOTS_OF_SPEED.GOLD),
			},
        },
    },
    -------------------------------------------------巫毒面具-------------------------------------------------
    {
        name = "dota_voodoo_mask",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.VOODOO_MASK.GOLD),
			},
        },
    },
    -------------------------------------------------吸血面具-------------------------------------------------
    {
        name = "dota_morbid_mask",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MORBID_MASK.GOLD),
			},
        },
    },
    -------------------------------------------------贤者面罩-------------------------------------------------
    {
        name = "dota_sages_mask",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SAGES_MASK.GOLD),
			},
        },
    },
    -------------------------------------------------幽魂权杖 or 绿杖-------------------------------------------------
    {
        name = "dota_ghost_scepter",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.GHOST_SCEPTER.GOLD),
			},
        },
    },
    -------------------------------------------------真视宝石-------------------------------------------------
    {
        name = "dota_gem_of_true_sight",
        dotatype = "dota_other",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.GEM_OF_TRUE_SIGHT.GOLD),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    ------------------------------------------------神秘商店-------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------板甲-------------------------------------------------
    {
        name = "dota_platemail",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.PLATEMAIL.GOLD),
			},
        },
    },
    -------------------------------------------------恶魔刀锋-------------------------------------------------
    {
        name = "dota_demon_edge",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DEMON_EDGE.GOLD),
			},
        },
    },
    -------------------------------------------------活力之球-------------------------------------------------
    {
        name = "dota_vitality_booster",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.VITALITY_BOOSTER.GOLD),
			},
        },
    },
    -------------------------------------------------精气之球-------------------------------------------------
    {
        name = "dota_point_booster",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.POINT_BOOSTER.GOLD),
			},
        },
    },
    -------------------------------------------------能量之球-------------------------------------------------
    {
        name = "dota_energy_booster",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ENERGY_BOOSTER.GOLD),
			},
        },
    },
    -------------------------------------------------极限法球-------------------------------------------------
    {
        name = "dota_ultimate_orb",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ULTIMATE_ORB.GOLD),
			},
        },
    },
    -------------------------------------------------掠夺者之斧-------------------------------------------------
    {
        name = "dota_reaver",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.REAVER.GOLD),
			},
        },
    },
    -------------------------------------------------闪避护符-------------------------------------------------
    {
        name = "dota_talisman_of_evasion",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.TALISMAN_OF_EVASION.GOLD),
			},
        },
    },
    -------------------------------------------------神秘法杖-------------------------------------------------
    {
        name = "dota_mystic_staff",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MYSTIC_STAFF.GOLD),
			},
        },
    },
    -------------------------------------------------圣者遗物-------------------------------------------------
    {
        name = "dota_sacred_relic",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SACRED_RELIC.GOLD),
			},
        },
    },
    -------------------------------------------------虚无宝石-------------------------------------------------
    {
        name = "dota_void_stone",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.VOID_STONE.GOLD),
			},
        },
    },
    -------------------------------------------------治疗指环-------------------------------------------------
    {
        name = "dota_ring_of_health",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.RING_OF_HEALTH.GOLD),
			},
        },
    },
    -------------------------------------------------鹰歌弓-------------------------------------------------
    {
        name = "dota_eaglesong",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.EAGLESONG.GOLD),
			},
        },
    },
    -------------------------------------------------振奋宝石-------------------------------------------------
    {
        name = "dota_hyperstone",
        dotatype = "dota_mysteryshop",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HYPERSTONE.GOLD),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------配件--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    ------------------------------------------------动力鞋 or 假腿-------------------------------------------   
    -- CraftTabs:DoUpdateRecipes() 能不能让这个假腿可以有多种合成方法呢
    { 
        name = "dota_power_treads",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.POWER_TREADS.GOLD),
                Ingredient("dota_gloves_of_haste", 1,  "images/dota_equipment/dota_gloves_of_haste.xml"),
                Ingredient("dota_belt_of_strength", 1,  "images/dota_attribute/dota_belt_of_strength.xml"),
			},
        },
    },
    -------------------------------------------------疯狂面具-------------------------------------------------
    {
        name = "dota_mask_of_madness",
        dotatype = "dota_accessories",
        ingredients = {
			{   
				Ingredient("goldnugget", TUNING.DOTA.MASK_OF_MADNESS.GOLD),
                Ingredient("dota_morbid_mask", 1, "images/dota_other/dota_morbid_mask.xml"),
                Ingredient("dota_quarterstaff", 1, "images/dota_equipment/dota_quarterstaff.xml"),
			},
        },
    },
    -------------------------------------------------腐蚀之球-------------------------------------------------
    {
        name = "dota_orb_of_corrosion",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ORB_OF_CORROSION.GOLD),
                Ingredient("dota_orb_of_venom", 1, "images/dota_equipment/dota_orb_of_venom.xml"),
                Ingredient("dota_blight_stone", 1, "images/dota_equipment/dota_blight_stone.xml"),
                Ingredient("dota_fluffy_hat", 1, "images/dota_other/dota_fluffy_hat.xml"),
			},
        },
    },
    -------------------------------------------------护腕-------------------------------------------------
    {
        name = "dota_bracer",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BRACER.GOLD),
                Ingredient("dota_circlet", 1, "images/dota_attribute/dota_circlet.xml"),
                Ingredient("dota_gauntlets_of_strength", 1, "images/dota_attribute/dota_gauntlets_of_strength.xml"),
			},
        },
    },
    -------------------------------------------------坚韧球-------------------------------------------------
    {
        name = "dota_perseverance",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.PERSEVERANCE.GOLD),
                Ingredient("dota_ring_of_health", 1, "images/dota_mysteryshop/dota_ring_of_health.xml"),
                Ingredient("dota_void_stone", 1, "images/dota_mysteryshop/dota_void_stone.xml"),
			},
        },
    },
    -------------------------------------------------空灵挂件-------------------------------------------------
    {
        name = "dota_null_talisman",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.NULL_TALISMAN.GOLD),
                Ingredient("dota_circlet", 1, "images/dota_attribute/dota_circlet.xml"),
                Ingredient("dota_mantle_of_intelligence", 1, "images/dota_attribute/dota_mantle_of_intelligence.xml"),
			},
        },
    },
    -------------------------------------------------空明杖-------------------------------------------------
    {
        name = "dota_oblivion_staff",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.OBLIVION_STAFF.GOLD),
                Ingredient("dota_quarterstaff", 1, "images/dota_equipment/dota_quarterstaff.xml"),
                Ingredient("dota_sages_mask", 1, "images/dota_other/dota_sages_mask.xml"),
                Ingredient("dota_robe_of_the_magi", 1, "images/dota_attribute/dota_robe_of_the_magi.xml"),
			},
        },
    },
    -------------------------------------------------猎鹰战刃-------------------------------------------------
    {
        name = "dota_falcon_blade",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.FALCON_BLADE.GOLD),
                Ingredient("dota_sages_mask", 1, "images/dota_other/dota_sages_mask.xml"),
                Ingredient("dota_fluffy_hat", 1, "images/dota_other/dota_fluffy_hat.xml"),
                Ingredient("dota_blades_of_attack", 1, "images/dota_equipment/dota_blades_of_attack.xml"),
			},
        },
    },
    -------------------------------------------------灵魂之戒-------------------------------------------------
    {
        name = "dota_soul_ring",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SOUL_RING.GOLD),
                Ingredient("dota_ring_of_protection", 1,  "images/dota_equipment/dota_ring_of_protection.xml"),
                Ingredient("dota_gauntlets_of_strength", 2,  "images/dota_attribute/dota_gauntlets_of_strength.xml"),
			},
        },
    },
    -------------------------------------------------迈达斯之手 or 点金手-------------------------------------------------
    {
        name = "dota_hand_of_midas",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HAND_OF_MIDAS.GOLD),
                Ingredient("dota_gloves_of_haste", 1,  "images/dota_equipment/dota_gloves_of_haste.xml"),
			},
        },
    },
    -------------------------------------------------魔杖-------------------------------------------------
    {
        name = "dota_magic_wand",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MAGIC_WAND.GOLD),
                Ingredient("dota_magic_stick", 1,  "images/dota_other/dota_magic_stick.xml"),
                Ingredient("dota_iron_branch", 2,  "images/dota_attribute/dota_iron_branch.xml"),  
			},
        },
    },
    -------------------------------------------------统御头盔 or 大支配-------------------------------------------------
    {
        name = "dota_helm_of_the_overlord",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HELM_OF_THE_OVERLORD.GOLD),
                Ingredient("dota_helm_of_the_dominator", 1,  "images/dota_accessories/dota_helm_of_the_dominator.xml"),
                Ingredient("dota_vladmirs_offering", 1,  "images/dota_assisted/dota_vladmirs_offering.xml"),
			},
        },
    },
    -------------------------------------------------相位鞋-------------------------------------------------
    {
        name = "dota_phase_boots",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.PHASE_BOOTS.GOLD),
                Ingredient("dota_boots_of_speed", 1,  "images/dota_other/dota_boots_of_speed.xml"),
                Ingredient("dota_chainmail", 1,  "images/dota_equipment/dota_chainmail.xml"),
                Ingredient("dota_blades_of_attack", 1, "images/dota_equipment/dota_blades_of_attack.xml"),
			},
        },
    },
    -------------------------------------------------银月之晶-------------------------------------------------
    {
        name = "dota_moon_shard",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MOON_SHARD.GOLD),
                Ingredient("dota_hyperstone", 2,  "images/dota_mysteryshop/dota_hyperstone.xml"),
			},
        },
    },
    -------------------------------------------------远行鞋I or 飞鞋-------------------------------------------------
    {
        name = "dota_boots_of_travel_level1",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BOOTS_OF_TRAVEL_LEVEL1.GOLD),
                Ingredient("dota_boots_of_speed", 1,  "images/dota_other/dota_boots_of_speed.xml"),
			},
        },
    },
    -------------------------------------------------远行鞋II or 大飞鞋-------------------------------------------------
    {
        name = "dota_boots_of_travel_level2",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BOOTS_OF_TRAVEL_LEVEL2.GOLD),
                Ingredient("dota_boots_of_travel_level1", 1,  "images/dota_accessories/dota_boots_of_travel_level1.xml"),
			},
        },
    },
    -------------------------------------------------怨灵系带-------------------------------------------------
    {
        name = "dota_wraith_band",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.WRAITH_BAND.GOLD),
                Ingredient("dota_circlet", 1, "images/dota_attribute/dota_circlet.xml"),
                Ingredient("dota_slippers_of_agility", 1, "images/dota_attribute/dota_slippers_of_agility.xml"),
			},
        },
    },
    -------------------------------------------------支配头盔-------------------------------------------------
    {
        name = "dota_helm_of_the_dominator",
        dotatype = "dota_accessories",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HELM_OF_THE_DOMINATOR.GOLD),
                Ingredient("dota_helm_of_iron_will", 1, "images/dota_equipment/dota_helm_of_iron_will.xml"),
                Ingredient("dota_crown", 1, "images/dota_attribute/dota_crown.xml"),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------辅助--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------奥术鞋 or 秘法鞋-------------------------------------------------
    {
        name = "dota_arcane_boots",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ARCANE_BOOTS.GOLD),
                Ingredient("dota_boots_of_speed", 1,  "images/dota_other/dota_boots_of_speed.xml"),
                Ingredient("dota_energy_booster", 1,  "images/dota_mysteryshop/dota_energy_booster.xml"),
			},
        },
    },
    -------------------------------------------------洞察烟斗 or 笛子-------------------------------------------------
    {
        name = "dota_pipe_of_insight",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.PIPE_OF_INSIGHT.GOLD),
                Ingredient("dota_hood_of_defiance", 1,  "images/dota_protect/dota_hood_of_defiance.xml"),
                Ingredient("dota_headdress", 1,  "images/dota_assisted/dota_headdress.xml"),
			},
        },
    },
    -------------------------------------------------弗拉迪米尔的祭品-------------------------------------------------
    {
        name = "dota_vladmirs_offering",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.VLADMIRS_OFFERING.GOLD),
                Ingredient("dota_buckler", 1,  "images/dota_assisted/dota_buckler.xml"),
                Ingredient("dota_ring_of_basilius", 1,  "images/dota_assisted/dota_ring_of_basilius.xml"),
                Ingredient("dota_morbid_mask", 1,  "images/dota_other/dota_morbid_mask.xml"),
                Ingredient("dota_blades_of_attack", 1, "images/dota_equipment/dota_blades_of_attack.xml"),
            },
        },
    },
    -------------------------------------------------恢复头巾-------------------------------------------------
    {
        name = "dota_headdress",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HEADDRESS.GOLD),
                Ingredient("dota_ring_of_regen", 1,  "images/dota_other/dota_ring_of_regen.xml"),
			},
        },
    },
    -------------------------------------------------魂之灵瓮 or 大骨灰-------------------------------------------------
    {
        name = "dota_spirit_vessel",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SPIRIT_VESSEL.GOLD),
                Ingredient("dota_urn_of_shadows", 1,  "images/dota_assisted/dota_urn_of_shadows.xml"),
                Ingredient("dota_vitality_booster", 1,  "images/dota_mysteryshop/dota_vitality_booster.xml"),
			},
        },
    },
    -------------------------------------------------影之灵龛 or 骨灰-------------------------------------------------
    {
        name = "dota_urn_of_shadows",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.URN_OF_SHADOWS.GOLD),
                Ingredient("dota_sages_mask", 1, "images/dota_other/dota_sages_mask.xml"),
                Ingredient("dota_ring_of_protection", 1,  "images/dota_equipment/dota_ring_of_protection.xml"),
                Ingredient("dota_circlet", 1, "images/dota_attribute/dota_circlet.xml"),
			},
        },
    },
    -------------------------------------------------静谧之鞋 or 绿鞋-------------------------------------------------
    {
        name = "dota_tranquil_boots",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.TRANQUIL_BOOTS.GOLD),
                Ingredient("dota_boots_of_speed", 1,  "images/dota_other/dota_boots_of_speed.xml"),
                Ingredient("dota_wind_lace", 1,  "images/dota_other/dota_wind_lace.xml"),
                Ingredient("dota_ring_of_regen", 1,  "images/dota_other/dota_ring_of_regen.xml"),
			},
        },
    },
    -------------------------------------------------宽容之靴 or 大绿鞋-------------------------------------------------
    {
        name = "dota_boots_of_bearing",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BOOTS_OF_BEARING.GOLD),
                Ingredient("dota_tranquil_boots", 1,  "images/dota_assisted/dota_tranquil_boots.xml"),
                Ingredient("dota_drum_of_endurance", 1,  "images/dota_assisted/dota_drum_of_endurance.xml"),
			},
        },
    },
    -------------------------------------------------梅肯斯姆-------------------------------------------------
    {
        name = "dota_mekansm",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MEKANSM.GOLD),
                Ingredient("dota_headdress", 1,  "images/dota_assisted/dota_headdress.xml"),
                Ingredient("dota_chainmail", 1,  "images/dota_equipment/dota_chainmail.xml"),
			},
        },
    },
    -------------------------------------------------韧鼓-------------------------------------------------
    {
        name = "dota_drum_of_endurance",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DRUM_OF_ENDURANCE.GOLD),
                Ingredient("dota_gauntlets_of_strength", 1,  "images/dota_attribute/dota_gauntlets_of_strength.xml"),
                Ingredient("dota_robe_of_the_magi", 1,  "images/dota_attribute/dota_robe_of_the_magi.xml"),
                Ingredient("dota_wind_lace", 1,  "images/dota_other/dota_wind_lace.xml"),
            },
        },
    },
    -------------------------------------------------圣洁吊坠-------------------------------------------------
    {
        name = "dota_holy_locket",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HOLY_LOCKET.GOLD),
                Ingredient("dota_headdress", 1,  "images/dota_assisted/dota_headdress.xml"),
                Ingredient("dota_fluffy_hat", 1, "images/dota_other/dota_fluffy_hat.xml"),
                Ingredient("dota_energy_booster", 1,  "images/dota_mysteryshop/dota_energy_booster.xml"),
                Ingredient("dota_magic_wand", 1,  "images/dota_accessories/dota_magic_wand.xml"),
			},
        },
    },
    -------------------------------------------------王者之戒-------------------------------------------------
    {
        name = "dota_ring_of_basilius",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.RING_OF_BASILIUS.GOLD),
                Ingredient("dota_sages_mask", 1, "images/dota_other/dota_sages_mask.xml"),
			},
        },
    },
    -------------------------------------------------卫士胫甲 or 大鞋-------------------------------------------------
    {
        name = "dota_guardian_greaves",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.GUARDIAN_GREAVES.GOLD),
                Ingredient("dota_mekansm", 1, "images/dota_assisted/dota_mekansm.xml"),
                Ingredient("dota_arcane_boots", 1, "images/dota_assisted/dota_arcane_boots.xml"),
                Ingredient("dota_buckler", 1, "images/dota_assisted/dota_buckler.xml"),
			},
        },
    },
    -------------------------------------------------玄冥盾牌-------------------------------------------------
    {
        name = "dota_buckler",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BUCKLER.GOLD),
                Ingredient("dota_ring_of_protection", 1, "images/dota_equipment/dota_ring_of_protection.xml"),
			},
        },
    },
    -------------------------------------------------勇气勋章-------------------------------------------------
    {
        name = "dota_medallion_of_courage",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MEDALLION_OF_COURAGE.GOLD),
                Ingredient("dota_chainmail", 1,  "images/dota_equipment/dota_chainmail.xml"),
                Ingredient("dota_blight_stone", 1,  "images/dota_equipment/dota_blight_stone.xml"),
                Ingredient("dota_sages_mask", 1, "images/dota_other/dota_sages_mask.xml"),
			},
        },
    },
    -------------------------------------------------怨灵之契-------------------------------------------------
    {
        name = "dota_wraith_pact",
        dotatype = "dota_assisted",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.WRAITH_PACT.GOLD),
                Ingredient("dota_vladmirs_offering", 1,  "images/dota_assisted/dota_vladmirs_offering.xml"),
                Ingredient("dota_point_booster", 1,  "images/dota_mysteryshop/dota_point_booster.xml"),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------法器--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------eul的神圣法杖-------------------------------------------------
    {
        name = "dota_euls_scepter_of_divinity",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.EULS.GOLD),
                Ingredient("dota_staff_of_wizardry", 1,  "images/dota_attribute/dota_staff_of_wizardry.xml"),
                Ingredient("dota_void_stone", 1,  "images/dota_mysteryshop/dota_void_stone.xml"),
                Ingredient("dota_wind_lace", 1,  "images/dota_other/dota_wind_lace.xml"),
			},
        },
    },
    -------------------------------------------------阿哈利姆神杖-------------------------------------------------
    {
        name = "dota_aghanims_scepter",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.AGHANIMS_SCEPTER.GOLD),
                Ingredient("dota_point_booster", 1,  "images/dota_mysteryshop/dota_point_booster.xml"),
                Ingredient("dota_staff_of_wizardry", 1,  "images/dota_attribute/dota_staff_of_wizardry.xml"),
                Ingredient("dota_ogre_axe", 1,  "images/dota_attribute/dota_ogre_axe.xml"),
                Ingredient("dota_blade_of_alacrity", 1,  "images/dota_attribute/dota_blade_of_alacrity.xml"),
			},
        },
    },
    -------------------------------------------------阿托斯之棍-------------------------------------------------
    {
        name = "dota_rod_of_atos",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ROD_OF_ATOS.GOLD),
                Ingredient("dota_staff_of_wizardry", 1,  "images/dota_attribute/dota_staff_of_wizardry.xml"),
                Ingredient("dota_crown", 2,  "images/dota_attribute/dota_crown.xml"),
			},
        },
    },
    -------------------------------------------------达贡之神力1 or 大根-------------------------------------------------
    {
        name = "dota_dagon_level1",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DAGON_ENERGY.GOLD),
                Ingredient("dota_staff_of_wizardry", 1,  "images/dota_attribute/dota_staff_of_wizardry.xml"),
                Ingredient("dota_crown", 1,  "images/dota_attribute/dota_crown.xml"),
			},
        },
    },
    -------------------------------------------------达贡之神力2-------------------------------------------------
    {
        name = "dota_dagon_level2",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DAGON_ENERGY.GOLD),
                Ingredient("dota_dagon_level1", 1,  "images/dota_magic/dota_dagon_level1.xml"),
			},
        },
    },
    -------------------------------------------------达贡之神力3-------------------------------------------------
    {
        name = "dota_dagon_level3",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DAGON_ENERGY.GOLD),
                Ingredient("dota_dagon_level2", 1,  "images/dota_magic/dota_dagon_level2.xml"),
			},
        },
    },
    -------------------------------------------------达贡之神力4-------------------------------------------------
    {
        name = "dota_dagon_level4",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DAGON_ENERGY.GOLD),
                Ingredient("dota_dagon_level3", 1,  "images/dota_magic/dota_dagon_level3.xml"),
			},
        },
    },
    -------------------------------------------------达贡之神力5-------------------------------------------------
    {
        name = "dota_dagon_level5",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DAGON_ENERGY.GOLD),
                Ingredient("dota_dagon_level4", 1,  "images/dota_magic/dota_dagon_level4.xml"),
			},
        },
    },
    -------------------------------------------------纷争面纱-------------------------------------------------
    {
        name = "dota_veil_of_discord",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.VEIL_OF_DISCORD.GOLD),
                Ingredient("dota_crown", 1,  "images/dota_attribute/dota_crown.xml"),
                Ingredient("dota_ring_of_basilius", 1,  "images/dota_assisted/dota_ring_of_basilius.xml"),
			},
        },
    },
    -------------------------------------------------风之杖 or 大吹风-------------------------------------------------
    {
        name = "dota_wind_waker",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.WIND_WAKER.GOLD),
                Ingredient("dota_euls_scepter_of_divinity", 1,  "images/dota_magic/dota_euls_scepter_of_divinity.xml"),
                Ingredient("dota_mystic_staff", 1,  "images/dota_mysteryshop/dota_mystic_staff.xml"),
            },
        },
    },
    -------------------------------------------------缚灵索-------------------------------------------------
    {
        name = "dota_gleipnir",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.GLEIPNIR.GOLD),
                Ingredient("dota_maelstrom", 1,  "images/dota_precious/dota_maelstrom.xml"),
                Ingredient("dota_rod_of_atos", 1,  "images/dota_magic/dota_rod_of_atos.xml"),
			},
        },
    },
    -------------------------------------------------玲珑心-------------------------------------------------
    {
        name = "dota_octarine_core",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.OCTARINE_CORE.GOLD),
                Ingredient("dota_aether_lens", 1,  "images/dota_magic/dota_aether_lens.xml"),
                Ingredient("dota_soul_booster", 1,  "images/dota_protect/dota_soul_booster.xml"),
			},
        },
    },
    -------------------------------------------------刷新球-------------------------------------------------
    {
        name = "dota_refresher_orb",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.REFRESHER_ORB.GOLD),
                Ingredient("dota_perseverance", 2,  "images/dota_accessories/dota_perseverance.xml"),
			},
        },
    },
    -------------------------------------------------微光披风-------------------------------------------------
    {
        name = "dota_glimmer_cape",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.GLIMMER_CAPE.GOLD),
                Ingredient("dota_shadow_amulet", 1,  "images/dota_other/dota_shadow_amulet.xml"),
                Ingredient("dota_cloak", 1,  "images/dota_other/dota_cloak.xml"),
			},
        },
    },
    -------------------------------------------------巫师之刃-------------------------------------------------
    {
        name = "dota_witch_blade",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.WITCH_BLADE.GOLD),
                Ingredient("dota_blitz_knuckles", 1,  "images/dota_equipment/dota_blitz_knuckles.xml"),
                Ingredient("dota_robe_of_the_magi", 1,  "images/dota_attribute/dota_robe_of_the_magi.xml"),
                Ingredient("dota_chainmail", 1,  "images/dota_equipment/dota_chainmail.xml"),
			},
        },
    },
    -------------------------------------------------邪恶镰刀 or 羊刀-------------------------------------------------
    {
        name = "dota_scythe_of_vyse",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SCYTHE_OF_VYSE.GOLD),
                Ingredient("dota_mystic_staff", 1,  "images/dota_mysteryshop/dota_mystic_staff.xml"),
                Ingredient("dota_ultimate_orb", 1,  "images/dota_mysteryshop/dota_ultimate_orb.xml"),
                Ingredient("dota_void_stone", 1, "images/dota_mysteryshop/dota_void_stone.xml"),
			},
        },
    },
    -------------------------------------------------炎阳纹章 or 大勋章-------------------------------------------------
    {
        name = "dota_solar_crest",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SOLAR_CREST.GOLD),
                Ingredient("dota_medallion_of_courage", 1, "images/dota_assisted/dota_medallion_of_courage.xml"),
                Ingredient("dota_crown", 1, "images/dota_attribute/dota_crown.xml"),
                Ingredient("dota_wind_lace", 1,  "images/dota_other/dota_wind_lace.xml"),
			},
        },
    },
    -------------------------------------------------以太透镜-------------------------------------------------
    {
        name = "dota_aether_lens",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.AETHER_LENS.GOLD),
                Ingredient("dota_energy_booster", 1,  "images/dota_mysteryshop/dota_energy_booster.xml"),
                Ingredient("dota_void_stone", 1, "images/dota_mysteryshop/dota_void_stone.xml"),
			},
        },
    },
    -------------------------------------------------原力法杖 or 推推棒-------------------------------------------------
    {
        name = "dota_force_staff",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.FORCE_STAFF.GOLD),
                Ingredient("dota_staff_of_wizardry", 1,  "images/dota_attribute/dota_staff_of_wizardry.xml"),
                Ingredient("dota_fluffy_hat", 1, "images/dota_other/dota_fluffy_hat.xml"),
			},
        },
        -- 
        -- 
    },
    -------------------------------------------------紫怨-------------------------------------------------
    {
        name = "dota_orchid_malevolence",
        dotatype = "dota_magic",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ORCHID_MALEVOLENCE.GOLD),
                Ingredient("dota_blitz_knuckles", 1,  "images/dota_equipment/dota_blitz_knuckles.xml"),
                Ingredient("dota_claymore", 1,  "images/dota_equipment/dota_claymore.xml"),
                Ingredient("dota_void_stone", 1, "images/dota_mysteryshop/dota_void_stone.xml"),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------防具--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------赤红甲-------------------------------------------------
    {
        name = "dota_crimson_guard",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.CRIMSON_GUARD.GOLD),
                Ingredient("dota_vanguard", 1, "images/dota_protect/dota_vanguard.xml"),
                Ingredient("dota_helm_of_iron_will", 1, "images/dota_equipment/dota_helm_of_iron_will.xml"),
			},
        },
    },
    -------------------------------------------------黑黄杖-------------------------------------------------
    {
        name = "dota_black_king_bar",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLACK_KING_BAR.GOLD),
                Ingredient("dota_ogre_axe", 1,  "images/dota_attribute/dota_ogre_axe.xml"),
                Ingredient("dota_mithril_hammer", 1,  "images/dota_equipment/dota_mithril_hammer.xml"),
			},
        },
    },
    -------------------------------------------------幻影斧 or 分身斧-------------------------------------------------
    {
        name = "dota_manta_style",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MANTA_STYLE.GOLD),
                Ingredient("dota_yasha", 1,  "images/dota_precious/dota_yasha.xml"),
                Ingredient("dota_ultimate_orb", 1,  "images/dota_mysteryshop/dota_ultimate_orb.xml"),
			},
        },
    },
    -------------------------------------------------飓风长戟-------------------------------------------------
    {
        name = "dota_hurricane_pike",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HURRICANE_PIKE.GOLD),
                Ingredient("dota_force_staff", 1,  "images/dota_magic/dota_force_staff.xml"),
                Ingredient("dota_dragon_lance", 1,  "images/dota_precious/dota_dragon_lance.xml"),
			},
        },
    },
    -------------------------------------------------恐鳌之心-------------------------------------------------
    {
        name = "dota_heart_of_tarrasque",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HEART_OF_TARRASQUE.GOLD),
                Ingredient("dota_vitality_booster", 1,  "images/dota_mysteryshop/dota_vitality_booster.xml"),
                Ingredient("dota_reaver", 1,  "images/dota_mysteryshop/dota_reaver.xml"),
			},
        },
    },
    -------------------------------------------------林肯法球-------------------------------------------------
    {
        name = "dota_linkens_sphere",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.LINKENS_SPHERE.GOLD),
                Ingredient("dota_ultimate_orb", 1,  "images/dota_mysteryshop/dota_ultimate_orb.xml"),
                Ingredient("dota_perseverance", 1,  "images/dota_accessories/dota_perseverance.xml"),
			},
        },
    },
    -------------------------------------------------强袭胸甲-------------------------------------------------
    {
        name = "dota_assault_cuirass",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ASSAULT_CUIRASS.GOLD),
                Ingredient("dota_platemail", 1,  "images/dota_mysteryshop/dota_platemail.xml"),
                Ingredient("dota_hyperstone", 1,  "images/dota_mysteryshop/dota_hyperstone.xml"),
                Ingredient("dota_buckler", 1,  "images/dota_assisted/dota_buckler.xml"),
			},
        },
    },
    -------------------------------------------------清莲宝珠 or 莲花-------------------------------------------------
    {
        name = "dota_lotus_orb",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.LOTUS_ORB.GOLD),
                Ingredient("dota_perseverance", 1,  "images/dota_accessories/dota_perseverance.xml"),
                Ingredient("dota_platemail", 1,  "images/dota_mysteryshop/dota_platemail.xml"),
                Ingredient("dota_energy_booster", 1,  "images/dota_mysteryshop/dota_energy_booster.xml"),
			},
        },
    },
    -------------------------------------------------刃甲-------------------------------------------------
    {
        name = "dota_blade_mail",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLADE_MAIL.GOLD),
                Ingredient("dota_broadsword", 1,  "images/dota_equipment/dota_broadsword.xml"),
                Ingredient("dota_chainmail", 1,  "images/dota_equipment/dota_chainmail.xml"),
			},
        },
    },
    -------------------------------------------------挑战头巾-------------------------------------------------
    {
        name = "dota_hood_of_defiance",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HOOD_OF_DEFIANCE.GOLD),
                Ingredient("dota_ring_of_health", 1,  "images/dota_mysteryshop/dota_ring_of_health.xml"),
                Ingredient("dota_cloak", 1,  "images/dota_other/dota_cloak.xml"),
                Ingredient("dota_ring_of_regen", 1,  "images/dota_other/dota_ring_of_regen.xml"),
			},
        },
    },
    -------------------------------------------------希瓦的守护 or 冰甲-------------------------------------------------
    {
        name = "dota_shivas_guard",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SHIVAS_GUARD.GOLD),
                Ingredient("dota_platemail", 1,  "images/dota_mysteryshop/dota_platemail.xml"),
                Ingredient("dota_mystic_staff", 1,  "images/dota_mysteryshop/dota_mystic_staff.xml"),
			},
        },
    },
    -------------------------------------------------先锋盾-------------------------------------------------
    {
        name = "dota_vanguard",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.VANGUARD.GOLD),
                Ingredient("dota_ring_of_health", 1, "images/dota_mysteryshop/dota_ring_of_health.xml"),
                Ingredient("dota_vitality_booster", 1,  "images/dota_mysteryshop/dota_vitality_booster.xml"),
			},
        },
    },
    -------------------------------------------------血精石-------------------------------------------------
    {
        name = "dota_bloodstone",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLOODSTONE.GOLD),
                Ingredient("dota_voodoo_mask", 1,  "images/dota_other/dota_voodoo_mask.xml"),
                Ingredient("dota_soul_booster", 1,  "images/dota_protect/dota_soul_booster.xml"),
			},
        },
    },
    -------------------------------------------------永恒之盘 or 盘子-------------------------------------------------
    {
        name = "dota_aeon_disk",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.AEON_DISK.GOLD),
                Ingredient("dota_vitality_booster", 1,  "images/dota_mysteryshop/dota_vitality_booster.xml"),
                Ingredient("dota_energy_booster", 1,  "images/dota_mysteryshop/dota_energy_booster.xml"),
			},
        },
    },
    -------------------------------------------------永世法衣-------------------------------------------------
    {
        name = "dota_eternal_shroud",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SHROUD.GOLD),
                Ingredient("dota_voodoo_mask", 1,  "images/dota_other/dota_voodoo_mask.xml"),
                Ingredient("dota_hood_of_defiance", 1,  "images/dota_protect/dota_hood_of_defiance.xml"),
			},
        },
    },
    -------------------------------------------------振魂石-------------------------------------------------
    {
        name = "dota_soul_booster",
        dotatype = "dota_protect",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SOUL_BOOSTER.GOLD),
                Ingredient("dota_vitality_booster", 1,  "images/dota_mysteryshop/dota_vitality_booster.xml"),
                Ingredient("dota_energy_booster", 1,  "images/dota_mysteryshop/dota_energy_booster.xml"),
                Ingredient("dota_point_booster", 1,  "images/dota_mysteryshop/dota_point_booster.xml"),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------兵刃--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------黯灭-------------------------------------------------
    {
        name = "dota_desolator",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DESOLATOR.GOLD),
                Ingredient("dota_blight_stone", 1, "images/dota_equipment/dota_blight_stone.xml"),
                Ingredient("dota_mithril_hammer", 2,  "images/dota_equipment/dota_mithril_hammer.xml"),
			},
        },
    },
    -------------------------------------------------白银之锋-------------------------------------------------
    {
        name = "dota_silver_edge",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SILVER_EDGE.GOLD),
                Ingredient("dota_invis_sword", 1,  "images/dota_weapon/dota_invis_sword.xml"),
                Ingredient("dota_crystalys", 1,  "images/dota_weapon/dota_crystalys.xml"),
			},
        },
    },
    -------------------------------------------------代达罗斯之殇 or 大炮-------------------------------------------------
    {
        name = "dota_daedalus",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DAEDALUS.GOLD),
                Ingredient("dota_crystalys", 1,  "images/dota_weapon/dota_crystalys.xml"),
                Ingredient("dota_demon_edge", 1,  "images/dota_mysteryshop/dota_demon_edge.xml"),
			},
        },
    },
    -------------------------------------------------否决坠饰-------------------------------------------------
    {
        name = "dota_nullifier",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.NULLIFIER.GOLD),
                Ingredient("dota_sacred_relic", 1,  "images/dota_mysteryshop/dota_sacred_relic.xml"),
                Ingredient("dota_helm_of_iron_will", 1, "images/dota_equipment/dota_helm_of_iron_will.xml"),
			},
        },
    },
    -------------------------------------------------蝴蝶-------------------------------------------------
    {
        name = "dota_butterfly",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BUTTERFLY.GOLD),
                Ingredient("dota_eaglesong", 1, "images/dota_mysteryshop/dota_eaglesong.xml"),
                Ingredient("dota_talisman_of_evasion", 1, "images/dota_mysteryshop/dota_talisman_of_evasion.xml"),
                Ingredient("dota_quarterstaff", 1, "images/dota_equipment/dota_quarterstaff.xml"),
			},
        },
    },
    -------------------------------------------------辉耀-------------------------------------------------
    {
        name = "dota_radiance",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.RADIANCE.GOLD),
                Ingredient("dota_sacred_relic", 1,  "images/dota_mysteryshop/dota_sacred_relic.xml"),
                Ingredient("dota_talisman_of_evasion", 1, "images/dota_mysteryshop/dota_talisman_of_evasion.xml"),
			},
        },
    },
    -------------------------------------------------金箍棒-------------------------------------------------
    {
        name = "dota_monkey_king_bar",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MONKEY_KING_BAR.GOLD),
                Ingredient("dota_demon_edge", 1,  "images/dota_mysteryshop/dota_demon_edge.xml"),
                Ingredient("dota_javelin", 1,  "images/dota_equipment/dota_javelin.xml"),
                Ingredient("dota_blitz_knuckles", 1,  "images/dota_equipment/dota_blitz_knuckles.xml"),
			},
        },
    },
    -------------------------------------------------狂战斧-------------------------------------------------
    {
        name = "dota_battle_fury",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BATTLE_FURY.GOLD),
                Ingredient("dota_broadsword", 1,  "images/dota_equipment/dota_broadsword.xml"),
                Ingredient("dota_claymore", 1,  "images/dota_equipment/dota_claymore.xml"),
                Ingredient("dota_quelling_blade", 1,  "images/dota_equipment/dota_quelling_blade.xml"),
                Ingredient("dota_perseverance", 1,  "images/dota_accessories/dota_perseverance.xml"),
			},
        },
    },
    -------------------------------------------------莫尔迪基安的臂章-------------------------------------------------
    {
        name = "dota_armlet_of_mordiggian",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ARMLET.GOLD),
                Ingredient("dota_helm_of_iron_will", 1, "images/dota_equipment/dota_helm_of_iron_will.xml"),
                Ingredient("dota_gloves_of_haste", 1, "images/dota_equipment/dota_gloves_of_haste.xml"),
                Ingredient("dota_blades_of_attack", 1, "images/dota_equipment/dota_blades_of_attack.xml"),
			},
        },
    },
    -------------------------------------------------深渊之刃 or 大晕-------------------------------------------------
    {
        name = "dota_abyssal_blade",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ABYSSAL_BLADE.GOLD),
                Ingredient("dota_skull_basher", 1, "images/dota_weapon/dota_skull_basher.xml"),
                Ingredient("dota_vanguard", 1, "images/dota_protect/dota_vanguard.xml"),
			},
        },
    },
    -------------------------------------------------圣剑-------------------------------------------------
    {
        name = "dota_divine_rapier",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DIVINE_RAPIER.GOLD),
                Ingredient("dota_sacred_relic", 1,  "images/dota_mysteryshop/dota_sacred_relic.xml"),
                Ingredient("dota_demon_edge", 1,  "images/dota_mysteryshop/dota_demon_edge.xml"),
			},
        },
    },
    -------------------------------------------------水晶剑-------------------------------------------------
    {
        name = "dota_crystalys",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.CRYSTALYS.GOLD),
                Ingredient("dota_broadsword", 1,  "images/dota_equipment/dota_broadsword.xml"),
                Ingredient("dota_blades_of_attack", 1, "images/dota_equipment/dota_blades_of_attack.xml"),
			},
        },
    },
    -------------------------------------------------碎颅锤 or 晕锤-------------------------------------------------
    {
        name = "dota_skull_basher",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SKULL_BASHER.GOLD),
                Ingredient("dota_mithril_hammer", 1,  "images/dota_equipment/dota_mithril_hammer.xml"),
                Ingredient("dota_belt_of_strength", 1,  "images/dota_attribute/dota_belt_of_strength.xml"),
			},
        },
    },
    -------------------------------------------------虚灵之刃-------------------------------------------------
    {
        name = "dota_ethereal_blade",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ETHEREAL_BLADE.GOLD),
                Ingredient("dota_kaya", 1,  "images/dota_precious/dota_kaya.xml"),
                Ingredient("dota_ghost_scepter", 1,  "images/dota_other/dota_ghost_scepter.xml"),
			},
        },
    },
    -------------------------------------------------血棘 or 大紫怨-------------------------------------------------
    {
        name = "dota_bloodthorn",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.BLOODTHORN.GOLD),
                Ingredient("dota_orchid_malevolence", 1,  "images/dota_magic/dota_orchid_malevolence.xml"),
                Ingredient("dota_mage_slayer", 1,  "images/dota_precious/dota_mage_slayer.xml"),
			},
        },
    },
    -------------------------------------------------英灵胸针-------------------------------------------------
    {
        name = "dota_revenants_brooch",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.REVENANTS_BROOCH.GOLD),
                Ingredient("dota_witch_blade", 1,  "images/dota_magic/dota_witch_blade.xml"),
                Ingredient("dota_mystic_staff", 1,  "images/dota_mysteryshop/dota_mystic_staff.xml"),
			},
        },
    },
    -------------------------------------------------隐刀-------------------------------------------------
    {
        name = "dota_invis_sword",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.INVIS_SWORD.GOLD),
                Ingredient("dota_shadow_amulet", 1,  "images/dota_other/dota_shadow_amulet.xml"),
                Ingredient("dota_blitz_knuckles", 1,  "images/dota_equipment/dota_blitz_knuckles.xml"),
                Ingredient("dota_broadsword", 1,  "images/dota_equipment/dota_broadsword.xml"),
			},
        },
    },
    -------------------------------------------------陨星锤-------------------------------------------------
    {
        name = "dota_meteor_hammer",
        dotatype = "dota_weapon",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.METEOR_HAMMER.GOLD),
                Ingredient("dota_perseverance", 2,  "images/dota_accessories/dota_perseverance.xml"),
                Ingredient("dota_crown", 1, "images/dota_attribute/dota_crown.xml"),
			},
        },
    },
    --------------------------------------------------------------------------------------------------------
    --------------------------------------------------宝物--------------------------------------------------
    --------------------------------------------------------------------------------------------------------
    -------------------------------------------------法师克星-------------------------------------------------
    {
        name = "dota_mage_slayer",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MAGE_SLAYER.GOLD),
                Ingredient("dota_cloak", 1,  "images/dota_other/dota_cloak.xml"),
                Ingredient("dota_oblivion_staff", 1,  "images/dota_accessories/dota_oblivion_staff.xml"),
			},
        },
    },
    -------------------------------------------------回音战刃 or 连击刀-------------------------------------------------
    {
        name = "dota_echo_sabre",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ECHO_SABRE.GOLD),
                Ingredient("dota_oblivion_staff", 1,  "images/dota_accessories/dota_oblivion_staff.xml"),
                Ingredient("dota_ogre_axe", 1,  "images/dota_attribute/dota_ogre_axe.xml"),
			},
        },
    },
    -------------------------------------------------斯嘉蒂之眼  or 冰眼-------------------------------------------------
    {
        name = "dota_eye_of_skadi",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.EYE_OF_SKADI.GOLD),
                Ingredient("dota_ultimate_orb", 2,  "images/dota_mysteryshop/dota_ultimate_orb.xml"),
                Ingredient("dota_point_booster", 1,  "images/dota_mysteryshop/dota_point_booster.xml"),   
			},
        },
    },
    -------------------------------------------------天堂之戟-------------------------------------------------
    {
        name = "dota_heavens_halberd",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.HEAVENS_HALBERD.GOLD),
                Ingredient("dota_sange", 1,  "images/dota_precious/dota_sange.xml"),   
                Ingredient("dota_talisman_of_evasion", 1, "images/dota_mysteryshop/dota_talisman_of_evasion.xml"),
			},
        },
    },
    -------------------------------------------------魔龙枪-------------------------------------------------
    {
        name = "dota_dragon_lance",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DRAGON_LANCE.GOLD),
                Ingredient("dota_blade_of_alacrity", 1,  "images/dota_attribute/dota_blade_of_alacrity.xml"),
                Ingredient("dota_belt_of_strength", 1,  "images/dota_attribute/dota_belt_of_strength.xml"),
			},
        },
    },
    -------------------------------------------------撒旦之邪力 or 大吸-------------------------------------------------
    {
        name = "dota_satanic",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SATANIC.GOLD),
                Ingredient("dota_morbid_mask", 1, "images/dota_other/dota_morbid_mask.xml"),
                Ingredient("dota_claymore", 1,  "images/dota_equipment/dota_claymore.xml"),
                Ingredient("dota_reaver", 1,  "images/dota_mysteryshop/dota_reaver.xml"),
			},
        },
    },
    -------------------------------------------------净魂之刃 or 散失-------------------------------------------------
    {
        name = "dota_diffusal_blade",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.DIFFUSAL_BLADE.GOLD),
                Ingredient("dota_blade_of_alacrity", 1,  "images/dota_attribute/dota_blade_of_alacrity.xml"),
                Ingredient("dota_robe_of_the_magi", 1, "images/dota_attribute/dota_robe_of_the_magi.xml"),
			},
        },
    },
    -------------------------------------------------漩涡 or 电锤-------------------------------------------------
    {
        name = "dota_maelstrom",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MAELSTORM.GOLD),
                Ingredient("dota_mithril_hammer", 1,  "images/dota_equipment/dota_mithril_hammer.xml"),
                Ingredient("dota_javelin", 1,  "images/dota_equipment/dota_javelin.xml"),
			},
        },
    },
    -------------------------------------------------雷神之锤 or 大雷锤 or 大电锤-------------------------------------------------
    {
        name = "dota_mjollnir",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.MJOLLNIR.GOLD),
                Ingredient("dota_maelstrom", 1,  "images/dota_precious/dota_maelstrom.xml"),
                Ingredient("dota_hyperstone", 1,  "images/dota_mysteryshop/dota_hyperstone.xml"),
			},
        },
    },
    -------------------------------------------------慧光-------------------------------------------------
    {
        name = "dota_kaya",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.KAYA.GOLD),
                Ingredient("dota_staff_of_wizardry", 1,  "images/dota_attribute/dota_staff_of_wizardry.xml"),
                Ingredient("dota_robe_of_the_magi", 1, "images/dota_attribute/dota_robe_of_the_magi.xml"),
			},
        },
    },
    -------------------------------------------------散华-------------------------------------------------
    {
        name = "dota_sange",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SANGE.GOLD),
                Ingredient("dota_ogre_axe", 1,  "images/dota_attribute/dota_ogre_axe.xml"),
                Ingredient("dota_belt_of_strength", 1,  "images/dota_attribute/dota_belt_of_strength.xml"),
			},
        },
    },
    -------------------------------------------------夜叉-------------------------------------------------
    {
        name = "dota_yasha",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.YASHA.GOLD),
                Ingredient("dota_blade_of_alacrity", 1,  "images/dota_attribute/dota_blade_of_alacrity.xml"),
                Ingredient("dota_band_of_elvenskin", 1,  "images/dota_attribute/dota_band_of_elvenskin.xml"),
			},
        },
    },
    -------------------------------------------------慧夜对剑-------------------------------------------------
    {
        name = "dota_yasha_and_kaya",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.YASHA_AND_KAYA.GOLD),
                Ingredient("dota_yasha", 1,  "images/dota_precious/dota_yasha.xml"),
                Ingredient("dota_kaya", 1,  "images/dota_precious/dota_kaya.xml"),
			},
        },
    },
    -------------------------------------------------散慧对剑-------------------------------------------------
    {
        name = "dota_kaya_and_sange",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.KAYA_AND_SANGE.GOLD),
                Ingredient("dota_sange", 1,  "images/dota_precious/dota_sange.xml"),
                Ingredient("dota_kaya", 1,  "images/dota_precious/dota_kaya.xml"),
			},
        },
    },
    -------------------------------------------------散夜对剑-------------------------------------------------
    {
        name = "dota_sange_and_yasha",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SANGE_AND_YASHA.GOLD),
                Ingredient("dota_yasha", 1,  "images/dota_precious/dota_yasha.xml"),
                Ingredient("dota_sange", 1,  "images/dota_precious/dota_sange.xml"),
			},
        },
    },
    -------------------------------------------------迅疾闪光-------------------------------------------------
    {
        name = "dota_swift_blink",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.SWIFT_BLINK.GOLD),
                Ingredient("dota_blink_dagger", 1,  "images/dota_other/dota_blink_dagger.xml"),
                Ingredient("dota_eaglesong", 1, "images/dota_mysteryshop/dota_eaglesong.xml"),
			},
        },
    },
    -------------------------------------------------秘奥闪光-------------------------------------------------
    {
        name = "dota_arcane_blink",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.ARCANE_BLINK.GOLD),
                Ingredient("dota_blink_dagger", 1,  "images/dota_other/dota_blink_dagger.xml"),
                Ingredient("dota_mystic_staff", 1,  "images/dota_mysteryshop/dota_mystic_staff.xml"),
			},
        },
    },
    -------------------------------------------------盛势闪光-------------------------------------------------
    {
        name = "dota_overwhelming_blink",
        dotatype = "dota_precious",
        ingredients = {
			{
				Ingredient("goldnugget", TUNING.DOTA.OVERWHELMING_BLINK.GOLD),
                Ingredient("dota_blink_dagger", 1,  "images/dota_other/dota_blink_dagger.xml"),
                Ingredient("dota_reaver", 1,  "images/dota_mysteryshop/dota_reaver.xml"),
			},
        },
    },
}

--------------------------------------------------------------------------------------------------------------
-----------------------------------------------自定义分解配方表------------------------------------------------
--------------------------------------------------------------------------------------------------------------

local dota_deconstructrecipes ={
    -------------------------------------------------疯狂面具-------------------------------------------------
    {
        name = "dota_mask_of_madness",
        ingredients = {
            {
                Ingredient("dota_morbid_mask", 1),
                Ingredient("dota_quarterstaff", 1),
            },
        },
    },
    -------------------------------------------------坚韧球-------------------------------------------------
    {
        name = "dota_perseverance",
        ingredients = {
			{
                Ingredient("dota_ring_of_health", 1),
                Ingredient("dota_void_stone", 1),
			},
        },
    },
     -------------------------------------------------奥术鞋 or 秘法鞋-------------------------------------------------
     {
        name = "dota_arcane_boots",
        ingredients = {
			{
                Ingredient("dota_boots_of_speed", 1),
                Ingredient("dota_energy_booster", 1),
			},
        },
    },
    -------------------------------------------------回音战刃 or 连击刀-------------------------------------------------
    {
        name = "dota_echo_sabre",
        ingredients = {
            {
                Ingredient("dota_oblivion_staff", 1),
                Ingredient("dota_ogre_axe", 1),
            },
        },
    },    
    -------------------------------------------------天堂之戟-------------------------------------------------
    {
        name = "dota_heavens_halberd",
        ingredients = {
			{
                Ingredient("dota_sange", 1),   
                Ingredient("dota_talisman_of_evasion", 1),
			},
        },
    },   
    -------------------------------------------------清莲宝珠 or 莲花-------------------------------------------------
    {
        name = "dota_lotus_orb",
        ingredients = {
            {
                Ingredient("dota_perseverance", 1),
                Ingredient("dota_platemail", 1),
                Ingredient("dota_energy_booster", 1),
            },
        },
    },
    -------------------------------------------------玲珑心-------------------------------------------------
    {
        name = "dota_octarine_core",
        ingredients = {
            {
                Ingredient("dota_aether_lens", 1),
                Ingredient("dota_soul_booster", 1),
            },
        },
    },
    -------------------------------------------------辉耀-------------------------------------------------
    {
        name = "dota_radiance",
        ingredients = {
            {
                Ingredient("dota_sacred_relic", 1),
                Ingredient("dota_talisman_of_evasion", 1),
            },
        },
    },
    -------------------------------------------------先锋盾-------------------------------------------------
    {
        name = "dota_vanguard",
        ingredients = {
            {
                Ingredient("dota_ring_of_health", 1),
                Ingredient("dota_vitality_booster", 1),
            },
        },
    },
    -------------------------------------------------魔龙枪-------------------------------------------------
    {
        name = "dota_dragon_lance",
        ingredients = {
            {
                Ingredient("dota_blade_of_alacrity", 1),
                Ingredient("dota_belt_of_strength", 1),
            },
        },
    },
    -------------------------------------------------虚灵之刃-------------------------------------------------
    {
        name = "dota_ethereal_blade",
        ingredients = {
            {
                Ingredient("dota_kaya", 1),
                Ingredient("dota_ghost_scepter", 1),
            },
        },
    },
    -------------------------------------------------慧夜对剑-------------------------------------------------
    {
        name = "dota_yasha_and_kaya",
        ingredients = {
            {
                Ingredient("dota_yasha", 1),
                Ingredient("dota_kaya", 1),
            },
        },
    },
    -------------------------------------------------散慧对剑-------------------------------------------------
    {
        name = "dota_kaya_and_sange",
        ingredients = {
            {
                Ingredient("dota_sange", 1),
                Ingredient("dota_kaya", 1),
            },
        },
    },
    -------------------------------------------------散夜对剑-------------------------------------------------
    {
        name = "dota_sange_and_yasha",
        ingredients = {
            {
                Ingredient("dota_yasha", 1),
                Ingredient("dota_sange", 1),
            },
        },
    },
}

return {
	Recipes = dota_recipes,
	DeconstructRecipes = dota_deconstructrecipes,
}