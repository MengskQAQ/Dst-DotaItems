local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local dota_item_precious = {}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------宝物--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------法师克星-------------------------------------------------
dota_item_precious.dota_mage_slayer = {
    name = "dota_mage_slayer",
    animname = "dota_mage_slayer",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.MAGE_SLAYER.INTELLIGENCE)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.MAGE_SLAYER.MANAREGEN)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.MAGE_SLAYER.EXTRADAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.MAGE_SLAYER.ATTACKSPEED)
        owner.components.dotacharacter:AddSpellResistance(TUNING.DOTA.MAGE_SLAYER.SPELLRESIS)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.MAGE_SLAYER.INTELLIGENCE)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.MAGE_SLAYER.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.MAGE_SLAYER.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.MAGE_SLAYER.ATTACKSPEED)
        owner.components.dotacharacter:RemoveSpellResistance(TUNING.DOTA.MAGE_SLAYER.SPELLRESIS)
	end,
}
-------------------------------------------------回音战刃 or 连击刀-------------------------------------------------
dota_item_precious.dota_echo_sabre = {
    name = "dota_echo_sabre",
    animname = "dota_echo_sabre",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.ECHO_SABRE.STRENGTH)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.ECHO_SABRE.INTELLIGENCE)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.ECHO_SABRE.MANAREGEN)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.ECHO_SABRE.EXTRADAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.ECHO_SABRE.ATTACKSPEED)
        owner.components.dotacharacter:AddAbility(inst, "ability_dota_echo", "ability_dota_echo")
        owner:ListenForEvent("dotaevent_echo", inst._onrecharger)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.ECHO_SABRE.STRENGTH)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.ECHO_SABRE.INTELLIGENCE)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.ECHO_SABRE.MANAREGEN)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.ECHO_SABRE.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.ECHO_SABRE.ATTACKSPEED)
        owner.components.dotacharacter:RemoveAbility(inst, "ability_dota_echo")
        owner:RemoveEventCallback("dotaevent_echo", inst._onrecharger)
	end,
    extrafn=function(inst)
        inst._onrecharger = function(owner)
            if inst and inst.components.rechargeable ~= nil then
                inst.components.rechargeable:Discharge(TUNING.DOTA.ECHO_SABRE.ECHO.CD)
			end
        end
    end,
}
-------------------------------------------------斯嘉蒂之眼  or 冰眼-------------------------------------------------
dota_item_precious.dota_eye_of_skadi = {
    name = "dota_eye_of_skadi",
    animname = "dota_eye_of_skadi",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.EYE_OF_SKADI.ATTRIBUTES)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.EYE_OF_SKADI.EXTRAHEALTH)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.EYE_OF_SKADI.MAXMANA)
        owner:ListenForEvent("onhitother", inst.OnHitOther)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.EYE_OF_SKADI.ATTRIBUTES)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.EYE_OF_SKADI.EXTRAHEALTH)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.EYE_OF_SKADI.MAXMANA)
        owner:RemoveEventCallback("onhitother", inst.OnHitOther)
	end,
    extrafn=function(inst)
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.DOTA.EYE_OF_SKADI.INSULATOR)
        inst.components.insulator:SetSummer()
        inst.OnHitOther = function(inst, data)
            if data and data.target and data.target.components.debuffable ~= nil then
                data.target.components.debuffable:AddDebuff("buff_dota_skadi", "buff_dota_skadi")
            end
        end
    end,
}
-------------------------------------------------天堂之戟-------------------------------------------------
dota_item_precious.dota_heavens_halberd = {
    name = "dota_heavens_halberd",
    animname = "dota_heavens_halberd",
	animzip = "dota_precious", 
	taglist = {
    },
    activatename = "DOTA_DISARM",
    sharedcoolingtype = "disarm",
    manacost = TUNING.DOTA.HEAVENS_HALBERD.DISARM.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.HEAVENS_HALBERD.STRENGTH)
        owner.components.dotacharacter:AddHealthRegenAMP(TUNING.DOTA.HEAVENS_HALBERD.HEALTHREGENAMP)
        owner.components.dotacharacter:AddLifestealAMP(TUNING.DOTA.HEAVENS_HALBERD.LIFESTEALAMP)
        owner.components.dotacharacter:AddDodgeChance(TUNING.DOTA.HEAVENS_HALBERD.DODGECHANCE)
        owner.components.dotacharacter:AddStatusResistance(TUNING.DOTA.HEAVENS_HALBERD.STATUSRESIS)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.HEAVENS_HALBERD.STRENGTH)
        owner.components.dotacharacter:RemoveHealthRegenAMP(TUNING.DOTA.HEAVENS_HALBERD.HEALTHREGENAMP)
        owner.components.dotacharacter:RemoveLifestealAMP(TUNING.DOTA.HEAVENS_HALBERD.LIFESTEALAMP)
        owner.components.dotacharacter:RemoveDodgeChance(TUNING.DOTA.HEAVENS_HALBERD.DODGECHANCE)
        owner.components.dotacharacter:RemoveStatusResistance(TUNING.DOTA.HEAVENS_HALBERD.STATUSRESIS)
	end,
}
-------------------------------------------------魔龙枪-------------------------------------------------
dota_item_precious.dota_dragon_lance = {
    name = "dota_dragon_lance",
    animname = "dota_dragon_lance",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.DRAGON_LANCE.STRENGTH)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.DRAGON_LANCE.AGILITY)
        owner.components.dotacharacter:AddDamageRange(TUNING.DOTA.DRAGON_LANCE.DISTANCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.DRAGON_LANCE.STRENGTH)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.DRAGON_LANCE.AGILITY)
        owner.components.dotacharacter:RemoveDamageRange(TUNING.DOTA.DRAGON_LANCE.DISTANCE)
	end,
}
-------------------------------------------------撒旦之邪力 or 大吸-------------------------------------------------
dota_item_precious.dota_satanic = {
    name = "dota_satanic",
    animname = "dota_satanic",
	animzip = "dota_precious", 
	taglist = {
    },
    sharedcoolingtype = "satanic",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.SATANIC.STRENGTH)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.SATANIC.EXTRADAMAGE)
        owner.components.dotacharacter:AddLifesteal(TUNING.DOTA.SATANIC.LIFESTEAL)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.SATANIC.STRENGTH)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.SATANIC.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveLifesteal(TUNING.DOTA.SATANIC.LIFESTEAL)
	end,
}
-------------------------------------------------净魂之刃 or 散失-------------------------------------------------
dota_item_precious.dota_diffusal_blade = {
    name = "dota_diffusal_blade",
    animname = "dota_diffusal_blade",
	animzip = "dota_precious", 
	taglist = {
    },
    activatename = "DOTA_INHIBIT",
    sharedcoolingtype = "inhibit",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.DIFFUSAL_BLADE.AGILITY)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.DIFFUSAL_BLADE.INTELLIGENCE)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.DIFFUSAL_BLADE.AGILITY)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.DIFFUSAL_BLADE.INTELLIGENCE)
	end,
}
-------------------------------------------------电锤-------------------------------------------------
local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "player"}	--连环闪电攻击排除对象
local LIGHTING_CD = TUNING.DOTA.MAELSTORM.LIGHTING.CD
local LIGHTING_DAMAGE = TUNING.DOTA.MAELSTORM.LIGHTING.DAMAGE
local LIGHTING_CHANCE = TUNING.DOTA.MAELSTORM.LIGHTING.CHANCE
local LIGHTING_INTERVAL = TUNING.DOTA.MAELSTORM.LIGHTING.INTERVAL
local LIGHTING_RANGE = TUNING.DOTA.MAELSTORM.LIGHTING.RANGE
local LIGHTING_NUMBER = TUNING.DOTA.MAELSTORM.LIGHTING.BOUNCES
-- if not TheNet:GetPVPEnabled() then   -- 关于pvp的内容，下次一定
--     table.insert(exclude_tags, "player")
-- end

