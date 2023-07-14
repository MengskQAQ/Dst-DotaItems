---------------------------------------- Dota人物属性计算 - Components ---------------------------------------------
-- 我们希望装备系统与属性系统分离，这样怪物于人物公用一个属性系统，机制方面才比较统一
-- 但由于历史遗留问题，两个系统里的参数大部分重叠，未来可能考虑优化
-- 我们默认 dotacharacter 存在时必定存在 dotaattributes 
-- TODO: 优化方向：重新涉及数据结构，将插值替换为填值
local function on_level(self, level)
    -- 主机对current赋值时，同时调用replica的赋值函数
    self.inst.replica.dotacharacter:SetLevel(level)
end
local function on_maxlevel(self, maxlevel)
    self.inst.replica.dotacharacter:SetMaxLevel(maxlevel)
end
local function on_skillpoint(self, skillpoint)
    self.inst.replica.dotacharacter:SetSkillPoint(skillpoint)
end
local function on_exp(self, exp)
    self.inst.replica.dotacharacter:SetExp(exp)
end
local function on_maxexp(self, maxexp)
    self.inst.replica.dotacharacter:SetMaxexp(maxexp)
end
-- local function on_mana(self, mana)
--     self.inst.replica.dotacharacter:SetMana(mana)
-- end
-- local function on_maxmana(self, maxmana)
--     self.inst.replica.dotacharacter:SetMaxmana(maxmana)
-- end
local function on_strength(self, strength)
    self.inst.replica.dotacharacter:SetStrength(strength)
end
local function on_agility(self, agilit)
    self.inst.replica.dotacharacter:SetAgility(agilit)
end
local function on_intelligence(self, intelligence)
    self.inst.replica.dotacharacter:SetIntelligence(intelligence)
end

local function on_activateitem(self, target)
    self.inst.replica.dotacharacter:SetActivateItem(target)
end

local function DefaultMaxexpfn(level)  -- 每级所需经验(原版升级所需经验)  --（本来想用其他方法写，但是想了想，没有优化必要）
    local maxexp = 99999
    if level == 0 then maxexp = 100
    elseif level == 1 then maxexp = 230
    elseif level == 2 then maxexp = 370
    elseif level == 3 then maxexp = 480
    elseif level == 4 then maxexp = 580
    elseif level == 5 then maxexp = 600
    elseif level == 6 then maxexp = 720
    elseif level == 7 then maxexp = 750
    elseif level == 8 then maxexp = 890
    elseif level == 9 then maxexp = 930
    elseif level == 10 then maxexp = 970
    elseif level == 11 then maxexp = 1010
    elseif level == 12 then maxexp = 1050
    elseif level == 13 then maxexp = 1225
    elseif level == 14 then maxexp = 1250
    elseif level == 15 then maxexp = 1275
    elseif level == 16 then maxexp = 1300
    elseif level == 17 then maxexp = 1325
    elseif level == 18 then maxexp = 1500
    elseif level == 19 then maxexp = 1590
    elseif level == 20 then maxexp = 1600
    elseif level == 21 then maxexp = 1850
    elseif level == 22 then maxexp = 2100
    elseif level == 23 then maxexp = 2350
    elseif level == 24 then maxexp = 2600
    elseif level == 25 then maxexp = 3500
    elseif level == 26 then maxexp = 4500
    elseif level == 27 then maxexp = 5500
    elseif level == 28 then maxexp = 6500
    elseif level == 29 then maxexp = 7500
    elseif level == 30 then maxexp = 9999
    else maxexp = 99999
    end
    return maxexp
end

local DotaCharacter = Class(function(self, inst)   -- 参数有那么亿点点多，一直疑惑嵌套表会占用性能吗？
    self.inst = inst
    ---------------------人物基本属性----------------------
    self.level = 0                      -- 等级
    self.maxlevel = 30                  -- 最大等级
    self.exp = 0                        -- 经验
    self.maxexp = 10                    -- 最大经验
    self.skillpoint = 0                 -- 技能点
    self.primary = 3                    -- 主属性(1-力量；2-敏捷；3-智力)
    -- self.mana = 0                       -- 魔法  -- 这个比较特殊，有些物品能修改魔量，所以这个参数得在 dotaattributes 里面计算
    self.strength = 0                   -- 力量
    self.agility = 0                    -- 敏捷
    self.intelligence = 0               -- 智力
    ---------------------人物主属性加成----------------------
    self.extrahealth = 0                -- 额外生命
    self.healthregen = 0                -- 生命恢复
    self.extraarmor = 0                 -- 护甲
    self.attackspeed = 0                -- 攻速
    self.maxmana = 0                    -- 魔法总值
    self.manaregen = 0                  -- 魔法恢复
    ---------------------人物额外属性----------------------
    self.extradamage = 0                -- 额外攻击力
    self.damagerange = 0                -- 额外攻击距离
    self.extraspeed = 0                 -- 额外移速
    -- self.extraspeedpriority = 0         -- 额外移速优先度
    self.spelldamageamp = 0             -- 技能伤害增强
    self.dodgechance = 0                -- 闪避概率
    -- self.attackresistance = 0           -- 物理抗性( 该属性在 dotaattributes 里面进行计算)
    self.spellresistance = 0            -- 魔法抗性
    self.statusresistance = 0           -- 状态抗性
    self.lifesteal = 0                  -- 攻击吸血
    self.lifestealamp = 0               -- 攻击吸血增强
    self.spelllifesteal = 0             -- 技能吸血
    self.spelllifestealamp = 0          -- 技能吸血增强
    self.extraspellrange = 0            -- 施法距离加成
    self.manaregenamp = 0               -- 魔法恢复增强
    self.healthregenamp = 0             -- 生命恢复增强
    self.outhealamp = 0                 -- 提供的治疗增强
    self.healedamp = 0                  -- 接受的治疗增强    
    self.cdreduction = 0                -- 冷却减少
    ---------------------人物负面属性----------------------
    self.spellweak = 0                  -- 受到的魔法伤害增强
    self.misschance = 0                 -- 落空概率
    self.accuracy = 0                   -- 必中
    self.decrhealthregenamp = 0         -- 生命恢复降低
    self.decrlifestealamp = 0           -- 攻击吸血降低
    self.decrspelllifestealamp = 0      -- 技能吸血降低
    self.decrspelldamageamp = 0         -- 技能伤害降低
	self.decrhealedamp = 0              -- 接受的治疗降低
    ---------------------人物初始属性----------------------     --此行以上数值会在其他地方进行相应运算，此行以下数值仅用于此 components
    self.defaultstrength = 0            -- 力量
    self.defaultagility = 0             -- 敏捷
    self.defaultintelligence = 0        -- 智力
    self.defaultdodgechance = 0         -- 闪避概率
    self.defaultspelldamageamp = 0      -- 技能伤害增强
    self.defaultdamagerange = 0         -- 额外攻击距离
    self.defaultextraspellrange = 0     -- 施法距离加成
    self.defaultspellresistance = 0     -- 魔法抗性
    self.defaultextraarmor = 0          -- 护甲
    self.defaultstatusresistance = 0    -- 状态抗性
    self.defaultlifesteal = 0           -- 攻击吸血
    self.defaultlifestealamp = 0        -- 攻击吸血增强
    self.defaultspelllifesteal = 0      -- 技能吸血
    self.defaultspelllifestealamp = 0   -- 技能吸血增强
    self.defaultmanaregenamp = 0        -- 魔法恢复增强
    self.defaulthealthregenamp = 0      -- 生命恢复增强
    self.defaultouthealamp = 0          -- 提供的治疗增强
    self.defaulthealedamp = 0           -- 接受的治疗增强
    self.defaultcritical = {}           -- 暴击相关 （表存入) eg.{{critical=0.1,criticaldamage=0.5}} 
    self.defaultmisschance = 0          -- 落空概率
    self.defaultaccuracy = 0            -- 必中 (debuff)
    self.defaultdecrlifestealamp = 0       -- 攻击吸血降低 (debuff)
    self.defaultspellweak = 0           -- 受到的魔法伤害增强 (debuff)
    self.defaultcdreduction = 0         -- 冷却减少
    -------------------人物升级时属性加成-------------------
    self.levelupstrength = 0            -- 力量
    self.levelupagility = 0             -- 敏捷
    self.levelupintelligence = 0        -- 智力
    --------------------记录装备属性加成--------------------    -- 名称似乎全被编译器优化了
    self.equippable={         -- 总表
        strength = {},        -- 力量      
        agility = {},         -- 敏捷
        intelligence = {},    -- 智力
        extraspeed = {        -- 额外移速  （表存入） eg.(速度值，key) （相同key取最高值）
            boot={},
            windlace={}
        },
        extrahealth = {},     -- 额外生命
        healthregen = {},     -- 生命恢复
        manaregen = {},       -- 魔法恢复
        maxmana = {},         -- 魔法总值
        extraarmor = {},      -- 护甲
        attackspeed = {},     -- 攻速
        extradamage = {},     -- 额外攻击力 
        damagerange = {},     -- 额外攻击距离 
        manaregenamp = {},    -- 魔法恢复增强
        healthregenamp = {},  -- 生命恢复增强
        decrhealthregenamp = {},  -- 生命恢复降低
        outhealamp = {},      -- 提供的治疗增强
        healedamp = {},       -- 接受的治疗增强    
        spelldamageamp = {},  -- 技能伤害增强
        lifesteal = {},       -- 攻击吸血
        lifestealamp = {},    -- 攻击吸血增强
        spelllifesteal = {},  -- 技能吸血
        spelllifestealamp = {},  -- 技能吸血增强
        decrspelllifestealamp = {},      -- 技能吸血降低
        spellresistance = {}, -- 魔法抗性
        -- attackresistance = {},-- 物理抗性(废案)
        statusresistance = {},-- 状态抗性
        extraspellrange = {   -- 施法距离加成
            core={}
        }, 
        dodgechance = {},     -- 闪避概率
        critical = {},        -- 暴击相关 （表存入） （存入暴击率和暴击伤害）
        misschance = {},      -- 落空概率 （有好多情况会增加落空，所以用表储存）
        truestrike = {},      -- 克敌击先 （表存入） （许多物品拥有，所以存入概率、对应的伤害、对应key） eg.{{概率,伤害,武器}}
        accuracy = {},        -- 必中（虽然是debuff，但为了统一，还是用这个命名了）
        decrlifestealamp = {},   -- 攻击吸血降低
        decrspelldamageamp = {},         -- 技能伤害降低
        decrhealedamp = {},     -- 接受的治疗降低
        spellweak = {},        -- 受到的魔法伤害增强
        cdreduction = {},       -- 冷却减少
        block = {}              -- 格挡
    }
    ---------------------相关函数-----------------------
    self.maxexpfn = DefaultMaxexpfn                 -- 升级所需经验函数
    ---------------------动作相关-----------------------
    self.activateitem = nil
    --------------DotaAttributes相关key----------------
    self.source = "dota"
    self.key = "equip"
    -----------------------被动------------------------
    self.abilities = {}
    self.equipments = {}
    self.followsymbol = ""
    self.followoffset = Vector3(0, 0, 0)
