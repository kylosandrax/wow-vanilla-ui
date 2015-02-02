

-------------------------------------
-- MAJORDOMO
-------------------------------------
function RDXM.MC.DomoActivate()
	VFLEvent:NamedBind("domo", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"), function() RDXM.MC.ParseDomo(arg1); end);
	VFLEvent:NamedBind("domo", BlizzEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER"), function() RDXM.MC.ParseDomoDown(arg1); end);
	RDXM.MC.domoPowerUp = false;
end
function RDXM.MC.DomoDeactivate()
	VFLEvent:NamedUnbind("domo");
	RDXM.MC.domoPowerUp = nil;
end

function RDXM.MC.ParseDomo(arg)
	local abilTime, leadTime, sound = 30, 5, "Sound\\Doodad\\BellTollAlliance.wav";
	-- If a power is already up, ignore
	if RDXM.MC.domoPowerUp then return; end
	if(string.find(arg, "gains Magic Reflection")) then
		RDX.Alert.CenterPopup(nil, "Magic Reflection - Don't Cast", 10, "Sound\\Doodad\\BellTollNightElf.wav", 10);
	elseif(string.find(arg, "gains Damage Shield")) then
		RDX.Alert.CenterPopup(nil, "Damage Shield - Don't Swing", 10, "Sound\\Doodad\\BellTollHorde.wav", 10);
	else
		-- If no power, do nothing further
		return;
	end
	-- Mark power as up
	RDXM.MC.domoPowerUp = true;
	-- Schedule next domo power
	RDX.Alert.Dropdown("domo", "Next Majordomo power", abilTime, leadTime, sound);
end

function RDXM.MC.ParseDomoDown(arg)
	if not RDXM.MC.domoPowerUp then return; end
	if(string.find(arg, "Magic Reflection fades")) or (string.find(arg,"Damage Shield fades")) then
		RDXM.MC.domoPowerUp = false;
	end
end

-- RDX event table
RDXM.MC.enctbl["majordomo"] = {
	DeactivateEncounter = RDXM.MC.DomoDeactivate;
	ActivateEncounter = RDXM.MC.DomoActivate;
};