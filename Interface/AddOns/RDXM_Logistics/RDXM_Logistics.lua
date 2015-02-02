-- RDXM_Logistics.lua
-- RDX5 - Raid Data Exchange
-- (C)2005 Bill Johnson - Venificus of Eredar server
--
-- Logistics module for RDX.
--
-- Responding to chatsynced requests, provide leaders with information about:
-- - Items possessed/not possessed
-- - Location (Who's not here list revisited)
-- - Stats (FR check anyone?)
-- - "Ready Check"
if not RDXM.Logistics then RDXM.Logistics = {}; end

-----------------------------------
-- REQUEST PROCESSING
-----------------------------------
-- Request type dispatch table
RDXM.Logistics.reqDispatch = {};

-- Respond to a logistics request sent by another user.
function RDXM.Logistics.RequestHandler(proto, sender, data)
	VFL.debug("RDXM.Logistics.RequestHandler(): Req from [" .. sender:GetProperName() .. "] -- [" .. data .. "]", 9);
	-- Leader check (removed 12.25)
	--if not sender:IsLeader() then 
	--	VFL.debug("-- Rejected: not raid leader", 9);
	--	return; 
	--end
	-- Format: (reqid) (reqtype) (args)
	local found,_,reqid,reqtype,args = string.find(data,"^(%d+) (%d+) (.*)$");
	-- Ignore nonsense requests
	if not found then return; end
	-- Ignore requests with no dispatcher
	reqtype = tonumber(reqtype);
	if not RDXM.Logistics.reqDispatch[reqtype] then return; end
	-- Call dispatcher
	RDXM.Logistics.reqDispatch[reqtype](reqid, sender, args);
end

-----------------------------------
-- RESPONSE PROCESSING
-----------------------------------
-- Response dispatch table
RDXM.Logistics.respDispatch = {};

-- Generate a unique request ID
function RDXM.Logistics.GenID()
	return math.random(10000000);
end

-- Register a response handler for a given request ID
function RDXM.Logistics.RegisterResponseHandler(id, hdlr)
	RDXM.Logistics.respDispatch[id] = hdlr;
end
function RDXM.Logistics.UnregisterResponseHandler(id)
	RDXM.Logistics.respDispatch[id] = nil;
end

-- Handle a logistics response to a previous request.
function RDXM.Logistics.ResponseHandler(proto, sender, data)
	local found,_,reqid,args = string.find(data, "^(%d+) (.*)$");
	if not found then return; end
	reqid = tonumber(reqid);
	if not RDXM.Logistics.respDispatch[reqid] then return; end
	RDXM.Logistics.respDispatch[reqid](reqid, sender, args);
end

-----------------------------------
-- LOGISTICS WINDOWS
-----------------------------------
if not RDXM.LogisticsWindow then RDXM.LogisticsWindow = {}; end
RDXM.LogisticsWindow.__index = RDXM.LogisticsWindow;

function RDXM.LogisticsWindow:new()
	local self = {};
	setmetatable(self, RDXM.LogisticsWindow);
	-- ID of matching request
	self.reqid = nil;
	-- RDX container
	RDX.Window.MakeContainer(self, 4);
	-- Anchor to screen center
	self.window:ClearAllPoints();
	self.window:SetPoint("CENTER", UIParent, "CENTER");
	-- "Close" button binding
	self.window.btnClose.OnClick = function()
		self:Destroy();
	end
	-- Movement binding
	self.window.btnI.OnMouseDown = function()
		if(arg1 == "LeftButton") and (IsShiftKeyDown()) then
			self.window:StartMoving();
		end
	end
	self.window.btnI.OnMouseUp = function()
		self.window:StopMovingOrSizing();
	end
	return self;
end

-- Setup logistics window
function RDXM.LogisticsWindow:Setup(title, colWidth)
	self:Hide();
	-- Set grid dimensions
	self.grid:SetColumnPadding(0); self.grid:SetRowPadding(0);
	self.grid:SetDefaultColumnWidth(colWidth); self.grid:SetDefaultRowHeight(14);
	-- Set title
	self.window.text:SetText(title);
	getglobal(self.window:GetName().."TitleBkg"):SetGradient("HORIZONTAL", 0, 0, 0.9, 0, 0, 0.1);
end

-- Destroy all contents/memory
function RDXM.LogisticsWindow:Destroy()
	-- Destroy the matching request
	if self.reqid then
		RDXM.Logistics.UnregisterResponseHandler(self.reqid); self.reqid = nil;
	end
	RDX.Window.DestroyContainer(self);
end

-- Show contents
function RDXM.LogisticsWindow:Show()
	self.window:Show(); self.window:SetFrameLevel(1);
end

-- Hide the window.
function RDXM.LogisticsWindow:Hide()
	self.grid:Destroy(); self.window:Hide();
end

-----------------------------------
-- REQUEST TYPE 1: READY CHECK
----------------------------------
-- Start a ready check
function RDXM.Logistics.DoReadyCheck()
	-- First create a window.
	local w = RDXM.LogisticsWindow:new();
	w:Setup("Ready Check", 90);
	-- The window's content shall consist of all raiders, together with a value indicating their ready status
	w.ntbl = {};
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if u:IsValid() then
			w.ntbl[u.name] = { status = 1; }
		end
	end
	-- Build list function lists everyone beneath ready status
	w.Repaint = function()
		-- Build the list
		local list = {};
		for k,v in w.ntbl do
			if v.status < 4 then
				local ubn = RDX.GetUnitByName(k);
				if ubn then table.insert(list, { unit = ubn, status = v.status }); end
			end
		end
		-- Sort alpha
		table.sort(list, function(ud1,ud2) return (ud1.unit.name < ud2.unit.name); end);
		-- Layout the window
		RDX.LayoutRDXWindow(w, table.getn(list), 0, 1, table.getn(list), w.fnAcquireCell);
		-- Paint the window
		RDX.PaintRDXWindow(w, list, 0, w.displayed, w.fnApplyData);
	end
	-- Apply data function paints name and ready status
	w.fnApplyData = function(ud, c)
		local u = ud.unit;
		c:SetPurpose(5);
		c.text1:SetText(u:GetProperName());
		if(ud.status == 1) then
			c.text2:SetTextColor(.3,.3,.3);
			c.text2:SetText("No resp.");
		elseif(ud.status == 2) then
			c.text2:SetTextColor(0.6,0,0);
			c.text2:SetText("AFK");
		elseif(ud.status == 3) then
			c.text2:SetTextColor(1,0,0);
			c.text2:SetText("Not ready");
		end
		c.OnClick = function() TargetUnit(u.uid); end
	end
	-- Dispatch handler - on chat message, trip unit status, then repaint window.
	local reqid = RDXM.Logistics.GenID();
	w.reqid = reqid;
	RDXM.Logistics.RegisterResponseHandler(reqid, function(id, sender, args)
		-- Ignore senseless messages
		local status = tonumber(args);
		if not status then return; end
		-- Ignore responses from unknown senders
		local sn = sender.name;
		if not w.ntbl[sn] then return; end
		-- Update status
		w.ntbl[sn].status = status;
		-- Repaint window
		w.Repaint();
	end);
	-- Show the window.
	w:Show();
	w.Repaint();
	-- Now the fun begins, send the request.
	RDX.EnqueueMessage(RDXM.Logistics.p_req, reqid .. " 1 none");
end

-- Request type 1: Ready Check
RDXM.Logistics.rc_pending = false;
RDXM.Logistics.reqDispatch[1] = function(id, sender, args)
	-- No duplicate ready checks
	if RDXM.Logistics.rc_pending then return; end
	RDXM.Logistics.rc_pending = true;
	-- Display the ready check dialog
	local dlg,dn = RDXReadyCheckDlg,"RDXReadyCheckDlg";
	dlg:Show();
	-- Callback broadcasts appropriate response.
	local ready = function()
		dlg:Hide(); RDXM.Logistics.rc_pending = false;
		RDX.EnqueueMessage(RDXM.Logistics.p_resp, id .. " 4");
	end
	local notReady = function()
		dlg:Hide(); RDXM.Logistics.rc_pending = false;
		RDX.EnqueueMessage(RDXM.Logistics.p_resp, id .. " 3");
	end
	getglobal(dn.."NotReady").OnClick = notReady;
	getglobal(dn.."Ready").OnClick = ready;
	-- TODO: These closures go unfreed...
	-- 15 sec timeout: close ready dialog and report AFK.
	VFL.schedule(15, function()
		if RDXM.Logistics.rc_pending then
			RDXM.Logistics.rc_pending = false; dlg:Hide();
			RDX.EnqueueMessage(RDXM.Logistics.p_resp, id .. " 2");
		end
	end);
end

-----------------------------------
-- REQUEST TYPE 2: WHO'S NOT HERE
-----------------------------------
function RDXM.Logistics.DoWhosNotHere()
	-- First create a window.
	local w = RDXM.LogisticsWindow:new();
	w:Setup("Not Here", 120);
	-- Window is initially empty. As people report in, content builds.
	w.list = {};
	w.Repaint = function()
		-- Layout the window
		RDX.LayoutRDXWindow(w, table.getn(w.list), 0, 1, table.getn(w.list), w.fnAcquireCell);
		-- Paint the window
		RDX.PaintRDXWindow(w, w.list, 0, w.displayed, w.fnApplyData);
	end
	-- Apply data function paints name and zone
	w.fnApplyData = function(ud, c)
		local u = ud.unit;
		c:SetPurpose(5);
		c.text1:SetText(u:GetProperName()); c.text1:SetTextColor(1,1,1);
		c.text2:SetText(ud.zone); c.text2:SetTextColor(0.8,0.8,0.8);
		c.OnClick = function() TargetUnit(u.uid); end
	end
	-- Dispatch handler - on chat message, check zone and repaint as needed.
	local reqid = RDXM.Logistics.GenID();
	w.reqid = reqid;
	RDXM.Logistics.RegisterResponseHandler(reqid, function(id, sender, args)
		-- Ignore senseless messages
		if args == "" then return; end
		-- Get my current zone
		local myZone = GetRealZoneText() or "Unknown";
		-- If I'm not in the same zone...
		if (myZone ~= args) then
			table.insert(w.list, { unit = sender, zone = args });
			w.Repaint();
		end
	end);
	-- Show the window.
	w:Show();
	w.Repaint();
	-- Now the fun begins, send the request.
	RDX.EnqueueMessage(RDXM.Logistics.p_req, reqid .. " 2 none");
end
-- Respond to a request type 2 with the name of my current zone
RDXM.Logistics.reqDispatch[2] = function(id, sender, args)
	local zn = GetRealZoneText() or "Unknown";
	RDX.EnqueueMessage(RDXM.Logistics.p_resp, id .. " " .. zn);
end

-----------------------------------
-- REQUEST TYPE 3: RESISTS
-----------------------------------
function RDXM.Logistics.DoResistCheck()
	local w = RDXM.LogisticsWindow:new();
	w:Setup("Resistances", 150);
	w.list = {};
	w.Repaint = function()
		RDX.LayoutRDXWindow(w, table.getn(w.list), 0, 1, table.getn(w.list), w.fnAcquireCell);
		RDX.PaintRDXWindow(w, w.list, 0, w.displayed, w.fnApplyData);
	end
	w.fnApplyData = function(ud, c)
		c:SetPurpose(5);
		local u = ud.unit;
		c.text1:SetText(u:GetProperName()); c.text1:SetTextColor(1,1,1);
		c.text2:SetText(strcolor(1,0,0)..ud.fire.." "..strcolor(0,1,0)..ud.nature.." "..strcolor(0,0,1)..ud.frost.." "..strcolor(1,1,1)..ud.arcane.." "..strcolor(0.4,0.4,0.4)..ud.shadow);
		c.OnClick = function() TargetUnit(u.uid); end
	end
	local reqid = RDXM.Logistics.GenID();
	w.reqid = reqid;
	RDXM.Logistics.RegisterResponseHandler(reqid, function(id, sender, args)
		local x,_,fire,nature,frost,shadow,arcane = string.find(args, "(%d+)!(%d+)!(%d+)!(%d+)!(%d+)!");
		if not x then return; end
		local total = fire+nature+frost+shadow+arcane;
		table.insert(w.list, {unit = sender, fire=fire, frost=frost, nature=nature, arcane=arcane, shadow=shadow, total=total});
		table.sort(w.list, function(d1,d2) return d1.total>d2.total; end);
		w.Repaint();
	end);
	w:Show(); w.Repaint();
	RDX.EnqueueMessage(RDXM.Logistics.p_req, reqid .. " 3 none");
end
RDXM.Logistics.reqDispatch[3] = function(id, sender, args)
	-- Formulate resist reply
	local str = id .. " ";
	for i=2,6 do
		local _,res = UnitResistance("player", i);
		str = str .. res .. "!";
	end
	RDX.EnqueueMessage(RDXM.Logistics.p_resp, str);
end

-----------------------------------
-- REQUEST TYPE 4: INVENTORY
-----------------------------------
-- Count items in inventory with the given name
function RDXM.Logistics.CountItems(targ)
	local ret = 0; targ = string.lower(targ);
	-- For each bag, for each item in that bag...
	for i=0,4 do for j=1,MAX_CONTAINER_ITEMS do
		local link = GetContainerItemLink(i,j);
		if link then
			local _,_,name = string.find(link, "%[(.+)%]");
			if name and (string.lower(name) == targ) then
				local _,count = GetContainerItemInfo(i,j);
				ret = ret + count;
			end
		end -- if link
	end end -- foreach bag, item
	return ret;
end

-- Start inventory check
function RDXM.Logistics.DoInventoryCheck(item)
	if(not item) or (item == "") then return; end
	-- First create a window.
	local w = RDXM.LogisticsWindow:new();
	w:Setup(item, 90);
	-- The window's content shall consist of all raiders, together with a value indicating their inventory
	w.ntbl = {}; w.list = {};
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if u:IsValid() then
			local t = { unit = u; count = -1; }
			table.insert(w.list, t);
			w.ntbl[u.name] = t;
		end
	end
	w.Repaint = function()
		-- Sort by count
		table.sort(w.list, function(ud1,ud2) return (ud1.count > ud2.count); end);
		RDX.LayoutRDXWindow(w, table.getn(w.list), 0, 1, table.getn(w.list), w.fnAcquireCell);
		RDX.PaintRDXWindow(w, w.list, 0, w.displayed, w.fnApplyData);
	end
	w.fnApplyData = function(ud, c)
		c:SetPurpose(5);
		local u = ud.unit;
		c.text1:SetText(u:GetProperName()); c.text1:SetTextColor(1,1,1);
		if(ud.count < 0) then
			c.text2:SetTextColor(0.5,0.5,0.5); c.text2:SetText("No resp.");
		else
			c.text2:SetTextColor(0.8,0.8,0.8); c.text2:SetText(ud.count);
		end
		c.OnClick = function() TargetUnit(u.uid); end
	end
	local reqid = RDXM.Logistics.GenID();
	w.reqid = reqid;
	RDXM.Logistics.RegisterResponseHandler(reqid, function(id, sender, args)
		local x = tonumber(args);
		if not x then return; end
		if not w.ntbl[sender.name] then return; end
		w.ntbl[sender.name].count = x;
		w.Repaint();
	end);
	w:Show(); w.Repaint();
	RDX.EnqueueMessage(RDXM.Logistics.p_req, reqid .. " 4 " .. string.lower(item));
end
RDXM.Logistics.reqDispatch[4] = function(id, sender, args)
	if(args == "") then return; end
	local str = id .. " " .. RDXM.Logistics.CountItems(args);
	RDX.EnqueueMessage(RDXM.Logistics.p_resp, str);
end

-------------------------------------------------
-- REQUEST TYPE 5: SERVER TIME/SYNCHRONIZATION
-------------------------------------------------
function RDXM.Logistics.DoSyncCheck()
	local w = RDXM.LogisticsWindow:new();
	w:Setup("Sync Check", 90);
	w.list = {}; w.ntbl = {};
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if u:IsValid() then
			local t = { unit = u; sync = -1; }
			table.insert(w.list, t);
			w.ntbl[u.name] = t;
		end
	end
	w.Repaint = function()
		table.sort(w.list, function(ud1,ud2) return (ud1.unit.name < ud2.unit.name); end);
		RDX.LayoutRDXWindow(w, table.getn(w.list), 0, 1, table.getn(w.list), w.fnAcquireCell);
		RDX.PaintRDXWindow(w, w.list, 0, w.displayed, w.fnApplyData);
	end
	w.fnApplyData = function(ud, c)
		c:SetPurpose(5); local u = ud.unit;
		c.text1:SetText(u:GetProperName()); c.text1:SetTextColor(1,1,1);
		if(ud.sync < 0) then
			c.text2:SetTextColor(0.5, 0.5, 0.5); c.text2:SetText("Desync");
		else
			c.text2:SetTextColor(0.8, 0.8, 0.8); c.text2:SetText(string.format("%0.1f", ud.sync));
		end
	end
	local reqid = RDXM.Logistics.GenID();
	w.reqid = reqid;
	RDXM.Logistics.RegisterResponseHandler(reqid, function(id, sender, args)
		local x = tonumber(args); if not x then return; end
		if not w.ntbl[sender.name] then return; end
		w.ntbl[sender.name].sync = x;
		w.Repaint();
	end);
	w:Show(); w.Repaint();
	RDX.EnqueueMessage(RDXM.Logistics.p_req, reqid .. " 5 ");
end

-- On message receipt, respond with server time
RDXM.Logistics.reqDispatch[5] = function(id, sender, args)
	local str = GetTime();
	VFL.debug("RDXM.Logistics.SyncCheck(): got request 5, sending response " .. str, 10);
	RDX.EnqueueMessage(RDXM.Logistics.p_resp, id .. " " .. str);
end

-------------------------------------
-- REQUEST TYPE 6: DURABILITY
-------------------------------------
function RDXM.Logistics.GetDurability()
	local currDur, maxDur, brokenItems = 0, 0, 0;
	local itemIds = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 };
	for k, v in itemIds do
		VFLTip:ClearLines();
		VFLTip:SetInventoryItem("player", v);
		for i = 1, VFLTip:NumLines(), 1 do
			local _, _, sMin, sMax = string.find(getglobal("VFLTipTextLeft" .. i):GetText() or "", "^Durability (%d+) / (%d+)$");
			if ( sMin and sMax ) then
				local iMin, iMax = tonumber(sMin), tonumber(sMax);
				if ( iMin == 0 ) then
					brokenItems = brokenItems + 1;
				end
				currDur = currDur + iMin;
				maxDur = maxDur + iMax;
				break;
			end
		end
	end
	return currDur, maxDur, brokenItems;
