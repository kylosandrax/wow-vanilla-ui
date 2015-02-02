
-------------------------------------
-- NEFARIAN PHASE 2
-------------------------------------
-- Activate/deactivate Phase 2
local nef_track = nil;
local nef_sigupdate = nil;

function RDXM.BWL.Nef2Activate()
	VFLEvent:NamedBind("nef2", BlizzEvent("CHAT_MSG_MONSTER_YELL"), function() RDXM.BWL.Nef2OnYell(arg1); end);
	VFLEvent:NamedBind("nef2", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.BWL.Nef2OnCVCD(arg1); end);
	if not nef_track then
		nef_track = HOT.TrackTarget("Nefarian");
		nef_sigupdate = nef_track.SigUpdate:Connect(RDXM.BWL, "Nef2Update");
	end
end
function RDXM.BWL.Nef2Deactivate()
	VFLEvent:NamedUnbind("nef2");
	if nef_track then
		nef_track.SigUpdate:DisconnectByHandle(nef_sigupdate);
		nef_sigupdate = nil;
		nef_track = nil;
	end
end

function RDXM.BWL.Nef2Update()
	RDX.AutoUpdateEncounterPane(nef_track);
end

-- Yell handler
RDXM.BWL.nefYells = {
	["Impossible! Rise my"] = function() RDX.Alert.Simple("Skeleton Zerg!", "Sound\\Doodad\\BellTollAlliance.wav", 2); end,
	["Druids"] = function() RDXM.BWL.Nef2ClassCall("DRUIDS - Stuck in Catform"); end,
	["Warlocks"] = function() RDXM.BWL.Nef2ClassCall("WARLOCKS - Infernals inc"); end,
	["Priests"] = function() RDXM.BWL.Nef2ClassCall("PRIESTS - STOP HEALING!!"); end,
	["Hunters"] = function() RDXM.BWL.Nef2ClassCall("HUNTERS - Ranged weapons damaged"); end,
	["Warriors"] = function() RDXM.BWL.Nef2ClassCall("WARRIORS - Zerker stance, +50% dmg"); end,
	["Rogues"] = function() RDXM.BWL.Nef2ClassCall("ROGUES - Teleported/rooted"); end,
	["Paladins"] = function() RDXM.BWL.Nef2ClassCall("PALADINS - BoP on Nefarian - DISPEL HIM"); end,
	["Mages"] = function() RDXM.BWL.Nef2ClassCall("MAGES - Polymorph on Raid - SPAM DISPEL"); end,
};
function RDXM.BWL.Nef2OnYell(arg)
	for k,v in RDXM.BWL.nefYells do
		if string.find(arg,k) then v(); return; end
	end
end

-- Shadowflame and fear handler
function RDXM.BWL.Nef2OnCVCD(arg)
	local sound = "Sound\\Doodad\\BellTollAlliance.wav";
	if(arg == "Nefarian begins to cast Bellowing Roar.") then
		RDX.Alert.CenterPopup("nef2", "FEAR", 2, sound, nil, {r=.3,g=.3,b=.3});
	elseif(arg == "Nefarian begins to cast Shadow Flame.") then
		RDXM.BWL.Shadowflame();
	end
end

-- Classcall countdown timer
function RDXM.BWL.Nef2ClassCallCountdown()
	local ccTime, leadTime, sound = 40, 5, "Sound\\Doodad\\BellTollAlliance.wav";
	RDX.Alert.Dropdown("nef2", "Next class call", ccTime, leadTime, sound, {r=.1, g=.45, b=.8});
end

-- Classcall main handler
function RDXM.BWL.Nef2ClassCall(text)
	local sound = "Sound\\Doodad\\BellTollAlliance.wav";
	RDXM.BWL.Nef2ClassCallCountdown();
	RDX.Alert.Simple(text, sound, 10);
end

RDXM.BWL.enctbl["nefarian2"] = {
	ActivateEncounter = RDXM.BWL.Nef2Activate;
	DeactivateEncounter = RDXM.BWL.Nef2Deactivate;
	StartEncounter = RDXM.BWL.Nef2ClassCallCountdown;
}