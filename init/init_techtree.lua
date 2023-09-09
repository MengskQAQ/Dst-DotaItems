local _G = GLOBAL
local require = _G.require

local TechTree = require("techtree")

table.insert(TechTree.AVAILABLE_TECH, "DOTASHOP_TECHTREE")

TechTree.Create = function(t)
	t = t or {}
	for i, v in ipairs(TechTree.AVAILABLE_TECH) do
	    t[v] = t[v] or 0
	end
	return t
end

_G.TECH.NONE.DOTASHOP_TECHTREE = 0
_G.TECH.DOTASHOP_TECHTREE_ONE = { DOTASHOP_TECHTREE = 1 }
_G.TECH.DOTASHOP_TECHTREE_TWO = { DOTASHOP_TECHTREE = 2 }

for k,v in pairs(TUNING.PROTOTYPER_TREES) do
    v.DOTASHOP_TECHTREE = 0
end

TUNING.PROTOTYPER_TREES.DOTASHOP_TECHTREE_ONE = TechTree.Create({
    DOTASHOP_TECHTREE = 1,
})
TUNING.PROTOTYPER_TREES.DOTASHOP_TECHTREE_TWO = TechTree.Create({
    DOTASHOP_TECHTREE = 2,
})

for i, v in pairs(_G.AllRecipes) do
	if v.level.DOTASHOP_TECHTREE == nil then
		v.level.DOTASHOP_TECHTREE = 0
	end
end

----------------------------------靠近解锁制作站------------------------------------
-- AddPrototyperDef(
	-- "pigking",
	-- {
		-- icon_atlas = "images/station_dotashop.xml", 
		-- icon_image = "station_dotashop.tex",
		-- is_crafting_station = true,
		-- action_str = "BUY",
		-- filter_text = STRINGS.UI.CRAFTING_FILTERS.DOTASHOP
	-- }
-- )

----------------------------------制作站图标------------------------------------
AddRecipeFilter({
	name = "DOTASHOP",	--独一无二的过滤器名
	atlas = "images/station_dotashop.xml",	--原始贴图64x64像素
	image = "station_dotashop.tex",
	image_size = 64,  --缩放像素	
	custom_pos = false  --不添加在下面的网格中，将会显示于上方，如FAVORITES(收藏夹)
})

--AddRecipeToFilter("tophat", "DOTASHOP")	--也可通过该api添加其他物品至此制作站