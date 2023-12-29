------------------------------------------------ 神符 - 生成 - 洞穴 ----------------------------------------------

AddPrefabPostInit("cave", function(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("dotarunespawner")
		return inst
	end
end)