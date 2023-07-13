------------------------------------攻击系统----------------------------------------
-- 主要流程树（物理）：
--				(while,计算每个特效)
-- 主体发动物理攻击 - 计算克敌击先 - 是 - 1.推送事件 - 武器/技能促发特效 
--							   		 - 2.计算额外攻击力 - 目标受到物理攻击 - 计算物理抗性  - 计算暴击 - 计算物理吸血 
--							 	- 否 - 计算必中 - 是 - 计算额外攻击力 - 目标受到物理攻击 - 计算物理抗性  - 计算暴击- 计算物理吸血
--									 			- 否 - 计算落空 - 是 - 攻击中止
--									 						- 否 - 计算额外攻击力 - 目标受到物理攻击 - 计算闪避(evade) - 是 - 攻击中止
--																													- 否 - 计算物理抗性 - 计算暴击 - 计算物理吸血
-- 主要流程树（魔法）：
-- 主体发动魔法攻击 - - 计算技能增强 - 目标受到魔法攻击  - 计算魔法抗性
-------------------------------------------------------------------------------------
-- 必中 、 evade 、 物理抗性 、 魔法抗性 、 暴击 、 额外攻击 、 克敌击先 、 miss 、 额外攻击距离 、 攻击吸血 、 技能吸血
-------------------------------------------------------------------------------------
-- 为了保留其他mod的特色，我们尽量采用原函数进行结算，避免影响其他mod
-------------------------------------------------------------------------------------
local SpDamageUtil = require("components/spdamageutil")	-- 逆天的位面伤害

local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local AREA_EXCLUDE_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }
local INFUSED_RAINDROP_MINDAMAGE = TUNING.DOTA.INFUSED_RAINDROP.MINDAMAGE
local INFUSED_RAINDROP_DAMAGEBLOCK = TUNING.DOTA.INFUSED_RAINDROP.DAMAGEBLOCK

