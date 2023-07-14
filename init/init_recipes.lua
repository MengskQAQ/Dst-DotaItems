local require = GLOBAL.require
local pcall = GLOBAL.pcall
local STRINGS = GLOBAL.STRINGS
require("recipe")

local TECH = GLOBAL.TECH
local Ingredient = GLOBAL.Ingredient
local AllRecipes = GLOBAL.AllRecipes
local CONSTRUCTION_PLANS = GLOBAL.CONSTRUCTION_PLANS
local CRAFTING_FILTERS = GLOBAL.CRAFTING_FILTERS


-----Asset 资源加载

-- local assets = {
    -- Asset("ATLAS", "images/station_dotashop.xml"),
    -- Asset("IMAGE", "images/station_dotashop.tex"),
    -- Asset("ATLAS", "images/inventoryimages/battle_fury.xml"),
    -- Asset("IMAGE", "images/inventoryimages/battle_fury.tex"),
-- }

-- for k,v in pairs(assets) do
    -- table.insert(Assets, v)
-- end

-- List of Vanilla Recipe Filters
-- "FAVORITES", "CRAFTING_STATION", "SPECIAL_EVENT", "MODS", "CHARACTER", "TOOLS", "LIGHT",
-- "PROTOTYPERS", "REFINE", "WEAPONS", "ARMOUR", "CLOTHING", "RESTORATION", "MAGIC", "DECOR",
-- "STRCUTURES", "CONTAINERS", "COOKING", "GARDENING", "FISHING", "SEAFARING", "RIDING",
-- "WINTER", "SUMMER", "RAIN", "EVERYTHING"

-----------------------------------------------------------------------
-- 以下lua框架出自恒子大佬的能力勋章[workshop-1909182187]
-- 来源 /scripts/medal_modframework.lua
-----------------------------------------------------------------------

-------------------------------导入自定义配方----------------------------------
local recipes_status,recipes_data = pcall(require,"dota_defs/dota_recipes")
local recipes_mode = 1 -- 采用原dota配方
if TUNING.DOTA.DSTRECIPES_MODE == true then
	recipes_mode = 2 -- 采用饥荒配方
end
-- local filters = {"DOTASHOP"}
if recipes_status then
    if recipes_data.Recipes then
        for _,data in pairs(recipes_data.Recipes) do
			local ingredientID = nil	--配方编号
			local atlas = nil	--图集文件
			local image = nil	--贴图文件
			local level = TECH.DOTASHOP_TECHTREE_ONE	-- CARNIVAL_PRIZESHOP_ONE 鸦年华客科技
			local filters = {"DOTASHOP"} -- 制作栏种类

			if #data.ingredients < recipes_mode then	
				ingredientID = 1
			else
				ingredientID = recipes_mode	
			end

			if data.dotatype then
				atlas = data.atlas or ("images/"..data.dotatype.."/"..(data.product or data.name)..".xml")
			else
				atlas = data.atlas or ("images/"..(data.product or data.name)..".xml")
			end

			image = data.image or ((data.product or data.name)..".tex")

			if data.level then
				level = data.level	
			end

			if data.filters then
				filters = data.filters
				table.insert(filters, "DOTASHOP")
			end

			AddRecipe2(data.name, data.ingredients[ingredientID],level,{
				atlas = atlas,
				image = image,
				nounlock=true,
				no_deconstruction=true,
				actionstr="CARNIVAL_PRIZESHOP",	 -- CARNIVAL_PRIZESHOP : Purchase购买
				sg_state="give",
			},filters)
        end
    end

	-- TODO：存在bug，分解配方无法正常生效，启用此部分代码会导致物品无法合成
	--[[
	if recipes_data.DeconstructRecipes then
		for _,data in pairs(recipes_data.DeconstructRecipes) do
			local ingredientID = nil	--配方编号
			if #data.ingredients < recipes_mode then
				ingredientID = 1
			else
				ingredientID = recipes_mode
			end
			AddDeconstructRecipe(data.name,data.ingredients[ingredientID])
		end
	end
	]]--
end