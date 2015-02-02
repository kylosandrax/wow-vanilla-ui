-- Debuffs.lua 
-- RDX5 - Raid Data Exchange
-- Debuff Module
-- (C)2005 Venificus of Eredar server
--
-- UI code for displaying and interacting with raid debuffs.
--
-- Two styles: 
-- "Slice by player" = One big list of players with debuff icons
-- "Slice by debuff" = A bunch of windows, one for each debuff
--
VFL.debug("[RDXM_Debuffs] Loading RDXM_Debuffs.lua", 2);

if not RDXM.Debuffs then RDXM.Debuffs = {}; end

------------------------------------------------------------
-- DebuffSmallList
-- Respond to AuraMuxDirty for appropriate debuffs.
-- Respond by rebuilding internal set and redrawing window.
------------------------------------------------------------
if not RDXM.DebuffSmallList then RDXM.DebuffSmallList = {}; end
RDXM.DebuffSmallList.__index = RDXM.DebuffSmallList;
function RDXM.DebuffSmallList:new()
	local self = {};
	setmetatable(self, RDXM.DebuffSmallList);
	-- Is this object visible?
	self.visible = false;
	-- Catchall sense
	self.catchall = false; self.debuffs = {}; self.set = RDX.Set:new();
	-- Catch-one sense
	self.debuff = nil;
	-- The window
	RDX.Window.MakeContainer(self, 2);
	-- Mouse controls
	self.window.btnI.OnMouseDown = function()
		if(arg1 == "LeftButton") and (IsShiftKeyDown()) then
			RDXM.Debuffs.WindowStartMoving();
		end
	end
	self.window.btnI.OnMouseUp = function()
		if(arg1 == "LeftButton") then
			RDXM.Debuffs.WindowStopMoving();
		elseif(arg1 == "RightButton") then
			RDXM.Debuffs.EncShowConfigDialog();
		end
	end
	-- The update manager
	RDX.ManagerImbue(self);
	return self;
end

------------------------------ ADMINISTRIVIA
-- Generalized setup
function RDXM.DebuffSmallList:Setup()
	-- Destroy any current content
	self:Hide();
	-- Set grid dimensions
	self.grid:SetColumnPadding(0); self.grid:SetRowPadding(0);
	self.grid:SetDefaultColumnWidth(67); self.grid:SetDefaultRowHeight(14);
end

-- Setup as catchall
function RDXM.DebuffSmallList:SetCatchAll()
	self:Setup();
	self.catchall = true; self.debuffs = {}; self.set:RemoveAllMembers();
	self.debuff = nil;
	self.window.text:SetText("Other Debuffs");
	local color = RDXG.vis.cDT["other"];
	getglobal(self.window:GetName().."TitleBkg"):SetGradient("HORIZONTAL", color.r, color.g, color.b, 0, 0, 0);
end

-- Setup as debuff (from metadata)
function RDXM.DebuffSmallList:SetDebuff(meta)
	self:Setup();
	VFL.debug("RDXM.DebuffWindow:SetDebuff(" .. meta.name .. ")", 9);
	self.catchall = false; self.debuff = meta.name;
	-- Setup window title and icon
	self.window.text:SetText(meta.text1);
	local color = RDXG.vis.cDT["other"];
	if meta.dt then color = RDXG.vis.cDT[meta.dt]; end
	getglobal(self.window:GetName().."TitleBkg"):SetGradient("HORIZONTAL", color.r, color.g, color.b, 0, 0, 0);
	self.window.icon:SetTexture(meta.texture);
	self.window.btnI.OnEnter = function()
		RDX.ShowAuraTooltip(meta, self.window, "CENTER");
	end
	self.window.btnI.OnLeave = function()
		GameTooltip:Hide();
	end
end

-- Get the priority of the underlying debuff. (Catchalls automatically have priority 0)
function RDXM.DebuffSmallList:GetPriority()
	if(self.catchall) then return 0; end
	return RDXM.Debuffs.GetDebuffPrio(self.debuff.name);
end

-- Destroy all contents 
function RDXM.DebuffSmallList:Destroy()
	self.visible = false;
	RDXM.Debuffs.WindowStopMoving();
	self:UnbindEvents();
	RDX.Window.DestroyContainer(self);
	self.debuffs = nil; self.set = nil;
end

-- Show the window
function RDXM.DebuffSmallList:Show()
	self.visible = true;
	self.window:Show(); self.window:SetFrameLevel(1);
end

-- Hide the window.
function RDXM.DebuffSmallList:Hide()
	RDXM.Debuffs.WindowStopMoving(); -- Bugfix: stop moving when we hide stuff.
	self.visible = false;
	self.grid:Destroy(); self.window:Hide();
