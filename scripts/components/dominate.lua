-------------------------------------------------支配效果----------------------------------------------
------------------------------------------支配头盔 and (统御头盔 or 大支配)-------------------------------------------------

local Dominate = Class(function(self, inst)
    self.inst = inst
    self.ondominatefn = nil
    self.targetfx = nil
    self.ownerfx = nil
    self.target = nil

    self:ResetSoundFX()
end)

function Dominate:OnRemoveFromEntity()
    self:StopDominate()
end

function Dominate:ResetSoundFX()
    self.sound = "dontstarve/wilson/chest_open"
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
    -- Todo:切斯特和星空要不要特别说明呢
    if target:HasTag("companion") then return false end
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

        if owner.components.minigame_participator == nil then   -- Todo:这个判断有什么用途？如果不执行的话，会造成下面的逻辑bug吗
            owner:PushEvent("makefriend")
            owner.components.leader:AddFollower(target)
        end

        -- 模仿follower中的AddLoyaltyTime函数   -- Todo:缺少 targettime 应该没什么影响吧，或者我们直接去hook这个接口？
        target:PushEvent("gainloyalty", { leader = self.leader })
		
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
        target.components.domesticatable:SetDominateStatus(true)

		succeed = true
    end

    if succeed then
        if self.ondominatefn ~= nil then
			self.ondominatefn(owner, target)
		end
		self:StopDominate()
		self.target = target
		self:SpawnOwnerEffect(owner)
		self:SpawnTargetEffect(target)
    end

    return succeed
end

local function KillTarget(target)
    if target.components.health ~= nil and not target.components.health:IsDead() then
        target.components.health:SetVal(0, "dota_dominate", nil)	-- Todo: 所有生物都可以这样致死吗？
    end
end

function Dominate:StopDominate()
    if self.target == nil then return false end
    if self.target.components.domesticatable ~= nil then
        self.target.components.domesticatable:SetDominateStatus(false)
        KillTarget(self.target)
        return true
    end

    if self.target:IsValid() then
        self.target:PushEvent("loseloyalty", { leader = self.leader })
        self.target.components.follower:SetLeader(nil)
        KillTarget(self.target)
        return true
    end
    return false
end

function Dominate:HasTarget()
    return self.target ~= nil
end

function Dominate:OnSave()
    local data = {
        target = self.target,
    }
    return data
end

function Dominate:OnLoad(data)
    self.target = data.target or nil
    if self.target ~= nil and self.ondominatefn ~= nil then
        self.ondominatefn(self.inst, self.target)
    end
end

return Dominate
