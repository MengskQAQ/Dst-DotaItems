---@diagnostic disable: lowercase-global

local L = locale ~= nil and locale ~= "zh" and locale ~= "zhr" and locale ~= "zht" -- true 英文  false 中文

name = L and "Dst Dota2 Items Test" or "Dota2 装备  测试版" -- 名称
version = "1.0.11" -- 版本 大版本，小版本，优化/bug
author = "Mengsk"   -- 作者
forumthread = ""    -- klei官方论坛地址，为空则默认是工坊的地址

-- The Githud url of this project : https://github.com/MengskQAQ/Dst-DotaItems
-- 该项目的Github地址 ： https://github.com/MengskQAQ/Dst-DotaItems

-- 描述
description = L and
[[
【Version】
Base on Dota version: 7.31  
【Warning】
This mod is still in development, may crash sever at any time, DO NOT enable it UNLESS you know what you are going to do
【Allowance】
The author of Functional Medal[workshop-1909182187] authorize me to use his code.
]]
or
[[
【版本】
基于Dota版本 7.31 而来 
【警告】
该mod仍在开发阶段，可能会导致服务器崩溃，请您在知晓此风险后再决定是否启用该mod
【授权】
本Mod中使用了恒子大佬的能力勋章[workshop-1909182187]的部分代码，已获授权
]]

dst_compatible = true   -- dst兼容
client_only_mod = false -- 是否是客户端mod
all_clients_require_mod = true  -- 是否是所有客户端都需要安装
api_version = 10    -- 饥荒api版本，固定填10
-- modicon
icon_atlas = "modicon2.xml"
icon = "modicon2.tex"

server_filter_tags = {"dota2"}
-- priority = -9999 --优先级随缘

-- mod的配置项
local multipliertable = {
    {description = "0.1", data = 0.1},
    {description = "0.3", data = 0.3},
    {description = "0.5", data = 0.5},
    {description = "0.8", data = 0.8},
    {description = "1", data = 1},
    {description = "1.3", data = 1.3},
    {description = "1.5", data = 1.5},
    {description = "1.8", data = 1.8},
    {description = "2", data = 2},
    {description = "2.3", data = 2.3},
    {description = "2.5", data = 2.5},
    {description = "2.8", data = 2.8},
    {description = "3", data = 3},
    {description = "4", data = 4},
    {description = "5", data = 5},
    {description = "6", data = 6},
    {description = "7", data = 7},
    {description = "8", data = 8},
    {description = "9", data = 9},
    {description = "10", data = 10},
}

local normalratio = {
    {description = "0.1", data = 0.1},
    {description = "0.2", data = 0.2},
    {description = "0.3", data = 0.3},
    {description = "0.4", data = 0.4},
    {description = "0.5", data = 0.5},
    {description = "0.6", data = 0.6},
    {description = "0.7", data = 0.7},
    {description = "0.8", data = 0.8},
    {description = "0.9", data = 0.9},
    {description = "1.0", data = 1.0},
    {description = "1.5", data = 1.5},
    {description = "2.0", data = 2.0},
    {description = "3.0", data = 3.0},
    {description = "4.0", data = 4.0},
    {description = "5.0", data = 5.0},
}

local smallratio = {
    {description = "0.01", data = 0.01},
    {description = "0.02", data = 0.02},
    {description = "0.03", data = 0.03},
    {description = "0.04", data = 0.04},
    {description = "0.05", data = 0.05},
    {description = "0.06", data = 0.06},
    {description = "0.07", data = 0.07},
    {description = "0.08", data = 0.08},
    {description = "0.09", data = 0.09},
    {description = "0.10", data = 0.10},
    {description = "0.15", data = 0.15},
    {description = "0.20", data = 0.20},
    {description = "0.30", data = 0.30},
    {description = "0.40", data = 0.40},
    {description = "0.50", data = 0.50},
    {description = "1.00", data = 1.00},
}

local tinyratio = {
    {description = "0.001", data = 0.001},
    {description = "0.002", data = 0.002},
    {description = "0.003", data = 0.003},
    {description = "0.004", data = 0.004},
    {description = "0.005", data = 0.005},
    {description = "0.006", data = 0.006},
    {description = "0.007", data = 0.007},
    {description = "0.008", data = 0.008},
    {description = "0.009", data = 0.009},
    {description = "0.010", data = 0.010},
    {description = "0.015", data = 0.015},
    {description = "0.020", data = 0.020},
    {description = "0.030", data = 0.030},
}

local numtable = {
    {description = "0", data = 0},
    {description = "1", data = 1},
    {description = "2", data = 2},
    {description = "3", data = 3},
    {description = "4", data = 4},
    {description = "5", data = 5},
    {description = "6", data = 6},
    {description = "7", data = 7},
    {description = "8", data = 8},
    {description = "9", data = 9},
    {description = "10", data = 10},
    {description = "13", data = 13},
    {description = "15", data = 15},
    {description = "20", data = 20},
}

