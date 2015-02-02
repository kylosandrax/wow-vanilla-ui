-- Assists.lua
-- RDX - Raid Data Exchange
-- Assist module 
-- (C)2005-06 Bill Johnson (Venificus of Eredar server)
--

if not RDXM.Assists then RDXM.Assists = {}; end
---------------------------------------------------------
-- WINDOW
---------------------------------------------------------
if not RDXM.AssistWindow then RDXM.AssistWindow = {}; end
RDXM.AssistWindow.__index = RDXM.AssistWindow;

function RDXM.AssistWindow:new()
	local self = {};
	setmetatable(self, RDXM.AssistWindow);
	-- Config
	self.showTT = true; self.visible = nil;
	-- Container
	RDX.Window.MakeContainer(self, 4);
	-- Onclicks
	self.window.btnClose.OnClick = function() RDXM.Assists.window:Hide(); RDXM.Assists.Save(); end
	self.window.btnI.OnMouseDown = function()
		if(arg1 == "LeftButton") and (IsShiftKeyDown()) then
			self.window:StartMoving();
		end
	end
	self.window.btnI.OnMouseUp = function()
		if(arg1 == "RightButton") then
			RDXM.Assists.ShowConfigDialog();
		else
			self.window:StopMovingOrSizing();
			RDXM.Assists.Save();
		end
	end
	
	-- Layout/title
	
	self:Hide();
	self.grid:SetColumnPadding(0); self.grid:SetRowPadding(0);
	self.grid:SetDefaultColumnWidth(80); self.grid:SetDefaultRowHeight(14);
	self.window.text:SetText("Assists");
	getglobal(self.window:GetName().."TitleBkg"):SetGradient("HORIZONTAL", 0, 0, 0.9, 0, 0, 0.1);
	return self;
end

-- Show/hide methods
function RDXM.AssistWindow:Show()
	self.visible = true;
	self.window:Show(); self.window:SetFrameLevel(1); self:Update();
end
function RDXM.AssistWindow:Hide()
	self.visible = nil;
	self.window:Hide(); self.grid:Destroy();
end

-- Repaint routine
function RDXM.AssistWindow:Update()
	if not self.visible then return; end
	-- Layout
	local cols,n,cfg = 2,table.getn(RDX.tanktable),RDXM.Assists.cfg;
	if(self.showTT) then cols = 3; end
	self.grid:Size(cols, n, self.fnAcquireCell);
	self.grid:Layout();
	local dx,dy = self.grid:GetExtents();
	if(dx == 0) or (dy == 0) then
		dy = 1; dx = self.grid.defCW;
	end
	self.window:Accomodate(dx,dy);
	-- Paint
	for i=1,n do
		RDXM.AssistWindow.ApplyData(self.grid, self.showTT, RDX.tanktable[i], i);
	end
	-- Alpha
	if (cfg.alpha) then
		self.window:SetAlpha(cfg.alpha)
	else
		self.window:SetAlpha(1.0);
	end
	-- Scale
	if (cfg.scale) then
		self.window:SetScale(cfg.scale)
	else
		self.window:SetScale(1.0);
	end
end
function RDXM.AssistWindow.SanityCheckUnit(un)
	if(not un) or (un == "Unknown Entity") then return false; end
	return true;
