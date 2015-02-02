

-------------------------------------
-- VAELASTRASZ
-------------------------------------
-- Burning Adrenaline
function RDXM.BWL.ParseBA(str)
	local _, _, player = string.find(str, "^(%w+) %w+ afflicted by Burning Adrenaline.");
	if not player then return; end
	local name,flash,sound = "",0,"Sound\\Doodad\\BellTollAlliance.wav";
	if (player == "You") then
		name = UnitName("player"); flash=20;
		RDX.Alert.Simple("YOU HAVE BURNING ADRENALINE!", nil, 3, true);
	else
		name = player;
	end
	RDX.Alert.CenterPopup(nil, "BA: " .. name .. " explodes in", 20, sound, flash);
end

-- Metacontrol
local vael_track = nil;
local vael_sigupdate = nil;

function RDXM.BWL.VaelActivate()
	VFLEvent:NamedBind("vael", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.BWL.ParseBA(arg1); end);
	VFLEvent:NamedBind("vael", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"), function() RDXM.BWL.ParseBA(arg1); end);
	VFLEvent:NamedBind("vael", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"), function() RDXM.BWL.ParseBA(arg1); end);
	if not vael_track then
		vael_track = HOT.TrackTarget("Vaelastrasz the Corrupt");
		vael_sigupdate = vael_track.SigUpdate:Connect(RDXM.BWL, "VaelUpdate");
	end
end
function RDXM.BWL.VaelDeactivate()
	VFLEvent:NamedUnbind("vael");
	if vael_track then
		vael_track.SigUpdate:DisconnectByHandle(vael_sigupdate);
		vael_sigupdate = nil; vael_track = nil;
	end
end

function RDXM.BWL.VaelUpdate()
	RDX.AutoStartStopEncounter(vael_track);
	RDX.AutoUpdateEncounterPane(vael_track);
end

-- Event table
RDXM.BWL.enctbl["vael"] = {
	DeactivateEncounter = RDXM.BWL.VaelDeactivate;
	ActivateEncounter = RDXM.BWL.VaelActivate;
};
