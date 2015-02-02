

-------------------------------------
-- FLAMEGOR
-------------------------------------
local flamegor_track = nil;
local flamegor_sigupdate = nil;

-- Frenzy
function RDXM.BWL.FlamegorFrenzyParse(arg1)
	if(string.find(arg1, "goes into a frenzy!")) then
		RDX.Alert.Simple("FRENZY!", nil, 1);
	end
end

-- Metacontrol
function RDXM.BWL.FlamegorActivate()
	VFLEvent:NamedBind("flamegor", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.BWL.WingBuffetParse(arg1); end);
	VFLEvent:NamedBind("flamegor", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.BWL.ShadowflameParse(arg1); end);
	VFLEvent:NamedBind("flamegor", BlizzEvent("CHAT_MSG_MONSTER_EMOTE"), function() RDXM.BWL.FlamegorFrenzyParse(arg1); end);
	if not flamegor_track then
		flamegor_track = HOT.TrackTarget("Flamegor");
		flamegor_sigupdate = flamegor_track.SigUpdate:Connect(RDXM.BWL, "FlamegorUpdate");
	end
end
function RDXM.BWL.FlamegorDeactivate()
	VFLEvent:NamedUnbind("flamegor");
	if flamegor_track then
		flamegor_track.SigUpdate:DisconnectByHandle(flamegor_sigupdate);
		flamegor_sigupdate = nil; flamegor_track = nil;
	end
end

function RDXM.BWL.FlamegorUpdate()
	RDX.AutoStartStopEncounter(flamegor_track);
	RDX.AutoUpdateEncounterPane(flamegor_track);
end

-- Event map
RDXM.BWL.enctbl["flamegor"] = {
	DeactivateEncounter = RDXM.BWL.FlamegorDeactivate;
	ActivateEncounter = RDXM.BWL.FlamegorActivate;
};