end

-- Apply data function
function RDXM.DebuffSmallList.ApplyData(u,c)
	c:SetPurpose(4);
	c.text1:SetText(u:GetProperName()); c.text1:SetTextColor(1,1,1);
	c.OnClick = function()
		if not RDXM.Debuffs.CureUnit(u) then TargetUnit(u.uid); end
	end
end

---------------------------- STAGING
-- Rebuild catchall set
function RDXM.DebuffSmallList:RebuildStage()
	-- If we're not a catchall, abort this shizizzle
	if not self.catchall then return; end
	-- Empty set and rebuild from scratch
	self.set:RemoveAllMembers();
	local m = self.set.members;
	local debuffs = RDX.AllDebuffs();
	for debuff,v in self.debuffs do if v then
		if debuffs[debuff] then
			for unit,value in debuffs[debuff].members do if value then
				m[unit] = true;
			end end
		end
	end end
	-- Recount set
	self.set:Recount();
	-- If the count is 0, hide this window
	if (self.set:GetSize() == 0) then
		self:Hide();
	else
		self:Show();
	end
end

-- Layout phase
function RDXM.DebuffSmallList:LayoutStage()
	if self.visible then
		local set = nil;
		-- If catchall, point at selfbuilt set, otherwise point at appropriate RDX mux set
		if self.catchall then set = self.set; else set = (RDX.AllDebuffs())[self.debuff]; end
		local n = set:GetSize();
		RDX.LayoutRDXWindow(self, n, 0, 4, n, self.fnAcquireCell);
	end
end

-- Paint phase
function RDXM.DebuffSmallList:PaintStage()
	if self.visible then
		local set = nil;
		if self.catchall then set = self.set; else set = (RDX.AllDebuffs())[self.debuff]; end
		RDX.PaintRDXWindowFromSet(self, set, 0, self.displayed, RDXM.DebuffSmallList.ApplyData);
	end
end

-- Master update
function RDXM.DebuffSmallList:Update()
	VFL.debug("RDXM.DebuffSmallList:Update("..self.updateLevel..")", 10);
	if self.updateLevel == 3 then
		self:RebuildStage(); self:LayoutStage(); self:PaintStage();
	elseif self.updateLevel == 2 then
		self:LayoutStage(); self:PaintStage();
	elseif self.updateLevel == 1 then
		self:PaintStage();
	end
	self.updateLevel = 0;
end

---------------------------- EVENTS
-- Aura mux
function RDXM.DebuffSmallList:OnAuraMuxDirty(debuff, set)
	if not self.catchall then
		-- If it's not a catchall, and it's our debuff, repaint us from the set.
		if(debuff == self.debuff) then self:TriggerUpdate(2); end
		return;
	end
end

-- Raidgroup change
function RDXM.DebuffSmallList:OnRaidGroupChanged()
	-- Full rebuild
	self:TriggerUpdate(3);
end

-- Event binding
function RDXM.DebuffSmallList:BindEvents()
	self:UnbindEvents();
--	RDX.SigUnitIdentitiesChanged:Connect(self, self.OnRaidGroupChanged);
--	RDX.SigRaidRosterMoved:Connect(self, self.OnRaidGroupChanged);
	if not self.catchall then RDX.SigMuxFlagsDirty[1]:Connect(self, self.OnAuraMuxDirty); end
end
function RDXM.DebuffSmallList:UnbindEvents()
--	RDX.SigUnitIdentitiesChanged:DisconnectObject(self);
--	RDX.SigRaidRosterMoved:DisconnectObject(self);
	RDX.SigMuxFlagsDirty[1]:DisconnectObject(self);
end

------------------------------------------------------------
-- DebuffBigList
-- Basic concepts:
-- Each unit has a "priority"
-- The BDL (big debuff list) is a list (unit, debuffs, prio)
-- Also a map directly into the entries
-- Sorted by prio each time
------------------------------------------------------------
if not RDXM.DebuffBigList then RDXM.DebuffBigList = {}; end
RDXM.DebuffBigList.__index = RDXM.DebuffBigList;
function RDXM.DebuffBigList:new()
	local self = {};
	setmetatable(self, RDXM.DebuffBigList);
	-- Visibility
	self.visible = false;
	-- Internal tables.
	-- Two indices on the data; one ordered by prio, the other ordered by raid unit #
	self.list = {}; self.itbl = {};
	-- The master debuff filter function
	self.filterFunc = VFL.True;
	self.prioFilterFunc = VFL.Nil;
	-- The "big debuff list" window
	RDX.Window.MakeContainer(self, 5);
	self.window.btnFilter.OnClick = function() self:Filter(); end
	self.window.btnI.OnMouseDown = function()
		if(arg1 == "LeftButton") and (IsShiftKeyDown()) then
			RDXM.Debuffs.WindowStartMoving();
		end
	end
	self.window.btnI.OnMouseUp = function()
		if(arg1 == "LeftButton") then
			RDXM.Debuffs.WindowStopMoving();
		elseif(arg1 == "RightButton") then
			RDXM.Debuffs.EncShowConfigDialog();
		end
	end
	-- The update manager
	RDX.ManagerImbue(self);
	return self;
