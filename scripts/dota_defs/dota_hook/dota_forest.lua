------------------------------------------------ 神符 - 生成 - 地表 ----------------------------------------------

AddPrefabPostInit("forest", function(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("dotarunespawner")
		return inst
	end
end)