end
function RDXM.AssistWindow.ApplyData(grid, stt, ud, row)
	local fc2,fc3,u = true, stt, ud.unit;
	-- Cell 1: Tank name
	local c = grid:GetCell(1, row);
	c:Show(); 
	if(not u) or (not u:IsOnline()) then -- Tank is wholly nonpresent
		fc2 = false; fc3 = false; c:SetPurpose(4);
		c.text1:SetText(VFL.capitalize(ud.name)); c.text1:SetTextColor(0.5,0.5,0.5);
	else
		c:SetPurpose(1);
		c.text1:SetText(ud.unit:GetProperName()); c.text1:SetTextColor(1,1,1);
		local h = u:FracHealth();
		RDX.SetStatusBar(c.bar1, h, RDXG.vis.cFriendHP, RDXG.vis.cFriendHPFade);
		RDX.SetStatusText(c.text2, h, RDXG.vis.cStatusText, RDXG.vis.cStatusTextFade);
		c.text2:SetText(string.format("%0.0f%%", h*100));
		c.OnClick = function() TargetUnit(u.uid); end
	end
	-- Cell 2: Target
	local c = grid:GetCell(2, row);
	if not fc2 then c:Hide() else
		-- If no target, hide cell
		local tn = UnitName(u.uid .. "target");
		if not RDXM.AssistWindow.SanityCheckUnit(tn) then c:Hide() else
			c:Show(); c:SetPurpose(1); c.text1:SetText(tn); c.text1:SetTextColor(1,1,1);
			local h = UnitHealth(u.uid .. "target")/UnitHealthMax(u.uid.."target");
			--TESTING - Trying to fix -1hp / huge grey bar bug in pvp
			if not (h >= 0 and h <= 1) then h = 0; end
			--END TESTING
			RDX.SetStatusBar(c.bar1, h, RDXG.vis.cFriendHP, RDXG.vis.cFriendHPFade);
			RDX.SetStatusText(c.text2, h, RDXG.vis.cStatusText, RDXG.vis.cStatusTextFade);
			c.text2:SetText(string.format("%0.0f%%", h*100));
			c.OnClick = function() AssistUnit(u.uid); end
		end
	end
	-- Cell 3: Target's Target
	if(not stt) then return; end
	local c = grid:GetCell(3, row);
	if not fc3 then c:Hide() else
		local tn = UnitName(u.uid .. "targettarget");
		if not RDXM.AssistWindow.SanityCheckUnit(tn) then c:Hide() else
			c:Show(); c:SetPurpose(1); c.text1:SetText(tn); c.text1:SetTextColor(1,1,1);
			local h = UnitHealth(u.uid .. "targettarget")/UnitHealthMax(u.uid.."targettarget");
			--TESTING - Trying to fix -1hp / huge grey bar bug in pvp
			if not (h >= 0 and h <= 1) then h = 0; end
			--END TESTING
			RDX.SetStatusBar(c.bar1, h, RDXG.vis.cFriendHP, RDXG.vis.cFriendHPFade);
			RDX.SetStatusText(c.text2, h, RDXG.vis.cStatusText, RDXG.vis.cStatusTextFade);
			c.text2:SetText(string.format("%0.0f%%", h*100));
			c.OnClick = function() AssistUnit(u.uid .. "target"); end
		end
	end
end

---------------------------------------------------------
-- DRIVER
---------------------------------------------------------
-- Update the cached versions of the assist db
function RDXM.Assists.UpdateTankTable()
	VFL.debug("RDXM.Assists.UpdateTankTable()", 4);
	local mtarray,auxarray = RDXM.Assists.cfg.mtarray, RDXM.Assists.cfg.auxarray;
	RDX.tanktable = {};
	RDX.n_tanktable = {};
	local idx = 1;
	for i=1,table.getn(mtarray) do
		local t = { name = mtarray[i], type = 1, index = idx, unit = nil };
		VFL.debug("RDXM.Assists.UpdateTankTable() inserting " .. t.name, 4);
		table.insert(RDX.tanktable, t);
		RDX.n_tanktable[t.name] = t;
		idx = idx + 1;
	end
	for i=1,table.getn(auxarray) do
		local t = { name = auxarray[i], type = 2, index = idx, unit = nil };
		VFL.debug("RDXM.Assists.UpdateTankTable() inserting " .. t.name, 4);
		table.insert(RDX.tanktable, t);
		RDX.n_tanktable[t.name] = t;
		idx = idx + 1;
	end
	-- Redo unit map
	RDXM.Assists.RemapTankTableUnits();
end

-- Search through the raid group, updating the tank tables with the unit ids
-- of the tanks.
function RDXM.Assists.RemapTankTableUnits()
	VFL.debug("RDXM.Assists.RemapTankTableUnits()", 2);
	-- Clear existing tanktable units
	for _,ud in RDX.tanktable do ud.unit = nil; end
	-- Redo tanktable units
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if (u:IsValid()) and RDX.n_tanktable[u.name] then
			VFL.debug("RDXM.Assists.RemapTankTableUnits() found tank " .. u.name, 2);
			RDX.n_tanktable[u.name].unit = u;
		end
	end
end

-- Load assists for the encoutner
function RDXM.Assists:LoadEncounter(en)
	local cfg = RDXM.Assists.cfg;
	if not RDX.MapUEMPrefs(en, "assists", cfg) then
		cfg.mtarray = {};
		cfg.auxarray = {};
	end
	-- Restore layout
	RDXM.Assists.window.window:ClearAllPoints();
	if not cfg.x then
		RDXM.Assists.window.window:SetPoint("CENTER", UIParent, "CENTER");
	else
		RDXM.Assists.window.window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", cfg.x, cfg.y);
	end
	-- Restore show
	if(cfg.shown) then 
		RDXM.Assists.window:Show();
	else 
		RDXM.Assists.window:Hide(); 
	end
	-- Update tanktable
	RDXM.Assists.UpdateTankTable();
