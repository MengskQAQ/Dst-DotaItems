local dota_item_other = {}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------其他--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------暗影护符-------------------------------------------------
dota_item_other.dota_shadow_amulet = {
    name = "dota_shadow_amulet",
    animname = "dota_shadow_amulet",
	animzip = "dota_other",
}
-------------------------------------------------风灵之纹-------------------------------------------------
dota_item_other.dota_wind_lace = {
    name = "dota_wind_lace",
    animname = "dota_wind_lace",
	animzip = "dota_other",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraSpeed("windlace", TUNING.DOTA.WIND_LACE.EXTRASPEED, "unique")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraSpeed("windlace", "unique")
	end,
}
-------------------------------------------------回复戒指-------------------------------------------------
dota_item_other.dota_ring_of_regen = {
    name = "dota_ring_of_regen",
    animname = "dota_ring_of_regen",
	animzip = "dota_other",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddHealthRegen(TUNING.DOTA.RING_OF_REGEN.HEALTHREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveHealthRegen(TUNING.DOTA.RING_OF_REGEN.HEALTHREGEN)
	end,
}
-------------------------------------------------抗魔斗篷-------------------------------------------------
dota_item_other.dota_cloak = {
    name = "dota_cloak",
    animname = "dota_cloak",
	animzip = "dota_other",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddSpellResistance(TUNING.DOTA.CLOAK.SPELLRESIS)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveSpellResistance(TUNING.DOTA.CLOAK.SPELLRESIS)
	end,
}
-------------------------------------------------毛毛帽-------------------------------------------------
dota_item_other.dota_fluffy_hat = {
    name = "dota_fluffy_hat",
    animname = "dota_fluffy_hat",
	animzip = "dota_other",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraHealth(TUNING.DOTA.FLUFFY_HAT.EXTRAHEALTH)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraHealth(TUNING.DOTA.FLUFFY_HAT.EXTRAHEALTH)
	end,
}
-------------------------------------------------魔棒-------------------------------------------------
local GETPOINT = TUNING.DOTA.MAGIC_STICK.GETPOINT or 1
local MAGIC_STICK_RANGE = TUNING.DOTA.MAGIC_STICK.RANGE
local function EmptyFunction(inst)
end

local function OnMagicUse(inst, owner, data)
    local victim = data and data.inst
    if (victim ~= nil and owner:IsNear(victim, MAGIC_STICK_RANGE))
     or ( data and data.pos and (distsq(owner:GetPosition(), data.pos) > (MAGIC_STICK_RANGE * MAGIC_STICK_RANGE)) )
    then
        local uses = inst.components.finiteuses and inst.components.finiteuses:GetUses() --当前耐久
        local total = inst.components.finiteuses and inst.components.finiteuses.total --耐久上限
        inst.components.finiteuses:SetUses(math.min(uses + GETPOINT, total))
    end
end

dota_item_other.dota_magic_stick = {
    name = "dota_magic_stick",
    animname = "dota_magic_stick",
	animzip = "dota_other",
    maxuses = TUNING.DOTA.MAGIC_STICK.MAXPOINTS, --次数耐久
    notstartfull = true,
    onfinishedfn = EmptyFunction,--耐久用完执行的函数
    activatename = "DOTA_MAGICCHARGE",
    sharedcoolingtype = "wand",
    onequipfn = function(inst,owner)
        if inst._onmagicusefn == nil then
            inst._onmagicusefn = function(src, data) OnMagicUse(inst, owner, data) end
            inst:ListenForEvent("dota_magicuse", inst._onmagicusefn, TheWorld)
        end
	end,
	onunequipfn = function(inst,owner)
        if inst._onmagicusefn ~= nil then
            inst:RemoveEventCallback("dota_magicuse", inst._onmagicusefn, TheWorld)
            inst._onmagicusefn = nil
        end
	end,
}
--------------------------------------------闪烁匕首 or 跳刀----------------------------------------------
--写法来自orangestaff，作用未知
local function NoHoles(pt)
    return not TheWorld.Map:IsGroundTargetBlocked(pt)
end
local BLINKFOCUS_MUST_TAGS = { "blinkfocus" }
local function blinkstaff_reticuletargetfn()
    local player = ThePlayer
    local rotation = player.Transform:GetRotation()
    local pos = player:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.CONTROLLER_BLINKFOCUS_DISTANCE, BLINKFOCUS_MUST_TAGS)
    for _, v in ipairs(ents) do
        local epos = v:GetPosition()
        if distsq(pos, epos) > TUNING.CONTROLLER_BLINKFOCUS_DISTANCESQ_MIN then
            local angletoepos = player:GetAngleToPoint(epos)
            local angleto = math.abs(anglediff(rotation, angletoepos))
            if angleto < TUNING.CONTROLLER_BLINKFOCUS_ANGLE then
                return epos
            end
        end
    end
    rotation = rotation * DEGREES
    for r = 13, 1, -1 do
        local numtries = 2 * PI * r
        local offset = FindWalkableOffset(pos, rotation, r, numtries, false, true, NoHoles)
        if offset ~= nil then
            pos.x = pos.x + offset.x
            pos.y = 0
            pos.z = pos.z + offset.z
            return pos
        end
    end
