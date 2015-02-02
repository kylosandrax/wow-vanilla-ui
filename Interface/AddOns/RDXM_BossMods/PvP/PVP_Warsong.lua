
local reztimer_lock = false;
local lastUpdate = nil;

function RDXM.PVP.WarsongActivate()

	TRACK_PVP_PLAYERS = true;
	RDXM.PVP.WarsongWindowShow();
	
end

function RDXM.PVP.WarsongDeactivate()

	TRACK_PVP_PLAYERS = false;

end

local DO_SCAN = true;

function scanoff()
	DO_SCAN = false;
	return "Scanning disabled."
end
function scanon()
	DO_SCAN = true;
	return "Scanning enabled."
end

function RDXM.PVP.WarsongStart()
	
	VFL.print("Scanning should be active... to stop auto-scanning type /x scanoff()")
	RequestBattlefieldScoreData() --Refreshes the list
	
	reztimer_lock = false;
	 
	-- Events
	--VFLEvent:NamedBind("warsong", BlizzEvent("PLAYER_DEAD"), function() RDXM.PVP.WarsongPlayerDiedEvent(); end);
	--VFLEvent:NamedBind("warsong", BlizzEvent("PLAYER_UNGHOST"), function() RDXM.PVP.WarsongSpiritRezEvent(); end);
	-- RPC Binds
	--RPC.Bind("warsong_reztimer", RDXM.PVP.WarsongRezTimerEvent);
	
	VFL.schedule(1, function() RDXM.PVP.BeginTrackAllEnemiesInBattleground(); end)
	 
	
end

function RDXM.PVP.WarsongStop()
	
	RDX.QuashAlertsByPattern("^warsong_");
	
	--remove scheduled loop
	VFL.removeScheduledEventByName("warsong_reztimer");
		
	
	-- Unbind Events
	VFLEvent:NamedUnbind("warsong");
	-- Unbind RPCs
	RPC.UnbindPattern("^warsong_");
	
end


function RDXM.PVP.WarsongRezTimerEvent()
	
	if (reztimer_lock==false) then
		reztimer_lock = true;
	
		--remove any scheduled loop
		VFL.removeScheduledEventByName("warsong_reztimer");
			
		-- start rez timer
		--RDX.QuashAlertsByPattern("^warsong_");
		--RDX.Alert.Dropdown("warsong_reztimer", "Next Resurrection", 30, 1, nil)
				
		--start recursive loop.
		RDXM.PVP.WarsongRezTimerLoop()
		--VFL.scheduleExclusive("warsong_reztimer", 32, function() RDXM.PVP.WarsongRezTimerLoop(); end);
		--VFL.schedule(3, function() reztimer_lock = false; end);
		--Note i set this to never unlock unless the mod is stopped and restarted cause it seems accurate
		-- and i have no way of knowing if somoene clicked "accept" to a body rez (compared to autorez)
		-- if it gets desynced the mod should just be stopped and restarted
		
	end
		
end


function RDXM.PVP.WarsongPlayerDiedEvent()
	--Auto Release!
	RepopMe();

end

function RDXM.PVP.WarsongSpiritRezEvent()
		
	--RPC the rez timer!
	RPC.Invoke("warsong_reztimer")

end

function RDXM.PVP.WarsongRezTimerLoop()

		--remove any scheduled loop
		VFL.removeScheduledEventByName("warsong_reztimer");
		RDX.QuashAlertsByPattern("^warsong_");
		
		--do another dropdown.
		RDX.Alert.Dropdown("warsong_reztimer", "Next Resurrection...", 33.5, 1, nil)
		--recursive
		VFL.scheduleExclusive("warsong_reztimer", 33.5, function() RDXM.PVP.WarsongRezTimerLoop(); end);

end




RDXM.PVP.enctbl["warsong"] = {
	ActivateEncounter = RDXM.PVP.WarsongActivate;
	DeactivateEncounter = RDXM.PVP.WarsongDeactivate;
	StartEncounter = RDXM.PVP.WarsongStart;
	StopEncounter = RDXM.PVP.WarsongStop;
};



------------------------------------------------
-- TEST CODE for new pvp mod.
------------------------------------------------


warsong_window = nil;

