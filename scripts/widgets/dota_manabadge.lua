local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Text = require('widgets/text')
local Widget = require "widgets/widget"
local Image = require "widgets/image"

local Dota_Mana_Badge = Class(Widget, function(self, owner, art)
    Widget._ctor(self, "dota_manabadge", owner)

    self.root = self:AddChild(Widget("ROOT"))   -- 设置一个父级方便统一管理
	self.owner = owner
    self.defpos = nil

    if self.modenable == nil then   
		self.modenable = false  -- 如果开启三维mod，就让此值为true
	end
    
    -- 主体动画
	self.anim = self.root:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("dota_manabadge")
	self.anim:GetAnimState():SetBuild("dota_manabadge")
	self.anim:GetAnimState():PlayAnimation("anim")

    -- 显示最大魔法值
    self.maxnum = self.root:AddChild(Text(NUMBERFONT, 25))
	self.maxnum:SetPosition(6, 0, 0)
	self.maxnum:MoveToFront()
	self.maxnum:Hide()

    -- 显示当前魔法值
    self.num = self.root:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetPosition(3, 0, 0)
    self.num:Hide()

    -- self.num背景板
	self.bg = self.root:AddChild(Image("images/dota_ui/status_bgs.xml", "status_bgs.tex"))
	self.bg:SetScale(0.55, .43, 0)
	self.bg:SetPosition(-.5, -40, 0)
    self.bg:Hide()

    -- self.root:SetTooltip(STRINGS.DOTA.UI_DRAG)
    -- local oldOnControl=self.root.OnControl
    -- self.root.OnControl = function (self,control, down)
    --     local parentwidget=self:GetParent()
    --     if parentwidget and parentwidget.Passive_OnControl then
    --         parentwidget:Passive_OnControl(control, down)
    --     end
    --     return oldOnControl and oldOnControl(self,control,down)
    -- end

	self:StartUpdating()

    if self.candrag == nil then
        self.candrag=true
    end

    -------------------------------拖拽拽拽拽拽拽拽拽拽---------------------------------
    if TUNING.DOTA.UI_DRAG then
        MakeDotaDragableUI(self,self.root,"dota_manabadge_pos",{drag_offset=0.8})
        local defpos = GetDotaDragPos("dota_manabadge_pos")
        if defpos then
            self.defpos = defpos
            self:SetPosition(defpos)
        end
    end
    ------------------------------------------------------------------------------------

end)

function Dota_Mana_Badge:SetPercent(val, max)
	val = val or self.percent
    max = max or 100

    if self.circular_meter ~= nil then
        self.circular_meter:GetAnimState():SetPercent("meter", val)
    else
        self.anim:GetAnimState():SetPercent("anim", val)
        if self.circleframe ~= nil and not self.dont_animate_circleframe then
            self.circleframe:GetAnimState():SetPercent("frame", val)
        end
    end

    --print(val, max, val * max)
    self.num:SetString(tostring(math.ceil(val * max)))
    self.maxnum:SetString("Max:\n".. tostring(math.ceil(max or 100)))
    self.percent = val
end

function Dota_Mana_Badge:OnUpdate(dt)
	local dotaattributes = self.owner.replica.dotaattributes
	if dotaattributes then
		local mana = math.floor(dotaattributes:GetMana()) or 100 
		local maxmana = math.floor(dotaattributes:GetMaxMana()) or 100
		self:SetPercent(mana/maxmana, maxmana)
	end
end

function Dota_Mana_Badge:OnGainFocus()
    Badge._base.OnGainFocus(self)
    if self.modenable then
        self.maxnum:Show()
    else
        self.num:Show()
    end
end

function Dota_Mana_Badge:OnLoseFocus()
    Badge._base.OnLoseFocus(self)
    if self.modenable then
        self.maxnum:Hide()
        self.num:Show()
    else
        self.num:Hide()
    end
end

-- 模拟三维Mod，不知道为什么三维Mod不能自动适配，只能伪装一下有三维Mod的效果
function Dota_Mana_Badge:SetModEnable(val, pos) 
    self.modenable = val
    if self.modenable then
        self.num:SetFont(NUMBERFONT)
        self.num:SetSize(30)
        self.num:SetPosition(2, -40.5, 0)
        self.num:SetScale(1,.78,1)
        self.num:MoveToFront()
        self.num:Show()
        self.bg:Show() -- 显示背景板
        self:SetScale(0.9)
    elseif not self.modenable then
        -- self.num:SetHAlign(ANCHOR_MIDDLE)
        self.num:SetPosition(3, 0, 0)
        self.bg:Hide() -- 隐藏背景板
        self:SetScale(1)
    end
    if pos ~= nil and not self.defpos then
        self:SetPosition(pos)
    end
end

function Dota_Mana_Badge:IsModEnable() 
    return self.modenable
end

return Dota_Mana_Badge