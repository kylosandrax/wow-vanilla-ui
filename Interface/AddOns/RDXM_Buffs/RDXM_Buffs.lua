-- RDXM_Buffs.lua
-- RDX5 - Buff Module
-- (C)2005 Bill Johnson (Venificus of Eredar server)
--
-- Management for automated buffing tasks.
-- 
if not RDXM.Buffs then RDXM.Buffs = {}; end

------------------
-- WINDOW
------------------
if not RDXM.BuffWindow then RDXM.BuffWindow = {}; end
RDXM.BuffWindow.__index = RDXM.BuffWindow;

function RDXM.BuffWindow:new()
	local self = {};
	setmetatable(self, RDXM.BuffWindow);
	-- Setup window
	RDX.Window.MakeContainer(self, 3);
	-- Setup titlebar
	local tc = RDXG.vis.cBuffWindowTitle;
	getglobal(self.window:GetName().."TitleBkg"):SetGradient("HORIZONTAL",tc.r,tc.g,tc.b,0,0,0);
	-- Return!@#%
	return self;
end

-- Destroy all resources associated to the window
function RDXM.BuffWindow:Destroy()
	self:Hide();
	RDX.windowPool:Release(self.window); self.window = nil;
	self.grid = nil; self.fnAcquireCell = nil;
end

-- Hide the window
function RDXM.BuffWindow:Hide()
	self:StopMoving();
	self.window:Hide();
	self.grid:Destroy();
end

-- Show the window
function RDXM.BuffWindow:Show()
	self.window:Show();
	self.window:SetFrameLevel(1);
end

-- Setup the window's content
function RDXM.BuffWindow:Setup()
	-- Destroy any current content
	self:Hide();
	-- Set grid dimensions
	self.grid:SetColumnPadding(0); self.grid:SetRowPadding(0);
	self.grid:SetDefaultColumnWidth(82); self.grid:SetDefaultRowHeight(14);
end

function RDXM.BuffWindow:SetupAssignment(a)
	-- Destroy any current content
	self:Hide();
	-- Set grid dimensions
	self.grid:SetColumnPadding(0); self.grid:SetRowPadding(0);
	self.grid:SetDefaultColumnWidth(50); self.grid:SetDefaultRowHeight(14);
	-- Set buff icon/name in title
	self.window.icon:SetTexture(a.assignment:GetTexture());
	self.window.text:SetText("Assignment: " .. a.assignment.name);
	if(a.filterConfig) then self:FilterOn(); else self:FilterOff(); end
	self.window.btnFilter.OnClick = function() a:Filter(); end
	self.window.btnClose.OnClick = function() RDXM.Buffs.CloseWindowByReference(a); end
	self.window.btnI.OnMouseDown = function()
		if(arg1 == "LeftButton") and (IsShiftKeyDown()) then
			self:StartMoving();
		end
	end
	self.window.btnI.OnMouseUp = function()
		self:StopMoving();
	end
end

function RDXM.BuffWindow:SetupWatch(w)
	-- Destroy any current content
	self:Hide();
	-- Set grid dimensions
	self.grid:SetColumnPadding(0); self.grid:SetRowPadding(0);
	self.grid:SetDefaultColumnWidth(50); self.grid:SetDefaultRowHeight(14);
	-- Set watch bufflist in title
	local str = "";
	for b,_ in w.buffs do str = str .. "[" .. RDX.GetEffectByID(b).name .. "] ";  end
	self.window.text:SetText("Watch: " .. str);
	self.window.icon:Hide();
	self.window.btnI.OnMouseDown = function()
		if(arg1 == "LeftButton") and (IsShiftKeyDown()) then
			self:StartMoving();
		end
	end
	self.window.btnI.OnMouseUp = function()
		if(arg1 == "RightButton") then
			w:ShowConfigDialog(function() w:ConfigChanged(); end);
		else
			self:StopMoving();
		end
	end
	if(w.filterConfig) then self:FilterOn(); else self:FilterOff(); end
	self.window.btnFilter.OnClick = function() w:Filter(); end
	self.window.btnClose.OnClick = function() RDXM.Buffs.CloseWindowByReference(w); end
end

-- Utility functions
function RDXM.BuffWindow:FilterOn()
	self.window.btnFilter:LockHighlight();
end
function RDXM.BuffWindow:FilterOff()
	self.window.btnFilter:UnlockHighlight();
end
function RDXM.BuffWindow:StartMoving()
	if not self.moving then
		self.moving = true;
		RDXBuffAnchor:StartMoving();
	end
end
function RDXM.BuffWindow:StopMoving()
	if self.moving then
		RDXM.Buffs.Save();
	end
	RDXBuffAnchor:StopMovingOrSizing();
	self.moving = nil;
end

-- Assignment sort function generating function
-- Primary sort by whether or not the unit has the buff in question.. units who don't come first.
-- Secondary sort by buff time... stale data comes last
function RDXM.Buffs.GenAssignmentSortFunc(eid)
	return function(u1,u2)
		local u1v,u2v = 0,0;
		-- Linkdead = dead last
		if (not u1:IsOnline()) then u1v=u1v+100000000; end
		if (not u2:IsOnline()) then u2v=u2v+100000000; end
		-- Having buff = medium last
		if u1:HasEffect(eid) then u1v=u1v+10000000; end
		if u2:HasEffect(eid) then u2v=u2v+10000000; end
		-- OOR = farther down
		if (not u1:IsInDataRange()) then u1v=u1v+1000000; end
		if (not u2:IsInDataRange()) then u2v=u2v+1000000; end
		-- Otherwise, alpha order
		if(u1.name < u2.name) then u1v = u1v + 10000; else u2v = u2v + 10000; end
		-- BUGFIX: Remove timers.
		-- If unit is stale, it comes last in sort
