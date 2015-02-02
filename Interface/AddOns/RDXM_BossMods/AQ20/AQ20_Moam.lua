
------------------------------------
-- Moam
------------------------------------

moam_track = nil;
moam_sigupdate = nil;

function RDXM.AQ20.MoamStart()
	RDX.Alert.Dropdown("moam_freeze", "Moam Freezes In", 90, 10, "Sound\\Doodad\\BellTollAlliance.wav");
	VFL.schedule(60, function() RDX.Alert.Simple("Moam Freezes in 30 Seconds!", "Sound\\Doodad\\BellTollAlliance.wav", 3); end);
	VFL.schedule(75, function() RDX.Alert.Simple("Moam Freezes in 15 Seconds!", "Sound\\Doodad\\BellTollAlliance.wav", 3); end);
end

function RDXM.AQ20.MoamStop()
	RDX.QuashAlertsByPattern("^moam")
end


function RDXM.AQ20.MoamActivate()
	if not moam_track then
		moam_track = HOT.TrackTarget("Moam");
		moam_sigupdate = moam_track.SigUpdate:Connect(RDXM.AQ, "MoamUpdate");
	end
end

function RDXM.AQ20.MoamDeactivate()
	if moam_track then
		moam_track.SigUpdate:DisconnectByHandle(moam_sigupdate);
		moam_sigupdate = nil; moam_track = nil;
	end
end

function RDXM.AQ20.MoamUpdate()
	RDX.AutoStartStopEncounter(moam_track);
	RDX.AutoUpdateEncounterPane(moam_track);
end

RDXM.AQ20.enctbl["moam"] = { ActivateEncounter = RDXM.AQ20.MoamActivate; DeactivateEncounter = RDXM.AQ20.MoamDeactivate; StartEncounter = RDXM.AQ20.MoamStart; StopEncounter = RDXM.AQ20.MoamStop;};
