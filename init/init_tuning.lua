TUNING = GLOBAL.TUNING

local seg_time = TUNING.SEG_TIME--一格时间，默认30秒
local day_segs = TUNING.DAY_SEGS_DEFAULT--白天时间，10格，5分钟
local dusk_segs = TUNING.DUSK_SEGS_DEFAULT--傍晚时间，4格，2分钟
local night_segs = TUNING.NIGHT_SEGS_DEFAULT--夜晚时间，2格，1分钟
local total_day_time = TUNING.TOTAL_DAY_TIME--一天时间，16格，8分钟	-- = seg_time*16
local wilson_health=TUNING.WILSON_HEALTH--威尔逊血量，150
local multiplayer_armor_absorption_modifier = TUNING.MULTIPLAYER_ARMOR_ABSORPTION_MODIFIER
local day_time = seg_time * day_segs
local dusk_time = seg_time * dusk_segs
local night_time = seg_time * night_segs

local stack_size = TUNING.STACK_SIZE_LARGEITEM	-- 奇妙的stack_size，限定那几个参数

local language = GetModConfigData("language") or "AUTO"
if language == "AUTO" then
    language = locale ~= nil and locale ~= "zh" and locale ~= "zhr" and locale ~= "zht" and "EN" or "ZH"
end

local HEALTH_SYSTEM = GetModConfigData("health_system") or true
local ATTRIBUTES_SYSTEM = GetModConfigData("attributes_system") or 1

local BASE_VOICE_VOLUME = GetModConfigData("volume") or 0.5
local DSTRECIPES_MODE = GetModConfigData("recipes_mode") or false
local UI_DRAG = GetModConfigData("ui_drag") or true
local HEALTH_COMPATIBILITY = GetModConfigData("health_compatibility_deafultmode") or 2
local RECHARGEMOD = GetModConfigData("rechargemod") or false
local SPEED_SYSTEM = GetModConfigData("speed_system") or true

local gold_ratio = GetModConfigData("gold_ratio") or 0.1
local extradamage_ratio = GetModConfigData("extradamage_ratio") or 0.5
local extrahealth_ratio = GetModConfigData("extrahealth_ratio") or 0.05
local healthregen_ratio = GetModConfigData("healthregen_ratio") or 0.05
local spellrange_ratio = GetModConfigData("spellrange_ratio") or 0.01
local duration_ratio = GetModConfigData("duration_ratio") or 1
local range_ratio = GetModConfigData("range_ratio") or 0.01
local cd_ratio = GetModConfigData("cd_ratio") or 1
local extraspeed_ratio = GetModConfigData("extraspeed_ratio") or 0.01
local attackspeed_ratio = GetModConfigData("attackspeed_ratio") or 0.005
local lifesteal_ratio = GetModConfigData("lifesteal_ratio") or 0.1

local handofmidas_cdplus = GetModConfigData("hand_of_midas_cdplus") or 1
local handofmidas_limit = GetModConfigData("hand_of_midas_limit") or 110
local blinkdagger_cdplus = GetModConfigData("blink_dagger_cdplus") or 1
local tpscroll_cdplus = GetModConfigData("tpscroll_cdplus") or 1
local bananalimit = GetModConfigData("bottle_bananalimit") or 1

local debug_optional = GetModConfigData("debug_optional") or false

