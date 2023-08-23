local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local dota_projectile = {}
local function PlaySound(inst, sound, ...)
	if inst.SoundEmitter ~= nil and sound ~= nil then
		inst.SoundEmitter:PlaySound(sound, ...)
		-- SoundEmitter:PlaySound(emitter, event, name, volume, ...)
	end
end
-------------------------------------------------阿托斯之棍-------------------------------------------------
dota_projectile.cripple = {
    name = "dota_projectile_cripple",
    animzip = "staff_projectile",
    prefabs = {
        "shatter",
        "spat_splat_fx",
    },
    bank = "projectile",
    build = "staff_projectile",
    anim = "ice_spin_loop",
    extrafn = function(inst)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end,

    projectile = true,
    speed = 50,
    onhitfn = function(inst, weapon, target)
        if not target:IsValid() then return end

        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("spat_splat_fx").Transform:SetPosition(x, 0, z)
        -- local fx = SpawnPrefab("shatter")
        -- fx.Transform:SetPosition(target.Transform:GetWorldPosition())
        -- fx.components.shatterfx:SetLevel(2)

        if target.components.debuffable ~= nil then
            target.components.debuffable:AddDebuff("buff_dota_cripple", "buff_dota_cripple")
        end

        inst:Remove()
    end,
    onmissfn = function(inst, attacker, target)
        inst:Remove()
    end,
}
-------------------------------------------------缚灵索-------------------------------------------------
local ETERNAL_DAMAGE = TUNING.DOTA.GLEIPNIR.ETERNAL.DAMAGE
dota_projectile.eternal = {
    name = "dota_projectile_eternal",
    animzip = "staff_projectile",
    prefabs = {
        "shatter",
        "spat_splat_fx",
    },
    bank = "projectile",
    build = "staff_projectile",
    anim = "ice_spin_loop",
    extrafn = function(inst)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end,

    projectile = true,
    speed = 50,
    onthrownfn = function(inst, owner, target, attacker)
        inst.owner = owner
		inst.attacker = attacker
        PlaySound(owner, "mengsk_dota2_sounds/items/gleipnir_cast", nil, BASE_VOICE_VOLUME)
    end,
    onhitfn = function(inst, weapon, target)
        if not target:IsValid() then return end

        local attacker = inst.attacker
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("spat_splat_fx").Transform:SetPosition(x, 0, z)

        if target and target.components.combat ~= nil and attacker and attacker.components.combat and attacker:IsValid() then
            target.components.combat:GetAttacked(attacker, ETERNAL_DAMAGE, nil, "dotamagic")
        end

        if target.components.debuffable ~= nil then
            target.components.debuffable:AddDebuff("buff_dota_eternal", "buff_dota_eternal")
            PlaySound(target, "mengsk_dota2_sounds/items/gleipnir_target", nil, BASE_VOICE_VOLUME)
        end

        inst:Remove()
    end,
    onmissfn = function(inst, attacker, target)
        inst:Remove()
    end,
}
-------------------------------------------------电锤-------------------------------------------------
local CHAIN_DAMAGE = TUNING.DOTA.MAELSTORM.LIGHTING.DAMAGE
local CHAIN_INTERVAL = TUNING.DOTA.MAELSTORM.LIGHTING.INTERVAL
local CHAIN_RANGE = TUNING.DOTA.MAELSTORM.LIGHTING.RANGE
local CHAIN_BOUNCES = TUNING.DOTA.MAELSTORM.LIGHTING.BOUNCES
local CHAIN_SPEED = 50   -- 不是及时命中，再快的速度也不稳定

local CHAIN_MUST_TAGS = { "_combat" }
local CHAIN_NO_TAGS = { "INLIMBO", "wall", "notarget", "player", "companion", "flight", "invisible", "noattack", "hiding" }

