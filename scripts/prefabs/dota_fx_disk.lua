local assets =
{
    Asset("ANIM", "anim/forcefield.zip")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("forcefield")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.kill_fx = function()
        inst.AnimState:PlayAnimation("close")
        inst:DoTaskInTime(.1, inst.Remove)  
    end

    return inst
end

return Prefab("dota_fx_disk", fn, assets)