--		if u1:EffectTimersStale() then u1v=u1v+100000; end
--		if u2:EffectTimersStale() then u1v=u1v+100000; end
		-- Otherwise, sort by time.
--		u1v=u1v+u1:EffectTime(eid,20000); u2v=u2v+u2:EffectTime(eid,20000);
		return u1v < u2v;
	end;
end

-- Assignment fnApplyData generating function
function RDXM.Buffs.GenAssignmentFnApplyData(eid)
	-- BUGFIX: References to timers removed
	local ldr, ldg, ldb = RDXG.vis.cLinkdead.r, RDXG.vis.cLinkdead.g, RDXG.vis.cLinkdead.b;
	local sdr, sdg, sdb = RDXG.vis.cStaleData.r, RDXG.vis.cStaleData.g, RDXG.vis.cStaleData.b;
	return function(u,c)
		local hasBuff = u:HasEffect(eid);
		c:SetPurpose(5); -- Two text, no % bar
		-- Pri text = name, sec text = timer
		c.text1:SetText(u:GetProperName()); c.text2:SetText("");
		if not u:IsOnline() then
			c.text1:SetTextColor(ldr, ldg, ldb); c.text2:SetText("");
		elseif not hasBuff then
			c.text1:SetTextColor(0.7, 0.4, 0); c.text2:SetText("");
		else
			c.text1:SetTextColor(1,1,1); c.text2:SetTextColor(0,1,0); c.text2:SetText("--");
		end
		-- Onclick handling
		c.OnClick = function(self, arg)
			RDXM.Buffs.Buff(u, eid);
		end
	end
end

------------------
-- ASSIGNMENT
------------------
if not RDXM.BuffAssignment then RDXM.BuffAssignment = {}; end
RDXM.BuffAssignment.__index = RDXM.BuffAssignment;

function RDXM.BuffAssignment:new(eid)
	local self = {};
	setmetatable(self, RDXM.BuffAssignment);
	-- Setup buff array
	self.assignment = RDX.GetEffectByID(eid); self.eid = eid;
	-- Setup window
	self.dbw = nil;
	-- Internal set
	self.units = {};
	-- Internal functions
	self.sortFunc = RDXM.Buffs.GenAssignmentSortFunc(eid);
	self.fnApplyData = RDXM.Buffs.GenAssignmentFnApplyData(eid);
	self.filterFunc = VFL.True;
	self.filterConfig = nil;
	-- Update manager
	RDX.ManagerImbue(self);
	return self;
end

-- Destroy all contents
function RDXM.BuffAssignment:Destroy()
	VFL.debug("RDXM.BuffAssignment:Destroy()", 4);
	self:UnbindEvents();
	if(self.dbw) then self.dbw:Destroy(); self.dbw = nil; end
	self.units = nil; self.sortFunc = nil; self.fnApplyData = nil;
	self.filterConfig = nil; self.filterFunc = nil;
end

-- Save/load configuration from tables
function RDXM.BuffAssignment:Save(targ)
	targ.assignment = true;
	targ.eid = self.eid;
	targ.filterConfig = VFL.copy(self.filterConfig);
end
function RDXM.BuffAssignment.Load(targ)
	if (not targ.assignment) or (not targ.eid) then return; end
	local self = RDXM.BuffAssignment:new(targ.eid);
	if targ.filterConfig then
		self.filterConfig = VFL.copy(targ.filterConfig);
		self:RebuildInternalFunctions();
	else
		self.filterConfig = nil;
		self.filterFunc = VFL.True;
	end
	return self;
end

-- Set filter
function RDXM.BuffAssignment:Filter()
	-- If filter's enabled, disable
	if self.filterConfig then
		self.filterConfig = nil;
		self:RebuildInternalFunctions();
		self:TriggerUpdate(3);
	else
		self.tmpFilterConfig = {};
		RDX.tempfd:SetConfig(self.tmpFilterConfig);
		RDX.tempfd:SetDefaults();
		RDX.tempfd:ShowConfigDialog(function() self:FilterChanged(); end);
	end
end
function RDXM.BuffAssignment:FilterChanged()
	self.filterConfig = self.tmpFilterConfig;
	self.tmpFilterConfig = nil;
	self:RebuildInternalFunctions();
	self:TriggerUpdate(3);
	RDXM.Buffs.Save();
end
function RDXM.BuffAssignment:RebuildInternalFunctions()
	if self.filterConfig then
		RDX.tempfd:SetConfig(self.filterConfig);
		self.filterFunc = RDX.MakeFilterFromDescriptor(RDX.tempfd);
		if(self.dbw) then self.dbw:FilterOn(); end
	else
		self.filterFunc = VFL.True;
		if(self.dbw) then self.dbw:FilterOff(); end
	end
end

-- Determine if the unit "needs" the given buff.
-- The unit must be online and synchronized.
-- If the unit has the buff, his timers must be synced and his timer must be below the "isLow" timer
-- for the effect.
function RDXM.BuffAssignment:UnitNeeds(u)
	if not u:IsSynced() then return false; end
	if u:HasEffect(self.eid) then
		-- BUGFIX: Disregard effect timers