configuration_options = 
{
    -------------------------------------------------------------------------------------------------
    {
        name = "DotaItem",
        label = L and "General" or "通用选项",
        hover = L and "General options" or "一些基础选项",
        options = {{description = "", data = 0}},
        default = 0
    },
    {
        name = "language",
        label = L and "Language" or "语言",
        hover = L and "Sorry, English is not suposse right now" or "语言选项",
        options = {
            {description = "Auto/自动", data = "AUTO"},
            {description = "中文", data = "ZH"},
            {description = "English", data = "EN"},
        },
        default = "AUTO",
    },
    {
        name = "volume",
        label = L and "Volume" or "音量大小",
        hover = L and "Volume about fx" or "选择一个合适的特效音量",
        options = normalratio,
        default = 0.7,
    },
    {
        name = "rechargemod",
        label = L and "Sharing Cooling Down" or "装备共享CD",
        hover = L and "Same items have the same cool down" or "同种装备间共享冷却",
        options = {
            {description = L and "Sharing CD" or "共享冷却", data = true},
            {description = L and "Independent CD" or "独立冷却", data = false},
        },
        default = false,
    },
    -- {
    --     name = "recipes_mode",
    --     label = L and "Recipes Mode" or "物品合成方式",
    --     hover = L and "gold or items" or "用物品或者金币合成",
    --     options = {
    --         {description = L and "DST Mode" or "饥荒模式", data = true},
    --         {description = L and "DOTA Mode" or "Dota模式", data = false},
    --     },
    --     default = false,
    -- },
    -------------------------------------------------------------------------------------------------
    {
        name = "DotaItem",
        label = L and "Compatibility" or "兼容性",
        hover = L and "change it when you meet question with other mods" or "调整与其他mod的兼容问题",
        options = {{description = "", data = 0}},
        default = 0
    },
    {
        name = "health_system",
        label = L and "Health System" or "生命系统",
        hover = L and "Disable it when the health system conflict with other mods " or "当生命系统与其他mod冲突时，可关闭此系统",
        options = {
            {description = L and "Enable System" or "启动系统", data = true},
            {description = L and "Disable System" or "禁用系统", data = false},
        },
        default = true,
    },
    {
        name = "health_compatibility_deafultmode",
        label = L and "Deafult Health System Compatibility" or "生命兼容性默认选项",
        hover = L and "Choose the deafult mode of health compatibility for your mod character(details in the workshop intro)" or "为mod人物选择默认兼容性的方法(详细见mod工坊)",
        options = {
            {description = L and "Mode 1" or "方式1", data = 1},
            {description = L and "Mode 2" or "方式2", data = 2},
        },
        default = 2,
    },
    {
        name = "speed_system",
        label = L and "Speed System" or "移速系统",
        hover = L and "Disable it when the speed system conflict with other mods " or "当移速系统与其他mod冲突时，可关闭此系统",
        options = {
            {description = L and "Enable System" or "启动系统", data = true},
            {description = L and "Disable System" or "禁用系统", data = false},
        },
        default = true,
    },
    {
        name = "attributes_system",
        label = L and "Attributes System" or "属性系统",
        hover = L and "Who use attributes System" or "属性系统生效范围",
        options = {
            {description = L and "White List" or "白名单制(仅部分人物)", data = 1},
            {description = L and "All suited prefabs" or "全部合适的预制体", data = 2},
            {description = L and "Disable System(Means lose the core functions)" or "禁用系统（mod核心功能失效）", data = 3},
        },
        default = 2,
    },
    {
        name = "ui_drag",
        label = L and "UI Drag" or "UI 拖拽",
        hover = L and "Can Mana and items' UI be put anywhere" or "能否拖动魔法值和装备栏的UI",
        options = {
            {description = L and "Enable" or "可拖动", data = true},
            {description = L and "Disable" or "固定", data = false},
        },
        default = true,
    },
    -------------------------------------------------------------------------------------------------
    {
        name = "DotaItem",
        label = L and "Balance Ratio" or "平衡性系数",
        hover = L and "Make a balance world yourself" or "我即是数值策划",
        options = {{description = "", data = 0}},
        default = 0
    },
    {
        name = "gold_ratio",
        label = L and "Gold Ratio" or "物品售价系数",
        hover = L and "The price of items, compared to Dota" or "与Dota内物品售价相比",
        options = normalratio,
        default = 0.1,
    },
    {
        name = "extradamage_ratio",
        label = L and "Damage Ratio" or "攻击力系数",
        hover = L and "The attack bonus of items, compared to Dota" or "与Dota内攻击力增加相比",
        options = normalratio,
        default = 0.5,
    },
    {
        name = "extrahealth_ratio",
        label = L and "Health Ratio" or "额外生命系数",
        hover = L and "The health bonus of items, compared to Dota. Avavliable only when enable the health system" or "与Dota内生命增加相比",
        options = smallratio,
        default = 0.05,
    },
    {
        name = "healthregen_ratio",
        label = L and "Health Regen Ratio" or "生命恢复系数",
        hover = L and "The health regen of items, compared to Dota. Avavliable only when enable the health system" or "与Dota内生命恢复相比",
        options = smallratio,
        default = 0.05,
    },
    {
        name = "spellrange_ratio",
        label = L and "Spellrange Ratio" or "施法范围系数",
        hover = L and "The spellrange of items, compared to Dota." or "与Dota内施法范围相比",
        options = smallratio,
        default = 0.02,
    },
    {
        name = "range_ratio",
        label = L and "Range Ratio" or "物品生效范围系数",
        hover = L and "The spell range of items, compared to Dota." or "与Dota内物品生效范围相比",
        options = smallratio,
        default = 0.02,
    },
    {
        name = "duration_ratio",
        label = L and "Duratio Ratio" or "持续时间系数",
        hover = L and "The buff time of items, compared to Dota." or "与Dota内buff的持续时间相比",
        options = normalratio,
        default = 1,
    },
    {
        name = "cd_ratio",
        label = L and "CD Ratio" or "冷却时间系数",
        hover = L and "The cd of items, compared to Dota." or "与Dota内冷却时间相比",
        options = normalratio,
        default = 1,
    },
    {
        name = "extraspeed_ratio",
        label = L and "Speed Ratio" or "速度加成系数",
        hover = L and "The extraspeed of items, compared to Dota." or "与Dota内移速相比",
        options = tinyratio,
        default = 0.01,
    },
    {
        name = "attackspeed_ratio",
        label = L and "AttackSpeed Ratio" or "攻速加成系数",
        hover = L and "The AttackSpeed of items, compared to Dota." or "与Dota内攻速加成相比",
        options = tinyratio,
        default = 0.005,
    },
    {
        name = "lifesteal_ratio",
        label = L and "LifeSteal Ratio" or "吸血系数",
        hover = L and "The LifeSteal of items, compared to Dota." or "与Dota内吸血效果相比",
        options = smallratio,
        default = 0.1,
    },
    -------------------------------------------------------------------------------------------------
    {
        name = "DotaItem",
        label = L and "Special Item" or "特殊物品",
        hover = L and "Special Item Special Settings" or "特殊物品特殊设置",
        options = {{description = "", data = 0}},
        default = 0
    },
    {
        name = "hand_of_midas_cdplus",
        label = L and "Hand Of Midas CD plus" or "点金手额外CD",
        hover = L and "Hand of midas's extra cd ratio." or "点金手额外冷却时间系数",
        options = multipliertable,
        default = 3,
    },
    {
        name = "hand_of_midas_limit",
        label = L and "Hand Of Midas Health limit of transmute" or "点金手炼化要求",
        hover = L and "the maxhealth limit you can transmute" or "点金手炼化生物的最高血量限制",
        options = {
            {description = "110", data = 110},
            {description = "200", data = 200},
            {description = "300", data = 300},
            {description = "400", data = 400},
            {description = "500", data = 500},
            {description = "600", data = 600},
        },
        default = 200,
    },
    {
        name = "blink_dagger_cdplus",
        label = L and "Blink Dagger CD plus" or "跳刀额外CD",
        hover = L and "Blink dagger's extra cd ratio." or "跳刀额外冷却时间系数",
        options = multipliertable,
        default = 1,
    },
    {
        name = "tpscroll_cdplus",
        label = L and "Tpscroll CD plus" or "回城卷轴额外CD",
        hover = L and "Tpscroll's extra cd ratio." or "回城卷轴额外冷却时间系数",
        options = multipliertable,
        default = 2,
    },
    {
        name = "bottle_bananalimit",
        label = L and "LImit of fill bottle" or "装满瓶子的条件",
        hover = L and "How many bananas need to fill bottle" or "需要多少香蕉才允许猴王装满瓶子",
        options = numtable,
        default = 1,
    },
    -------------------------------------------------------------------------------------------------
    {
        name = "DotaItem",
        label = L and "Misc" or "杂项",
        hover = L and "" or "",
        options = {{description = "", data = 0}},
        default = 0
    },
    {
        name = "debug_optional",
        label = L and "Debug" or "调试模式",
        hover = L and "Please don't turn on it" or "请勿开启调试",
        options = {
            {description = L and "ON" or "开启", data = true},
            {description = L and "OFF" or "关闭", data = false},
        },
        default = false
    },
}