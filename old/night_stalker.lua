----------------------------------------------暗夜魔王-------------------------------------------------
-- 在遥远的未来，可能添加的人物
local function OnIsRaining(inst, israining)
    if israining then --如果在下雨
        inst.components.combat.damagemultiplier =2
    else
        inst.components.combat.damagemultiplier =1
    end
end

--夜视
AddModRPCHandler(modname, "NightVision", function(player)
	if not player:HasTag("playerghost") and player.components.carneystatus then
		--player.components.carneystatus:CtrlNightVision()
		if player._nightvision:value() == true then
			player._nightvision:set(false)
		else
			player._nightvision:set(true)
		end
	end
end)
--复眼滤镜
local OMMATEUM_COLOURCUBES ={
	-- day = "images/colour_cubes/purple_moon_cc.tex",
	-- dusk = "images/colour_cubes/purple_moon_cc.tex",
	-- night = "images/colour_cubes/purple_moon_cc.tex",
	-- full_moon = "images/colour_cubes/purple_moon_cc.tex",
	day = "images/colour_cubes/spring_day_cc.tex",
	dusk = "images/colour_cubes/spring_dusk_cc.tex",
	night = "images/colour_cubes/purple_moon_cc.tex",
	full_moon = "images/colour_cubes/purple_moon_cc.tex",
}

--复眼函数
local function SetOmmateumVision(inst)
	local isequipped = inst.medalnightvision:value()
	local _forced_nightvision = inst._forced_nightvision and inst._forced_nightvision:value()--机器人的夜视组件
	if isequipped then
		if inst.components.playervision then
			inst.components.playervision:ForceNightVision(true)
			inst.components.playervision:ForceGoggleVision(true)
			inst.components.playervision:SetCustomCCTable(OMMATEUM_COLOURCUBES)
		end
	else
		if inst.components.playervision then
			-- inst.components.playervision:ForceNightVision(false)
			inst.components.playervision:ForceNightVision(_forced_nightvision)
			inst.components.playervision:ForceGoggleVision(false)
			inst.components.playervision:SetCustomCCTable(nil)
		end
	end
end



local function fn()
    local inst = CreateEntity()

	inst:WatchWorldState("israining", OnIsRaining)
	
    return inst
end

return Prefab("night_stalker", fn, assets, prefabs)

-- AddLoadingTip(LORES, "DOTATIP_3",
--     "沃尔特很快上手了晓美焰的魔法弓，并给出了五星好评：\"和我的弹弓很像，但不用随身携带弹药，真方便！\"")