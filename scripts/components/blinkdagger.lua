--------------------------------------------闪烁匕首 or 跳刀----------------------------------------------

--源文件来源于 /components/blinkstaff.lua

--饥荒的世界加载范围16-19地皮
--人物背后19地皮，正面16地皮（根据b站视频）
--推测应该是加载16格，卸载19格
local BASE_VOICE_VOLUME = TUNING.DOTA.BASE_VOICE_VOLUME + 1	-- 实在是太小了这个声音，加个附加值

local BlinkDagger = Class(function(self, inst)
    self.inst = inst
    self.onblinkfn = nil
    self.blinktask = nil
    self.frontfx = nil
    self.backfx = nil
	self.pendis = 32
	self.maxdis = 32

    self:ResetSoundFX()
end)

function BlinkDagger:SetFX(front, back)
    self.frontfx = front
    self.backfx = back
end

function BlinkDagger:SetMaxDistance(maxdis)
    self.maxdis = maxdis or self.maxdis
end

function BlinkDagger:SetPenDistance(pendis)
    self.pendis = pendis or self.pendis
end

function BlinkDagger:ResetSoundFX()
    self.presound = "dontstarve/common/staff_blink"
    self.postsound = "dontstarve/common/staff_blink"
end

function BlinkDagger:SetSoundFX(presound, postsound)
    self.presound = presound or self.presound
    self.postsound = postsound or self.postsound
end

function BlinkDagger:SpawnEffect(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if self.backfx ~= nil then
        SpawnPrefab(self.backfx).Transform:SetPosition(x, y - .1, z)
    end
    if self.frontfx ~= nil then
        SpawnPrefab(self.frontfx).Transform:SetPosition(x, y, z)
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function NoPlayersOrHoles(pt)
    return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or TheWorld.Map:IsPointNearHole(pt))
end

function BlinkDagger:GetVaildPosition(pt, caster)
	local caster_pt = Vector3(caster.Transform:GetWorldPosition())
	local angle = caster:GetAngleToPoint(pt)*DEGREES

	local x = caster_pt.x + self.pendis * math.cos(angle)
	local y = 0
	local z = caster_pt.z - self.pendis * math.sin(angle)
	local pos = Vector3(x,y,z)

	-- print("[Debug] blinkdagger")
	-- print("x = ".. x .. " caster_pt.x = " .. caster_pt.x .. " Diff = " .. x - caster_pt.x)
	-- print("y = ".. y .. " caster_pt.y = " .. caster_pt.y .. " Diff = " .. y - caster_pt.y)
	-- print("z = ".. z .. " caster_pt.z = " .. caster_pt.z .. " Diff = " .. z - caster_pt.z)
	-- print("angle = ".. angle)
	-- print("cos" .. angle .. ": " .. math.cos(angle))
	-- print("sin" .. angle .. ": " .. math.sin(angle))
	-- print("cos_distance = " .. self.pendis * math.cos(angle))
	-- print("sin_distance = " .. self.pendis * math.sin(angle))
	-- print("PI = ".. PI)
	-- print("PI + angle = ".. PI + angle)
	
	if not TheWorld.Map:IsOceanAtPoint(x, 0, z) then
		return pos
	end
	
	-- 利用二分法拟合落点( TODO: 这里的二分法要不要考虑溢出问题呢？用不用位运算呢？ )
	local trycount = 6	-- 二分法尝试次数
	local left = 0
	local right = 2^trycount
	local mid = 0
	local piece_x = (self.pendis * math.cos(angle)) / right
	local piece_z = (- self.pendis * math.sin(angle)) / right

	while(trycount>0) do
		mid = (left + right) / 2
		if TheWorld.Map:IsOceanAtPoint(caster_pt.x + mid * piece_x, 0, caster_pt.z + mid * piece_z) then
			right = mid
		else
			left = mid
		end
		trycount = trycount - 1
	end

	local x2 = caster_pt.x + left * piece_x
	local y2 = 0
	local z2 = caster_pt.z + left * piece_z
	local vpos = Vector3(x2,y2,z2)

	return vpos
