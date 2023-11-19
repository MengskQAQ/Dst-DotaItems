---------------------------------------- 自定义音频 ---------------------------------------------

AddComponentPostInit("dynamicmusic", function(self)
    if not TheWorld.ismastersim then
        self.inst:AddComponent("dotadynamicmusic")
    end
end)