end
function RDXM.Assists.Load()
	RDXM.Assists:LoadEncounter(RDX.GetVirtualEncounter());
end

-- Save assists (and scale/alpha) for the encounter
function RDXM.Assists:SaveEncounter(en)
	local cfg = RDXM.Assists.cfg;
	cfg.shown = RDXM.Assists.window.visible;
	if(cfg.shown) then
		cfg.x = RDXM.Assists.window.window:GetLeft();
		cfg.y = RDXM.Assists.window.window:GetTop();
	end
	RDX.SaveUEMPrefs(en, "assists", RDXM.Assists.cfg);
	-- Scaling
	if (cfg.scale) then
		RDXM.Assists.window.window:SetScale(cfg.scale);
	else
		RDXM.Assists.window.window:SetScale(1.0);
	end
	RDXM.Assists.UpdateTankTable();
end
function RDXM.Assists.Save()
	RDXM.Assists:SaveEncounter(RDX.GetVirtualEncounter());
end

-- Timed updates
function RDXM.Assists.Heartbeat()
	if (not UnitInRaid("player") and RDXM.Assists.cfg.auxarray and RDXM.Assists.cfg.mtarray) then
		RDXM.Assists.ClearMainTanks_RPC();
	end
		
	RDXM.Assists.window:Update();
	VFL.schedule(RDXG.perf.uiWindowUpdateDelay, RDXM.Assists.Heartbeat);
end

------------------------------
-- CONFIG AND METADATA
------------------------------
-- Show the assist list dialog
function RDXM.Assists.ShowConfigDialog()
	local dlg,dn,ctl,cfg = RDXAssistList,"RDXAssistList",nil,RDXM.Assists.cfg;
	dlg:Show();
	-- MT list
	ctl = getglobal(dn.."MTsList");
	ctl.list.data = {};
	for i=1,table.getn(cfg.mtarray) do
		table.insert(ctl.list.data, {text = cfg.mtarray[i]});
	end
	ctl.list:UpdateContent();
	-- Aux list
	ctl = getglobal(dn.."AuxList");
	ctl.list.data = {};
	for i=1,table.getn(cfg.auxarray) do
		table.insert(ctl.list.data, {text = cfg.auxarray[i]});
	end
	ctl.list:UpdateContent();
	-- Bind to ok/cancel
	getglobal(dn.."Cancel").OnClick = function() dlg:Hide(); end
	getglobal(dn.."OK").OnClick = function()
		RDXM.Assists.ReadConfigDialog(); dlg:Hide();
		RDXM.Assists.Save();
	end
	-- Scale
	local scaleChk = getglobal(dn.."ScaleChk");
	local scale = getglobal(dn.."Scale");
	local alphaChk = getglobal(dn.."AlphaChk");
	local alpha = getglobal(dn.."Alpha");

	if (cfg.scale) then
		scaleChk:Set(1);
		scale:SetValue(cfg.scale);
	else
		scaleChk:Set(nil);
		scale:SetValue(1);
	end
	if (cfg.alpha) then
		alphaChk:Set(1);
		alpha:SetValue(cfg.alpha);
	else
		alphaChk:Set(nil);
		alpha:SetValue(1);
	end

	if (IsRaidLeader() or IsRaidOfficer()) then
		getglobal(dn.."MTs" .. "Edit"):Show();
		getglobal(dn.."MTs" .. "BClr"):Show();
		getglobal(dn.."MTs" .. "BDel"):Show();
	else	
		getglobal(dn.."MTs" .. "Edit"):Hide();
		getglobal(dn.."MTs" .. "BClr"):Hide();
		getglobal(dn.."MTs" .. "BDel"):Hide();
	end
end

