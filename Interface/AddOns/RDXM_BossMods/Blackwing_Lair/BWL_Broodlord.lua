
-------------------------------------
-- BROODLORD
-------------------------------------
local broodlord_track = nil;
local broodlord_sigupdate = nil;

function RDXM.BWL.BroodlordActivate()
	if not broodlord_track then
		broodlord_track = HOT.TrackTarget("Broodlord Lashlayer");
		broodlord_sigupdate = broodlord_track.SigUpdate:Connect(RDXM.BWL, "BroodlordUpdate");
	end
end
function RDXM.BWL.BroodlordDeactivate()
	if broodlord_track then
		broodlord_track.SigUpdate:DisconnectByHandle(broodlord_sigupdate);
		broodlord_sigupdate = nil; broodlord_track = nil;
	end
end
function RDXM.BWL.BroodlordUpdate()
	RDX.AutoStartStopEncounter(broodlord_track);
	RDX.AutoUpdateEncounterPane(broodlord_track);
end

RDXM.BWL.enctbl["broodlord"] = {
	ActivateEncounter = RDXM.BWL.BroodlordActivate;
	DeactivateEncounter = RDXM.BWL.BroodlordDeactivate;
};