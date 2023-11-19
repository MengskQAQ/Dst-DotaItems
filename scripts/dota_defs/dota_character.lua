------------------------------------------------------------------------
----------------- Health Compatibility / 生命兼容选项 -------------------
------------------------------------------------------------------------
-- You can change the health compatibility of the special character here
-- 你可以在此处为特定人物指定生命系统兼容性选项
local character_mode1 = {   -- 作者通过 基础值 + 附加值 的形式修改血量
    -- "xuaner", -- 璇儿
}
local character_mode2 = {   -- 作者通过 现有血量 + 附加值 的形式修改血量
    "wx78", --  机器人  -- 哈人，鱼人与机器人都拥有升级，却采用了不同的方法
}
------------------------------------------------------------------------
----------- Attributes System White List / 属性系统白名单 ---------------
------------------------------------------------------------------------
local orginal_character = {
    "wilson", -- 威尔逊
    "willow", -- 火女
    "wolfgang", -- 大力士
    "wendy", -- 温蒂
    -- "wx78", --  机器人
    "wickerbottom", --  老奶奶
    "woodie", --  吴迪
    "wes", --  韦斯
    "waxwell", --  老麦
    "wathgrithr", --  女武神
    "webber", --  韦伯
    "winona", --  女红（确信
    "warly", --  沃利
    "walter", --  沃尔特
    "wortox", -- 小恶魔 
    "wormwood", --  植物人
    "wurt", --  小鱼人
    "wanda", --  旺达
    "wonkey", --  芜猴
}
------------------------------------------------------------------------
------------------------------------------------------------------------

local HEALTH_SYSTEM = GetModConfigData("health_system")
local ATTRIBUTES_SYSTEM = GetModConfigData("attributes_system")
local BASEMANA = TUNING.DOTA.BASEMANA
local function HealthReflash(inst)
	if not inst:HasTag("playerghost") then	-- 当然了，幽灵刷新什么血量
		inst.components.dotacharacter:CalcFinalAttributes()
	end
end
local function CommonCharcterEnable(inst)
    if not inst.components.dotaattributes then
        inst:AddComponent("dotaattributes")
        inst.components.dotaattributes:SetBaseMaxMana(BASEMANA)  -- 设置基础蓝量
    end
    if not inst.components.dotacharacter then
        inst:AddComponent("dotacharacter")
    end
    if not inst.components.dotainvisible then
        inst:AddComponent("dotainvisible")
    end
    if not inst.components.dotaethereal then
        inst:AddComponent("dotaethereal")
    end
    if not inst.components.dotasharedcoolingable then
        inst:AddComponent("dotasharedcoolingable")
    end
	if inst.components.dotacharacter ~= nil then
		inst:DoTaskInTime(0.1, HealthReflash)	-- 在人物初始化0.1s后刷新一下生命值
	end

    -- 我们存一下角色tag，用于隐身状态的切换
    if not inst:HasTag("shadow") and inst.Dota_IsHasTagShadow == nil then inst.Dota_IsHasTagShadow = false end
    if not inst:HasTag("notarget") and inst.Dota_IsHasTagNotarget == nil then inst.Dota_IsHasTagNotarget = false end
    if not inst:HasTag("scarytoprey") and inst.Dota_IsHasTagScarytoprey == nil then inst.Dota_IsHasTagScarytoprey = false end
end

if HEALTH_SYSTEM then
	if #character_mode1 > 0 then
		for _, v in pairs(character_mode1) do
			AddPrefabPostInit(v, function(inst)
				if GLOBAL.TheWorld.ismastersim then
					if inst.components.health then
						inst.components.health:Dota_SetCompatibility(1)
					end
					return inst
				end
			end)
		end
	end
	if #character_mode2 > 0 then
		for _, v in pairs(character_mode2) do
			AddPrefabPostInit(v, function(inst)
				if GLOBAL.TheWorld.ismastersim then
					if inst.components.health then
						inst.components.health:Dota_SetCompatibility(2)
					end
					return inst
				end
			end)
		end
	end
end

local function DoDotaattributesInit(player)
	AddPrefabPostInit(player, function(inst)
		if not inst:HasTag("dotaattributes") then   -- 虽然组件里加了这个tag，但不知为何不生效
			inst:AddTag("dotaattributes")
		end
		if GLOBAL.TheWorld.ismastersim then
			CommonCharcterEnable(inst)
			return inst
		end
	end)
end

if ATTRIBUTES_SYSTEM == 1 then    -- 白名单制
    for k, v in pairs(orginal_character) do
		DoDotaattributesInit(v)
    end
	for k, v in pairs(character_mode1) do
		DoDotaattributesInit(v)
    end
	for k, v in pairs(character_mode2) do
		DoDotaattributesInit(v)
    end
elseif ATTRIBUTES_SYSTEM == 2 then    -- 全体
    AddPlayerPostInit(function(inst)
        if not inst:HasTag("dotaattributes") then
            inst:AddTag("dotaattributes")
        end
        if GLOBAL.TheWorld.ismastersim then
            CommonCharcterEnable(inst)
            return inst
        end
    end)
elseif ATTRIBUTES_SYSTEM == 3 then    -- 禁用系统
    AddPlayerPostInit(function(inst)
        if inst:HasTag("dotaattributes") then
            inst:RemoveTag("dotaattributes")
        end
        if GLOBAL.TheWorld.ismastersim then
            if inst.components.dotaattributes then
                inst:RemoveComponent("dotaattributes")
            end
            if inst.components.dotacharacter then
                inst:RemoveComponent("dotacharacter")		
            end
            if inst.components.dotainvisible then
                inst:RemoveComponent("dotainvisible")
            end
            return inst
        end
    end)
end

-- local function OnPlayerDied(inst, data)
--     inst:PushEvent("ms_becameghost", { corpse = true })
-- end

-- AddPlayerPostInit(function(inst)
--     if GLOBAL.TheWorld.ismastersim then
--         inst:ListenForEvent("playerdied", OnPlayerDied)
--         return inst
--     end
-- end)
