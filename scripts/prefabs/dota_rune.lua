------------------------------------------------ 神符 - 实体 ----------------------------------------------

local RADIUS = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.RADIUS
local FALLOFF = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.FALLOFF
local INTENSITY = TUNING.DOTA.GEM_OF_TRUE_SIGHT.LIGHT.INTENSITY

local commonassets =
{
    Asset("ANIM", "anim/dota_rune.zip"),
}

local colors = {
    arcane = {
        r = 157,
        g = 30,
        b = 186,
    },
    bounty = {
        r = 255,
        g = 195,
        b = 18,
    },
    double = {
        r = 147,
        g = 180,
        b = 255,
    },
    haste = {
        r = 232,
        g = 40,
        b = 16,
    },
    illusion = {
        r = 254,
        g = 214,
        b = 148,
    },
    invisbility = {
        r = 154,
        g = 149,
        b = 156,
    },
    regeneration = {
        r = 145,
        g = 255,
        b = 78,
    },
    shield = {
        r = 75,
        g = 156,
        b = 130,
    },
    water = {
        r = 20,
        g = 200,
        b = 200,
    },
    wisdom = {
        r = 86,
        g = 15,
        b = 154,
    },
}

local function MakeRune(name, buffname, r, g, b, prefabs)

    local function fn()
        local inst = CreateEntity()
    
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()
    
        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild("dota_rune")
        inst.AnimState:PlayAnimation("idle", true)
    
        -- 神符的光亮范围与真实宝石保持一致
        inst.entity:AddLight()
        inst.Light:SetFalloff(FALLOFF)
        inst.Light:SetIntensity(INTENSITY)
        inst.Light:SetRadius(RADIUS)
        inst.Light:SetColour(r, g, b)
        inst.Light:Enable(true)

        inst:AddTag("nosteal")
		inst:AddTag("meteor_protection")
		inst:AddTag("dota_rune")
		inst:AddTag("dota_rune_"..name)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("dotaitem")   -- 这个组件仅用于触发动作，无实际用途

        inst.buffname = buffname    -- 我们将神符的具体效果写入buff中
    
        return inst
    end

    return Prefab("dota_rune_"..name, fn, commonassets, prefabs)
end

return MakeRune("arcane", "buff_dota_rune_arcane", colors.arcane.r, colors.arcane.g, colors.arcane.b),
    MakeRune("bounty", "buff_dota_rune_bounty", colors.bounty.r, colors.bounty.g, colors.bounty.b, {"goldnugget"}),
    MakeRune("double", "buff_dota_rune_double", colors.double.r, colors.double.g, colors.double.b),
    MakeRune("haste", "buff_dota_rune_haste", colors.haste.r, colors.haste.g, colors.haste.b),
    MakeRune("illusion", "buff_dota_rune_illusion", colors.illusion.r, colors.illusion.g, colors.illusion.b),
    MakeRune("invisbility", "buff_dota_rune_invisbility", colors.invisbility.r, colors.invisbility.g, colors.invisbility.b),
    MakeRune("regeneration", "buff_dota_rune_regeneration", colors.regeneration.r, colors.regeneration.g, colors.regeneration.b),
    MakeRune("shield", "buff_dota_rune_shield", colors.shield.r, colors.shield.g, colors.shield.b),
    MakeRune("water", "buff_dota_rune_water", colors.water.r, colors.water.g, colors.water.b),
    MakeRune("wisdom", "buff_dota_rune_wisdom",colors.wisdom.r, colors.wisdom.g, colors.wisdom.b)