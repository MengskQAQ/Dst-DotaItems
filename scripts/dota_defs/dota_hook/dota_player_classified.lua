---------------------------------------- 自定义音频 ---------------------------------------------

-- local function OnPlayThemeMusic(parent, data)
-- 	if data ~= nil then
-- 		if data.theme == "dotaclickon" then
-- 			parent.player_classified.start_dota_clickon_music:push()
--         elseif data.theme == "dotaclickoff" then
--             parent.player_classified.start_dota_clickoff_music:push()
-- 		end
-- 	end
-- end
local function OnPlayDotaClickOnMusic_Mana(parent)
    parent.player_classified.start_dota_clickon_music:push()
end
local function OnPlayDotaClickOffMusic_Mana(parent)
    parent.player_classified.start_dota_clickoff_music:push()
end
local function OnPlayDotaThemeMusic_Mana(parent)
    parent.player_classified.start_dota_mana_music:push()
end
local function OnPlayDotaThemeMusic_CD(parent)
    parent.player_classified.start_dota_cd_music:push()
end
local function OnPlayDotaThemeMusic_General(parent)
    parent.player_classified.start_dota_default_music:push()
end


local function StartDotaClickOnMusicEvent(inst)
	inst._parent:PushEvent("playdotaclickonmusic")
end
local function StartDotaClickOffMusicEvent(inst)
	inst._parent:PushEvent("playdotaclickoffmusic")
end
local function StartDotaManaMusicEvent(inst)
	inst._parent:PushEvent("playdotamanamusic")
end
local function StartDotaCDMusicEvent(inst)
	inst._parent:PushEvent("playdotacdmusic")
end
local function StartDotaDefaultMusicEvent(inst)
	inst._parent:PushEvent("playdotadefualtmusic")
end

local function RegisterNetListeners(inst)
    if TheWorld.ismastersim then
        inst._parent = inst.entity:GetParent()  -- 为何这个是必须的？
        -- inst:ListenForEvent("play_theme_music", OnPlayThemeMusic, inst._parent)
        inst:ListenForEvent("dotaevent_theme_clickon", OnPlayDotaClickOnMusic_Mana, inst._parent)
        inst:ListenForEvent("dotaevent_theme_clickoff", OnPlayDotaClickOffMusic_Mana, inst._parent)
        inst:ListenForEvent("dotaevent_theme_mana", OnPlayDotaThemeMusic_Mana, inst._parent)
        inst:ListenForEvent("dotaevent_theme_cd", OnPlayDotaThemeMusic_CD, inst._parent)
        inst:ListenForEvent("dotaevent_theme_default", OnPlayDotaThemeMusic_General, inst._parent)
    end
    inst:ListenForEvent("startdotaclickonmusicevent", StartDotaClickOnMusicEvent)
    inst:ListenForEvent("startdotaclickoffmusicevent", StartDotaClickOffMusicEvent)
    inst:ListenForEvent("startdotamanamusicevent", StartDotaManaMusicEvent)
    inst:ListenForEvent("startdotacdmusicevent", StartDotaCDMusicEvent)
    inst:ListenForEvent("startdotadefaultmusicevent", StartDotaDefaultMusicEvent)
end

-- AddClassPostConstruct("prefabs/player_classified", function(inst)

--     inst.start_dota_clickon_music = net_event(inst.GUID, "startdotaclickonmusicevent")
--     inst.start_dota_clickoff_music = net_event(inst.GUID, "startdotaclickoffmusicevent")
--     inst.start_dota_mana_music = net_event(inst.GUID, "startdotamanamusicevent")
--     inst.start_dota_cd_music = net_event(inst.GUID, "startdotacdmusicevent")
--     inst.start_dota_default_music = net_event(inst.GUID, "startdotadefaultmusicevent")

--     inst:DoStaticTaskInTime(0, RegisterNetListeners)

-- end)

AddPrefabPostInit("player_classified", function(inst)
    inst.start_dota_clickon_music = net_event(inst.GUID, "startdotaclickonmusicevent")
    inst.start_dota_clickoff_music = net_event(inst.GUID, "startdotaclickoffmusicevent")
    inst.start_dota_mana_music = net_event(inst.GUID, "startdotamanamusicevent")
    inst.start_dota_cd_music = net_event(inst.GUID, "startdotacdmusicevent")
    inst.start_dota_default_music = net_event(inst.GUID, "startdotadefaultmusicevent")

    inst:DoStaticTaskInTime(0, RegisterNetListeners)
end)