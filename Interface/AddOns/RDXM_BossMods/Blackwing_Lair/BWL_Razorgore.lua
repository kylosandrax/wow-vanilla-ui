
-------------------------------------
-- RAZORGORE
-------------------------------------
local razor_track = nil;
local razor_sigupdate = nil;

function RDXM.BWL.RazorgoreActivate()
	if not razor_track then
		razor_track = HOT.TrackTarget("Razorgore the Untamed");
		razor_sigupdate = razor_track.SigUpdate:Connect(RDXM.BWL, "RazorgoreUpdate");
	end
end
function RDXM.BWL.RazorgoreDeactivate()
	if razor_track then
		razor_track.SigUpdate:DisconnectByHandle(razor_sigupdate);
		razor_sigupdate = nil; razor_track = nil;
	end
end
function RDXM.BWL.RazorgoreUpdate()
	RDX.AutoStartStopEncounter(razor_track);
	RDX.AutoUpdateEncounterPane(razor_track);
end

RDXM.BWL.enctbl["razorgore"] = {
	ActivateEncounter = RDXM.BWL.RazorgoreActivate;
	DeactivateEncounter = RDXM.BWL.RazorgoreDeactivate;
};