--		if(u:EffectTime(self.eid, 1000000) > self.assignment:GetLowTimer()) then
			return false;
--		end
	end
	return true;
end

-- Find limited layout truncation.
-- This is the point at which a non-"showall" assignment window should be
-- truncated. In other words, it is the first person in the unit list who
-- has the buff and timer exceeds the threshold.
function RDXM.BuffAssignment:FindLimitedTruncation()
	local i = 1;
	while true do
		local u = self.units[i];
		if (not u) then break; end
		if (not self:UnitNeeds(u)) then break; end
		i=i+1;
	end
	VFL.debug("RDXM.BA:FindLimitedTruncation(): i is " .. i, 9);
	return i-1;
end

---------- UPDATES/STAGING
-- Rebuild the underlying unit set.
function RDXM.BuffAssignment:RebuildStage()
	self.units = {};
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if u:IsValid() and self.filterFunc(u) then
			table.insert(self.units, u);
		end
	end
end

-- Sort the underlying unit array.
function RDXM.BuffAssignment:SortStage()
	table.sort(self.units, self.sortFunc);
end

-- Layout stage.
-- If "show all" is set, just show everyone, otherwise truncate to the
-- first person whose time exists and exceeds the threshold.
function RDXM.BuffAssignment:LayoutStage()
	-- Determine how many debuffs we need to show
	local trunc = table.getn(self.units);
	if RDXM.Buffs.cfg.trunc then trunc = math.min(trunc, RDXM.Buffs.cfg.trunc); end
	if not RDXM.Buffs.cfg.showAll then
		trunc = math.min(trunc, self:FindLimitedTruncation());
	end
	self.ndisp = trunc;
	-- Determine if we need to show/hide our window
	if (not self.dbw) then
		if(trunc > 0) or (not RDXM.Buffs.cfg.hideEmpty) then
			self.dbw = RDXM.BuffWindow:new();
			self.dbw:SetupAssignment(self);
			self.dbw:Show();
			RDXM.Buffs.UpdateLayout();
		end
	elseif (self.dbw) and (trunc == 0) and (RDXM.Buffs.cfg.hideEmpty) then
		self.dbw:Destroy();
		self.dbw = nil;
		RDXM.Buffs.UpdateLayout();
	end
	if self.dbw then
		RDX.LayoutRDXWindow(self.dbw, trunc, 0, 3, trunc, self.dbw.fnAcquireCell);
	end
end

-- Paint stage
function RDXM.BuffAssignment:PaintStage()
	-- If our debuff window is open, repaint it.
	if self.dbw then
		RDX.PaintRDXWindow(self.dbw, self.units, 0, self.ndisp, self.fnApplyData);
	end
end

-- Master updating
function RDXM.BuffAssignment:Update()
	if self.updateLevel == 3 then
		self:RebuildStage(); self:SortStage(); self:LayoutStage(); self:PaintStage();
	elseif self.updateLevel == 2 then
		self:SortStage(); self:LayoutStage(); self:PaintStage();
	elseif self.updateLevel == 1 then
		self:PaintStage();
	end
	self.updateLevel = 0;
end

-------------- IMPULSE HANDLING
-- Handle dirty aura mux
function RDXM.BuffAssignment:OnAuraMuxDirty(eid, set)
	-- If the effect being updated is not pertinent to this assignment, return
	if(eid ~= self.eid) then return; end
	-- Level 2 update
	self:TriggerUpdate(2);
end

-- Handle group compo change
function RDXM.BuffAssignment:OnRaidGroupChanged()
	-- Full rebuild
	self:TriggerUpdate(3);
end

-- Handle timer change
function RDXM.BuffAssignment:OnEffectTimersUpdated(unit)
	if not unit.fxTimers[self.eid] then return; end
	-- Regrettably, we need to resort...
	self:TriggerUpdate(2);
end

-- Event binding
function RDXM.BuffAssignment:BindEvents()
	self:UnbindEvents();
	RDX.SigUnitIdentitiesChanged:Connect(self, self.OnRaidGroupChanged);
	RDX.SigRaidRosterMoved:Connect(self, self.OnRaidGroupChanged);
	RDX.SigMuxFlagsDirty[4]:Connect(self, self.OnAuraMuxDirty);
	-- BUGFIX: Removal of buff timers
  -- RDX.SigUnitEffectTimersUpdated:Connect(self, self.OnEffectTimersUpdated);
end
function RDXM.BuffAssignment:UnbindEvents()
	RDX.SigUnitIdentitiesChanged:DisconnectObject(self);
	RDX.SigRaidRosterMoved:DisconnectObject(self);
	RDX.SigMuxFlagsDirty[4]:DisconnectObject(self);
	-- BUGFIX: Removal of buff timers
	-- RDX.SigUnitEffectTimersUpdated:DisconnectObject(self);
end

----------------------------------------------
-- WATCH
----------------------------------------------
if not RDXM.BuffWatch then RDXM.BuffWatch = {}; end
RDXM.BuffWatch.__index = RDXM.BuffWatch;

function RDXM.BuffWatch:new()
	local self = {};
	setmetatable(self, RDXM.BuffWatch);
	-- Setup buff array
	self.buffs = {};
	-- Setup window
	self.dbw = nil;
	-- Internal set
	self.set = RDX.Set:new();
	-- Internal functions
	self.filterConfig = nil;
	self.filterFunc = VFL.True;
	self.dataType = 1;
	self.swizzle = RDXM.Buffs.UnitMissingAny;
	-- Update manager
	RDX.ManagerImbue(self);
	return self;