end

-- Start dura check
function RDXM.Logistics.DoDurabilityCheck()
	-- First create a window.
	local w = RDXM.LogisticsWindow:new();
	w:Setup("Durability", 110);
	-- The window's content shall consist of all raiders, together with a value indicating their durability
	w.ntbl = {}; w.list = {};
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if u:IsValid() then
			local t = { unit = u; dfrac = -1; broken = 0; }
			table.insert(w.list, t);
			w.ntbl[u.name] = t;
		end
	end
	w.Repaint = function()
		-- Sort by durability
		table.sort(w.list, function(ud1,ud2) return (ud1.dfrac > ud2.dfrac); end);
		RDX.LayoutRDXWindow(w, table.getn(w.list), 0, 1, table.getn(w.list), w.fnAcquireCell);
		RDX.PaintRDXWindow(w, w.list, 0, w.displayed, w.fnApplyData);
	end
	w.fnApplyData = function(ud, c)
		c:SetPurpose(1);
		local u = ud.unit;
		c.text1:SetText(u:GetProperName()); c.text1:SetTextColor(1,1,1);
		c.bar1:SetStatusBarColor(0.7, 0.7, 0);
		if(ud.dfrac < 0) then
			c.text2:SetTextColor(0.5,0.5,0.5); c.text2:SetText("No resp.");
			c.bar1:SetValue(0);
		else
			c.text2:SetTextColor(0.8,0.8,0.8); c.text2:SetText(string.format("%0.0f%% (%d)", ud.dfrac * 100, ud.broken));
			c.bar1:SetValue(ud.dfrac);
		end
		c.OnClick = function() TargetUnit(u.uid); end
	end
	RPC.Evoke(30, function(sender, tbl)
		if not w.ntbl[sender.name] then return; end
		w.ntbl[sender.name].dfrac = tbl.dfrac;
		w.ntbl[sender.name].broken = tbl.broken;
		w.Repaint();
	end, "logistics_dura");
	w:Show(); w.Repaint();
