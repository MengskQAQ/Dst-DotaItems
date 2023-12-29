require("stategraph")

local function onwakeup(inst)
    inst.sg:GoToState("idle")
end

AddGlobalClassPostConstruct("stategraph", "StateGraph", function(self)
    -- 借用科雷的冰冻通道
    if self.states.frozen then

        -- 眩晕状态
        local state = GLOBAL.State{
            name = "dota_sg_stun",
            -- tags = { "busy", "frozen" },
            tags = { "busy" },
        
            onenter = function(inst)
                if inst.components.locomotor ~= nil then
                    inst.components.locomotor:StopMoving()
                end
                inst.AnimState:PlayAnimation("frozen", true)
                inst.SoundEmitter:PlaySound("mengsk_dota2_sounds/items/skull_basher")
                inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            end,
        
            events =
            {
                EventHandler("dotaevent_stunwake", onwakeup),
            },
        
            onexit = function(inst)
                self.states.frozen.onexit(inst)
                -- inst.AnimState:ClearOverrideSymbol("swap_frozen")
            end,
        }

        assert(state:is_a(State), "[Dota-Items] Error SG Stun")
        self.states[state.name] = state

        -- 触发眩晕状态
        local eventhandler = GLOBAL.EventHandler("dotaevent_gotostunned", function(inst)
            if inst.components.health ~= nil and not inst.components.health:IsDead() then
                inst.sg:GoToState("dota_sg_stun")
            end
        end)

        assert(eventhandler:is_a(EventHandler), "[Dota-Items] Error EventHandler Stun")
        self.events[eventhandler.name] = eventhandler
    end
end)