end,
nil,
{
    level = on_level,
    maxlevel = on_maxlevel,
    exp = on_exp,
    maxexp = on_maxexp,
    -- mana = on_mana,
    -- maxmana = on_maxmana,
    skillpoint = on_skillpoint,
    strength = on_strength,
    agilit = on_agility,
    intelligence = on_intelligence,

    activateitem = on_activateitem,
})

--------------------------------------------------------------------------------------------
------------------------------------------动作相关-------------------------------------------
--------------------------------------------------------------------------------------------

function DotaCharacter:SetActivateItem(item)
    self.activateitem = item
end
function DotaCharacter:GetActivateItem()
    return self.activateitem
end

--------------------------------------------------------------------------------------------
-----------------------------------------设立初始值------------------------------------------
--------------------------------------------------------------------------------------------

function DotaCharacter:SetMaxexpFn(maxexpfn)   -- 设置升级所需经验函数
    self.maxexpfn = maxexpfn or DefaultMaxexpfn
end
function DotaCharacter:SetDefaultStrength(defaultstrength)     -- 设置初始力量
    if defaultstrength ~= nil     then self.defaultstrength = defaultstrength end
end
function DotaCharacter:SetDefaultAgility(defaultagility)       -- 设置初始敏捷
    if defaultagility ~= nil      then self.defaultagility = defaultagility   end
end
function DotaCharacter:SetDefaultIntelligence(defaultintelligence)     -- 设置初始智力
    if defaultintelligence ~= nil then self.defaultintelligence = defaultintelligence end
end
function DotaCharacter:SetLevelUpAttributes(strength,agility,intelligence)     -- 人物升级时的属性加成
    if strength     ~= nil  then self.levelupstrength     = strength        end
    if agility      ~= nil  then self.levelupagility      = agility         end
    if intelligence ~= nil  then self.levelupintelligence = intelligence    end
end
--------------------------------------------------------------------------------------------
-----------------------------------------主属性------------------------------------------
--------------------------------------------------------------------------------------------
function DotaCharacter:SetPrimary(primary)       -- 设置主属性
    if primary ~= nil      then self.primary = primary   end
end
function DotaCharacter:GetPrimary()       -- 设置主属性
    return self.primary
end
function DotaCharacter:GetPrimaryAttribute()       -- 设置主属性
    local primary = self.primary
    if primary == 3 then
        return self.intelligence
    elseif primary == 2 then
        return self.agility
    elseif primary == 1 then
        return self.strength
    else
        return 0
    end
end
--------------------------------------------------------------------------------------------
-------------------------------------三维属性增益--------------------------------------------
--------------------------------------------------------------------------------------------

local function SumTable(t)  -- 加成计算（线性叠加）
    if #t > 0 then
        local sum = 0
        for _, v in pairs(t) do
            sum = sum + v
        end
        return sum
    end
    return 0
end

local function SumTable2(t)  -- 衰减加成计算（非线性叠加）  -- 输入值不应为1
    if #t > 0 then
        local sum2 = 1
        for _, v in pairs(t) do
            sum2 = sum2 * (1 - v)
        end
        return sum2
    end
    return 1
end

local function CalcExtraHealth(self) -- 额外生命
    self.extrahealth = self.strength * 20 * TUNING.DOTA.RATIO.EXTRAHEALTH + SumTable(self.equippable.extrahealth)
    -- self.inst.components.dotaattributes.extrahealth:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes:AddExtraHealth(self.source, self.extrahealth, self.key)
end
local function CalcHealthRegen(self) -- 生命恢复
    self.healthregen = self.strength * 0.1 * TUNING.DOTA.RATIO.HEALTHREGEN + SumTable(self.equippable.healthregen)
    -- self.inst.components.dotaattributes:RemoveHealthRegen(self.source, self.key)
    self.inst.components.dotaattributes:AddHealthRegen(self.source, self.healthregen, self.key)
end
-- local function CalcAttackResistance(self) -- 物理抗性
--     local armor = (self.extraarmor * 0.06)/(1 + 0.06 * math.abs(self.extraarmor))
--     self.attackresistance =  1 - (1 - self.defaultattackresistance) * SumTable2(self.equippable.attackresistance) * (1 - armor)
-- end
local function CalcExtraArmor(self) -- 护甲
    self.extraarmor = self.agility * 0.33 / 2 + SumTable(self.equippable.extraarmor) + self.defaultextraarmor
    -- self.inst.components.dotaattributes:RemoveExtraArmor(self.source, self.key)
    self.inst.components.dotaattributes:AddExtraArmor(self.source, self.extraarmor, self.key)
end
local function CalcAttackSpeed(self) -- 攻速
    self.attackspeed = self.agility * 1 * TUNING.DOTA.RATIO.ATTACKSPEED + SumTable(self.equippable.attackspeed)
    -- self.inst.components.dotaattributes:RemoveAttackSpeed(self.source, self.key)
    self.inst.components.dotaattributes:AddAttackSpeed(self.source, self.attackspeed, self.key)
