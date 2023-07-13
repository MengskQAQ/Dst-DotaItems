-----------------------------------------------------------------------
-- 此lua写法出自恒子大佬的能力勋章[workshop-1909182187]
-- 来源 /scripts/medal_modframework.lua
-----------------------------------------------------------------------

-- local fn = function(inst, doer, pos, actions, right, target)
					-- local x,y,z = pos:Get()
					-- return right and (TheWorld.Map:IsAboveGroundAtPoint(x,y,z) or TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil) and not TheWorld.Map:IsGroundTargetBlocked(pos) and not doer:HasTag("steeringboat") and not doer:HasTag("rotatingboat")
-- end

-- AddComponentAction("POINT","blinkdagger",fn)

local pcall = GLOBAL.pcall
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

----------------------------------------------------------------------------

-- --动作需要激活(基于严格统一的命名)
-- local function AddActivateAction(name)
    -- local activateitem = {
        -- id = string.upper( string.format(name.."_ACTIVATE") ),
        -- str = STRINGS.DOTA.NEWACTION[name],
        -- fn = function(act)
            -- if act.invobject ~= nil and
             -- act.invobject.components.activatableitem ~= nil and
            -- --  act.invobject.components.activatableitem:IsActivate() and
             -- act.doer.components.inventory ~= nil and
             -- act.doer.components.inventory:IsOpenedBy(act.doer) then
                -- return act.invobject.components.activatableitem:ChangeActivate()
            -- end
        -- end,
        -- actiondata = {
            -- priority=9,
            -- rmb=true,
            -- instant=true,
            -- mount_valid=true,
            -- encumbered_valid=true,
        -- },
    -- }
	
    -- local action = AddAction(activateitem.id, activateitem.str, activateitem.fn)
    -- for k,data in pairs(activateitem.actiondata) do
        -- action[k] = data
    -- end
	-- AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(action, activateitem.state))
	-- AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(action,activateitem.state))
-- --	print("[debug]AddActivateAction " .. activateitem.id)
-- end

-- local function AddActivateComponent(name)
    -- local actionname = string.upper( string.format(name.."_ACTIVATE") )
	-- name = string.lower(name)
    -- local function testfn(inst,doer,actions,right)
		-- local equipped = (inst ~= nil and doer.replica.inventory ~= nil) and doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) or nil

        -- if ((inst.replica.equippable ~= nil and inst.replica.equippable:IsEquipped())
		 -- or (equipped ~= nil and equipped.replica.container ~= nil and equipped.replica.container:IsHolding(inst)))
         -- and doer.replica.inventory ~= nil 
         -- and doer.replica.inventory:IsOpenedBy(doer)
		 -- and inst:HasTag(name) then
            -- table.insert(actions,GLOBAL.ACTIONS[actionname])
        -- end
    -- end
    -- AddComponentAction("INVENTORY", "activatableitem", testfn)
-- --	print("[debug]AddActivateComponent " .. actionname)
-- end
----------------------------------------------------------------------------

-- -- Todo：优化方向，把所有激活动作集合成一个
-- local ACTIVATEITEM = Action()
-- ACTIVATEITEM.id = "ACTIVATEITEM"
-- ACTIVATEITEM.str = STRINGS.DOTA.NEWACTION.ACTIVATEITEM
-- -- 动作触发函数
-- ACTIVATEITEM.fn = function(act)
    -- if act.target ~= nil then
		-- if act.invobject ~= nil and
		 -- act.invobject.components.activatableitem ~= nil and
		-- --  act.invobject.components.activatableitem:IsActivate() and
		 -- act.doer.components.inventory ~= nil and
		 -- act.doer.components.inventory:IsOpenedBy(act.doer) then
			-- return act.invobject.components.activatableitem:ChangeActivate()
		-- end
    -- end
    -- return false
