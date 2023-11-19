---------------------------------------- 自定义音频 ---------------------------------------------

--------------------------------------------------------------------------
--[[ DotaDynamicMusic class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ 不变量 ]]
--------------------------------------------------------------------------

local DOTA_BUTTON_MUSIC =
{
    clickon = "mengsk_dota2_sounds/ui/buttonclick",
    clickoff = "mengsk_dota2_sounds/ui/buttonrollover",
}

local DOTA_UI_MUSIC = 
{
    mana = "mengsk_dota2_sounds/ui/deny_mana",
    cd = "mengsk_dota2_sounds/ui/deny_cooldown",
    default = "mengsk_dota2_sounds/ui/ui_general_deny",
}

local THEMES = {
    CLICKON = 1,
    CLICKOFF = 2,
    MANA = 3,
    CD = 4,
    DEFAULT = 5,
}

--------------------------------------------------------------------------
--[[ 成员变量 ]]
--------------------------------------------------------------------------

-- 公共
self.inst = inst

-- 私有
local _isenabled = true
local _buttontask = nil
local _buttontheme = nil
local _extendtime = nil
local _soundemitter = nil
local _activatedplayer = nil --cached for activation/deactivation only, NOT for logic use

--------------------------------------------------------------------------
--[[ 私有函数 ]]
--------------------------------------------------------------------------

local function StopThemeMusic(inst, istimeout)
    if _buttontask ~= nil then
        if not istimeout then
            _buttontask:Cancel()
        elseif _extendtime > 0 then
            local time = GetTime()
            if time < _extendtime then
                _buttontask = inst:DoTaskInTime(_extendtime - time, StopThemeMusic, true)
                _extendtime = 0
                return
            end
        end
        _buttontask = nil
        _extendtime = 0
        _soundemitter:SetParameter("dota2", "intensity", 0)
    end
end

local function StartThemeMusic(player, theme, sound, duration, extendtime)
    -- if (_buttontheme ~= theme or _extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
    if (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _buttontask then
            _buttontask:Cancel()
            _buttontask = nil
        end
        -- if _buttontheme ~= theme then
            _soundemitter:KillSound("dota2")
            _soundemitter:PlaySound(sound, "dota2")
	        -- _buttontheme = theme
        -- end

        _soundemitter:SetParameter("dota2", "intensity", 1)
        _buttontask = inst:DoTaskInTime(duration, StopThemeMusic, true)
        _extendtime = extendtime or 0
    end
end

local function StartClickOn(player)
	StartThemeMusic(player, THEMES.CLICKON, DOTA_BUTTON_MUSIC.clickon, 5)
end

local function StartClickOff(player)
	StartThemeMusic(player, THEMES.CLICKOFF, DOTA_BUTTON_MUSIC.clickoff, 5)
end

local function StartNeedMana(player)
	StartThemeMusic(player, THEMES.MANA, DOTA_UI_MUSIC.mana, 5)
end

local function StartCoolingDown(player)
	StartThemeMusic(player, THEMES.CD, DOTA_UI_MUSIC.cd, 5)
end

local function StartGeneral(player)
	StartThemeMusic(player, THEMES.DEFAULT, DOTA_UI_MUSIC.default, 5)
end

local function StartPlayerListeners(player) 
    inst:ListenForEvent("playdotaclickonmusic", StartClickOn, player)
    inst:ListenForEvent("playdotaclickoffmusic", StartClickOff, player)
    inst:ListenForEvent("playdotamanamusic", StartNeedMana, player)
    inst:ListenForEvent("playdotacdmusic", StartCoolingDown, player)
    inst:ListenForEvent("playdotadefualtmusic", StartGeneral, player)
end

local function StopPlayerListeners(player) 
    inst:RemoveEventCallback("playdotaclickonmusic", StartClickOn, player)
    inst:RemoveEventCallback("playdotaclickoffmusic", StartClickOff, player)
    inst:RemoveEventCallback("playdotamanamusic", StartNeedMana, player)
    inst:RemoveEventCallback("playdotacdmusic", StartCoolingDown, player)
    inst:RemoveEventCallback("playdotadefualtmusic", StartGeneral, player)
end

local function StartSoundEmitter()
    if _soundemitter == nil then
        _soundemitter = TheFocalPoint.SoundEmitter
        _extendtime = 0
    end 
end

local function StopSoundEmitter()
    if _soundemitter ~= nil then
        StopThemeMusic()
        _extendtime = nil
        _soundemitter = nil
    end 
end

--------------------------------------------------------------------------
--[[ 私有事件句柄 ]]
--------------------------------------------------------------------------

local function OnPlayerActivated(inst, player)
    if _activatedplayer == player then
        return
    elseif _activatedplayer ~= nil and _activatedplayer.entity:IsValid() then
        StopPlayerListeners(_activatedplayer)
    end
    _activatedplayer = player
    StopSoundEmitter()
    StartSoundEmitter()
    StartPlayerListeners(player)
end

local function OnPlayerDeactivated(inst, player)
    StopPlayerListeners(player)
    if player == _activatedplayer then
        _activatedplayer = nil
        StopSoundEmitter()
    end
end

local function OnEnableDynamicMusic(inst, enable)
    if _isenabled ~= enable then
        if not enable and _soundemitter ~= nil then
            StopThemeMusic() 
        end
        _isenabled = enable
    end 
end

--------------------------------------------------------------------------
--[[ 初始化 ]]
--------------------------------------------------------------------------

-- 监听事件
inst:ListenForEvent("playeractivated", OnPlayerActivated)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
inst:ListenForEvent("enabledynamicmusic", OnEnableDynamicMusic)

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)