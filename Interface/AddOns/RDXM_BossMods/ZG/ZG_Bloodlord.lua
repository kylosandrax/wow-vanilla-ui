
--------------------------------------
-- GEDDON
--------------------------------------
function RDXM.MC.GeddonActivate()
	VFLEvent:NamedBind("mandokir", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.ZG.ParseBloodlordWatching(arg1); end);
	VFLEvent:NamedBind("mandokir", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"), function() RDXM.ZG.ParseBloodlordWatching(arg1); end);
	VFLEvent:NamedBind("mandokir", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"), function() RDXM.ZG.ParseBloodlordWatching(arg1); end);
end
function RDXM.MC.GeddonDeactivate()
	VFLEvent:NamedUnbind("mandokir");
end

function RDXM.MC.ParseLivingBomb(arg)
	local _,_,player = string.find(arg, "^([^%s]+)! I'm watching you!$");
	if not player then return; end
	local name,flash,sound = "",0,"Sound\\Doodad\\BellTollAlliance.wav";
	if(player == UnitName("player")) then
		name = player; flash = 20;
		RDX.Alert.Simple("***YOU ARE BEING WATCHED***!", nil, 3, true);
	else
		name = player;
		-- Send a tell if announce is on
		if(RDXU.spam) then
			SendChatMessage("YOU ARE BEING WATCHED!", "WHISPER", nil, player);
		end
	end
	RDX.Alert.CenterPopup(nil, name .. " is being watched for", 6, sound, flash);
end

-- RDX event table
RDXM.ZG.enctbl["mandokir"] = {
	DeactivateEncounter = RDXM.ZG.MandokirDeactivate;
	ActivateEncounter = RDXM.ZG.MandokirActivate;
};