-- end
-- local newaction = AddAction(ACTIVATEITEM)
-- newaction.priority = 8
-- newaction.mount_valid = true
-- newaction.strfn = function(act)
    -- print("debug  " .. act.invobject)
	-- return act.invobject ~= nil and act.invobject.components.activatableitem.actionname or nil
-- end

-- AddComponentAction("INVENTORY", "activatableitem", function(inst, doer, actions, right)
	-- local equipped = (inst ~= nil and doer.replica.inventory ~= nil) and doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.DOTASLOT or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY) or nil
	-- if ((inst.replica.equippable ~= nil and inst.replica.equippable:IsEquipped())
	 -- or (equipped ~= nil and equipped.replica.container ~= nil and equipped.replica.container:IsHolding(inst)))
	 -- and doer.replica.inventory ~= nil 
	 -- and doer.replica.inventory:IsOpenedBy(doer)
	 -- and inst:HasTag("dota_needactivate") then
		-- table.insert(actions,GLOBAL.ACTIONS.ACTIVATEITEM)
	-- end
-- end)

----------------------------------------------------------------------------

local queueractlist={}--可兼容排队论的动作
local actions_status,actions_data = pcall(require,"dota_defs/dota_action")
--local actions_data = require("dota_defs/dota_action")

--if actions_data then
if actions_status then
    -- 导入自定义动作
    if actions_data.actions then
        for _,act in pairs(actions_data.actions) do
            local action = AddAction(act.id,act.str,act.fn)
            if act.actiondata then
                for k,data in pairs(act.actiondata) do
                    action[k] = data
                end
            end
			--兼容排队论
			if act.canqueuer then
				queueractlist[act.id]=act.canqueuer
				-- table.insert(queueractlist,act.id)
			end
            AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(action, act.state))
            AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(action,act.state))
            --动作需要激活
            -- if act.needactivate then
                -- AddActivateAction(act.id)
                -- AddActivateComponent(act.id)
            -- end
        end
    end

    -- 导入动作与组件的绑定
    if actions_data.component_actions then
        for _,v in pairs(actions_data.component_actions) do
            local testfn = function(...)
                local actions = (v.type == "POINT") and GLOBAL.select (4,...) or GLOBAL.select (-2,...)	--选取第四个元素为actions，限制了fn的参数
                for _,data in pairs(v.tests) do
                    if data and data.testfn and data.testfn(...) then
                        data.action = string.upper( data.action )
                        table.insert(actions,GLOBAL.ACTIONS[data.action])
                    end
                end
            end
            AddComponentAction(v.type, v.component, testfn)
        end
    end
	--修改老动作
	if actions_data.old_actions then
        for _,act in pairs(actions_data.old_actions) do
			if act.switch then 
				local action = GLOBAL.ACTIONS[act.id]
				if act.actiondata then
					for k,data in pairs(act.actiondata) do
						action[k] = data
					end
				end
				if act.state then
					local testfn = act.state.testfn
					AddStategraphPostInit("wilson", function(sg)
						local old_handler = sg.actionhandlers[action].deststate
						sg.actionhandlers[action].deststate = function(inst, action)
							if testfn and testfn(inst,action) and act.state.deststate then
								return act.state.deststate(inst,action)
							end
							return old_handler(inst, action)
						end
					end)
					if act.state.client_testfn then
						testfn = act.state.client_testfn
					end
					AddStategraphPostInit("wilson_client", function(sg)
						local old_handler = sg.actionhandlers[action].deststate
						sg.actionhandlers[action].deststate = function(inst, action)
							if testfn and testfn(inst,action) and act.state.deststate then
								return act.state.deststate(inst,action)
							end
							return old_handler(inst, action)
						end
					end)
				end
			end
        end
    end
end

-- --动作兼容行为排队论
-- local actionqueuer_status,actionqueuer_data = pcall(require,"components/actionqueuer")
-- if actionqueuer_status then
-- 	if AddActionQueuerAction and next(queueractlist) then
--     	for k,v in pairs(queueractlist) do
--     		AddActionQueuerAction(v,k,true)
--     	end
--     end
-- end