AddComponentPostInit("combat", function(self)

	self.dota_istruestrike = false		-- 记录此次攻击是否触发克敌击先	(因为跨越calcdamage和doattack，所以用不了local)
	self.dota_oldattackrange = 3		-- 记录原先的攻击距离
	self.dota_oldhitrange = 3
	self.dota_min_attack_period = 4		-- 记录原有的攻击间隔
	self.dota_attackspeed = 1			-- 攻速
	self.dota_damagerange = 0			-- 攻击距离

	self.dota_truestrikebonus = 0		-- 记录克敌击先触发时的额外伤害
	self.truestriketable = {}			-- 记录克敌击先效果
	self.updatetruestrike = true		-- 记录克敌击先效果是否需要更新

	self.dota_infused = false			-- 魂泪标记
	
	self.dota_isethereal = false		-- 用于虚灵状态
	self.dota_avatar = false			-- 用于BKB
	----------------------------------------------------
    ----------------- Event:attacked --------------------
	----------------------------------------------------
	-- 注意：
	-- 根据流程树(物理)，最优顺序是在闪避判定完后，先计算目标debuff，再计算伤害，再物理抗性或者暴击，再吸血
	-- 但是由于饥荒文件本身的构造，debuff和伤害结算被捆绑到了一起，我们无法再插入判断
	-- 所以只能退而求其次，在闪避计算结束后，我们先计算物理抗性和暴击，将经过处理的伤害再导入原函数计算debuff，并结算
	-- 对于吸血，则通过结算时推送的attacked事件来计算

	-- 攻击吸血、技能吸血
	self.inst:ListenForEvent("attacked", function (inst, data)
		if data and data.attacker and data.attacker.components.dotaattributes then  
			local damage = 0
			local attacker = data.attacker
			
			if attacker:HasTag("player") and data.damageresolved ~= nil and data.damageresolved > 0 then
				damage = data.damageresolved
			elseif data.original_damage ~= nil and data.original_damage > 0 then
				damage = data.original_damage
			end

			if damage > 0 and attacker.components.health ~= nil and attacker.components.health:GetPercent() < 1 
			 and not (self.inst:HasTag("wall") or self.inst:HasTag("engineering")) then -- 蝙蝠刀代码
				if data.stimuli ~= nil and data.stimuli == "dotamagic" then	-- 技能吸血
					local delta = attacker.components.dotaattributes.spelllifesteal:Get() * damage
					if delta > 0 then attacker.components.health:DoDelta(delta, false, "dota_spelllifesteal") end
				else	-- 物理吸血
					local delta = attacker.components.dotaattributes.lifesteal:Get() * damage
					if delta > 0 then attacker.components.health:DoDelta(delta, false, "dota_lifesteal") end
				end
			end
		end
	end)

	----------------------------------------------------
    ------------------- GetAttacked --------------------
	----------------------------------------------------
	-- 必中、evade、物理抗性
	local old_GetAttacked = self.GetAttacked
	function self:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
		if stimuli == "dotamagic" or stimuli == "electric" then
			return self:GetDotaMagicAttacked(attacker, damage, weapon, stimuli, spdamage)
		elseif stimuli == "dota_orginal" then
			return old_GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
		else
			if self.inst.components.dotaattributes ~= nil then
			
				-- 虚无状态
				if self.dota_isethereal then
					return 0
				end

				if attacker and attacker.components.combat and attacker.components.combat.dota_isethereal then
					return 0
				end

				-- 计算必中
				local dota_isaccuracy = false -- 必中记录
				local accuracy = self.inst.components.dotaattributes.accuracy:Get()	-- 获取必中概率
				if (stimuli == "dota_accuracy") or (accuracy > 0 and math.random() < accuracy) then	-- 条件：必中概率大于0，触发必中
					dota_isaccuracy = true	-- 记录此次攻击触发必中
				end

				-- 计算闪避
				local istruestrike = attacker and attacker.components.combat and attacker.components.combat.dota_istruestrike or false -- 获取克敌击先
				if (not istruestrike and not dota_isaccuracy)	-- -- 未触发克敌击先和必中
				 then
					local dodgechance = self.inst.components.dotaattributes.dodgechance:Get()	-- 获取闪避概率
					if dodgechance > 0 and math.random() < dodgechance then	-- 闪避成功
						self.inst:PushEvent("dotaevent_dodge", { inst = self.inst, attacker = attacker})	-- 推送事件，用于触发特效
						return 0
					end
				end

				-- 计算格挡
				damage = self.inst.components.dotaattributes:CalcBlockDamage(damage)

				-- 计算物理抗性
				local attackresistance = self.inst.components.dotaattributes.attackresistance	-- 获取物理抗性
				damage = damage * (1 - attackresistance)		-- 乘以物理抗性，得到减免后的伤害

				-- 计算物理护盾
				damage = self.inst.components.dotaattributes:CalcNormalShieldDamage(damage)

				-- 计算魔法抗性
				if spdamage ~= nil then
					local spellresistance = self.inst.components.dotaattributes.spellresistance:Get()	-- 获取魔法抗性
					for sptype, dmg in pairs(spdamage) do
						dmg = dmg * (1 - spellresistance)
						spdamage[sptype] = dmg > 0 and dmg or nil
					end
				end
			end
		end
		-- 导入原函数进行后续计算
		if old_GetAttacked then
			return old_GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
		end
	end

	----------------------------------------------------
    -------------- GetDotaMagicAttacked ----------------
	----------------------------------------------------
	-- 魔法抗性、技能增强、魂泪
	-- 照着官方代码写的
	-- 不考虑位面伤害，显然的
	function self:GetDotaMagicAttacked(attacker, damage, weapon, stimuli, spdamage)
		if self.inst.components.dotaattributes ~= nil then

			if ((self.inst.components.health and self.inst.components.health:IsDead()) or (self:Dota_IsAvatar())) then
				return true
			end
			
			self.lastwasattackedtime = GetTime()

			local blocked = false
			-- Todo：这一部分的 redirect_combat 需要重新评估兼容的可能性，以判断其存在的必要
			-- local damageredirecttarget = self.redirectdamagefn ~= nil and self.redirectdamagefn(self.inst, attacker, damage, weapon, stimuli) or nil
			local damageresolved = 0
			local original_damage = damage
			self.lastattacker = attacker

			if self.inst.components.health ~= nil and damage ~= nil -- and damageredirecttarget == nil 
			 then
				if damage > 0 and not self.inst.components.health:IsInvincible() then
					local spelldamageamp = 0
					local spellweak = 0
					if attacker.components.dotaattributes ~= nil then
						spelldamageamp = attacker.components.dotaattributes.spelldamageamp:Get()	-- 获取技能增强（Todo:存疑）
						spellweak = attacker.components.dotaattributes.spellweak:Get()	-- 获取技能伤害降低（Todo:存疑）
					end
					local spellresistance = self.inst.components.dotaattributes.spellresistance:Get()	-- 获取魔法抗性
					damage = damage * (1 + spelldamageamp) * (1 - spellweak) * (1 - spellresistance)		-- 乘以魔法抗性，得到结算后的伤害
					
					-- print("[debug 1] damage: " .. damage .. " MINDAMAGE: " .. INFUSED_RAINDROP_MINDAMAGE)
					--凝魂之露效果
					if self:Dota_IsInfused() and damage > INFUSED_RAINDROP_MINDAMAGE then	
						if self.inst.components.inventory then
							local item = self.inst.components.inventory:FindDotaItem(function(inst) return inst and inst.prefab == "dota_infused_raindrop" end)
							if item and item.components.rechargeable and item.components.rechargeable:IsCharged() then	-- Todo : cd可能造成bug吗
								item.UseOne()
								if self.inst.SoundEmitter ~= nil then
									self.inst.SoundEmitter:PlaySound("mengsk_dota2_sounds/items/infused_raindrop", nil, BASE_VOICE_VOLUME)
								end
								damage = damage - INFUSED_RAINDROP_DAMAGEBLOCK
								if damage < 0 then return not blocked end
							end
						end
					end

					--魔法护盾效果
					damage = self.inst.components.dotaattributes:CalcMagicShieldDamage(damage)

					local cause = attacker == self.inst and weapon or attacker
					--V2C: guess we should try not to crash old mods that overwrote the health component
					damageresolved = self.inst.components.health:DoDelta(-damage, nil, cause ~= nil and (cause.nameoverride or cause.prefab) or "NIL", nil, cause)
					damageresolved = damageresolved ~= nil and -damageresolved or damage
					if self.inst.components.health:IsDead() then
						if attacker ~= nil then
							attacker:PushEvent("killed", { victim = self.inst })
						end
						if self.onkilledbyother ~= nil then
							self.onkilledbyother(self.inst, attacker)
						end
					end
				else
					blocked = true
				end
			end

			
			-- local redirect_combat = damageredirecttarget ~= nil and damageredirecttarget.components.combat or nil
			-- if redirect_combat ~= nil then
			-- 	redirect_combat:GetAttacked(attacker, damage, weapon, stimuli)
			-- end
		
			if self.inst.SoundEmitter ~= nil and not self.inst:IsInLimbo() then
				local hitsound = self:GetImpactSound(self.inst, weapon)
				if hitsound ~= nil then
					self.inst.SoundEmitter:PlaySound(hitsound)
				end
				-- if damageredirecttarget ~= nil then
					-- if redirect_combat ~= nil and redirect_combat.hurtsound ~= nil then
					-- 	self.inst.SoundEmitter:PlaySound(redirect_combat.hurtsound)
					-- end
				if self.hurtsound ~= nil then
					self.inst.SoundEmitter:PlaySound(self.hurtsound)
				end
			end
		
			if not blocked then
				self.inst:PushEvent("attacked", { attacker = attacker, damage = damage, damageresolved = damageresolved, original_damage = original_damage, weapon = weapon, stimuli = stimuli, redirected = nil, noimpactsound = self.noimpactsound })
		
				if self.onhitfn ~= nil then
					self.onhitfn(self.inst, attacker, damage)
				end
		
				if attacker ~= nil then
					attacker:PushEvent("onhitother", { target = self.inst, damage = damage, damageresolved = damageresolved, stimuli = stimuli, weapon = weapon, redirected = nil })
					if attacker.components.combat ~= nil and attacker.components.combat.onhitotherfn ~= nil then
						attacker.components.combat.onhitotherfn(attacker, self.inst, damage, stimuli, weapon, damageresolved)
					end
				end
			else
				self.inst:PushEvent("blocked", { attacker = attacker })
			end

			if self.target == nil or self.target == attacker then
				self.lastwasattackedbytargettime = self.lastwasattackedtime
			end

			return not blocked
		end
		
		if old_GetAttacked then
			return old_GetAttacked(self, attacker, damage, weapon, "dota_orginal", spdamage)
		end
	end

	----------------------------------------------------
    ------------------- CalcDamage ---------------------
	----------------------------------------------------
	-- 暴击、额外攻击
	-- 思路：
	-- 希望的结果 = (原攻击 + 额外攻击) * 相关系数 * 暴击倍率 = 原攻击 * 相关系数 * 暴击倍率 + 额外攻击 * 相关系数 * 暴击倍率
	--			 = 原返回值 * 暴击倍率 + 额外攻击 * 相关系数 * 暴击倍率
	-- 所以复制原combat函数来重新计算相关系数，并获取原返回值
	-- 这是我能想到的最好的兼容方式

	local old_CalcDamage = self.CalcDamage	-- 获取原函数
	function self:CalcDamage(target, weapon, multiplier)
		if self.inst.components.dotaattributes ~= nil then
			local olddamage, oldspdamage = old_CalcDamage(self, target, weapon, multiplier)	-- 这是原函数的返回值
			-- 下面一串都是原函数，主要是获取相关系数，因为我们不需要basedamage了，所以注释掉所有basedamage
			-- bonus的伤害也已经在前面原返回值计算过了，这里不应计算
			-- 同时我们需要增加克敌击先的附加伤害
			local basedamage
			local basemultiplier = self.damagemultiplier
			local externaldamagemultipliers = self.externaldamagemultipliers
			local damagetypemult = 1	-- what's this?
			-- local bonus = self.damagebonus --not affected by multipliers
			local playermultiplier = target ~= nil and target:HasTag("player")
			local pvpmultiplier = playermultiplier and self.inst:HasTag("player") and self.pvp_damagemod or 1
			local mount = nil
			-- local spdamage
		
			if weapon ~= nil then
				--No playermultiplier when using weapons
				-- basedamage, spdamage = weapon.components.weapon:GetDamage(self.inst, target)
---@diagnostic disable-next-line: cast-local-type
				playermultiplier = 1
				--#V2C: entity's own damagetypebonus stacks with weapon's damagetypebonus
				if self.inst.components.damagetypebonus ~= nil then
					damagetypemult = self.inst.components.damagetypebonus:GetBonus(target)
				end
			else
				-- basedamage = self.defaultdamage
---@diagnostic disable-next-line: cast-local-type
				playermultiplier = playermultiplier and self.playerdamagepercent or 1
		
				if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then
					mount = self.inst.components.rider:GetMount()
					if mount ~= nil and mount.components.combat ~= nil then
						basedamage = mount.components.combat.defaultdamage
						basemultiplier = mount.components.combat.damagemultiplier
						externaldamagemultipliers = mount.components.combat.externaldamagemultipliers
						-- bonus = mount.components.combat.damagebonus
						if mount.components.damagetypebonus ~= nil then
							damagetypemult = mount.components.damagetypebonus:GetBonus(target)
						end
						-- spdamage = SpDamageUtil.CollectSpDamage(mount, spdamage)
					else
						if self.inst.components.damagetypebonus ~= nil then
							damagetypemult = self.inst.components.damagetypebonus:GetBonus(target)
						end
						-- spdamage = SpDamageUtil.CollectSpDamage(self.inst, spdamage)
					end
		
					local saddle = self.inst.components.rider:GetSaddle()
					if saddle ~= nil and saddle.components.saddler ~= nil then
						basedamage = basedamage + saddle.components.saddler:GetBonusDamage()
						if saddle.components.damagetypebonus ~= nil then
							damagetypemult = damagetypemult * saddle.components.damagetypebonus:GetBonus(target)
						end
						-- spdamage = SpDamageUtil.CollectSpDamage(saddle, spdamage)
					end
				else
					if self.inst.components.damagetypebonus ~= nil then
						damagetypemult = self.inst.components.damagetypebonus:GetBonus(target)
					end
					-- spdamage = SpDamageUtil.CollectSpDamage(self.inst, spdamage)
				end
			end

		
			local extradamage = self.inst.components.dotaattributes.extradamage:Get()	-- 获取额外攻击力
			local criticalmulti = self.inst.components.dotaattributes:GetCritical() or 1	-- 获取暴击倍率
			local dotabonus = target:HasTag("dota_avatar") and 0 or (self.dota_truestrikebonus)	-- 获取克敌击先附加伤害
	
			-- if spdamage ~= nil then
			-- 	local spmult =
			-- 		damagetypemult *
			-- 		playermultiplier *
			-- 		pvpmultiplier
		
			-- 	if spmult ~= 1 then
			-- 		spdamage = SpDamageUtil.ApplyMult(spdamage, spmult)
			-- 	end
			-- end

			-- 根据前面的思路编写返回值，位面伤害也计算暴击
			local newdamage = olddamage * criticalmulti
			+ extradamage * criticalmulti
			* (basemultiplier or 1)
			* externaldamagemultipliers:Get()
			* damagetypemult
			* (multiplier or 1)
			* playermultiplier
			* pvpmultiplier
			* (self.customdamagemultfn ~= nil and self.customdamagemultfn(self.inst, target, weapon, multiplier, mount) or 1)
			+ (dotabonus or 0)

			-- local newspdamage = nil
			-- 表是引用传递，就不用新建表了
			if oldspdamage ~= nil then
				for sptype, dmg in pairs(oldspdamage) do
					dmg = dmg * criticalmulti
					oldspdamage[sptype] = dmg > 0 and dmg or nil
				end
			end

			return newdamage, oldspdamage
		end
		if old_CalcDamage then
			return old_CalcDamage(self, target, weapon, multiplier)
		end
	end

	----------------------------------------------------
    -------------------- DoAttack ----------------------
	----------------------------------------------------
	-- 思路：
	-- 为了兼容性，思路是让闪避相关判定进行，然后决定是否返回原函数
	-- 克敌击先 、 miss

	local old_DoAttack = self.DoAttack
	function self:DoAttack(targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
		if self.dota_provincefn ~= nil then stimuli = "dotamagic" end	-- 英灵胸针效果
		if stimuli == "dota_orginal" then
			return old_DoAttack(self, targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
		elseif self.inst.components.dotaattributes and stimuli ~= "dotamagic" then

			-- if self.dota_isethereal then
			-- 	return
			-- end

			if not self:CanHitTarget(targ, weapon) then	-- 超出命中距离就返回原函数
				return old_DoAttack(self, targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
			end

			-- 计算克敌击先
			self.dota_istruestrike = false		-- 重设克敌击先记录
			self.dota_truestrikebonus = 0		-- 重设克敌击先附加伤害
			if #self.truestriketable > 0 then	-- Todo:可删除此类判定
				for _, v in pairs(self.truestriketable) do	-- 先获取表中所有克敌击先的效果
					if math.random() < v.pr then     -- 判断是否触发
						self.inst:PushEvent("dotaevent_truestrike", { target = targ, weapon = v.weapon})	-- 推送事件，可用于触发特效
						self.dota_truestrikebonus = self.dota_truestrikebonus + v.damage	-- 记录附加伤害
						self.dota_istruestrike = true	-- 记录此次攻击触发克敌击先
					end
				end
			end

			-- 计算落空 (miss)
			local misschance = self.inst.components.dotaattributes.misschance:Get()
			if (not self.dota_istruestrike) and misschance ~= 0 and math.random() < misschance then	-- 未触发克敌击先，落空判断
				self.inst:PushEvent("dotaevent_miss", { inst = self.inst})	-- 推送事件，用于触发特效
				return 0
			end

			-- 返回原计算函数
			if old_DoAttack then
				return old_DoAttack(self, targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
			end
		end
		if old_DoAttack then
			return old_DoAttack(self, targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos)
		end
	end

	----------------------------------------------------
    ------------ ResetTrueStrikeTable ------------------
	----------------------------------------------------
	-- 获取对象的克敌击先表，这导致更新表时都要用一次这个函数

	function self:ResetTrueStrikeTable()	-- 应该可以用索引之类的方式来代替重复数据
		if self.inst.components.dotaattributes ~= nil then
			if self.inst.components.dotacharacter ~= nil then
				self.truestriketable = self.inst.components.dotacharacter.equippable.truestrike
			else
				self.truestriketable = self.inst.components.dotaattributes.truestrike
			end
		end
	end

	----------------------------------------------------
    ---------------- IsValidTarget ---------------------
	----------------------------------------------------
	-- 隐身状态特殊效果，Todo:作用存疑，暂不启用
	-- local old_GetHitRange = self.IsValidTarget
	-- function self:IsValidTarget(target)
	-- 	if target:HasTag("dota_shadow") then return false end
	-- 	return old_GetHitRange(target)
	-- end

	----------------------------------------------------
    ---------- GetHitRange / GetAttackRange ------------	-- 关于attackrange和hitrange的修改有待考量
	----------------------------------------------------	-- 因为攻击距离和武器有关，所以修改起来得再细致考虑一下

	-- 额外攻击距离
	-- 我们改一下命中的判定范围，考虑装备带来的攻击距离变化
	local old_GetHitRange = self.GetHitRange
	function self:GetHitRange()
		if self.inst.components.dotaattributes ~= nil then
			local oldhitrange = old_GetHitRange(self)
			return oldhitrange + self.dota_damagerange
		end
		if old_GetHitRange then
			return old_GetHitRange(self)
		end
	end
	local old_GetAttackRange = self.GetAttackRange
	function self:GetAttackRange()
		if self.inst.components.dotaattributes ~= nil then
			local oldattackrange = old_GetAttackRange(self)
			return oldattackrange + self.dota_damagerange
		end
		if old_GetAttackRange then
			return old_GetAttackRange(self)
		end
	end

	-- 用于更新attackrange
	function self:Dota_UpdateAttackRange(val)
		if val then
			self.dota_damagerange = val
		else
			self.dota_damagerange = self.inst.components.dotaattributes and self.inst.components.dotaattributes.damagerange:Get()
		end
	end

	----------------------------------------------------
    ---------------- SetAttackPeriod -------------------
	----------------------------------------------------

	-- 记录攻击间隔的变化
	local old_SetAttackPeriod = self.SetAttackPeriod
	function self:SetAttackPeriod(period)
		if type(period) == "table" then
			self.dota_min_attack_period = deepcopy(period)
			for k, v in pairs(period) do
				v = v / self.dota_attackspeed
			end
		else
			self.dota_min_attack_period = period
			period = period / self.dota_attackspeed
		end
		
		if old_SetAttackPeriod then
			return old_SetAttackPeriod(self, period)
		end
	end

	-- 更新攻击间隔
	function self:Dota_UpdateAttackPeriod(period)
		if period ~= nil then
			self.dota_attackspeed = period
		end
		self:SetAttackPeriod(self.dota_min_attack_period)
	end

	----------------------------------------------------
    --------- Dota_SetInfused / Dota_IsInfused ---------
	----------------------------------------------------
	-- 新函数，用于记录凝魂之泪效果

	function self:Dota_SetInfused(val)
		self.dota_infused = val
		-- self.inst:PushEvent("dota_infusedtoggle", { infused = val })
	end
	function self:Dota_IsInfused()
		return self.dota_infused
	end

	----------------------------------------------------
    ---------------- Dota_SetEthereal ------------------
	----------------------------------------------------
	self.inst.replica.combat:Dota_SetEthereal(false)
	function self:Dota_SetEthereal(val)
		if val then val = true else val = false end
		self.dota_isethereal = val
		-- self.inst:PushEvent("dota_canattacktoggle", { dota_isethereal = val })
		-- if self.inst:HasTag("player") and self.inst.userid then
		-- 	SendModRPCToClient(GetClientModRPC("DOTARPC", "DotaCanAttack"), self.inst.userid, val)
		-- end
		self.inst.replica.combat:Dota_SetEthereal(val)
	end

	function self:Dota_IsEthereal()
		return self.dota_isethereal
	end
	local old_CanAttack = self.CanAttack
	function self:CanAttack(target)
		return not self.dota_isethereal and old_CanAttack(self, target)
	end
	local old_LocomotorCanAttack = self.LocomotorCanAttack
	function self:LocomotorCanAttack(reached_dest, target)
		local dest, valid, cooldown = old_LocomotorCanAttack(self, reached_dest, target)
		if self.dota_isethereal then valid = true end
		return dest, valid, cooldown
	end

	----------------------------------------------------
    ---------------- Dota_SetAvatar --------------------
	----------------------------------------------------
	function self:Dota_SetAvatar(val)
		self.dota_avatar = val
	end

	function self:Dota_IsAvatar()
		return self.dota_avatar
	end

	----------------------------------------------------
	-------------- CanDotaMagicHitTarget ---------------
	----------------------------------------------------
	-- 判断该魔法攻击能否被bkb免疫
	-- function self:CanDotaMagicHitTarget(target, weapon)
		-- if self.inst ~= nil
		 -- and self.inst:IsValid()
		 -- and target ~= nil
		 -- and target:IsValid()
		 -- and not target:IsInLimbo()
		 -- and target.components.combat:CanBeAttacked(self.inst)
		 -- and not target:HasTag("dota_avatar")
		 -- then
			-- return true
		-- end
		-- return false
	-- end

	-- --------------------------------------------------
	-- -------------- DoDotaMagicAttack -----------------
	-- --------------------------------------------------
	-- -- 思路：
	-- -- 事实上这段函数和原函数里的DoAttack几乎没有差别，选择新函数只是因为原函数中的 CalcDamage 函数没办法计算魔法伤害
	-- function self:DoDotaMagicAttack(targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos, damage)
	-- 	if self.inst.components.dotaattributes ~= nil
	-- 	 and stimuli == "dotamagic" then	-- 限定为魔法
	-- 		if instrangeoverride then self.temprange = instrangeoverride end
	-- 		if instpos then self.temppos = instpos end
	-- 		if targ == nil then targ = self.target end
	-- 		if weapon == nil then weapon = self:GetWeapon() end
	-- 	end
	-- end
end)

AddClassPostConstruct("components/combat_replica", function(self, inst)

	self._dota_isethereal = GLOBAL.net_bool(inst.GUID, "combat._dota_isethereal")
	self._dota_isethereal:set(false)

	-- self._dota_isethereal = true

	function self:Dota_SetEthereal(isethereal)
		self._dota_isethereal:set(isethereal)
	end

	function self:Dota_IsEthereal()
		self._dota_isethereal:value()
	end

	local old_CanAttack = self.CanAttack
	function self:CanAttack(target)
		return not self:Dota_IsEthereal() and old_CanAttack(self, target)
	end

	local old_LocomotorCanAttack = self.LocomotorCanAttack
	function self:LocomotorCanAttack(reached_dest, target)
		local dest, valid, cooldown = old_LocomotorCanAttack(self, reached_dest, target)
		if self:Dota_IsEthereal() then valid = true end
		return dest, valid, cooldown
	end
end)

-- local function updatecanattack(val)
-- 	if TheNet:GetIsClient() then
-- 		if ThePlayer and ThePlayer.replica.combat then
-- 			ThePlayer.replica.combat._dota_canattack = val
-- 		end
-- 	end
-- end

-- AddClientModRPCHandler("DOTARPC", "DotaCanAttack", updatecanattack)

-- local function OnDotaCanAttackDirty(inst)

-- end

-- local function RegisterNetListeners(inst)
--     if TheWorld.ismastersim then
--         local parent = inst.entity:GetParent()
-- 		inst:ListenForEvent("dota_canattacktoggle", OnDotaCanAttackDirty, parent)
-- 	else
-- 		inst:ListenForEvent("DotaCanAttackDirty", OnDotaCanAttackDirty)
-- 	end
-- end

-- AddPrefabPostInit("player_classified", function(inst)
-- 	inst._dota_canattack = GLOBAL.net_bool(inst.GUID, "DotaCanAttack", "DotaCanAttackDirty")

-- 	inst:DoStaticTaskInTime(0, RegisterNetListeners)

-- 	if GLOBAL.TheWorld.ismastersim then
--         inst.OnDotaCanAttackDirty = function(owner, data)
--             inst._dota_canattack:set(data.dota_isethereal)
--         end
-- 	end
-- end)