--获取连环闪电的下一个目标，随机获取下一个目标
-- local function GetNextTarget(inst, target)
--     local targetlist = {}
--     local x, y, z = target.Transform:GetWorldPosition()	-- 获取被攻击对象的世界坐标
--     local ents = TheSim:FindEntities(x, y, z, TUNING.DOTA.MAELSTORM_CHAIN_LIGHTING_DISTANCE, { "_combat" }, exclude_tags) --攻击范围	 -- 通过 TheSim:FindEntities() 函数查找周围的实体
--     for i, ent in ipairs(ents) do	 -- 遍历找到的实体
--         if ent ~= target
--          and ent ~= inst
--          and inst.components.combat:IsValidTarget(ent)
--          and (inst.components.leader ~= nil and not inst.components.leader:IsFollower(ent)) 
--          then
--             table.insert(targetlist, ent)
--         end
--     end
--     if #targetlist > 0 then
--         return targetlist[math.random(1,#targetlist)]
--     end
--     return nil
-- end

-- local function EmitterLightning(inst)
--     if inst.SoundEmitter ~= nil then
--         inst.SoundEmitter:PlaySound("mengsk_dota2_sounds/items/item_mael_lightning_chain", nil, BASE_VOICE_VOLUME)
--     end
-- end

-- local function DoLishtingStrike(inst, target, attacker, damage)
--     if target.components.combat ~= nil then
--         -- SpawnPrefab("dota_fx_lightning").Transform:SetPosition(target.Transform:GetWorldPosition())
-- 		SpawnPrefab("electrichitsparks").Transform:SetPosition(target.Transform:GetWorldPosition())
--         -- SpawnPrefab("electrichitsparks"):AlignToTarget(attacker, target, true)
--         attacker:PushEvent("onareaattackother", { target = target, weapon = inst, stimuli = "electric" }) -- 推送事件给服务器来计算其它实体的血量以及通知其它玩家，当前多少实体正在被攻击
--         target.components.combat:GetAttacked(attacker, damage, nil, "electric")	-- 给予实体伤害，考虑防御
--     end
-- end

-- 获取连环闪电的下一个目标 
-- 开销低，但这样会出现一个喜感画面，闪电来回弹射
-- 如果使用表记录所有弹射过的对象，就可以避免这种状况，但是总觉得开销太大
-- 事实上方有光茄法杖，也实现了弹射，但是这两种方法依赖的方式不一样
-- 官方依托于实体，非及时命中，我的方法不依托于实体，及时命中
-- 不过为了与饥荒自身风格保持一致，就改用法杖的法球形式了
-- 这种形式的弹射姑且先弃用
-- 当然官方用表储存了所有弹射过的对象，但是要我独自去写，我是不敢的
-- local function GetNextTarget(attacker, target, range,  x, y, z)
--     local ents = TheSim:FindEntities(x, y, z, range, { "_combat" }, exclude_tags)
--     for _, ent in ipairs(ents) do	 -- 遍历找到的实体
--         if ent ~= target
--          and ent ~= attacker
--          and (attacker.components.combat ~= nil and attacker.components.combat:IsValidTarget(ent))
--          and (attacker.components.leader ~= nil and not attacker.components.leader:IsFollower(ent)) 
--          then
--             return ent
--         end
--     end
--     return nil
-- end


dota_item_precious.dota_maelstrom = {
    name = "dota_maelstrom",
    animname = "dota_maelstrom",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.MAELSTORM.EXTRADAMAGE)    -- Todo: 待复制
        owner:ListenForEvent("onhitother", inst.onhitotherfn)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.MAELSTORM.EXTRADAMAGE)
        owner:RemoveEventCallback("onhitother", inst.onhitotherfn)
	end,
    fakeweapon = {   -- 在电锤上挂载一个虚拟武器
        name = "FakeWeapon_maelstrom",
        damage = 0,
        range = LIGHTING_RANGE,
        projectile = "dota_projectile_chain",
        tag = "chainlighting",
    },
    extrafn=function(inst)
		inst.readylight = true
        inst.onhitotherfn = function(attacker, data)
            if data and data.target and inst.readylight
             and math.random(0,1) <= LIGHTING_CHANCE
             then
                inst.readylight = false
                local target = data.target
				-- local x, y, z = target.Transform:GetWorldPosition()	-- 获取被攻击对象的世界坐标
                -- DoLishtingStrike(inst, target, attacker, LIGHTING_DAMAGE)

                inst:DoTaskInTime(LIGHTING_CD, function() inst.readylight = true end)
                -- inst:DoTaskInTime(LIGHTING_INTERVAL, inst.ChainLighting, attacker, target, x, y, z, 0)

                if inst.fakeweapon and attacker.components.combat ~= nil then
                    inst.fakeweapon.components.weapon:LaunchProjectile(attacker, target)
                end

            end
        end
		-- inst.ChainLighting = function(inst, attacker, target, x, y, z, count)
		--     local nexttarget = GetNextTarget(attacker, target, LIGHTING_RANGE, x, y, z)
		-- 	if nexttarget ~= nil then
		-- 		local x, y, z = nexttarget.Transform:GetWorldPosition()	-- 获取被攻击对象的世界坐标
        --         DoLishtingStrike(inst, nexttarget, attacker, LIGHTING_DAMAGE)
		-- 		count = count + 1
		-- 		EmitterLightning(inst)
		-- 		if count <= LIGHTING_NUMBER then
		-- 			inst:DoTaskInTime(TUNING.DOTA.MAELSTORM.LIGHTING.INTERVAL, inst.ChainLighting, attacker, nexttarget, x, y, z, count)  -- 调用自身会不会出现栈溢出或者其他错误？
		-- 		end
		-- 	end
		-- end
    end,
}
-------------------------------------------------雷神之锤 or 大雷锤 or 大电锤-------------------------------------------------
local MAELSTORM_CD = TUNING.DOTA.MAELSTORM.LIGHTING.CD
local MAELSTORM_INTERVAL = TUNING.DOTA.MAELSTORM.LIGHTING.INTERVAL
local MAELSTORM_CHANCE = TUNING.DOTA.MAELSTORM.LIGHTING.CHANCE
local MAELSTORM_DAMAGE = TUNING.DOTA.MAELSTORM.LIGHTING.DAMAGE
local MAELSTORM_RANGE = TUNING.DOTA.MAELSTORM.LIGHTING.RANGE
local MAELSTORM_NUMBER = TUNING.DOTA.MAELSTORM.LIGHTING.BOUNCES

