------------------------------------------ 范围施法 --------------------------------------------------
-- 这里仅对 aoetargrting 进行判断，对于 reticule ，如果将来有变化时再做考虑
local function OnActivate(inst, data)
    local item = data and data.item
    if item and item.components.aoetargeting and item.components.aoetargeting:IsEnabled() then
        local self = inst.components.playercontroller
        self:StartAOETargetingUsing(item)
    end
end

local function OnInActivate(inst, data)
    local item = data and data.item
    local self = inst.components.playercontroller

    if item and data.item.components.aoetargeting and item.components.aoetargeting:IsEnabled() then
		-- self:ClearActionHold()
		self:CancelPlacement()
		self:CancelDeployPlacement()
		self:CancelAOETargeting()
    end

    self:TryAOETargeting()
end

local function OnInit(inst, self)
    inst:ListenForEvent("dotaevent_activate", OnActivate)
    inst:ListenForEvent("dotaevent_inactivate", OnInActivate)
end

AddComponentPostInit("playercontroller", function(self, inst)

    inst:DoTaskInTime(0, OnInit, self)

    local old_Activate = self.Activate
    function self:Activate()
        old_Activate(self)
        if self.inst == ThePlayer and self.handler ~= nil then
            self.inst:ListenForEvent("dotaevent_activate", OnActivate)
            self.inst:ListenForEvent("dotaevent_inactivate", OnInActivate)
        end
    end

    local old_Deactivate = self.Deactivate
    function self:Deactivate()
        old_Deactivate(self)
        if self.handler ~= nil then
            self.inst:RemoveEventCallback("dotaevent_activate", OnActivate)
            self.inst:RemoveEventCallback("dotaevent_inactivate", OnInActivate)
        end
    end

    --------------------------------回城卷轴 or 远行鞋I or 飞鞋 or 远行鞋II or 大飞鞋---------------------------------------
    local old_OnMapAction = self.OnMapAction
    function self:OnMapAction(actioncode, position)
        local act = GLOBAL.MOD_ACTIONS_BY_ACTION_CODE[modname][actioncode]
        if act and act.id == "DOTA_TPSCROLL_MAP" then
            if self.inst ~= nil and self.inst.HUD ~= nil and self.inst.HUD:IsMapScreenOpen() then
                if not self.inst.components.playercontroller.isclientcontrollerattached  then
                    GLOBAL.TheFrontEnd:PopScreen()
                end
            end
            if self.ismastersim then
                local LMBaction, RMBaction = self:GetMapActions(position)
                if act.rmb then
                    if RMBaction then
                        self.locomotor:PushAction(RMBaction, true)
                    end
                else
                    if LMBaction then
                        self.locomotor:PushAction(LMBaction, true)
                    end
                end
            elseif self.locomotor == nil then
                GLOBAL.SendRPCToServer(GLOBAL.RPC.DoActionOnMap, actioncode, position.x, position.z)
            elseif self:CanLocomote() then
                local _, RMBaction = self:GetMapActions(position)
                RMBaction.preview_cb = function()
                    GLOBAL.SendRPCToServer(GLOBAL.RPC.DoActionOnMap, actioncode, position.x, position.z)
                end
                self.locomotor:PreviewAction(RMBaction, true)
            end
        else
            return old_OnMapAction(self,actioncode, position)
        end
    end

    -- local old_HasAOETargeting = self.HasAOETargeting
    -- function self:HasAOETargeting()
    --     local item = self.inst.replica.dotacharacter and self.inst.replica.dotacharacter:GetActivateItem()
    --     return old_HasAOETargeting(self) or
    --         (item ~= nil and item.components.aoetargeting ~= nil and item.components.aoetargeting:IsEnabled())
    -- end

    -- local old_TryAOETargeting = self.TryAOETargeting
    -- function self:TryAOETargeting()
    --     old_TryAOETargeting(self)
    --     local item = self.inst.replica.dotacharacter and self.inst.replica.dotacharacter:GetActivateItem()
    --     if item ~= nil and item.components.aoetargeting ~= nil and item.components.aoetargeting:IsEnabled() then
    --         item.components.aoetargeting:StartTargeting()
    --     end
    -- end

end)