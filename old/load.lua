local function ServerResetAttackPerior(state)
    if not state.timeline then return end

    local old_onenter = state.onenter
    state.onenter = function(inst, ...)
        
        if old_onenter then
            old_onenter(inst, ...)
        end

        local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
        inst.sg:SetTimeout(cooldown)
        inst:PerformBufferedAction()

    end
end

AddStategraphPostInit("wilson", function(sg)
    local attack = sg.states.attack
    if attack then
        ServerResetAttackPerior(attack)
    end
end)