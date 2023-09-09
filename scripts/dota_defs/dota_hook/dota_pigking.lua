----------------------------------猪王------------------------------------
-- 让我们的制作站触发点设置为猪王

local function DisablePrototyper(inst)
	if inst.components.prototyper then
		if inst.components.prototyper.trees then
			inst.components.prototyper.trees.DOTASHOP_TECHTREE = 0
		end
	end
end

local function EnablePrototyper(inst)
	if not inst.components.prototyper then	
		inst:AddComponent("prototyper")
		inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.DOTASHOP_TECHTREE_ONE
	else	-- 如果有其他mod也在猪王身上添加了科技
		if inst.components.prototyper.trees then
			inst.components.prototyper.trees.DOTASHOP_TECHTREE = 1
		else
			inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.DOTASHOP_TECHTREE_ONE
		end
	end
end

local function OnWorldIsNight(inst, isnight)
    if isnight then
        DisablePrototyper(inst)
    else
		EnablePrototyper(inst)
    end
end

AddPrefabPostInit("pigking", function(inst)	-- 猪王睡觉的时候罢工了
	if GLOBAL.TheWorld.ismastersim then
		inst:DoTaskInTime(.1, function()
			inst:WatchWorldState("isnight", OnWorldIsNight)
			OnWorldIsNight(inst, TheWorld.state.isnight)
		end)
		return inst
	end
end)