local function Dota_nilSG()
    local state =
    GLOBAL.State{
        name = "dota_sg_nil",
        tags = { "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end
            inst:PerformBufferedAction()
            inst:ClearBufferedAction()
        end,
		
		-- events =
        -- {
        --     EventHandler("animover", function(inst)
        --         if inst.AnimState:AnimDone() then
        --             inst.sg:GoToState("idle")
        --         end
        --     end),
        -- },
    }
    return state
end

local function Dota_nilSGClient()
    local state =
    GLOBAL.State{
        name = "dota_sg_nil",
        tags = { "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end
            inst:PerformPreviewBufferedAction()
            inst:ClearBufferedAction()
        end,
		
		-- events =
        -- {
        --     EventHandler("animover", function(inst)
        --         if inst.AnimState:AnimDone() then
        --             inst.sg:GoToState("idle")
        --         end
        --     end),
        -- },
    }
    return state
end

AddStategraphState("wilson", Dota_nilSG())
AddStategraphState("wilson_client", Dota_nilSGClient())