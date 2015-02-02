
--------------------------------------
-- Ouro
--------------------------------------
local ouro_track = nil;
local ouro_sigupdate = nil;
local ouro_burrowlock = nil;
local ouro_sweeplock = nil;
local ouro_sandblastlock = nil;
local ouro_upstate = 0;

--technically ouro is probably still castable for a moment after casting ouro mounds.
--so lets mot mark him as "up" for a few seconds (5)
local ouro_brief_burrowlock = nil;  

function RDXM.AQ.OuroActivate()
	-- Events
	VFLEvent:NamedBind("ouro", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE"), function() RDXM.AQ.OuroCast(arg1); end);
	VFLEvent:NamedBind("ouro", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"), function() RDXM.AQ.OuroCast(arg1); end);
	VFLEvent:NamedBind("ouro", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"), function() RDXM.AQ.OuroCast(arg1); end);
	VFLEvent:NamedBind("ouro", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.AQ.OuroCast(arg1); end);
	VFLEvent:NamedBind("ouro", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"), function() RDXM.AQ.OuroCast(arg1); end);

	-- RPC Binds
	RPC.Bind("ouro_burrow", RDXM.AQ.OuroBurrowed);
	RPC.Bind("ouro_sweep", RDXM.AQ.OuroSweep);
	RPC.Bind("ouro_sandblast", RDXM.AQ.OuroSandblast);
	-- Tracking
	ouro_track = HOT.TrackTarget("Ouro");
	ouro_sigupdate = ouro_track.SigUpdate:Connect(RDXM.AQ, "OuroUpdate");
end

function RDXM.AQ.OuroDeactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("ouro");
	-- Unbind RPCs
	RPC.UnbindPattern("^ouro_");
	if ouro_track then
		ouro_track.SigUpdate:DisconnectByHandle(ouro_sigupdate);
		ouro_sigupdate = nil; ouro_track = nil;
	end
end

function RDXM.AQ.OuroCast(arg)
	if string.find(arg, "Sweep") then
		RDXM.AQ.OuroSweep();
		return;
	end;
	if string.find(arg, "Sand Blast") then
		RDXM.AQ.OuroSandblast();
		return;
	end;
	if string.find(arg, "Ouro casts Summon Ouro Mounds") then
		RDXM.AQ.OuroBurrowed()
	end
end

RDX.ourocastupdate = "RDXM.AQ.OuroCast = function(arg) if string.find(arg, \"Sweep\") then RDXM.AQ.OuroSweep(); return; end; if string.find(arg, \"Sand Blast\") then RDXM.AQ.OuroSandblast(); return; end; end"

function RDXM.AQ.OuroUpdate()
	RDX.AutoStartStopEncounter(ouro_track);
	RDX.AutoUpdateEncounterPane(ouro_track);
	
	
	--CHANGED:
	--We don't want to use not IsTracking() to determien burrow because all it takes
	--is one person not seeing ouro and the mod fires off.
	--Instead we are looking for ouro to cast ouro mounds.
	--
	--if not ouro_track:IsTracking() and ouro_track then
	--	RDXM.AQ.OuroBurrowed()
	--	ouro_upstate = 0
	--end
	
	if not ouro_brief_burrowlock then
		if ouro_track:IsTracking() and ouro_upstate == 0 then
			ouro_upstate = 1
			RDX.QuashAlertsByPattern("^ouro_")
			RDX.Alert.Simple("Ouro Back Up, Get In Position!", "Sound\\Doodad\\BellTollAlliance.wav", 3);
			RDXM.AQ.OuroSweep()
			RDXM.AQ.OuroSandblast()
			RDX.Alert.Dropdown("ouro_nextburrow", "1.5 Minute Burrow", 90, 10, nil)
			RDX.Alert.Dropdown("ouro_nextburrow", "3 Minute Burrow", 180, 10, nil)
		end
	end
		
	
end

function RDXM.AQ.OuroBurrowed()
	if ouro_burrowlock then return; end
	ouro_burrowlock = true;
	ouro_brief_burrowlock = true;
	VFL.schedule(35, function() ouro_burrowlock = false; end);
	VFL.schedule(5, function() ouro_brief_burrowlock = false; end);
	
	ouro_upstate = 0;
	
	-- Propagate burrow signal just for completeness
	RPC.Invoke("ouro_burrow");
	-- Remove sweep/sandblast alerts
	RDX.QuashAlertsByPattern("^ouro_up")
	RDX.QuashAlertsByPattern("^ouro_next")
	-- Dingit baby
	RDX.Alert.Simple("Burrowed! Spread out!", "Sound\\Doodad\\BellTollAlliance.wav", 3);
	-- Post-burrow activities
	RDXM.AQ.OuroPostBurrow();
end

function RDXM.AQ.OuroPostBurrow()
	RDX.Alert.Dropdown("ouro_burrowed", "Ouro Reemerges", 30, 5, nil)
end

function RDXM.AQ.OuroSweep()
	if ouro_sweeplock then return; end
	ouro_sweeplock = true;
	VFL.schedule(15, function() ouro_sweeplock = false; end);
	RPC.Invoke("ouro_sweep");
	RDX.Alert.Dropdown("ouro_up", "Next Sweep", 20, 3, nil)
end

function RDXM.AQ.OuroSandblast()
	if ouro_sandblastlock then return; end
	ouro_sandblastlock = true;
	VFL.schedule(15, function() ouro_sandblastlock = false; end);
	RPC.Invoke("ouro_sandblast");
	RDX.Alert.Dropdown("ouro_up", "Next Sandblast", 20, 3, nil)
end
	
function RDXM.AQ.OuroStart()
	RDX.QuashAlertsByPattern("^ouro_next")
	RDXM.AQ.OuroSweep()
	RDXM.AQ.OuroSandblast()
	RDX.Alert.Dropdown("ouro_nextburrow", "1.5 Minute Burrow", 90, 10, nil)
	RDX.Alert.Dropdown("ouro_nextburrow", "3 Minute Burrow", 180, 10, nil)
end

function RDXM.AQ.OuroStop()

	RDX.QuashAlertsByPattern("^ouro_")
	ouro_sandblastlock = false;
	ouro_sweeplock = false;
	
end

RDXM.AQ.enctbl["ouro"] = {
	ActivateEncounter = RDXM.AQ.OuroActivate;
	DeactivateEncounter = RDXM.AQ.OuroDeactivate;
	StartEncounter = RDXM.AQ.OuroStart;
	StopEncounter = RDXM.AQ.OuroStop;
};