end

local function onblink(inst, pt, caster)    -- 自身在装备栏中
	-- inst.components.rechargeable:Discharge(TUNING.DOTA.BLINK_DAGGER.BLINK.CD)		--冷却时间
end
-- local function onboxblink(inst, pt, caster) -- 在box里面时
--     if caster.components.inventory then
--         local items = caster.components.inventory:FindItems(function(inst) return inst and inst:HasTag("dota_blink_dagger") end)    -- 找到所有跳刀
--         for _, v in ipairs(items) do
--             if v.components.rechargeable ~= nil then
-- 	            v.components.rechargeable:Discharge(TUNING.DOTA.BLINK_DAGGER.BLINK.CD)		-- 所有跳刀进入冷却
--             end
--         end
--     end
-- end

dota_item_other.dota_blink_dagger = {
    name = "dota_blink_dagger",
    animname = "dota_blink_dagger",
	animzip = "dota_other",
    activatename = "DOTA_BLINK",
    sharedcoolingtype = "blink",
    onequipfn = function(inst,owner)
		owner:ListenForEvent("healthdelta", inst.CanBlink)  -- TODO:attacked这个事件如何？
	end,
	onunequipfn = function(inst,owner)
		owner:RemoveEventCallback("healthdelta", inst.CanBlink)
	end,
    client_extrafn=function(inst)
        inst:AddComponent("reticule")   -- TODO: reticule没有做特殊处理，并不能生效
        inst.components.reticule.targetfn = blinkstaff_reticuletargetfn
        inst.components.reticule.ease = true
    end,
    extrafn=function(inst)
		inst:AddComponent("blinkdagger")	--传送组件
		inst.components.blinkdagger.onblinkfn = onblink
		inst.components.blinkdagger:SetMaxDistance(TUNING.DOTA.BLINK_DAGGER.BLINK.MAX_DISTANCE)
		inst.components.blinkdagger:SetPenDistance(TUNING.DOTA.BLINK_DAGGER.BLINK.PENALTY_DISTANCE)
		inst.components.blinkdagger:SetSoundFX("", "mengsk_dota2_sounds/items/blink_nailed")

        inst.CanBlink = function(_,data)
			if data and data.amount < 0 then    -- 排除婚戒影响 and data.cause ~= "buff_dota_sacrifice"
				if inst and inst.components.rechargeable ~= nil then
					inst.components.rechargeable:Dota_SetMinTime(TUNING.DOTA.BLINK_DAGGER.BLINK.PENALTY_CD)
					--inst.components.rechargeable:SetCharge(0)	-- 
				end
			end
        end

		inst.onequipwithrhfn=function(box,item,owner)
			if not box.components.blinkdagger then -- 给box添加一下，方便action那边调用
				box:AddComponent("blinkdagger")
			end
		end
		inst.onunequipwithrhfn=function(box,item,owner)
			if not box.blinkdaggercheck(box) then
				box:RemoveComponent("blinkdagger")
			end
		end
    end,

}
-------------------------------------------------速度之靴 or 鞋子-------------------------------------------------
dota_item_other.dota_boots_of_speed = {
    name = "dota_boots_of_speed",
    animname = "dota_boots_of_speed",
	animzip = "dota_other",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddExtraSpeed("boot", TUNING.DOTA.BOOTS_OF_SPEED.EXTRASPEED, "boot")
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveExtraSpeed("boot", "boot")
	end,
}
-------------------------------------------------巫毒面具-------------------------------------------------
dota_item_other.dota_voodoo_mask = {
    name = "dota_voodoo_mask",
    animname = "dota_voodoo_mask",
	animzip = "dota_other",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddSpellLifesteal(TUNING.DOTA.VOODOO_MASK.LIFESTEAL)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveSpellLifesteal(TUNING.DOTA.VOODOO_MASK.LIFESTEAL)
	end,
}
-------------------------------------------------吸血面具-------------------------------------------------
dota_item_other.dota_morbid_mask = {
    name = "dota_morbid_mask",
    animname = "dota_morbid_mask",
	animzip = "dota_other",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddLifesteal(TUNING.DOTA.MORBID_MASK.LIFESTEAL)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveLifesteal(TUNING.DOTA.MORBID_MASK.LIFESTEAL)
	end,
}
-------------------------------------------------贤者面罩-------------------------------------------------
dota_item_other.dota_sages_mask = {
    name = "dota_sages_mask",
    animname = "dota_sages_mask",
	animzip = "dota_other",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddManaRegen(TUNING.DOTA.SAGES_MASK.MANAREGEN)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveManaRegen(TUNING.DOTA.SAGES_MASK.MANAREGEN)
	end,
}
-------------------------------------------------幽魂权杖 or 绿杖-------------------------------------------------
dota_item_other.dota_ghost_scepter = {
    name = "dota_ghost_scepter",
    animname = "dota_ghost_scepter",
	animzip = "dota_other",
    sharedcoolingtype = "ethereal",
	onequipfn = function(inst,owner)
        owner.components.dotacharacter:AddAttributes(TUNING.DOTA.GHOST_SCEPTER.ATTRIBUTES)
	end,
	onunequipfn = function(inst,owner)
        owner.components.dotacharacter:RemoveAttributes(TUNING.DOTA.GHOST_SCEPTER.ATTRIBUTES)
	end,
}
-------------------------------------------------真视宝石-------------------------------------------------
local COLOUR_R = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.COLOUR_R
local COLOUR_G = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.COLOUR_G
local COLOUR_B = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.COLOUR_B
local RADIUS = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.RADIUS
local FALLOFF = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.FALLOFF
local INTENSITY = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.INTENSITY

