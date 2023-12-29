---------------------------------------- Dota属性记录 - Components ---------------------------------------------
-- TODO ：添加 RemoveComponent 的部分

local SourceModifierList = require("util/sourcemodifierlist")
local DotaModifierList = require("dota_defs/dotamodifierlist")  -- 与原版无多大差异，主要添加了一个边际衰减的函数
local DamageModifierList = require("dota_defs/dotadamagemodifierlist")  -- 与原版无多大差异，主要添加了一个边际衰减的函数
local MANA_REGEN_TOTALTIME = TUNING.DOTA.MANA_REGEN_TOTALTIME

local function on_mana(self, mana)
    self.inst.replica.dotaattributes:SetMana(mana)
end
local function on_maxmana(self, maxmana)
    self.inst.replica.dotaattributes:SetMaxMana(maxmana)
end
local function on_attackspeed(self, attackspeed)
    self.inst.replica.dotaattributes:SetAttackSpeed(attackspeed:Get())
end

local DotaAttributes = Class(function(self, inst)   -- 参数有那么亿点点多，这会占用内存吗？
    self.inst = inst
    ---------------------基本属性---------------------- -- 事实上并非每个参数都需要 ModifierList，但为了美观全部选择该方法
    self.extrahealth = SourceModifierList(self.inst, 0, SourceModifierList.additive)                 -- 额外生命
    self.healthregen = SourceModifierList(self.inst, 0, SourceModifierList.additive)                 -- 生命恢复
    self.extraarmor = SourceModifierList(self.inst, 0, SourceModifierList.additive)                  -- 护甲
    self.attackspeed = SourceModifierList(self.inst, 1, SourceModifierList.additive)                 -- 攻速
    self.basemaxmana = 100
    self.mana = 100                                                                                    -- 魔法
    self.maxmana = 100                                                                               -- 最大魔法值
    self.maxmanacalc = SourceModifierList(self.inst, 0, SourceModifierList.additive)                -- 魔法总值
    self.manaregen = SourceModifierList(self.inst, 0, SourceModifierList.additive)                   -- 魔法恢复
    ---------------------额外属性----------------------
    self.extradamage = DamageModifierList(self.inst, 0, DamageModifierList.additive)                 -- 额外攻击力
    self.damagerange = SourceModifierList(self.inst, 0, SourceModifierList.additive)                 -- 额外攻击距离
    self.extraspeed = SourceModifierList(self.inst, 0, SourceModifierList.additive)                  -- 额外移速
    self.extraspellrange = SourceModifierList(self.inst, 0, SourceModifierList.additive)            -- 施法距离加成
    self.critical = {}                  -- 暴击相关 （表存入) eg.{{暴击率=1.1,暴击倍率=1.5}} 
    self.truestrike = {}                -- 克敌击先 （表存入）eg.{{概率,伤害,武器}}
    -- self.extraspeedpriority = 0         -- 额外移速优先度（废案）
    self.attackresistance = 0           -- 物理抗性
    self.spelldamageamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)             -- 技能伤害增强
    self.dodgechance = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)                -- 闪避概率
    self.spellresistance = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)            -- 魔法抗性
    self.statusresistance = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)           -- 状态抗性
    self.lifesteal = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)                  -- 攻击吸血
    self.lifestealamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)               -- 攻击吸血增强
    self.spelllifesteal = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)             -- 技能吸血
    self.spelllifestealamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)          -- 技能吸血增强
    self.manaregenamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)               -- 魔法恢复增强
    self.healthregenamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)             -- 生命恢复增强
    self.outhealamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)                 -- 提供的治疗增强
    self.healedamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)                  -- 接受的治疗增强    
    self.cdreduction = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)                -- 冷却减少
    ---------------------负面属性----------------------
    self.spellweak = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)                  -- 受到的魔法伤害增强
    self.misschance = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)                 -- 落空概率
    self.accuracy = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)                   -- 必中
    self.decrhealthregenamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)         -- 生命恢复降低
    self.decrlifestealamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)           -- 攻击吸血降低
    self.decrspelllifestealamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)      -- 技能吸血降低
    self.decrspelldamageamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)         -- 技能伤害降低
    self.decrhealedamp = DotaModifierList(self.inst, 0, DotaModifierList.diminishing)              -- 接受的治疗降低
    ---------------------护盾记录----------------------
    self.magicshields = {}                                                                          -- 魔法护盾
    self.normalshields = {}                                                                         -- 普通护盾

    self.inst:AddTag("dotaattributes")