end

-- Destroy all contents
function RDXM.BuffWatch:Destroy()
	VFL.debug("RDXM.BuffWatch:Destroy()", 4);
	self:UnbindEvents();
	if(self.dbw) then self.dbw:Destroy(); self.dbw = nil; end
	self.buffs = nil; self.set = nil; self.filterConfig = nil;
	self.filterFunc = nil; self.swizzle = nil;
end

-- Save/load configuration from tables
function RDXM.BuffWatch:Save(targ)
	targ.watch = true; targ.dataType = self.dataType;
	targ.buffs = VFL.copy(self.buffs);
	targ.filterConfig = VFL.copy(self.filterConfig);
end
function RDXM.BuffWatch.Load(targ)
	if (not targ.watch) then return; end
	local self = RDXM.BuffWatch:new();
	self.dataType = targ.dataType; 
	self.buffs = VFL.copy(targ.buffs);
	if targ.filterConfig then
		self.filterConfig = VFL.copy(targ.filterConfig);
	else
		self.filterConfig = nil;
		self.filterFunc = VFL.True;
	end
	self:RebuildInternalFunctions();
	return self;
end

------ CONFIG 
-- 1 = missing any 2 = missing all 3 = has any 4 = has all
function RDXM.BuffWatch:ShowConfigDialog(okCB, cancelCB)
	local dlg,dn,ctl = RDXBuffWatchConfig, "RDXBuffWatchConfig", nil;
	dlg:Show();
	----------- Populate show option
	ctl = getglobal(dn.."ShowHaveMissing");
	if(self.dataType == 1) or (self.dataType == 2) then ctl:SetText("are missing"); else ctl:SetText("have"); end
	ctl = getglobal(dn.."ShowAllAny");
	if(self.dataType == 1) or (self.dataType == 3) then ctl:SetText("any of"); else ctl:SetText("all of"); end
	----------- Populate lists
	ctl = getglobal(dn.."SelectedList");
	ctl.list.data = {};
	-- Selected
	for k,v in self.buffs do
		local fx = RDX.GetEffectByID(k);
		table.insert(ctl.list.data, { id = fx.id, text = fx.name, icon = fx:GetTexture() });
	end
	ctl.list:UpdateContent();
	-- Onclick: a click on the selected list should move the item to the unselected list
	local otherList = getglobal(dn.."UnselectedList").list;
	local thisList = ctl.list;
	ctl.list.OnClick = function(self, cell, arg)
		local _,n = self:VirtualPos(cell);
		table.insert(otherList.data, thisList.data[n]);
		table.remove(thisList.data, n);
		otherList:UpdateContent(); thisList:UpdateContent();
	end
	-- Populate UNSELECTED list
	ctl = getglobal(dn.."UnselectedList");
	ctl.list.data = {};
	for k,fx in RDX.fx do
		if not self.buffs[k] then
			table.insert(ctl.list.data, { id = fx.id, text = fx.name, icon = fx:GetTexture() });
		end
	end
	ctl.list:UpdateContent();
	-- Onclick: a click on the selected list should move the item to the unselected list
	local otherList = getglobal(dn.."SelectedList").list;
	local thisList = ctl.list;
	ctl.list.OnClick = function(self, cell, arg)
		local _,n = self:VirtualPos(cell);
		table.insert(otherList.data, thisList.data[n]);
		table.remove(thisList.data, n);
		otherList:UpdateContent(); thisList:UpdateContent();
	end
	-------------------- OK/Cancel
	getglobal(dn.."Cancel").OnClick = function()
		dlg:Hide(); if(cancelCB) then cancelCB(self); end
	end
	getglobal(dn.."OK").OnClick = function()
		self:ReadConfigDialog(); dlg:Hide(); if(okCB) then okCB(self); end
	end
end

function RDXM.BuffWatch:ReadConfigDialog()
	local dlg,dn,ctl = RDXBuffWatchConfig, "RDXBuffWatchConfig", nil;
	------ Show options
	ctl = getglobal(dn.."ShowAllAny");
	if(getglobal(dn.."ShowHaveMissing"):GetText() == "are missing") then
		if(ctl:GetText() == "any of") then self.dataType = 1; else self.dataType = 2; end
	else
		if(ctl:GetText() == "any of") then self.dataType = 3; else self.dataType = 4; end
	end
	----- Bufflist
	ctl = getglobal(dn.."SelectedList");
	self.buffs = {};
	for _,v in ctl.list.data do
		self.buffs[v.id] = true;
	end
end

-- Swizzle functions
function RDXM.Buffs.UnitHasAny(u, buffs)
	for k,v in buffs do
		if u:HasEffect(k) then return true; end
	end
	return false;
end
function RDXM.Buffs.UnitHasAll(u, buffs)
	for k,v in buffs do
		if not u:HasEffect(k) then return false; end
	end
	return true;
end
function RDXM.Buffs.UnitMissingAny(u, buffs)
	return not RDXM.Buffs.UnitHasAll(u, buffs);
end
function RDXM.Buffs.UnitMissingAll(u, buffs)
	return not RDXM.Buffs.UnitHasAny(u, buffs);
end

