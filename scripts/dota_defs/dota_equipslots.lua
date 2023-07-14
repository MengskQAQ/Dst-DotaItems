-----------------------------------------------------------------------
-- 此lua写法出自恒子大佬的能力勋章[workshop-1909182187]
-- 来源 /scripts/medal_ui.lua
-----------------------------------------------------------------------

local Inv = require "widgets/inventorybar"
local Widget = require "widgets/widget"

-- 总所周知，dota2有11格装备，但是受能力限制，所以只做一格，用容器来代替装备栏
if GLOBAL.EQUIPSLOTS then
    GLOBAL.EQUIPSLOTS["DOTASLOT"] = "dotaslot"
else
    GLOBAL.EQUIPSLOTS=
    {
        HANDS = "hands",
        HEAD = "head",
        BODY = "body",
        DOTASLOT = "dotaslot",
    }
end

GLOBAL.EQUIPSLOT_IDS = {}
local slot = 0  --装备栏格子数量
local noslot = {    --屏蔽元素反应模组的额外装备栏，防止装备栏UI异常增长
    CIRCLET = true,	
    SANDS = true,
    GOBLET = true,
    FLOWER = true,
    PLUME = true,
}
for k, v in pairs(GLOBAL.EQUIPSLOTS) do
    slot = slot + (noslot[k] and 0 or 1)
    GLOBAL.EQUIPSLOT_IDS[v] = slot
end

AddGlobalClassPostConstruct("widgets/inventorybar", "Inv", function(self)
    local W = 68
    local SEP = 12
    local INTERSEP = 28
    local Inv_Refresh_base = Inv.Refresh or function() return "" end
    local Inv_Rebuild_base = Inv.Rebuild or function() return "" end
    
    self.dota_inv=self.root:AddChild(Widget("dota_inv"))
    self.dota_inv:SetScale(1.5, 1.5)
    
    --获取total_w
    local function getTotalW(self)
        local inventory = self.owner.replica.inventory
        local num_slots = inventory:GetNumSlots()
        local num_equip = #self.equipslotinfo
        local num_buttons = self.controller_build and 0 or 1
        local num_slotintersep = math.ceil(num_slots / 5)
        local num_equipintersep = num_buttons > 0 and 1 or 0
        local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP
        local x=(W - total_w) * .5 + num_slots * W + (num_slots - num_slotintersep) * SEP + num_slotintersep * INTERSEP
        return total_w,x
    end
    --设置装备栏位置
    local function setDotaInv(self,do_integrated_backpack)
        local total_w,x=getTotalW(self)
        local dota_inv_y = do_integrated_backpack and 80 or 40
        for k, v in ipairs(self.equipslotinfo) do
            if v.slot == EQUIPSLOTS.DOTASLOT then
                self.dota_inv:SetPosition(x, dota_inv_y, 0)
            end
            x = x + W + SEP
        end
    end
    --加载装备栏
    function Inv:LoadDotaSlots()
        self.bg:SetScale(1.3+(slot-4)*0.05,1,1.25)--根据格子数量缩放装备栏
        self.bgcover:SetScale(1.3+(slot-4)*0.05,1,1.25)

        if self.adddotaslots == nil then
            self.adddotaslots = 1

            self:AddEquipSlot(GLOBAL.EQUIPSLOTS.DOTASLOT, "images/dota_ui/dotaequip_slot.xml", "dotaequip_slot.tex")

            if self.inspectcontrol then
                local total_w,x=getTotalW(self)
                self.inspectcontrol.icon:SetPosition(-4, 6)
                self.inspectcontrol:SetPosition((total_w - W) * .5 + 3, -6, 0)
            end
        end
    end
    --刷新函数
    function Inv:Refresh()
        Inv_Refresh_base(self)
        self:LoadDotaSlots()
    end
    --构建函数
    function Inv:Rebuild()
        Inv_Rebuild_base(self)
        self:LoadDotaSlots()
        local inventory = self.owner.replica.inventory
        local overflow = inventory:GetOverflowContainer()
        overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil
        local do_integrated_backpack = overflow ~= nil and self.integrated_backpack
        setDotaInv(self,do_integrated_backpack)
    end
end)

---------------------------------------------------------------------------------------------------------
--------------------------------------------- Containers ------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- 给我们的装备容器加6个格子

local params = {}
local default_pos = Vector3(400, -280, 0)
params.dota_box = {
	widget =
	{
		slotpos = {},
		slotbg = {},
		animbank = "ui_chest_3x2",  -- TODO: 使用新素材
		animbuild = "ui_chest_3x2", -- TODO: 使用新素材
		pos = default_pos,
	},
	usespecificslotsforitems = true,--使用特定插槽
	type = "dota_box",
	excludefromcrafting = true,--里面的道具不能直接用于制作
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.dota_box.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
        table.insert(params.dota_box.widget.slotbg, { atlas="images/hud2.xml",image = "yotb_sewing_slot.tex" })   -- TODO: 使用新素材
    end
end

--检测可放入装备栏的物品
function params.dota_box.itemtestfn(container, item, slot)
	return item:HasTag("dota_equipment")
end

local containers = require "containers"
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

local containers_widgetsetup = containers.widgetsetup

function containers.widgetsetup(container, prefab, data)
    local t = data or params[prefab or container.inst.prefab]
    if t~=nil then
        for k, v in pairs(t) do
			container[k] = v
		end
		container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        return containers_widgetsetup(container, prefab, data)
    end
end

---------------------------拖拽拽拽拽拽拽拽拽拽拽拽拽拽拽拽拽拽拽拽拽拽-----------------------
if TUNING.DOTA.UI_DRAG then
	AddClassPostConstruct("widgets/containerwidget", function(self)
		local oldOpen = self.Open
		self.Open = function(self,...)
			oldOpen(self,...)
			if self.container and self.container.prefab and self.container.prefab == "dota_box"
			 and self.container.replica.container then
				local widget = self.container.replica.container:GetWidget()
				if widget then
					if not self.candrag then
						MakeDotaDragableUI(self,self.bganim,"dota_box_pos",{drag_offset=0.6})
					end
					--设置容器坐标(可装备的容器第一次打开做个延迟，不然加载游戏进来位置读不到)
					local newpos=GetDotaDragPos("dota_box_pos") or default_pos
					if newpos then
						if self.container:HasTag("_equippable") and not self.container.isopended then
							self.container:DoTaskInTime(0, function()
								self:SetPosition(newpos)
							end)
							self.container.isopended=true
						else
							self:SetPosition(newpos)
						end
                    end
				end
			end
		end
	end)
end

--------兼容show me的绿色索引，代码参考自风铃草大佬的穹妹--------
local dota_containers={--需要兼容的容器列表
	"dota_box",--装备栏
}
--如果他优先级比我高 这一段生效
for k,mod in pairs(ModManager.mods) do      --遍历已开启的mod
	if mod and mod.SHOWME_STRINGS then      --因为showme的modmain的全局变量里有 SHOWME_STRINGS 所以有这个变量的应该就是showme
		if mod.postinitfns and mod.postinitfns.PrefabPostInit and mod.postinitfns.PrefabPostInit.treasurechest then     --是的 箱子的寻物已经加上去了
			for _, v in ipairs(dota_containers) do
				mod.postinitfns.PrefabPostInit[v] = mod.postinitfns.PrefabPostInit.treasurechest
			end
		end
	end
end
--如果他优先级比我低 那下面这一段生效
TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
for _, v in ipairs(dota_containers) do
	TUNING.MONITOR_CHESTS[v] = true
end