-- 提供一个多配方的实现方法

local ImageButton = require "widgets/imagebutton"
local textures = {
    arrow_left_normal = "crafting_inventory_arrow_l_idle.tex",
    arrow_left_over = "crafting_inventory_arrow_l_hl.tex",
    arrow_left_disabled = "arrow_left_disabled.tex",
    arrow_left_down = "crafting_inventory_arrow_l_hl.tex",
    arrow_right_normal = "crafting_inventory_arrow_r_idle.tex",
    arrow_right_over = "crafting_inventory_arrow_r_hl.tex",
    arrow_right_disabled = "arrow_right_disabled.tex",
    arrow_right_down = "crafting_inventory_arrow_r_hl.tex",
}

AddClassPostConstruct("widgets/redux/craftingmenu_details",
function(self, owner, parent_widget, panel_width, panel_height)
    local old_PopulateRecipeDetailPanel = self.PopulateRecipeDetailPanel
    function self:PopulateRecipeDetailPanel(data, skin_name)
        old_PopulateRecipeDetailPanel(self, data, skin_name)
        if data == nil then return end

        local product = data.recipe.name
        if data.recipe.product then
            product = data.recipe.product
        end
        if #self.parent_widget.repeatRecipes[product] > 1 then  -- 判断有重复的配方才添加
            
            -- 添加左右两个按钮图标
            if self.toRecipeLeftBtn ~= nil then
                self.toRecipeLeftBtn:Kill()
            end
            if self.toRecipeRightBtn ~= nil then
                self.toRecipeLeftBtn:Kill()
            end
            self.toRecipeLeftBtn = self.AddChild(ImageButton("inmages/ui.xml", textures.arrow_left_normal,
                textures.arrow_left_over, textures.arrow_left_disabled, textures.arrow_left_down, nil, 
                {1, 1}), {0, 0})
            self.toRecipeRightBtn = self.AddChild(ImageButton("inmages/ui.xml", textures.arrow_right_normal,
                textures.arrow_right_over, textures.arrow_right_disabled, textures.arrow_right_down, nil,
                {1, 1}), {0, 0})
            
            local btnX, btnY, btnZ = self.ingredients:GetPositionXYZ()  -- 获取配方行位置
            if #self.ingredients.ingredient_widgets > 3 then    -- 配方材料超过3个，按钮移动至制作按钮
                btnX, btnY, btnZ = self.build_button_root:GetPositionXYZ()  -- 获取制造按钮位置
                btnY = btnY - 2 -- 添加偏移，增强视觉效果
            else
                btnY = btnY - 4
            end

            self.toRecipeLeftBtn:SetPosition(btnX + 20, btnY)
            self.toRecipeRightBtn:SetPosition(btnX + 220, btnY)

            local arrow_width, arrow_height = self.toRecipeLeftBtn:GetSize()
            local arrow_scale = 40 / arrow_height

            self.toRecipeLeftBtn:SetScale(arrow_scale, arrow_scale, 1)
            self.toRecipeRightBtn:SetScale(arrow_scale, arrow_scale, 1)

            -- 确认当前配方位于列表的位置
            local currentIndex = 1
            for k, v in pairs(self.parent_widget.repeatRecipes[product]) do
                if data.recipe.name == v.recipe.name then
                    currentIndex = k
                    break
                end
            end

            -- 点击按钮后切换配方
            self.toRecipeLeftBtn:SetOnClick(function()
                currentIndex = currentIndex - 1
                if currentIndex < 1 then
                    currentIndex = #self.parent_widget.repeatRecipes[product]
                end
                data = self.parent_widget.repeatRecipes[product][currentIndex]
                self:PopulateRecipeDetailPanel(data, data and ProfanityFilter:GetLastUsedSkinForItem(data.recipe.name) or nil)
            end)
            self.toRecipeRightBtn:SetOnClick(function()
                currentIndex = currentIndex + 1
                if currentIndex < #self.parent_widget.repeatRecipes[product] then
                    currentIndex = 1
                end
                data = self.parent_widget.repeatRecipes[product][currentIndex]
                self:PopulateRecipeDetailPanel(data, data and ProfanityFilter:GetLastUsedSkinForItem(data.recipe.name) or nil)
            end)
        end
    end
end)

AddClassPostConstruct("widgets/redux/craftingmenu_widget",
function(self, owner, crafting_hud, height)
    local old_ApplyFilters = self.ApplyFilters
    function self:ApplyFilters()
        old_ApplyFilters(self)
        self.repeatRecipes = {} -- 预制物的重复配方表 { "预制物代码" = {配方1, 配方2} }
        self.filtered_recipes_2 = {}

        -- 遍历过滤器筛选后的配方
        local statistics = {}
        for k, v in pairs(self.filtered_recipes) do
            local product = v.recipe.name
            if v.recipe.product then
                product = v.recipe.product
            end
            if statistics[product] == nil then
                statistics[product] = 1
                table.insert(self.filtered_recipes_2, v)    -- 多个配方仅存一个
            end
            if self.repeatRecipes[product] == nil then
                self.repeatRecipes[product] = {v}
            else
                table.insert(self.repeatRecipes[product], v)
            end
        end

        -- 更新配方表
        self.filtered_recipes = self.filtered_recipes_2

        -- 更新制作栏
        if self.crafting_hud:IsCraftingOpen() then
            self:UpdateRecipeGrid(self.focus and not TheFrontEnd.tracking_mouse)
        else
            self.recipe_grid.dirty = true
        end
    end
end)