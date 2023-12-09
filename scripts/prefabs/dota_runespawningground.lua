------------------------------------------------ 神符 - 生成 ----------------------------------------------
local prefabs =
{
	"dota_rune_arcane",
	"dota_rune_bounty",
    "dota_rune_double",
    "dota_rune_haste",
    "dota_rune_illusion",
    "dota_rune_invisbility",
    "dota_rune_regeneration",
    "dota_rune_shield",
    "dota_rune_water",
    "dota_rune_wisdom",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("dota_runespawningground")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    TheWorld:PushEvent("ms_registerdota_runespawningground", inst)

    return inst
end
return Prefab("dota_runespawningground", fn, nil, prefabs)

