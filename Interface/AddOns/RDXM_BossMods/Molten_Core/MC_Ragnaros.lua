
-------------------------------------
-- RAGNAROS
-------------------------------------
function RDXM.MC.RagDeactivate()
	VFLEvent:NamedUnbind("rag");
end
function RDXM.MC.RagActivate()
	VFLEvent:NamedBind("rag", BlizzEvent("CHAT_MSG_MONSTER_YELL"), function() RDXM.MC.RagYell(arg1); end);
end
function RDXM.MC.RagStart()
	-- Setup wrath prewarning
	RDXM.MC.RagWrathWarn();
	-- Setup emerge prewarning
	RDXM.MC.RagSubmergeAlert();
end
function RDXM.MC.RagStop()
	RDX.QuashAlertsByPattern("^rag");
end

function RDXM.MC.RagYell(arg)
	-- Detect Wrath of Ragnaros
	if string.find(arg, "FLAMES OF SULFURON") then
		RDX.Alert.Simple("WRATH! Melee, get back in.", "Sound\\Doodad\\BellTollAlliance.wav", 4);
		RDXM.MC.RagWrathWarn();
	end
end

function RDXM.MC.RagWrathWarn()
	local wrathTime, leadTime, sound, color = 25, 3, "Sound\\Doodad\\BellTollAlliance.wav", {r=1, g=.33, b=0};
	RDX.Alert.Dropdown("rag_wrath", "Next Wrath in", wrathTime, leadTime, sound, color);
end

-- Manually create the submerge/sons alert.
function RDXM.MC.RagSubmergeAlert()
	local ragTime, leadTime = 180, 15;
	local alert = RDX.Alert.Dropdown("rag_submerge", "Ragnaros submerges in", ragTime, leadTime);
	alert:Schedule(ragTime, RDXM.MC.RagSonsAlert);
end
function RDXM.MC.RagSonsAlert()
	local sonsTime, leadTime = 90, 15;
	RDX.Alert.Dropdown("rag_emerge", "Ragnaros emerges in", sonsTime, leadTime);
end

RDXM.MC.enctbl["ragnaros"] = {
	DeactivateEncounter = RDXM.MC.RagDeactivate;
	ActivateEncounter = RDXM.MC.RagActivate;
	StartEncounter = RDXM.MC.RagStart;
	StopEncounter = RDXM.MC.RagStop;
};