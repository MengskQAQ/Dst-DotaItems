------------------------------------------黑黄杖-------------------------------------------
-- 加载资源表
local assets =
{
    Asset("ANIM", "anim/dota_black_king_bar.zip"),
	-- Asset("ANIM", "anim/swap_dota_battle_fury.zip"),
    Asset("ATLAS", "images/inventoryimages/dota_black_king_bar.xml"),
	Asset("IMAGE", "images/inventoryimages/dota_black_king_bar.tex"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()   --未来添加
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("dota_black_king_bar")
    inst.AnimState:SetBuild("dota_black_king_bar")
    inst.AnimState:PlayAnimation("idle") -- 设置默认播放动画为idle
	
    inst:AddTag("dota_equipment")
    inst:AddTag("dota_black_king_bar")
    -- inst:AddTag("book")

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")	--可检查
	
    inst:AddComponent("inventoryitem")		-- 可放入物品栏
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dota_black_king_bar.xml" -- 设置物品栏图片文档

    --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
    MakeHauntableLaunch(inst)	--可作祟

    return inst
end

return Prefab("dota_black_king_bar", fn, assets, prefabs)