end,
nil,
{
    mana = on_mana,
    maxmana = on_maxmana,
    attackspeed = on_attackspeed,
})
-- 示例
-- self.inst.components.dotaattributes.maxmana:RemoveModifier(self.source, self.key)
-- self.inst.components.dotaattributes.maxmana:SetModifier(self.source, self.maxmana, self.key)

function DotaAttributes:OnRemoveFromEntity()
    self.inst:RemoveTag("dotaattributes")
end

--------------------------------------------------------------------------------------------
-------------------------------------暴击相关------------------------------------------------
--------------------------------------------------------------------------------------------

function DotaAttributes:GetCritical()
    if self.inst.components.dotacharacter ~= nil then
        return self.inst.components.dotacharacter:GetCritical()
    else
        local critical = 1  -- 默认暴击倍率
        for _, dv in pairs(self.critical) do   -- 计算初始暴击率
            if math.random() < dv.critical then     -- 计算是否暴击
                critical = math.max(critical, dv.criticaldamage)
            end
        end
        -- self.inst:PushEvent("dotaevent_critical", { inst = self.inst})	-- 推送事件，用于触发特效
        return critical
    end
end

--------------------------------------------------------------------------------------------
-------------------------------------生命相关------------------------------------------------
--------------------------------------------------------------------------------------------

function DotaAttributes:Health_UpdateHealthRegen()
    if self.inst.components.health ~= nil and not self.inst.components.health:IsDead() then
        local regen = self.healthregen:Get()
        local healthregenamp = self.healthregenamp:Get()
		self.inst.components.health:Dota_UpdateHealthRegen(regen, healthregenamp)
	end
end

function DotaAttributes:AddHealthRegen(source, healthregen, key)     -- 生命恢复
    self.healthregen:SetModifier(source, healthregen, key)
    self:Health_UpdateHealthRegen()
end
function DotaAttributes:RemoveHealthRegen(source, key)
    self.healthregen:RemoveModifier(source, key)
    self:Health_UpdateHealthRegen()
end

function DotaAttributes:AddHealthRegenAMP(source, healthregenamp, key)     -- 生命恢复增强
    self.healthregenamp:SetModifier(source, healthregenamp, key)
    self:Health_UpdateHealthRegen()
end
function DotaAttributes:RemoveHealthRegenAMP(source, key)
    self.healthregenamp:RemoveModifier(source, key)
    self:Health_UpdateHealthRegen()
end

function DotaAttributes:Health_UpdateHealthAMP()
    if self.inst.components.health ~= nil and not self.inst.components.health:IsDead() then
        local healedamp = self.healedamp:Get()
        local decrhealedamp = self.decrhealedamp:Get()
        local decrhealthregenamp = self.decrhealthregenamp:Get()
		self.inst.components.health:Dota_UpdateHealthAMP(healedamp, decrhealedamp, decrhealthregenamp)
	end
end

function DotaAttributes:AddHealedAMP(source, decrhealthregenamp, key)     -- 接受的治疗增强
    self.healedamp:SetModifier(source, decrhealthregenamp, key)
    self:Health_UpdateHealthAMP()
end
function DotaAttributes:RemoveHealedAMP(source, key)
    self.healedamp:RemoveModifier(source, key)
    self:Health_UpdateHealthAMP()
end

