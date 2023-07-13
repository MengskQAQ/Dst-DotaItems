-------------------------------------------------瓶子----------------------------------------------
-- Todo：添加神符(10种神符)

local DotaBottle = Class(function(self, inst)
    self.inst = inst
    self.table = nil
    self.level = 4
    self.minlevel = 1
    self.maxlevel = 4
end)

function DotaBottle:SetMaxLevel(amount)
    self.maxlevel = math.max(amount, self.minlevel)
end

function DotaBottle:SetImages(table)
    self.table = table
end

function DotaBottle:CanDelta()
    return self.level > self.minlevel
end

function DotaBottle:UpdateImage()
    if self.inst.components.inventoryitem then
        for _,v in ipairs(self.table) do
            if v.level == self.level then
                self.inst.components.inventoryitem:ChangeImageName(v.image)
                return true
            end
        end
    end
    return false
end

function DotaBottle:DoDelta(val)
    self.level = math.clamp(self.level + val, self.minlevel, self.maxlevel)
    self:UpdateImage()
end

function DotaBottle:ResetLevel()
    self.level = self.maxlevel
    self:UpdateImage()
end

function DotaBottle:SetLevel(level)
    self.level = math.clamp(level, self.minlevel, self.maxlevel)
    self:UpdateImage()
end

function DotaBottle:OnSave()
    return {level = self.level}
end

function DotaBottle:OnLoad(data)
    if data.level ~= nil then
        self.level = data.level
    end
end

return DotaBottle