-- local type = "POINT" -- 设置动作绑定的类型
-- local component = "blinkdagger" -- 设置动作绑定的组件
-- local testfns = function(inst, doer, pos, actions, right, target)
					-- local x,y,z = pos:Get()
					-- if right and (TheWorld.Map:IsAboveGroundAtPoint(x,y,z) or TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil) and not TheWorld.Map:IsGroundTargetBlocked(pos) and not doer:HasTag("steeringboat") and not doer:HasTag("rotatingboat") then
						-- table.insert(actions, ACTIONS.BLINKDAGGER)
					-- end
				-- end
-- AddComponentAction(type, component, testfns)

--给激活动作添加名字	-- Todo:怎么在客户端设置元表啊？！WTF？这怎么解决啊~~~
-- STRINGS.ACTIONS.ACTIVATEITEM = {ACTIVATEITEM = "激活",}
-- setmetatable(STRINGS.ACTIONS.ACTIVATEITEM, STRINGS.DOTA.NEWACTION)

-- for k,v in pairs (STRINGS.DOTA.NEWACTION) do
--     STRINGS.ACTIONS.ACTIVATEITEM[k] = v
-- end

-- STRINGS.ACTIONS.ACTIVATEITEM = {
-- 	ACTIVATEITEM = "激活",
-- 	WEARDOTAEQUIP = "放至装备栏",
-- 	TAKEOFFDOTAEQUIP = "自装备栏脱下",
-- 	DOTA_TPSCROLL = "传送",
-- 	DOTA_CLARITY = "贴上",
-- 	DOTA_FAERIEFIRE = "吃下",
-- 	DOTA_SMOKE = "散开",
-- 	DOTA_MANGO = "恰",
-- 	DOTA_TANGO = "吃树",
-- 	DOTA_DUST = "撒粉",
-- 	DOTA_TOME = "阅读",
-- 	DOTA_SALVE = "贴上",
-- 	DOTA_CHOP = "砍伐",
-- 	DOTA_FADING = "渐隐",
-- 	DOTA_BLINK = "闪烁",
-- 	DOTA_TOGGLE = "切换",
-- 	DOTA_BERSERK = "狂热",
-- 	DOTA_SACRIFICE = "献身",
-- 	DOTA_TRANSMUTE = "炼金",
-- 	DOTA_DOMINATE = "支配",
-- 	DOTA_PHASE = "相位移动",
-- 	DOTA_REPLENISH = "补魔",
-- 	DOTA_BARRIER = "魔法护盾",
-- 	DOTA_RELEASE = "灵魂释放",
-- 	DOTA_RELEASEPLUS = "灵魂释放",
-- 	DOTA_ENDURANCE = "坚韧",
-- 	DOTA_RESTORE = "回复",
-- 	DOTA_ENDURANCEDRUM = "坚韧",
-- 	DOTA_CHARGE = "充能",
-- 	DOTA_MEND = "修复",
-- 	DOTA_VALOR = "无畏",
-- 	DOTA_REPRISAL = "怨灵报复",
-- 	DOTA_CYCLONE = "龙卷风",
-- 	DOTA_CRIPPLE = "致残",
-- 	DOTA_BURST1 = "能量冲击1",
-- 	DOTA_BURST2 = "能量冲击2",
-- 	DOTA_BURST3 = "能量冲击3",
-- 	DOTA_BURST4 = "能量冲击4",
-- 	DOTA_BURST5 = "能量冲击5",
-- 	DOTA_CYCLONEPLUS = "龙卷风",
-- 	DOTA_CHAINS = "永恒锁链",
-- 	DOTA_RESETCOOLDOWNS = "完全重置",
-- 	DOTA_GLIMMER = "微光",
-- 	DOTA_HEX = "妖术",
-- 	DOTA_SHINE = "日耀",
-- 	DOTA_FORCE = "原力",
-- 	DOTA_BURNX = "灵魂燃烧",
-- 	DOTA_GUARD = "坚盾",
-- 	DOTA_AVATAR = "天神下凡",
-- 	DOTA_MIRROR = "镜像",
-- 	DOTA_THRUST = "飓风之力",
-- 	DOTA_SHELL = "回音护盾",
-- 	DOTA_RETURN = "伤害反弹",
-- 	DOTA_INSULATION = "绝缘",
-- 	DOTA_BLAST = "极寒冲击",
-- 	DOTA_BLOODPACT = "血之契约",
-- 	DOTA_SHROUD = "法衣",
-- 	DOTA_WALK = "暗影步",
-- 	DOTA_METEOR = "陨星锤",
-- 	DOTA_NULLIFY = "否决",
-- 	DOTA_FLUTTER = "振翅",
-- 	DOTA_BURN = "辉耀灼烧",
-- 	DOTA_UNHOLY = "邪恶之力",
-- 	DOTA_OVERWHELM = "强击",
-- 	DOTA_ETHEREAL = "虚化冲击",
-- 	DOTA_REND = "灵魂撕裂",
-- 	DOTA_PROVINCE = "幻影之域",
-- 	DOTA_DISARM = "缴械",
-- 	DOTA_RAGE = "不洁狂热",
-- 	DOTA_INHIBIT = "阻止",
-- 	DOTA_LIGHTING = "静电冲击",
--     DOTA_WEAKNESS = "虚弱",
-- }