local function topocket(inst)
    if inst.icon ~= nil then
        inst.icon:Remove()
        inst.icon = nil
    end
    inst.Light:Enable(false)
	inst.Light:SetRadius(0)
    -- print("[debug_gem]  toground")
end

local function toground(inst)
    if inst.icon == nil then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon:TrackEntity(inst)
    end
    inst.Light:Enable(true)
	inst.Light:SetRadius(RADIUS)
    -- print("[debug_gem]  toground RADIUS:" .. RADIUS)
end

local function init(inst)
    if not inst.components.inventoryitem:IsHeld() then
        toground(inst)
    end
end

dota_item_other.dota_gem_of_true_sight = {    -- TODO:给宝石添加一个唯一标签 暂时没有隐身怪，先不用做这个
    name = "dota_gem_of_true_sight",
    animname = "dota_gem_of_true_sight",
	animzip = "dota_other",
    taglist = {
        "donotautopick",
    },
	-- assets = {
    --     Asset("MINIMAP_IMAGE", "dota_gem_of_true_sight"),
    -- },
    prefabs ={
        "globalmapicon",
    },
	onequipfn = function(inst,owner)

	end,
	onunequipfn = function(inst,owner)

	end,
    client_extrafn = function(inst)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon("purplemooneye.png")
        -- inst.MiniMapEntity:SetIcon("dota_gem_of_true_sight_icon.png")
        inst.MiniMapEntity:SetPriority(11)
        inst.MiniMapEntity:SetCanUseCache(false)
        inst.MiniMapEntity:SetDrawOverFogOfWar(true)

        MakeInventoryPhysics(inst)
    
        inst.entity:AddLight()
        inst.Light:SetFalloff(FALLOFF) -- 衰减
        inst.Light:SetIntensity(INTENSITY) -- 光强
        inst.Light:SetRadius(0) -- 半径
        inst.Light:SetColour(COLOUR_R, COLOUR_G, COLOUR_B)   -- 颜色
        inst.Light:Enable(false)
    end,
    extrafn = function(inst)
        inst.icon = nil
        inst:ListenForEvent("onputininventory", topocket)
        inst:ListenForEvent("ondropped", toground)
        inst:DoTaskInTime(0, init)

        inst.OnRemoveEntity = OnRemoveEntity
        -- inst.init = init
        -- inst.topocket = topocket
        -- inst.toground = toground
    end,
}

return {dota_item_other = dota_item_other}