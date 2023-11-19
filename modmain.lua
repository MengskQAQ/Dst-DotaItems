-- Base on Dota2-Version: 7.31

GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local require = GLOBAL.require
-- require("debug_dota")

-- 语言
local language = GetModConfigData("language") or "AUTO"
if language == "AUTO" then
    language = locale ~= nil and locale ~= "zh" and locale ~= "zhr" and locale ~= "zht" and "EN" or "ZH"
end

--prefab 预制体
PrefabFiles = require("dota2_prefabs")

--assets 动画音效资源(实际上资源里有一些游戏术语错了，但是懒得改了)
modimport("init/init_assets")

--tuning 各类预设数值
modimport("init/init_tuning")

-- 真视宝石
AddMinimapAtlas("minimap/dota_gem_of_true_sight_icon.xml")
-- AddMinimapImage("dota_gem_of_true_sight")

-- rpc注册
AddReplicableComponent("dotacharacter")
AddReplicableComponent("dotaattributes")
-- AddReplicableComponent("dotaitem")

--string 物品检查信息
if language == "ZH" then
    modimport("init/init_strings_zh")
else
    modimport("init/init_strings_en")
end

--component action 为自定义component添加action
modimport("init/init_componentaction")

--recipes 物品制作配方
modimport("init/init_techtree")
modimport("init/init_recipes")

--equipslots 添加装备栏位
modimport("scripts/dota_defs/dota_uidrag")  -- 让容器可以拖拽，源自能力勋章
modimport("scripts/dota_defs/dota_equipslots")

--hook hook游戏内函数/新的机制
modimport("scripts/dota_defs/dota_hook/dota_combat")    -- 战斗系统
modimport("scripts/dota_defs/dota_hook/dota_health")    -- 生命系统
modimport("scripts/dota_defs/dota_hook/dota_status_resistance") -- 状态抗性
modimport("scripts/dota_defs/dota_hook/dota_container")
modimport("scripts/dota_defs/dota_hook/dota_playeractionpicker")    -- 让客户端可以选取equipslots里的动作列表
modimport("scripts/dota_defs/dota_hook/dota_domesticatable")	-- 支配效果
modimport("scripts/dota_defs/dota_hook/dota_rechargeable")  -- 减CD
modimport("scripts/dota_defs/dota_hook/dota_playerprox")    -- 光环效果
modimport("scripts/dota_defs/dota_hook/dota_singinginspiration")    -- 攻击力加成兼容女武神歌唱值
modimport("scripts/dota_defs/dota_hook/dota_temperature")
modimport("scripts/dota_defs/dota_hook/dota_locomotor") -- 束缚效果实现
modimport("scripts/dota_defs/dota_hook/dota_inventory")
modimport("scripts/dota_defs/dota_hook/dota_attackspeed")   -- 攻速系统
modimport("scripts/dota_defs/dota_hook/dota_playercontroller")  -- TP效果实现文件之一
modimport("scripts/dota_defs/dota_hook/dota_arcane_buff")   -- 智力跳效果
modimport("scripts/dota_defs/dota_hook/dota_monkeyqueen")   -- 猴王补充魔瓶
modimport("scripts/dota_defs/dota_hook/dota_avatar")   -- bkb期间无硬直
-- modimport("scripts/dota_defs/dota_hook/dota_debuffable")   -- 装备被动属性(废案)
-- modimport("scripts/dota_defs/dota_hook/dota_widgets_craftingmenu")   -- 多配方(未测试，不启用)
modimport("scripts/dota_defs/dota_hook/dota_widgets_manaui")   -- 魔法值ui
modimport("scripts/dota_defs/dota_hook/dota_hud")   -- AOE旋转
modimport("scripts/dota_defs/dota_hook/dota_pigking")   -- 科技树触发
modimport("scripts/dota_defs/dota_hook/dota_edible")    -- 食物回复魔法
modimport("scripts/dota_defs/dota_hook/dota_player_classified")    -- 特殊音效
modimport("scripts/dota_defs/dota_hook/dota_dynamicmusic")    -- 特殊音效

