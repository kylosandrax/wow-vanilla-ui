
-------------------------------------
-- EBONROC
-------------------------------------
-- Shadow of Ebonroc
function RDXM.BWL.ParseSOE(arg1)
	local sound = "Sound\\Doodad\\BellTollAlliance.wav";
	local _, _, m1, m2 = string.find(arg1, "^([^%s]+) ([^%s]+) afflicted by Shadow of Ebonroc");
	if m1 and m2 then
		local name = m1;
		if(m1 == "You") then name = UnitName("player"); end
		RDX.Alert.Simple(name .. " IS CURSED", sound, 3);
	end
end

-- Metacontrol
local ebon_track = nil;
local ebon_sigupdate = nil;

function RDXM.BWL.EbonrocActivate()
	VFLEvent:NamedBind("ebonroc", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.BWL.WingBuffetParse(arg1); end);
	VFLEvent:NamedBind("ebonroc", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.BWL.ShadowflameParse(arg1); end);
	VFLEvent:NamedBind("ebonroc", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.BWL.ParseSOE(arg1); end);
	VFLEvent:NamedBind("ebonroc", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"), function() RDXM.BWL.ParseSOE(arg1); end);
	VFLEvent:NamedBind("ebonroc", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"), function() RDXM.BWL.ParseSOE(arg1); end);
	if not ebon_track then
		ebon_track = HOT.TrackTarget("Ebonroc");
		ebon_sigupdate = ebon_track.SigUpdate:Connect(RDXM.BWL, "EbonrocUpdate");
	end
end
function RDXM.BWL.EbonrocDeactivate()
	VFLEvent:NamedUnbind("ebonroc");
	if ebon_track then
		ebon_track.SigUpdate:DisconnectByHandle(ebon_sigupdate);
		ebon_sigupdate = nil; ebon_track = nil;
	end
end

function RDXM.BWL.EbonrocUpdate()
	RDX.AutoStartStopEncounter(ebon_track);
	RDX.AutoUpdateEncounterPane(ebon_track);
end

-- Event map
RDXM.BWL.enctbl["ebonroc"] = {
	DeactivateEncounter = RDXM.BWL.EbonrocDeactivate;
	ActivateEncounter = RDXM.BWL.EbonrocActivate;
};