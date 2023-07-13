GLOBAL.setmetatable(
    env,
    {
        __index = function(t, k)
            return GLOBAL.rawget(GLOBAL, k)
        end
    }
)
AddStategraphPostInit("wilson", function(self)
	local oldop = self.actionhandlers[ACTIONS.ATTACK].deststate 
	self.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		local weapon = inst.components.combat:GetWeapon()
		if inst then
			if action.doer and action.doer:HasTag("hungerfource") then
				return "attack_bear"
			else
				return oldop(inst, action)
			end
		end
	end
   self.states["attack_bear"] = State{
        name = "attack_bear",
        tags = { "attack", "notalking", "abouttoattack" },
        onenter = function(inst)
           local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)	
			if inst.components.combat:InCooldown() then 
				inst.sg:RemoveStateTag("abouttoattack")
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle", true)
				return
			end
			local buffaction = inst:GetBufferedAction()
	        local target = buffaction ~= nil and buffaction.target or nil
			local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
			
			inst.components.combat:SetTarget(target) 
	        inst.components.combat:StartAttack()
			inst.components.locomotor:Stop() 	
            inst.Physics:Stop() 
            if rider ~= nil and rider:IsRiding() then
                if equip ~= nil and (equip:HasTag("rangedweapon") or equip:HasTag("projectile")) then
                    inst.AnimState:PlayAnimation("player_atk_pre")
                    inst.AnimState:PushAnimation("player_atk", false)
                    if (equip.projectiledelay or 0) > 0 then
                        inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                        if inst.sg.statemem.projectiledelay > FRAMES then
                            inst.sg.statemem.projectilesound =
                                (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                                (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                                "dontstarve/wilson/attack_weapon"
                        elseif inst.sg.statemem.projectiledelay <= 0 then
                            inst.sg.statemem.projectiledelay = nil
                        end
                    end
                    if inst.sg.statemem.projectilesound == nil then
                        inst.SoundEmitter:PlaySound(
                            (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                            (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                            "dontstarve/wilson/attack_weapon",
                            nil, nil, true
                        )
                    end
					inst.AnimState:SetDeltaTimeMultiplier(2)
					cooldown = 7 * FRAMES
                else
                    inst.AnimState:PlayAnimation("atk_pre")
                    inst.AnimState:PushAnimation("atk", false)
                    DoMountSound(inst, rider:GetMount(), "angry")
					inst.AnimState:SetDeltaTimeMultiplier(2)
                    cooldown = 8 * FRAMES
                end
            elseif equip ~= nil and equip:HasTag("toolpunch") then
                inst.AnimState:PlayAnimation("toolpunch")
                inst.sg.statemem.istoolpunch = true
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
				inst.AnimState:SetDeltaTimeMultiplier(2)
				cooldown = 7 * FRAMES
            elseif equip ~= nil and equip:HasTag("whip") then
                inst.AnimState:PlayAnimation("whip_pre")
                inst.AnimState:PushAnimation("whip", false)
                inst.sg.statemem.iswhip = true
                inst.SoundEmitter:PlaySound("dontstarve/common/whip_pre", nil, nil, true)
				inst.AnimState:SetDeltaTimeMultiplier(2)
                cooldown = 9 * FRAMES
			elseif equip ~= nil and equip:HasTag("pocketwatch") then
				inst.AnimState:PlayAnimation(inst.sg.statemem.chained and "pocketwatch_atk_pre_2" or "pocketwatch_atk_pre" )
				inst.AnimState:PushAnimation("pocketwatch_atk", false)
				inst.sg.statemem.ispocketwatch = true
				inst.AnimState:SetDeltaTimeMultiplier(2)
				cooldown = 7* FRAMES
                if equip:HasTag("shadow_item") then
	                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow", nil, nil, true)
					inst.AnimState:Show("pocketwatch_weapon_fx")
					inst.sg.statemem.ispocketwatch_fueled = true
                else
	                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre", nil, nil, true)
					inst.AnimState:Hide("pocketwatch_weapon_fx")
                end
            elseif equip ~= nil and equip:HasTag("book") then
                inst.AnimState:PlayAnimation("attack_book")
                inst.sg.statemem.isbook = true
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                inst.AnimState:SetDeltaTimeMultiplier(2)
                cooldown = 8 * FRAMES
            elseif equip ~= nil and equip:HasTag("chop_attack") and inst:HasTag("woodcutter") then
                inst.AnimState:PlayAnimation(inst.AnimState:IsCurrentAnimation("woodie_chop_loop") and inst.AnimState:GetCurrentAnimationTime() < 7.1 * FRAMES and "woodie_chop_atk_pre" or "woodie_chop_pre")
                inst.AnimState:PushAnimation("woodie_chop_loop", false)
                inst.sg.statemem.ischop = true
				inst.AnimState:SetDeltaTimeMultiplier(2)
                cooldown = 6 * FRAMES
            elseif equip ~= nil and
                equip.replica.inventoryitem ~= nil and
                equip.replica.inventoryitem:IsWeapon() and
                not equip:HasTag("punch") then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                if (equip.projectiledelay or 0) > 0 then
                    --V2C: Projectiles don't show in the initial delayed frames so that
                    --     when they do appear, they're already in front of the player.
                    --     Start the attack early to keep animation in sync.
                    inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                    if inst.sg.statemem.projectiledelay > FRAMES then
                        inst.sg.statemem.projectilesound =
                            (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                            (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                            "dontstarve/wilson/attack_weapon"
                    elseif inst.sg.statemem.projectiledelay <= 0 then
                        inst.sg.statemem.projectiledelay = nil
                    end
                end
                if inst.sg.statemem.projectilesound == nil then
                    inst.SoundEmitter:PlaySound(
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("shadow") and "dontstarve/wilson/attack_nightsword") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        "dontstarve/wilson/attack_weapon",
                        nil, nil, true
                    )
                end
                inst.AnimState:SetDeltaTimeMultiplier(2)
                cooldown = 6 * FRAMES
            elseif equip ~= nil and
                (equip:HasTag("light") or
                equip:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
                inst.AnimState:SetDeltaTimeMultiplier(2)
                cooldown = 7* FRAMES
            elseif inst:HasTag("beaver") then
                inst.sg.statemem.isbeaver = true
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 13 * FRAMES)
                end
            elseif inst:HasTag("weremoose") then
                inst.sg.statemem.ismoose = true
                inst.AnimState:PlayAnimation(
                    ((inst.AnimState:IsCurrentAnimation("punch_a") or inst.AnimState:IsCurrentAnimation("punch_c")) and "punch_b") or
                    (inst.AnimState:IsCurrentAnimation("punch_b") and "punch_c") or
                    "punch_a"
                )
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 15 * FRAMES)
                end
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                if cooldown > 0 then
                    cooldown =  12* FRAMES
                end
            end

            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                end
            end
                inst.sg:SetTimeout(cooldown)
				if target ~= nil then
				inst.components.combat:BattleCry()
				if target:IsValid() then
					inst:FacePoint(target:GetPosition())
					inst.sg.statemem.attacktarget = target
				end
			end
            
        end,
			onupdate = function(inst, dt)
            if (inst.sg.statemem.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
                if inst.sg.statemem.projectiledelay <= FRAMES then
                    if inst.sg.statemem.projectilesound ~= nil then
                        inst.SoundEmitter:PlaySound(inst.sg.statemem.projectilesound, nil, nil, true)
                        inst.sg.statemem.projectilesound = nil
                    end
                    if inst.sg.statemem.projectiledelay <= 0 then
                        inst:PerformBufferedAction()
                        inst.sg:RemoveStateTag("abouttoattack")
                    end
                end
            end
        end,
		
        timeline = {
            TimeEvent(5 * FRAMES, function(inst)
				local target = inst.components.combat.target
                if target and target:IsValid() and inst.components.combat then
                    inst:ForceFacePoint(target:GetPosition())
					inst:PerformBufferedAction() 
                end
				if inst.sg.statemem.ismoose then
                    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/punch", nil, nil, true)
                end
            end), 
			TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.ismoose then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
			TimeEvent(13 * FRAMES, function(inst)
				local target = inst.components.combat.target
                if target and target:IsValid() then
					inst:PerformBufferedAction()
					inst:ForceFacePoint(target:GetPosition())
					inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/spell/elemental/attack") 
                end
            end), 
        },
		
		ontimeout = function(inst)
			inst.AnimState:SetDeltaTimeMultiplier(1)
			inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,
		
        events =
        {
			EventHandler("equip", function(inst) 
				inst.AnimState:SetDeltaTimeMultiplier(1)
				inst.sg:GoToState("idle") 
			end),
            EventHandler("unequip", function(inst) 
				inst.AnimState:SetDeltaTimeMultiplier(1)
				inst.sg:GoToState("idle") 				
			end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.AnimState:SetDeltaTimeMultiplier(1)
                    inst.sg:GoToState("idle")
                end
            end),
        },
		onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
				inst.AnimState:SetDeltaTimeMultiplier(1) 
                inst.components.combat:CancelAttack()
            end
        end,
    }

end)
TUNING.ARMORSLURPER_SLOW_HUNGER = 0.3;
AddPrefabPostInit("armorslurper", function(inst)
if not TheWorld.ismastersim then return inst end
	if inst.components.equippable ~= nil then
		local _onequipfn = inst.components.equippable.onequipfn
		inst.components.equippable.onequipfn = function(inst,owner, ...)
		_onequipfn(inst,owner, ...)
		
        local hunger = owner.components.hunger
		ACTASK=owner:DoPeriodicTask(0.1,function()
		local current = owner.components.hunger.current
		if current > 75 then
			if not owner:HasTag("hungerfource") then
			owner:AddTag("hungerfource")
				end
			else
			if owner:HasTag("hungerfource") then
			owner:RemoveTag("hungerfource")
				end
			end
				
		end)
		TASK = owner:DoPeriodicTask(0.2,function()
		local current1 = owner.components.hunger.current
        if hunger and  current1 > 50 then
            hunger:DoDelta(-1, false)
        end
		end)
	end
		local _onunequipfn = inst.components.equippable.onunequipfn
		inst.components.equippable.onunequipfn = function(inst,owner)
		_onunequipfn(inst,owner)
		ACTASK:Cancel()
		TASK:Cancel()
		if owner:HasTag("hungerfource") then
			owner:RemoveTag("hungerfource")
		end
		end
	end
end)
AddPrefabPostInit("armorslurper", function(inst)
if not TheWorld.ismastersim then return inst end
local CRAZINESS_ME = -100/300
if inst.components.equippable ~= nil then
		local _onequipfn = inst.components.equippable.onequipfn
		inst.components.equippable.onequipfn = function(inst,owner, ...)
		_onequipfn(inst,owner, ...)
		inst:AddTag("shadowguestitem")
		if owner:HasTag("shadowguest") then
		inst.components.equippable.dapperness = 100/300
		end
		local _onunequipfn = inst.components.equippable.onunequipfn
		inst.components.equippable.onunequipfn = function(inst,owner)
		_onunequipfn(inst,owner)
		inst:RemoveTag("shadowguestitem")
		inst.components.equippable.dapperness = CRAZINESS_ME
		end
		
	end
end
end)    ---¼¢¶öÑü´ø