end

RPC.Bind("logistics_dura", function(sender)
	-- if not sender:IsLeader() then return; end -- (removed 12.25)
	local c,m,b = RDXM.Logistics.GetDurability();
	local dfrac = 0;
	if(m > 0) then dfrac = c/m; end
	return { dfrac = dfrac, broken = b };
end);




-------------------------------------------------
-- REQUEST TYPE 7: Release Version
-------------------------------------------------
function RDXM.Logistics.DoVersionCheck()
	local w = RDXM.LogisticsWindow:new();
	w:Setup("RDX Release Vers.", 90);
	w.list = {}; w.ntbl = {};
	for i=1,40 do
		local u = RDX.GetUnitByNumber(i);
		if u:IsValid() then
			local t = { unit = u; sync = -1; }
			table.insert(w.list, t);
			w.ntbl[u.name] = t;
		end
	end
	w.Repaint = function()
		table.sort(w.list, function(ud1,ud2) return (ud1.unit.name < ud2.unit.name); end);
		RDX.LayoutRDXWindow(w, table.getn(w.list), 0, 1, table.getn(w.list), w.fnAcquireCell);
		RDX.PaintRDXWindow(w, w.list, 0, w.displayed, w.fnApplyData);
	end
	w.fnApplyData = function(ud, c)
		c:SetPurpose(5); local u = ud.unit;
		c.text1:SetText(u:GetProperName()); c.text1:SetTextColor(1,1,1);
		if(ud.sync < 0) then
			c.text2:SetTextColor(0.5, 0.5, 0.5); c.text2:SetText("Desync");
		else
			c.text2:SetTextColor(0.8, 0.8, 0.8); c.text2:SetText(string.format("%0.2f", ud.sync));
		end
	end
	local reqid = RDXM.Logistics.GenID();
	w.reqid = reqid;
	RDXM.Logistics.RegisterResponseHandler(reqid, function(id, sender, args)
		local x = tonumber(args); if not x then return; end
		if not w.ntbl[sender.name] then return; end
		w.ntbl[sender.name].sync = x;
		w.Repaint();
	end);
	w:Show(); w.Repaint();
	RDX.EnqueueMessage(RDXM.Logistics.p_req, reqid .. " 7 ");
