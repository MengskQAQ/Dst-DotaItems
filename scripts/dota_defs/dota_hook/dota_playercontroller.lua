------------------------------------------ 范围施法 --------------------------------------------------
-- 这里仅对 aoetargrting 进行判断，对于 reticule ，如果将来有变化时再做考虑

-- TODO:核心在于与spellbook的兼容性问题，spellbook的优先级与activateaction优先级不会冲突
-- 这导致没办法在取消激活后重现spellbook，因此展示搁置此兼容

-- AddClientModRPCHandler("DOTARPC", "ItemActivate", function (status)
--     if not TheNet:GetIsClient() then return end
--     local dotacharacter = ThePlayer and ThePlayer.replica.dotacharacter
-- 	local self = ThePlayer and ThePlayer.components.playercontroller
--     if dotacharacter ~= nil then
--         if status then
--             dotacharacter:StartAOETargetingUsing()
--         elseif self then
-- 			self:ClearActionHold()
-- 			self:CancelPlacement()
-- 			self:CancelDeployPlacement()
-- 			self:CancelAOETargeting()

-- 			-- self:TryAOETargeting()
--         end
--     end
-- end)

-- local function OnActivate(inst, data)
--     local item = data and data.item
--     -- SendModRPCToClient(CLIENT_MOD_RPC["DOTARPC"]["ItemActivate"], inst.userid, true)
--     local self = ThePlayer and ThePlayer.components.playercontroller
--     if self and not self.ismastersim then
--         self:StartAOETargetingUsing(item)
--     end
-- end

-- local function OnInActivate(inst, data)
--     local item = data and data.item
--     local self = inst.components.playercontroller

--     if item and data.item.components.aoetargeting and item.components.aoetargeting:IsEnabled() then
-- 		self:ClearActionHold()
-- 		self:CancelPlacement()
-- 		self:CancelDeployPlacement()
-- 		self:CancelAOETargeting()
--     end

--     self:TryAOETargeting()
-- end

-- local function OnInit(inst, self)
--     inst:ListenForEvent("dotaevent_activate", OnActivate)
--     inst:ListenForEvent("dotaevent_inactivate", OnInActivate)
-- end

AddComponentPostInit("playercontroller", function(self, inst)

    self.dota_takeoveraoetargeting = false

-- if inst == GLOBAL.ThePlayer then

    -- inst:DoTaskInTime(0, OnInit, self)

    -- local old_Activate = self.Activate
    -- function self:Activate()
    --     old_Activate(self)
    --     if self.inst == ThePlayer and not self.ismastersim then
    --         self.inst:ListenForEvent("dotaevent_activate", OnActivate)
    --         self.inst:ListenForEvent("dotaevent_inactivate", OnInActivate)
    --     end
    -- end

    -- local old_Deactivate = self.Deactivate
    -- function self:Deactivate()
    --     old_Deactivate(self)
    --     if not self.ismastersim then
    --         self.inst:RemoveEventCallback("dotaevent_activate", OnActivate)
    --         self.inst:RemoveEventCallback("dotaevent_inactivate", OnInActivate)
    --     end
    -- end

-- end

    -- 在官方的设想里，右键是不能触发AOE的，因此我们需要在此处修改对我们武器的AOE的判定，使其能够右键执行
    local old_IsAOETargeting = self.IsAOETargeting
    function self:IsAOETargeting()
        return (self.dota_takeoveraoetargeting == false) and old_IsAOETargeting(self)
    end

    function self:Dota_TakeOverAOETargeting(istakeover)
        self.dota_takeoveraoetargeting = istakeover
    end

    function self:Dota_IsTakeOverAOETargeting()
        return self.dota_takeoveraoetargeting
    end

    -- local old_OnRightClick = self.OnRightClick
    -- function self:OnRightClick(down)
        -- 如果当前触发 aoetargrting 的是我们的 dota 系武器，那么接管 IsAOETargeting ,使得 OnRightClick 能执行 DoAction
        -- if self:Dota_IsTakeOverAOETargeting() then
        --     local item = self.inst.components.dotacharacter and self.inst.components.dotacharacter:GetActivateItem()
        --     if item and item.components.aoetargrting then
        --         self:Dota_TakeOverAOETargeting(true) -- 我们在此处接管 IsAOETargeting ，然后在 action 里面放弃接管
        --     else
        --         self:Dota_TakeOverAOETargeting(false)
        --     end
        -- end
        -- old_OnRightClick(self, down)
        -- self:Dota_TakeOverAOETargeting(false)
        -- if self:IsAOETargeting() then
        --     self:CancelAOETargeting()
        -- end
        -- if not self.ismastersim and self:Dota_IsTakeOverAOETargeting() and self.inst.replica.dotacharacter then
        --     self.inst.replica.dotacharacter:StartAOETargetingUsing()
        -- end
    -- end

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