end
local function CalcMaxMana(self) -- 魔法总值
    self.maxmana = self.intelligence * 12 + SumTable(self.equippable.maxmana)
    -- self.inst.components.dotaattributes.maxmana:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes:AddMaxMana(self.source, self.maxmana, self.key)
end
local function CalcManaRegen(self) -- 魔法恢复
    self.manaregen = self.intelligence * 0.1 / 2 + SumTable(self.equippable.manaregen)
    -- self.inst.components.dotaattributes:RemoveManaRegen(self.source, self.key)
    self.inst.components.dotaattributes:AddManaRegen(self.source, self.manaregen, self.key)
end
local function CalcAttributesGain(self)
    CalcExtraHealth(self)   CalcHealthRegen(self)   CalcExtraArmor(self)
    CalcAttackSpeed(self)   CalcMaxMana(self)       CalcManaRegen(self)
end

--------------------------------------------------------------------------------------------
-------------------------------------详细增益统计--------------------------------------------
--------------------------------------------------------------------------------------------
local extradamage_ratio = TUNING.DOTA.RATIO.EXTRADAMAGE -- 装备里计算过系数了，这里不重复计算
local function CalcExtradamage(self) -- 额外攻击力
    local primary = self.primary
    if primary == 3 then    -- 智力主属性
        self.extradamage = self.intelligence * extradamage_ratio + SumTable(self.equippable.extradamage)
    elseif primary == 2 then    -- 敏捷主属性
        self.extradamage = self.agility * extradamage_ratio + SumTable(self.equippable.extradamage)
    elseif primary == 1 then    -- 力量主属性
        self.extradamage = self.strength * extradamage_ratio + SumTable(self.equippable.extradamage)
    else
        self.extradamage = SumTable(self.equippable.extradamage)
    end
    -- self.inst.components.dotaattributes.extradamage:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.extradamage:SetModifier(self.source, self.extradamage, self.key)
end
local function CalcDamageRange(self) -- 额外攻击距离
    self.damagerange = self.defaultdamagerange + SumTable(self.equippable.damagerange)
    -- self.inst.components.dotaattributes:RemoveDamageRange(self.source, self.key)
    self.inst.components.dotaattributes:AddDamageRange(self.source, self.damagerange, self.key)
end
-- 因为 RemoveByValueFromTable 的局限性，所以绿鞋会出现很神奇的bug，因此采用了keyvalue的形式
local function CalcExtraSpeed(self) -- 额外移速
    local speed = 0
    local extraspeed = 0
    for _, source in pairs(self.equippable.extraspeed) do
        for _, value in pairs(source) do
            speed = math.max(speed, value)
        end
        extraspeed = extraspeed + speed
    end
    self.extraspeed = extraspeed
    -- self.inst.components.dotaattributes:RemoveExtraSpeed(self.source, self.key)
    self.inst.components.dotaattributes:AddExtraSpeed(self.source, self.extraspeed, self.key)
end
local function CalcManaRegenAMP(self) -- 魔法恢复增强
    self.manaregenamp = 1 - (1 - self.defaultmanaregenamp) * SumTable2(self.equippable.manaregenamp)
    -- self.inst.components.dotaattributes:RemoveManaRegenAMP(self.source, self.key)
    self.inst.components.dotaattributes:AddManaRegenAMP(self.source, self.manaregenamp, self.key)
end
local function CalcHealthRegenAMP(self) -- 生命恢复增强
    self.healthregenamp = 1 - (1 - self.defaulthealthregenamp) * SumTable2(self.equippable.healthregenamp)
    -- self.inst.components.dotaattributes:RemoveHealthRegenAMP(self.source, self.key)
    self.inst.components.dotaattributes:AddHealthRegenAMP(self.source, self.healthregenamp, self.key)
end
local function CalcDecrHealthRegenAMP(self) -- 生命恢复降低
    self.decrhealthregenamp = 1 - SumTable2(self.equippable.decrhealthregenamp)
    -- self.inst.components.dotaattributes:RemoveDecrHealthRegenAMP(self.source, self.key)
    self.inst.components.dotaattributes:AddDecrHealthRegenAMP(self.source, self.decrhealthregenamp, self.key)
end
local function CalcOutHealAMP(self) -- 提供的治疗增强
    self.outhealamp = 1 - (1 - self.defaultouthealamp) * SumTable2(self.equippable.outhealamp)
    -- self.inst.components.dotaattributes.outhealamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.outhealamp:SetModifier(self.source, self.outhealamp, self.key)  
end
local function CalcHealedAMP(self) -- 接受的治疗增强
    self.healedamp = 1 - (1 - self.defaulthealedamp) * SumTable2(self.equippable.healedamp)
    -- self.inst.components.dotaattributes.healedamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes:AddHealedAMP(self.source, self.healedamp, self.key)
end
local function CalcSpellDamageAMP(self) -- 技能伤害增强
    self.spelldamageamp = 1 - (1 - self.defaultspelldamageamp) * SumTable2(self.equippable.spelldamageamp)
    -- self.inst.components.dotaattributes.spelldamageamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.spelldamageamp:SetModifier(self.source, self.spelldamageamp, self.key)
end
local function CalcLifeSteal(self) -- 攻击吸血
    self.lifesteal = 1 - (1 - self.defaultlifesteal) * SumTable2(self.equippable.lifesteal)
    -- self.inst.components.dotaattributes.lifesteal:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.lifesteal:SetModifier(self.source, self.lifesteal, self.key)
end
local function CalcLifeStealAMP(self) -- 攻击吸血增强
    self.lifestealamp = 1 - (1 - self.defaultlifestealamp) * SumTable2(self.equippable.lifestealamp)
    -- self.inst.components.dotaattributes.lifestealamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.lifestealamp:SetModifier(self.source, self.lifestealamp, self.key)
end
local function CalcSpellLifeSteal(self) -- 技能吸血
    self.spelllifesteal = 1 - (1 - self.defaultspelllifesteal) * SumTable2(self.equippable.spelllifesteal)
    -- self.inst.components.dotaattributes.spelllifesteal:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.spelllifesteal:SetModifier(self.source, self.spelllifesteal, self.key)
end
local function CalcSpellLifeStealAMP(self) -- 技能吸血增强
    self.spelllifestealamp = 1 - (1 - self.defaultspelllifestealamp) * SumTable2(self.equippable.spelllifestealamp)
    -- self.inst.components.dotaattributes.spelllifestealamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.spelllifestealamp:SetModifier(self.source, self.spelllifestealamp, self.key)
end
local function CalcSpellResistance(self) -- 魔法抗性
    self.spellresistance =  1 - (1 - self.defaultspellresistance) * SumTable2(self.equippable.spellresistance)
    -- self.inst.components.dotaattributes.spellresistance:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.spellresistance:SetModifier(self.source, self.spellresistance, self.key)
end
local function CalcStatusResistance(self) -- 状态抗性
    self.statusresistance = 1 - (1 - self.defaultstatusresistance) * SumTable2(self.equippable.statusresistance)
    -- self.inst.components.dotaattributes.statusresistance:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.statusresistance:SetModifier(self.source, self.statusresistance, self.key)
end
local function CalcExtraSpellRange(self) -- 施法距离加成
    local range = 0
    for _, v in pairs(self.equippable.extraspellrange) do
        if #v > 0 then
            range = range + math.max(unpack(v))
        end
    end
    self.extraspellrange = self.defaultextraspellrange + range
    -- self.inst.components.dotaattributes.extraspellrange:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.extraspellrange:SetModifier(self.source, self.extraspellrange, self.key)
end
local function CalcDodgeChance(self) -- 闪避概率
    self.dodgechance = 1 - (1 - self.defaultdodgechance) * SumTable2(self.equippable.dodgechance)
    -- self.inst.components.dotaattributes.dodgechance:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.dodgechance:SetModifier(self.source, self.dodgechance, self.key)
