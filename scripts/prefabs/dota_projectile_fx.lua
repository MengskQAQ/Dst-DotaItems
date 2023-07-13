local function MakeFx(def)
    local assets =
    {
        Asset("ANIM", "anim/"..def.animzip..".zip"),
    }
    
	local prefabs = {}
	if def.prefabs and #def.prefabs>0 then
		for _,v in ipairs(def.prefabs) do
			table.insert(prefabs, v)
		end
	else
		prefabs = nil
	end
    
    local function projectilefn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddPhysics()
        inst.entity:AddNetwork()
    
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
    
        inst:AddTag("FX")
	    inst:AddTag("NOCLICK")

        inst.AnimState:SetBank(def.bank)
        inst.AnimState:SetBuild(def.build)
        inst.AnimState:PlayAnimation(def.anim, true)

        if def.extrafn then
			def.extrafn(inst)
		end
    
        --projectile (from projectile component) added to pristine state for optimization
        inst:AddTag("projectile")
    
        inst.entity:SetPristine()
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst.persists = false
    
        if def.projectile then
            inst:AddComponent("projectile")
            inst.components.projectile:SetSpeed(def.speed)
            inst.components.projectile:SetStimuli(def.stimuli)
            inst.components.projectile:SetRange(def.range)
            inst.components.projectile:SetHitDist(def.hitdist or 1)
            inst.components.projectile:SetOnThrownFn(def.onthrownfn)
            inst.components.projectile:SetOnHitFn(def.onhitfn)
            inst.components.projectile:SetOnPreHitFn(def.onprehitfn)
            inst.components.projectile:SetOnCaughtFn(def.oncaughtfn)
            inst.components.projectile:SetOnMissFn(inst.onmissfn)
            inst.components.projectile:SetCanCatch(inst.cancatch or false)
            inst.components.projectile:SetHoming(inst.homing or true)
            inst.components.projectile:SetLaunchOffset(inst.launchoffset)
        end

        return inst
    end

    return Prefab(def.name, projectilefn, assets, prefabs)
end

local prefs = {}
local fx = require("dota_defs/dota_projectile_fx")

for k, v in pairs(fx) do
    table.insert(prefs, MakeFx(v))
end

return unpack(prefs)