dota_item_precious.dota_mjollnir = {
    name = "dota_mjollnir",
    animname = "dota_mjollnir",
	animzip = "dota_precious", 
	taglist = {
    },
    activatename = "DOTA_LIGHTING",
    sharedcoolingtype = "mjollnir",
    manacost = TUNING.DOTA.MJOLLNIR.STATIC.MANA,
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraDamage(TUNING.DOTA.MJOLLNIR.EXTRADAMAGE)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.MJOLLNIR.ATTACKSPEED)
        owner:ListenForEvent("onhitother", inst.onhitotherfn)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraDamage(TUNING.DOTA.MJOLLNIR.EXTRADAMAGE)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.MJOLLNIR.ATTACKSPEED)
        owner:RemoveEventCallback("onhitother", inst.onhitotherfn)
	end,
    fakeweapon = { 
        name = "FakeWeapon_mjollnir",
        damage = 0,
        range = LIGHTING_RANGE,
        projectile = "dota_projectile_maelstorm",
        tag = "chainlighting",
    },
    extrafn=function(inst)
		inst:AddComponent("inventory")
		inst.readylight = true
        inst.onhitotherfn = function(attacker, data)
            if data and data.target and inst.readylight
             and math.random(0,1) <= MAELSTORM_CHANCE
             then
                inst.readylight = false
                local target = data.target
                -- local x, y, z = target.Transform:GetWorldPosition()	-- 获取被攻击对象的世界坐标
                -- DoLishtingStrike(inst, target, attacker, MAELSTORM_DAMAGE)

                inst:DoTaskInTime(MAELSTORM_CD, function() inst.readylight = true end)
                -- inst:DoTaskInTime(MAELSTORM_INTERVAL, inst.ChainLighting, attacker, target, x, y, z, 0)

                if inst.fakeweapon and attacker.components.combat ~= nil then
                    inst.fakeweapon.components.weapon:LaunchProjectile(attacker, target)
                end
            end
        end
		-- inst.ChainLighting = function(inst, attacker, target, x, y, z, count)
		--     local nexttarget = GetNextTarget(attacker, target, MAELSTORM_RANGE, x, y, z)
		-- 	if nexttarget ~= nil then
		-- 		local x, y, z = nexttarget.Transform:GetWorldPosition()	-- 获取被攻击对象的世界坐标
        --         DoLishtingStrike(inst, nexttarget, attacker, MAELSTORM_DAMAGE)
		-- 		count = count + 1
		-- 		EmitterLightning(inst)
		-- 		if count <= MAELSTORM_NUMBER then
		-- 			inst:DoTaskInTime(TUNING.DOTA.MAELSTORM.LIGHTING.INTERVAL, inst.ChainLighting, attacker, nexttarget, x, y, z, count)  -- 调用自身会不会出现栈溢出或者其他错误？
		-- 		end
		-- 	end
		-- end
    end,
}
-------------------------------------------------慧光-------------------------------------------------
dota_item_precious.dota_kaya = {
    name = "dota_kaya",
    animname = "dota_kaya",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.KAYA.INTELLIGENCE)
        owner.components.dotacharacter:AddSpellDamageAMP(TUNING.DOTA.KAYA.SPELLDAMAGEAMP)
        owner.components.dotacharacter:AddSpellLifestealAMP(TUNING.DOTA.KAYA.SPELLLIFESTEALAMP)
        owner.components.dotacharacter:AddManaRegenAMP(TUNING.DOTA.KAYA.MANAREGENAMP)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.KAYA.INTELLIGENCE)
        owner.components.dotacharacter:RemoveSpellDamageAMP(TUNING.DOTA.KAYA.SPELLDAMAGEAMP)
        owner.components.dotacharacter:RemoveSpellLifestealAMP(TUNING.DOTA.KAYA.SPELLLIFESTEALAMP)
        owner.components.dotacharacter:RemoveManaRegenAMP(TUNING.DOTA.KAYA.MANAREGENAMP)
	end,
}
-------------------------------------------------散华-------------------------------------------------
dota_item_precious.dota_sange = {
    name = "dota_sange",
    animname = "dota_sange",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.SANGE.STRENGTH)
        owner.components.dotacharacter:AddStatusResistance(TUNING.DOTA.SANGE.STATUSRESIS)
        owner.components.dotacharacter:AddLifestealAMP(TUNING.DOTA.SANGE.LIFESTEALAMP)
        owner.components.dotacharacter:AddHealthRegenAMP(TUNING.DOTA.SANGE.HEALTHREGENAMP)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.SANGE.STRENGTH)
        owner.components.dotacharacter:RemoveStatusResistance(TUNING.DOTA.SANGE.STATUSRESIS)
        owner.components.dotacharacter:RemoveLifestealAMP(TUNING.DOTA.SANGE.LIFESTEALAMP)
        owner.components.dotacharacter:RemoveHealthRegenAMP(TUNING.DOTA.SANGE.HEALTHREGENAMP)
	end,
}
-------------------------------------------------夜叉-------------------------------------------------
dota_item_precious.dota_yasha = {
    name = "dota_yasha",
    animname = "dota_yasha",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.YASHA.AGILITY)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.YASHA.ATTACKSPEED)
        if owner.components.locomotor ~= nil then
            owner.components.locomotor:SetExternalSpeedMultiplier(inst, "dota_yasha", (1+TUNING.DOTA.YASHA.SPEEDMULTI))
        end
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.YASHA.AGILITY)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.YASHA.ATTACKSPEED)
        if owner.components.locomotor ~= nil then
            owner.components.locomotor:RemoveExternalSpeedMultiplier(inst, "dota_yasha")
        end
	end,
}
-------------------------------------------------慧夜对剑-------------------------------------------------
dota_item_precious.dota_yasha_and_kaya = {
    name = "dota_yasha_and_kaya",
    animname = "dota_yasha_and_kaya",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.YASHA_AND_KAYA.INTELLIGENCE)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.YASHA_AND_KAYA.AGILITY)
        owner.components.dotacharacter:AddSpellDamageAMP(TUNING.DOTA.YASHA_AND_KAYA.SPELLDAMAGEAMP)
        owner.components.dotacharacter:AddSpellLifestealAMP(TUNING.DOTA.YASHA_AND_KAYA.SPELLLIFESTEALAMP)
        owner.components.dotacharacter:AddManaRegenAMP(TUNING.DOTA.YASHA_AND_KAYA.MANAREGENAMP)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.YASHA_AND_KAYA.ATTACKSPEED)
        if owner.components.locomotor ~= nil then
            owner.components.locomotor:SetExternalSpeedMultiplier(inst, "dota_yasha_and_kaya", (1+TUNING.DOTA.YASHA_AND_KAYA.SPEEDMULTI))
        end
    end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.YASHA_AND_KAYA.INTELLIGENCE)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.YASHA_AND_KAYA.AGILITY)
        owner.components.dotacharacter:RemoveSpellDamageAMP(TUNING.DOTA.YASHA_AND_KAYA.SPELLDAMAGEAMP)
        owner.components.dotacharacter:RemoveSpellLifestealAMP(TUNING.DOTA.YASHA_AND_KAYA.SPELLLIFESTEALAMP)
        owner.components.dotacharacter:RemoveManaRegenAMP(TUNING.DOTA.YASHA_AND_KAYA.MANAREGENAMP)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.YASHA_AND_KAYA.ATTACKSPEED)
        if owner.components.locomotor ~= nil then
            owner.components.locomotor:RemoveExternalSpeedMultiplier(inst, "dota_yasha_and_kaya")
        end
	end,
}
-------------------------------------------------散慧对剑-------------------------------------------------
dota_item_precious.dota_kaya_and_sange = {
    name = "dota_kaya_and_sange",
    animname = "dota_kaya_and_sange",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.KAYA_AND_SANGE.INTELLIGENCE)
        owner.components.dotacharacter:AddSpellDamageAMP(TUNING.DOTA.KAYA_AND_SANGE.SPELLDAMAGEAMP)
        owner.components.dotacharacter:AddSpellLifestealAMP(TUNING.DOTA.KAYA_AND_SANGE.SPELLLIFESTEALAMP)
        owner.components.dotacharacter:AddManaRegenAMP(TUNING.DOTA.KAYA_AND_SANGE.MANAREGENAMP)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.KAYA_AND_SANGE.STRENGTH)
        owner.components.dotacharacter:AddStatusResistance(TUNING.DOTA.KAYA_AND_SANGE.STATUSRESIS)
        owner.components.dotacharacter:AddLifestealAMP(TUNING.DOTA.KAYA_AND_SANGE.LIFESTEALAMP)
        owner.components.dotacharacter:AddHealthRegenAMP(TUNING.DOTA.KAYA_AND_SANGE.HEALTHREGENAMP)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.KAYA_AND_SANGE.INTELLIGENCE)
        owner.components.dotacharacter:RemoveSpellDamageAMP(TUNING.DOTA.KAYA_AND_SANGE.SPELLDAMAGEAMP)
        owner.components.dotacharacter:RemoveSpellLifestealAMP(TUNING.DOTA.KAYA_AND_SANGE.SPELLLIFESTEALAMP)
        owner.components.dotacharacter:RemoveManaRegenAMP(TUNING.DOTA.KAYA_AND_SANGE.MANAREGENAMP)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.KAYA_AND_SANGE.STRENGTH)
        owner.components.dotacharacter:RemoveStatusResistance(TUNING.DOTA.KAYA_AND_SANGE.STATUSRESIS)
        owner.components.dotacharacter:RemoveLifestealAMP(TUNING.DOTA.KAYA_AND_SANGE.LIFESTEALAMP)
        owner.components.dotacharacter:RemoveHealthRegenAMP(TUNING.DOTA.KAYA_AND_SANGE.HEALTHREGENAMP)
	end,
}
-------------------------------------------------散夜对剑-------------------------------------------------
dota_item_precious.dota_sange_and_yasha = {
    name = "dota_sange_and_yasha",
    animname = "dota_sange_and_yasha",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.SANGE_AND_YASHA.STRENGTH)
        owner.components.dotacharacter:AddStatusResistance(TUNING.DOTA.SANGE_AND_YASHA.STATUSRESIS)
        owner.components.dotacharacter:AddLifestealAMP(TUNING.DOTA.SANGE_AND_YASHA.LIFESTEALAMP)
        owner.components.dotacharacter:AddHealthRegenAMP(TUNING.DOTA.SANGE_AND_YASHA.HEALTHREGENAMP)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.SANGE_AND_YASHA.AGILITY)
        owner.components.dotacharacter:AddAttackSpeed(TUNING.DOTA.SANGE_AND_YASHA.ATTACKSPEED)
        if owner.components.locomotor ~= nil then
            owner.components.locomotor:SetExternalSpeedMultiplier(inst, "dota_sange_and_yasha", (1+TUNING.DOTA.SANGE_AND_YASHA.SPEEDMULTI))
        end
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.SANGE_AND_YASHA.STRENGTH)
        owner.components.dotacharacter:RemoveStatusResistance(TUNING.DOTA.SANGE_AND_YASHA.STATUSRESIS)
        owner.components.dotacharacter:RemoveLifestealAMP(TUNING.DOTA.SANGE_AND_YASHA.LIFESTEALAMP)
        owner.components.dotacharacter:RemoveHealthRegenAMP(TUNING.DOTA.SANGE_AND_YASHA.HEALTHREGENAMP)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.SANGE_AND_YASHA.AGILITY)
        owner.components.dotacharacter:RemoveAttackSpeed(TUNING.DOTA.SANGE_AND_YASHA.ATTACKSPEED)
        if owner.components.locomotor ~= nil then
            owner.components.locomotor:RemoveExternalSpeedMultiplier(inst, "dota_sange_and_yasha")
        end
	end,
}
-------------------------------------------------迅疾闪光 or 敏捷跳-------------------------------------------------
local function onblink_swift(inst, pt, caster)
	-- inst.components.rechargeable:Discharge(TUNING.DOTA.BLINK_DAGGER.BLINK.CD)		--冷却时间
    if caster.components.debuffable ~= nil then
        caster.components.debuffable:AddDebuff("buff_dota_swift", "buff_dota_venom")
    end