-- Build filter and swizzle
-- Set filter
function RDXM.BuffWatch:Filter()
	-- If filter's enabled, disable
	if self.filterConfig then
		self.filterConfig = nil;
		self.filterFunc = VFL.True;
		if(self.dbw) then self.dbw:FilterOff(); end
		self:TriggerUpdate(2);
	else
		self.tmpFilterConfig = {};
		RDX.tempfd:SetConfig(self.tmpFilterConfig);
		RDX.tempfd:SetDefaults();
		RDX.tempfd:ShowConfigDialog(function() self:FilterChanged(); end);
	end
end
function RDXM.BuffWatch:FilterChanged()
	self.filterConfig = self.tmpFilterConfig;
	self.tmpFilterConfig = nil;
	self:RebuildInternalFunctions();
	self:TriggerUpdate(2);
	RDXM.Buffs.Save();
end
function RDXM.BuffWatch:RebuildInternalFunctions()
	if self.filterConfig then
		RDX.tempfd:SetConfig(self.filterConfig);
		self.filterFunc = RDX.MakeFilterFromDescriptor(RDX.tempfd);
		if(self.dbw) then self.dbw:FilterOn(); end
	else
		self.filterFunc = VFL.True;
		if(self.dbw) then self.dbw:FilterOff(); end
	end
	-- missingany missingall hasany hasall
	if(self.dataType == 1) then 
		self.swizzle = RDXM.Buffs.UnitMissingAny;
	elseif(self.dataType == 2) then
		self.swizzle = RDXM.Buffs.UnitMissingAll;
	elseif(self.dataType == 3) then
		self.swizzle = RDXM.Buffs.UnitHasAny;
	else
		self.swizzle = RDXM.Buffs.UnitHasAll;
	end
end

-- On config change...
function RDXM.BuffWatch:ConfigChanged()
	if self.dbw then
		self.dbw:Destroy();
		self.dbw = nil;
	end
	self:RebuildInternalFunctions();
	self:TriggerUpdate(2);
	RDXM.Buffs.Save();
end

---------------- STAGING
-- Completely rebuild the set
function RDXM.BuffWatch:RebuildStage()
	self.set:RemoveAllMembers();
	local m = self.set.members;
	-- For each unit in the raid
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		m[i] = nil;
		-- If it's valid and matches the filters, and has the buffs, add it to the set
		if (u:IsValid()) and (u:IsOnline()) and (self.filterFunc(u)) and (self.swizzle(u, self.buffs)) then
			m[i] = true;
		end
	end
	-- Recount the number of members
	self.set:Recount();
end

-- Layout the window
function RDXM.BuffWatch:LayoutStage()
	-- Determine how many debuffs we need to show
	local n = self.set:GetSize();
	if RDXM.Buffs.cfg.trunc then n = math.min(n, RDXM.Buffs.cfg.trunc); end
	-- Determine if we need to show/hide our window
	if (not self.dbw) then
		if(n > 0) or (not RDXM.Buffs.cfg.hideEmpty) then
			self.dbw = RDXM.BuffWindow:new();
			self.dbw:SetupWatch(self);
			self.dbw:Show();
			RDXM.Buffs.UpdateLayout();
		end
	elseif (n == 0) and (RDXM.Buffs.cfg.hideEmpty) then
		self.dbw:Destroy();
		self.dbw = nil;
		RDXM.Buffs.UpdateLayout();
	end
	if self.dbw then
		RDX.LayoutRDXWindow(self.dbw, n, 0, 3, n, self.dbw.fnAcquireCell);
	end
end

-- Paint the window.
function RDXM.BuffWatch:PaintStage()
	if self.dbw then
		RDX.PaintRDXWindowFromSet(self.dbw, self.set, 0, self.dbw.displayed, RDX.Windows.ApplyDataNameOnly);
	end
end

-- Master updating
function RDXM.BuffWatch:Update()
	VFL.debug("RDXM.BuffWatch:Update("..self.updateLevel..")", 10);
	if self.updateLevel == 2 then
		self:RebuildStage(); self:LayoutStage(); self:PaintStage();
	elseif self.updateLevel == 1 then
		self:PaintStage();
	end
	self.updateLevel = 0;
end

-------------- IMPULSE HANDLING
-- Handle dirty aura mux
function RDXM.BuffWatch:OnAuraMuxDirty(eid, set)
	-- If the effect being updated is not pertinent to this assignment, return
	if not self.buffs[eid] then return; end
	-- Level 2 update
	self:TriggerUpdate(2);
end

-- Handle group compo change
function RDXM.BuffWatch:OnRaidGroupChanged()
	-- Full rebuild
	self:TriggerUpdate(2);
end

-- Event binding
function RDXM.BuffWatch:BindEvents()
	self:UnbindEvents();
	RDX.SigUnitIdentitiesChanged:Connect(self, RDXM.BuffWatch.OnRaidGroupChanged);
	RDX.SigRaidRosterMoved:Connect(self, RDXM.BuffWatch.OnRaidGroupChanged);
	RDX.SigMuxFlagsDirty[4]:Connect(self, RDXM.BuffWatch.OnAuraMuxDirty);
end
function RDXM.BuffWatch:UnbindEvents()
	RDX.SigUnitIdentitiesChanged:DisconnectObject(self);
	RDX.SigRaidRosterMoved:DisconnectObject(self);
	RDX.SigMuxFlagsDirty[4]:DisconnectObject(self);
end



