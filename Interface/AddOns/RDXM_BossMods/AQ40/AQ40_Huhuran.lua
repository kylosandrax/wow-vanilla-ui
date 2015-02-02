

--------------------------------------
-- HUHURAN
--------------------------------------
local huhuran_track = nil;
local huhuran_sigupdate = nil;

function RDXM.AQ.HuhuranActivate()
	if not huhuran_track then
		huhuran_track = HOT.TrackTarget("Princess Huhuran");
		huhuran_sigupdate = huhuran_track.SigUpdate:Connect(RDXM.AQ, "HuhuranUpdate");
	end
end

function RDXM.AQ.HuhuranDeactivate()
	if huhuran_track then
		huhuran_track.SigUpdate:DisconnectByHandle(huhuran_sigupdate);
		huhuran_sigupdate = nil; huhuran_track = nil;
	end
end

function RDXM.AQ.HuhuranUpdate()
	RDX.AutoStartStopEncounter(huhuran_track);
	RDX.AutoUpdateEncounterPane(huhuran_track);
end

RDXM.AQ.enctbl["huhuran"] = {
	ActivateEncounter = RDXM.AQ.HuhuranActivate;
	DeactivateEncounter = RDXM.AQ.HuhuranDeactivate;
};