function DotaAttributes:AddDecrHealedAMP(source, decrhealthregenamp, key)     -- 接受的治疗降低
    self.decrhealedamp:SetModifier(source, decrhealthregenamp, key)
    self:Health_UpdateHealthAMP()
end
function DotaAttributes:RemoveDecrHealedAMP(source, key)
    self.decrhealedamp:RemoveModifier(source, key)
    self:Health_UpdateHealthAMP()
end

function DotaAttributes:AddDecrHealthRegenAMP(source, decrhealthregenamp, key)     -- 生命恢复降低
    self.decrhealthregenamp:SetModifier(source, decrhealthregenamp, key)
    self:Health_UpdateHealthAMP()
end
function DotaAttributes:RemoveDecrHealthRegenAMP(source, key)
    self.decrhealthregenamp:RemoveModifier(source, key)
    self:Health_UpdateHealthAMP()
end

function DotaAttributes:Health_CalcExtraHealth()
    if self.inst.components.health ~= nil and not self.inst.components.health:IsDead() then
		self.inst.components.health:Dota_UpdateDefaultHealth()
	end
end

function DotaAttributes:AddExtraHealth(source, extrahealth, key)     -- 额外生命
    self.extrahealth:SetModifier(source, extrahealth, key)
    self:Health_CalcExtraHealth()
end
function DotaAttributes:RemoveExtraHealth(source, key)
    self.extrahealth:RemoveModifier(source, key)
    self:Health_CalcExtraHealth()
end
--------------------------------------------------------------------------------------------
-------------------------------------魔法相关------------------------------------------------
--------------------------------------------------------------------------------------------
-- 本来想要另起一个components，然后导入的，想了想懒得弄，就放一起了
-- 完全模仿自官方的 health.lua

function DotaAttributes:Mana_GetPercent()
    return self.mana / self.maxmana
end

function DotaAttributes:Mana_SetPercent(percent, overtime, cause)
    self:Mana_SetVal(self.maxmana * percent, cause)
    self:Mana_DoDelta(0, overtime, cause)
end

local function Mana_DoRegen(inst, self)
    if self.inst.components.health ~= nil and not self.inst.components.health:IsDead()  -- 死亡状态当然不恢复魔法值
     and (self.mana < self.maxmana)     -- 当魔法值为满时不再回复，减少一点占用
     then
        self:Mana_DoDelta(self.mana_regen.amount, true, "mana_regen")
    end
end

function DotaAttributes:Mana_StartRegen(amount, period, interruptcurrentregen)
	-- print("[debug] [Mana_StartRegen] amount: "..amount.." period: "..period)
    if interruptcurrentregen ~= false then
        self:Mana_StopRegen()
    end

    if self.mana_regen == nil then
        self.mana_regen = {}
    end
    self.mana_regen.amount = amount
    self.mana_regen.period = period

    if self.mana_regen.task == nil then
        self.mana_regen.task = self.inst:DoPeriodicTask(self.mana_regen.period, Mana_DoRegen, nil, self)
    end
end

function DotaAttributes:Mana_StopRegen()
    if self.mana_regen ~= nil then
        if self.mana_regen.task ~= nil then
            self.mana_regen.task:Cancel()
            self.mana_regen.task = nil
        end
        self.mana_regen = nil
    end
end

function DotaAttributes:Mana_SetVal(val, cause)
    local max_mana = self.maxmana
    local min_mana = math.min(self.minmana or 0, max_mana)

    if val > max_mana then
        val = max_mana
    end

    if val <= min_mana then
        self.mana = min_mana
        -- self.inst:PushEvent("dota_minmana", { cause = cause})
    else
        self.mana = val
    end
end

function DotaAttributes:Mana_DoDelta(amount, overtime, cause) -- 删除了后面几个参数，因为不会用
    local old_percent = self:Mana_GetPercent()

    self:Mana_SetVal(self.mana + amount, cause)

    self.inst:PushEvent("dota_manadelta", { oldpercent = old_percent, newpercent = self:Mana_GetPercent(), overtime = overtime, cause = cause, amount = amount })

    if self.mana_ondelta ~= nil then
        self.mana_ondelta(self.inst, old_percent, self:Mana_GetPercent(), overtime, cause, amount)
    end
    return amount
