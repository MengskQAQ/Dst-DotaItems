---------------------------------------- Dota怪物属性 - Components ---------------------------------------------
-- TODO：虽然是废案，不过要怎么优雅地给怪物加上随时间变化的属性呢
local DotaMonster = Class(function(self, inst)   -- 用于记录怪物的属性
    self.inst = inst
    ---------------------怪物加成----------------------
    self.extrahealth = 0                -- 额外生命
    self.extraarmor = 0                 -- 护甲
    self.attackspeed = 0                -- 攻速
    self.maxmana = 0                    -- 魔法总值
    self.manaregen = 0                  -- 魔法恢复
    self.extradamage = 0                -- 额外攻击力
    self.damagerange = 0                -- 额外攻击距离
    self.extraspeed = 0                 -- 额外移速
    self.dodgechance = 0                -- 闪避概率
    self.attackresistance = 0           -- 物理抗性
    self.spellresistance = 0            -- 魔法抗性
    self.statusresistance = 0           -- 状态抗性
    self.lifesteal = 0                  -- 攻击吸血
    self.truestriketable = {}           -- 克敌击先
    -- self.truestriketable_magic = {}     -- 克敌击先
    ---------------------怪物debuff----------------------
    self.spellweak = 0                  -- 受到的魔法伤害增强
    self.misschance = 0                 -- 落空概率
    self.accuracy = 0                   -- 必中
    self.decrhealthregen = 0            -- 生命回复降低
    self.decreaselifesteal = 0          -- 吸血能力降低
    ---------------------设置初始值----------------------
    self.attributesfn = nil
end,
nil,
{
})

function DotaMonster:SetDeafultAttributes(monster_type)
    if monster_type == "eqic" then
        self.extrahealth = math.random(1000, 2000)
    end
end

function DotaMonster:OnSave()
    local data = {
        extrahealth = self.extrahealth,
        extraarmor = self.extraarmor,
        attackspeed = self.attackspeed,
        maxmana = self.maxmana,
        manaregen = self.manaregen,
        extradamage = self.extradamage,
        damagerange = self.damagerange,
        extraspeed = self.extraspeed,
        dodgechance = self.dodgechance,
        attackresistance = self.attackresistance,
        spellresistance = self.spellresistance,
        statusresistance = self.statusresistance,
        lifesteal = self.lifesteal,
        truestriketable = self.truestriketable,
    }
    return data
end

function DotaMonster:OnLoad(data)
    self.extrahealth = data.extrahealth or 0
    self.extraarmor = data.extraarmor or 0
    self.attackspeed = data.attackspeed or 0
    self.maxmana = data.maxmana or 0
    self.manaregen = data.manaregen or 0
    self.extradamage = data.extradamage or 0
    self.damagerange = data.damagerange or 0
    self.extraspeed = data.extraspeed or 0
    self.dodgechance = data.dodgechance or 0
    self.attackresistance = data.attackresistance or 0
    self.spellresistance = data.spellresistance or 0
    self.statusresistance = data.statusresistance or 0
    self.lifesteal = data.lifesteal or 0
    self.truestriketable = data.truestriketable or 0
end


return DotaMonster