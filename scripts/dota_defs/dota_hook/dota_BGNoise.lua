------------------------------------------------ 神符 - 生成 ----------------------------------------------

-- local Rooms = require("map/rooms")

-- local BGNoise = Rooms.GetRoomByName("BGNoise")  -- 获取表

-- if BGNoise and BGNoise.contents then
--     if BGNoise.contents.countprefabs == nil then
--         BGNoise.contents.countprefabs = {}
--     end
--     BGNoise.contents.countprefabs.dota_runespawningground = 1
-- end

AddRoomPreInit("BGNoise", function(rooom)
    if rooom and rooom.contents then
        if rooom.contents.countprefabs == nil then
            rooom.contents.countprefabs = {}
        end
        rooom.contents.countprefabs.dota_runespawningground = 1
    end
end)