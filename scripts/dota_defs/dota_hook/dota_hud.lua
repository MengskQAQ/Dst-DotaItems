-- 因为 Hud 仅在客户端存在，在此处添加可以保证这些代码仅在客户端运行

AddClassPostConstruct("screens/playerhud", function(self)

    function self:Dota_GetActivateReticuleInv()
        local Inv = ThePlayer and ThePlayer.replica.dotacharacter and ThePlayer.replica.dotacharacter:GetActivateItem()
        return Inv and Inv.components.aoetargeting and Inv
    end

    function self:Dota_StartReticule(invobject)
        self:CloseCrafting()
        local item = invobject or ThePlayer and ThePlayer.replica.dotacharacter and ThePlayer.replica.dotacharacter:GetActivateItem()
        local playercontroller = ThePlayer and ThePlayer.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:StartAOETargetingUsing(item)   -- 里面已经有item判空了
        end
    end

    function self:Dota_EndReticule()
        local playercontroller = ThePlayer and ThePlayer.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:CancelAOETargeting()
        end 
    end
end)