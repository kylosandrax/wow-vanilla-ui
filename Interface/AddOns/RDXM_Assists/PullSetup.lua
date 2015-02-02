-- PullSetup.lua
-- RDX5 - Raid Data Exchange
-- (C)2005 Bill Johnson (Venificus of Eredar server)
--
-- Pull setup subsystem for the RDX5 Assists module.

-- Pull setup: Main window/functionality
-- 3 columns: Unit, last known target, status
-- For N seconds after assist request, continue checking if my target is
-- his target. If so, confirm.
function RDXM.Assists.CreatePullSetupWindow()
	local w = {};
	RDX.Window.MakeContainer(w, 4);
	-- Window related
	w.visible = false;
	w.window:ClearAllPoints();
	w.window:SetPoint("CENTER", UIParent, "CENTER");

	w.window.text:SetText("Pull Setup");
	getglobal(w.window:GetName() .. "TitleBkg"):SetGradient("HORIZONTAL", 0, 0, 0.9, 0, 0, 0.1);
	
	w.window.btnClose.OnClick = function() w:Hide(); end
	w.window.btnI.OnMouseDown = function()
		if(arg1 == "LeftButton") then
			if(IsShiftKeyDown()) then
				w.window:StartMoving();
			else
				w:Clear();
			end
		end
	end
	w.window.btnI.OnMouseUp = function() 
		w.window:StopMovingOrSizing();
		if(arg1 == "RightButton") then w:Menu(); end
	end

	w.grid:SetColumnPadding(0); w.grid:SetRowPadding(0);
	w.grid:SetDefaultColumnWidth(190); w.grid:SetDefaultRowHeight(14);

	function w:Show()
		self.visible = true; self.window:Show(); self.window:SetFrameLevel(1);
	end
	function w:Hide()
		self.visible = false; self.grid:Destroy(); self.window:Hide();
	end

	function w:CountValidClients()
		local i = 0;
		for _,v in self.cli do
			if v.track:GetUnit() then i = i + 1; end
		end
		return i;
	end

	-- Painting subroutines
	function w:PaintName(c, ud, u)
		c.text1:SetText(u:GetProperName());
		if u:IsOnline() then
			c.text1:SetTextColor(explodeColor(u:GetClassColor()));
			return true;
		else
			-- Not online, clear all text boxes
			c.text1:SetTextColor(0.5, 0.5, 0.5);
			c.text3:SetText(""); c.text2:SetText("");
			return false;
		end
	end
	function w:PaintTarget(c, ud, u)
		-- If in range...
		if u:IsNear() then
			local n = UnitName(u.uid .. "target");
			if n then
				-- Setup target name
	 			c.text3:SetTextColor(0.4, 0.7, 0.7);
				c.text3:SetText(UnitName(u.uid .. "target")); 
				-- Verify a pending assist
				w:CheckTargetStatus(ud, u);
			else
				c.text3:SetText("(no target)"); c.text3:SetTextColor(0.5, 0.5, 0.5);
			end
		else
			-- OOR, no target data.
			c.text3:SetText("(no data)"); c.text3:SetTextColor(0.5, 0.5, 0.5);
		end
	end
	function w:PaintStatus(c, ud, u)
		if ud.status == 0 then
			if ud.err then -- Error
				c.text2:SetText(ud.err); c.text2:SetTextColor(1,0,0);
			else -- No status
				c.text2:SetText("");
			end
		elseif ud.status == 1 then -- Pending
			c.text2:SetText("Wait"); c.text2:SetTextColor(0.6, 0.6, 0.6);
		elseif ud.status == 2 then -- Assisted
			c.text2:SetText("OK?"); c.text2:SetTextColor(1, 1, 0);
		elseif ud.status == 3 then
			c.text2:SetText("OK!"); c.text2:SetTextColor(0, 1, 0);
		end
	end

	function w:Repaint()
		if not self.visible then return; end
		-- Layout phase
		self.grid:Size(1, self:CountValidClients(), self.fnAcquireCell);
		self.grid:Layout();
		local dx,dy = self.grid:GetExtents();
		if(dx == 0) or (dy == 0) then dy = 1; dx = 190; end
		self.window:Accomodate(dx, dy);

		-- Paint phase
		local r = 1; local idx, x, c;
		-- Foreach tracking client...
		for idx,x in self.cli do
			-- If they have a valid unit...
			local u = x.track:GetUnit();
			if u then
				local c = self.grid:GetCell(1, r); c.OnClick = nil;
				c:SetPurpose(7); c:Show();
				-- Bind onclick
				local cl_idx = idx; -- Tightly bind closure
				c.OnClick = function()
					if(arg1 == "RightButton") then
						self:RemoveClientByIndex(cl_idx);
					elseif(arg1 == "LeftButton") then
						self:InstructClientByIndex(cl_idx);
					end
				end
				-- Paint the data...
				if self:PaintName(c, x, u) then
					self:PaintTarget(c, x, u);
					self:PaintStatus(c, x, u);
				end -- if self:PaintName
				r=r+1;
			end -- if u
		end -- for idx,x in self.cli
	end

	-- Data-related
	w.cli = {};
	w.cliByName = {};
	
	-- Functionality
	-- Add a unit as a client
	function w:AddClient(name)
		if (not name) then return; end
		-- Create data
		local track = RDX.TrackRaider(name);
		local data = { name = name; track = track; err = nil; status = 0; }
		-- Update tables
		table.insert(self.cli, data);
		self.cliByName[name] = data;
	end

	-- Add by class id
	function w:AddByClassID(id)
		for i=1,40 do
			local u = RDX.GetUnitByNumber(i);
			if u:IsValid() and (u.class == id) then self:AddClient(u.name); end
		end
	end

	-- Remove a client by number
	function w:RemoveClientByIndex(idx)
		local d = self.cli[idx]; if not d then return; end
		self.cliByName[d.name] = nil; table.remove(self.cli, idx);
	end

	-- Instruct a client by index
	function w:InstructClientByIndex(idx)
		local d = self.cli[idx]; if not d then return; end
		self:InstructClient(d);
	end

	-- Instruct a client to assist
	function w:InstructClient(ud)
		VFL.debug("PullSetup:InstructClient(" .. ud.name .. ")", 7);
		-- If I don't have a target, this is all nonsense
		if (not UnitName("target")) then
			RDX.print("[RDX] Pull Setup: You must have a target in order to request an assist.");
			return;
		end
		-- Find the unit
		local u = ud.track:GetUnit();
		if not u then 
			VFL.debug("PullSetup:InstructClient(): unit not found.", 1);
			return; 
		end
		-- If something is already pending for the unit, forget it
		if(self.pending) or (ud.status == 1) then 
			RDX.print("[RDX] Pull Setup: An assist process is already in progress; wait for it to timeout.");
			return; 
		end
		-- Generate an ID to mark this transaction
		local id = math.random(100000000); ud.id = id; ud.status = 1;
		self.pending = id;
		-- In 5 seconds, if no success, timeout
		VFL.schedule(5, function() self:ClientError(ud, id, "T/O"); end);
		-- Broadcast the assist order.
		RDX.EnqueueMessage(RDXM.Assists.setupReq, id .. " " .. u.name);
	end

	-- Update a client's error status.
	function w:ClientError(ud, id, err)
		VFL.debug("PullSetup:ClientError(" .. ud.name .. "," .. id .. "," .. err .. ")", 10);
		if(ud.id == id) and (self.pending == id) and (ud.status == 1) then
			self.pending = nil; ud.status = 0; ud.err = err;
		end
	end

	-- Reset a client's status
	function w:ClientReset(ud, id)
		if(ud.id == id) then
			ud.id = nil; ud.status = 0; ud.err = nil;
		end
	end

	-- Clear all client status
	function w:Clear()
		self.pending = nil;
		for _,cli in self.cli do
			cli.status = 0; cli.err = nil; cli.id = nil;
		end
	end

	-- Check a client's status against a piece of unit data
	function w:CheckTargetStatus(ud, u)
		-- If there's a pending assist, and he acquired the target...
		if ((ud.status == 1) or (ud.status == 2)) and UnitIsUnit("target", u.uid .. "target") then
			VFL.debug("PullSetup:CheckTargetStatus(" .. ud.name .. "): confirmed successful assist.", 10);
			-- Mark the target as acquired.
			ud.status = 3; self.pending = nil;
		end
	end
	
	-- The popup menu
	function w:Menu(tree)
		-- Init tree
		local tree = VFL.poptree;
		tree:Begin(80, 15, w.window, "TOP");
		-- Gen menu
		local mnu = {};
		for _,class in RDX.classes do
			local color,name,id = class.color,VFL.capitalize(class.name),class.id;
			table.insert(mnu, {
				text = strcolor(explodeColor(color)) .. name .. "|r",
				OnClick = function() tree:Release(); self:AddByClassID(id); end
			});
		end
		-- Show menu
		tree:Expand(nil, mnu);
	end

	return w;
