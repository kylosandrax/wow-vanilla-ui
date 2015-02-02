
-------------------------------------
-- Anub'Rekhan
-------------------------------------
local anub_swarmlock = nil;
local anub_swarm_timer = 90;
local anub_swarm_castingtime = 6;
local anub_swarm_duration = 20;
local anub_track = nil;
local anub_sigupdate = nil;

function RDXM.NAXE.AnubDeactivate()
	-- Cleanup binds
	VFLEvent:NamedUnbind("anub");
	RPC.UnbindPattern("^anub_");
	-- Cleanup tracking
	if anub_track then
		anub_track.SigUpdate:DisconnectByHandle(anub_sigupdate);
		anub_sigupdate = nil; anub_track = nil;
	end
	-- Cleanup alerts
	RDX.QuashAlertsByPattern("^anub");
	-- Cleanup scheduled events
	VFL.removeScheduledEventByName("anub_swarm");
end

function RDXM.NAXE.AnubActivate()
	-- Event Binds
	VFLEvent:NamedBind("anub", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"), function() RDXM.NAXE.AnubAbility(arg1); end);
	-- RPC Binds
	RPC.Bind("anub_swarmcast", RDXM.NAXE.AnubSwarmDetected);
	-- Tracking
	anub_track = HOT.TrackTarget("Anub'Rekhan");
	anub_sigupdate = anub_track.SigUpdate:Connect(RDXM.NAXE, "AnubUpdate");
end

RDX.anubeventupdate = "RDXM.NAXE.AnubActivate = function() VFLEvent:NamedBind(\"anub\", BlizzEvent(\"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE\"), function() RDXM.NAXE.AnubAbility(arg1); end); RPC.Bind(\"anub_swarm\", RDXM.NAXE.AnubSwarmDetected); anub_track = HOT.TrackTarget(\"Anub'Rekhan\"); anub_sigupdate = anub_track.SigUpdate:Connect(RDXM.NAXE, \"AnubUpdate\"); end"

function RDXM.NAXE.AnubStart()
	-- Clear any existing timers
	RDX.QuashAlertsByPattern("^anub")
	VFL.removeScheduledEventByName("anub_swarm")
	-- Setup locust swarm prewarning
	RDXM.NAXE.AnubLocustWarn();
end

function RDXM.NAXE.AnubStop()
	RDX.QuashAlertsByPattern("^anub");
end

function RDXM.NAXE.AnubUpdate()
	RDX.AutoStartStopEncounter(anub_track);
	RDX.AutoUpdateEncounterPane(anub_track);
end

function RDXM.NAXE.AnubAbility(arg)
	-- Detect Locust swarm
	if string.find(arg, "cast Locust Swarm") then
		RDXM.NAXE.AnubSwarmDetected();
		RPC.Invoke("anub_swarmcast");
	end
end

function RDXM.NAXE.AnubSwarmDetected()
	-- Make sure there is no lockout
	if anub_swarmlock then return; end
	-- Create lockout so it doesn't misfire
	anub_swarmlock = true;
	-- Remove lockout in x seconds for next swarm
	VFL.schedule(anub_swarm_timer-20, function() anub_swarmlock = false; end);
	-- Get rid of old timer since it is outdated
	RDX.QuashAlertsByPattern("^anub_swarm")
	-- Show casting bar and schedule the function to create the next timer
	RDX.Alert.CenterPopup("anub_castswarm", "Inc Locust Swarm + Add", anub_swarm_castingtime, "Sound\\Doodad\\BellTollAlliance.wav", 0, {r=1,g=.2,b=.2}, nil, true);
	RDX.Alert.CenterPopup("anub_castswarm", "Inc Locust Swarm + Add", anub_swarm_castingtime, "Sound\\Doodad\\BellTollAlliance.wav", 0, {r=1,g=.2,b=.2}, nil, true);
	VFL.scheduleExclusive("anub_swarm", anub_swarm_castingtime, function() RDXM.NAXE.AnubLocustWarn(); RDXM.NAXE.AnubLocustCasting(); end);
end

function RDXM.NAXE.AnubLocustWarn()
	-- Create new timer
	local swarmTime, leadTime, sound, color = anub_swarm_timer, -5, nil, {r=0, g=0, b=0};
	RDX.Alert.Dropdown("anub_swarm", "Locust Swarm + Add", swarmTime, leadTime, sound, color);
end

function RDXM.NAXE.AnubLocustCasting()
	-- Show time remaining on Locust Swarm
	RDX.Alert.CenterPopup("anub_swarmactive", "LOCUST SWARM, RLAB!", anub_swarm_duration, nil, 0, {r=.2, g=1, b=.2}, nil, true);
end

RDXM.NAXE.enctbl["anubrekhan"] = {
	DeactivateEncounter = RDXM.NAXE.AnubDeactivate;
	ActivateEncounter = RDXM.NAXE.AnubActivate;
	StartEncounter = RDXM.NAXE.AnubStart;
	StopEncounter = RDXM.NAXE.AnubStop;
};