end

function DotaAttributes:Mana_ResetDefulatRegen()
    local regen = self.manaregen:Get() * (1 + self.manaregenamp:Get()) -- 恢复值 = 魔法恢复 * (1 +  魔法恢复增强)
    if regen ~= 0 then
        local period = TUNING.DOTA.MANA_REGEN_INTERVAL
        local amount = (regen * period)/MANA_REGEN_TOTALTIME
        self:Mana_StartRegen(amount, period, false)   -- 开始恢复
    else
        self:Mana_StopRegen()   -- 恢复值为0取消恢复
    end
end

function DotaAttributes:AddManaRegen(source, manaregen, key)     -- 魔法恢复
    self.manaregen:SetModifier(source, manaregen, key)
    self:Mana_ResetDefulatRegen()
end
function DotaAttributes:RemoveManaRegen(source, key)
    self.manaregen:RemoveModifier(source, key)
    self:Mana_ResetDefulatRegen()
end

function DotaAttributes:AddManaRegenAMP(source,manaregenamp, key)     -- 魔法恢复增强
    self.manaregenamp:SetModifier(source, manaregenamp, key)
    self:Mana_ResetDefulatRegen()
end
function DotaAttributes:RemoveManaRegenAMP(source, key)
    self.manaregenamp:RemoveModifier(source, key)
    self:Mana_ResetDefulatRegen()
end

function DotaAttributes:CalcMaxMana()
    local percent = self:Mana_GetPercent()
    self.maxmana = self.maxmanacalc:Get() + self.basemaxmana
    self:Mana_SetPercent(percent)
end
function DotaAttributes:AddMaxMana(source, maxmana, key)  
    self.maxmanacalc:SetModifier(source, maxmana, key)
    self:CalcMaxMana()
end
function DotaAttributes:RemoveMaxMana(source, key)
    self.maxmanacalc:RemoveModifier(source, key)
    self:CalcMaxMana()
end
function DotaAttributes:SetBaseMaxMana(amount)
    self.basemaxmana = amount
end
--------------------------------------------------------------------------------------------
-----------------------------------物理抗性/护甲相关------------------------------------------
--------------------------------------------------------------------------------------------

function DotaAttributes:CalcAttackResistance()  -- 物理抗性
    local extraarmor = self.extraarmor:Get()
    self.attackresistance = (extraarmor * 0.06)/(1 + 0.06 * math.abs(extraarmor))
end

function DotaAttributes:AddExtraArmor(source, extraarmor, key)    -- 护甲比较特殊，因为涉及物理抗性的计算，所以单独列出
    self.extraarmor:SetModifier(source, extraarmor, key)
    self:CalcAttackResistance()
end
function DotaAttributes:RemoveExtraArmor(source, key)  
    self.extraarmor:RemoveModifier(source, key)
    self:CalcAttackResistance()
end

--------------------------------------------------------------------------------------------
--------------------------------------------攻击相关-----------------------------------------
--------------------------------------------------------------------------------------------
function DotaAttributes:CalcDamageRange() 
    if self.inst.components.combat ~= nil then
        self.inst.components.combat:Dota_UpdateAttackRange()
    end
end

function DotaAttributes:AddDamageRange(source, damagerange, key)    --  额外攻击距离
    self.damagerange:SetModifier(source, damagerange, key)
    self:CalcDamageRange()
end
function DotaAttributes:RemoveDamageRange(source, key)  
    self.damagerange:RemoveModifier(source, key)
    self:CalcDamageRange()
end

--------------------------------------------------------------------------------------------
--------------------------------------------移速相关------------------------------------------
--------------------------------------------------------------------------------------------
function DotaAttributes:CalcExtraSpeed() 
	if self.inst.components.locomotor ~= nil then
		self.inst.components.locomotor:Dota_UpdateRunSpeed(self.extraspeed:Get())
	end
