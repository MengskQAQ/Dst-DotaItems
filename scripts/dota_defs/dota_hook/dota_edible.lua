-- 我们根据原先食物的三维回复，通过固定公式来得到一个新的值，作为食物的魔法回复效果

-- 先设置默认三维回复值在公式中的权重
local weight_health = 2
local weight_hunger = 1
local weight_sanity = 2

-- 得到总权重与三维的各自权重占比
local weights_total = weight_health + weight_hunger + weight_sanity
local weights_health = weight_health / weights_total
local weights_hunger = weight_hunger / weights_total
local weights_sanity = weight_sanity / weights_total

-- 设置魔法回复的百分比，因为公式计算结果较大，需要缩小一下
local weight_mana = 1/20

AddComponentPostInit("edible", function(self)

    function self:Dota_GetMana(eater)

        -- 获取食物的三维回复
        local health = self:GetHealth(eater)
        local hunger = self:GetHunger(eater)
        local sanity = self:GetSanity(eater)
        
        local weights = weights_health * health + weights_hunger * hunger + weights_sanity * sanity

        if weights <= 0 then    -- 我们不希望公式得到的结果为负，因此权重总和小于0的部分舍去
            return 0
        end
    
        return math.log10(math.floor( weight_mana * weights * weights ) + 1)    -- 将里面的数取整，减少log运算量
    end
end)

-- 关于该公式的形式选择，我希望这个公式具有以下几个特点：
-- 它是光滑连续的，它具备权重，它运算量不大，它具备单调性（起码有一段具备），它能满足平衡性
-- 基于此，ChatGPT推荐了我这样的函数形式，我稍微修改了一下，得到现在的公式
-- 但其实我对这个公式不满意，它与我心目中的美感相差甚远，但我没能力进一步完善，不知其他人可有方案替代