--NOTE: warsong_window.list  is the list of nearby horde.

--------------------
-- Show the window
--------------------

function RDXM.PVP.WarsongWindowShow()

	if not warsong_window then warsong_window = RDXM.PVP.GetWindow(); end
	
	--let's make sure it is named correctly
	warsong_window.window.text:SetText("Nearby Enemies");		
	--remove any other possible running 'threads'
	VFL.removeScheduledEventByName("warsong_heartbeat");
	--start the heartbeat
	RDXM.PVP.WarsongHeartBeat()


end

local lastScan = 1
function RDXM.PVP.scanNext()

	if UnitAffectingCombat("player") == 1 then return; end -- do not auto scan if we are in combat
	

	local cnt = 1;
	local wescanned = false;
	for k,v in tt_targets do
	
		if cnt == lastScan + 1 then--this is what we want to scan!
			--VFL.print("cnt is " .. cnt .. " and lastScan is " .. lastScan);
			--lets scan this target.
			lastScan = lastScan + 1;
			wescanned = true;
			if k then

				local OurTarget = UnitName("target");
				TargetByName(v.name);
				if UnitName("target") then
					if string.lower(UnitName("target")) == k then
						--VFL.print("updating table");
						--we have a match!!! 
						v.health = UnitHealth("target");
						v.unitName = UnitName("target")
						v.healthMax = UnitHealthMax("target");
						v.unitManaMax = UnitManaMax("target");
						--fix friendly stuff for the hell of it
						if v.health > 100 then v.health = v.health / v.healthMax * 100 end;
						v.unit = "target"
						v.mana = UnitMana("target");
						v.class = UnitClass("target");
						v.lastUpdate = GetTime();
						v.valid = true;
					end
				end
				if OurTarget then TargetByName(OurTarget); else ClearTarget(); end
				--VFL.schedule(.2, function() RDXM.PVP.scanNext(); end)
				return;
			end
			
		end
		cnt = cnt + 1;
		
	end
	if not wescanned then lastScan = 0 end;

	--VFL.schedule(.2, function() RDXM.PVP.scanNext(); end)
end



function RDXM.PVP.TrackNearby()

	--This function will attempt to target all players that we are currently tracking.
	--If it successfully targets them, it will manually update our tracking table with the current
	--time, their hitpoints, class, etc
	

	local OurTarget = UnitName("target");
	--local cnt = 0;
	for k,v in tt_targets do
		if k then
			--VFL.print("Processing: " .. k);
			TargetByName(v.name)
			if UnitName("target") then
				--VFL.print("1")
				if string.lower(UnitName("target")) == k then
					--VFL.print("updating table");
					--we have a match!!! 
					v.health = UnitHealth("target");
					--VFL.print(v.health);
					v.unitName = UnitName("target")
					v.healthMax = UnitHealthMax("target");
					v.unitManaMax = UnitManaMax("target");
						--fix friendly stuff for the hell of it
						if v.health > 100 then v.health = v.health / v.healthMax * 100 end;
					v.unit = "target"
					v.mana = UnitMana("target");
					v.class = UnitClass("target");
					v.lastUpdate = GetTime();
					v.valid = true;
				end
			end
			
		end
		if OurTarget then TargetByName(OurTarget); end
		--cnt = cnt + 2;
	end

end

local LastKnownNumOfEnemies = 0;


function RDXM.PVP.WarsongUpdate()
	--update the contents of the window.
	--We will display players with <10s since last update
	
	warsong_window.list = {}
		--the "Scan" bar
	scan = {title="Scan";valuestr="Enemies";val=1};
	table.insert(warsong_window.list, scan);
	
	for k,v in tt_targets do
		
		local q;
		if v.unit then
			q = v.unit;
		else
			q = "?"
		end
		local lUpdate = GetTime() - v.lastUpdate
		
		--VFL.print(lUpdate);
				
		if v.lastUpdate ~= 0 and lUpdate < 7 then

			--this player has been targetted 7 or less seconds ago.
			
			thisMember = {}
			thisMember.title = k;
			thisMember.valuestr = v.class;-- v.health;
			thisMember.val = v.health / 100;
			thisMember.r = .1;
			thisMember.g = .9;
			thisMember.b = .1;
			table.insert(warsong_window.list, thisMember);
		
		end
		--VFL.debug("v ["..v.unitName.."]");
	end
	
	warsong_window.Repaint();