end

-- On message receipt, respond with server time
RDXM.Logistics.reqDispatch[7] = function(id, sender, args)
	local str = RDX.CurrentVersion;

	VFL.debug("RDXM.Logistics.SyncCheck(): got request 7, sending response " .. str, 10);
	RDX.EnqueueMessage(RDXM.Logistics.p_resp, id .. " " .. str);
end

-------------------------------------
-- FORCE LOGOUT
-------------------------------------
function RDXM.Logistics.ForceLogoutCallback(flg, name)
	-- They clicked " cancel", just ignore
	if not flg then return; end
	RPC.Invoke("officer_requested_logout", name);
end

function RDXM.Logistics.ForceLogout()
	-- Pop up a name prompt
	VFL.CC.Popup(RDXM.Logistics.ForceLogoutCallback, "Force Logout", "Enter the name of the person to log out", "");
end

function RDXM.Logistics.ForceLogout_RPC(sender, name)
	if sender:IsLeader() then
		if string.lower(UnitName("player")) == string.lower(name) then
			Logout();
		end
	end
end
RPC.Bind("officer_requested_logout", RDXM.Logistics.ForceLogout_RPC);

-----------------------------------
-- MENU
-----------------------------------
function RDXM.Logistics:Menu(tree, frame)
	local mnu = {};
	-- If the player is not a leader, show him a stub menu (removed 12.25)
	local pu = RDX.GetPlayerUnit();
	if (not pu) then
		table.insert(mnu, { text = strcolor(.5,.5,.5) .. "(debug: playerunit not found)|r" }); -- was leaders only
	else
		table.insert(mnu, {
			text = "Sync Check", OnClick = function() RDXM.Logistics.DoSyncCheck(); tree:Release(); end
		});
		table.insert(mnu, {
			text = "Ready Check", OnClick = function() RDXM.Logistics.DoReadyCheck(); tree:Release(); end
		});
		table.insert(mnu, {
			text = "Who's Not Here", OnClick = function() RDXM.Logistics.DoWhosNotHere(); tree:Release(); end
		});
		table.insert(mnu, {
			text = "Resist Check",
			OnClick = function() 
				RDXM.Logistics.DoResistCheck(); 
				tree:Release();
			end
		});
		table.insert(mnu, {
			text = "Durability Check",
			OnClick = function() RDXM.Logistics.DoDurabilityCheck(); tree:Release(); end
		});
		table.insert(mnu, {
			text = "Inventory Check",
			isSubmenu = true,
			OnClick = function() RDXM.Logistics.MenuInventoryCheck(tree, this); end
		});
		table.insert(mnu, {
			text = "Version Check", OnClick = function() RDXM.Logistics.DoVersionCheck(); tree:Release(); end
		});
		table.insert(mnu, {
			text = "Version Warn", OnClick = function() RDXM.Logistics.VersionWarn(); tree:Release(); end
		});
		table.insert(mnu, {
			text = "Force Logout", OnClick = function() RDXM.Logistics.ForceLogout(); tree:Release(); end
		});
		table.insert(mnu,{
			text="Raid Status Window", OnClick = function() RDXM.Logistics.RaidStatus.Toggle(); tree:Release(); end
		});
	end
	tree:Expand(frame, mnu);
