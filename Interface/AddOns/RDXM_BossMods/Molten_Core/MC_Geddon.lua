
--------------------------------------
-- GEDDON
--------------------------------------
function RDXM.MC.GeddonActivate()
	VFLEvent:NamedBind("geddon", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.MC.ParseLivingBomb(arg1); end);
	VFLEvent:NamedBind("geddon", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"), function() RDXM.MC.ParseLivingBomb(arg1); end);
	VFLEvent:NamedBind("geddon", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"), function() RDXM.MC.ParseLivingBomb(arg1); end);
end
function RDXM.MC.GeddonDeactivate()
	VFLEvent:NamedUnbind("geddon");
end

function RDXM.MC.ParseLivingBomb(arg)
	local _,_,player = string.find(arg, "^(%w+) %w+ afflicted by Living Bomb");
	if not player then return; end
	local name,flash,sound = "",0,"Sound\\Doodad\\BellTollAlliance.wav";
	if(player == "You") then
		name = UnitName("player"); flash = 20;
		RDX.Alert.Simple("YOU ARE THE BOMB!", nil, 3, true);
	else
		name = player;
		-- Send a tell if announce is on
		if(RDXU.spam) then
			SendChatMessage("YOU ARE THE BOMB!", "WHISPER", nil, player);
		end
	end
	RDX.Alert.CenterPopup(nil, "Living Bomb: " .. name .. " explodes in", 10, sound, flash);
end

-- RDX event table
RDXM.MC.enctbl["geddon"] = {
	DeactivateEncounter = RDXM.MC.GeddonDeactivate;
	ActivateEncounter = RDXM.MC.GeddonActivate;
};