end
local function CalcMissChance(self) -- 落空概率
    self.misschance = 1 - (1 - self.defaultmisschance) * SumTable2(self.equippable.misschance)
    -- self.inst.components.dotaattributes.misschance:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.misschance:SetModifier(self.source, self.misschance, self.key)
end
local function CalcAccuracy(self) -- 必中
    self.accuracy = 1 - (1 - self.defaultaccuracy) * SumTable2(self.equippable.accuracy)
    -- self.inst.components.dotaattributes.accuracy:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.accuracy:SetModifier(self.source, self.accuracy, self.key)
end
local function CalcDecrLifeStealAMP(self) -- 攻击吸血降低
    self.decrlifestealamp = 1 - (1 - self.defaultdecrlifestealamp) * SumTable2(self.equippable.decrlifestealamp)
    -- self.inst.components.dotaattributes.decrlifestealamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.decrlifestealamp:SetModifier(self.source, self.decrlifestealamp, self.key)
end
local function CalcDecrSpellLifeStealAMP(self) -- 技能吸血降低
    self.decrspelllifestealamp = 1 - SumTable2(self.equippable.decrspelllifestealamp)
    -- self.inst.components.dotaattributes.decrspelllifestealamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.decrspelllifestealamp:SetModifier(self.source, self.decrspelllifestealamp, self.key)
end
local function CalcDecrSpellDamageAMP(self) -- 技能伤害降低
    self.decrspelldamageamp = 1 - SumTable2(self.equippable.decrspelldamageamp)
    -- self.inst.components.dotaattributes.decrspelldamageamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.decrspelldamageamp:SetModifier(self.source, self.decrspelldamageamp, self.key)
end
local function CalcDecrHealedAMP(self) -- 接受的治疗降低
    self.decrhealedamp = 1 - SumTable2(self.equippable.decrhealedamp)
    -- self.inst.components.dotaattributes.decrhealedamp:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes:AddDecrHealedAMP(self.source, self.decrhealedamp, self.key)
end
local function CalcSpellWeak(self) -- 受到的魔法伤害增强
    self.spellweak = 1 - (1 - self.defaultspellweak) * SumTable2(self.equippable.spellweak)
    -- self.inst.components.dotaattributes.spellweak:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.spellweak:SetModifier(self.source, self.spellweak, self.key)
end
local function CalcCDReduction(self) -- 冷却减少
    self.cdreduction = 1 - (1 - self.defaultcdreduction) * SumTable2(self.equippable.cdreduction)
    -- self.inst.components.dotaattributes.cdreduction:RemoveModifier(self.source, self.key)
    self.inst.components.dotaattributes.cdreduction:SetModifier(self.source, self.cdreduction, self.key)
end

function DotaCharacter:CalcAllAttributesGain()
    self:CalcFinalAttributes()      CalcDamageRange(self)       CalcManaRegenAMP(self)      CalcSpellDamageAMP(self)     -- 此处重复计算了2次魔法恢复，不过应该没什么问题，吧
    CalcLifeSteal(self)             CalcSpellLifeSteal(self)    CalcSpellLifeStealAMP(self) CalcSpellResistance(self)   -- CalcAttackResistance(self)  
    CalcExtraSpellRange(self)       CalcDodgeChance(self)       CalcMissChance(self)        CalcAccuracy(self)          CalcDecrLifeStealAMP(self)
    CalcOutHealAMP(self)            CalcHealedAMP(self)         CalcSpellWeak(self)         CalcCDReduction(self)       CalcHealthRegenAMP(self)
    CalcDecrHealthRegenAMP(self)    CalcDecrSpellLifeStealAMP(self) CalcDecrSpellDamageAMP(self)    CalcLifeStealAMP(self)  CalcStatusResistance(self)
    CalcDecrHealedAMP(self)
end

--------------------------------------------------------------------------------------------
------------------------------------三维属性计算---------------------------------------------
--------------------------------------------------------------------------------------------

local function CalcFinalStrength(self)  -- 力量
    self.strength = self.defaultstrength + self.level * self.levelupstrength + SumTable(self.equippable.strength)
    CalcExtraHealth(self)   CalcHealthRegen(self)   CalcExtradamage(self)
end
local function CalcFinalAgility(self)   -- 敏捷
    self.agility = self.defaultagility + self.level * self.levelupagility + SumTable(self.equippable.agility)
    CalcExtraArmor(self)    CalcAttackSpeed(self)   CalcExtradamage(self)
end
local function CalcFinalIntelligence(self)  -- 智力
    self.intelligence = self.defaultintelligence + self.level * self.levelupintelligence + SumTable(self.equippable.intelligence)
    CalcMaxMana(self)       CalcManaRegen(self)     CalcExtradamage(self)
end

function DotaCharacter:CalcFinalAttributes()    -- 三维
    self.strength     = self.defaultstrength + self.level * self.levelupstrength     + SumTable(self.equippable.strength)
    self.agility      = self.defaultagility + self.level * self.levelupagility      + SumTable(self.equippable.agility)
    self.intelligence = self.defaultintelligence + self.level * self.levelupintelligence + SumTable(self.equippable.intelligence)
    CalcAttributesGain(self)    CalcExtradamage(self)
end

--------------------------------------------------------------------------------------------
----------------------------------装备时记录属性加成------------------------------------------
--------------------------------------------------------------------------------------------

function DotaCharacter:AddStrength(strength)   -- 力量
    if strength ~= nil then    table.insert(self.equippable.strength, tonumber(strength))  CalcFinalStrength(self) end
end
function DotaCharacter:AddAgility(agility) -- 敏捷
    if agility ~= nil then    table.insert(self.equippable.agility, tonumber(agility))  CalcFinalAgility(self)  end
end
function DotaCharacter:AddIntelligence(intelligence)   -- 智力
    if intelligence ~= nil then    table.insert(self.equippable.intelligence, tonumber(intelligence)) CalcFinalIntelligence(self)  end
end
function DotaCharacter:AddAttributes(attributes)  -- 三维
    if attributes ~= nil  then
        table.insert(self.equippable.strength,     tonumber(attributes))    CalcFinalStrength(self)
        table.insert(self.equippable.agility,      tonumber(attributes))    CalcFinalAgility(self)
        table.insert(self.equippable.intelligence, tonumber(attributes))    CalcFinalIntelligence(self)
    end
end
function DotaCharacter:AddExtraHealth(extrahealth) -- 额外生命
    if extrahealth ~= nil then    table.insert(self.equippable.extrahealth, tonumber(extrahealth))  CalcExtraHealth(self) end
end
function DotaCharacter:AddHealthRegen(healthregen) -- 生命恢复
    if healthregen ~= nil then    table.insert(self.equippable.healthregen, tonumber(healthregen))  CalcHealthRegen(self) end
end
function DotaCharacter:AddManaRegen(manaregen) -- 魔法恢复
    if manaregen ~= nil then    table.insert(self.equippable.manaregen, tonumber(manaregen))  CalcManaRegen(self) end
end
function DotaCharacter:AddMaxMana(maxmana) -- 魔法总值
    if maxmana ~= nil then    table.insert(self.equippable.maxmana, tonumber(maxmana))  CalcMaxMana(self) end
end
function DotaCharacter:AddExtraArmor(extraarmor)   -- 护甲
    if extraarmor ~= nil then    table.insert(self.equippable.extraarmor, tonumber(extraarmor))  CalcExtraArmor(self) end
end
function DotaCharacter:AddAttackSpeed(attackspeed) -- 攻速
    if attackspeed ~= nil then    table.insert(self.equippable.attackspeed, tonumber(attackspeed))  CalcAttackSpeed(self) end
end
function DotaCharacter:AddExtraDamage(extradamage) -- 额外攻击力 
    if extradamage ~= nil then    table.insert(self.equippable.extradamage, tonumber(extradamage))  CalcExtradamage(self) end
end
function DotaCharacter:AddDamageRange(damagerange) -- 额外攻击距离 
    if damagerange ~= nil then    table.insert(self.equippable.damagerange, tonumber(damagerange))  CalcDamageRange(self) end