-- Load the contents of the assist list dialog
function RDXM.Assists.ReadConfigDialog()
	local dlg,dn,ctl,cfg = RDXAssistList,"RDXAssistList",nil,RDXM.Assists.cfg;
	-- MT list
	ctl = getglobal(dn.."MTsList");
	cfg.mtarray = {};
	for i=1,table.getn(ctl.list.data) do
		table.insert(cfg.mtarray, string.lower(ctl.list.data[i].text));
	end
	-- Aux list
	ctl = getglobal(dn.."AuxList");
	cfg.auxarray = {};
	for i=1,table.getn(ctl.list.data) do
		table.insert(cfg.auxarray, string.lower(ctl.list.data[i].text));
	end
	-- Scale
	if(getglobal(dn.."ScaleChk"):Get()) then
		cfg.scale = getglobal(dn.."Scale"):GetValue();
	else
		cfg.scale = nil;
	end
	-- Alpha
	if(getglobal(dn.."AlphaChk"):Get()) then
		cfg.alpha = getglobal(dn.."Alpha"):GetValue();
	else
		cfg.alpha = nil;
	end
end


-- Add assists
function RDXM.Assists.ToggleMainTank(name)
	-- don't add it if we're not a raid office/leader
	if (not IsRaidLeader() and not IsRaidOfficer()) then
		return;
	end

	-- don't add it if we have it
	for i=1, table.getn(RDXM.Assists.cfg.mtarray) do
		if RDXM.Assists.cfg.mtarray[i] == name then
			table.remove(RDXM.Assists.cfg.mtarray, i);
			RDXM.Assists.SyncMainTanks();
			return;
		end
	end
	table.insert(RDXM.Assists.cfg.mtarray, name);
	RDXM.Assists.SyncMainTanks();
end
function RDXM.Assists.ToggleAuxAssist(name)
	-- don't add it if we have it
	for i=1, table.getn(RDXM.Assists.cfg.auxarray) do
		if RDXM.Assists.cfg.auxarray[i] == name then
			table.remove(RDXM.Assists.cfg.auxarray, i);
			RDXM.Assists.Save();
			return;
		end
	end
	table.insert(RDXM.Assists.cfg.auxarray, name);
	RDXM.Assists.Save();
end
function RDXM.Assists.ClearMainTanks()
	RPC.Invoke("clear_main_tanks");
end
function RDXM.Assists.ClearMainTanks_RPC()
	RDXM.Assists.cfg.mtarray = {};
	RDXM.Assists.Save();
end
function RDXM.Assists.SyncMainTanks()
	if (table.getn(RDXM.Assists.cfg.mtarray) == 0) then
		RDXM.Assists.ClearMainTanks();
	else
		RPC.Invoke("sync_main_tanks", RDXM.Assists.cfg.mtarray);
	end
end
function RDXM.Assists.SyncMainTanks_RPC(sender, maintanks)
	-- don't add it if the sender is not raid leader/officer
	if (not sender:IsLeader()) then
		return;
	end
	RDXM.Assists.cfg.mtarray = maintanks;
	RDXM.Assists.Save();
end

---------------------------------------------------------
-- MAIN TANK DEATH
---------------------------------------------------------
function RDXM.Assists.PlayerDeath()
	if not RDXM.Assists.cfg.mtarray then
		return;
	end
	local playerName = string.lower(UnitName("player"));
	for i = 1, table.getn(RDXM.Assists.cfg.mtarray) do
		if playerName == RDXM.Assists.cfg.mtarray[i] then
			RPC.Invoke("main_tank_death");
			return;
		end
	end
end
VFLEvent:NamedBind("maintankdeath", BlizzEvent("PLAYER_DEAD"), function() RDXM.Assists.PlayerDeath(); end);

function RDXM.Assists.MainTankDeath_RPC(sender)
	if RDXM.Assists.cfg.mtarray then
		local senderName = string.lower(sender.name);
		for i = 1, table.getn(RDXM.Assists.cfg.mtarray) do
			if senderName == RDXM.Assists.cfg.mtarray[i] then
				RDX.Alert.Simple(sender:GetProperName() .. " HAS DIED!", "Sound\\interface\\igQuestFailed.wav", 1, 1);
				return;
			end
		end
	end
end
RPC.Bind("main_tank_death", RDXM.Assists.MainTankDeath_RPC);

---------------------------------------------------------
-- WOW DEFAULT UI INTEGRATION
---------------------------------------------------------
RDXM.Assists.oldUnitPopup_OnClick = nil;
function RDXM.Assists.UnitPopup_OnClick()
	local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local button = this.value;
	local name = string.lower(dropdownFrame.name);
	if button == "RDX_MT" then
		RDXM.Assists.ToggleMainTank(name);
		PlaySound("UChatScrollButton");
	elseif button == "RDX_AUXA" then
		RDXM.Assists.ToggleAuxAssist(name);
		PlaySound("UChatScrollButton");
	elseif RDXM.Assists.oldUnitPopup_OnClick then
		RDXM.Assists.oldUnitPopup_OnClick();
	end
