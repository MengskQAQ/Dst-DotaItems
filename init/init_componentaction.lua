-----------------------------------------------------------------------
-- 此lua写法出自恒子大佬的能力勋章[workshop-1909182187]
-- 来源 /scripts/medal_modframework.lua
-----------------------------------------------------------------------

local pcall = GLOBAL.pcall
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

----------------------------------------------------------------------------

local queueractlist={}--可兼容排队论的动作
local actions_status,actions_data = pcall(require,"dota_defs/dota_action")
-- local actions_data = require("dota_defs/dota_action")

-- if actions_data then
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

            if act.pre_action_cb ~= nil then
                action.pre_action_cb = act.pre_action_cb
            end

			--兼容排队论
			if act.canqueuer then
				queueractlist[act.id]=act.canqueuer
				table.insert(queueractlist,act.id)
			end
            AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(action, act.state))
            AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(action,act.state))
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

--动作兼容行为排队论
local actionqueuer_status,actionqueuer_data = pcall(require,"components/actionqueuer")
if actionqueuer_status then
	if AddActionQueuerAction and next(queueractlist) then
    	for k,v in pairs(queueractlist) do
    		AddActionQueuerAction(v,k,true)
    	end
    end
end

-----------------------------------------------激活装备 / 取消装备激活 -------------------------------------------

STRINGS.ACTIONS.ACTIVATEITEM = {
	ACTIVATEITEM = STRINGS.DOTA.NEWACTION.ACTIVATEITEM,
}

STRINGS.ACTIONS.DEACTIVATEITEM = {
	DEACTIVATEITEM = STRINGS.DOTA.NEWACTION.DEACTIVATEITEM,
}

-- 为 激活动作 命名
for k, v in pairs(STRINGS.DOTA.NEWACTION) do
	STRINGS.ACTIONS.ACTIVATEITEM[k] = v
end

-- 为 取消装备激活 命名
local salt = STRINGS.DOTA.DEACTIVATESALT
for k, v in pairs(STRINGS.DOTA.NEWACTION) do
	STRINGS.ACTIONS.DEACTIVATEITEM[k] = v .. salt
end

local function AoeInActivate(val)
	if TheNet:GetIsClient() then
		if ThePlayer and ThePlayer.components.playercontroller then
			ThePlayer.components.playercontroller:CancelAOETargeting()
		end
	end
end

AddClientModRPCHandler("DOTARPC", "AOEINACTIVATE", AoeInActivate)

--------------------------------回城卷轴 or 远行鞋I or 飞鞋 or 远行鞋II or 大飞鞋---------------------------------------
local function ActionCanMaphop(act)
	if act.doer:HasTag("dota_tpscroll") then
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
	act_remap.currentmana = act_remap.doer.replica.dotaattributes and act_remap.doer.replica.dotaattributes:GetMana_Double() or 0
    act_remap.aimassisted = aimassisted
	if not ActionCanMaphop(act_remap) then
        return nil
    end

    return act_remap
end

local MapScreen = require "screens/mapscreen"
local Text = require("widgets/text")

local deco = MapScreen.ProcessRMBDecorations
---@diagnostic disable-next-line: duplicate-set-field
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
            -- rmb.currentmana = rmb.doer.replica.dotaattributes and rmb.doer.replica.dotaattributes:GetMana_Double() or 0
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