end
function DotaCharacter:AddManaRegenAMP(manaregenamp)   -- 魔法恢复增强
    if manaregenamp ~= nil then    table.insert(self.equippable.manaregenamp, tonumber(manaregenamp))  CalcManaRegenAMP(self) end
end
function DotaCharacter:AddHealthRegenAMP(healthregenamp)   -- 生命恢复增强
    if healthregenamp ~= nil then    table.insert(self.equippable.healthregenamp, tonumber(healthregenamp))  CalcHealthRegenAMP(self) end
end
function DotaCharacter:AddDecrHealthRegenAMP(decrhealthregenamp)   -- 生命恢复降低
    if decrhealthregenamp ~= nil then    table.insert(self.equippable.decrhealthregenamp, tonumber(decrhealthregenamp))  CalcDecrHealthRegenAMP(self) end
end
function DotaCharacter:AddOutHealAMP(outhealamp)   -- 提供的治疗增强
    if outhealamp ~= nil then    table.insert(self.equippable.outhealamp, tonumber(outhealamp))  CalcOutHealAMP(self) end
end
function DotaCharacter:AddHealedAMP(healedamp)   -- 接受的治疗增强
    if healedamp ~= nil then    table.insert(self.equippable.healedamp, tonumber(healedamp))  CalcHealedAMP(self) end
end
function DotaCharacter:AddSpellDamageAMP(spelldamageamp)   -- 技能伤害增强
    if spelldamageamp ~= nil then    table.insert(self.equippable.spelldamageamp, tonumber(spelldamageamp))  CalcSpellDamageAMP(self) end
end
function DotaCharacter:AddLifesteal(lifesteal) -- 攻击吸血
    if lifesteal ~= nil then    table.insert(self.equippable.lifesteal, tonumber(lifesteal))  CalcLifeSteal(self) end
end
function DotaCharacter:AddLifestealAMP(lifestealamp) -- 攻击吸血增强
    if lifestealamp ~= nil then    table.insert(self.equippable.lifestealamp, tonumber(lifestealamp))  CalcLifeStealAMP(self) end
end
function DotaCharacter:AddSpellLifesteal(spelllifesteal)   -- 技能吸血
    if spelllifesteal ~= nil then    table.insert(self.equippable.spelllifesteal, tonumber(spelllifesteal))  CalcSpellLifeSteal(self) end
end
function DotaCharacter:AddSpellLifestealAMP(spelllifestealamp)   -- 技能吸血增强
    if spelllifestealamp ~= nil then    table.insert(self.equippable.spelllifestealamp, tonumber(spelllifestealamp))  CalcSpellLifeStealAMP(self) end
end
function DotaCharacter:AddSpellResistance(spellresistance) -- 魔法抗性
    if spellresistance ~= nil then    table.insert(self.equippable.spellresistance, tonumber(spellresistance))  CalcSpellResistance(self) end
end
-- function DotaCharacter:Addattackresistance(attackresistance)   -- 物理抗性
--     if attackresistance ~= nil then    table.insert(self.equippable.attackresistance, tonumber(attackresistance))  CalcAttackResistance(self) end
-- end
function DotaCharacter:AddStatusResistance(statusresistance)   -- 状态抗性
    if statusresistance ~= nil then    table.insert(self.equippable.statusresistance, tonumber(statusresistance))  CalcStatusResistance(self) end
end
function DotaCharacter:AddExtraSpellRange(extraspellrange, key) -- 施法距离加成
    if extraspellrange ~= nil then
        if type(key) ~= "string" then key = "deafult" end
        -- key = string.format("%s", key)
        if self.equippable.extraspeed[key] then
            table.insert(self.equippable.extraspellrange[key], extraspellrange)
        else
            self.equippable.extraspeed[key] = {extraspellrange}
        end
        CalcExtraSpellRange(self)
    end
end
function DotaCharacter:AddDodgeChance(dodgechance) -- 闪避概率
    if dodgechance ~= nil then    table.insert(self.equippable.dodgechance, tonumber(dodgechance))  CalcDodgeChance(self) end
end
function DotaCharacter:AddMissChance(misschance) -- 落空概率
    if misschance ~= nil then    table.insert(self.equippable.misschance, misschance) end
end
function DotaCharacter:AddBlock(probability, damage) -- 格挡
    if probability ~= nil and damage ~= nil then
        local blocktable = {pr = probability, damage = damage}
        table.insert(self.equippable.block, blocktable)
    end
end
function DotaCharacter:AddCritical(critical, criticaldamage) -- 暴击相关       -- 储存暴击率和暴击伤害的格式为table
    if critical ~= nil and criticaldamage ~= nil then
        local criticaltable = {critical = critical, criticaldamage = criticaldamage}
        table.insert(self.equippable.critical, criticaltable)
        if self.inst.components.combat ~= nil then
            self.inst.components.combat:ResetTrueStrikeTable()
        end
    end
end
function DotaCharacter:AddTrueStrike(probability, damage, weapon) -- 克敌击先
    if probability ~= nil and damage ~= nil then
        local truestriketable = {pr = probability, damage = damage, weapon = weapon}
        table.insert(self.equippable.truestrike, truestriketable)
        if self.inst.components.combat ~= nil then
            self.inst.components.combat:ResetTrueStrikeTable()
        end
    end
end
function DotaCharacter:AddExtraSpeed(source, extraspeed, key) -- 额外移速
    if source ~= nil and extraspeed ~= nil then
        -- key = string.format("%s", key)
        local src_params = self.equippable.extraspeed[source]
        if src_params == nil then
            if key == "unique" then
                self.equippable.extraspeed[source] = {extraspeed}
            else
                self.equippable.extraspeed[source] = {[key] = extraspeed}
            end
        else
            if key == nil then
                table.insert(self.equippable.extraspeed[source], extraspeed)
            elseif src_params[key] ~= extraspeed then
                src_params[key] = extraspeed
            end
        end
        CalcExtraSpeed(self)
    end
end
function DotaCharacter:AddAccuracy(accuracy) -- 必中
    if accuracy ~= nil then    table.insert(self.equippable.accuracy, accuracy)    CalcAccuracy(self)  end
end
function DotaCharacter:AddDecrLifeStealAMP(decrlifestealamp) -- 攻击吸血降低
    if decrlifestealamp ~= nil then    table.insert(self.equippable.decrlifestealamp, decrlifestealamp)    CalcDecrLifeStealAMP(self)   end
end
function DotaCharacter:AddDecrSpellLifeStealAMP(decrspelllifestealamp) -- 技能吸血降低
    if decrspelllifestealamp ~= nil then    table.insert(self.equippable.decrspelllifestealamp, decrspelllifestealamp)    CalcDecrSpellLifeStealAMP(self)   end
end 
function DotaCharacter:AddDecrSpellDamageAMP(decrspelldamageamp) -- 技能伤害降低
    if decrspelldamageamp ~= nil then    table.insert(self.equippable.decrspelldamageamp, decrspelldamageamp)    CalcDecrSpellDamageAMP(self)   end
end
function DotaCharacter:AddDecrHealedAMP(decrhealedamp) -- 接受的治疗降低
    if decrhealedamp ~= nil then    table.insert(self.equippable.decrhealedamp, decrhealedamp)    CalcDecrHealedAMP(self)   end
end
function DotaCharacter:AddSpellWeak(spellweak) -- 受到的魔法伤害增强
    if spellweak ~= nil then    table.insert(self.equippable.spellweak, spellweak)    CalcSpellWeak(self)   end
end
function DotaCharacter:AddCDReduction(cdreduction) -- 冷却减少
    if cdreduction ~= nil then    table.insert(self.equippable.cdreduction, cdreduction)    CalcCDReduction(self)   end
end
--------------------------------------------------------------------------------------------
--------------------------------脱下装备时删除属性加成----------------------------------------
--------------------------------------------------------------------------------------------