end

------------------------------ ADMINISTRIVIA
-- Generalized setup
function RDXM.DebuffBigList:Setup()
	-- Destroy any current content
	self:Hide();
	-- Set grid dimensions
	self.grid:SetColumnPadding(0); self.grid:SetRowPadding(0);
	self.grid:SetDefaultColumnWidth(100); self.grid:SetDefaultRowHeight(14);
	-- Set window params
	self.window.text:SetText("Debuffs");
	local color = RDXG.vis.cDT["other"];
	getglobal(self.window:GetName().."TitleBkg"):SetGradient("HORIZONTAL", color.r, color.g, color.b, 0, 0, 0);
end

-- Show the window
function RDXM.DebuffBigList:Show()
	self.visible = true;
	self.window:Show(); self.window:SetFrameLevel(1);
	self:TriggerUpdate(1);
end

-- Hide the window.
function RDXM.DebuffBigList:Hide()
	RDXM.Debuffs.WindowStopMoving(); -- BUGFIX: Stop moving things when we hide stuff
	self.grid:Destroy(); self.window:Hide();
	self.visible = false;
end

-- Filtration
function RDXM.DebuffBigList:Filter()
	-- Filter keys off encounter config
	local cfg = RDXM.Debuffs.ecfg;
	if cfg.filterConfig then
		cfg.filterConfig = nil;
		self:ConfigChanged();
		self:TriggerUpdate(3);
		RDXM.Debuffs.Save();
	else
		self.tmpFilterConfig = {};
		RDX.tempfd:SetConfig(self.tmpFilterConfig);
		RDX.tempfd:SetDefaults();
		RDX.tempfd:ShowConfigDialog(function() self:FilterChanged(); end);
	end
end
function RDXM.DebuffBigList:FilterChanged()
	local cfg = RDXM.Debuffs.ecfg;
	cfg.filterConfig = self.tmpFilterConfig; self.tmpFilterConfig = nil;
	self:ConfigChanged();
	self:TriggerUpdate(3);
	-- Save config.
	RDXM.Debuffs.Save();
end

-- Config change notification.
function RDXM.DebuffBigList:ConfigChanged()
	local cfg = RDXM.Debuffs.ecfg;
	-- Filter
	if cfg.filterConfig then
		RDX.tempfd:SetConfig(cfg.filterConfig);
		self.filterFunc = RDX.MakeFilterFromDescriptor(RDX.tempfd);
		self.window:FilterOn();
	else
		self.filterFunc = VFL.True;
		self.window:FilterOff();
	end
	-- Prio filter
	if cfg.prioFilterConfig then
		RDX.tempfd:SetConfig(cfg.prioFilterConfig);
		self.prioFilterFunc = RDX.MakeFilterFromDescriptor(RDX.tempfd);
	else
		self.prioFilterFunc = VFL.Nil;
	end
end

------------------- STAGING
-- Rebuild the "big list" from scratch
function RDXM.DebuffBigList:RebuildStage()
	self.list = {};
	self.itbl = {};
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if u:IsValid() then
			local data = { unit = u; prio = -1; };
			self.list[i] = data; self.itbl[i] = data;
			self:UpdateUnitData(data);
		end
	end
end

-- Update a unit's value on the "big list"
function RDXM.DebuffBigList:UpdateUnitData(ud)
	local u = ud.unit;
	if not self.filterFunc(u) then
		ud.prio = -1; ud.debuffs = nil; ud.curable = nil; return;
	end
	local score,db,curable = 0, {}, nil;
	-- Figure out which debuffs this guy has that are relevant.
	-- Debuffs get a bonus according to their priority; curable debuffs get double bonus.
	for k,v in u.flagsets[1].flags do if v.value then
		-- Make sure the debuff has metadata
		local meta = RDX.GetDebuffMetadata(k);
		local dprio = RDXM.Debuffs.GetDebuffPrio(k, meta);
		local lcprio = 0;
		if meta and (dprio > 0) then
			-- Store curable priority -- we want the highest priority debuff to be cured,
			-- so use that to determine the cure type
			if (meta.curable) and (dprio >= lcprio) then 
				curable = meta.dt; lcprio = dprio;
			end
			-- Add the debuff priority to the score
			score = score + dprio;
			table.insert(db, meta);
		end
	end end
	-- Priority bonus if the prio filter function matches
	if(score > 0) and (self.prioFilterFunc(u)) then
		score = score + 1;
	end
	-- Set everything
	ud.prio = score;
	if(score > 0) then 
		ud.debuffs = db; ud.curable = curable;
	else 
		ud.debuffs = nil; ud.curable = nil;
	end