local function TryBounce(inst, x, z, attacker, target, range)
	if attacker.components.combat == nil or not attacker:IsValid() then
		inst:Remove()
		return
	end
	local newtarget, newrecentindex, newhostile
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, range, CHAIN_MUST_TAGS, CHAIN_NO_TAGS)) do
    -- 检索附近符合对象的实体
		if v ~= target and v.entity:IsVisible() -- 先排除自身
		 and not (v.components.health ~= nil and v.components.health:IsDead())
		 and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) -- 简单检查一下
		then
			local vhostile = v:HasTag("hostile")
			local vrecentindex
			if inst.recenttargets ~= nil then   -- 寻找一下该实体是否在recenttargets表，此时表中有过去攻击的对象
				for i1, v1 in ipairs(inst.recenttargets) do
					if v == v1 then
						vrecentindex = i1   -- 如果在表中就记录一下，意味着被攻击过
						break
					end
				end
			end
			if inst.initial_hostile and not vhostile and vrecentindex == nil and v.components.locomotor == nil then
				--attack was initiated against a hostile target
				--skip if non-hostile, can't move, and has never been targeted
			elseif newtarget == nil then
                -- 第一次大循环，先记录一下此次循环的目标目标
				newtarget = v   -- 记录此次循环的目标
				newrecentindex = vrecentindex
				newhostile = vhostile
			elseif vhostile and not newhostile then
                -- 下一次大循环，通过tag筛选目标，若同时满足：此次大循环的目标有tag、上次大循环的目标没有tag。重置目标
				newtarget = v
				newrecentindex = vrecentindex
				newhostile = vhostile
			elseif vhostile or not newhostile then 
                -- 下一次大循环，通过tag进一步筛选目标。与上步作用一致，但上步能处理通用情况，减少系统开销。
				if vrecentindex == nil then -- 如果此次循环选中的目标未被攻击过
					if newrecentindex ~= nil or (newtarget.prefab ~= target.prefab and v.prefab == target.prefab) then
                        -- 上次大循环的目标被攻击过 
                        -- 或者 
                        -- 两次大循环的目标均未被攻击过，优先相同实体的目标
						newtarget = v
						newrecentindex = vrecentindex
						newhostile = vhostile
					end
				elseif newrecentindex ~= nil and vrecentindex < newrecentindex then  
                    -- 两次循环选中的目标均被攻击过，选择最早被攻击的对象
					newtarget = v
					newrecentindex = vrecentindex
					newhostile = vhostile
				end
			end
		end
	end

    -- 待上面大循环确认下一个目标后，计算后续
	if newtarget ~= nil then
		inst.Physics:Teleport(x, 0, z)
		inst:Show()
		-- inst.components.projectile:SetSpeed(CHAIN_SPEED)
		if inst.recenttargets ~= nil then
			if newrecentindex ~= nil then
				table.remove(inst.recenttargets, newrecentindex)    
                -- 下一个目标在表中，则从表中移除该目标，当然了，还没攻击到呢，在表中是几个意思
			end
			table.insert(inst.recenttargets, target)    -- 把自身存入表中
		else
			inst.recenttargets = { target } -- 把自身存入表中
		end
		inst.components.projectile:SetBounced(true)
		inst.components.projectile.overridestartpos = Vector3(x, 0, z)
		inst.components.projectile:Throw(inst.owner, newtarget, attacker)
	else
		inst:Remove()
	end
end

