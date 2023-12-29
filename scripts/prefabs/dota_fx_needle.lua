local assets =
{
    Asset("ANIM", "anim/dota_fx_needle.zip")
}

local function SetFXOwner(inst, owner)
    inst.entity:SetParent(owner.entity)
    inst.Transform:SetPosition(0, 0.2, 0)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("dota_fx_needle")
    inst.AnimState:SetBuild("dota_fx_needle")

    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.SetFXOwner = SetFXOwner

    inst.removetask = inst:DoTaskInTime(TUNING.DOTA.BLADE_MAIL.RETURN.DURATION + 1, inst:Remove())

    return inst
end

return Prefab("dota_fx_needle", fn, assets)