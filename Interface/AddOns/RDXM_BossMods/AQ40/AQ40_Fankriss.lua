
--------------------------------------
-- FANKRISS
--------------------------------------
local fankriss_track = nil;
local fankriss_sigupdate = nil;

function RDXM.AQ.FankrissActivate()
	if not fankriss_track then
		fankriss_track = HOT.TrackTarget("Fankriss the Unyielding");
		fankriss_sigupdate = fankriss_track.SigUpdate:Connect(RDXM.AQ, "FankrissUpdate");
	end
end

function RDXM.AQ.FankrissDeactivate()
	if fankriss_track then
		fankriss_track.SigUpdate:DisconnectByHandle(fankriss_sigupdate);
		fankriss_sigupdate = nil; fankriss_track = nil;
	end
end

function RDXM.AQ.FankrissUpdate()
	RDX.AutoStartStopEncounter(fankriss_track);
	RDX.AutoUpdateEncounterPane(fankriss_track);
end

RDXM.AQ.enctbl["fankriss"] = {
	ActivateEncounter = RDXM.AQ.FankrissActivate;
	DeactivateEncounter = RDXM.AQ.FankrissDeactivate;
};