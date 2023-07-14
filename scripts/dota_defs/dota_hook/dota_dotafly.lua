------------------------------------------eul的神圣法杖 or 吹风----------------------------------------------
---------------------------------------------风之杖 or 大吹风------------------------------------------------

local function runfnhook(self)
    local run = self.states.run
    if run then
        local old_enter = run.onenter
        function run.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("dota_flying") then
                if not inst.AnimState:IsCurrentAnimation("idle_loop") then  -- TODO:暂时用idle，未来要使用角色上下旋转的sg
                    inst.AnimState:PlayAnimation("idle_loop", true)
                end
                inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 0.01)
            end
        end
    end

    local run_start = self.states.run_start
    if run_start then
        local old_enter = run_start.onenter
        function run_start.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("dota_flying") then
                inst.AnimState:PlayAnimation("idle_loop")
            end
        end
    end

    local run_stop = self.states.run_stop
    if run_stop then
        local old_enter = run_stop.onenter
        function run_stop.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("dota_flying") then
                inst.AnimState:PlayAnimation("idle_loop")
            end
        end
    end
end

AddStategraphPostInit("wilson", runfnhook)
AddStategraphPostInit("wilson_client", runfnhook)