end

dota_item_precious.dota_swift_blink = {
    name = "dota_swift_blink",
    animname = "dota_swift_blink",
	animzip = "dota_precious", 
	taglist = {
        "dota_blink_dagger"
    },
    activatename = "DOTA_BLINK",
    sharedcoolingtype = "blink",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAgility(TUNING.DOTA.SWIFT_BLINK.AGILITY)
        owner:ListenForEvent("healthdelta", inst.CanBlink)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAgility(TUNING.DOTA.SWIFT_BLINK.AGILITY)
        owner:RemoveEventCallback("healthdelta", inst.CanBlink)
	end,
    extrafn=function(inst)
		inst:AddComponent("blinkdagger")	--传送组件
		inst.components.blinkdagger.onblinkfn = onblink_swift
		inst.components.blinkdagger:SetMaxDistance(TUNING.DOTA.BLINK_DAGGER.BLINK.MAX_DISTANCE)
		inst.components.blinkdagger:SetPenDistance(TUNING.DOTA.BLINK_DAGGER.BLINK.PENALTY_DISTANCE)
        inst.components.blinkdagger:SetSoundFX("mengsk_dota2_sounds/items/blink_nailed", "mengsk_dota2_sounds/items/blink_swift")
		
		inst.CanBlink = function(_,data)
			if data and data.amount < 0 then    -- 排除婚戒影响 and data.cause ~= "buff_dota_sacrifice"
				if inst and inst.components.rechargeable ~= nil then
					inst.components.rechargeable:Dota_SetMinTime(TUNING.DOTA.BLINK_DAGGER.BLINK.PENALTY_CD)
					--inst.components.rechargeable:SetCharge(0)	-- 
				end
			end
        end
		
        inst.onequipwithrhfn=function(inst,item,owner)
			if not inst.components.blinkdagger then -- 给box添加一下，方便action那边调用
				inst:AddComponent("blinkdagger")
			end
		end
		inst.onunequipwithrhfn=function(box,item,owner)
			if not box.blinkdaggercheck(box) then
				box:RemoveComponent("blinkdagger")
			end
		end
    end,
}
-------------------------------------------------秘奥闪光 or 智力跳-------------------------------------------------
local function onblink_arcane(inst, pt, caster)
	-- inst.components.rechargeable:Discharge(TUNING.DOTA.BLINK_DAGGER.BLINK.CD)		--冷却时间
    if caster.components.debuffable ~= nil then
        caster.components.debuffable:AddDebuff("buff_dota_arcane", "buff_dota_arcane")
    end