STRINGS.ACTIONS.ACTIVATEITEM = {
	ACTIVATEITEM = STRINGS.DOTA.NEWACTION.ACTIVATEITEM,
}

-- 为 激活动作 命名
for k, v in pairs(STRINGS.DOTA.NEWACTION) do
	STRINGS.ACTIONS.ACTIVATEITEM[k] = v
end

-- -- 为 范围施法 命名
-- for k, v in pairs(STRINGS.DOTA.AOEACTION) do
	-- STRINGS.ACTIONS.CASTAOE[k] = v
-- end

--------------------------------回城卷轴 or 远行鞋I or 飞鞋 or 远行鞋II or 大飞鞋---------------------------------------
local function ActionCanMaphop(act)
	if act.doer:HasTag("dota_tpscroll")
	--  and act.doer.dota_ontpcooldowntask == nil
	--  act.invobject == nil and act.doer
	--  and act.doer.replica.inventory:Has("dota_town_portal_scroll", 1) 
	 then
		local rider = act.doer.replica.rider
        if rider == nil or not rider:IsRiding() then
            return true
        end
	end
    return false
end
local BLINK_MAP_MUST = { "CLASSIFIED", "globalmapicon", "fogrevealer" }
local TPSCROLL_MANA = TUNING.DOTA.TOWN_PORTAL_SCROLL.MANA
GLOBAL.ACTIONS_MAP_REMAP[ACTIONS.DOTA_TPSCROLL.code] = function(act, targetpos)
    local doer = act.doer
    if doer == nil then
        return nil
    end

    local aimassisted = false
    local distoverride = nil

    if not TheWorld.Map:IsVisualGroundAtPoint(targetpos.x, targetpos.y, targetpos.z) then
        -- NOTES(JBK): No map tile at the cursor but the area might contain a boat that has a maprevealer component around it.
        -- First find a globalmapicon near here and look for if it is from a fogrevealer and assume it is on landable terrain.
        local ents = TheSim:FindEntities(targetpos.x, targetpos.y, targetpos.z, PLAYER_REVEAL_RADIUS * 0.4, BLINK_MAP_MUST)
        local revealer = nil
        local MAX_WALKABLE_PLATFORM_DIAMETERSQ = TUNING.MAX_WALKABLE_PLATFORM_RADIUS * TUNING.MAX_WALKABLE_PLATFORM_RADIUS * 4 -- Diameter.
        for _, v in ipairs(ents) do
            if doer:GetDistanceSqToInst(v) > MAX_WALKABLE_PLATFORM_DIAMETERSQ then -- Ignore close boats because the range for aim assist is huge.
                revealer = v
                break
            end
        end
        if revealer == nil then
            return nil
        end
        -- NOTES(JBK): Ocuvigils are normally placed at the edge of the boat and can result in the teleportee being pushed out of the boat boundary.
        -- The server will make the adjustments to the target position without the client being able to know so we force the original distance to be an override.
        targetpos.x, targetpos.y, targetpos.z = revealer.Transform:GetWorldPosition()
        distoverride = act.pos:GetPosition():Dist(targetpos)
        if revealer._target ~= nil then
            -- Server only code.
            local boat = revealer._target:GetCurrentPlatform()
            if boat == nil then
                -- This should not happen but in case it does fail the act to not teleport onto water.
                return nil
            end
            targetpos.x, targetpos.y, targetpos.z = boat.Transform:GetWorldPosition()
        end
        aimassisted = true
    end
    -- local dist = distoverride or act.pos:GetPosition():Dist(targetpos)
    local act_remap = BufferedAction(doer, nil, ACTIONS.DOTA_TPSCROLL_MAP, act.invobject, targetpos)
	act_remap.manacost = TPSCROLL_MANA
	act_remap.currentmana = act_remap.doer.replica.dotaattributes ~= nil and act_remap.doer.replica.dotaattributes.mana or 0
    act_remap.aimassisted = aimassisted
	if not ActionCanMaphop(act_remap) then
        return nil
    end

    return act_remap