end

-- Sort the big list
function RDXM.DebuffBigList:SortStage()
	table.sort(self.list, function(le1,le2) return (le1.prio > le2.prio); end);
end

-- Find the first deprioritized entry in the sorted list
function RDXM.DebuffBigList:FindFirstDeprioritized()
	local i=1;
	while true do
		local le = self.list[i];
		if(not le) then break; end
		if(le.prio <= 0) then break; end
		i=i+1;
	end
	return i-1;
end

-- Layout phase
function RDXM.DebuffBigList:LayoutStage()
	-- Only do this crap if the window is visible
	if self.visible then
		-- Find the first "deprioritized" entry -- that's where we cut it off
		local trunc = self:FindFirstDeprioritized();
		RDX.LayoutRDXWindow(self, trunc, 0, 2, trunc, self.fnAcquireCell);
	end
end

-- Paint phase
function RDXM.DebuffBigList:PaintStage()
	if self.visible then
		RDX.PaintRDXWindow(self, self.list, 0, self.displayed, RDXM.DebuffBigList.ApplyData);
	end
end

-- Master updater (three-stage)
function RDXM.DebuffBigList:Update()
	VFL.debug("RDXM.DebuffBigList:Update("..self.updateLevel..")", 10);
	if self.updateLevel == 3 then
		self:RebuildStage(); self:SortStage(); self:LayoutStage(); self:PaintStage();
	elseif self.updateLevel == 2 then
		self:SortStage(); self:LayoutStage(); self:PaintStage();
	elseif self.updateLevel == 1 then
		self:LayoutStage(); self:PaintStage();
	end
	self.updateLevel = 0;
end

---------------------------- EVENTS
-- Unit aura dirty
function RDXM.DebuffBigList:OnUnitAuraDirty(unit)
	-- Get unit number
	local n = unit.nid;
	-- Find that unit number in our index
	local data = self.itbl[n]
	-- Update its paired data
	if data then
		self:UpdateUnitData(data);
		self:TriggerUpdate(2);
	end
end

-- Raidgroup change
function RDXM.DebuffBigList:OnRaidGroupChanged()
	-- Full rebuild
	self:TriggerUpdate(3);
end

-- Event binding
function RDXM.DebuffBigList:BindEvents()
	self:UnbindEvents();
	RDX.SigUnitIdentitiesChanged:Connect(self, self.OnRaidGroupChanged);
	RDX.SigRaidRosterMoved:Connect(self, self.OnRaidGroupChanged);
	RDX.SigUnitFlagsDirty[1]:Connect(self, self.OnUnitAuraDirty);
end
function RDXM.DebuffBigList:UnbindEvents()
	RDX.SigUnitIdentitiesChanged:DisconnectObject(self);
	RDX.SigRaidRosterMoved:DisconnectObject(self);
	RDX.SigUnitFlagsDirty[1]:DisconnectObject(self);
end

-- Big list data application function
function RDXM.DebuffBigList.ApplyData(d, c)
	-- d is of the form (unit, debuffMetaList, curable)
	local u = d.unit;
	c:SetPurpose(3);
	c.text1:SetText(u:GetProperName()); c.text1:SetTextColor(1,1,1);
	-- Apply debuffs to icons
	for i=1,4 do
		local meta = d.debuffs[i];
		if meta then
			c.icon[i]:SetMeta(meta);
			c.icon[i]:Show();
		else
			c.icon[i]:Hide();
		end
	end
	-- Onclick cure
	c.OnClick = function()
		if not RDXM.Debuffs.CureUnit(u) then TargetUnit(u.uid); end
	end
end

------------------------------------------------------------
-- SMALL LIST DRIVER
-- Two cases:
-- 1) The "big list" is visible. This thing handles itself.
-- 2) The "big list" is not visible. THen we must:
--    - Get active debuffs and their priorities
--    - Sort this list
--    - Deallocate any small windows not needed
-----------------------------------------------------------
if not RDXM.DebuffDriver then RDXM.DebuffDriver = {}; end
RDXM.DebuffDriver.__index = RDXM.DebuffDriver;