end

function DotaAttributes:AddExtraSpeed(source, extraspeed, key) 
    self.extraspeed:SetModifier(source, extraspeed, key)
    self:CalcExtraSpeed()
end
function DotaAttributes:RemoveExtraSpeed(source, key)  
    self.extraspeed:RemoveModifier(source, key)
    self:CalcExtraSpeed()
end

--------------------------------------------------------------------------------------------
--------------------------------------------攻速相关------------------------------------------
--------------------------------------------------------------------------------------------
function DotaAttributes:CalcAttackSpeed() 
    if self.inst.components.combat then
        self.inst.components.combat:Dota_UpdateAttackPeriod(self.attackspeed:Get())
    end
end

function DotaAttributes:AddAttackSpeed(source, damagerange, key) 
    self.attackspeed:SetModifier(source, damagerange, key)
    self:CalcAttackSpeed()
end
function DotaAttributes:RemoveAttackSpeed(source, key)  
    self.attackspeed:RemoveModifier(source, key)
    self:CalcAttackSpeed()
end

--------------------------------------------------------------------------------------------
-----------------------------------------格挡相关--------------------------------------------
--------------------------------------------------------------------------------------------

function DotaAttributes:CalcBlockDamage(damage)  
    if self.inst.components.dotacharacter ~= nil then
        return self.inst.components.dotacharacter:CalcBlockDamage(damage)
    else
        return damage
    end
end

--------------------------------------------------------------------------------------------
-------------------------------------魔法护盾相关--------------------------------------------
--------------------------------------------------------------------------------------------
function DotaAttributes:CalcMagicShieldDamage(damage)  
    for _, v in pairs(self.magicshields) do
        if v.components.dotashield ~= nil then
            damage = v.components.dotashield:ApplyDamage(damage)
        end
    end
    return damage
end

function DotaAttributes:CreateMagicShield(shieldname)
    if self.magicshields[shieldname] ~= nil and self.magicshields[shieldname].components.dotashield ~= nil then
        self.magicshields[shieldname].components.dotashield:ResetShield()
    else
        local shield = SpawnPrefab(shieldname)
        shield.components.dotashield:CreateShield(self.inst)
        self.magicshields[shieldname] = shield
    end
end

function DotaAttributes:RemoveMagicShield(shieldname)  
    if self.magicshields[shieldname] ~= nil then
        self.magicshields[shieldname] = nil
    end
end

--------------------------------------------------------------------------------------------
-------------------------------------物理护盾相关--------------------------------------------
--------------------------------------------------------------------------------------------
function DotaAttributes:CalcNormalShieldDamage(damage)  
    for _, v in pairs(self.normalshields) do
        if v.components.dotashield ~= nil then
            damage = v.components.dotashield:ApplyDamage(damage)
        end
    end
    return damage
end

function DotaAttributes:CreateNormalShield(shieldname)
    if self.normalshields[shieldname] ~= nil and self.normalshields[shieldname].components.dotashield ~= nil then
        self.normalshields[shieldname].components.dotashield:ResetShield()
    else
        local shield = SpawnPrefab(shieldname)
        shield.components.dotashield:CreateShield(self.inst)
        self.normalshields[shieldname] = shield
    end
end

function DotaAttributes:RemoveNormalShield(shieldname)  
    if self.normalshields[shieldname] ~= nil then
        self.normalshields[shieldname] = nil
    end
end

--------------------------------------------------------------------------------------------
-------------------------------------Save/Load相关------------------------------------------
--------------------------------------------------------------------------------------------
function DotaAttributes:OnSave()
    local data = {
        mana = self.mana,
		maxmana = self.maxmana,
    }
    return data
end

function DotaAttributes:OnLoad(data)
    if data then
        self.mana = data.mana or 100
        self.maxmana = data.maxmana or 100
    end
end

return DotaAttributes