end

function RDXM.Logistics.MenuInventoryCheck(tree, frame)
	local mnu = {};
	table.insert(mnu, { text = "Custom...",
		OnClick = function() 
			VFL.CC.Popup(
				function(flg,txt)
					if(flg) then 
						-- Update MRU list
						table.insert(RDXM.Logistics.MRUItems, 1, txt);
						VFL.asize(RDXM.Logistics.MRUItems, 4, nil);
						-- Run inventory query
						RDXM.Logistics.DoInventoryCheck(txt); 
					end
				end,
				"Inventory Check", "Enter the name of the item to check", ""
			);
			tree:Release();
		end
	});
	table.insert(mnu, {
		text = "Aqual Quintessence",
		OnClick = function() 
			RDXM.Logistics.DoInventoryCheck("Aqual Quintessence");
			tree:Release();
		end
	});
	table.insert(mnu, {
		text = "Greater Nature Protection Potion",
		OnClick = function() 
			RDXM.Logistics.DoInventoryCheck("Elementium Ore");
			tree:Release();
		end
	});
	table.insert(mnu, {
		text = "Hourglass Sand",
		OnClick = function() 
			RDXM.Logistics.DoInventoryCheck("Hourglass Sand");
			tree:Release();
		end
	});
	table.insert(mnu, {
		text = "Nature Protection Potion",
		OnClick = function() 
			RDXM.Logistics.DoInventoryCheck("Nature Protection Potion");
			tree:Release();
		end
	});
	table.insert(mnu, {
		text = "Soul Shard",
		OnClick = function() 
			RDXM.Logistics.DoInventoryCheck("Soul Shard");
			tree:Release();
		end
	});
	-- MRU list
	local i = 1;
	for _,v in RDXM.Logistics.MRUItems do
		local cl = v; -- Tightly bind closure
		table.insert(mnu, { text = i .. ". " .. cl, OnClick = function() RDXM.Logistics.DoInventoryCheck(cl); tree:Release(); end });
		i=i+1;
	end
	tree:Expand(frame, mnu);
