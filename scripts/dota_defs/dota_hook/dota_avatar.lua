-------------------------------------------------黑黄杖 or BKB-------------------------------------------------
-- bkb开启时，赋予玩家抗受击能力，不受攻击与击倒带来的SG插队影响
AddStategraphPostInit("wilson", function(sg)
    local old_attacked = sg.events["attacked"]
    sg.events["attacked"] = EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() and inst:HasTag("dota_avatar") then
            return
        end
        if old_attacked then
            return old_attacked.fn and old_attacked.fn(inst, data)
        end
    end)

    local old_knockback = sg.events["knockback"]
    sg.events["knockback"] = EventHandler("knockback", function(inst, data)
        if not inst.components.health:IsDead() and inst:HasTag("dota_avatar") then
            return
        end
        if old_knockback then
            return old_knockback.fn and old_knockback.fn(inst, data)
        end
    end)
end)