---------------
-- DRIVER
-- Maintain a list of active windows
-- Each entry in the active windows list is of the form (desc, config, dirty)
-- Move the config data in/out of per-enc storage.
---------------
-- Active windows list
RDXM.Buffs.active_windows = {};

-- Destroy all active windows
function RDXM.Buffs.DestroyAllWindows()
	for _,w in RDXM.Buffs.active_windows do
		w.desc:Destroy();
		w.desc = nil;
	end
	RDXM.Buffs.active_windows = {};
end

-- Restore windows from encounter settings.
function RDXM.Buffs:LoadEncounter(enc)
	VFL.debug("RDXM.Buffs.LoadEncounter("..enc..")", 2);
	RDXM.Buffs.DestroyAllWindows();
	local cfg = {};
	RDX.MapUEMPrefs(enc, "buffs", cfg);
	-- Empty config table, do nothing
	if not cfg.x then return; end
	-- Restore positioning
	VFL.debug("-- Restoring buff positioning x " .. cfg.x .. " y " .. cfg.y, 8);
	RDXBuffAnchor:ClearAllPoints();
	RDXBuffAnchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", cfg.x, cfg.y);
	-- Restore windows
	for _,wc in cfg.wcs do
		local wd = nil;
		if wc.watch then
			wd = RDXM.BuffWatch.Load(wc);
		elseif wc.assignment then
			wd = RDXM.BuffAssignment.Load(wc);
		end
		if wd then
			table.insert(RDXM.Buffs.active_windows, {desc = wd});
			wd:BindEvents();
			if(wc.watch) then wd:TriggerUpdate(2); else wd:TriggerUpdate(3); end
		end
	end
end
function RDXM.Buffs.Load()
	VFL.debug("RDXM.Buffs.Load()", 3);
	RDXM.Buffs.DestroyAllWindows();
	RDXM.Buffs:LoadEncounter(RDX.GetVirtualEncounter());
end

-- Save window settings to the given encoutner
function RDXM.Buffs:SaveEncounter(enc)
	VFL.debug("RDXM.Buffs.SaveEncounter("..enc..")", 2);
	local cfg = {};
	cfg.x = RDXBuffAnchor:GetLeft(); cfg.y = RDXBuffAnchor:GetTop();
	cfg.wcs = {};
	for _,w in RDXM.Buffs.active_windows do
		local ct = {};
		w.desc:Save(ct);
		table.insert(cfg.wcs, ct);
	end
	RDX.SaveUEMPrefs(enc, "buffs", cfg);
end
function RDXM.Buffs.Save()
	VFL.debug("RDXM.Buffs.Save()", 3);
	RDXM.Buffs:SaveEncounter(RDX.GetVirtualEncounter());
end

-- Update the layout of the windows on screen
function RDXM.Buffs.UpdateLayout()
	VFL.debug("RDXM.Buffs.UpdateLayout()", 9);
	local n = table.getn(RDXM.Buffs.active_windows);
	local starti,endi,diri,hold,holdPoint,grab,grabPoint = 1,n,1,RDXBuffAnchor,"BOTTOMLEFT",nil,"TOPLEFT";
	if reverse then 
		starti = table.getn(RDXM.Buffs.active_windows); endi = 1;
		diri = -1; 
		holdPoint="TOPLEFT"; grabPoint="BOTTOMLEFT";
	end
	-- For each window, do...
	for i=starti,endi,diri do
		-- Figure out which window will be "grabbing"
		grab = RDXM.Buffs.active_windows[i].desc.dbw;
		-- If it exists...
		if grab then
			-- Grab it
			grab.window:SetPoint(grabPoint, hold, holdPoint);
			-- And it becomes the new anchor.
			hold = grab.window;
		end
	end
end

-- Add a buff assignment, by effect ID.
function RDXM.Buffs.AddAssignment(eid)
	-- No more than 10 buff windows
	if table.getn(RDXM.Buffs.active_windows) > 9 then return false; end
	-- Create this window's data table
	local t = {};
	t.desc = RDXM.BuffAssignment:new(eid);
	-- Push into the beginning of the active windows
	table.insert(RDXM.Buffs.active_windows, 1, t);
	-- Cause an update.
	t.desc:TriggerUpdate(3);
	-- Connect us to events
	t.desc:BindEvents();
	-- Save prefs
	RDXM.Buffs.Save();
end

-- Add a watch. The config dialog for the watch is displayed before adding it.
function RDXM.Buffs.AddWatch()
	local w = RDXM.BuffWatch:new();
	w:ShowConfigDialog(RDXM.Buffs.AddWatchCallback);
end
function RDXM.Buffs.AddWatchCallback(w)
	local t = {};
	t.desc = w;
	table.insert(RDXM.Buffs.active_windows, t);
	t.desc:BindEvents();
	t.desc:ConfigChanged();
end

-- Close a window.
function RDXM.Buffs.CloseWindowByReference(wr)
	local wt,targ = RDXM.Buffs.active_windows,nil;
	-- Attempt to locate the destroyed window
	for i=1,table.getn(wt) do
		if (wt[i].desc == wr) then targ = i; break; end
	end
	-- If we found it, do the deed.
	if targ then
		local wd = table.remove(wt, targ);
		wd.desc:Destroy();
		RDXM.Buffs.UpdateLayout();
		RDXM.Buffs.Save();
	end
end