dota_projectile.chain = {
    name = "dota_projectile_chain",
    animzip = "brilliance_projectile_fx",
    prefabs = {
    },
    bank = "brilliance_projectile_fx",
    build = "brilliance_projectile_fx",
    anim = "idle_loop",
    extrafn = function(inst)
        inst.AnimState:SetSymbolMultColour("light_bar", 1, 1, 1, .5)
        inst.AnimState:SetSymbolBloom("light_bar")
        inst.AnimState:SetSymbolBloom("glow")
        inst.AnimState:SetLightOverride(.5)
    end,

    projectile = true,
    speed = CHAIN_SPEED,
    -- range = 25,
    onthrownfn = function(inst, owner, target, attacker)
        inst.owner = owner
		inst.attacker = attacker
        if inst.bounces == nil then
            inst.bounces = 1
            inst.initial_hostile = target ~= nil and target:IsValid() and target:HasTag("hostile")
        end
        PlaySound(inst, "mengsk_dota2_sounds/items/item_mael_lightning_01", nil, BASE_VOICE_VOLUME)
    end,
    onhitfn = function(inst, weapon, target)	
		-- inst 为 projectile ; weapon 为 虚拟武器 ; target 为 攻击目标
		-- 所以获取玩家的时候用 thrownfn 里记录的 attacker
        local x, y, z
		local attacker = inst.attacker
        if target:IsValid() then
            local radius = target:GetPhysicsRadius(0) + .2
            local angle = (inst.Transform:GetRotation() + 180) * DEGREES
            x, y, z = target.Transform:GetWorldPosition()
            x = x + math.cos(angle) * radius + GetRandomMinMax(-.2, .2)
            -- y = GetRandomMinMax(.1, .3)
            z = z - math.sin(angle) * radius + GetRandomMinMax(-.2, .2)
        else
            x, y, z = inst.Transform:GetWorldPosition()
        end
		
        if target and target.components.combat ~= nil and attacker and attacker.components.combat and attacker:IsValid() then
            target.components.combat:GetAttacked(attacker, CHAIN_DAMAGE, nil, "electric")
        end
		
        if inst.bounces ~= nil and inst.bounces < CHAIN_BOUNCES and attacker and attacker.components.combat and attacker:IsValid() then
			inst.bounces = inst.bounces + 1
            inst.Physics:Stop()
            inst:Hide()
            inst:DoTaskInTime(CHAIN_INTERVAL, TryBounce, x, z, attacker, target, CHAIN_RANGE)
        else
            inst:Remove()
        end
    end,
    onmissfn = function(inst, attacker, target)
        if not inst.AnimState:IsCurrentAnimation("disappear") then
            inst.AnimState:PlayAnimation("disappear")
            if not inst.removing then
                inst.removing = true
                inst:ListenForEvent("animover", inst.Remove)
            end
        end
    end,
}
-------------------------------------------------雷神之锤 or 大雷锤 or 大电锤-------------------------------------------------
local MAELSTORM_INTERVAL = TUNING.DOTA.MJOLLNIR.LIGHTING.INTERVAL
local MAELSTORM_DAMAGE = TUNING.DOTA.MJOLLNIR.LIGHTING.DAMAGE
local MAELSTORM_RANGE = TUNING.DOTA.MJOLLNIR.LIGHTING.RANGE
local MAELSTORM_BOUNCES = TUNING.DOTA.MJOLLNIR.LIGHTING.BOUNCES
local MAELSTORM_SPEED = 50

