-----------------------------------------------------------------------
--此lua写法Copy自恒子大佬的能力勋章[workshop-1909182187]
--来源 scripts/medal_globalfn.lua
-----------------------------------------------------------------------

----------------------------------------------容器拖拽-------------------------------------------
local persistentname = "dota_drag_pos" -- 数据块名称
local uiloot={}--UI列表，方便重置
--拖拽坐标，局部变量存储，减少io操作
local dragpos={}
--更新同步拖拽坐标(如果容器没打开过，那么存储的坐标信息就没被赋值到dragpos里，这时候直接去存储就会导致之前存储的数据缺失，所以要主动取一下数据存到dragpos里)
local function loadDragPos()
	TheSim:GetPersistentString(persistentname, function(load_success, data)
		if load_success and data ~= nil then
            local success, allpos = RunInSandbox(data)
		    if success and allpos and type(allpos)=="table" then
				for k, v in pairs(allpos) do
					if dragpos[k]==nil then
						dragpos[k]=Vector3(v.x or 0, v.y or 0, v.z or 0)
					end
				end
			end
		end
	end)
end
--存储拖拽后坐标
local function saveDragPos(dragtype,pos)
	if next(dragpos) then
		local str = DataDumper(dragpos, nil, true)
		TheSim:SetPersistentString(persistentname, str, false)
	end
end
--获取拖拽坐标
function GetDotaDragPos(dragtype)
	if dragpos[dragtype]==nil then
		loadDragPos()
	end
	return dragpos[dragtype]
end

--设置UI可拖拽(self,拖拽目标,拖拽标签,拖拽信息)
function MakeDotaDragableUI(self,dragtarget,dragtype,dragdata)
	self.candrag=true--可拖拽标识(防止重复添加拖拽功能)
	uiloot[self]=self:GetPosition()--存储UI默认坐标
	--给拖拽目标添加拖拽提示
	if dragtarget then
		dragtarget:SetTooltip(STRINGS.DOTA.UI_DRAG)
		local oldOnControl=dragtarget.OnControl
		dragtarget.OnControl = function (self,control, down)
			local parentwidget=self:GetParent()--控制它爹的坐标,而不是它自己
			--按下右键可拖动
			if parentwidget and parentwidget.Passive_OnControl then
				parentwidget:Passive_OnControl(control, down)
			end
			return oldOnControl and oldOnControl(self,control,down)
		end
	end
	
	--被控制(控制状态，是否按下)
	function self:Passive_OnControl(control, down)
		if self.focus and control == CONTROL_SECONDARY then
			if down then
				self:StartDrag()
			else
				self:EndDrag()
			end
		end
	end
	--设置拖拽坐标
	function self:SetDragPosition(x, y, z)
		local pos
		if type(x) == "number" then
			pos = Vector3(x, y, z)
		else
			pos = x
		end
		
		local self_scale=self:GetScale()
		local offset=dragdata and dragdata.drag_offset or 1--偏移修正(容器是0.6)
		local newpos=self.p_startpos+(pos-self.m_startpos)/(self_scale.x/offset)--修正偏移值
		self:SetPosition(newpos)--设定新坐标
	end
	
	--开始拖动
	function self:StartDrag()
		if not self.followhandler then
			local mousepos = TheInput:GetScreenPosition()
			self.m_startpos = mousepos--鼠标初始坐标
			self.p_startpos = self:GetPosition()--面板初始坐标
			self.followhandler = TheInput:AddMoveHandler(function(x,y)
				self:SetDragPosition(x,y,0)
				if not Input:IsMouseDown(MOUSEBUTTON_RIGHT) then
					self:EndDrag()
				end
			end)
			self:SetDragPosition(mousepos)
		end
	end
	
	--停止拖动
	function self:EndDrag()
		if self.followhandler then
			self.followhandler:Remove()
		end
		self.followhandler = nil
		self.m_startpos = nil
		self.p_startpos = nil
		local newpos=self:GetPosition()
		if dragtype then
			dragpos[dragtype]=newpos--记录记录拖拽后坐标
		end
		saveDragPos()--存储坐标
	end
end

--重置拖拽坐标
function ResetDotaUIPos()
	dragpos={}
	TheSim:SetPersistentString(persistentname, "", false)
	for k, v in pairs(uiloot) do
		if k.inst and k.inst:IsValid() then
			k:SetPosition(v)--重置坐标
		else
			uiloot[k]=nil--失效了的就清掉吧
		end
	end
end

GLOBAL.GetDotaDragPos=GetDotaDragPos
GLOBAL.MakeDotaDragableUI=MakeDotaDragableUI
GLOBAL.ResetDotaUIPos=ResetDotaUIPos