end

---------------------------------------------------------
-- MENU
---------------------------------------------------------
function RDXM.Assists:Menu(tree, frame)
	local mnu, cfg = {}, RDXM.Assists.cfg;
	if cfg.shown then
		-- "Hide" option
		table.insert(mnu, {
			text="Hide";
			OnClick = function() RDXM.Assists.window:Hide(); RDXM.Assists.Save(); tree:Release(); end
		});
	else
		-- "Show" option
		table.insert(mnu, {
			text="Show";
			OnClick = function() RDXM.Assists.window:Show(); RDXM.Assists.Save(); tree:Release(); end
		});
	end

	-- Clear
	if (IsRaidLeader() or IsRaidOfficer()) then
		table.insert(mnu, {
			text = "Clear",
			OnClick = function() RDXM.Assists.ClearMainTanks(); tree:Release(); end
		});
	end

	-- Sync
	if (IsRaidLeader() or IsRaidOfficer()) then
		table.insert(mnu, {
			text = "Sync",
			OnClick = function() RDXM.Assists.SyncMainTanks(); tree:Release(); end
		});
	end

	-- Pull setup
	if RDXM.Assists.wPullSetup.visible then
	else
		table.insert(mnu, { 
			text = "Show Pull Setup"; 
			OnClick = function() 
				RDXM.Assists.wPullSetup.window:SetPoint("CENTER", UIParent, "CENTER");
				RDXM.Assists.wPullSetup:Show();
				tree:Release();
			end
		});
	end
	-- Configuration
	table.insert(mnu, {
		text = "Options...",
		OnClick = function() RDXM.Assists.ShowConfigDialog(); tree:Release(); end
	});
	-- Display menu
	tree:Expand(frame, mnu);
end

---------------------------------------------------------
-- MODULE INIT AND REGISTRATION
---------------------------------------------------------
-- Initialize assists
function RDXM.Assists.Init()
	VFL.debug("RDXM.Assists.Init()", 2);

	-- Bind into the raid screen popups
	UnitPopupButtons["RDX_MT"] = { text = "RDX: Toggle Main Tank", dist = 0 };
	UnitPopupButtons["RDX_AUXA"] = { text = "RDX: Toggle Aux Assist", dist = 0 };
	if (UnitPopupMenus["RAID"]) then
		table.insert( UnitPopupMenus["RAID"], "RDX_MT");
		table.insert( UnitPopupMenus["RAID"], "RDX_AUXA");
	end
	RDXM.Assists.oldUnitPopup_OnClick = UnitPopup_OnClick;
	UnitPopup_OnClick = RDXM.Assists.UnitPopup_OnClick;

	-- Create the tank tables/config tables
	RDX.tanktable = {}; RDX.n_tanktable = {}; RDXM.Assists.cfg = {};

	-- Create "the window"
	RDXM.Assists.window = RDXM.AssistWindow:new();

	-- Any time the raid group's identity changes, we must update the tank table
	RDX.SigUnitIdentitiesChanged:Connect(nil, function() RDXM.Assists.RemapTankTableUnits(); end);

	-- Start heartbeat
	RDXM.Assists.Heartbeat();

	-- Create pull setup window; bind its heartbeat
	RDXM.Assists.wPullSetup = RDXM.Assists.CreatePullSetupWindow();
	RDX.SigHeartbeatFast:Connect(RDXM.Assists.wPullSetup, RDXM.Assists.wPullSetup.Repaint);

	-- Bind the main tank function
	RPC.Bind("sync_main_tanks", RDXM.Assists.SyncMainTanks_RPC);
	RPC.Bind("clear_main_tanks", RDXM.Assists.ClearMainTanks_RPC);
end

-- Move assist window to screen center
function RDXM.Assists.ResetUI()
	-- Set layout to center
	RDXM.Assists.window.window:ClearAllPoints();
	RDXM.Assists.window.window:SetPoint("CENTER", UIParent, "CENTER");
	RDXM.Assists.Save();
end

-- Register the module
RDXM.Assists.module = RDX.RegisterModule({
	name = "assists";
	title = "Assists";
	DeferredInit = RDXM.Assists.Init;
	LoadEncounter = RDXM.Assists.LoadEncounter;
	SaveCurrentEncounter = RDXM.Assists.Save;
	Menu = RDXM.Assists.Menu;
	ResetUI = RDXM.Assists.ResetUI;
});
