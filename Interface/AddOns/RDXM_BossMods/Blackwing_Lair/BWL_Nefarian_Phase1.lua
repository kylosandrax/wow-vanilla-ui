
-------------------------------------
-- NEFARIAN PHASE 1
-------------------------------------
-- Activate Phase 1 handlers
function RDXM.BWL.Nef1Activate()
	VFLEvent:NamedBind("nef1", BlizzEvent("CHAT_MSG_MONSTER_YELL"), function() RDXM.BWL.Nef1OnYell(arg1); end);
end
function RDXM.BWL.Nef1Deactivate()
	VFLEvent:NamedUnbind("nef1");
end

-- Nef Yell binding
function RDXM.BWL.Nef1OnYell(arg)
	local sound = "Sound\\Doodad\\BellTollAlliance.wav";
	if(string.find(arg, "Well done, my minions")) then
		RDX.Alert.CenterPopup("nef1", "Nefarian Landing", 10, sound, 10);
	elseif(string.find(arg, "BURN! You wretches")) then
		RDX.Alert.Simple("Nefarian has landed!", nil, 2);
		-- Autotransition to phase 2
		RDX.SetActiveEncounter("nefarian2", true);
		RDX.StartEncounter(true);
	end
end

-- Handlers
RDXM.BWL.enctbl["nefarian1"] = {
	ActivateEncounter = RDXM.BWL.Nef1Activate;
	DeactivateEncounter = RDXM.BWL.Nef1Deactivate;
};