dota_projectile.maelstorm = {
    name = "dota_projectile_maelstorm",
    animzip = "brilliance_projectile_fx",
    prefabs = {
    },
    bank = "brilliance_projectile_fx",
    build = "brilliance_projectile_fx",
    anim = "idle_loop",
    extrafn = function(inst)
        inst.AnimState:SetSymbolMultColour("light_bar", 1, 1, 1, .5)
        inst.AnimState:SetSymbolBloom("light_bar")
        inst.AnimState:SetSymbolBloom("glow")
        inst.AnimState:SetLightOverride(.5)
    end,

    projectile = true,
    speed = MAELSTORM_SPEED,
    -- range = 25,
    onthrownfn = function(inst, owner, target, attacker)
        inst.owner = owner
		inst.attacker = attacker
        if inst.bounces == nil then
            inst.bounces = 1
            inst.initial_hostile = target ~= nil and target:IsValid() and target:HasTag("hostile")
        end
        PlaySound(inst, "mengsk_dota2_sounds/items/item_mael_lightning_01", nil, BASE_VOICE_VOLUME)
    end,
    onhitfn = function(inst, weapon, target)
        local x, y, z
		local attacker = inst.attacker
        if target:IsValid() then
            local radius = target:GetPhysicsRadius(0) + .2
            local angle = (inst.Transform:GetRotation() + 180) * DEGREES
            x, y, z = target.Transform:GetWorldPosition()
            x = x + math.cos(angle) * radius + GetRandomMinMax(-.2, .2)
            -- y = GetRandomMinMax(.1, .3)
            z = z - math.sin(angle) * radius + GetRandomMinMax(-.2, .2)
        else
            x, y, z = inst.Transform:GetWorldPosition()
        end
		
        if target and target.components.combat ~= nil and attacker and attacker.components.combat and attacker:IsValid() then
            target.components.combat:GetAttacked(attacker, MAELSTORM_DAMAGE, nil, "electric")
        end

        if inst.bounces ~= nil and inst.bounces < MAELSTORM_BOUNCES and attacker and attacker.components.combat and attacker:IsValid() then
            inst.bounces = inst.bounces + 1
            inst.Physics:Stop()
            inst:Hide()
            inst:DoTaskInTime(MAELSTORM_INTERVAL, TryBounce, x, z, attacker, target, MAELSTORM_RANGE)
        else
            inst:Remove()
        end
    end,
    onmissfn = function(inst, attacker, target)
        if not inst.AnimState:IsCurrentAnimation("disappear") then
            inst.AnimState:PlayAnimation("disappear")
            if not inst.removing then
                inst.removing = true
                inst:ListenForEvent("animover", inst.Remove)
            end
        end
    end,
}

local STATIC_DAMAGE = TUNING.DOTA.MJOLLNIR.STATIC.DAMAGE

dota_projectile.static = {
    name = "dota_projectile_static",
    animzip = "brilliance_projectile_fx",
    prefabs = {
    },
    bank = "brilliance_projectile_fx",
    build = "brilliance_projectile_fx",
    anim = "idle_loop",
    extrafn = function(inst)
        inst.AnimState:SetSymbolMultColour("light_bar", 1, 1, 1, .5)
        inst.AnimState:SetSymbolBloom("light_bar")
        inst.AnimState:SetSymbolBloom("glow")
        inst.AnimState:SetLightOverride(.5)
    end,

    projectile = true,
    speed = MAELSTORM_SPEED,
    -- range = 25,
    onthrownfn = function(inst, owner, target, attacker)
        inst.owner = owner
		inst.attacker = attacker
    end,
    onhitfn = function(inst, weapon, target)
        local x, y, z
		local attacker = inst.attacker
        if target:IsValid() then
            local radius = target:GetPhysicsRadius(0) + .2
            local angle = (inst.Transform:GetRotation() + 180) * DEGREES
            x, y, z = target.Transform:GetWorldPosition()
            x = x + math.cos(angle) * radius + GetRandomMinMax(-.2, .2)
            -- y = GetRandomMinMax(.1, .3)
            z = z - math.sin(angle) * radius + GetRandomMinMax(-.2, .2)
        else
            x, y, z = inst.Transform:GetWorldPosition()
        end

        if target and target.components.combat ~= nil and attacker and attacker.components.combat and attacker:IsValid() then
            target.components.combat:GetAttacked(attacker, STATIC_DAMAGE, nil, "electric")
        end

        inst:Remove()
    end,
    onmissfn = function(inst, attacker, target)
        if not inst.AnimState:IsCurrentAnimation("disappear") then
            inst.AnimState:PlayAnimation("disappear")
            if not inst.removing then
                inst.removing = true
                inst:ListenForEvent("animover", inst.Remove)
            end
        end
    end,
}

