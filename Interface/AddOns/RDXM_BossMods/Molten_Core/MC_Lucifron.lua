
--------------------------------------
-- LUCIFRON
--------------------------------------
local lucifron_track = nil;
local lucifron_sigupdate = nil;

function RDXM.MC.LucifronActivate()
	if not lucifron_track then
		lucifron_track = HOT.TrackTarget("Lucifron");
		lucifron_sigupdate = lucifron_track.SigUpdate:Connect(RDXM.MC, "LucifronUpdate");
	end
end
function RDXM.MC.LucifronDeactivate()
	if lucifron_track then
		lucifron_track.SigUpdate:DisconnectByHandle(lucifron_sigupdate);
		lucifron_sigupdate = nil; lucifron_track = nil;
	end
end
function RDXM.MC.LucifronUpdate()
	RDX.AutoStartStopEncounter(lucifron_track);
	RDX.AutoUpdateEncounterPane(lucifron_track);
end

RDXM.MC.enctbl["lucifron"] = {
	ActivateEncounter = RDXM.MC.LucifronActivate;
	DeactivateEncounter = RDXM.MC.LucifronDeactivate;
};