local projectile_assets =
{
    Asset("ANIM", "anim/spat_bomb.zip"),
}

local projectile_prefabs =
{
    "spat_splat_fx",
    "spat_splash_fx_full",
    "spat_splash_fx_med",
    "spat_splash_fx_low",
    "spat_splash_fx_melted",
}

local sounds =
{
    spit_hit = "dontstarve/creatures/spat/spit_hit",
}

local function doprojectilehit(inst, attacker, other)
    inst.SoundEmitter:PlaySound(sounds.spit_hit)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("spat_splat_fx").Transform:SetPosition(x, 0, z)

    if attacker ~= nil and not attacker:IsValid() then
        attacker = nil
    end

    -- stick whatever got actually hit by the projectile
    -- otherwise stick our target, if he was in splash radius
    if other == nil and attacker ~= nil then
        other = attacker.components.combat.target
        if other ~= nil and not (other:IsValid() and other:IsNear(inst, TUNING.SPAT_PHLEGM_RADIUS)) then
            other = nil
        end
    end

    if other ~= nil and other:IsValid() then
        if attacker ~= nil then
            attacker.components.combat:DoAttack(other, inst.components.complexprojectile.owningweapon, inst)
        end
        if other.components.pinnable ~= nil then
            other.components.pinnable:Stick()
        end
    end

    return other
end

local function OnProjectileHit(inst, attacker, other)
    doprojectilehit(inst, attacker, other)
    inst:Remove()
end

local function oncollide(inst, other)
    -- If there is a physics collision, try to do some damage to that thing.
    -- This is so you can't hide forever behind walls etc.

    local attacker = inst.components.complexprojectile.attacker
    if other ~= doprojectilehit(inst, attacker) and
        other ~= nil and
        other:IsValid() and
        other.components.combat ~= nil then
        if attacker ~= nil and attacker:IsValid() then
            attacker.components.combat:DoAttack(other, inst.components.complexprojectile.owningweapon, inst)
        end
        if other.components.pinnable ~= nil then
            other.components.pinnable:Stick()
        end
    end

    inst:Remove()
end

local function projectilefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(10)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    -- inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    -- inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:SetCapsule(0.02, 0.02)

    inst.AnimState:SetBank("spat_bomb")
    inst.AnimState:SetBuild("spat_bomb")
    inst.AnimState:PlayAnimation("spin_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(oncollide)    -- 中途遇到障碍物？

    inst.persists = false

    inst:AddComponent("locomotor")
    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(OnProjectileHit)
    inst.components.complexprojectile:SetHorizontalSpeed(30)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(3, 2, 0))
    inst.components.complexprojectile.usehigharc = false

    return inst
end

return  Prefab("dota_cripple_projectile", projectilefn, projectile_assets, projectile_prefabs)