-------------------------------------------------虚灵之刃-------------------------------------------------
dota_projectile.ethereal = {
    name = "dota_projectile_ethereal",
    animzip = "brilliance_projectile_fx",
    prefabs = {
        "brilliance_projectile_blast_fx",
    },
    bank = "brilliance_projectile_fx",
    build = "brilliance_projectile_fx",
    anim = "idle_loop",
    extrafn = function(inst)
        inst.AnimState:SetSymbolMultColour("light_bar", 1, 1, 1, .5)
        inst.AnimState:SetSymbolBloom("light_bar")
        inst.AnimState:SetSymbolBloom("glow")
        inst.AnimState:SetLightOverride(.5)
    end,

    projectile = true,
    speed = 15,
    onthrownfn = function(inst, owner, target, attacker)
        inst.owner = owner
		inst.attacker = attacker
        PlaySound(inst, "mengsk_dota2_sounds/weapon/crit1", nil, BASE_VOICE_VOLUME)
    end,
    onhitfn = function(inst, weapon, target)
        -- local blast = SpawnPrefab("brilliance_projectile_blast_fx")
        -- local x, y, z

        -- if target:IsValid() then
        --     local radius = target:GetPhysicsRadius(0) + .2
        --     local angle = (inst.Transform:GetRotation() + 180) * DEGREES
        --     x, y, z = target.Transform:GetWorldPosition()
        --     x = x + math.cos(angle) * radius + GetRandomMinMax(-.2, .2)
        --     y = GetRandomMinMax(.1, .3)
        --     z = z - math.sin(angle) * radius + GetRandomMinMax(-.2, .2)
        --     blast:PushFlash(target)
        -- else
        --     x, y, z = inst.Transform:GetWorldPosition()
        -- end
        -- blast.Transform:SetPosition(x, y, z)

        local attacker = inst.attacker
        
        if not target:IsValid() then return end

        if target.components.debuffable ~= nil then
            target.components.debuffable:AddDebuff("buff_dota_ethereal", "buff_dota_ethereal")
        end

        local PRIMARY = attacker and attacker.components.dotacharacter and attacker.components.dotacharacter:GetPrimaryAttribute() or 0
        local ETHEREAL_DAMEGE = TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.DAMAGE + PRIMARY * TUNING.DOTA.ETHEREAL_BLADE.ETHEREAL.PRIMARYMULTI
        if not target:HasTag("player") and target.components.combat ~= nil then
            target.components.combat:GetAttacked(attacker, ETHEREAL_DAMEGE, nil, "dotamagic")
            PlaySound(target, "mengsk_dota2_sounds/items/item_ghost_etherealblade", nil, BASE_VOICE_VOLUME)
        elseif target:HasTag("player") then
            PlaySound(target, "mengsk_dota2_sounds/items/ethereal_blade_cast", nil, BASE_VOICE_VOLUME)
        end

        inst:Remove()
    end,
    onmissfn = function(inst, attacker, target)
        inst:Remove()
    end,
}
-------------------------------------------------否决坠饰-------------------------------------------------
dota_projectile.nullifier = {
    name = "dota_projectile_nullifier",
    animzip = "boomerang",
    bank = "boomerang",
    build = "boomerang",
    anim = "spin_loop",

    projectile = true,
    speed = 10,
    onthrownfn = function(inst, owner, target, attacker)
        inst.owner = owner
		inst.attacker = attacker
        PlaySound(inst, "mengsk_dota2_sounds/items/nullifier_cast", nil, BASE_VOICE_VOLUME)
    end,
    onhitfn = function(inst, weapon, target)
        if not target:IsValid() then return end

        if target.components.combat then
            local impactfx = SpawnPrefab("impact")
            if impactfx ~= nil then
                local follower = impactfx.entity:AddFollower()
                follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
                impactfx:FacePoint(inst.Transform:GetWorldPosition())
            end
        end

        if target.components.debuffable then
            target.components.debuffable:AddDebuff("buff_dota_nullifier", "buff_dota_nullifier")
        end
        
        inst:Remove()
    end,
    onmissfn = function(inst, attacker, target)
        inst:Remove()
    end,
}



return dota_projectile