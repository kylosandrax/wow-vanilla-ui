

--------------------------------------
-- MAGMADAR
--------------------------------------
function RDXM.MC.MagActivate()
	VFLEvent:NamedBind("mag", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.MC.ParsePanic(arg1); end);
	VFLEvent:NamedBind("mag", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"), function() RDXM.MC.ParsePanic(arg1); end);
	VFLEvent:NamedBind("mag", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"), function() RDXM.MC.ParsePanic(arg1); end);
	RDXM.MC.magFearFlag = true;
end
function RDXM.MC.MagDeactivate()
	VFLEvent:NamedUnbind("mag");
	RDXM.MC.magFearFlag = nil;
end

function RDXM.MC.ParsePanic(arg)
	if (string.find(arg,"by Panic") and RDXM.MC.magFearFlag) then
		RDXM.MC.magFearFlag = false;
		local a = RDX.Alert.Dropdown("mag_fear", "Next Fear in", 30, 5, "Sound\\Doodad\\BellTollAlliance.wav");
		a:Schedule(25, function() RDXM.MC.magFearFlag = true; end);
	end
end

RDXM.MC.enctbl["magmadar"] = {
	DeactivateEncounter = RDXM.MC.MagDeactivate;
	ActivateEncounter = RDXM.MC.MagActivate;
};



