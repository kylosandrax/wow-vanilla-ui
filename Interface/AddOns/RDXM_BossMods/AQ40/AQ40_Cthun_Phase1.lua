


------------------------------------
-- C'thun Phase 1
------------------------------------
local cthun1_track
local cthun1_sigupdate

local cthun1_eye_track
local cthun1_eye_sigupdate
local eye_lock = false


function RDXM.AQ.CthunActivate()

	-- Tracking
	cthun1_track = HOT.TrackTarget("Eye of C'thun");
	cthun1_sigupdate = cthun1_track.SigUpdate:Connect(RDXM.AQ, "CthunUpdate");
	
	if RDXM.Logistics then
		--launch stumock monitor
		RDXM.AQ.CthunTooCloseShow()
	else
		VFL.print("You must have the Logistics module to show the 'Too Close' Monitor")
		return;
	end
	
end

function RDXM.AQ.CthunDeactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("cthun");
	
	if cthun1_track then
		cthun1_track.SigUpdate:DisconnectByHandle(cthun1_sigupdate);
		cthun1_sigupdate = nil; cthun1_track = nil;
	end

end


function RDXM.AQ.CthunStart()

	eye_lock = false

	--start hottracking eyes
	cthun1_eye_track = HOT.TrackTarget("Eye Tentacle");
	cthun1_eye_sigupdate = cthun1_eye_track.SigUpdate:Connect(RDXM.AQ, "CthunEyeUpdate");
	
	--Show Eye timer
	RDXM.AQ.CthunShowEyeTimer()
	
	--Show Dark Glare timer
	RDX.Alert.Dropdown("cthun_nextglare", "Dark Glare", 47, 5, "Sound\\Doodad\\G_GongTroll01.wav")
	
	--Dark Glare recursive cycle starts in 47 seconds.
	VFL.scheduleExclusive("cthun_startrecursiveglare", 47, function() RDXM.AQ.CthunRecursiveGlare(); end);
end

function RDXM.AQ.CthunStop()

	--remove any lingering alerts
	
	RDX.QuashAlertsByPattern("^cthun_")

	--unbind hottrack
	if cthun1_eye_track then
		cthun1_eye_track.SigUpdate:DisconnectByHandle(cthun1_eye_sigupdate);
		cthun1_eye_sigupdate = nil; cthun1_eye_track=nil;
	end
	
	--unschedule any events
	VFL.removeScheduledEventByName("cthun_startrecursiveglare");
	VFL.removeScheduledEventByName("cthun_continuerecursiveglare");
	VFL.removeScheduledEventByName("cthun_nextglare");
	VFL.removeScheduledEventByName("cthun_unlockeye");
	
			
end


function RDXM.AQ.CthunRecursiveGlare()

	-- Show next "green beam" timer
	RDX.Alert.Dropdown("cthun_nextbeam", "Green Beam", 38, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});

	-- In 38 seconds, we have 51 until the next glare, so lets schedule that as well
	VFL.scheduleExclusive("cthun_nextglare", 38, function() RDX.Alert.Dropdown("cthun_nextglare", "Dark Glare", 49.5, 5, "Sound\\Doodad\\G_GongTroll01.wav"); end);
	
	--this function fires off every  87.5 seconds
	VFL.scheduleExclusive("cthun_continuerecursiveglare", 87.5, function() RDXM.AQ.CthunRecursiveGlare(); end);

end


function RDXM.AQ.CthunEyeUpdate()


	if eye_lock == true then return; end
	
	if (not cthun1_eye_track:IsTracking()) then
		return; 
	else
		--we are tracking it!
		eye_lock = true;
		RDXM.AQ.CthunShowEyeTimer()
		VFL.scheduleExclusive("cthun_unlockeye", 35, function() eye_lock = false; end);
	end	
	
	
end

function RDXM.AQ.CthunShowEyeTimer()
	
	RDX.QuashAlertsByPattern("^cthun_nexteyes")
	RDX.Alert.Dropdown("cthun_nexteyes", "Next Eyes", 45, 5, "Sound\\Doodad\\BellTollAlliance.wav")
	
end



function RDXM.AQ.CthunUpdate()
	RDX.AutoStartStopEncounter(cthun1_track);
	RDX.AutoUpdateEncounterPane(cthun1_track);
end



-------------------------------------
-- Too Close monitor
-------------------------------------

function RDXM.AQ.CthunTooCloseShow()

	if not cthun_window then cthun_window = RDXM.AQ.CthunStumock.GetWindow(); end
	
	--let's make sure it is named correctly
	cthun_window.window.text:SetText("Too Close");		
	--remove any other running 'threads'
	VFL.removeScheduledEventByName("cthun1_heartbeat");
	VFL.removeScheduledEventByName("cthun2_heartbeat");
	--start the heartbeat
	RDXM.AQ.CthunTooCloseHeartBeat()


end


function RDXM.AQ.CthunTooCloseUpdate()

	if not cthun_window then return; end
	if not RDX.unit then return; end
	
	--clear the current list
	cthun_window.list = {}
	
	--lets loop through our DB and check who has the stumock debuff
	--if they do, add them to our list with their HP
	local numAdded = 0; --only show up to 5 people in the list
	
	for i=1,40 do
		if numAdded < 5 then
			if RDX.unit[i].valid and RDX.unit[i].name ~= string.lower(UnitName("player")) then
				if CheckInteractDistance(RDX.unit[i].uid, 1) then
					--theplayer is within 5.55 yards
					thisMember = {}
					thisMember.title = RDX.unit[i].name;
					thisMember.valuestr = RDX.unit[i]:Health() .. "/" .. RDX.unit[i]:MaxHealth();
					thisMember.val = RDX.unit[i]:FracHealth();
					thisMember.r = .9;
					thisMember.g = .1;
					thisMember.b = .1;
					table.insert(cthun_window.list, thisMember);
					numAdded = numAdded + 1;
				end
			end
		end
	end
	
	for i=1,40 do
		if numAdded < 5 then
			if RDX.unit[i].valid and RDX.unit[i].name ~= string.lower(UnitName("player")) then
				if CheckInteractDistance(RDX.unit[i].uid, 2) and not CheckInteractDistance(RDX.unit[i].uid, 1) then
					--the player is within 10 yards
					thisMember = {}
					thisMember.title = RDX.unit[i].name;
					thisMember.valuestr = RDX.unit[i]:Health() .. "/" .. RDX.unit[i]:MaxHealth();
					thisMember.val = RDX.unit[i]:FracHealth();
					thisMember.r = .9;
					thisMember.g = .9;
					thisMember.b = .1;
					table.insert(cthun_window.list, thisMember);
					numAdded = numAdded + 1;
				end
			end
		end
	end	
		
	cthun_window.Repaint();

end

function RDXM.AQ.CthunTooCloseHeartBeat()

	if not cthun_window then return; end --the heartbeat will stop if they close the window.

	RDXM.AQ.CthunTooCloseUpdate()
	VFL.scheduleExclusive("cthun2_heartbeat", .25, function() RDXM.AQ.CthunTooCloseHeartBeat(); end); --1 second heartbeat
	
end


RDXM.AQ.enctbl["cthun1"] = {
	ActivateEncounter = RDXM.AQ.CthunActivate;
	DeactivateEncounter = RDXM.AQ.CthunDeactivate;
	StartEncounter = RDXM.AQ.CthunStart;
	StopEncounter = RDXM.AQ.CthunStop;
};