-----------------------------------
-- SMARTCASTING
-----------------------------------
-- Buff blacklist. Keys are of the form name|eid
RDXM.Buffs.bl = {};

-- Attempt to buff the given unit with the given effect.
function RDXM.Buffs.Buff(unit, eid)
	VFL.debug("RDXM.Buffs.Buff("..unit.name..","..eid..")", 10);
	-- Honor global block on autocasting
	if RDXM.Buffs.blockAutoCast then 
		VFL.debug("RDXM.Buffs.Buff: blockAutoCast enabled, aborting.", 4);
		return false; 
	end
	-- If target is blacklisted, return false
	local blkey = unit.name .. "|" .. eid;
	if RDX.CheckBlacklist(RDXM.Buffs.bl, blkey) then 
		VFL.debug("RDXM.Buffs.Buff(): " .. unit.name .. " blacklisted, aborting", 10);
		return false; 
	end
	-- Get the effect we're trying to produce
	local fx = RDX.GetEffectByID(eid);
	-- Make sure we have a spell that can produce the effect
	local sp,splist,gv = fx:GetCachedSpell(),nil,nil;
	if not sp then
		VFL.debug("RDXM.Buffs.Buff: could not find spell for effect id " .. eid, 7);
		return;
	end
	-- See if we can upgrade to a group version
	if (RDXM.Buffs.cfg.useGroupVersions) and (fx:GetGroupVersionSpell()) then
		splist = RDXM.Buffs.GetGroupMembersWithout(unit, eid);
		
		-- Paladins are special.  They always want to cast the group version.
		if UnitClass("player") == "Paladin" then
			RDXM.Buffs.GroupBuffCallback(true, unit, eid, sp, fx:GetGroupVersionSpell(), splist);
			return;
		end
		
		-- For everyone else...
		if (splist) and (table.getn(splist) > 1) then
			local prompt = "The following people in " .. unit:GetProperName() .. "'s group need " .. fx.name .. ": ";
			for _,u in splist do
				prompt = prompt .. u:GetProperName() .. " ";
			end
			prompt = prompt .. "|nDo you wish to cast the group version?";
			-- Prompt the user.
			VFL.CC.Popup(function(tf) RDXM.Buffs.GroupBuffCallback(tf, unit, eid, sp, fx:GetGroupVersionSpell(), splist); end,
				"Group Cast", prompt);
			-- Abort out
			return;
		end
	end
	-- Try for single target buff
	return RDXM.Buffs.CastBuff(sp, unit, eid);
end

-- Callback for group buffing dialog
function RDXM.Buffs.GroupBuffCallback(flg, unit, eid, spS, spG, targs)
	if flg then -- Grp vers
		RDXM.Buffs.CastBuff(spG, unit, eid, targs);
	else -- Single target
		RDXM.Buffs.CastBuff(spS, unit, eid);
	end
end

-- Cast the given spell on the given unit. Blacklist the given targets.
function RDXM.Buffs.CastBuff(sp, unit, eid, targs)
	-- If unit is LoS blacklisted, abort.
	if RDX.CheckBlacklist(RDX.losbl, unit.name) then return false; end
	-- Attempt the cast
	VFL.debug("RDXM.Buffs.CastBuff: casting " .. sp.title .. " on " .. unit.name, 10);
	local rt = RDX.Target(unit);
	RDXM.Buffs.blockAutoCast = true;
	local ret = RDX.GuardedCast(sp, function(flg, reason) 
		if flg then -- good cast
			RDXM.Buffs.SuccessfulCast(unit,eid,targs);
			RDX.Retarget(rt);
		else -- failed cast
			RDXM.Buffs.blockAutoCast = nil;
			if(reason == 2) or (reason == 3) then
				RDX.Blacklist(RDX.losbl, unit.name, 5);
			end
		end
	end);
	if not ret then 
		VFL.debug("RDXM.Buffs.CastBuff(): RDX.GuardedCast failed", 10);
		RDXM.Buffs.blockAutoCast = nil; 
	end
	return ret;
end

-- Helper function: reset a unit's timer predictively for a given buff
function RDXM.Buffs.PredictiveTiming(unit, eid)
	if (not unit.fxTimers) or (not unit.fxTimers[eid]) then return; end
	if (not RDX.fx[eid].duration) then return; end
	unit.fxTimers[eid] = RDX.fx[eid].duration;
	RDX.SigUnitEffectTimersUpdated:Raise(unit);
end

-- If a buff is successfully cast, blacklist the relevant people.
function RDXM.Buffs.SuccessfulCast(unit, eid, targs)
	-- Remove global block
	RDXM.Buffs.blockAutoCast = nil;
	-- Blacklist all targets
	if targs then
		for _,u in targs do
			-- Reset unit effect timers and blacklist em
			RDXM.Buffs.PredictiveTiming(u, eid);
			RDX.Blacklist(RDXM.Buffs.bl, u.name .. "|" .. eid, 30); 
		end
	else
		RDXM.Buffs.PredictiveTiming(unit, eid);
		RDX.Blacklist(RDXM.Buffs.bl, unit.name .. "|" .. eid, 30);
	end
end

-- Count the number of people in a group that need a buff
function RDXM.Buffs.GetGroupMembersWithout(unit, eid)
	local gn = unit.group;
	if(not gn) or (gn == 0) then return nil; end
	local ret = {};
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if (u:IsValid()) and (u.group == gn) and (not u:HasEffect(eid)) then
			table.insert(ret, u);
		end
	end
	return ret;