-- -- 比较两个table内元素是否相同，一般化写法（适用此类表格 eg.{a=1,b=2}） 
-- local function TableCompare(t1, t2)  -- 当然了，一些特殊情况没考虑，例如元素个数比较等等
--     for k1, v1 in pairs(t1) do  -- 遍历t1所有元素
--         local v2 = t2[k1]   -- 获取t2表中k1位置的值
--         if v2 == nil or v1 ~= v2 then   -- 如果值不存在，或者值与v1不一样，直接返回
--             return false
--         end
--     end
--     return true -- 全部通过返回true
-- end

-- 比较两个table内元素是否相同，特殊写法（仅适用特殊写法，例如本component采用insert填充元素） 
local function TableCompare(t1, t2) 
    for i=1,#t1,1 do
        if t1[i] ~= t2[i] then return false end
    end
    return true -- 全部通过返回true
end

-- TODO：这实在是太占用性能了，未来完成度高了后，可以降低可读性时，
-- 装备记录就不再使用key值，而是采用默认排序，这样就可以直接用123来代替key
-- 无论是在记录，读取，更改，都可以做到优化

local function RemoveByValueFromTable(t, value)     -- 删除指定表中的某个指定元素
    local i = 1
    if type(value) == "table" then  -- 指定元素为表
        while(t[i]) do
            if TableCompare(t[i], value) then
                table.remove(t , i) -- 官方都是判空，那么用判空代替remove会不会更好些
                break
            else
                i = i + 1
            end
        end
    else     -- 指定元素为数字
        while(t[i]) do
            if t[i] == value then
                table.remove(t , i)
                break
            else
                i = i + 1
            end
        end
    end
end

function DotaCharacter:RemoveStrength(strength)    -- 力量
    if strength ~= nil then    RemoveByValueFromTable(self.equippable.strength, strength)   CalcFinalStrength(self) end
end
function DotaCharacter:RemoveAgility(agility)  -- 敏捷
    if agility ~= nil then     RemoveByValueFromTable(self.equippable.agility, agility) CalcFinalAgility(self)  end
end
function DotaCharacter:RemoveIntelligence(intelligence)    -- 智力
    if intelligence ~= nil then    RemoveByValueFromTable(self.equippable.intelligence, intelligence)   CalcFinalIntelligence(self)  end
end
function DotaCharacter:RemoveAttributes(attributes)  -- 三维
    if attributes ~= nil  then
        RemoveByValueFromTable(self.equippable.strength,     attributes)    CalcFinalStrength(self)
        RemoveByValueFromTable(self.equippable.agility,      attributes)    CalcFinalAgility(self)
        RemoveByValueFromTable(self.equippable.intelligence, attributes)    CalcFinalIntelligence(self)
    end
end
function DotaCharacter:RemoveExtraHealth(extrahealth)   -- 额外生命
    if extrahealth ~= nil then    RemoveByValueFromTable(self.equippable.extrahealth, tonumber(extrahealth))  CalcExtraHealth(self) end
end
function DotaCharacter:RemoveHealthRegen(healthregen)  -- 生命恢复
    if healthregen ~= nil then    RemoveByValueFromTable(self.equippable.healthregen, tonumber(healthregen))  CalcHealthRegen(self) end
end
function DotaCharacter:RemoveManaRegen(manaregen)  -- 魔法恢复
    if manaregen ~= nil then    RemoveByValueFromTable(self.equippable.manaregen, tonumber(manaregen))  CalcManaRegen(self) end
end
function DotaCharacter:RemoveMaxMana(maxmana)  -- 魔法总值
    if maxmana ~= nil then    RemoveByValueFromTable(self.equippable.maxmana, tonumber(maxmana))  CalcMaxMana(self) end
end
function DotaCharacter:RemoveExtraArmor(extraarmor)    -- 护甲
    if extraarmor ~= nil then    RemoveByValueFromTable(self.equippable.extraarmor, tonumber(extraarmor))  CalcExtraArmor(self) end
end
function DotaCharacter:RemoveAttackSpeed(attackspeed)  -- 攻速
    if attackspeed ~= nil then    RemoveByValueFromTable(self.equippable.attackspeed, tonumber(attackspeed))  CalcAttackSpeed(self) end
end
function DotaCharacter:RemoveExtraDamage(extradamage)  -- 额外攻击力
    if extradamage ~= nil then    RemoveByValueFromTable(self.equippable.extradamage, tonumber(extradamage))  CalcExtradamage(self) end
end
function DotaCharacter:RemoveDamageRange(damagerange)  -- 额外攻击距离
    if damagerange ~= nil then    RemoveByValueFromTable(self.equippable.damagerange, tonumber(damagerange))  CalcDamageRange(self) end
end
function DotaCharacter:RemoveManaRegenAMP(manaregenamp)    -- 魔法恢复增强
    if manaregenamp ~= nil then    RemoveByValueFromTable(self.equippable.manaregenamp, tonumber(manaregenamp))  CalcManaRegenAMP(self) end
end
function DotaCharacter:RemoveHealthRegenAMP(healthregenamp)    -- 生命恢复增强
    if healthregenamp ~= nil then    RemoveByValueFromTable(self.equippable.healthregenamp, tonumber(healthregenamp))  CalcHealthRegenAMP(self) end
end
function DotaCharacter:RemoveDecrHealthRegenAMP(decrhealthregenamp)    -- 生命恢复减弱
    if decrhealthregenamp ~= nil then    RemoveByValueFromTable(self.equippable.decrhealthregenamp, tonumber(decrhealthregenamp))  CalcDecrHealthRegenAMP(self) end
end
function DotaCharacter:RemoveOutHealAMP(outhealamp)   -- 提供的治疗增强
    if outhealamp ~= nil then    RemoveByValueFromTable(self.equippable.outhealamp, tonumber(outhealamp))  CalcOutHealAMP(self) end
end
function DotaCharacter:RemoveHealedAMP(healedamp)   -- 接受的治疗增强
    if healedamp ~= nil then    RemoveByValueFromTable(self.equippable.healedamp, tonumber(healedamp))  CalcHealedAMP(self) end
end
function DotaCharacter:RemoveSpellDamageAMP(spelldamageamp)    -- 技能伤害增强
    if spelldamageamp ~= nil then    RemoveByValueFromTable(self.equippable.spelldamageamp, tonumber(spelldamageamp))  CalcSpellDamageAMP(self) end
end
function DotaCharacter:RemoveLifesteal(lifesteal)  -- 攻击吸血
    if lifesteal ~= nil then    RemoveByValueFromTable(self.equippable.lifesteal, tonumber(lifesteal))  CalcLifeSteal(self) end
end
function DotaCharacter:RemoveLifestealAMP(lifestealamp)  -- 攻击吸血增强
    if lifestealamp ~= nil then    RemoveByValueFromTable(self.equippable.lifestealamp, tonumber(lifestealamp))  CalcLifeStealAMP(self) end
end
function DotaCharacter:RemoveSpellLifesteal(spelllifesteal)    -- 技能吸血
    if spelllifesteal ~= nil then    RemoveByValueFromTable(self.equippable.spelllifesteal, tonumber(spelllifesteal))  CalcSpellLifeSteal(self) end
end
function DotaCharacter:RemoveSpellLifestealAMP(spelllifestealamp)    -- 技能吸血
    if spelllifestealamp ~= nil then    RemoveByValueFromTable(self.equippable.spelllifestealamp, tonumber(spelllifestealamp))  CalcSpellLifeStealAMP(self) end
end
function DotaCharacter:RemoveSpellResistance(spellresistance)  -- 魔法抗性
    if spellresistance ~= nil then    RemoveByValueFromTable(self.equippable.spellresistance, tonumber(spellresistance))  CalcSpellResistance(self) end
end
-- function DotaCharacter:Removeattackresistance(attackresistance)    -- 物理抗性
--     if attackresistance ~= nil then    RemoveByValueFromTable(self.equippable.attackresistance, tonumber(attackresistance))  CalcAttackResistance(self) end
-- end
function DotaCharacter:RemoveStatusResistance(statusresistance)    -- 状态抗性
    if statusresistance ~= nil then    RemoveByValueFromTable(self.equippable.statusresistance, tonumber(statusresistance))  CalcStatusResistance(self) end
