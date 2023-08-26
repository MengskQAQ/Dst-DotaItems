-------------------------------------------------瓶子----------------------------------------------
-- 神符组件主要由两部分构成，一部分是普通状态，一部分是特殊状态
-- 在表现形式上，特殊状态优先

--[[

states = {
    {rune = 神符名称, level = 使用后瓶子的使用次数, image = 瓶子图片, buff = 使用后获得的buff名},
}

level要求为连续不中断的实数
images = {
    {level = 使用次数, image = 瓶子图片, buff = 使用后获得的buff名},
}

]]--

local function OnTimerDone(inst, data)
    if data.name == "autodrink" then
        local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
        inst.components.dotabottle:Drink(owner)
    end
end

local DotaBottle = Class(function(self, inst)
    self.inst = inst
    self.images = {}    -- 普通状态列表
    self.states = {}    -- 神符状态列表 
    self.rune = nil     -- 当前的神符状态地址
    self.level = nil      -- 当前瓶子状态地址
    self.minlevel = 1
    self.maxlevel = 4

    if not self.inst.components.timer then 
        self.inst:AddComponent("timer") 
    end
    self.inst:ListenForEvent("timerdone", OnTimerDone)
end)

function DotaBottle:SetImages(images)
    self.images = images
    local levels = {}
    for _,v in pairs(self.images) do
        if v.level then
            table.insert(levels, v.level)
        end
    end
    self.minlevel = math.min(unpack(levels))
    self.maxlevel = math.max(unpack(levels))
    self:Setlevel(self.maxlevel)
end

function DotaBottle:SetStates(states)
    self.states = states
end

function DotaBottle:IsFull()
    return self.level >= self.maxlevel
end

function DotaBottle:IsEmpty()
    return self.level <= self.minlevel
end

function DotaBottle:IsStoreRune()
    return self.rune ~= nil
end

function DotaBottle:GetCurrentLevel()
    return self.level
end

function DotaBottle:GetCurrentRune()
    return self.rune
end

function DotaBottle:GetCurrentRuneImage()
    return self:IsStoreRune() and self.rune.image
end

function DotaBottle:UpdateImage()
    if self.inst.components.inventoryitem then
        local image = self:GetCurrentRuneImage() or ( self.level and self.level.image )
        if image then
            self.inst.components.inventoryitem:ChangeImageName(image)
            return true
        end
    end
    return false
end

function DotaBottle:StoreRune(rune)
    for _,v in ipairs(self.states) do
        if v.rune == rune.prefab then
            self.rune = v
            rune:Remove()
            self:UpdateImage()
            return true
        end 
    end
    return false
end

function DotaBottle:Setlevel(level)
    for _,v in pairs(self.images) do
        if v.level == level then
            self.level = v
            self:UpdateImage()
            return true
        end
    end
    return false
end

function DotaBottle:Drink(player)
    self:CancelAutoDrinkTimer()
    -- 有神符
    if self:IsStoreRune() then
        if self.rune.buff and player and player.components.debuffable then
            player.components.debuffable:AddDebuff(self.rune.buff, self.rune.buff)
        end
        local runelevel = self.rune.level or self.level.level
        self.rune = nil
        self:Setlevel(math.max(self.level.level, runelevel))
        return true
    end

    -- 无神符
    if self.level then
        if self.level.buff and player and player.components.debuffable then
            player.components.debuffable:AddDebuff(self.level.buff, self.level.buff)
        end
        self:Setlevel(self.level.level - 1)
        return true
    end
    return false
end

function DotaBottle:StartAutoDrinkTimer(time)
    self:CancelAutoDrinkTimer()
    time = time or 300
    self.inst.components.timer:StartTimer("autodrink", time)
end

function DotaBottle:CancelAutoDrinkTimer()
    self.inst.components.timer:StopTimer("autodrink")
end

-- 仅保存名称，在加载时通过名称重新指向对应表
function DotaBottle:OnSave()
    return {
        level = self.level and self.level.level,
        rune = self.rune and self.rune.rune,
    }
end

function DotaBottle:OnLoad(data)
    if data ~= nil and data.level then
        self:Setlevel(data.level)
        self:StoreRune(data.rune)
    end
end

return DotaBottle