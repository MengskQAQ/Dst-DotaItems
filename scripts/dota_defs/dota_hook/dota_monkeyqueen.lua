---------------------------------------------------魔瓶 or 瓶子---------------------------------------------------
-- 瓶子可以通过猴王来重新装满，以此代替泉水
-- 同时装瓶具有一定限制，需要给予一定数量的物品，让猴王的满足值达到一定程度才允许装瓶

local bananalimit = TUNING.DOTA.BOTTLE.BANANALIMIT  -- 满足值限制

AddPrefabPostInit("monkeyqueen", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst.components.trader ~= nil then

            -- 没有存储满足值，意味着每次上线都会重置，所以每次上线都需要重新给予香蕉
            inst.dota_canfillbottle = 0
			
            -- 给予瓶子时需要做一次判定
			local old_test = inst.components.trader.test
            local new_test = function(inst, item, giver)
                if item.prefab == "dota_bottle" -- 限定目标为魔瓶
                 and inst.dota_canfillbottle and inst.dota_canfillbottle >= bananalimit -- 给予的东西数量达到了要求
                 and item.components.dotabottle -- 冗余判定
                 and not item.components.dotabottle:IsStoreRune() -- 有神符时不可以装瓶
                 and not item.components.dotabottle:IsFull()    -- 瓶满时不可以装瓶
                 then
                    return true
                else
                    return old_test(inst, item, giver)
                end
				-- return item.prefab == "dota_bottle" or old_test(inst, item, giver)
            end
            inst.components.trader.test = new_test

            local old_onaccept = inst.components.trader.onaccept
            local new_onaccept = function(inst, giver, item)
                if item.prefab == "dota_bottle" then    -- 拿到瓶子时导向我们下方预设的SG
                    inst.sg:GoToState("dota_getbollte",{giver=giver, item=item})
                    item:Remove()
                else    -- 拿到其他东西时满足值+1
                    inst.dota_canfillbottle = inst.dota_canfillbottle and (inst.dota_canfillbottle + 1) or 1
                    old_onaccept(inst, giver, item)
                end
            end
            inst.components.trader.onaccept = new_onaccept

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
            -- 没办法向官方的猴王动画中插入瓶子动画，因此就不显示瓶子了
            inst.AnimState:PlayAnimation("receive_item")
            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/receive_item")
            inst.sg.statemem.giver = data.giver
            -- 更改猴王的满足值
            inst.dota_canfillbottle = inst.dota_canfillbottle and (inst.dota_canfillbottle - bananalimit) or 0
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                -- 生成新魔瓶，所以上面限制了魔瓶状态，如果不做限制，此处需要使用其他写法
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