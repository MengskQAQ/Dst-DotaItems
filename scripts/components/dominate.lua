-------------------------------------------------支配效果----------------------------------------------
------------------------------------------支配头盔 and (统御头盔 or 大支配)-------------------------------------------------
local function OnDominateTargetAppeared(self, data)
    if self and not self:HasTarget() then
        if self.targetid == data.targetid then
            if data.target.components.dotadominatetarget.helmid == self.helmid then
                self:DoDominate(self.inst, data.inst)
            else
                self.targetid = nil
            end
        end
    end
end

local Dominate = Class(function(self, inst)
    self.inst = inst

    self.ondominatefn = nil

    self.targetfx = nil
    self.ownerfx = nil

    self.target = nil

    self.helmid = nil
    self.targetid = nil

    self:InitHelmID()
    self:ResetSoundFX()

    self.OnDominateTargetAppear = function(src, data) OnDominateTargetAppeared(self, data) end
    self.inst:ListenForEvent("dotaevent_dominatetargetappear", self.OnDominateTargetAppear, TheWorld)
end)

function Dominate:OnRemoveFromEntity()
    self:StopDominate()
end

function Dominate:ResetSoundFX()
    self.sound = "dontstarve/wilson/chest_open"
end

function Dominate:InitHelmID()
    self.helmid = self.helmid or Dota_GetDominateID()
end

function Dominate:SetSoundFX(sound)
    self.sound = sound or self.sound
end

function Dominate:SetFX(owner, target)
    self.ownerfx = owner
    self.targetfx = target
end

function Dominate:SetDominateFn(fn)
    self.ondominatefn = fn
end