end
--------------------
-- Heartbeat
--------------------
local warsongupdatelimiter = 0;
function RDXM.PVP.WarsongHeartBeat()
	if not warsong_window then return; end --the heartbeat will stop if they close the window.

	if lastUpdate then
		--has it been 60 seconds since our last player update?
		if GetTime() - lastUpdate > 60 then
			--are we out of combat?
			if not UnitAffectingCombat("player") then
				lastUpdate = GetTime();
				RDXM.PVP.BeginTrackAllEnemiesInBattleground()
			end
		end
	else
		--we have never had an update
		lastUpdate = GetTime();
		RDXM.PVP.BeginTrackAllEnemiesInBattleground()
	end

	
	if DO_SCAN then RDXM.PVP.scanNext(); end --autoscan!
	
	
	if warsongupdatelimiter == 0 then
		RDXM.PVP.WarsongUpdate() --this only needs to be 1 second
		warsongupdatelimiter = warsongupdatelimiter + 1
	else
		warsongupdatelimiter = warsongupdatelimiter + 1
		if warsongupdatelimiter == 3 then warsongupdatelimiter = 0 end
	end
	VFL.scheduleExclusive("warsong_heartbeat", .25, function() RDXM.PVP.WarsongHeartBeat(); end); --.25 second heartbeat
	
end

--------------------
-- GET WINDOW
--------------------

function RDXM.PVP.GetWindow()
	-- First create a window.
	local w = RDXM.LogisticsWindow:new();
	w:Setup("Nearby Enemies", 105);
		w.list = {};
	w.Repaint = function()
		-- Layout the window
		RDX.LayoutRDXWindow(w, table.getn(w.list), 0, 1, table.getn(w.list), w.fnAcquireCell);
		-- Paint the window
		RDX.PaintRDXWindow(w, w.list, 0, w.displayed, w.fnApplyData);
	end
	w.window.btnClose.OnClick = function() 
		w.visible = nil;
		w.window:Hide(); 
		w.grid:Destroy();
		warsong_window = nil; --remove reference
	end
	-- Apply data function paints name / class / hp
	w.fnApplyData = function(ud, c)
		--local u = ud.unit;
		c:SetPurpose(1);
		c.text1:SetText(ud.title); 
		c.text1:SetTextColor(1,1,1);
		c.text2:SetText(ud.valuestr); --valuestr will be the class
		c.text2:SetTextColor(1,1,1);
		if ud.title == "Scan" then
			c.bar1:SetStatusBarColor(1,.2,.2);
			c.bar1:SetValue(ud.val);
			c.OnClick = function() RDXM.PVP.TrackNearby(); end
		else
			RDX.SetStatusBar(c.bar1, ud.val, RDXG.vis.cFriendHP, RDXG.vis.cFriendHPFade);
			c.OnClick = function() TargetByName(ud.title); end
		end

		
	end


	--show the window
	w:Show();
	w.Repaint();
	return w;
end



-- This function updates our tracking list.
function RDXM.PVP.BeginTrackAllEnemiesInBattleground()

	local numScores = GetNumBattlefieldScores();
	
	--clear tracking table.
	tt_targets = {};
	setmetatable(tt_targets, { __mode = 'v' }); -- Make this a weak table.
	local cnt = 0;
	--add tracking entries
	for i=1, numScores do

		name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class = GetBattlefieldScore(i);
		rankName, rankNumber = GetPVPRankInfo(rank, faction);
		local factionString;
		if (faction == 0) then
			factionString = "Horde";
		else
			factionString =	"Alliance";
		end
	
		if factionString ~= UnitFactionGroup("player") then
			--horde
			local sometrack
			local somesig
				-- Tracking
			--	sometrack = HOT.TrackTarget(name);
			--	somesig = sometrack.SigUpdate:Connect(RDX, "testSomething");
			HOT.TrackTarget(name);
			cnt = cnt + 1
		
		end
	end
	
	LastKnownNumOfEnemies = cnt;
	
end