--------------------------------------
-- Gluth
--------------------------------------
local gluth_fearlockout = nil;

function RDXM.NAXW.GluthActivate()
	-- Events
	VFLEvent:NamedBind("gluth", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.NAXW.GluthFear(arg1); end);
	VFLEvent:NamedBind("gluth", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"), function() RDXM.NAXW.GluthFear(arg1); end);
	VFLEvent:NamedBind("gluth", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"), function() RDXM.NAXW.GluthFear(arg1); end);
	-- Tracking
	gluth_track = HOT.TrackTarget("Gluth");
	gluth_sigupdate = gluth_track.SigUpdate:Connect(RDXM.NAXW, "GluthUpdate");
	
	--if i'm the raid leader, set the master target to glutch after a 2 second pause
	if IsRaidLeader() then
		RDXM.BossMods.SetThreatMasterTarget("Gluth", 2)
	end
		
end


function RDXM.NAXW.GluthDeactivate()
	-- Cleanup events
	VFLEvent:NamedUnbind("gluth");
	-- Cleanup tracking
	if gluth_track then
		gluth_track.SigUpdate:DisconnectByHandle(gluth_sigupdate);
		gluth_sigupdate = nil; gluth_track = nil;
	end
	-- Cleanup alerts
	RDX.QuashAlertsByPattern("^gluth");
end

function RDXM.NAXW.GluthStart()
	-- Fear prewarning
	RDXM.NAXW.GluthFearAlert()
end

function RDXM.NAXW.GluthStop()
	-- Quash alerts
	RDX.QuashAlertsByPattern("^gluth");
end

function RDXM.NAXW.GluthUpdate()
	RDX.AutoStartStopEncounter(gluth_track);
	RDX.AutoUpdateEncounterPane(gluth_track);
end

function RDXM.NAXW.GluthFear(arg)
	if gluth_fearlockout then return; end
	if string.find(arg,"by Terrifying Roar") or string.find(arg,"Terrifying Roar failed") then
		RDXM.NAXW.GluthFearAlert()
		gluth_fearlockout = true;
		VFL.schedule(17, function() gluth_fearlockout = false; end);
	end
end

function RDXM.NAXW.GluthFearAlert()
	RDX.Alert.Dropdown("gluth_fear", "Next Fear in", 20, 5, "Sound\\Doodad\\BellTollAlliance.wav", {r=1, g=0, b=1});
end

RDXM.NAXW.enctbl["gluth"] = {
	DeactivateEncounter = RDXM.NAXW.GluthDeactivate;
	ActivateEncounter = RDXM.NAXW.GluthActivate;
	StartEncounter = RDXM.NAXW.GluthStart;
	StopEncounter = RDXM.NAXW.GluthStop;	
};