local function OnTimerDone(inst, data)
    if data.name == "buffover" then
        inst.components.debuff:Stop()
    end
end

local function MakeBuff(defs)
    local function OnExtended(inst, target, followsymbol, followoffset, data)	-- 重复使用buff时
        inst.components.timer:StopTimer("buffover")
        inst.components.timer:StartTimer("buffover", defs.duration)

        if defs.onextendedfn ~= nil then
            defs.onextendedfn(inst, target,followsymbol, followoffset, data)
        end
    end

	local function OnAttached(inst, target, followsymbol, followoffset, data)    -- 触发buff
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0)
        inst:ListenForEvent("death", function()
            inst.components.debuff:Stop()
        end, target)
        if defs.onattachedfn ~= nil then
            defs.onattachedfn(inst, target, followsymbol, followoffset, data)
        end
    end

	local function OnDetached(inst, target)	-- 消除buff
        if defs.ondetachedfn ~= nil then
            defs.ondetachedfn(inst, target)
        end
        inst:Remove()
    end

    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end
        inst.entity:AddTransform()

        --[[Non-networked entity]]
        --inst.entity:SetCanSleep(false)
        inst.entity:Hide()
        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetDetachedFn(OnDetached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff.keepondespawn = true

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("buffover", defs.duration)
        inst:ListenForEvent("timerdone", OnTimerDone)

        return inst
    end

    return Prefab(defs.name, fn, nil, defs.prefabs)
end

local dota_buffs={}
for k, v in pairs(require("dota_defs/dota_buff")) do
    table.insert(dota_buffs, MakeBuff(v))
end
return unpack(dota_buffs)
