------------------------------------------------------
-- Noth the Plaguebringer
------------------------------------------------------

-- Hot-Tracking variables 
noth_track = nil;
noth_sigupdate = nil;

-- Lockout booleans for events
local noth_CurseOfThePlaguebringer_LOCKOUT = nil;

-- ********************************************************
-- Activate / Deactivate / Tracking / Start / Stop
-- ********************************************************

function RDXM.NAXE.NothActivate()
	-- Events
	VFLEvent:NamedBind("noth", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE"), function() RDXM.NAXE.NothCurseOfThePlaguebringerEVENT(arg1); end);
	VFLEvent:NamedBind("noth", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"), function() RDXM.NAXE.NothCurseOfThePlaguebringerEVENT(arg1); end);

	-- RPC Binds
	RPC.Bind("noth_CurseOfThePlaguebringer", RDXM.NAXE.NothCurseOfThePlaguebringer_RPC);

	-- Tracking
	noth_track = HOT.TrackTarget("Noth the Plaguebringer");
	noth_sigupdate = noth_track.SigUpdate:Connect(RDXM.NAXE, "NothUpdate");
end

function RDXM.NAXE.NothDeactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("noth");

	-- Unbind RPCs
	RPC.UnbindPattern("^noth_");

	-- Stop Tracking
	if noth_track then
		noth_track.SigUpdate:DisconnectByHandle(noth_sigupdate);
		noth_sigupdate = nil; noth_track = nil;
	end
end

function RDXM.NAXE.NothUpdate()
	RDX.AutoStartStopEncounter(noth_track);
	RDX.AutoUpdateEncounterPane(noth_track);
end

function RDXM.NAXE.NothStart()
	
	--Start scheduled timers for teleports / spawns / etc
	--First, we immediatly put up the first teleport timer
	RDX.Alert.Dropdown("noth_main_1", "Teleport #1", 90, 5, nil, {r=1,g=1,b=0}, nil, true);
	--and schedule the rest
	VFL.scheduleExclusive("NothMainTimers_2", 90, function() RDX.Alert.Dropdown("noth_main_2", "Plagued Champions", 10, 3, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_3", 100, function() RDX.Alert.Dropdown("noth_main_3", "Plagued Champions", 30, 3, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_4", 130, function() RDX.Alert.Dropdown("noth_main_4", "Noth Returns", 30, 5, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_5", 160, function() RDX.Alert.Dropdown("noth_main_5", "Teleport #2", 110, 5, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_6", 270, function() RDX.Alert.Dropdown("noth_main_6", "Plagued Champs + Guardians", 10, 3, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_7", 280, function() RDX.Alert.Dropdown("noth_main_7", "Plagued Champs + Guardians", 45, 3, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_8", 325, function() RDX.Alert.Dropdown("noth_main_8", "Noth Returns", 40, 5, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_9", 365, function() RDX.Alert.Dropdown("noth_main_9", "Teleport #3", 175, 10, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_10", 550, function() RDX.Alert.Dropdown("noth_main_10", "Champs + Guardians + ???", 10, 3, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_11", 550, function() RDX.Alert.Dropdown("noth_main_11", "Champs + Guardians + ???", 65, 3, nil, {r=1,g=1,b=0}, nil, true); end)
	VFL.scheduleExclusive("NothMainTimers_12", 615, function() RDX.Alert.Dropdown("noth_main_12", "Noth Returns", 50, 5, nil, {r=1,g=1,b=0}, nil, true); end)
	
end

function RDXM.NAXE.NothStop()
	RDX.QuashAlertsByPattern("^noth")
	noth_CurseOfThePlaguebringer_LOCKOUT = false;
	
	--unschedule everything else
	VFL.removeScheduledEventByName("noth_CurseOfThePlaguebringer_unlock");
	VFL.removeScheduledEventByName("NothMainTimers_2");
	VFL.removeScheduledEventByName("NothMainTimers_3");
	VFL.removeScheduledEventByName("NothMainTimers_4");
	VFL.removeScheduledEventByName("NothMainTimers_5");
	VFL.removeScheduledEventByName("NothMainTimers_6");
	VFL.removeScheduledEventByName("NothMainTimers_7");
	VFL.removeScheduledEventByName("NothMainTimers_8");
	VFL.removeScheduledEventByName("NothMainTimers_9");
	VFL.removeScheduledEventByName("NothMainTimers_10");
	VFL.removeScheduledEventByName("NothMainTimers_11");
	VFL.removeScheduledEventByName("NothMainTimers_12");
	
end



-- ****************************
-- Blizzard Chat Message Events
-- ****************************

-- CurseOfThePlaguebringer event
function RDXM.NAXE.NothCurseOfThePlaguebringerEVENT(arg1)

	--are we locked out?
	if noth_CurseOfThePlaguebringer_LOCKOUT then return; end
	if string.find(arg1, "Curse of the Plaguebringer") then

		--LOCKOUT
		noth_CurseOfThePlaguebringer_LOCKOUT = true;
		VFL.scheduleExclusive("noth_CurseOfThePlaguebringer_unlock", 5, function() noth_CurseOfThePlaguebringer_LOCKOUT = false; end)

		-- Fire the event
		RDX.QuashAlertsByPattern("noth_curse_of_plaguebringer");
		RDX.Alert.Dropdown("noth_curse_of_plaguebringer", "Curse of the Plaguebringer", 10, 2, nil, {r=1,g=0.2,b=1}, nil, true);
		RDX.Alert.Simple("C.O.P. - Cure Curse!", "Sound\\Doodad\\BellTollAlliance.wav", 1, nil);

		-- RPC this event for others
		RPC.Invoke("noth_CurseOfThePlaguebringer");

	end

end

-- RPC for CurseOfThePlaguebringer event
function RDXM.NAXE.NothCurseOfThePlaguebringer_RPC()
	--are we locked out?
	if noth_CurseOfThePlaguebringer_LOCKOUT then return; end

	RDX.QuashAlertsByPattern("noth_curse_of_plaguebringer");
	RDX.Alert.Dropdown("noth_curse_of_plaguebringer", "Curse of the Plaguebringer", 10, 2, nil, {r=1,g=0.2,b=1}, nil, true);
	RDX.Alert.Simple("C.O.P. - Cure Curse!", "Sound\\Doodad\\BellTollAlliance.wav", 1, nil);

end



-- ****************************
-- Register the encounter
-- ****************************

RDXM.NAXE.enctbl["noth"] = {
	ActivateEncounter = RDXM.NAXE.NothActivate;
	DeactivateEncounter = RDXM.NAXE.NothDeactivate;
	StartEncounter = RDXM.NAXE.NothStart;
	StopEncounter = RDXM.NAXE.NothStop;
};
