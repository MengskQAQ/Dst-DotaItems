---------------------------------------------------魔瓶 or 瓶子---------------------------------------------------

AddPrefabPostInit("monkeyqueen", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst.components.trader ~= nil then
            local old_onaccept = inst.components.trader.onaccept
            local new_onaccept = function(inst, giver, item)
                if item.prefab == "dota_bottle" then
                    inst.sg:GoToState("dota_getbollte",{giver=giver, item=item})
                    item:Remove()
                else
                    old_onaccept(inst, giver, item)
                end
            end
            inst.components.trader.onaccept = new_onaccept
			
			-- local old_test = inst.components.trader.test
            -- local new_test = function(inst, item, giver)
                -- if item.prefab == "dota_bottle" then
                    -- return true
                -- else
                    -- return old_test(inst, item, giver)
                -- end
				-- -- return item.prefab == "dota_bottle" or old_test(inst, item, giver)
            -- end
            -- inst.components.trader.test = new_test
			
        end
		return inst
	end
end)

local function Dota_BottleSG()
    local state =
    GLOBAL.State{
        name = "dota_getbollte",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("receive_item")
            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/receive_item")
            inst.sg.statemem.giver = data.giver
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                local loot = SpawnPrefab("dota_bottle")
                if inst.sg.statemem.giver.components.inventory then
                    inst.sg.statemem.giver.components.inventory:GiveItem(loot)
                else
                    inst.components.lootdropper:FlingItem(loot)
                end
                inst.sg:GoToState("happy",{say="MONKEY_QUEEN_HAPPY"})
            end)
        },
    }
    return state
end

AddStategraphState("monkeyqueen", Dota_BottleSG())