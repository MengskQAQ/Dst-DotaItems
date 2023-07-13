local function MakeFx(t)
    local function kill_fx(inst)
        if t.killanim then
            inst.AnimState:PlayAnimation(t.killanim)
        end
        inst:DoTaskInTime(.1, inst.Remove)
    end

    local assets =
    {
        Asset("ANIM", "anim/"..t.animzip..".zip")
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
        -- inst.entity:AddFollower()

        inst.AnimState:SetBank(t.bank)
        inst.AnimState:SetBuild(t.build)
        inst.AnimState:PlayAnimation(t.anim)
        if t.loopanim then
            inst.AnimState:PushAnimation(t.loopanim, true)
        end
        if t.scale ~= nil then
            inst.AnimState:SetScale(t.scale:Get())
        end

        -- if t.twofaced then
        --     inst.Transform:SetTwoFaced()
        -- elseif t.eightfaced then
        --     inst.Transform:SetEightFaced()
        -- elseif t.sixfaced then
        --     inst.Transform:SetSixFaced()
        -- elseif not t.nofaced then
        --     inst.Transform:SetFourFaced()
        -- end

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.kill_fx = kill_fx

        inst.persists = false

        inst:AddComponent("dotashield")
        inst.components.dotashield:SetMaxHealth(t.maxhealth)
        inst.components.dotashield:SetOnCreateFn(t.oncreatefn)
        if t.ontakedamagefn then
            inst.components.dotashield:SetOnTakedamageFn(t.ontakedamagefn)
        end

        inst:ListenForEvent("Remove", function()
            local owner = inst.components.dotashield.owner
            if owner and owner.components.dotaattributes ~= nil then
                owner.components.dotaattributes:RemoveMagicShield(t.name)
            end
            inst.kill_fx(inst)
        end)
    
        inst:DoTaskInTime(t.duration, function()
            inst:PushEvent("Remove")
        end)

        return inst
    end

    return Prefab(t.name, fn, assets)
end

local prefs = {}
local fx = require("dota_defs/dota_shield_fx")

for k, v in pairs(fx) do
    table.insert(prefs, MakeFx(v))
end

return unpack(prefs)