local DOTATUNING = {
--首选项
	LANGUAGE = LANGUAGE,
	-- MONSTER_ATTRIBUTES = 1,
	DSTRECIPES_MODE = DSTRECIPES_MODE,
	BASE_VOICE_VOLUME = BASE_VOICE_VOLUME,
	UI_DRAG = UI_DRAG,
	SHARINGCD = RECHARGEMOD,
	ISDEBUG = debug_optional,
--人物属性系统
	HEALTH_SYSTEM = HEALTH_SYSTEM,
	ATTRIBUTES_SYSTEM = ATTRIBUTES_SYSTEM,
	SPEED_SYSTEM = SPEED_SYSTEM,
	HEALTH_COMPATIBILITY = HEALTH_COMPATIBILITY,			-- 生命系统兼容性选择
	BASEMANA = 100,		-- 玩家基础蓝量
--生命魔法回复
	HEALTH_REGEN_INTERVAL = seg_time/6,-- 生命恢复间隔
	HEALTH_REGEN_TOTALTIME = total_day_time, -- 生命回复的数值在多长时间内达到
	MANA_REGEN_INTERVAL = seg_time/6,	-- 魔法恢复间隔
	MANA_REGEN_TOTALTIME = seg_time/1, -- 魔法回复的数值在多长时间内达到
	EQUIPMENT_COOLDOWN = 6,				-- 装备后增加cd
--各类系数
	RATIO ={
		GOLD = gold_ratio,
		EXTRADAMAGE = extradamage_ratio,
		EXTRAHEALTH = extrahealth_ratio,
		HEALTHREGEN = healthregen_ratio,
		SPELLRANGE = spellrange_ratio,
		DURATION = duration_ratio,
		RANGE = range_ratio,
		CD = cd_ratio,
		EXTRASPEED = extraspeed_ratio,
		ATTACKSPEED = attackspeed_ratio,
	},
--------------------------------------------------------------------------------------------
--------------------------------------------装备参数-----------------------------------------
--------------------------------------------------------------------------------------------

---------------------------------消耗品-----------------------------
--回城卷轴
	TOWN_PORTAL_SCROLL = {
		GOLD = 100 * gold_ratio,		-- 价格
		MAXSIZE = stack_size,		-- 最大堆叠
		MANA = 75,		-- 花费的魔法值
		CD = 80 * cd_ratio * tpscroll_cdplus,			-- 使用CD
	},
--净化药水 or 小蓝
	CLARITY_CAST = {
		GOLD = 50 * gold_ratio,				-- 价格
		MAXSIZE = stack_size,			-- 最大堆叠
		SPELLRANGE = 250 * spellrange_ratio,			-- 施法范围
		DURATION = 25 * duration_ratio,				-- 持续时间
		MANA_REGEN = 6,				-- 恢复速率
		MANA_REGEN_INTERVAL = 1,
	},
--仙灵之火
	FAERIE_FIRE = {
		GOLD = 50 * gold_ratio,
		HEALTH = 85 * extrahealth_ratio * 2,	-- 恢复血量 (default-85)
		CD = 5 * cd_ratio,					-- 食用间隔
	},
--侦查守卫
	OBSERVER_WARD = {
		GOLD = 0 * gold_ratio,
		DURATION = 6 * 60 * duration_ratio,		-- 持续时间
	},
--岗哨守卫
	SENTRY_WARD = {
		GOLD = 50 * gold_ratio,
		DURATION = 7 * 60 * duration_ratio,
	},
--诡计之雾		
	SMOKE_OF_DECEIT = {
		GOLD = 50 * gold_ratio,			-- 价格
		RANGE = 1200 * range_ratio,		-- 生效距离
		DURATION = 35 * duration_ratio,		-- 持续时间
		SPEEDMULTI = 0.15,	-- 速度加成
		ENEMYRANGE = 1025 * range_ratio,	-- 破雾距离
	},
--阿哈利姆魔晶
	AGHANIMS_SHARD = {
		GOLD = 1400 * gold_ratio,
	},
--魔法芒果
	ENCHANTED_MANGO = {
		GOLD = 65 * gold_ratio,
		MANA = 100,			-- 食用恢复的魔法值
		MAXSIZE = stack_size,		-- 最大堆叠数量
		HEALTHREGEN = 0.3 * healthregen_ratio,	-- 生命恢复速率
	},
--魔瓶 or 瓶子
	BOTTLE = {
		GOLD = 675 * gold_ratio,
		BANANALIMIT = bananalimit,
		REGENERATE = {
			HEALTH = 115 * extrahealth_ratio,		-- 使用回复生命
			MANA = 65,					-- 使用回复魔法
			DURATION = 2.5 * duration_ratio,				-- 生效时间
			INTERVAL = 0.5 * duration_ratio,
			CD = 0.5 * cd_ratio,
		},
		RUNE = {
			ARCANE = {
				DURATION = 50 * duration_ratio,
				REDUCTION = 0.3,
				MANACOST = 0.3,
			},
			BOUNTY = {
				GOLD = 36 * gold_ratio,
				ADDPERDAY = 9 * gold_ratio,
			},
			DOUBLE = {
				DURATION = 45 * duration_ratio,
			},
			HASTE = {
				EXTRASPEED = 90 * extraspeed_ratio,
				DURATION = 22 * duration_ratio,
			},
			ILLUSION = {
				NUM = 2,
				DAMAGEMULTI = 3,
				DURATION = 75 * duration_ratio,
			},
			INVISBILITY = {
				FADING = 1,
				DURATION = 45 * duration_ratio,
			},
			REGENERATION = {
				INTERVAL = 1,
				MAXRATIO = 0.1,
				DURATION = 30 * duration_ratio,
			},
			SHIELD = {
				MAXRATIO = 0.5,
				DURATION = 75 * duration_ratio,
			},
			WATER = {
				HEALTH = 80 * extrahealth_ratio,
				MANA = 80,
				MAXRATIO = 0.1,
			},
			WISDOM = {
				EXP = 700,
				EXTREXP = 135,
			},
		},
	},
--树之祭祀 or 吃树
	TANGO = {
		GOLD = 90 * gold_ratio,
		MAXSIZE = stack_size,					-- 最大堆叠数量
		DEVOU = {
			SPELLRANGE = 165 * spellrange_ratio,			-- 吞食生效范围
			DURATION = 16 * duration_ratio * 4,			-- 吞食持续时间
			HEALTHREGEN = 7 * healthregen_ratio,		-- 吞食生命恢复速率
			INTERVAL = 1 * 4,
		},
	},
--显影之尘 or 粉
	DUST_OF_APPEARANCE = {
		GOLD = 80 * gold_ratio,
		MAXSIZE = stack_size,
		RANGE = 1200 * range_ratio,		-- 生效距离
		DURATION = 8 * seg_time * duration_ratio,
	},
--知识之书
	TOME_OF_KNOWLEDGE = {
		GOLD = 75 * gold_ratio,
		EXP = 700,		-- 启迪提供经验
		EXTREXP = 135,	-- 第二次起每次启迪额外经验
		RE_TIME = 10*60,	-- 刷新时间
	},
--治疗药膏
	HEALING_SALVE = {
		GOLD = 100 * gold_ratio,
		MAXSIZE = stack_size,
		HEALTHREGEN = 15 * healthregen_ratio,		-- 生命恢复速率
		DURATION = 13 * duration_ratio,		-- 持续时间
		INTERVAL = 0.5,	-- 回复间隔
	},
--血腥榴弹
	BLOOD_GRENADE = {
		GOLD = 65 * gold_ratio,
		MAXSIZE = stack_size,
		GRENADE = {
			HEALTH = 75 * extrahealth_ratio,
			CD = 10 * cd_ratio,
			RANGE = 300 * range_ratio,		-- 生效距离
			SPELLRANGE = 900 * range_ratio,
			DURATION = 5 * duration_ratio,
			DAMAGE = 50 * extradamage_ratio,
			PERDAMAGE = 15 * extradamage_ratio,
			TICK = 1,
			SPEEDMULTI = -0.15,
		},
	},
---------------------------------属性-----------------------------
--法师长袍
	ROBE_OF_THE_MAGI = {
		GOLD = 450 * gold_ratio,
		INTELLIGENCE = 6,
	},
--欢欣之刃
	BLADE_OF_ALACRITY = {
		GOLD = 1000 * gold_ratio,
		AGILITY = 10,
	},
--精灵布带
	BAND_OF_ELVENSKIN = {
		GOLD = 450 * gold_ratio,
		AGILITY =6,
	},
--力量手套
	GAUNTLETS_OF_STRENGTH = {
		GOLD = 140 * gold_ratio,
		STRENGTH = 3,
	},
--力量腰带
	BELT_OF_STRENGTH = {
		GOLD = 450 * gold_ratio,
		STRENGTH = 6,
	},
--敏捷便鞋
	SLIPPERS_OF_AGILITY = {
		GOLD = 140 * gold_ratio,
		AGILITY = 3,
	},
--魔力法杖
	STAFF_OF_WIZARDRY = {
		GOLD = 1000 * gold_ratio,
		INTELLIGENCE = 10,
	},
--食人魔之斧
	OGRE_AXE = {
		GOLD  = 1000 * gold_ratio,
		STRENGTH = 10,
	},
--铁树枝干
	IRON_BRANCH = {
		GOLD  = 50 * gold_ratio,
		ATTRIBUTES = 1,			-- 全属性加成
	},
--王冠
	CROWN = {
		GOLD  = 450 * gold_ratio,
		ATTRIBUTES = 4,
	},
--圆环
	CIRCLET = {
		GOLD  = 155 * gold_ratio,
		ATTRIBUTES = 2,
	},
--智力斗篷
	MANTLE_OF_INTELLIGENCE = {
		GOLD  = 140 * gold_ratio,
		INTELLIGENCE = 3,
	},
--宝冕
	DIADEM = {
		GOLD  = 1000 * gold_ratio,
		ATTRIBUTES = 6,
	},
---------------------------------装备-----------------------------
--标枪
	JAVELIN = {
		GOLD  = 1100 * gold_ratio,
		PIERCE = {
			PROBABILITY = 0.3,	-- 穿刺触发概率
			DAMAGE = 70 * extradamage_ratio,			-- 穿刺触发伤害
		},
	},
--淬毒之珠
	ORB_OF_VENOM = {
		GOLD  = 275 * gold_ratio,
		SPEEDMULTI = 0.13,		-- 攻击目标移速降低
		DAMAGE = 2,			-- 毒性攻击每次伤害
		INTERVAL = 1,		-- 毒性攻击促发频率
		DURATION = 2 * duration_ratio,			-- buff持续时间
	},
--大剑
	CLAYMORE = {
		GOLD  = 1350 * gold_ratio,
		EXTRADAMAGE = 10 * extradamage_ratio,			-- 额外攻击力
	},
--短棍
	QUARTERSTAFF = {
		GOLD  = 875 * gold_ratio,
		EXTRADAMAGE = 10 * extradamage_ratio,
		DAMAGERANGE = 10,
	},
--攻击之爪
	BLADES_OF_ATTACK = {
		GOLD  = 450 * gold_ratio,
		EXTRADAMAGE = 9 * extradamage_ratio,
	},
--加速手套
	GLOVES_OF_HASTE = {
		GOLD  = 450 * gold_ratio,
		ATTACKSPEED = 20 * attackspeed_ratio,	-- 攻速
	},
--枯萎之石
	BLIGHT_STONE = {
		GOLD  = 300 * gold_ratio,
		LESSERARMOR = 2,
		DURATION = 8 * duration_ratio,
	},
--阔剑
	BROADSWORD = {
		GOLD  = 1000 * gold_ratio,
		EXTRADAMAGE = 10 * extradamage_ratio,
	},
--秘银锤
	MITHRIL_HAMMER = {
		GOLD  = 1600 * gold_ratio,
		EXTRADAMAGE = 24 * extradamage_ratio,
	},
--凝魂之露
	INFUSED_RAINDROP = {
		GOLD  = 225 * gold_ratio,
		MAXUSE = 6,
		MINDAMAGE = 75 * extradamage_ratio,
		DAMAGEBLOCK = 120 * extradamage_ratio,
		MANAREGEN = 0.6,
		CD = 6 * cd_ratio,
	},
--闪电指套
	BLITZ_KNUCKLES = {
		GOLD  = 1000 * gold_ratio,
		ATTACKSPEED = 35 * attackspeed_ratio,
	},
--守护指环
	RING_OF_PROTECTION = {
		GOLD  = 175 * gold_ratio,
		EXTRAARMOR = 2,
	},
--锁子甲
	CHAINMAIL = {
		GOLD  = 550 * gold_ratio,
		EXTRAARMOR = 4,
	},
--铁意头盔
	HELM_OF_IRON_WILL = {
		GOLD  = 975 * gold_ratio,
		EXTRAARMOR = 6,
		HEALTHREGEN = 5 * healthregen_ratio,
	},
--压制之刃 or 补刀斧
	QUELLING_BLADE = {
		GOLD  = 100 * gold_ratio,
		EXTRADAMAGE = 8 * extradamage_ratio,		-- 压制额外伤害
		CHOP = {
			SPELLRANGE = 350 * spellrange_ratio,
			CD = 4 * cd_ratio,				-- 砍伐cd
		},
	},	
---------------------------------其他-----------------------------
--暗影护符
	SHADOW_AMULET = {
		GOLD  = 1000 * gold_ratio,
		FADING = 1.25,		-- 渐隐时间
		DURATION = total_day_time * 3 * duration_ratio,		-- 持续时间（我们设置一个足够长的时间，或者直接取消限制？）
		CD = 1 * cd_ratio,		-- 加个1s的CD，帮助确认按键
	},
--风灵之纹
	WIND_LACE = {
		GOLD  = 250 * gold_ratio,
		EXTRASPEED = 20 * extraspeed_ratio,		-- 移速( deafult - 20 )
	},
--回复戒指
	RING_OF_REGEN = {
		GOLD  = 175 * gold_ratio,
		HEALTHREGEN = 1.25 * healthregen_ratio,
	},
--抗魔斗篷
	CLOAK = {
		GOLD  = 500 * gold_ratio,
		SPELLRESIS = 0.15,
	},
--毛毛帽
	FLUFFY_HAT = {
		GOLD  = 250 * gold_ratio,
		EXTRAHEALTH = 125 * extrahealth_ratio,
	},
--魔棒
	MAGIC_STICK = {
		GOLD  = 200 * gold_ratio,
		RANGE = 1200 * range_ratio,			-- 充能搜索范围
		MAXPOINTS =10,			-- 最大能量点
		HEAL = 15 * extrahealth_ratio * 4,		-- 每点能力恢复生命值
		MANA = 15,				-- 每点能力恢复生命魔法值
		GETPOINT = 1,			-- 每次搜索增加能量点
		CD = 13,
	},
--闪烁匕首 or 跳刀
	BLINK_DAGGER = {
		GOLD  = 2200 * gold_ratio,
		SPEED_MULT	= 0.25,			--手持时速度提升
		ISONLYEPIC = 1,			--是否仅boss打断跳刀
		BLINK = {
			CD = 14 * cd_ratio * blinkdagger_cdplus,	--跳刀CD	(default-14)
			MAX_DISTANCE = 18,	--最远距离 (default-30)
			PENALTY_DISTANCE = 10,	--惩罚距离
			PENALTY_CD = 3,		--受击CD
		},
	},
--速度之靴 or 鞋子
	BOOTS_OF_SPEED = {
		GOLD  = 500 * gold_ratio,
		EXTRASPEED = 45 * extraspeed_ratio,		-- default - 45
	},
--巫毒面具
	VOODOO_MASK = {
		GOLD  = 700 * gold_ratio,
		SPELLLIFESTEAL = 0.1 * lifesteal_ratio,
	},
--吸血面具
	MORBID_MASK = {
		GOLD  = 900 * gold_ratio,
		LIFESTEAL = 0.18 * lifesteal_ratio,
	},
--贤者面罩
	SAGES_MASK = {
		GOLD  = 175 * gold_ratio,
		MANAREGEN = 0.7,
	},
--幽魂权杖 or 绿杖
	GHOST_SCEPTER = {
		GOLD  = 1500 * gold_ratio,
		ATTRIBUTES = 5,
		GHOSTFORM = {
			SPELLWEAK = 0.4,
			DURATION = 4 * duration_ratio,
			CD = 22,
		},
	},
--真视宝石
	GEM_OF_TRUE_SIGHT = {
		GOLD  = 900 * gold_ratio,
		RANGE = 900 * range_ratio,
		LIGHT = {	-- 光照
			FALLOFF = 1.15, -- 衰减
			INTENSITY = 0.7, -- 光强
			RADIUS = 300 * range_ratio,	-- 半径
			COLOUR_R = 50 / 255, -- 颜色:柠檬绿
			COLOUR_G = 205 / 255,
			COLOUR_B = 50 / 255,
		},
	},
---------------------------------神秘商店-----------------------------
--板甲
	PLATEMAIL = {
		GOLD  = 1400 * gold_ratio,
		EXTRAARMOR = 10,
	},
--恶魔刀锋
	DEMON_EDGE = {
		GOLD  = 2200 * gold_ratio,
		EXTRADAMAGE = 40 * extradamage_ratio,
	},
--活力之球
	VITALITY_BOOSTER = {
		GOLD  = 1000 * gold_ratio,
		EXTRAHEALTH  = 250 * extrahealth_ratio,
	},
--精气之球
	POINT_BOOSTER = {
		GOLD  = 1200 * gold_ratio,
		EXTRAHEALTH = 175 * extrahealth_ratio,
		MAXMANA = 175,
	},
--能量之球
	ENERGY_BOOSTER = {
		GOLD  = 800 * gold_ratio,
		MAXMANA = 250,
	},
--极限法球
	ULTIMATE_ORB = {
		GOLD  = 2050 * gold_ratio,
		ATTRIBUTES = 10,
	},
--掠夺者之斧
	REAVER = {
		GOLD  = 2800 * gold_ratio,
		STRENGTH = 25,
	},
--闪避护符
	TALISMAN_OF_EVASION = {
		GOLD  = 1300 * gold_ratio,
		DODGECHANCE = 0.15,
	},
--神秘法杖
	MYSTIC_STAFF = {
		GOLD  = 2800 * gold_ratio,
		INTELLIGENCE = 25,
	},
--圣者遗物
	SACRED_RELIC = {
		GOLD  = 3750 * gold_ratio,
		EXTRADAMAGE = 60 * extradamage_ratio,
	},
--虚无宝石
	VOID_STONE = {
		GOLD  = 825 * gold_ratio,
		MANAREGEN = 2.25,
	},
--治疗指环
	RING_OF_HEALTH = {
		GOLD  = 825 * gold_ratio,
		HEALTHREGEN = 6.5 * healthregen_ratio,
	},
--鹰歌弓
	EAGLESONG = {
		GOLD  = 2800 * gold_ratio,
		AGILITY = 25,
	},
--振奋宝石
	HYPERSTONE = {
		GOLD  = 2000 * gold_ratio,
		ATTACKSPEED = 60 * attackspeed_ratio,
	},
--丰饶之环
	CORNUCOPIA = {
		GOLD  = 1200 * gold_ratio,
		HEALTHREGEN = 5 * healthregen_ratio,
		MANAREGEN = 2,
		EXTRADAMAGE = 7 * extradamage_ratio,
	},
---------------------------------配件-----------------------------
--动力鞋 or 假腿
	POWER_TREADS = {
		GOLD  = 0 * gold_ratio,
		ATTACKSPEED = 25 * attackspeed_ratio,
		EXTRASPEED = 45 * extraspeed_ratio,
		ATTRIBUTES = 10,
		CD = 1,
	},
--疯狂面具 or 疯脸
	MASK_OF_MADNESS = {
		GOLD  = 0 * gold_ratio,
		EXTRADAMAGE = 10 * extradamage_ratio,
		ATTACKSPEED = 10 * attackspeed_ratio,
		LIFESTEAL = 0.24 * lifesteal_ratio,
		BERSERK = {
			ATTACKSPEED = 110 * attackspeed_ratio,
			LESSERARMOR = 8,
			SPEED = 30 * extraspeed_ratio,
			DURATION = 6 * duration_ratio,
			MANA = 25,
			CD = 16 * cd_ratio,
		},
	},
--腐蚀之球
	ORB_OF_CORROSION = {
		GOLD  = 100 * gold_ratio,	-- 卷轴钱
		EXTRAHEALTH = 150 * extrahealth_ratio,
		CORRUPTION = {
			LESSERARMOR = 3,	-- 腐蚀护甲降低
			SPEEDMULTI = -0.13,	-- 腐蚀减速效果
			DAMAGE = 3,			-- 腐蚀每次伤害
			TICK = 1,			-- 腐蚀伤害间隔
			DURATION = 3 * duration_ratio,		-- 腐蚀持续时间
		},
	},
--护腕
	BRACER = {
		GOLD  = 210 * gold_ratio,	-- 卷轴
		STRENGTH = 5,
		AGILITY = 2,
		INTELLIGENCE = 2,
		EXTRADAMAGE = 2 * extradamage_ratio,
		HEALTHREGEN = 0.75 * healthregen_ratio,
	},
--坚韧球
	PERSEVERANCE = {
		GOLD  = 0 * gold_ratio,
		HEALTHREGEN = 6.5 * healthregen_ratio,
		MANAREGEN = 2.25,
	},
--空灵挂件
	NULL_TALISMAN = {
		GOLD  = 210 * gold_ratio,	-- 卷轴
		STRENGTH = 2,
		AGILITY = 2,
		INTELLIGENCE = 5,
		MAXMANA = 30,
		MANAREGEN = 0.75,
	},
--空明杖
	OBLIVION_STAFF = {
		GOLD  = 0 * gold_ratio,
		INTELLIGENCE = 10,
		EXTRADAMAGE = 15 * extradamage_ratio,
		ATTACKSPEED = 10 * attackspeed_ratio,
		MANAREGEN = 1.25,
	},
--猎鹰战刃
	FALCON_BLADE = {
		GOLD  = 250 * gold_ratio,	-- 卷轴
		EXTRAHEALTH = 200 * extrahealth_ratio,
		MANAREGEN = 1.8,
		EXTRADAMAGE = 14 * extradamage_ratio,
	},
--灵魂之戒 or 魂戒
	SOUL_RING = {
		GOLD  = 400 * gold_ratio,	-- 卷轴
		STRENGTH = 6,
		EXTRAARMOR = 2,
		SACRIFICE = {
			HEALTH = 170 * extrahealth_ratio,
			MANA = 150,
			DURATION = 10 * duration_ratio,
			CD = 25 * cd_ratio,
		},
	},
--迈达斯之手 or 点金手
	HAND_OF_MIDAS = {
		GOLD  = 1750 * gold_ratio,	-- 卷轴
		ATTACKSPEED = 40 * attackspeed_ratio,
		TRANSMUTE = {
			GOLD  = 160 * gold_ratio,		-- 额外金钱
			EXPMULTI = 2.1,	-- 经验倍率
			CD = 90 * cd_ratio * handofmidas_cdplus,
			SPELLRANGE = 600 * spellrange_ratio,
			HEALTHLIMIT = handofmidas_limit,	-- 非小动物时，点金血量上限要求
		},
	},
--魔杖
	MAGIC_WAND = {
		GOLD  = 150 * gold_ratio,		-- 卷轴
		ATTRIBUTES = 3,		-- 卷轴
		RANGE = 1200 * range_ratio,			-- 充能搜索范围
		MAXPOINTS = 20,			-- 最大能量点
		HEAL = 15 * extrahealth_ratio * 4,				-- 每点恢复生命值
		MANA = 15,
		GETPOINT = 1,			-- 每次搜索增加能量点
		CD = 13,
	},
--统御头盔
	HELM_OF_THE_OVERLORD = {
		GOLD  = 1325 * gold_ratio,
		ATTRIBUTES = 7,
		HEALTHREGEN = 7 * healthregen_ratio,
		EXTRAARMOR = 7,
		AURA = {
			LIFESTEAL = 0.2 * lifesteal_ratio,
			RANGE = 1200 * range_ratio,
			EXTRAARMOR = 3,
			DAMAGEMULTI = 0.18,
			MANAREGEN = 2,
		},
		DOMINATE = {
			BASEHEALTH = 1800,
			EXTRADAMAGE = 80 * extradamage_ratio,
			HEALTHREGEN = 12 * healthregen_ratio,
			MANAREGEN = 4,
			EXTRAARMOR = 2,
			CD = 45 * cd_ratio,
			-- RANGE = 700 * range_ratio,
			NUMLIMIT = 1,
			SPELLRANGE = 700 * spellrange_ratio,
		},
	},
--相位鞋
	PHASE_BOOTS = {
		GOLD  = 0 * gold_ratio,
		EXTRADAMAGE = 18 * extradamage_ratio,
		EXTRAARMOR = 4,
		EXTRASPEED = 45 * extraspeed_ratio,
		PHASE = {
			SPEEDMULTI = 0.2,
			CD = 8 * cd_ratio,
			DURATION = 3 * duration_ratio,
		},
	},
--银月之晶
	MOON_SHARD = {
		GOLD  = 0 * gold_ratio,
		ATTACKSPEED = 140 * attackspeed_ratio,
	},
--远行鞋I or 飞鞋
	BOOTS_OF_TRAVEL_LEVEL1 = {
		GOLD  = 2000 * gold_ratio,
		EXTRASPEED = 90 * extraspeed_ratio,
		CD = 80 * cd_ratio * tpscroll_cdplus,
	},
--远行鞋II or 大飞鞋
	BOOTS_OF_TRAVEL_LEVEL2 = {
		GOLD  = 2000 * gold_ratio,		-- 卷轴
		EXTRASPEED = 110 * extraspeed_ratio,
		CD = 80 * cd_ratio * tpscroll_cdplus * 0.8, -- 稍微增强大飞
	},
--怨灵系带
	WRAITH_BAND = {
		GOLD  = 210 * gold_ratio,
		STRENGTH = 2,
		AGILITY = 5,
		INTELLIGENCE = 2,
		EXTRAARMOR = 2,
		ATTACKSPEED = 6 * attackspeed_ratio,
	},
--支配头盔
	HELM_OF_THE_DOMINATOR = {
		GOLD  = 975 * gold_ratio,
		ATTRIBUTES = 6,
		EXTRAARMOR = 6,
		HEALTHREGEN = 6 * healthregen_ratio,
		DOMINATE = {
			BASEHEALTH = 1000,
			EXTRADAMAGE = 25 * extradamage_ratio,
			HEALTHREGEN = 12 * healthregen_ratio,
			MANAREGEN = 4,
			EXTRAARMOR = 2,
			CD = 45 * cd_ratio,
			-- RANGE = 700 * range_ratio,
			NUMLIMIT = 1,
			SPELLRANGE = 700 * spellrange_ratio,
		},
	},
---------------------------------辅助-----------------------------
--奥术鞋 or 秘法鞋
	ARCANE_BOOTS = {
		GOLD  = 0 * gold_ratio,
		EXTRASPEED = 45 * extraspeed_ratio,
		MAXMANA = 250,
		REPLENISH = {
			RANGE = 1200 * range_ratio,
			MANA = 175,
			CD = 55 * cd_ratio,
		},
	},
--洞察烟斗 or 笛子
	PIPE_OF_INSIGHT = {
		GOLD  = 1550 * gold_ratio,
		HEALTHREGEN = 8.5 * healthregen_ratio,
		SPELLRESIS = 0.3,
		BARRIER = {
			DURATION = 12 * duration_ratio,
			MANA = 100,
			CD = 60 * cd_ratio,
			RANGE = 1200 * range_ratio,
			MAGIC = 400,
		},
		AURA = {
			RANGE = 1200 * range_ratio,
			HEALTHREGEN = 2.5 * healthregen_ratio,
			SPELLRESIS = 0.15,
		},
	},
--弗拉迪米尔的祭品
	VLADMIRS_OFFERING = {
		GOLD  = 250 * gold_ratio, -- 卷轴
		AURA = {
			RANGE = 1200 * range_ratio,
			LIFESTEAL = 0.2 * lifesteal_ratio,
			DAMAGEMULTI = 0.18,
			MANAREGEN = 1.75,
			EXTRAARMOR = 3,
		}
	},
--恢复头巾
	HEADDRESS = {
		GOLD  = 250 * gold_ratio,	-- 卷轴
		HEALTHREGEN = 0.5 * healthregen_ratio,
		AURA = {
			HEALTHREGEN = 2 * healthregen_ratio,
			RANGE = 1200 * range_ratio,
		},
	},
--魂之灵瓮 or 大骨灰
	SPIRIT_VESSEL = {
		GOLD  = 1100 * gold_ratio,	-- 卷轴
		ATTRIBUTES = 2,
		EXTRAHEALTH = 250 * extrahealth_ratio,
		EXTRAARMOR = 2,
		MANAREGEN = 1.75,
		RELEASE = {
			RANGE = 1400 * range_ratio,
			SPELLRANGE = 950 * spellrange_ratio,
			HEALTH = 40 * extrahealth_ratio * 2,
			DAMAGE = 35 * extradamage_ratio,
			DAMAGEMULTI = 0.04,
			DECREASE = 0.45, -- 生命恢复降低
			DURATION = 8 * duration_ratio,
			CD = 7 * cd_ratio,
			TICK = 1,
			MAXUSES = 20,
		},
	},
--影之灵龛 or 骨灰
	URN_OF_SHADOWS = {
		GOLD  = 375 * gold_ratio,	-- 卷轴
		ATTRIBUTES = 2,
		EXTRAARMOR = 2,
		MANAREGEN = 1.4,
		RELEASE = {
			RANGE = 1400 * range_ratio,
			SPELLRANGE = 750 * spellrange_ratio,
			HEALTH = 30 * extrahealth_ratio * 2,
			DAMAGE = 25 * extradamage_ratio,
			DURATION = 8 * duration_ratio,
			CD = 7 * cd_ratio,
			TICK = 1,
			MAXUSES = 20,
		},
	},
--静谧之鞋 or 绿鞋
	TRANQUIL_BOOTS = {
		GOLD  = 0 * gold_ratio,
		BASESPEED = 40 * extraspeed_ratio,		-- 基础移速
		EXTRASPEED = 65 * extraspeed_ratio,		-- 初始移速
		HEALTHREGEN = 14 * healthregen_ratio,
		CD = 14 * cd_ratio,
	},
--宽容之靴 or 大绿鞋
	BOOTS_OF_BEARING = {
		GOLD  = 1500 * gold_ratio,	-- 卷轴
		STRENGTH = 8,
		INTELLIGENCE = 8,
		EXTRASPEED = 65 * extraspeed_ratio,
		HEALTHREGEN = 15 * healthregen_ratio,
		AURA = 	{
			EXTRASPEED = 20 * extraspeed_ratio,
			RANGE = 20 * range_ratio,
		},
		ENDURANCE = {
			RANGE = 1300 * range_ratio,
			ATTACKSPEED = 50 * attackspeed_ratio,
			SPEEDMULTI = 0.15,
			TIME = 1.5,
			DURATION = 6 * duration_ratio,
			CD = 30 * cd_ratio,
			POINTCD = 180 * cd_ratio,
			MAXPOINTS = 8,
		},
	},
--梅肯斯姆
	MEKANSM = {
		GOLD  = 800 * gold_ratio,	-- 卷轴
		EXTRAARMOR = 4,
		AURA = {
			RANGE = 1200 * range_ratio,
			HEALTHREGEN = 2.5 * healthregen_ratio,
		},
		RESTORE = {
			RANGE = 1200 * range_ratio,
			HEALTH = 275 * extrahealth_ratio,
			MANA = 100,
			CD = 50 * cd_ratio,
		},
	},
--韧鼓
	DRUM_OF_ENDURANCE = {
		GOLD  = 550 * gold_ratio,	-- 卷轴
		STRENGTH = 7,
		INTELLIGENCE = 7,
		AURA = {
			EXTRASPEED = 20 * extraspeed_ratio,
			RANGE = 1200 * range_ratio,
		},
		ENDURANCE = {
			RANGE = 1200 * range_ratio,
			SPEEDMULTI = 0.13,
			ATTACKSPEED = 0.45 * attackspeed_ratio,
			DURATION = 6 * duration_ratio,
			CD = 30 * cd_ratio,
			MAXPOINTS = 8,
		},
	},
--圣洁吊坠
	HOLY_LOCKET = {
		GOLD  = 475 * gold_ratio,	-- 卷轴
		EXTRAHEALTH = 250 * extrahealth_ratio,
		MAXMANA = 300,
		ATTRIBUTES = 3,
		OUTHEALAMP = 0.3,
		AURA = {
			HEALTHREGEN = 3 * healthregen_ratio,
			RANGE = 1200 * range_ratio,
		},
		CHARGE = {
			SPELLRANGE = 500 * spellrange_ratio,
			RANGE = 1200 * range_ratio,
			MAXPOINTS = 20,
			HEAL = 15 * extrahealth_ratio * 4,				-- 每点恢复生命值
			MANA = 15,
			TIME = 10,
			CD = 13 * cd_ratio,
		},
	},
--王者之戒
	RING_OF_BASILIUS = {
		GOLD  = 250 * gold_ratio, -- 卷轴
		AURA = {
			RANGE = 1200 * range_ratio,
			MANAREGEN = 1,
		},
	},
--卫士胫甲 or 大鞋
	GUARDIAN_GREAVES = {
		GOLD  = 1550 * gold_ratio, -- 卷轴
		MAXMANA = 250,
		EXTRAARMOR = 4,
		EXTRASPEED = 50 * extraspeed_ratio,
		MEND = {
			HEALTH = 350 * extrahealth_ratio,
			MANA = 200,
			CD = 40 * cd_ratio,
		},
		AURA = {
			RANGE = 1200 * range_ratio,
			HEALTHREGEN = 2.5 * healthregen_ratio,
			EXTRAARMOR = 4,
		},
	},
--玄冥盾牌
	BUCKLER = {
		GOLD  = 250 * gold_ratio, -- 卷轴
		EXTRAARMOR = 1,
		AURA = {
			EXTRAARMOR = 2,
			RANGE = 1200 * range_ratio,
		},
	},
--勇气勋章
	MEDALLION_OF_COURAGE = {
		GOLD  = 0 * gold_ratio,
		MANAREGEN = 1.5,
		EXTRAARMOR = 5,
		VALOR = {
			CD = 12 * cd_ratio,
			EXTRAARMOR = 5,
			DURATION = 12 * duration_ratio,
			SPELLRANGE = 1000 * range_ratio,
		},
	},
--怨灵之契
	WRAITH_PACT = {
		GOLD  = 400 * gold_ratio, -- 卷轴
		EXTRAHEALTH = 250 * extrahealth_ratio,
		MAXMANA = 250,
		AURA = {
			LIFESTEAL = 0.1 * lifesteal_ratio,
			RANGE = 1200 * range_ratio,
			EXTRAARMOR = 3,
			DAMAGEMULTI = 0.18,
			MANAREGEN = 2,
		},
		REPRISAL = {
			RANGE = 900 * range_ratio,
			DAMAGE = 30,
			DURATION = 25 * duration_ratio,
			MANA = 100,
			CD = 60 * cd_ratio,
			DAMAGEMULTI = -0.3,
		},
	},
--长盾
	PAVISE = {
		GOLD  = 275 * gold_ratio, -- 卷轴
		EXTRAHEALTH = 175 * extrahealth_ratio,
		MANAREGEN = 2.5,
		EXTRAARMOR = 6,
		PROTECT = {
			DAMAGE = 300 * extrahealth_ratio,
			DURATION = 8 * duration_ratio,
			MANA = 75,
			CD = 18,
			SPELLRANGE = 1400 * range_ratio,
		},
	},
---------------------------------法器-----------------------------

--吹风 or EUL的神圣法杖
	EULS = {
		GOLD  = 650 * gold_ratio,	-- 卷轴
		INTELLIGENCE = 10,
		MANAREGEN = 2.5,
		EXTRASPEED = 20 * extraspeed_ratio,
		CYCLONE = {
			CD = 23 * cd_ratio, 			--龙卷风CD
			MANA = 175,
			SPELLRANGE = 550 * spellrange_ratio,
			DAMAGE = 50 * extradamage_ratio, 		--龙卷风落地伤害
			DURATION = 2.5,	--龙卷风持续时间
		},
	},
--阿哈利姆神杖
	AGHANIMS_SCEPTER = {
		GOLD  = 0 * gold_ratio,
		ATTRIBUTES = 10,
		EXTRAHEALTH = 175 * extrahealth_ratio,
		MAXMANA = 175,
	},
--阿托斯之棍
	ROD_OF_ATOS = {
		GOLD  = 850 * gold_ratio,	-- 卷轴
		STRENGTH = 12,
		AGILITY = 12,
		INTELLIGENCE = 24,
		CRIPPLE = {
			SPELLRANGE = 1100 * spellrange_ratio,
			MANA = 50,
			CD = 18 * cd_ratio,
			DURATION = 5 * duration_ratio,	-- default:2
			SPEED = 1500,
		},
	},
--大根 or 达贡之神力
	DAGON_ENERGY = {
		GOLD  = 1250 * gold_ratio, -- 卷轴
		STRENGTH = 6,
		AGILITY = 6,
		INTELLIGENCE = 14,
		BURST = {
			DAMAGE = {
				LEVEL1 = 400 * extradamage_ratio,		--一级能量冲击伤害
				LEVEL2 = 500 * extradamage_ratio,
				LEVEL3 = 600 * extradamage_ratio,
				LEVEL4 = 700 * extradamage_ratio,
				LEVEL5 = 800 * extradamage_ratio,
			},
			MANA = {
				LEVEL1 = 120,			--一级能量冲击消耗魔法值
				LEVEL2 = 140,
				LEVEL3 = 160,
				LEVEL4 = 180,
				LEVEL5 = 200,
			},
			CD = {
				LEVEL1 = 35 * cd_ratio,			--一级能量冲击cd
				LEVEL2 = 30 * cd_ratio,
				LEVEL3 = 25 * cd_ratio,
				LEVEL4 = 20 * cd_ratio,
				LEVEL5 = 15 * cd_ratio,
			},
			SPELLRANGE = {
				LEVEL1 = 700 * 1 * spellrange_ratio,		--一级能量冲击施法距离
				LEVEL2 = 700 * 1.5 * spellrange_ratio,
				LEVEL3 = 700 * 2 * spellrange_ratio,
				LEVEL4 = 700 * 2.5 * spellrange_ratio,
				LEVEL5 = 700 * 3 * spellrange_ratio,
			},
		},
	},
--纷争面纱
	VEIL_OF_DISCORD = {
		GOLD  = 850 * gold_ratio,	 -- 卷轴
		ATTRIBUTES = 4,
		WEAKNESS = {
			SPELLRANGE = 1200 * spellrange_ratio,
			RANGE = 600 * range_ratio,
			SPELLWEAK = 0.18,
			DURATION = 18 * duration_ratio,
			MANA = 50,
			CD = 22 * cd_ratio,
		},
		AURA = {
			RANGE = 1200 * range_ratio,
			MANAREGEN = 1.75,
		},
	},
--风之杖 or 大吹风
	WIND_WAKER = {
		GOLD  = 1300 * gold_ratio, -- 卷轴
		INTELLIGENCE = 35,
		MANAREGEN = 6,
		EXTRASPEED = 50 * extraspeed_ratio,
		CD = 18 * cd_ratio,
		SPEED = 360,
	},
--缚灵索
	GLEIPNIR = {
		GOLD  = 700 * gold_ratio, -- 卷轴
		STRENGTH = 14,
		AGILITY = 14,
		INTELLIGENCE = 24,
		EXTRADAMAGE = 30 * extradamage_ratio,
		ETERNAL = {
			SPELLRANGE = 1100 * spellrange_ratio,
			RANGE = 450 * range_ratio,
			DURATION = 2 * duration_ratio,
			DAMAGE = 220 * extradamage_ratio,
			MANA = 200,
			CD = 18 * cd_ratio,
		},
	},
--玲珑心
	OCTARINE_CORE = {
		GOLD  = 0 * gold_ratio,
		EXTRAHEALTH = 425 * extrahealth_ratio,
		MAXMANA = 725,
		MANAREGEN = 3,
		SPELLRANGE = 225 * spellrange_ratio,
		REDUCTION = 0.25,
	},
--刷新球
	REFRESHER_ORB = {
		GOLD  = 1700 * gold_ratio, -- 卷轴
		HEALTHREGEN = 13 * healthregen_ratio,
		MANAREGEN = 7,
		RESETCOOLDOWNS = {
			CD = 180 * cd_ratio,
			MANA = 350,
		},
	},
--微光披风
	GLIMMER_CAPE = {
		GOLD  = 450 * gold_ratio, -- 卷轴
		SPELLRESIS = 0.2,
		GLIMMER = {
			MANA = 90,
			CD = 14,
			SPELLRESIS = 0.5,
			DURATION = 5 * duration_ratio,
			FADING = 0.5,
			SPELLRANGE = 600 * spellrange_ratio,
		},
	},
--巫师之刃
	WITCH_BLADE = {
		GOLD  = 600 * gold_ratio, -- 卷轴
		INTELLIGENCE = 12,
		EXTRAARMOR = 6,
		ATTACKSPEED = 35 * attackspeed_ratio,
		BLADE = {
			CD = 9 * cd_ratio,
			DAMAGEMULTI = 0.75,
			SPEEDMULTI = -0.25,
			DURATION = 4 * duration_ratio,
			TICK = 1,
		},
	},
--邪恶镰刀  or 羊刀
	SCYTHE_OF_VYSE = {
		GOLD  = 0 * gold_ratio,
		STRENGTH = 10,
		AGILITY = 10,
		INTELLIGENCE = 35,
		MANAREGEN = 9,
		HEX = {
			DURATION = 3.5 * duration_ratio,
			MANA = 250,
			CD = 20 * cd_ratio,
			SPELLRANGE = 800 * spellrange_ratio,
		},
	},
--炎阳纹章 or 大勋章
	SOLAR_CREST = {
		GOLD  = 900 * gold_ratio, -- 卷轴
		ATTRIBUTES = 5,
		MANAREGEN = 1.75,
		EXTRAARMOR = 6,
		EXTRASPEED = 20 * extraspeed_ratio,
		SHINE = {
			SPELLRANGE = 1000 * spellrange_ratio,
			EXTRAARMOR = 6,
			SPEEDMULTI = 0.1,
			ATTACKSPEED = 50 * attackspeed_ratio,
			DURATION = 12 * duration_ratio,
			CD = 12 * cd_ratio,
		},
	},
--以太透镜
	AETHER_LENS = {
		GOLD  = 650 * gold_ratio, -- 卷轴
		MAXMANA = 300,
		MANAREGEN = 2.5,
	-- 	EXSPELLRANGE = 225 * spellrange_ratio,
	},
--原力法杖 or 推推棒
	FORCE_STAFF = {
		GOLD  = 950 * gold_ratio, -- 卷轴
		INTELLIGENCE = 10,
		EXTRAHEALTH = 175 * extrahealth_ratio,
		FORCE = {
			SPELLRANGE = 550 * spellrange_ratio,
			DURATION = 10 * FRAMES,
			SPEED = 30,
			CD = 19 * cd_ratio,
			MANA = 100,
		},
	},
--紫怨
	ORCHID_MALEVOLENCE = {
		GOLD = 300 * gold_ratio,	-- 卷轴
		MANAREGEN = 3,
		ATTACKSPEED = 40 * attackspeed_ratio,
		EXTRADAMAGE = 30 * extradamage_ratio,
		BURNX = {
			SPELLRANGE = 900 * spellrange_ratio,
			DURATION = 5 * duration_ratio,
			CD = 18 * cd_ratio,
			MANA = 100,
			DAMAGERATIO = 0.3,
		},
	},
---------------------------------防具-----------------------------
--赤红甲
	CRIMSON_GUARD = {
		GOLD = 800 * gold_ratio,
		EXTRAHEALTH = 250 * extrahealth_ratio,
		HEALTHREGEN = 12 * healthregen_ratio,
		EXTRAARMOR = 6,
		BLOCK = {
			CHANCE = 0.6,
			DAMAGE = 75,
		},
		GUARD = {
			RANGE = 1200 * range_ratio,
			DAMAGEBLOCK = 75,
			DURATION = 12 * duration_ratio,
			CD = 35 * cd_ratio,
		},
	},
--黑黄杖
	BLACK_KING_BAR = {
		GOLD = 1450 * gold_ratio,	-- 卷轴
		STRENGTH = 10,
		EXTRADAMAGE = 24 * extradamage_ratio,
		AVATAR = {
			MANA = 50,
			CD = 90 * cd_ratio,
			DURATION = 9 * duration_ratio,
			SCALE = 1.3,			-- 模型大小变化（暂定）
		},
	},
--幻影斧 or 分身斧
	MANTA_STYLE = {
		GOLD = 500 * gold_ratio,	-- 卷轴
		STRENGTH = 10,
		AGILITY = 26,
		INTELLIGENCE = 10,
		ATTACKSPEED = 12 * attackspeed_ratio,
		SPEEDMULTI = 0.08,
		MIRROR = {
			MANA = 120,
			CD = 30 * cd_ratio,
			DURATION = 20 * duration_ratio,
			DAMAGE = 0.33,
			NUMBER = 2,
		},
	},
--飓风长戟 or 大推推
	HURRICANE_PIKE = {
		GOLD = 350 * gold_ratio,
		STRENGTH = 15,
		AGILITY = 20,
		INTELLIGENCE = 15,
		EXTRAHEALTH = 200 * extrahealth_ratio,
		THRUST = {
			MANA = 100,
			CD = 19 * cd_ratio,
			DURATION = 10 * FRAMES,
			SPEED = 30,
			SPELLRANGE = 550 * spellrange_ratio,
		},
	},
--恐鳌之心
	HEART_OF_TARRASQUE = {
		GOLD = 1200 * gold_ratio,
		STRENGTH = 45,
		EXTRAHEALTH = 250 * extrahealth_ratio,
		HEALTHREGEN = 16 * healthregen_ratio,
	},
--林肯法球
	LINKENS_SPHERE = {
		GOLD = 900 * gold_ratio,
		ATTRIBUTES = 16,
		HEALTHREGEN = 7 * healthregen_ratio,
		MANAREGEN = 5,
		BLOCK = {
			CD = 14 * cd_ratio,
			SPELLRANGE = 700 * spellrange_ratio,
		},
	},
--强袭胸甲
	ASSAULT_CUIRASS = {
		GOLD = 1300 * gold_ratio,
		EXTRAARMOR = 10,
		ATTACKSPEED = 30 * attackspeed_ratio,
		AURA = {
			RANGE = 1200 * range_ratio,
			ATTACKSPEED = 30 * attackspeed_ratio,
			EXTRAARMOR = 5,
		},
	},
--清莲宝珠 or 莲花
	LOTUS_ORB = {
		GOLD = 0 * gold_ratio,
		MAXMANA = 250,
		HEALTHREGEN = 6.5 * healthregen_ratio,
		MANAREGEN = 4,
		EXTRAARMOR = 10,
		SHELL = {
			MANA = 175,
			DURATION = 6 * duration_ratio,
			CD = 15 * cd_ratio,
			SPELLRANGE = 900 * spellrange_ratio,
		},
	},
--刃甲
	BLADE_MAIL = {
		GOLD = 550 * gold_ratio,
		EXTRADAMAGE = 28 * extradamage_ratio,
		EXTRAARMOR = 6,
		RETURN = {
			MANA = 25,
			CD = 25 * cd_ratio,				--伤害反弹CD
			DURATION = 5.5 * duration_ratio,		--伤害反弹持续时间
			RATIO = 1 + 0.8,		--伤害反弹比率
		},
	},
--挑战头巾
	HOOD_OF_DEFIANCE = {
		GOLD = 0 * gold_ratio,
		HEALTHREGEN = 8.5 * healthregen_ratio,
		SPELLRESIS = 0.18,
		INSULATION = {
			DAMAGE = 350,
			DURATION = 12 * duration_ratio,
			MANA = 50,
			CD = 60 * cd_ratio,
		},
	},
--希瓦的守护 or 冰甲
	SHIVAS_GUARD = {
		GOLD = 650 * gold_ratio,
		INTELLIGENCE = 30,
		EXTRAARMOR = 15,
		AURA = {
			RANGE = 1200 * range_ratio,
			ATTACKSPEED = 45 * attackspeed_ratio,
			DECREASE = 0.25,
		},
		BLAST = {
			MANA = 100,
			CD = 72 * cd_ratio,
			RANGE = 900 * range_ratio,
			DAMAGE = 200,
			SPEEDMULTI = 0.4,
			DURATION = 4 * duration_ratio,
		},
	},
--先锋盾
	VANGUARD = {
		GOLD = 0 * gold_ratio,
		EXTRAHEALTH = 250 * extrahealth_ratio,
		HEALTHREGEN = 7 * healthregen_ratio,
		BLOCK = {
			CHANCE = 0.6,
			DAMAGE = 64,
		}
	},
--血精石
	BLOODSTONE = {
		GOLD = 700 * gold_ratio,
		MAXMANA = 550,
		EXTRAHEALTH = 550 * extrahealth_ratio,
		SPELLLIFESTEAL = 0.3 * lifesteal_ratio,
		BLOODPACT = {
			CD = 30 * cd_ratio,	
			SPELLLIFESTEAL = 0.3 * 2.5 * lifesteal_ratio,
			DURATION = 6 * duration_ratio,
		},
	},
--永恒之盘 or 盘子
	AEON_DISK = {
		GOLD = 1200 * gold_ratio,
		MAXMANA = 300,
		EXTRAHEALTH = 250 * extrahealth_ratio,
		BREAKER = {
			STATUSRESIS = 0.75,
			DURATION = 2.5 * duration_ratio,
			CD = 165 * cd_ratio,
			LINE = 0.75
		},
	},
--永世法衣
	SHROUD = {
		GOLD = 1100 * gold_ratio,
		SPELLRESIS = 0.25,
		HEALTHREGEN = 8.5 * healthregen_ratio,
		SPELLLIFESTEAL = 0.2 * lifesteal_ratio,
		SHROUD = {
			DAMAGE = 400,
			DURATION = 12 * duration_ratio,
			MANA = 50,
			CD = 45 * cd_ratio,
		},
	},
--振魂石
	SOUL_BOOSTER = {
		GOLD = 0 * gold_ratio,
		MAXMANA = 425,
		EXTRAHEALTH = 425 * extrahealth_ratio,
	},
---------------------------------兵刃-----------------------------
--黯灭
	DESOLATOR = {
		GOLD = 0 * gold_ratio,
		EXTRADAMAGE = 50 * extradamage_ratio,
		CORRUPTION = {
			DURATION = 7 * duration_ratio,
			EXTRAARMOR = -6,
		},
	},
--白银之锋 or 大隐刀
	SILVER_EDGE = {
		GOLD = 500 * gold_ratio,		
		EXTRADAMAGE = 52 * extradamage_ratio,
		ATTACKSPEED = 35 * attackspeed_ratio,
		WALK = {
			MANA = 75,
			CD = 20 * cd_ratio,
			SPEEDMULTI = 0.25,
			DURATION = 14 * duration_ratio,
			DAMAGE = 175,
		},
		CRITICAL = {
			CHANCE = 0.3,
			DAMAGE = 1.6,
		},
	},
--代达罗斯之殇
	DAEDALUS = {
		GOLD = 1000 * gold_ratio,
		EXTRADAMAGE = 88 * extradamage_ratio,
		CRITICAL = {
			CHANCE = 0.3,
			DAMAGE = 2.25,
		},
	},
--否决坠饰
	NULLIFIER = {
		GOLD = 0 * gold_ratio,
		EXTRADAMAGE = 80 * extradamage_ratio,
		EXTRAARMOR = 10,
		HEALTHREGEN = 6 * healthregen_ratio,
		NULLIFY = {
			SPELLRANGE = 900 * spellrange_ratio,
			CD = 10 * cd_ratio,
			DURATION = 5 * duration_ratio,
			SPEEDMULTI = -0.8,
			SPEEDDURATION = 0.5 * duration_ratio,
		},
	},
--蝴蝶
	BUTTERFLY = {
		GOLD = 0 * gold_ratio,
		AGILITY = 35,
		EXTRADAMAGE = 25 * extradamage_ratio,
		DODGECHANCE = 0.35,
		ATTACKSPEED = 30 * attackspeed_ratio,
		FLUTTER = {
			CD = 35 * cd_ratio,				--主动技能振翅cd
			DURATION = 2 * duration_ratio,			--主动技能振翅持续时间
			SPEEDMULTI = 0.35,		--振翅提升移速
		},
	},
--辉耀
	RADIANCE = {
		GOLD = 0 * gold_ratio,
		EXTRADAMAGE = 60 * extradamage_ratio,
		DODGECHANCE = 0.15,
		BURN = {
			RANGE = 700 * range_ratio,
			DAMAGE = 60 * extradamage_ratio,
			MISSCHANCE = 0.15,
			TICK = 1,
		},
	},
--金箍棒
	MONKEY_KING_BAR = {
		GOLD = 675 * gold_ratio,
		EXTRADAMAGE = 40 * extradamage_ratio,
		ATTACKSPEED = 45 * attackspeed_ratio,
		PIERCE = {
			CHANCE = 0.8,
			DAMAGE = 70 * extradamage_ratio,
		},
	},
--狂战斧
	BATTLE_FURY = {
		GOLD = 0 * gold_ratio,
		EXTRADAMAGE = 60 * extradamage_ratio,
		HEALTHREGEN = 7.5 * healthregen_ratio,
		MANAREGEN = 2.75,
		CHOP= {
			SPELLRANGE = 350 * spellrange_ratio,
			CD = 5 * cd_ratio,			--主动技能CD	(default-5)
		},
		CLEAVA = {
			MULTIPLE = 0.7,	--分裂系数 (default-0.7)
			RANGE = 5,		--分裂范围	(default-5)
			ANGLE = 50,		--分裂角度	(default-50)
		},
	},
--莫尔迪基安的臂章
	ARMLET = {
		GOLD = 625 * gold_ratio,
		EXTRADAMAGE = 15 * extradamage_ratio,
		HEALTHREGEN = 5 * healthregen_ratio,
		ATTACKSPEED = 25 * attackspeed_ratio,
		EXTRAARMOR = 6,
		UNHOLY = {
			EXTRADAMAGE = 35 * extradamage_ratio,
			STRENGTH = 35,
			EXTRAARMOR = 4,
			HEALTH = 45,
			TIME = 1,		--生效时间	(default-0.6)
		},
	},
--深渊之刃 or 大晕锤
	ABYSSAL_BLADE = {
		GOLD = 1550 * gold_ratio,
		HEALTHREGEN = 10 * healthregen_ratio,
		STRENGTH = 10,
		EXTRAHEALTH = 250 * extrahealth_ratio,
		EXTRADAMAGE = 25 * extradamage_ratio,
		BASH = {
			CHANCE = 0.25,
			DAMAGE = 120,
			STUN = 1.5,
			CD = 2.3 * cd_ratio,
		},
		OVERWHELM = {
			MANA = 75,
			CD = 35 * cd_ratio,
			SPELLRANGE = 150 * spellrange_ratio,
			STUN = 2,
		},
	},
--圣剑
	DIVINE_RAPIER = {
		GOLD = 0 * gold_ratio,
		EXTRADAMAGE = 350 * extradamage_ratio,
		EVERLASTING = true,
	},
--水晶剑
	CRYSTALYS = {
		GOLD = 500 * gold_ratio,
		EXTRADAMAGE = 32 * extradamage_ratio,
		CRITICAL = {
			CHANCE = 0.3,
			DAMAGE = 1.6,
		},
	},
--碎颅锤 or 晕锤
	SKULL_BASHER = {
		GOLD = 825 * gold_ratio,
		STRENGTH = 10,
		EXTRADAMAGE = 25 * extradamage_ratio,
		BASH = {
			CHANCE = 0.1,
			DAMAGE = 120,
			STUN = 1.5,
			CD = 2.3 * cd_ratio,
		},
	},
--虚灵之刃 or 虚灵刀
	ETHEREAL_BLADE = {
		GOLD = 1100 * gold_ratio,
		STRENGTH = 5,
		AGILITY = 5,
		INTELLIGENCE = 25,
		SPELLDAMAGEAMP = 0.12,
		SPELLLIFESTEALAMP = 0.24,
		MANAREGENAMP = 0.75,
		ETHEREAL = {
			MANA = 100,
			CD = 22 * cd_ratio,
			SPELLRANGE = 800 * spellrange_ratio,
			DAMAGE = 125,
			PRIMARYMULTI = 1.5,
			SPEEDMULTI = 0.8,
			SPELLWEAK = 0.4,
			DURATION = 4 * duration_ratio,
		},
	},
--血棘 or 大紫怨
	BLOODTHORN = {
		GOLD = 925 * gold_ratio,
		INTELLIGENCE = 20,
		MANAREGEN = 5,
		EXTRADAMAGE = 50 * extradamage_ratio,
		ATTACKSPEED = 60 * attackspeed_ratio,
		SPELLRESIS = 0.25,
		REND = {
			MANA = 100,
			CD = 15 * cd_ratio,
			SPELLRANGE = 900 * spellrange_ratio,
			MAGICCALC = 0.3,
			DAMAGEMULTI = 1.3,
			DAMAGERATIO = 0.6,
			DURATION = 5 * duration_ratio,
			ACCURACY = 1,
		},
	},
--英灵胸针
	REVENANTS_BROOCH = {
		GOLD = 800 * gold_ratio,
		INTELLIGENCE = 45,
		ATTACKSPEED = 40 * attackspeed_ratio,
		EXTRAARMOR = 8,
		PROVINCE = {
			NUM = 5,
			ATTACKSPEED = 60 * attackspeed_ratio,
			MANA = 300,
			CD = 25 * cd_ratio,
			DURATION = 15 * duration_ratio,
		},
	},
--隐刀
	INVIS_SWORD = {
		GOLD = 0 * gold_ratio,
		EXTRADAMAGE = 20 * extradamage_ratio,
		ATTACKSPEED = 35 * attackspeed_ratio,
		WALK = {
			MANA = 75,
			CD = 25 * cd_ratio,
			FADE = 0.3,
			SPEEDMULTI = 0.2,
			DAMAGE = 175,
			DURATION = 14 * duration_ratio,
		},
	},
--陨星锤
	METEOR_HAMMER = {
		GOLD = 250 * gold_ratio,
		ATTRIBUTES = 8,
		HEALTHREGEN = 6.5 * healthregen_ratio,
		MANAREGEN = 2.5,
		METEOR = {
			SPELLRANGE = 600 * spellrange_ratio,
			RANGE = 400 * range_ratio * 1/2,	-- 星陨半径
			-- SPELLTIME = 2.5,
			-- DAMAGE = 150,
			-- PERDAMAGE = 60,
			DURATION = 6 * duration_ratio,
			-- STUN = 1.25,
			MANA = 200,
			CD = 24,
		},
	},
--散魂剑
	DISPERSER = {
		GOLD = 1000 * gold_ratio,
		AGILITY = 20,
		INTELLIGENCE = 10,
		EXTRADAMAGE = 45 * extradamage_ratio,
		SUPPRESS = {

		},
	},
---------------------------------宝物-----------------------------
--法师克星
	MAGE_SLAYER = {
		GOLD = 400 * gold_ratio,
		INTELLIGENCE = 10,
		MANAREGEN = 2,
		EXTRADAMAGE = 20 * extradamage_ratio,
		ATTACKSPEED = 20 * attackspeed_ratio,
		SPELLRESIS = 0.25,
		SLAYER = {
			SPELLDAMAGEAMP = 0.35,
			DURATION = 6 * duration_ratio,
		},
	},
--回音战刃 or 连击刀
	ECHO_SABRE = {
		GOLD = 0 * gold_ratio,
		STRENGTH = 13,
		INTELLIGENCE = 10,
		MANAREGEN = 1.75,
		EXTRADAMAGE = 15 * extradamage_ratio,
		ATTACKSPEED = 10 * attackspeed_ratio,
		ECHO = {
			CD = 6 * cd_ratio,
			SPEEDMULTI = -1,
			DURATION = 0.8 * duration_ratio,
			ATTACKSPEED = 5,
		},
	},
--斯嘉蒂之眼 or 冰眼
	EYE_OF_SKADI = {
		GOLD = 0 * gold_ratio,
		ATTRIBUTES = 22,
		EXTRAHEALTH = 220 * extrahealth_ratio,
		MAXMANA = 220,
		INSULATOR = 1000,
		COLD = {
			SPEEDMULTI = -0.2,
			ATTACKSPEED = 20 * attackspeed_ratio,
			DECREASE = 0.4,
			DURATION = 0.8 * duration_ratio,
		},
	},
--天堂之戟
	HEAVENS_HALBERD = {
		GOLD = 200 * gold_ratio,
		STRENGTH = 20,
		HEALTHREGENAMP = 0.2 * healthregen_ratio,
		LIFESTEALAMP = 0.2,
		DODGECHANCE = 0.2,
		STATUSRESIS = 0.16,
		DISARM = {
			MANA = 100,
			CD = 18 * cd_ratio,
			SPELLRANGE = 650 * spellrange_ratio,
			DURATION = 5 * duration_ratio, -- defeat: 3
		},
	},
--魔龙枪
	DRAGON_LANCE = {
		GOLD = 0 * gold_ratio,
		STRENGTH = 12,
		AGILITY = 15,
		DISTANCE = 1.5,		-- default 150
	},
--撒旦之邪力 or 大吸
	SATANIC = {
		GOLD = 0 * gold_ratio,
		STRENGTH = 25,
		EXTRADAMAGE = 38 * extradamage_ratio,
		LIFESTEAL = 0.3 * lifesteal_ratio,
		RAGE = {
			CD = 30 * cd_ratio,
			LIFESTEAL = 1.45 * lifesteal_ratio,
			DURATION = 6 * duration_ratio,
		},
	},
--净魂之刃 or 散失
	DIFFUSAL_BLADE = {
		GOLD = 1050 * gold_ratio,
		AGILITY = 15,
		INTELLIGENCE = 10,
		INHIBIT = {
			CD = 15 * cd_ratio,
			SPELLRANGE = 600 * spellrange_ratio,
			DURATION = 4 * duration_ratio,
			SPEEDMULTI = -0.6,
		},
	},
--漩涡 or 电锤
	MAELSTORM = {
		GOLD = 0 * gold_ratio,
		EXTRADAMAGE = 24 * extradamage_ratio,
		LIGHTING = {
			CHANCE = 0.3,	--连环闪电概率 (DEFAULT-0.3) RANGE(0,1)
			DAMAGE = 140 * extradamage_ratio,	--闪电伤害
			BOUNCES = 4,	--闪电弹射单位次数，包含原单位	(DEFAULT-4)
			RANGE = 650 * range_ratio,	--闪电弹射距离
			INTERVAL = 0.25,--闪电弹射间隔
			CD = 1,		-- 闪电内置CD (DEFAULT-0.2)
		},
	},
--雷神之锤 or 大雷锤 or 大电锤
	MJOLLNIR = {
		GOLD = 900 * gold_ratio,
		EXTRADAMAGE = 24 * extradamage_ratio,
		ATTACKSPEED = 70 * attackspeed_ratio,
		STATIC = {
			MANA = 50,
			CD = 35 * cd_ratio,
			SPELLRANGE = 800 * spellrange_ratio,
			RANGE = 900 * range_ratio,
			NUMBER = 4,
			DAMAGE = 225 * extradamage_ratio,
			CHANCE = 0.2,
			INTERVAL = 1,
			DURATION = 15 * duration_ratio,
		},
		LIGHTING = {
			CHANCE = 0.3,	--连环闪电概率 (DEFAULT-0.3) RANGE(0,1)
			DAMAGE = 180 * extradamage_ratio,	--闪电伤害
			BOUNCES = 4,	--闪电弹射单位次数，不包含原单位	(DEFAULT-12)
			RANGE = 650 * range_ratio,	--闪电弹射距离
			INTERVAL = 0.25,--闪电弹射间隔
			CD = 1,		-- 闪电内置CD (DEFAULT-0.2)
		},
	},
--慧光
	KAYA = {
		GOLD = 600 * gold_ratio,
		INTELLIGENCE = 16,
		SPELLDAMAGEAMP = 0.08,
		SPELLLIFESTEALAMP = 0.24,
		MANAREGENAMP = 0.5,
	},
--散华
	SANGE = {
		GOLD = 600 * gold_ratio,
		STRENGTH = 16,
		STATUSRESIS = 0.12,
		LIFESTEALAMP = 0.2,
		HEALTHREGENAMP = 0.2 * healthregen_ratio,
	},
--夜叉
	YASHA = {
		GOLD = 600 * gold_ratio,
		AGILITY = 16,
		ATTACKSPEED = 12 * attackspeed_ratio,
		SPEEDMULTI = 0.08,
	},
--慧夜对剑 or 智力双刀
	YASHA_AND_KAYA = {
		GOLD = 0 * gold_ratio,
		INTELLIGENCE = 16,
		AGILITY = 16,
		SPELLDAMAGEAMP = 0.16,
		ATTACKSPEED = 12 * attackspeed_ratio,
		SPEEDMULTI = 0.1,
		SPELLLIFESTEALAMP = 0.3,
		MANAREGENAMP = 0.5,
	},
--散慧对剑
	KAYA_AND_SANGE = {
		GOLD = 0 * gold_ratio,
		INTELLIGENCE = 16,
		STRENGTH = 16,
		SPELLDAMAGEAMP = 0.16,
		STATUSRESIS = 0.2,
		LIFESTEALAMP = 0.22,
		SPELLLIFESTEALAMP = 0.3,
		MANAREGENAMP = 0.5,
		HEALTHREGENAMP = 0.22 * healthregen_ratio,
	},
--散夜对剑
	SANGE_AND_YASHA = {
		GOLD = 0 * gold_ratio,
		STRENGTH = 16,
		AGILITY = 16,
		ATTACKSPEED = 12 * attackspeed_ratio,
		SPEEDMULTI = 0.1,
		STATUSRESIS = 0.2,
		LIFESTEALAMP = 0.22,
		HEALTHREGENAMP = 0.22 * healthregen_ratio,
	},
--迅疾闪光 or 敏捷跳
	SWIFT_BLINK = {
		GOLD = 1750 * gold_ratio,
		AGILITY = 25,
		SWIFT = {
			AGILITY = 35,
			SPEEDMULTI = 0.4,
			DURATION = 6 * duration_ratio,
		},
	},
--秘奥闪光 OR 智力跳
	ARCANE_BLINK = {
		GOLD = 1750 * gold_ratio,
		INTELLIGENCE = 25,
		ARCANE = {
			DURATION = 6 * duration_ratio,
			REDUCTION = 1.5,	-- 施法前摇减少50%
		},
	},
--盛势闪光 OR 力量跳
	OVERWHELMING_BLINK = {
		GOLD = 1750 * gold_ratio,
		STRENGTH = 25,
		OVERWHELMING = {
			RANGE = 800 * range_ratio,
			SPEEDMULTI = -0.5,
			ATTACKSPEED = -50 * attackspeed_ratio,
			DAMAGE = 100 * extradamage_ratio,
			RATIO = 1.5,
			DURATION = 6 * duration_ratio,
		},
	},
--灵匣
	PHYLACTERY = {
		GOLD = 0 * gold_ratio,
		ATTRIBUTES = 7,
		EXTRAHEALTH = 200 * extrahealth_ratio,
		MAXMANA = 200,
		MANAREGEN = 0.7,
		EMPOWERSPELL = {
			DAMAGE = 150 * extradamage_ratio,
			SPEEDMULTI = -0.5,
			DURATION = 1.5 * duration_ratio,
			CD = 6 * cd_ratio,
		},
	},
-- 鱼叉
	HARPOON = {
		GOLD = 1000 * gold_ratio,	
		ATTACKSPEED = 15 * attackspeed_ratio,	-- 攻速
		EXTRADAMAGE = 15 * extradamage_ratio,
		STRENGTH = 20,
		AGILITY = 10,
		INTELLIGENCE = 16,
		MANAREGEN = 2,
		DRAWFORTH = {
			SPELLRANGE = 800 * spellrange_ratio,
			CD = 19 * cd_ratio,
			MINPULLDIST = 100,
			MAXPULLDIST = 1000,
			DURATION = 0.3 * duration_ratio,
		},
	},
---------------------------------肉山-----------------------------
--不朽之守护
	AEGIS_OF_THE_IMMORTAL = {
		GOLD = 0,
	},
--奶酪
	CHEESE = {
		GOLD = 0,
		HEALTH = 2500 * extrahealth_ratio,
		HUNGER = 2500 * extrahealth_ratio,
		MANA = 2000,
	},
--刷新球碎片
	REFRESHER_SHARD = {
		GOLD = 0,
	},
}

local function tablemerge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            tablemerge(t1[k], t2[k])
		elseif t1[k] then
			table.insert(t1, v)
        else
            t1[k] = v
        end
    end
    return t1
end

if TUNING.DOTA ~= nil then
	tablemerge(TUNING.DOTA, DOTATUNING)
else
	TUNING.DOTA = DOTATUNING
end