end

-----------------------------------
-- INIT/REGISTRATION
-----------------------------------
-- Init
function RDXM.Logistics.Init()
	VFL.debug("RDXM.Logistics.Init()", 2);
	RDXM.Logistics.MRUItems = {};
	
	-- Register protocols
	RDXM.Logistics.p_req = RDX.RegisterProtocol({
		id = 100; name = "Logistics: Request";
		replace = false; highPrio = false; realtime = true;
		handler = RDXM.Logistics.RequestHandler;
	});
	RDXM.Logistics.p_resp = RDX.RegisterProtocol({
		id = 101; name = "Logistics: Response";
		replace = false; highPrio = false; realtime = true;
		handler = RDXM.Logistics.ResponseHandler;
	});
	
	 RDXM.Logistics.RaidStatus.Init()
end


function RDXM.Logistics.VersionWarn()
	RPC.Invoke("logistics_version_warning", RDX.CurrentVersion);
	VFL.print("A version warning RPC was broadcasted.  Anyone with a version less than " .. string.format("%0.2f", RDX.CurrentVersion) .. " will be notified.");
end

function RDXM.Logistics.WarnIfVersionOutOfDate(sender, n)

	local broadcastedversion = n;
	if broadcastedversion > RDX.CurrentVersion then
		VFL.print("[RDX] Please be aware that your RDX5 is out of date.  You are using Release " .. string.format("%0.2f", RDX.CurrentVersion) .. " and the current Release Version is " .. string.format("%0.2f", broadcastedversion) .. ".");
	end
end

RPC.Bind("logistics_version_warning", RDXM.Logistics.WarnIfVersionOutOfDate);









-- Registration
RDXM.Logistics.module = RDX.RegisterModule({
	name = "logistics";
	title = "Logistics";
	DeferredInit = RDXM.Logistics.Init;
	Menu = RDXM.Logistics.Menu;
});
