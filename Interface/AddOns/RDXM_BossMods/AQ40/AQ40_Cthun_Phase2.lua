
------------------------------------
-- C'thun Phase 2
------------------------------------
local cthun2_track
local cthun2_sigupdate
local eye_lock2

local cthun2_eye_track
local cthun2_eye_sigupdate

local cthun2_giant_claw_track
local cthun2_giant_claw_sigupdate

local cthunweak_lockout

cthun_window = nil; --note this is not local - this window is shared with cthun phase 1.

function RDXM.AQ.Cthun2Activate()

	-- Tracking (cthun)
	cthun2_track = HOT.TrackTarget("C'thun");
	cthun2_sigupdate = cthun2_track.SigUpdate:Connect(RDXM.AQ, "Cthun2Update");
	
	VFLEvent:NamedBind("cthun2", BlizzEvent("CHAT_MSG_MONSTER_EMOTE"), function() RDXM.AQ.Cthun2CheckWeakened(arg1); end);
	VFLEvent:NamedBind("cthun2", BlizzEvent("CHAT_MSG_EMOTE"), function() RDXM.AQ.Cthun2CheckWeakened(arg1); end);
	
	if RDXM.Logistics then
		--launch stumock monitor
		RDXM.AQ.CthunStumock.Show()
	else
		VFL.print("You must have the Logistics module to show the Stumock Monitor")
		return;
	end
	
	
end

function RDXM.AQ.Cthun2Start()
	cthunweak_lockout = false;
	eye_lock2 = false;
	
	-- Tracking (Eye Tentacle)
	cthun2_eye_track = HOT.TrackTarget("Eye Tentacle");
	cthun2_eye_sigupdate = cthun2_eye_track.SigUpdate:Connect(RDXM.AQ, "Cthun2EyeUpdate");
	
		-- Tracking (Giant Claw)
	cthun2_giant_claw_track = HOT.TrackTarget("Giant Claw Tentacle");
	cthun2_giant_claw_sigupdate = cthun2_giant_claw_track.SigUpdate:Connect(RDXM.AQ, "Cthun2EyeUpdate");

	RPC.Bind("cthun2_eyes", RDXM.AQ.Cthun2EyesRPC);
	RPC.Bind("cthun2_weak", RDXM.AQ.Cthun2WeakRPC);
			
end

function RDXM.AQ.Cthun2WeakRPC()
	if not cthunweak_lockout then
		--lockout
		cthunweak_lockout = true;
		VFL.scheduleExclusive("cthun2_unlockweak", 30, function() cthunweak_lockout = false; end);
		
		--remove eyeunlock
		VFL.removeScheduledEventByName("cthun2_unlockeye");
		--remove dropdown(s)
		RDX.QuashAlertsByPattern("^cthun2_")
		--lock eyes for 45 seconds
		eye_lock2 = true;
		VFL.scheduleExclusive("cthun2_unlockeye", 45, function() eye_lock2 = false; end);
		
		--show centerpopup
		RDX.Alert.CenterPopup("cthun2_weakened", "CTHUN IS WEAKENED!", 45, sound, 0, {r=1,g=.1,b=1}, nil, true);
		
	end
end

function RDXM.AQ.Cthun2Stop()

	--Get rid of any linguering alerts
	RDX.QuashAlertsByPattern("^cthun2_")
	--unbind any scheduled events
	VFL.removeScheduledEventByName("cthun2_unlockeye");
	VFL.removeScheduledEventByName("cthun2_unlockweak");
	
	--unbind RPC
	VFLEvent:NamedUnbind("cthun2");	
	
	--unbind hottrack (eye)
	if cthun2_eye_track then
		cthun2_eye_track.SigUpdate:DisconnectByHandle(cthun2_eye_sigupdate);
		cthun2_eye_sigupdate = nil; cthun2_eye_track=nil;
	end
		
	--unbind hottrack (giant claw)
	if cthun2_giant_claw_track then
		cthun2_giant_claw_track.SigUpdate:DisconnectByHandle(cthun2_giant_claw_sigupdate);
		cthun2_giant_claw_sigupdate = nil; cthun2_giant_claw_track = nil;
	end
	
end

function RDXM.AQ.Cthun2Deactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("cthun2");
	
	--unbind hottrack
	if cthun_track then
		cthun2_track.SigUpdate:DisconnectByHandle(cthun2_sigupdate);
		cthun2_sigupdate = nil; cthun2_track = nil;
	end
	

	
end



function RDXM.AQ.Cthun2Update()
	RDX.AutoStartStopEncounter(cthun2_track);
	RDX.AutoUpdateEncounterPane(cthun2_track);
end

function RDXM.AQ.Cthun2EyeUpdate()
	
	if eye_lock2 == true then return; end
	
	if (not cthun2_eye_track:IsTracking()) and (not cthun2_giant_claw_track:IsTracking()) then
		return; 
	else
		--we are tracking either an eye or a giant claw tentacle
		--let's RPC the event...
		RPC.Invoke("cthun2_eyes");

	end	