end

dota_item_precious.dota_arcane_blink = {
    name = "dota_arcane_blink",
    animname = "dota_arcane_blink",
	animzip = "dota_precious", 
	taglist = {
        "dota_blink_dagger"
    },
    activatename = "DOTA_BLINK",
    sharedcoolingtype = "blink",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddIntelligence(TUNING.DOTA.ARCANE_BLINK.INTELLIGENCE)
        owner:ListenForEvent("healthdelta", inst.CanBlink)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveIntelligence(TUNING.DOTA.ARCANE_BLINK.INTELLIGENCE)
        owner:RemoveEventCallback("healthdelta", inst.CanBlink)
	end,
    extrafn=function(inst)
		inst:AddComponent("blinkdagger")	--传送组件
		inst.components.blinkdagger.onblinkfn = onblink_arcane
		inst.components.blinkdagger:SetMaxDistance(TUNING.DOTA.BLINK_DAGGER.BLINK.MAX_DISTANCE)
		inst.components.blinkdagger:SetPenDistance(TUNING.DOTA.BLINK_DAGGER.BLINK.PENALTY_DISTANCE)
		inst.components.blinkdagger:SetSoundFX("mengsk_dota2_sounds/items/blink_nailed", "mengsk_dota2_sounds/items/blink_arcane")

		inst.CanBlink = function(_,data)
			if data and data.amount < 0 then    -- 排除婚戒影响 and data.cause ~= "buff_dota_sacrifice"
				if inst and inst.components.rechargeable ~= nil then
					inst.components.rechargeable:Dota_SetMinTime(TUNING.DOTA.BLINK_DAGGER.BLINK.PENALTY_CD)
					--inst.components.rechargeable:SetCharge(0)	-- 
				end
			end
        end

        inst.onequipwithrhfn=function(inst,item,owner)
			if not inst.components.blinkdagger then -- 给box添加一下，方便action那边调用
				inst:AddComponent("blinkdagger")
			end
		end
		inst.onunequipwithrhfn=function(box,item,owner)
			if not box.blinkdaggercheck(box) then
				box:RemoveComponent("blinkdagger")
			end
		end
    end,
}
-------------------------------------------------盛势闪光 or 力量跳-------------------------------------------------
local function onblink_overwhelming(inst, pt, caster)
	-- inst.components.rechargeable:Discharge(TUNING.DOTA.BLINK_DAGGER.BLINK.CD)		--冷却时间
    local strength = caster.components.dotacharacter ~= nil and caster.components.dotacharacter.strength or 0
    local delta = TUNING.DOTA.OVERWHELMING_BLINK.OVERWHELMING.DAMAGE + strength * TUNING.DOTA.OVERWHELMING_BLINK.OVERWHELMING.RATIO
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.DOTA.OVERWHELMING_BLINK.OVERWHELMING.RANGE, { "_combat" }, { "player" })
    for _, ent in ipairs(ents) do
        if ent.components.health ~= nil and not ent.components.health:IsDead() then 	
            ent.components.health:DoDelta(-delta, nil, "overwhelming")
        end
        if caster.components.debuffable ~= nil then
            caster.components.debuffable:AddDebuff("buff_dota_overwhelming", "buff_dota_overwhelming")
        end
    end