function RDXM.DebuffDriver:new()
	local self = {};
	setmetatable(self, RDXM.DebuffDriver);
	-- Are we visible?
	self.visible = false;
	-- The catchall window
	self.ca = RDXM.DebuffSmallList:new();
	self.ca:SetCatchAll();
	-- Windows
	self.windowsMax = 5;
	-- Update manager
	RDX.ManagerImbue(self);
	return self;
end

-- Hide the separate lists
function RDXM.DebuffDriver:Hide()
	self:UnbindEvents();
	self.visible = false;
	RDXM.Debuffs.WindowStopMoving(); -- BUGFIX: Stop moving windows when we hide stuff.
	local debuffs = RDX.AllDebuffs();
	for k,v in debuffs do
		self:DestroyAssociatedWindow(k,v);
	end
	self.ca:Hide();
end

-- Show the separate lists
function RDXM.DebuffDriver:Show()
	self.visible = true;
	self:BindEvents();
	self:TriggerUpdate(2);
end

-- Release a window
function RDXM.DebuffDriver:ReleaseWindow(window)
	window:Destroy();
end

-- Acquire a window
function RDXM.DebuffDriver:AcquireWindow(meta)
	local w = RDXM.DebuffSmallList:new();
	w:SetDebuff(meta);
	w:Show();
	w:BindEvents();
	w:TriggerUpdate(3);
	return w;
end

-- Destroys the window associated with a given debuff
function RDXM.DebuffDriver:DestroyAssociatedWindow(debuff, set)
	if set.dm_window then
		self:ReleaseWindow(set.dm_window);
		set.dm_window = nil;
	elseif set.dm_ca then
		self.ca.debuffs[debuff] = nil;
		set.dm_ca = nil;
	end
end

-- Driver rebuild stage
function RDXM.DebuffDriver:RebuildStage()
	if not self.visible then return; end
	VFL.debug("RDXM.DebuffDriver:RebuildStage("..self.updateLevel..")", 10);
	local debuffs = RDX.AllDebuffs();
	-------------------- PHASE 1: FIGURE OUR SHIT OUT
	-- Empty prios table
	local prios = {};
	local edirty = false;
	-- Iterate over all debuffs
	for debuff,set in debuffs do
		-- If emptiness isn't dirty, we don't need to worry
		if set:IsEmptinessDirty() then
			edirty = true;
		end
		-- If the set is empty...
		if set:IsEmpty() then
			self:DestroyAssociatedWindow(debuff,set);
		else
			local meta = RDX.GetDebuffMetadata(debuff);
			local prio = RDXM.Debuffs.GetDebuffPrio(debuff, meta);
			-- If the debuff is deprioritized, cease displaying it
			if(prio <= 0) then
				self:DestroyAssociatedWindow(debuff, set);
			-- The debuff is prioritized, add it to the priotbl
			else
				table.insert(prios, {set = set, meta = meta, prio = prio});
			end
		end
	end -- for
	-- If emptiness wasn't dirty, rest is wholly unnecessary
	if (not edirty) and (self.updateLevel < 2) then return; end
	-- Sort the prios table by priority. Higher prio debuffs come first
	table.sort(prios, function(x1,x2) return (x1.prio > x2.prio); end);
	-------------------- PHASE 2: RECLAIM TRASH
	-- Any buff beyond the priority limit gets its window quashed.
	for i=1,table.getn(prios) do
		if(i > self.windowsMax) then
			local meta,set = prios[i].meta, prios[i].set;
			-- Remove from independent window pool
			if set.dm_window then self:ReleaseWindow(set.dm_window); set.dm_window = nil; end
			-- Assign to catchall
			set.dm_ca = true; self.ca.debuffs[meta.name] = true;
		end
	end
	-------------------- PHASE 3: ALLOCATION AND ANCHORING
	local af = RDXDebuffAnchor;
	for i=1,self.windowsMax do if prios[i] then
		local meta,set = prios[i].meta, prios[i].set;
		-- If the set didn't have a window associated...
		if not set.dm_window then
			-- If the set was in the catchall, annihilate it
			if set.dm_ca then
				set.dm_ca = nil; self.ca.debuffs[meta.name] = nil;
			end
			-- Let's acquire one!
			set.dm_window = self:AcquireWindow(meta);
		end
		VFL.debug("-- Anchoring " .. set.dm_window.window:GetName() .. " to " .. af:GetName(), 10);
		set.dm_window.window:SetPoint("TOPLEFT", af, "BOTTOMLEFT");
		af = set.dm_window.window;
	end end -- For i do if prios[i]
	self.ca.window:SetPoint("TOPLEFT", af, "BOTTOMLEFT");
