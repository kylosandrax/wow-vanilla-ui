
--------------------------------------
-- Gehennas.lua
--------------------------------------
local gehennas_track = nil;
local gehennas_sigupdate = nil;

function RDXM.MC.GehennasActivate()
	if not gehennas_track then
		gehennas_track = HOT.TrackTarget("Gehennas");
		gehennas_sigupdate = gehennas_track.SigUpdate:Connect(RDXM.MC, "GehennasUpdate");
	end
end

function RDXM.MC.GehennasDeactivate()
	if gehennas_track then
		gehennas_track.SigUpdate:DisconnectByHandle(gehennas_sigupdate);
		gehennas_sigupdate = nil; gehennas_track = nil;
	end
end

function RDXM.MC.GehennasUpdate()
	RDX.AutoStartStopEncounter(gehennas_track);
	RDX.AutoUpdateEncounterPane(gehennas_track);
end

RDXM.MC.enctbl["gehennas"] = {
	ActivateEncounter = RDXM.MC.GehennasActivate;
	DeactivateEncounter = RDXM.MC.GehennasDeactivate;
};