end

function RDXM.AQ.Cthun2CheckWeakened(arg1)

	if arg1 == nil then return; end
	
	if string.find(arg1, "is weakened!") then
		RPC.Invoke("cthun2_weak");
	end

end

function RDXM.AQ.Cthun2ShowEyeTimer()

	RDX.QuashAlertsByPattern("^cthun2_nexteyes")
	RDX.Alert.Dropdown("cthun2_nexteyes", "Next Eyes + Giant XXX!", 30, 5, "Sound\\Doodad\\BellTollAlliance.wav")
	
end

function RDXM.AQ.Cthun2EyesRPC()
	if eye_lock2 == true then return; end
	
	RDXM.AQ.Cthun2ShowEyeTimer()
	--lock for 20 sec		
	eye_lock2 = true;
	VFL.scheduleExclusive("cthun2_unlockeye", 25, function() eye_lock2 = false; end);

end



-----------------------------------------
-- Stumock Monitor code
-----------------------------------------

if not RDXM.AQ.CthunStumock then RDXM.AQ.CthunStumock = {}; end
--******************
-- Creates the window structure, and shows it.
-- Also defines functions for window updating, and click actions
--******************

function RDXM.AQ.CthunStumock.Show()

	if not cthun_window then cthun_window = RDXM.AQ.CthunStumock.GetWindow(); end
	
	--let's make sure it is named correctly
	cthun_window.window.text:SetText("The Stumock");		
	--remove any other running 'threads'
	VFL.removeScheduledEventByName("cthun1_heartbeat");
	VFL.removeScheduledEventByName("cthun2_heartbeat");
	--start the heartbeat
	RDXM.AQ.CthunStumock.HeartBeat()


end

function RDXM.AQ.CthunStumock.GetWindow()
	-- First create a window.
	local w = RDXM.LogisticsWindow:new();
	w:Setup("The Stumock", 105);
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
		cthun_window = nil; --remove reference
	end
	-- Apply data function paints name and zone
	w.fnApplyData = function(ud, c)
		--local u = ud.unit;
		c:SetPurpose(1);
		c.text1:SetText(ud.title); 
		c.text1:SetTextColor(1,1,1);
		c.text2:SetText(ud.valuestr); --valuestr will be the stumock debuff count
		c.text2:SetTextColor(0.8,0.8,0.8);
		c.bar1:SetStatusBarColor(ud.r, ud.g, ud.b);
		c.bar1:SetValue(ud.val);
		c.OnClick = function() TargetByName(ud.title); end
		
	end


	--show the window
	w:Show();
	w.Repaint();
	return w;
end

function RDXM.AQ.CthunStumock.Update()

	if not cthun_window then return; end
	if not RDX.unit then return; end
	
	--clear the current list
	cthun_window.list = {}
	
	
	--lets loop through our DB and check who has the stumock debuff
	--if they do, add them to our list with their HP
	for i=1,40 do
		--L O W E R C A S E to match buffs :)))
		if RDX.unit[i]:HasDebuff("digestive acid") then
		--if RDX.unit[i]:HasDebuff("recently bandaged") then -- TEST
			--we found someone with the debuff
			thisMember = {}
			thisMember.title = RDX.unit[i].name;
			thisMember.r = .1;
			if RDX.unit[i]:IsHealer() then
				--for healers show a blue bar representing their mana
				thisMember.val = RDX.unit[i]:FracMana();
				thisMember.valuestr = RDX.unit[i]:Mana() .. "/" .. RDX.unit[i]:MaxMana();
				thisMember.g = .1;
				thisMember.b = 1;	
			else
				--for everyone else show a green bar representing their health
				thisMember.val = RDX.unit[i]:FracHealth();
				thisMember.valuestr = RDX.unit[i]:Health() .. "/" .. RDX.unit[i]:MaxHealth();
				thisMember.g = 1;
				thisMember.b = .1;
			end
			table.insert(cthun_window.list, thisMember);
		end
	end
	
	cthun_window.Repaint();

end

function RDXM.AQ.CthunStumock.HeartBeat()
	if not cthun_window then return; end --the heartbeat will stop if they close the window.

	RDXM.AQ.CthunStumock.Update()	
	VFL.scheduleExclusive("cthun2_heartbeat", 1, function() RDXM.AQ.CthunStumock.HeartBeat(); end); --1 second heartbeat
		
end













--------------------------------------
-- Encounter Registration
--------------------------------------

RDXM.AQ.enctbl["cthun2"] = {
	ActivateEncounter = RDXM.AQ.Cthun2Activate;
	DeactivateEncounter = RDXM.AQ.Cthun2Deactivate;
	StartEncounter = RDXM.AQ.Cthun2Start;
	StopEncounter = RDXM.AQ.Cthun2Stop;
};