------------------------------------------支配头盔 and (统御头盔 or 大支配)-------------------------------------------------

-- 选择一种id生成的方式
local LINK_METHOD = TUNING.DOTA.DOMINATE_LINK_METHOD or true    -- true always

local Dota_GetDominateID = nil

-- local HelmLst = {}
-- local TargetList = {}

if LINK_METHOD then

    -- 利用时间戳，在饥荒这种低并发的场景中，简单可靠有效
    -- 科雷在c层应存有唯一ID，也许能用上？
    Dota_GetDominateID = function ()
        local num = math.random(100000,999999)
        return string.format("%d%d", num, os.time())
    end

else

    -- 另一种方法，但是要考虑额外储存等一系列问题，过于复杂，暂不考虑
    local IDs = {}
    Dota_GetDominateID = function ()
        local id = 1
        while IDs[id] ~= nil do
            id = id + 1
        end
        IDs[id] = true
        return id
    end

end

-- local function Dota_InsertDominateList(inst, id, type)
--     if type == "helm" then
--         HelmLst[id] = inst
--     elseif type == "target" then
--         TargetList[id] = inst
--     end
-- end

-- local function Dota_GetDominateList(id, type)
--     if type == "helm" then
--         return HelmLst[id]
--     elseif type == "target" then
--         return TargetList[id]
--     end
--     return nil
-- end

GLOBAL.Dota_GetDominateID = Dota_GetDominateID
-- GLOBAL.Dota_InsertDominateList = Dota_InsertDominateList
-- GLOBAL.Dota_GetDominateList = Dota_GetDominateList