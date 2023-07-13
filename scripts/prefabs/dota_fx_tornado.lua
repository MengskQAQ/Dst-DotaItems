------------------------------------------eul的神圣法杖 or 吹风----------------------------------------------
---------------------------------------------风之杖 or 大吹风------------------------------------------------

local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME
local DURATION = TUNING.DOTA.EULS.CYCLONE.DURATION
local assets =
{
    Asset("ANIM", "anim/tornado.zip"),
}

local function ontornadolifetime(inst)
    inst.task = nil
    inst.sg:GoToState("despawn")
end

local function SetDuration(inst, duration)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(duration, ontornadolifetime)
end

local function KillFx(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.sg:GoToState("despawn")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetBank("tornado")
    inst.AnimState:SetBuild("tornado")
    inst.AnimState:PlayAnimation("tornado_pre")
    inst.AnimState:PushAnimation("tornado_loop")

    inst.SoundEmitter:PlaySound("mengsk_dota2_sounds/items/dota_item_cyclone", "spinLoop", BASE_VOICE_VOLUME)

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 0
    inst.components.locomotor.runspeed = 0

    inst:SetStateGraph("SGtornado")

    inst.WINDSTAFF_CASTER = nil
    inst.persists = false

    inst.KillFx = KillFx
    inst.SetDuration = SetDuration

    return inst
end

return Prefab("dota_fx_tornado", fn, assets)