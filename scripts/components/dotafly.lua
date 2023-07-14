------------------------------------------eul的神圣法杖 or 吹风----------------------------------------------
---------------------------------------------风之杖 or 大吹风------------------------------------------------

local DotaFly = Class(function(self, inst)
    self.inst = inst
    self.height = 3
    self.owner = nil
    self.isupdate = false
end)

-- 生成龙卷风
local function spawntornado(self, inst) --TODO: 龙卷风存在显示bug
    if inst._dotatornado == nil then
        inst:DoTaskInTime(0.1, function(inst)
            inst._dotatornado = SpawnPrefab("dota_fx_tornado")
            inst._dotatornado.entity:AddFollower()
            inst._dotatornado.entity:SetParent(self.owner.entity)
            inst._dotatornado.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end)
    end
end

-- 移除龙卷风
local function removecloud(self, inst)
    if inst._dotatornado ~= nil then
        if inst._dotatornado.KillFx then
            inst._dotatornado.KillFx(inst._dotatornado)
        end
        -- inst._dotatornado:Remove()
        inst._dotatornado = nil
    end
end

-- 获取飞行的设定高度
function DotaFly:GetHeight()
    return self.height
end

function DotaFly:IsUpdate()
    return self.isupdate
end

-- 芜湖，起飞
function DotaFly:Fly(canmove)
    self.owner = self.inst

    self.inst:AddTag("dota_flying")

    -- 生成龙卷风
    spawntornado(self, self.inst)

    -- 落水组件置为失效
    if self.inst.components.drownable then
        self.inst.components.drownable.enabled = false
    end

    -- 设置高度
    if self.inst.Physics then
        self.inst.Physics:SetMotorVel(0, self.height, 0)
    end

    -- 禁止攻击
    if self.inst.components.combat ~= nil then
        self.inst.components.combat:BlankOutAttacks(TUNING.DOTA.EULS.CYCLONE.DURATION)
    end

    -- 禁止被攻击
    if self.inst.components.health ~= nil then
        self.inst.components.health:SetInvincible(true)
    end

    -- 禁止操作
    if self.inst.components.playeractionpicker ~= nil then
        self.inst.components.playeractionpicker.dota_disable_click = true
    end

    -- 停止ai
    if self.inst.brain ~= nil then
        self.inst.brain:Stop()
    end

    if self.inst.components.locomotor then
        -- 停止移动
        if not canmove then
            self.inst.components.locomotor:Dota_CanMove(false, "tornado")
        end
        -- 开始刷帧 
        self.isupdate = true
        self.inst.components.locomotor.dotafly_height_override = self.height
        self.inst:StartUpdatingComponent(self)
    end

    return true
end

-- 着陆
function DotaFly:Land(land)
    self.owner = nil

    self.inst:RemoveTag("dota_flying")

    removecloud(self, self.inst)

    if self.inst.components.locomotor then
        self.inst.components.locomotor.dotafly_height_override = 0
    end

    -- 将落水组件置为生效
    if self.inst.components.drownable then
        self.inst.components.drownable.enabled = true
    end

    if land and self.inst.Physics then
        self.inst.Physics:SetMotorVel(0, 0, 0)
    end

    if self.inst.components.health ~= nil then
        self.inst.components.health:SetInvincible(false)
    end

    if self.inst.components.locomotor then
        self.inst.components.locomotor:Dota_CanMove(true, "tornado")
    end

    if self.inst.components.playeractionpicker ~= nil then
        self.inst.components.playeractionpicker.dota_disable_click = false
    end

    if self.inst.brain ~= nil then
        self.inst.brain:Start()
    end

    -- 停止刷帧
    if self.isupdate then
        self.isupdate = false
        self.inst:StopUpdatingComponent(self)
    end
    
    return true
end

-- 刷帧
function DotaFly:OnUpdate(dt)
    if self.inst.Physics then
        local x,y,z = self.inst.Physics:GetMotorVel()
        local pt = self.inst:GetPosition()
        self.inst.Physics:SetMotorVel(x, (self.height - pt.y) * 32, z)
    end
end

return DotaFly