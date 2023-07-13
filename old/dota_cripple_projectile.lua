local assets =
{
    Asset("ANIM", "anim/staff_projectile.zip"),
}

local ice_prefabs =
{
    "shatter",
    "spat_splat_fx",
    "spat_splash_fx_full",
    "spat_splash_fx_med",
    "spat_splash_fx_low",
    "spat_splash_fx_melted",
}

local function OnHit(inst, attacker, target)
    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end
    
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("spat_splat_fx").Transform:SetPosition(x, 0, z)

    -- local fx = SpawnPrefab("shatter")
    -- fx.Transform:SetPosition(target.Transform:GetWorldPosition())
    -- fx.components.shatterfx:SetLevel(2)

    if target.components.debuffable ~= nil then 	
        target.components.debuffable:AddDebuff("buff_dota_cripple", "buff_dota_cripple")
    end

    -- if attacker ~= nil and not attacker:IsValid() then
        -- attacker = nil
    -- end

    -- target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })

    inst:Remove()
end

local function projectilefn(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("projectile")
    inst.AnimState:SetBuild("staff_projectile")
    inst.AnimState:PlayAnimation("ice_spin_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(50)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)

    return inst
end

return Prefab("dota_cripple_projectile", projectilefn, assets, ice_prefabs)