end

-- Driver paint stage
function RDXM.DebuffDriver:PaintStage()
	if not self.visible then return; end
	self.ca:TriggerUpdate(3);
end

-- Driver master update
function RDXM.DebuffDriver:Update()
	self:RebuildStage(); self:PaintStage();
end

--------------------- EVENTS
-- Aura mux update trips global update
function RDXM.DebuffDriver:OnAuraMuxDirty(eid, set)
	self:TriggerUpdate();
end

function RDXM.DebuffDriver:BindEvents()
	self:UnbindEvents();
	RDX.SigMuxFlagsDirty[1]:Connect(self, self.OnAuraMuxDirty);
end
function RDXM.DebuffDriver:UnbindEvents()
	RDX.SigMuxFlagsDirty[1]:DisconnectObject(self);
end

------------------------------------------------------------
-- MAIN DRIVER
------------------------------------------------------------
-- Save encounter settings
function RDXM.Debuffs:SaveEncounter(enc)
	VFL.debug("RDXM.Debuffs.SaveEncounter("..enc..")", 4);
	local cfg = RDXM.Debuffs.ecfg;
	cfg.x = RDXDebuffAnchor:GetLeft(); cfg.y = RDXDebuffAnchor:GetTop();
	RDX.SaveUEMPrefs(enc, "debuffs", cfg);
end
function RDXM.Debuffs.Save()
	RDXM.Debuffs:SaveEncounter(RDX.GetVirtualEncounter());
end

-- Load encounter settings
function RDXM.Debuffs:LoadEncounter(enc)
	VFL.debug("RDXM.Debuffs.LoadEncounter("..enc..")", 4);
	local cfg = RDXM.Debuffs.ecfg;
	-- Sideload encounter configuration
	RDX.MapUEMPrefs(enc, "debuffs", cfg);
	-- Restore positioning
	if cfg.x then
		RDXDebuffAnchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", cfg.x, cfg.y);
	else
		RDXDebuffAnchor:SetPoint("TOPLEFT", UIParent, "CENTER");
	end
	-- Setup defaults
	if not cfg.show then
		RDXM.Debuffs.LoadDefaults(cfg);
	end
	-- Reset the BIG LIST
	RDXM.Debuffs.bl:Hide();
	RDXM.Debuffs.bl:ConfigChanged();
	RDXM.Debuffs.bl:TriggerUpdate(3);
	-- Reset the small lists
	RDXM.Debuffs.sld:Hide();
	-- If anything is shown...
	if cfg.show > 1 then
		if (cfg.slice == 1) then
			RDXM.Debuffs.bl:Show();
		else
			RDXM.Debuffs.sld:Show();
		end
	end
end
function RDXM.Debuffs.Load()
	RDXM.Debuffs:LoadEncounter(RDX.GetVirtualEncounter());
end
function RDXM.Debuffs.LoadDefaults(cfg)
	cfg.filterFunc = nil; cfg.prioFilterFunc = nil;
	cfg.relevance = {};
	cfg.show = 4; cfg.slice = 1;
end

-- Window movement
function RDXM.Debuffs.WindowStartMoving()
	RDXM.Debuffs.moving = true;
	RDXDebuffAnchor:StartMoving();
end

function RDXM.Debuffs.WindowStopMoving()
	RDXDebuffAnchor:StopMovingOrSizing();
	if RDXM.Debuffs.moving then
		RDXM.Debuffs.moving = nil;
		RDXM.Debuffs.Save();
	end
end
------------------------------------------------------------
-- CURIFICATION
------------------------------------------------------------
-- Attempt to cure the given unit.
function RDXM.Debuffs.CureUnit(unit)
	-- Find the unit in the "BIG LIST"
	local biglist, un = RDXM.Debuffs.bl, unit.nid;
	local ud = biglist.itbl[un];
	if not ud then return false; end
	return RDXM.Debuffs.CureDataPhase(ud);
end

-- Cure: post-data phase
function RDXM.Debuffs.CureDataPhase(ud)
	-- Figure out the debuff type to be cured
	local dt = ud.curable;
	if not dt then return false; end
	-- Try to get a cure spell
	local sp = RDXM.Debuffs.GetCureSpell(dt);
	if not sp then return false; end
	local unit = ud.unit;
	-- Pass to cast phase
	return RDXM.Debuffs.CastCure(sp, unit);
end