function Dominate:SpawnOwnerEffect(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if self.ownerfx ~= nil then
        SpawnPrefab(self.ownerfx).Transform:SetPosition(x, y - .1, z)
    end
    if self.sound ~= "" then
        inst.SoundEmitter:PlaySound(self.sound)
    end
end

function Dominate:SpawnTargetEffect(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if self.targetfx ~= nil then
        SpawnPrefab(self.targetfx).Transform:SetPosition(x, y - .1, z)
    end
end

function Dominate:CanBeDominate(target)
    -- TODO:切斯特和星空要不要特别说明呢
    if target:HasTag("companion") then return false end

    -- if target.components.dotadominatetarget ~= nil and target.components.dotadominatetarget.helmid ~= nil then return false end

    -- 猪人/兔人/鱼人/石虾/猫
    if target.components.follower ~= nil and target.components.follower.leader == nil then  -- 未被收买
        return true
    end
    -- 牛
    if target.components.domesticatable ~= nil then
        return true
    end
    return false
end

function Dominate:CanDominate(owner)
    return owner.components.leader ~= nil
end

local function DoCheer_Act(inst)
    if inst.sg ~= nil and not inst.sg:HasStateTag("busy") then
        inst.sg:GoToState("cheer")
    end
end

function Dominate:DoDominate(owner, target)
    if not owner or not target then
        return false
    end

    local succeed = false
    -- 猫猫/石虾
    if (owner.components.leader ~= nil and (target.prefab == "catcoon" or target.prefab == "rocky")) then
        if target.components.combat ~= nil and target.components.combat:TargetIs(owner) then    -- 消除仇恨
            target.components.combat:SetTarget(nil)
        end

        if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then    -- 消除睡眠
            target.components.sleeper:WakeUp()
        end

		if owner.components.minigame_participator == nil then
			owner:PushEvent("makefriend")
	        owner.components.leader:AddFollower(target)
		end
        target.last_hairball_time = GetTime()
        target.hairball_friend_interval = math.random(2,4) -- Jumpstart the hairball timer (slot machine time!)

        if not target.sg:HasStateTag("busy") and target.prefab == "catcoon" then
            target:FacePoint(owner.Transform:GetWorldPosition())
            target.sg:GoToState("pawground")
        elseif target.prefab == "rocky" then
            target.sg:GoToState("rocklick")
        end
        succeed = true
    -- 猪人/兔人
    elseif owner.components.leader ~= nil and target.components.follower ~= nil 
     and not (target:HasTag("guard") or owner:HasTag("monster") or owner:HasTag("merm")) then
        if target.components.combat ~= nil and target.components.combat:TargetIs(owner) then    -- 消除仇恨
            target.components.combat:SetTarget(nil)
        end

        if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then    -- 消除睡眠
            target.components.sleeper:WakeUp()
        end

        if owner.components.minigame_participator == nil then   -- TODO:这个判断有什么用途？如果不执行的话，会造成下面的逻辑bug吗
            owner:PushEvent("makefriend")
            owner.components.leader:AddFollower(target)
        end

        -- 模仿follower中的AddLoyaltyTime函数   -- TODO:缺少 targettime 应该没什么影响吧，或者我们直接去hook这个接口？
        target:PushEvent("gainloyalty", { leader = self.leader })   -- nil又何妨
		
		succeed = true
	-- 鱼人
    elseif owner.components.leader ~= nil and target.components.follower ~= nil 
     and owner:HasTag("merm") and target:HasTag("merm")
     and not (TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:IsCandidate(target)) then
        if target.components.combat ~= nil and target.components.combat:TargetIs(owner) then    -- 消除仇恨
            target.components.combat:SetTarget(nil)
        end

        if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then    -- 消除睡眠
            target.components.sleeper:WakeUp()
        end

        owner:PushEvent("makefriend")
        owner.components.leader:AddFollower(target)
        target:PushEvent("gainloyalty", { leader = self.leader })

        target:DoTaskInTime(math.random()*1, DoCheer_Act)

		succeed = true
    -- 牛
    elseif target.components.domesticatable ~= nil then
        if target.components.combat ~= nil and target.components.combat:TargetIs(owner) then    -- 消除仇恨
            target.components.combat:SetTarget(nil)
        end

        if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then    -- 消除睡眠
            target.components.sleeper:WakeUp()
        end

        target.components.domesticatable:DeltaObedience(0.01)   -- 增加饱食度，防止驯化度掉太快
        target.components.domesticatable:TryBecomeDomesticated()
        target.components.domesticatable:DeltaDomestication(0.99)   -- 增加驯化度
        target.components.domesticatable:Dota_SetDominateStatus(true)

		succeed = true
    end

    if succeed then
		self:StopDominate(true)

        if target.components.dotadominatetarget == nil then
            target:AddComponent("dotadominatetarget")
        end
        -- self:WatchTarget(target) -- 这个放 WatchHelm 里执行
        target.components.dotadominatetarget:WatchHelm(self.inst)

        if self.ondominatefn ~= nil then
			self.ondominatefn(owner, target)
		end

		self:SpawnOwnerEffect(owner)
		self:SpawnTargetEffect(target)
    end

    return succeed
end

function Dominate:StopDominate(shouldkill)
    if not self:IsOwnTarget(self.target) then return end
    self:StopTargetFollow(self.target)
    if shouldkill then
        self:KillTarget()
    end
    self:WatchTarget(nil)
end

function Dominate:StopTargetFollow(target)
    if target.components.domesticatable ~= nil then
        target.components.domesticatable:Dota_SetDominateStatus(false)
    end

    if target:IsValid() then
        target:PushEvent("loseloyalty", { leader = self.leader })
        target.components.follower:SetLeader(nil)
    end

    if target.components.dotadominatetarget then
        target.components.dotadominatetarget:WatchHelm(nil)
        target:RemoveComponent("dotadominatetarget")
    end
end

function Dominate:HasTarget()
    return self.target ~= nil
end

function Dominate:GetTarget()
    return self.target
end

function Dominate:IsOwnTarget(target)
    return self.helmid == (target and target.components.dotadominatetarget and target.components.dotadominatetarget.helmid)
end

function Dominate:KillTarget(target)
    target = target or self.target
    if target and target:IsValid() -- WTF
     and target.components.health ~= nil and not target.components.health:IsDead() then
        target.components.health:SetVal(0, "dota_dominate", nil)	-- TODO: 所有生物都可以这样致死吗？
    end
end

function Dominate:WatchTarget(target)
    if target == nil then 
        self.target = nil
        self.targetid = nil   
        return
    end

    if target.components.dotadominatetarget then
        self.target = target
        self.targetid = target.components.dotadominatetarget.targetid

        -- self.inst:ListenForEvent("onremove", function()
        --     self.target = nil
        -- end, self.target)
    end
end

function Dominate:OnSave()
    return
    {
        helmid = self.helmid,
        targetid = self.targetid
    }
end

function Dominate:OnLoad(data)
    if data then
        self.helmid = data.helmid or nil
        self.targetid = data.targetid or nil
        TheWorld:PushEvent("dotaevent_dominatehelmappear", { inst = self.inst, helmid = self.helmid })
    end
end

function Dominate:LoadPostPass(ents, data)
    -- 物品在玩家身上时不会触发 LoadPostPass ， 因此 LoadPostPass 和 OnLoad 需要同时存在
    if data then
        self.helmid = data.helmid or nil
        self.targetid = data.targetid or nil
        TheWorld:PushEvent("dotaevent_dominatehelmappear", { inst = self.inst, helmid = self.helmid })
    end
end

return Dominate
