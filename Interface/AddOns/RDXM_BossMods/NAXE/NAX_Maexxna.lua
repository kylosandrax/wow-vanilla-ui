------------------------------------
-- Maexxna
------------------------------------
local maexxna_track
local maexxna_sigupdate
local maexxna_WebSpray_LOCKOUT

function RDXM.NAXE.MaexxnaActivate()
	-- Events
	VFLEvent:NamedBind("maexxna", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE"), function() RDXM.NAXE.MaexxnaWebSprayEVENT(arg1); end);
	VFLEvent:NamedBind("maexxna", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"), function() RDXM.NAXE.MaexxnaWebSprayEVENT(arg1); end);

	-- Tracking
	maexxna_track = HOT.TrackTarget("Maexxna");
	maexxna_sigupdate = maexxna_track.SigUpdate:Connect(RDXM.NAXE, "MaexxnaUpdate");

	if IsRaidLeader() then
		RDXM.BossMods.SetThreatMasterTarget("Maexxna", 2)
	end
end

function RDXM.NAXE.MaexxnaDeactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("maexxna");
	
	if maexxna_track then
		maexxna_track.SigUpdate:DisconnectByHandle(maexxna_track);
		maexxna_sigupdate = nil; maexxna_track = nil;
	end
end

function RDXM.NAXE.MaexxnaStart()
	--Heartbeat
	RDXM.NAXE.MaexxnaHeartBeat();

	--Show Web Spray timer
	RDXM.NAXE.MaexxnaShowWebTimer()
end

function RDXM.NAXE.MaexxnaStop()
	--remove any lingering alerts
	RDX.QuashAlertsByPattern("^maexxna_")
	maexxna_WebSpray_LOCKOUT = false;

	--unschedule everything else
	VFL.removeScheduledEventByName("maexxna_webspray_unlock");
	VFL.removeScheduledEventByName("maexxna_heartbeat");
end

function RDXM.NAXE.MaexxnaWebSprayEVENT(arg1)
	--are we locked out?
	if maexxna_WebSpray_LOCKOUT then return; end
	if string.find(arg1, "Web Spray") then

		--LOCKOUT
		maexxna_WebSpray_LOCKOUT = true;
		VFL.scheduleExclusive("maexxna_webspray_unlock", 15, function() maexxna_WebSpray_LOCKOUT = false; end)

		-- Fire the event
		RDX.QuashAlertsByPattern("maexxna_nextwebspray");
		RDX.Alert.Dropdown("maexxna_nextwebspray", "Web Spray", 35, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
	end
end

function RDXM.NAXE.MaexxnaShowWebTimer()
	-- Show next Web Spray timer
	RDX.Alert.Dropdown("maexxna_nextwebspray", "Web Spray", 35, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
end

function RDXM.NAXE.MaexxnaUpdate()
	RDX.AutoStartStopEncounter(maexxna_track);
	RDX.AutoUpdateEncounterPane(maexxna_track);
end

function RDXM.NAXE.MaexxnaWebWrapUpdate()
	if not RDX.unit then return; end
	if not IsRaidLeader() then return; end
	
	local raidTarget = 1;
	--lets loop through our DB and check who has the web wrap debuff
	for i=1,GetNumRaidMembers() do
		--L O W E R C A S E to match buffs :)))
		if RDX.unit[i]:HasDebuff("web wrap") then
			SetRaidTarget("raid" .. i, raidTarget);
			raidTarget = raidTarget + 1;
		end
	end
end

function RDXM.NAXE.MaexxnaHeartBeat()
	RDXM.NAXE.MaexxnaWebWrapUpdate();
	VFL.scheduleExclusive("maexxna_heartbeat", 1, function() RDXM.NAXE.MaexxnaHeartBeat(); end); --1 second heartbeat
end

RDXM.NAXE.enctbl["maexxna"] = {
	ActivateEncounter = RDXM.NAXE.MaexxnaActivate;
	DeactivateEncounter = RDXM.NAXE.MaexxnaDeactivate;
	StartEncounter = RDXM.NAXE.MaexxnaStart;
	StopEncounter = RDXM.NAXE.MaexxnaStop;
};