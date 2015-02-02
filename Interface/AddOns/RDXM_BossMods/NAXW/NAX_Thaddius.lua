--------------------------------------
-- Thadius
--------------------------------------
function RDXM.NAXW.ThadActivate()
	-- Events
	VFLEvent:NamedBind("thad", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.NAXW.ThadStomp(arg1); end);
	VFLEvent:NamedBind("thad", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE"), function() RDXM.NAXW.ThadStomp(arg1); end);
	VFLEvent:NamedBind("thad", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"), function() RDXM.NAXW.ThadStomp(arg1); end);
	-- Tracking
	thad_track = HOT.TrackTarget("Thaddius");
	thad_sigupdate = thad_track.SigUpdate:Connect(RDXM.NAXW, "ThadUpdate");

	--if i'm the raid leader, set the master target to glutch after a 2 second pause
	if IsRaidLeader() then
		RDXM.BossMods.SetThreatMasterTarget("Thaddius", 2)
	end
end


function RDXM.NAXW.ThadDeactivate()
	-- Cleanup events
	VFLEvent:NamedUnbind("thad");
	-- Cleanup tracking
	if thad_track then
		thad_track.SigUpdate:DisconnectByHandle(thad_sigupdate);
		thad_sigupdate = nil; thad_track = nil;
	end
	-- Cleanup alerts
	RDX.QuashAlertsByPattern("^thad");
end

function RDXM.NAXW.ThadStart()
	-- Reset last polarity
	thad_mylastpolarity = nil
	-- Quash stomp timer
	RDX.QuashAlertsByPattern("^thad_stomp")
end

function RDXM.NAXW.ThadStop()
	-- Quash alerts
	RDX.QuashAlertsByPattern("^thad");
end

function RDXM.NAXW.ThadUpdate()
	RDX.AutoStartStopEncounter(thad_track);
	RDX.AutoUpdateEncounterPane(thad_track);
end

function RDXM.NAXW.ThadStomp(arg)
	if string.find(arg, "War Stomp") then
		RDX.QuashAlertsByPattern("^thad_stomp")
		RDX.Alert.Dropdown("thad_stomp", "War Stomp", 15, 5, "Sound\\Doodad\\BellTollAlliance.wav", {r=1, g=1, b=1});
	end
end

RDXM.NAXW.enctbl["thaddius"] = {
	DeactivateEncounter = RDXM.NAXW.ThadDeactivate;
	ActivateEncounter = RDXM.NAXW.ThadActivate;
	StartEncounter = RDXM.NAXW.ThadStart;
	StopEncounter = RDXM.NAXW.ThadStop;	
};