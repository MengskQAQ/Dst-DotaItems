------------------------------------------------ 神符 - 生成 ----------------------------------------------

AddPrefabPostInit("forest", function(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("dotarunespawner")
		return inst
	end
end)