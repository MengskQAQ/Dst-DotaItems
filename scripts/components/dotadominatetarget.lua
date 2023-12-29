-------------------------------------------------支配效果----------------------------------------------
------------------------------------------支配头盔 and (统御头盔 or 大支配)-------------------------------------------------
local function OnDominateHelmAppeared(self, data)
    if data and data.helmid and data.inst and self
     and self.helmid == data.helmid then
        if data.inst.components.dominate.targetid ~= self.targetid then -- 双重检测
            self.helm = nil
            self.helmid = nil
            data.inst.components.dominate:StopTargetFollow(self.inst)
            return
        else
            self:WatchHelm(data.inst)
        end
    end
end

local DotaDominateTarget = Class(function(self, inst)
    self.inst = inst
    self.helm = nil
    self.helmid = nil
    self.targetid = nil
    self.beimproved = false

    self:InitTargrtID()

    self.OnDominateHelmAppear = function(src, data) OnDominateHelmAppeared(self, data) end
    self.inst:ListenForEvent("dotaevent_dominatehelmappear", self.OnDominateHelmAppear, TheWorld)
end)

function DotaDominateTarget:OnRemoveFromEntity()

end

function DotaDominateTarget:InitTargrtID()
    self.targetid = self.targetid or Dota_GetDominateID()
end

function DotaDominateTarget:WatchHelm(helm)
    if helm == nil then 
        self.helm = nil
        self.helmid = nil 
        return
    end

    if helm.components.dominate then

        self.helm = helm
        self.helmid = helm.components.dominate.helmid 

        self.helm.components.dominate:WatchTarget(self.inst)

        -- self.inst:ListenForEvent("onremove", function()
        --     self.helm = nil
        -- end, helm)
    end
end

function DotaDominateTarget:HasHelm()
    return self.helm ~= nil
end

function DotaDominateTarget:OnSave()
    local data = {
        add_component_if_missing = true,
        targetid = self.targetid,
        helmid = self.helmid,
    }
    return data
end

function DotaDominateTarget:OnLoad(data)
    if data then
        self.targetid = data.targetid
        self.helmid = data.helmid
        if self.helmid then
            TheWorld:PushEvent("dotaevent_dominatetargetappear", { inst = self.inst, targetid = self.targetid })
        end
    end
end

function DotaDominateTarget:LoadPostPass(ents, data)
-- 利用事件来进行处理世界传送时的同步问题
    if data then
        self.targetid = data.targetid
        self.helmid = data.helmid
        if self.helmid then
            TheWorld:PushEvent("dotaevent_dominatetargetappear", { inst = self.inst, targetid = self.targetid })
        end
    end
end

return DotaDominateTarget