--sg 新动作
modimport("scripts/stategraphs/dota_nilsg")
modimport("scripts/stategraphs/dota_sg_meteor")
modimport("scripts/stategraphs/dota_sg_tpscroll_pre")

--为实体添加组件
modimport("scripts/dota_defs/dota_creature")

--为人物添加组件
modimport("scripts/dota_defs/dota_character")

--为何这个AddRecipe2放在modimport中会失效
--预制体配方
-- --背包
AddRecipe2(
    "dota_box", {	
        Ingredient("boards", 2),
        Ingredient("redgem", 1),
        Ingredient("bluegem", 1),
    }, TECH.NONE, {	--解锁所需科技
        atlas = "images/dota_box.xml", image = "dota_box.tex"
    }, { "WEAPONS", "DOTASHOP" }
)

-- 调试模式
local debug_optional = GetModConfigData("debug_optional") or false
if debug_optional then
    modimport("scripts/dota_debug")
end

-- 添加加载界面台词

if AddLoadingTip == nil then
    return
end

-- AddLoadingTip(<string_table>, <tip_id>, <tip_string>, <controltipdata>)

-- <string_table> can be one of the following:
-- LOADING_SCREEN_SURVIVAL_TIPS
-- LOADING_SCREEN_LORE_TIPS
-- LOADING_SCREEN_CONTROL_TIPS
-- LOADING_SCREEN_CONTROL_TIPS_CONSOLE
-- LOADING_SCREEN_CONTROL_TIPS_NOT_CONSOLE
-- STRINGS.UI.LOADING_SCREEN_OTHER_TIPS (It is recommended to use this table as it is reserved for custom loading tips.)
-- <tip_id> must be a unique ID name.
-- <tip_string> is the actual tip string to be displayed.
-- <controltipdata> is a table containing input control bindings to be used in the tip string. Refer to LOADING_SCREEN_CONTROL_TIP_KEYS in constants.lua and LOADING_SCREEN_CONTROL_TIPS in strings.lua for an example usage.
-- do return end

local LORES = STRINGS.UI.LOADING_SCREEN_LORE_TIPS

if language == "ZH" then

AddLoadingTip(LORES, "DOTATIP_1", 
    "在原DotA中，邪恶镰刀的名称为Guinsoo的邪恶镰刀，\n" ..
    "这是为了感谢DotA: Allstars的其中一个开发者，他现在已经去合作开发League of Legends了")

AddLoadingTip(LORES, "DOTATIP_2",
    "Eul的神圣法杖这个名字引用自Eul，他在2003年创建了第一张DotA地图\n"..
    "之后Eul将项目留给了其他两个开发者，Guinsoo和Pendragon")

AddLoadingTip(LORES, "DOTATIP_3",
    "很多玩家(包括几个游戏中的英雄)都称呼邪恶镰刀为羊刀，\n" ..
    "因为在DotA中会将英雄变为一只小绵羊，但是在Dota2中则是变为一只小猪")

AddLoadingTip(LORES, "DOTATIP_4",
    "科勒是一个在Warcraft世界中人尽皆知的流氓，他的匕首可以让他在任何危险的情况下逃脱")

else

AddLoadingTip(LORES, "DOTATIP_1", 
    "In the original DotA, Scythe of Vyse was known as Guinsoo's Scythe of Vyse,\n" .. 
    "as a tribute to one of the developers of DotA: Allstars,\n" ..
    "who went on to co-create League of Legends.")

AddLoadingTip(LORES, "DOTATIP_2",
    "The scepter's name (and flavor text) is a reference to Eul\n," ..
    "the creator of the first DotA map back in 2003.")

AddLoadingTip(LORES, "DOTATIP_3",
    "Scythe of Vyse is known by many players (and referred to by several in-game Heroes) as Sheepstick\n" ..
    "due to turning targeted heroes into sheep in DotA.\n" ..
    "However, in Dota 2, targeted units turn into a pig.")

AddLoadingTip(LORES, "DOTATIP_4",
    "Kelen was a well known rogue in the Warcraft universe,\n" ..
    "who was known for his ability to escape from any dangerous situation\n" ..
    "thanks to the help of his dagger.")
end