end
function DotaCharacter:RemoveExtraSpellRange(extraspellrange, key)  -- 施法距离加成
    if extraspellrange ~= nil then
        if type(key) ~= "string" then key = "deafult" end
        -- key = string.format("%s", key)
        if self.equippable.extraspellrange[key] then
            RemoveByValueFromTable(self.equippable.extraspellrange[key], extraspellrange)
        end
        CalcExtraSpellRange(self)
    end
end
function DotaCharacter:RemoveDodgeChance(dodgechance)  -- 闪避概率
    if dodgechance ~= nil then    RemoveByValueFromTable(self.equippable.dodgechance, tonumber(dodgechance))  CalcDodgeChance(self) end
end
function DotaCharacter:RemoveMissChance(misschance)  -- 落空概率
    if misschance ~= nil then    RemoveByValueFromTable(self.equippable.misschance, tonumber(misschance))  CalcMissChance(self) end
end
function DotaCharacter:RemoveBlock(probability, damage) -- 格挡
    if probability ~= nil and damage ~= nil then
        local blocktable = {pr = probability, damage = damage}
        RemoveByValueFromTable(self.equippable.block, blocktable)
    end
end
function DotaCharacter:RemoveCritical(critical, criticaldamage) -- 暴击相关
    if critical ~= nil and criticaldamage ~= nil then
        local criticaltable = {critical = critical, criticaldamage = criticaldamage}
        RemoveByValueFromTable(self.equippable.critical, criticaltable)
    end
end
function DotaCharacter:RemoveExtraSpeed(source, key) -- 额外移速
    local src_params = self.equippable.extraspeed[source]
    if src_params ~= nil then
        if key ~= nil and key == "unique" then
            RemoveByValueFromTable(self.equippable.extraspeed[source], 1)
        elseif key ~= nil then
            src_params[key] = nil
        else
            self.equippable.extraspeed[source] = nil
        end
        CalcExtraSpeed(self)
    end
end
function DotaCharacter:RemoveTrueStrike(probability, damage, weapon) -- 克敌击先
    if probability ~= nil and damage ~= nil then
        local truestriketable = {pr = probability, damage = damage, weapon = weapon}
        RemoveByValueFromTable(self.equippable.truestrike, truestriketable)
        if self.inst.components.combat ~= nil then
            self.inst.components.combat:ResetTrueStrikeTable()
        end
    end
end
function DotaCharacter:RemoveAccuracy(accuracy) -- 必中
    if accuracy ~= nil then    RemoveByValueFromTable(self.equippable.accuracy, tonumber(accuracy))  CalcAccuracy(self) end
end
function DotaCharacter:RemoveDecrLifeStealAMP(decrlifestealamp) -- 攻击吸血降低
    if decrlifestealamp ~= nil then    RemoveByValueFromTable(self.equippable.decrlifestealamp, decrlifestealamp)    CalcDecrLifeStealAMP(self)    end
end
function DotaCharacter:RemoveDecrSpellLifeStealAMP(decrspelllifestealamp) -- 技能吸血降低
    if decrspelllifestealamp ~= nil then    RemoveByValueFromTable(self.equippable.decrspelllifestealamp, decrspelllifestealamp)    CalcDecrSpellLifeStealAMP(self)    end
end 
function DotaCharacter:RemoveDecrSpellDamageAMP(decrspelldamageamp) -- 技能伤害降低
    if decrspelldamageamp ~= nil then    RemoveByValueFromTable(self.equippable.decrspelldamageamp, decrspelldamageamp)    CalcDecrSpellDamageAMP(self)    end
end
function DotaCharacter:RemoveDecrHealedAMP(decrhealedamp) -- 接受的治疗降低
    if decrhealedamp ~= nil then    RemoveByValueFromTable(self.equippable.decrhealedamp, decrhealedamp)    CalcDecrHealedAMP(self)    end
end
function DotaCharacter:RemoveSpellWeak(spellweak) -- 受到的魔法伤害增强
    if spellweak ~= nil then    RemoveByValueFromTable(self.equippable.spellweak, spellweak)    CalcSpellWeak(self)   end
end
function DotaCharacter:RemoveCDReduction(cdreduction) -- 冷却减少
    if cdreduction ~= nil then    RemoveByValueFromTable(self.equippable.cdreduction, cdreduction)    CalcCDReduction(self)   end
end

-------------------------------------获取人物暴击属性----------------------------------------------

-- local criticallist = {} -- 外置可以减少rehash，但是优化的性能和因为读取外部变量导致的损耗哪个更多呢？会不会因为没删除表导致内存占用呢？
-- function DotaCharacter:GetCritical()  -- 暴击相关 (返回值为倍率) 
--     local critical = 1  -- 默认暴击倍率
--     criticallist = {}   -- 重设暴击记录
--     if #self.defaultcritical > 0 then
--         for _, dv in pairs(self.defaultcritical) do   -- 计算初始暴击率
--             if math.random() < dv.critical then     -- 计算是否暴击
--                 table.insert(criticallist, dv.criticaldamage)      -- 成功暴击就添加暴击伤害
--                 self.inst:PushEvent("dotaevent_defaultcritical", { inst = self.inst})	-- 推送事件，用于触发特效
--             end
--         end
--     end
--     if #self.equippable.critical > 0 then
--         for _, v in pairs(self.equippable.critical) do   -- 每种暴击分别计算
--             if math.random() < v.critical then     -- 计算是否暴击
--                 table.insert(criticallist, v.criticaldamage)      -- 成功暴击就添加暴击伤害
--             end
--         end
--     end
--     if #criticallist > 0 then
--         critical = math.max(unpack(criticallist))    -- 多个暴击伤害取最大值
--         -- self.inst:PushEvent("dotaevent_critical", { inst = self.inst})	-- 推送事件，用于触发特效
--     end
--     return critical
-- end

-- 另一种实现方法
function DotaCharacter:GetCritical()  -- 暴击相关 (返回值为倍率) 
    local critical = 1  -- 默认暴击倍率
    if #self.defaultcritical > 0 then
        for _, dv in pairs(self.defaultcritical) do   -- 计算初始暴击率
            if math.random() < dv.critical then     -- 计算是否暴击
                critical = math.max(critical, dv.criticaldamage)
                self.inst:PushEvent("dotaevent_defaultcritical", { inst = self.inst})	-- 推送事件，用于触发特效
            end
        end
    end
    if #self.equippable.critical > 0 then
        for _, v in pairs(self.equippable.critical) do   -- 每种暴击分别计算
            if math.random() < v.critical then     -- 计算是否暴击
                critical = math.max(critical, v.criticaldamage)
            end
        end
    end
    return critical
end

-------------------------------------获取人物格挡属性----------------------------------------------
function DotaCharacter:CalcBlockDamage(damage)  -- 暴击相关 (返回值为倍率) 
    -- if #self.equippable.block > 0 then
        local blockdamage = 0
        for _, dv in pairs(self.equippable.block) do
            if math.random() > dv.pr then     -- 计算是否c成功格挡
                blockdamage = math.max(blockdamage, dv.damage)  -- 多个格挡效果不会叠加
                self.inst:PushEvent("dotaevent_block", { inst = self.inst})	-- 推送事件，用于触发特效
            end
        end
    -- end
    return damage - blockdamage
end

--------------------------------------------------------------------------------------------
-------------------------------------升级相关------------------------------------------------
--------------------------------------------------------------------------------------------

local function IsLevelUp(self)
    return ((self.exp > self.maxexp) and (self.level < self.maxlevel))
end