end

-- local function GetVaildPosition(pt, caster)	-- 姑且没有什么好方法
	-- local caster_in_ocean = caster.components.locomotor ~= nil and caster.components.locomotor:IsAquatic()
	-- if caster_in_ocean then
	-- 	local from_pt = caster:GetPosition()
	-- 	local offset = FindSwimmableOffset(from_pt, math.random() * 2 * PI, TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_DISTANCE, 16)
	-- 	if offset ~= nil then
	-- 		return from_pt + offset
	-- 	end
	-- 	return caster:GetPosition()
	-- else
		-- -- 根据地图节点选择
		-- local centers = {}
		-- for i, node in ipairs(TheWorld.topology.nodes) do
		-- 	if TheWorld.Map:IsPassableAtPoint(node.x, 0, node.y) and node.type ~= NODE_TYPE.SeparatedRoom then
		-- 		table.insert(centers, {x = node.x, z = node.y})
		-- 	end
		-- end
		-- if #centers > 0 then
		-- 	local pos = centers[math.random(#centers)]
		-- 	return Point(pos.x, 0, pos.z)
		-- else
		-- 	return caster:GetPosition()
		-- end

		-- 火药猴寻找可用火炮逻辑
		-- local CANNON_MUST = {"boatcannon"}
		-- local BOAT_MUST = {"boat"}
		-- local function gotocannon(inst)
		-- 	if inst.components.crewmember then
		-- 		return nil
		-- 	end
		-- 	local pos = Vector3(inst.Transform:GetWorldPosition())
		
		-- 	local cannons = TheSim:FindEntities(pos.x, pos.y, pos.z, 25, CANNON_MUST)
		
		-- 	for i,cannon in ipairs(cannons) do
		-- 		if not cannon.operator or cannon.operator == inst then
		-- 			local targetboats = TheSim:FindEntities(pos.x, pos.y, pos.z, 25, BOAT_MUST)
		-- 			if #targetboats > 0 then
		-- 				for i, boat in ipairs(targetboats) do
		-- 					if not cannon.components.timer:TimerExists("monkey_biz") then
		-- 						local boatpos = Vector3(boat.Transform:GetWorldPosition())
		-- 						local angle =cannon:GetAngleToPoint(boatpos.x,boatpos.y,boatpos.z)
		-- 						if math.abs( DiffAngle(angle, cannon.Transform:GetRotation()) ) < 45 then
		-- 							local cannonpos = Vector3(cannon.Transform:GetWorldPosition())
		-- 							local angle = (cannon.Transform:GetRotation() -180) * DEGREES
		-- 							local offset = FindWalkableOffset(cannonpos, angle, 2, 12, true, false, nil, true)
		-- 							if offset and inst:GetDistanceSqToPoint(cannonpos+offset) > (0.25*0.25) then
		
		-- 								cannon.operator = inst
		-- 								inst.cannon = cannon
										
		-- 								return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, cannonpos+offset)
		-- 							end
		-- 						end
		-- 					end
		-- 				end
		-- 			end
		-- 		end
		-- 	end
		-- end

		-- 奇怪的定位
		-- caster:ForceFacePoint(pt.x, 0, pt.z)
		-- local from_pt = caster:GetPosition()
		-- local angle = caster:GetAngleToPoint(pt.x,pt.y,pt.z)
		-- -- local angle = (pt.Transform:GetRotation() -180) * DEGREES
		-- local offset = FindWalkableOffset(from_pt, angle, TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_DISTANCE, 16, true, true, IsPenaltyPoition, true)
		-- if offset ~= nil then
		-- 	return from_pt + offset
		-- end

		-- 通过三角函数计算落地，但还存在着问题
		-- print("[Debug] blinkdagger")
		-- local from_pt = caster:GetPosition()
		-- local angle = caster:GetAngleToPoint(pt)
		-- local x = from_pt.x + TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_DISTANCE * math.cos(angle*DEGREES)
		-- local y = 0
		-- local z = from_pt.z + TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_DISTANCE * math.sin(angle*DEGREES)
		-- local pos = Vector3(x,y,z)
		-- -- print("anglediff_param1  ".. caster.Transform:GetRotation())
		-- -- print("anglediff_param2  ".. caster:GetAngleToPoint(pt))
		-- print("angle  ".. angle)
		-- if TheWorld.Map:IsPassableAtPoint(x,y,z) then
		-- 	print("return pos")
		-- 	return pos
		-- end
		-- local offset = FindWalkableOffset(pos, math.random() * 2 * PI, 1, 16, true, false)
		-- 				or FindWalkableOffset(pos, math.random() * 2 * PI, 2, 16, true, false)
		-- 				or FindWalkableOffset(pos, math.random() * 2 * PI, 3, 16, true, false)
		-- 				or FindWalkableOffset(pos, math.random() * 2 * PI, 4, 16, true, false)
		-- if offset ~= nil and caster:GetDistanceSqToPoint() <= (TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_DISTANCE * TUNING.DOTA.BLINK_DAGGER_BLINK_PENALTY_DISTANCE)  then
		-- 	print("return offset")
		-- 	return pos + offset
		-- end


	-- 	return caster:GetPosition()
	-- end
-- end

local function OnBlinked(caster, self, dpt)
    if caster.sg == nil then
        caster:Show()
        if caster.components.health ~= nil then
            caster.components.health:SetInvincible(false)
        end
        if caster.DynamicShadow ~= nil then
            caster.DynamicShadow:Enable(true)
        end
    elseif caster.sg.statemem.onstopblinking ~= nil then
        caster.sg.statemem.onstopblinking()
    end
	local pt = dpt:GetPosition()
	if pt ~= nil and TheWorld.Map:IsPassableAtPoint(pt:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pt) then
	    caster.Physics:Teleport(pt:Get())
	end
    self:SpawnEffect(caster)
    if self.postsound ~= "" then
        caster.SoundEmitter:PlaySound(self.postsound, nil, BASE_VOICE_VOLUME)
    end
end

function BlinkDagger:Blink(pt, caster)
    if not TheWorld.Map:IsPassableAtPoint(pt:Get()) 
--	 or (caster.sg ~= nil and caster.sg.currentstate.name ~= "quicktele") 	--此处的sg对应actions里的state
	 or TheWorld.Map:IsGroundTargetBlocked(pt) 
     then
        return false
    elseif self.blinktask ~= nil then
        self.blinktask:Cancel()
    end
    self:SpawnEffect(caster)
    if self.presound ~= "" then
        caster.SoundEmitter:PlaySound(self.presound, nil, BASE_VOICE_VOLUME)
    end
    if caster.sg == nil then
		caster:Hide()
		if caster.DynamicShadow ~= nil then
			caster.DynamicShadow:Enable(false)
		end
		if caster.components.health ~= nil then
			caster.components.health:SetInvincible(true)
		end
    elseif caster.sg.statemem.onstartblinking ~= nil then
        caster.sg.statemem.onstartblinking()
    end
	
	local pos = caster:GetPosition()
	local epos = DynamicPosition(pt):GetPosition()
	local distancesq = distsq(pos, epos)
	if distancesq > (self.maxdis * self.maxdis) then
		local ipos = self:GetVaildPosition(pt, caster)
		self.blinktask = caster:DoTaskInTime(.0, OnBlinked, self, DynamicPosition(ipos))
		-- self.blinktask = caster:DoTaskInTime(.0, OnBlinked, self, DynamicPosition(pt))
	else
		self.blinktask = caster:DoTaskInTime(.0, OnBlinked, self, DynamicPosition(pt))
	end
	
    if self.onblinkfn ~= nil then
        self.onblinkfn(self.inst, pt, caster)
    end

    return true
end

return BlinkDagger