end

local MapScreen = require "screens/mapscreen"
local Text = require("widgets/text")

local deco = MapScreen.ProcessRMBDecorations
MapScreen.ProcessRMBDecorations = function (self,rmb, fresh)
    if rmb.action == GLOBAL.ACTIONS.DOTA_TPSCROLL_MAP then
        if fresh then
            self.decorationdata.rmbents = {}
        end
        local decor1
        if fresh then
            local image = "dota_town_portal_scroll.tex"
            local atlas = "images/dota_consumables/dota_town_portal_scroll.xml"
            if rmb.doer then
                if rmb.doer:HasTag("boots_of_travel_level1") then
                    image = "dota_boots_of_travel_level1.tex"
                    atlas = "images/dota_accessories/dota_boots_of_travel_level1.xml"
                elseif rmb.doer:HasTag("boots_of_travel_level2") then
                    image = "dota_boots_of_travel_level2.tex"
                    atlas = "images/dota_accessories/dota_boots_of_travel_level2.xml"        
                end
            end
            decor1 = self.decorationrootrmb:AddChild(GLOBAL.Image(atlas, image))
            decor1.text = decor1:AddChild(Text(GLOBAL.NUMBERFONT, 42))
            self.decorationdata.rmbents[1] = decor1
        else
            decor1 = self.decorationdata.rmbents[1]
        end

        local rmb_pos = rmb:GetActionPoint()
        local px, py, pz = 0, 0, 0
        if rmb.doer then
            px, py, pz = rmb.doer.Transform:GetWorldPosition()
        end
        local dx, dz = rmb_pos.x - px, rmb_pos.z - pz
        local zoomscale = 1.25 / self.minimap:GetZoom()
        local w, h = GLOBAL.TheSim:GetScreenSize()
        w, h = w * 0.5, h * 0.5
        local ndx, ndz = dx + px, dz + pz
        local x, y = self.minimap:WorldPosToMapPos(ndx, ndz, 0)
        decor1:SetPosition(x * w, y * h)
        decor1:SetScale(zoomscale, zoomscale, 1)
        if rmb.currentmana<rmb.manacost then
            decor1.text:SetString(STRINGS.DOTA.LACKMANA)
        end
    else
        return deco(self,rmb, fresh)
    end
end