-- Cure: cast phase
function RDXM.Debuffs.CastCure(sp, unit)
	-- If unit is LoS blacklisted, abort.
	if RDX.CheckBlacklist(RDX.losbl, unit.name) then return false; end
	-- Attempt the cast
	VFL.debug("RDXM.Debuffs.CastCure: casting "..sp.title.. " on " .. unit.name, 8);
	local rt = RDX.Target(unit);
	local ret = RDX.GuardedCast(sp, function(flg, reason)
		if (not flg) then
			if(reason == 2) or (reason == 3) then
				RDX.Blacklist(RDX.losbl, unit.name, 5);
			end
		end
	end);
	RDX.Retarget(rt);
	return ret;
end

-- Autocure
function RDXM.Debuffs.Autocure()
	local biglist = RDXM.Debuffs.bl;
	-- Foreach unit in descending prio order...
	for _,ud in ipairs(biglist.list) do 
		if RDXM.Debuffs.CureDataPhase(ud) then return; end
	end
	VFL.debug("RDXM.Debuffs.Autocure(): cure cycle completed with no valid targets", 4);
end

-- Get the preferred cure spell for a debuff type
function RDXM.Debuffs.GetCureSpell(dt)
	local cfg,sp = RDXM.Debuffs.ecfg,nil;
	if cfg.preferredCures then
		if cfg.preferredCures[dt] then
			sp = RDX.GetSpell(cfg.preferredCures[dt]);
			if sp then return sp; end
		end
	end
	if RDX.playerClass.highestCure[dt] then
		sp = RDX.GetSpell(RDX.playerClass.highestCure[dt]);
		if sp then return sp; end
	end
	return nil;
end

------------------------------------------------------------
-- CONFIGURATION AND METADATA
------------------------------------------------------------
-- Get the priority of a debuff.
-- A zero or negative result indicates ignored.
function RDXM.Debuffs.GetDebuffPrio(dn, meta)
	-- Ignore all forced-ignored debuffs
	if RDXM.Debuffs.gcfg.ignore[dn] then return -1; end
	local cfg = RDXM.Debuffs.ecfg;
	-- Enforce "Curable Only"
	if (cfg.show == 3) then
		if(not meta) or (not meta.curable) then return -1; end
	end
	-- Get debuff relevance
	local rel = cfg.relevance[dn];
	-- Enforce "Show Relevant Only"
	if (cfg.show == 2) then if not rel then return -1; end end
	if not rel then rel = 1; end
	-- Prioritize curable
	if(meta and meta.curable) then return rel*2; else return rel; end
end

-- Global config
function RDXM.Debuffs.GlobalShowConfigDialog(okCB, cancelCB)
	local dlg,dn,ctl,cfg = RDXDebuffGlobal, "RDXDebuffGlobal", nil, RDXM.Debuffs.gcfg;
	dlg:Show();
	-- Ignore list
	ctl = getglobal(dn.."IgnoreList");
	ctl.list.data = {};
	for k,v in cfg.ignore do if v then
		table.insert(ctl.list.data, {text = k});
	end end
	ctl.list:UpdateContent();
	-- OK/Cancel
	getglobal(dn.."Cancel").OnClick = function() 
		VFL.Escape();
		if(cancelCB) then cancelCallback(); end
	end
	getglobal(dn.."OK").OnClick = function()
		RDXM.Debuffs.GlobalReadConfigDialog();
		VFL.Escape();
		if(okCB) then okCallback(); end
	end
	-- Setup escape handler
	VFL.AddEscapeHandler(function() dlg:Hide(); end);
end
function RDXM.Debuffs.GlobalReadConfigDialog()
	local dlg,dn,ctl,cfg = RDXDebuffGlobal, "RDXDebuffGlobal", nil, RDXM.Debuffs.gcfg;
	-- Ignore list
	ctl = getglobal(dn.."IgnoreList");
	cfg.ignore = {};
	for _,v in ctl.list.data do
		cfg.ignore[string.lower(v.text)] = true;
	end
	-- Save configuration
	RDX.SaveGMPrefs("debuffs", RDXM.Debuffs.gcfg);
	RDXM.Debuffs.Load();
end