function DotaCharacter:DeltaExp(delta)
    self.exp = self.exp + delta
    while IsLevelUp(self) do        -- 为了防止有时经验值过于庞大，出现连升几级的情况，用while循环处理
        self.exp = self.exp - self.maxexp   -- 减去升1级的所需经验
        self.level = self.level + 1     -- 等级+1
        self.skillpoint = self.skillpoint + 1   -- 技能点+1
        self.maxexp =  self.maxexpfn(self.level) or DefaultMaxexpfn(self.level)    -- 重设最大经验
        self.inst:PushEvent("dotaevent_levelup", {inst=self.inst, currentlevel = self.level})    -- 创建新事件，人物升级
    end
    self:CalcFinalAttributes()   -- 刷新属性
end

--------------------------------------------------------------------------------------------
-------------------------------------Ability/被动-------------------------------------------
--------------------------------------------------------------------------------------------

function DotaCharacter:HasAbility(name)
    return self.abilities[name] ~= nil
end

function DotaCharacter:GetAbility(name)
    local ability = self.abilities[name]
    return ability ~= nil and ability.inst or nil
end

function DotaCharacter:RegisterAbility(name, ent, data)
    if ent.components.debuff ~= nil then
        self.abilities[name] =
        {
            inst = ent,
            onremove = function(ability)
							self.abilities[name] = nil
							if self.onabilityremoved ~= nil then
								self.onabilityremoved(self.inst, name, ability)
							end
						end,
        }
        self.inst:ListenForEvent("onremove", self.abilities[name].onremove, ent)
        ent.persists = false
        ent.components.debuff:AttachTo(name, self.inst, self.followsymbol, self.followoffset, data)
		if self.onabilityadded ~= nil then
			self.onabilityadded(self.inst, name, ent, data)
		end
    else
        ent:Remove()
    end
end

function DotaCharacter:AddAbility(equip, name, ability, data)
    if self.equipments[name] == nil then
        self.equipments[name] = {}
    end
    self.equipments[name][equip] = true

    if not self:HasAbility(name) then
        local ent = SpawnPrefab(ability)
        if ent ~= nil then
            self:RegisterAbility(name, ent, data)
        end
        return ent
    else
        self.abilities[name].inst.components.debuff:Extend(self.followsymbol, self.followoffset, data)
        return self.debuffs[name].inst
    end
end

function DotaCharacter:RemoveAbility(equip, name)
    local ability = self.abilities[name]
    if ability ~= nil and equip ~= nil then
        self.equipments[name][equip] = false

        local tmp = false
        for _, v in pairs(self.equipments[name]) do
            if v then
                tmp = true
                break
            end
        end

        if not tmp then
            self.abilities[name] = nil
            self.inst:RemoveEventCallback("onremove", ability.onremove, ability.inst)
            if self.ondebuffremoved ~= nil then
                self.ondebuffremoved(self.inst, name, ability.inst)
            end
            if ability.inst.components.debuff ~= nil then
                ability.inst.components.debuff:OnDetach()
            else
                ability.inst:Remove()
            end
        end

    end
end

--------------------------------------------------------------------------------------------
------------------------------------保存/加载------------------------------------------------
--------------------------------------------------------------------------------------------
function DotaCharacter:OnSave()
    local data = {
        level = self.level,
        experience = self.exp,
        maxexp = self.maxexp,
		-- defaultstrength	 = self.defaultstrength,            -- 力量
		-- defaultagility	 = self.defaultagility,             -- 敏捷
		-- defaultintelligence	 = self.defaultintelligence,        -- 智力
		-- defaultdodgechance	 = self.defaultdodgechance,         -- 闪避概率
		-- defaultspelldamageamp	 = self.defaultspelldamageamp,      -- 技能伤害增强
		-- defaultdamagerange	 = self.defaultdamagerange,         -- 额外攻击距离
		-- defaultextraspellrange	 = self.defaultextraspellrange,     -- 施法距离加成
		-- defaultspellresistance	 = self.defaultspellresistance,     -- 魔法抗性
		-- defaultextraarmor	 = self.defaultextraarmor,          -- 护甲
		-- defaultstatusresistance	 = self.defaultstatusresistance,    -- 状态抗性
		-- defaultlifesteal	 = self.defaultlifesteal,           -- 攻击吸血
		-- defaultlifestealamp	 = self.defaultlifestealamp,        -- 攻击吸血增强
		-- defaultspelllifesteal	 = self.defaultspelllifesteal,      -- 技能吸血
		-- defaultspelllifestealamp	 = self.defaultspelllifestealamp,   -- 技能吸血增强
		-- defaultmanaregenamp	 = self.defaultmanaregenamp,        -- 魔法恢复增强
		-- defaulthealthregenamp	 = self.defaulthealthregenamp,      -- 生命恢复增强
		-- defaultouthealamp	 = self.defaultouthealamp,          -- 提供的治疗增强
		-- defaulthealedamp	 = self.defaulthealedamp,           -- 接受的治疗增强
			-- --  = self.defaultcritical = {}           -- 暴击相关 （表存入) eg.{{critical=0.1,criticaldamage=0.5}} 
		-- defaultmisschance	 = self.defaultmisschance,          -- 落空概率
		-- defaultaccuracy	 = self.defaultaccuracy,            -- 必中 (debuff)
		-- defaultdecrlifestealamp	 = self.defaultdecrlifestealamp,       -- 攻击吸血降低 (debuff)
		-- defaultspellweak	 = self.defaultspellweak,           -- 受到的魔法伤害增强 (debuff)
		-- defaultcdreduction	 = self.defaultcdreduction,         -- 冷却减少
    }
    return data
end

function DotaCharacter:OnLoad(data)
    self.level = data.level or 0
    self.exp = data.experience or 0
    self.maxexp = data.maxexp or 0
	-- self.defaultstrength = data.defaultstrength  or 0           -- 力量
    -- self.defaultagility = data.defaultagility  or 0             -- 敏捷
    -- self.defaultintelligence = data.defaultintelligence or 0        -- 智力
    -- self.defaultdodgechance = data.defaultdodgechance or 0         -- 闪避概率
    -- self.defaultspelldamageamp = data.defaultspelldamageamp or 0      -- 技能伤害增强
    -- self.defaultdamagerange = data.defaultdamagerange or 0         -- 额外攻击距离
    -- self.defaultextraspellrange = data.defaultextraspellrange or 0     -- 施法距离加成
    -- self.defaultspellresistance = data.defaultspellresistance or 0     -- 魔法抗性
    -- self.defaultextraarmor = data.defaultextraarmor or 0          -- 护甲
    -- self.defaultstatusresistance = data.defaultstatusresistance or 0    -- 状态抗性
    -- self.defaultlifesteal = data.defaultlifesteal or 0           -- 攻击吸血
    -- self.defaultlifestealamp = data.defaultlifestealamp or 0        -- 攻击吸血增强
    -- self.defaultspelllifesteal = data.defaultspelllifesteal or 0      -- 技能吸血
    -- self.defaultspelllifestealamp = data.defaultspelllifestealamp or 0   -- 技能吸血增强
    -- self.defaultmanaregenamp = data.defaultmanaregenamp or 0        -- 魔法恢复增强
    -- self.defaulthealthregenamp = data.defaulthealthregenamp or 0      -- 生命恢复增强
    -- self.defaultouthealamp = data.defaultouthealamp or 0          -- 提供的治疗增强
    -- self.defaulthealedamp = data.defaulthealedamp or 0           -- 接受的治疗增强
    -- -- self.defaultcritical = {}           -- 暴击相关 （表存入) eg.{{critical=data..1,criticaldamage=data..5}} 
    -- self.defaultmisschance = data.defaultmisschance or 0          -- 落空概率
    -- self.defaultaccuracy = data.defaultaccuracy or 0            -- 必中 (debuff)
    -- self.defaultdecrlifestealamp = data.defaultdecrlifestealamp or 0       -- 攻击吸血降低 (debuff)
    -- self.defaultspellweak = data.defaultspellweak or 0           -- 受到的魔法伤害增强 (debuff)
    -- self.defaultcdreduction = data.defaultcdreduction or 0         -- 冷却减少
    -- self:CalcAllAttributesGain()
    self:CalcFinalAttributes() -- 应该计算三维部分就好
end

return DotaCharacter