
-------------------------------------------------------------------------------
-- DotaModifierList 与官方 SourceModifierList 几乎无区别，仅仅更改了 DotaModifierList:Get() 的返回值，并增加了一个新函数
-- 如果不使用该文件的话，每一次使用 Get() 都需要手动减法，有点麻烦
-------------------------------------------------------------------------------

DotaModifierList = Class(function(self, inst, base_value, fn)
    self.inst = inst

    -- Private members
    self._modifiers = {}
    if base_value ~= nil then
        self._modifier = 1- base_value
        self._base = 1 - base_value
    else
        self._modifier = 1
        self._base = 1
    end

    self._fn = fn or DotaModifierList.multiply
end)

DotaModifierList.multiply = function(a, b)
	return a * b
end

DotaModifierList.additive = function(a, b)
	return a + b
end

DotaModifierList.boolean = function(a, b)
    return a or b
end

DotaModifierList.diminishing = function(a, b) -- 衰减加成计算（非线性叠加） -- a是初始值，b是输入值
    return a * (1 - b)
end

-------------------------------------------------------------------------------
function DotaModifierList:Get()
	return 1 - self._modifier
end

-------------------------------------------------------------------------------
local function RecalculateModifier(inst)
    local m = inst._base
    for source, src_params in pairs(inst._modifiers) do
        for k, v in pairs(src_params.modifiers) do
            m = inst._fn(m, v)
        end
    end
    inst._modifier = m
end

-------------------------------------------------------------------------------
-- Source can be an object or a name. If it is an object, then it will handle
--   removing the multiplier if the object is forcefully removed from the game.
-- Key is optional if you are only going to have one multiplier from a source.
function DotaModifierList:SetModifier(source, m, key)
	if source == nil then
		return
	end

    if key == nil then
        key = "key"
    end

    if m == nil or m == self._base then
        self:RemoveModifier(source, key)
        return
    end

    local src_params = self._modifiers[source]
    if src_params == nil then
        self._modifiers[source] = {
            modifiers = { [key] = m },
        }

        -- If the source is an object, then add a onremove event listener to cleanup if source is removed from the game
        if type(source) == "table" then
            self._modifiers[source].onremove = function(source)
                self._modifiers[source] = nil
                RecalculateModifier(self)
            end

            self.inst:ListenForEvent("onremove", self._modifiers[source].onremove, source)
        end

        RecalculateModifier(self)
    elseif src_params.modifiers[key] ~= m then
        src_params.modifiers[key] = m
        RecalculateModifier(self)
    end
end

-------------------------------------------------------------------------------
-- Key is optional if you want to remove the entire source
function DotaModifierList:RemoveModifier(source, key)
    local src_params = self._modifiers[source]
    if src_params == nil then
        return
    elseif key ~= nil then
        src_params.modifiers[key] = nil
        if next(src_params.modifiers) ~= nil then
            --this source still has other keys
			RecalculateModifier(self)
            return
        end
    end

    --remove the entire source
    if src_params.onremove ~= nil then
        self.inst:RemoveEventCallback("onremove", src_params.onremove, source)
    end
    self._modifiers[source] = nil
    RecalculateModifier(self)
end

-------------------------------------------------------------------------------
-- Key is optional if you want to calculate the entire source
function DotaModifierList:CalculateModifierFromSource(source, key)
    local src_params = self._modifiers[source]
    if src_params == nil then
        return self._base
    elseif key == nil then
        local m = self._base
        for k, v in pairs(src_params.modifiers) do
            m = self._fn(m, v)
        end
        return m
    end
    return src_params.modifiers[key] or self._base
end

-------------------------------------------------------------------------------
--
function DotaModifierList:CalculateModifierFromKey(key)
    local m = self._base
    for source, src_params in pairs(self._modifiers) do
        for k, v in pairs(src_params.modifiers) do
			if k == key then
	            m = self._fn(m, v)
	        end
        end
    end
    return m
end



-------------------------------------------------------------------------------
return DotaModifierList