-- Enc config
function RDXM.Debuffs.EncShowConfigDialog(okCB, cancelCB)
	local dlg,dn,ctl,cfg = RDXDebuffEnc, "RDXDebuffEnc", nil, RDXM.Debuffs.ecfg;
	if not dlg.tmpfd then
		dlg.tempfd = RDX.FilterDesc:new();
	end
	dlg.tempfd:SetConfig({});
	dlg.tempfd:SetDefaults();
	dlg:Show();
	-- Relevant debuffs list
	ctl = getglobal(dn.."RelList");
	ctl.list.data = {};
	for k,v in cfg.relevance do
		table.insert(ctl.list.data, {text=k, rel=v});
	end
	table.sort(ctl.list.data, function(d1,d2) return (d1.rel>d2.rel); end);
	ctl.list:UpdateContent();
	-- Show
	dlg.RGShow:SelectByID(cfg.show);
	-- Slice
	dlg.RGSlice:SelectByID(cfg.slice);
	-- Player Prio
	if cfg.prioFilterConfig then
		getglobal(dn.."Prio"):Set(true);
		dlg.tempfd:SetConfig(cfg.prioFilterConfig);
	else
		getglobal(dn.."Prio"):Set(false);
	end
	getglobal(dn.."PrioFilter").OnClick = function()
		dlg.tempfd:ShowConfigDialog();
	end
	-- OK/Cancel
	getglobal(dn.."Cancel").OnClick = function() 
		VFL.Escape();
		if(cancelCB) then cancelCallback(); end
	end
	getglobal(dn.."OK").OnClick = function()
		RDXM.Debuffs.EncReadConfigDialog();
		VFL.Escape();
		if(okCB) then okCallback(); end
	end
	-- Setup escape handler
	VFL.AddEscapeHandler(function() dlg:Hide(); end);
end
function RDXM.Debuffs.EncReadConfigDialog()
	local dlg,dn,ctl,cfg = RDXDebuffEnc, "RDXDebuffEnc", nil, RDXM.Debuffs.ecfg;
	-- Relevant debuffs list
	cfg.relevance = {};
	ctl = getglobal(dn.."RelList");
	local n = table.getn(ctl.list.data);
	for i,v in ipairs(ctl.list.data) do
		cfg.relevance[string.lower(v.text)] = (n-i+2);
	end
	-- Show/slice
	cfg.show = dlg.RGShow:Get();
	cfg.slice = dlg.RGSlice:Get();
	-- Player prio
	if getglobal(dn.."Prio"):Get() then
		cfg.prioFilterConfig = dlg.tempfd.data;
	else
		cfg.prioFilterConfig = nil;
	end
	RDXM.Debuffs.Save();
	RDXM.Debuffs.Load();
end

------------------------------------------------------------
-- MENUS
------------------------------------------------------------
function RDXM.Debuffs:Menu(tree, frame)
	local mnu = {};
	-- Configuration
	table.insert(mnu, {
		text = "Encounter Options...",
		OnClick = function() RDXM.Debuffs.EncShowConfigDialog(); tree:Release(); end
	});
	table.insert(mnu, {
		text = "Global Options...",
		OnClick = function() RDXM.Debuffs.GlobalShowConfigDialog(); tree:Release(); end
	});
	-- Display menu
	tree:Expand(frame, mnu);
end

------------------------------------------------------------
-- MODULE INIT AND REGISTRATION
------------------------------------------------------------
function RDXM.Debuffs.Init(self)
	VFL.debug("RDXM.Debuffs.Init()", 5);

	-- Load global config/defaults
	RDXM.Debuffs.gcfg = {};
	RDX.MapGMPrefs("debuffs", RDXM.Debuffs.gcfg);
	if not RDXM.Debuffs.gcfg.ignore then RDXM.Debuffs.gcfg.ignore = {}; end
	-- Empty encounter config
	RDXM.Debuffs.ecfg = {};

	-- The "Big List"
	local biglist = RDXM.DebuffBigList:new();
	RDXM.Debuffs.bl = biglist;
	biglist.window:SetPoint("TOPLEFT", RDXDebuffAnchor, "BOTTOMLEFT");
	biglist:Setup();
	biglist:BindEvents();
	
	-- The small list driver
	local sld = RDXM.DebuffDriver:new();
	RDXM.Debuffs.sld = sld;
	sld:Hide();

	-- AUTOCURE SLASH COMMAND
	SLASH_RDXCURE1 = "/rdxcure";
	SlashCmdList["RDXCURE"] = function() RDXM.Debuffs.Autocure(); end
end

-- Move debuff anchor to screen center
function RDXM.Debuffs.ResetUI()
	RDXDebuffAnchor:SetPoint("TOPLEFT", UIParent, "CENTER");
	RDXM.Debuffs.Save();
end

-- Register the module
RDXM.Debuffs.module = RDX.RegisterModule({
	name = "debuffs";
	title = "Debuffs";
	DeferredInit = RDXM.Debuffs.Init;
	Menu = RDXM.Debuffs.Menu;
	LoadEncounter = RDXM.Debuffs.LoadEncounter;
	SaveCurrentEncounter = RDXM.Debuffs.Save;
	ResetUI = RDXM.Debuffs.ResetUI;
});