end

-- Automatically find someone in the raid party that needs buffed and buff them!
function RDXM.Buffs.Autobuff()
	VFL.debug("RDXM.Buffs.Autobuff()", 10);
	-- For each assignment...
	for _,w in RDXM.Buffs.active_windows do if w.desc.assignment then
		local wd = w.desc;
		-- Foreach person affected by the assignment...
		if wd.units then for _,u in ipairs(wd.units) do
			-- If that person actually needs the buff...
			if wd:UnitNeeds(u) then
				-- Try to cast it, if not blacklisted, success!
				if RDXM.Buffs.Buff(u, wd.eid) then
					return;
				end
			end
		end end -- for _,u in assg.units
	end end -- for _,w in assg
	VFL.debug("RDXM.Buffs.Autobuff(): buff cycle completed with no valid targets.", 4);
end


-----------------------------
-- BUFF MODULE CONFIG AND METADATA
-----------------------------
-- Master config for buffs module
function RDXM.Buffs.ShowConfigDialog(okCB, cancelCB)
	local dlg,dn,ctl,cfg = RDXBuffsConfig, "RDXBuffsConfig", nil, RDXM.Buffs.cfg;
	dlg:Show();
	-- Hide option
	getglobal(dn.."Hide"):Set(cfg.hideEmpty);
	-- Show all option
	getglobal(dn.."ShowAll"):Set(cfg.showAll);
	-- Autoupgrade to group buff option
	getglobal(dn.."AutoGroup"):Set(cfg.useGroupVersions);
	-- Truncation
	if(cfg.trunc) then		
		getglobal(dn.."Truncate"):Set(true);
		getglobal(dn.."TruncateNum"):SetText(cfg.trunc);
	else
		getglobal(dn.."Truncate"):Set(nil);
		getglobal(dn.."TruncateNum"):SetText("");
	end
	-- OK/cancel
	getglobal(dn.."Cancel").OnClick = function() 
		VFL.Escape();
		if(cancelCB) then cancelCallback(); end
	end
	getglobal(dn.."OK").OnClick = function()
		RDXM.Buffs.ReadConfigDialog();
		VFL.Escape();
		if(okCB) then okCallback(); end
	end
	-- Setup escape handler
	VFL.AddEscapeHandler(function() dlg:Hide(); end);
end

function RDXM.Buffs.ReadConfigDialog()
	local dlg,dn,ctl,cfg = RDXBuffsConfig, "RDXBuffsConfig", nil, RDXM.Buffs.cfg;
	cfg.hideEmpty = getglobal(dn.."Hide"):Get();
	cfg.showAll = getglobal(dn.."ShowAll"):Get();
	cfg.useGroupVersions = getglobal(dn.."AutoGroup"):Get();
	if(getglobal(dn.."Truncate"):Get()) then
		cfg.trunc = getglobal(dn.."TruncateNum"):GetNumber();
	else
		cfg.trunc = nil;
	end
	-- Save prefs to RDX config.
	RDX.SaveUMPrefs("buffs", RDXM.Buffs.cfg);
	-- Instruct a full UI rebuild
	RDXM.Buffs.Load();
end

---------------
-- MENU
---------------
function RDXM.Buffs:Menu(tree, frame)
	local mnu = {};
	-- Enumerate all possible buffs
	for k,v in RDX.possfx do if v then
		local fx = RDX.GetEffectByID(k);
		table.insert(mnu, {
			text = fx.name;
			texture = fx:GetTexture();
			OnClick = function() RDXM.Buffs.AddAssignment(fx.id); tree:Release(); end
		});
	end end
	-- "Watch" option
	table.insert(mnu, {
		text="Watch...";
		OnClick = function() RDXM.Buffs.AddWatch(); tree:Release(); end
	});
	-- Configuration
	table.insert(mnu, {
		text = "Options...",
		OnClick = function() RDXM.Buffs.ShowConfigDialog(); tree:Release(); end
	});
	-- Display menu
	tree:Expand(frame, mnu);
end

--------------
-- INIT AND MODULE REGISTRATION
--------------
function RDXM.Buffs.Init()
	VFL.debug("RDXM.Buffs.Init()", 2);
	-- Load preferences
	RDXM.Buffs.cfg = {};
	RDX.MapUMPrefs("buffs", RDXM.Buffs.cfg);
	
	-- AUTOBUFF SLASH COMMAND
	SLASH_RDXBUFF1 = "/rdxbuff";
	SlashCmdList["RDXBUFF"] = function() RDXM.Buffs.Autobuff(); end
end

-- Move buff anchor frame to screen center
function RDXM.Buffs.ResetUI()
	-- Reset buff anchor to center; clear config.
	RDXM.Buffs.cfg.x = nil; RDXM.Buffs.cfg.y = nil;
	RDXBuffAnchor:ClearAllPoints();
	RDXBuffAnchor:SetPoint("TOPLEFT", UIParent, "CENTER");
	-- Save config.
	RDXM.Buffs.Save();
end

RDXM.Buffs.module = RDX.RegisterModule({
	name="buffs";
	title="Buffs";
	Menu = RDXM.Buffs.Menu;
	DeferredInit = RDXM.Buffs.Init;
	LoadEncounter = RDXM.Buffs.LoadEncounter;
	SaveCurrentEncounter = RDXM.Buffs.Save;
	ResetUI = RDXM.Buffs.ResetUI;
});
