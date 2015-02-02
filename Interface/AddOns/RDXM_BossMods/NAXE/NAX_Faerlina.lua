------------------------------------------------------
-- Grand Widow Faerlina
------------------------------------------------------

-- Hot-Tracking variables 
grand_widow_faerlina_track = nil;
grand_widow_faerlina_sigupdate = nil;

-- Lockout booleans for events
local grand_widow_faerlina_WidowSilenced_LOCKOUT = nil;
local grand_widow_faerlina_NextEnrage_LOCKOUT = nil;
local grand_widow_faerlina_RainOfFire_LOCKOUT = nil;

-- ****************************
-- Activate / Deactivate / Tracking / Start / Stop
-- ****************************

function RDXM.NAXE.GrandWidowFaerlinaActivate()
	-- Events

	VFLEvent:NamedBind("grand_widow_faerlina", BlizzEvent("CHAT_MSG_OFFICER"), function() RDXM.NAXE.GrandWidowFaerlinaWidowSilencedEVENT(arg1); end);
	VFLEvent:NamedBind("grand_widow_faerlina", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"), function() RDXM.NAXE.GrandWidowFaerlinaRainOfFireEVENT(arg1); end);
	VFLEvent:NamedBind("grand_widow_faerlina", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"), function() RDXM.NAXE.GrandWidowFaerlinaWidowSilencedEVENT(arg1); end);


	-- RPC Binds
	RPC.Bind("grand_widow_faerlina_WidowSilenced", RDXM.NAXE.GrandWidowFaerlinaWidowSilenced_RPC);

	-- Tracking
	grand_widow_faerlina_track = HOT.TrackTarget("Grand Widow Faerlina");
	grand_widow_faerlina_sigupdate = grand_widow_faerlina_track.SigUpdate:Connect(RDXM.NAXE, "GrandWidowFaerlinaUpdate");
end

backtosixty = "RDXM.NAXE.GrandWidowFaerlinaNextEnrageEVENT = function(arg1) if grand_widow_faerlina_NextEnrage_LOCKOUT then return; end grand_widow_faerlina_NextEnrage_LOCKOUT = true; VFL.scheduleExclusive(\"grand_widow_faerlina_NextEnrage_unlock\", 2, function() grand_widow_faerlina_NextEnrage_LOCKOUT = false; end) RDX.QuashAlertsByPattern(\"grand_widow_faerlina_next_enrage\"); RDX.Alert.Dropdown(\"grand_widow_faerlina_next_enrage\", \"Enrage\", 60, 15, nil, {r=1,g=0,b=0}, nil, nil); VFL.scheduleExclusive(\"grand_widow_faerlina_recursive_enrage\", 60, function() RDXM.NAXE.GrandWidowFaerlinaNextEnrageEVENT(arg1); end); end "

--/script RDX.Gibybo_SendPatch(backtosixty, "backto60");


function RDXM.NAXE.GrandWidowFaerlinaDeactivate()

	-- Unbind Events
	VFLEvent:NamedUnbind("grand_widow_faerlina");

	-- Unbind RPCs
	RPC.UnbindPattern("^grand_widow_faerlina_");

	-- Stop Tracking
	if grand_widow_faerlina_track then
		grand_widow_faerlina_track.SigUpdate:DisconnectByHandle(grand_widow_faerlina_sigupdate);
		grand_widow_faerlina_sigupdate = nil; grand_widow_faerlina_track = nil;
	end
end

function RDXM.NAXE.GrandWidowFaerlinaUpdate()
	RDX.AutoStartStopEncounter(grand_widow_faerlina_track);
	RDX.AutoUpdateEncounterPane(grand_widow_faerlina_track);
end

function RDXM.NAXE.GrandWidowFaerlinaStart()
	RDXM.NAXE.GrandWidowFaerlinaNextEnrageEVENT(arg1);
end

function RDXM.NAXE.GrandWidowFaerlinaStop()
	RDX.QuashAlertsByPattern("^grand_widow_faerlina")
	grand_widow_faerlina_WidowSilenced_LOCKOUT = false;
	VFL.removeScheduledEventByName("grand_widow_faerlina_WidowSilenced_unlock");
	grand_widow_faerlina_NextEnrage_LOCKOUT = false;
	VFL.removeScheduledEventByName("grand_widow_faerlina_NextEnrage_unlock");
	grand_widow_faerlina_RainOfFire_LOCKOUT = false;
	VFL.removeScheduledEventByName("grand_widow_faerlina_RainOfFire_unlock");
	--stop recursive enrage timer
	VFL.removeScheduledEventByName("grand_widow_faerlina_recursive_enrage");
end



-- ****************************
-- Blizzard Chat Message Events
-- ****************************

-- WidowSilenced event
function RDXM.NAXE.GrandWidowFaerlinaWidowSilencedEVENT(arg1)


	--are we locked out?
	if grand_widow_faerlina_WidowSilenced_LOCKOUT then return; end
	if string.find(arg1, "Widow") then

	if string.find(arg1, "Embrace") then

		--LOCKOUT
		grand_widow_faerlina_WidowSilenced_LOCKOUT = true;
		VFL.scheduleExclusive("grand_widow_faerlina_WidowSilenced_unlock", 30, function() grand_widow_faerlina_WidowSilenced_LOCKOUT = false; end)

		-- RPC this event
		RPC.Invoke("grand_widow_faerlina_WidowSilenced");

	end
	end

end



-- RPC for WidowSilenced event
function RDXM.NAXE.GrandWidowFaerlinaWidowSilenced_RPC()
	--are we locked out?
	--if grand_widow_faerlina_WidowSilenced_LOCKOUT then return; end

	RDX.QuashAlertsByPattern("grand_widow_faerlina_silenced_dropdown");
	RDX.Alert.Dropdown("grand_widow_faerlina_silenced_dropdown", "Widow Silenced", 30, 5, "Sound\\Doodad\\BellTollAlliance.wav", {r=1,g=0,b=1}, nil, true);

end

-- NextEnrage event
function RDXM.NAXE.GrandWidowFaerlinaNextEnrageEVENT(arg1)

	--are we locked out?
	if grand_widow_faerlina_NextEnrage_LOCKOUT then return; end

		--LOCKOUT
		grand_widow_faerlina_NextEnrage_LOCKOUT = true;
		VFL.scheduleExclusive("grand_widow_faerlina_NextEnrage_unlock", 2, function() grand_widow_faerlina_NextEnrage_LOCKOUT = false; end)

		RDX.QuashAlertsByPattern("grand_widow_faerlina_next_enrage");
		RDX.Alert.Dropdown("grand_widow_faerlina_next_enrage", "Enrage", 60, 15, nil, {r=1,g=0,b=0}, nil, nil);
		
		VFL.scheduleExclusive("grand_widow_faerlina_recursive_enrage", 60, function() RDXM.NAXE.GrandWidowFaerlinaNextEnrageEVENT(arg1); end);
		
end


-- RainOfFire event
function RDXM.NAXE.GrandWidowFaerlinaRainOfFireEVENT(arg1)

	--are we locked out?
	if grand_widow_faerlina_RainOfFire_LOCKOUT then return; end
	if string.find(arg1, "Rain of Fire") then

		--LOCKOUT
		grand_widow_faerlina_RainOfFire_LOCKOUT = true;
		VFL.scheduleExclusive("grand_widow_faerlina_RainOfFire_unlock", 2, function() grand_widow_faerlina_RainOfFire_LOCKOUT = false; end)

		RDX.Alert.Simple("Rain of Fire - MOVE!", "Sound\\Doodad\\BellTollAlliance.wav", 1, true);
	end

end



-- ****************************
-- Register the encounter
-- ****************************

RDXM.NAXE.enctbl["faerlina"] = {
	ActivateEncounter = RDXM.NAXE.GrandWidowFaerlinaActivate;
	DeactivateEncounter = RDXM.NAXE.GrandWidowFaerlinaDeactivate;
	StartEncounter = RDXM.NAXE.GrandWidowFaerlinaStart;
	StopEncounter = RDXM.NAXE.GrandWidowFaerlinaStop;
};