end

dota_item_precious.dota_overwhelming_blink = {
    name = "dota_overwhelming_blink",
    animname = "dota_overwhelming_blink",
	animzip = "dota_precious", 
	taglist = {
        "dota_blink_dagger",
    },
    activatename = "DOTA_BLINK",
    sharedcoolingtype = "blink",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddStrength(TUNING.DOTA.OVERWHELMING_BLINK.STRENGTH)
        owner:ListenForEvent("healthdelta", inst.CanBlink)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveStrength(TUNING.DOTA.OVERWHELMING_BLINK.STRENGTH)
        owner:RemoveEventCallback("healthdelta", inst.CanBlink)
	end,
    extrafn=function(inst)
		inst:AddComponent("blinkdagger")	--传送组件
		inst.components.blinkdagger.onblinkfn = onblink_overwhelming
		inst.components.blinkdagger:SetMaxDistance(TUNING.DOTA.BLINK_DAGGER.BLINK.MAX_DISTANCE)
		inst.components.blinkdagger:SetPenDistance(TUNING.DOTA.BLINK_DAGGER.BLINK.PENALTY_DISTANCE)
		inst.components.blinkdagger:SetSoundFX("mengsk_dota2_sounds/items/blink_nailed", "mengsk_dota2_sounds/items/blink_overwhelming")

        inst.CanBlink = function(_,data)
			if data and data.amount < 0 then    -- 排除婚戒影响 and data.cause ~= "buff_dota_sacrifice"
				if inst and inst.components.rechargeable ~= nil then
					inst.components.rechargeable:Dota_SetMinTime(TUNING.DOTA.BLINK_DAGGER.BLINK.PENALTY_CD)
					--inst.components.rechargeable:SetCharge(0)	-- 
				end
			end
        end
		
        inst.onequipwithrhfn=function(inst,item,owner)
			if not inst.components.blinkdagger then -- 给box添加一下，方便action那边调用
				inst:AddComponent("blinkdagger")
			end
		end
		inst.onunequipwithrhfn=function(box,item,owner)
			if not box.blinkdaggercheck(box) then
				box:RemoveComponent("blinkdagger")
			end
		end
    end,
}
-------------------------------------------------灵匣-------------------------------------------------
dota_item_precious.dota_phylactery = {
    name = "dota_phylactery",
    animname = "dota_phylactery",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.PHYLACTERY.ATTRIBUTES)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.PHYLACTERY.MANAREGEN)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.PHYLACTERY.MAXMANA)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.PHYLACTERY.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.PHYLACTERY.ATTRIBUTES)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.PHYLACTERY.MANAREGEN)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.PHYLACTERY.MAXMANA)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.PHYLACTERY.EXTRAHEALTH)
	end,
}
-------------------------------------------------鱼叉-------------------------------------------------
dota_item_precious.dota_harpoon = {
    name = "dota_harpoon",
    animname = "dota_harpoon",
	animzip = "dota_precious", 
	taglist = {
    },
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.PHYLACTERY.ATTRIBUTES)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.PHYLACTERY.MANAREGEN)
        owner.components.dotacharacter:AddMaxMana(TUNING.DOTA.PHYLACTERY.MAXMANA)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.PHYLACTERY.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.PHYLACTERY.ATTRIBUTES)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.PHYLACTERY.MANAREGEN)
        owner.components.dotacharacter:RemoveMaxMana(TUNING.DOTA.PHYLACTERY.MAXMANA)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.PHYLACTERY.EXTRAHEALTH)
	end,
}
return {dota_item_precious = dota_item_precious}