end

-- Attempt to assist the sender. Send back a response with details of success/failure
function RDXM.Assists.SetupRequestHandler(proto, sender, data)
	-- Check for valid, leadered unit
	if (not sender) or (not sender:IsValid()) or (not sender:IsLeader()) then return; end
	-- Parse the request
	local _,_,id,name = string.find(data, "^(%d+) (.*)$");
	if not name then 
		VFL.debug("RDXM.Assists.SetupRequestHandler(): Malformed pull setup request.", 3);
		return; 
	end
	-- If it's not me who's being told to assist, ignore
	if(name ~= string.lower(UnitName("player"))) then return; end
	-- See if the sender is in range. If not, return failure codes
	if(not sender:IsNear()) then
		RDX.print("[RDX] Pull Setup: Tried to assist " .. sender:GetProperName() .. ", but you were out of range.");
		RDX.EnqueueMessage(RDXM.Assists.setupResp, id .. " 0");
		return;
	end
	-- Otherwise, assist and return target acquired.
	AssistUnit(sender.uid);
	RDX.print("[RDX] Pull Setup: Assisted " .. sender:GetProperName() .. ".");
	RDX.EnqueueMessage(RDXM.Assists.setupResp, id .. " 1");
end

-- Handle setup responses after assist succeeds/fails
function RDXM.Assists.SetupResponseHandler(proto, sender, data)
	-- Validate sender
	if (not sender) or (not sender:IsValid()) then return; end
	-- Find client record
	local w = RDXM.Assists.wPullSetup;
	local ud = w.cliByName[sender.name];
	if not ud then return; end
	-- Parse it
	local _,_,id,data = string.find(data, "^(%d+) (%d+)$");
	id = tonumber(id); data = tonumber(data);
	if(not id) or (not data) then 
		VFL.debug("RDXM.Assists.SetupResponseHandler(): Malformed pull setup response.", 3);
		return;
	end
	-- Check against pending requests
	if (id ~= ud.id) or (id ~= w.pending) then
		VFL.debug("RDXM.Assists.SetupResponseHandler(): Got response for a request other than the pending one.", 3);
		return;
	end
	if(ud.status ~= 1) then
		VFL.debug("RDXM.Assists.SetupResponseHandler(): Got response for an already satisfied request.", 3);
		return;
	end
	if data == 0 then -- Failure code
		w:ClientError(ud, id, "Failed");
	elseif data == 1 then -- Partial success code
		ud.status = 2; ud.id = nil; w.pending = nil;
	end
end

-- Comms protocols
RDXM.Assists.setupReq = RDX.RegisterProtocol({
	id = 102; name = "Assists: Pull Setup Request";
	replace = false; highPrio = false; realtime = true;
	handler = RDXM.Assists.SetupRequestHandler;
});
RDXM.Assists.setupResp = RDX.RegisterProtocol({
	id = 103; name = "Assists: Pull Setup Response";
	replace = false; highPrio = false; realtime = true;
	handler = RDXM.Assists.SetupResponseHandler;
});
