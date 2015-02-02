------------------------------------
-- Heigan
------------------------------------
local heigan_track
local heigan_sigupdate

function RDXM.NAXE.HeiganActivate()
	-- Tracking
	heigan_track = HOT.TrackTarget("Heigan the Unclean");
	heigan_sigupdate = heigan_track.SigUpdate:Connect(RDXM.NAXE, "HeiganUpdate");

	if IsRaidLeader() then
		RDXM.BossMods.SetThreatMasterTarget("Heigan the Unclean", 2)
	end
end

function RDXM.NAXE.HeiganUpdate()
	RDX.AutoStartStopEncounter(heigan_track);
	RDX.AutoUpdateEncounterPane(heigan_track);
end

function RDXM.NAXE.HeiganDeactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("heigan");
	
	if heigan_track then
		heigan_track.SigUpdate:DisconnectByHandle(heigan_track);
		heigan_sigupdate = nil; heigan_track = nil;
	end
end

function RDXM.NAXE.HeiganStart()
	--Show Teleport Timer
	RDXM.NAXE.HeiganStartTeleportTimer()
end

function RDXM.NAXE.HeiganStartTeleportTimer()
	VFL.scheduleExclusive("heigan_returns", 90, function() RDXM.NAXE.HeiganStartReturnTimer(); end);
	RDX.Alert.Dropdown("heigan_teleport", "Teleport", 90, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
end

function RDXM.NAXE.HeiganStartReturnTimer()
	VFL.scheduleExclusive("heigan_teleport", 45, function() RDXM.NAXE.HeiganStartTeleportTimer(); end);
	RDX.Alert.Dropdown("heigan_returns", "Heigan Returns", 45, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
end

function RDXM.NAXE.HeiganStop()
	--remove any lingering alerts
	RDX.QuashAlertsByPattern("^heigan_")

	VFL.removeScheduledEventByName("heigan_returns");
	VFL.removeScheduledEventByName("heigan_teleport");
end

RDXM.NAXE.enctbl["heigan"] = {
	ActivateEncounter = RDXM.NAXE.HeiganActivate;
	DeactivateEncounter = RDXM.NAXE.HeiganDeactivate;
	StartEncounter = RDXM.NAXE.HeiganStart;
	StopEncounter = RDXM.NAXE.HeiganStop;
};