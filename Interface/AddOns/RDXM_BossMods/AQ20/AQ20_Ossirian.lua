
---------------------------------
-- OSSIRIAN THE UNSCARRED
---------------------------------
local oss_track = nil;
local oss_sigupdate = nil;
local oss_supreme_alert = nil;
local oss_target_alert = nil;
local oss_target = nil;
local oss_supreme_lock = false;


-- Supreme mode management
function RDXM.AQ20.OssirianParse()
	-- If "Strength of Ossirian" fades from him, he's definitely not supreme anymore
	if string.find(arg1, "^Strength of Ossirian fades from") then
		RDXM.AQ20.OssirianCombatLogNotSupreme();
		return;
	end
end

function RDXM.AQ20.OssirianCombatLogNotSupreme()
	RDXM.AQ20.OssirianNotSupreme();
	RPC.Invoke("oss_notsupreme");
end

function RDXM.AQ20.OssirianNotSupreme()
	-- Prevent accidental spam
	if oss_supreme_lock then return; end
	oss_supreme_lock = true; VFL.schedule(5, function() oss_supreme_lock = false; end);
	-- Ding and set not supreme
	PlaySoundFile("Sound\\Doodad\\BellTollAlliance.wav");
	RDXM.AQ20.OssirianSetNotSupreme();
end

function RDXM.AQ20.OssirianSetSupreme()
	if oss_supreme_alert then
		oss_supreme_alert.dataFunc = nil;
		oss_supreme_alert.tw:SetTime(0);
		oss_supreme_alert.statusBar:SetValue(1);
		oss_supreme_alert.timeline = {};
	end
end
function RDXM.AQ20.OssirianSetNotSupreme()
	if oss_supreme_alert then
		oss_supreme_alert.dataFunc = RDX.Alert.GenFlashCountdownFunc(30, GetTime() + 30, 7);
		oss_supreme_alert.timeline = {};
		oss_supreme_alert:Schedule(23, function() PlaySoundFile("Sound\\Doodad\\BellTollAlliance.wav"); end);
	end
end


function RDXM.AQ20.OssirianUpdate()
	RDX.AutoUpdateEncounterPane(oss_track);
	RDX.AutoStartStopEncounter(oss_track);
	if not RDX.EncounterIsRunning() then return; end
	-- If there's no target, set to unknown
	if (not oss_track:IsTracking()) or (not oss_track.targetIsRaider) then
		if oss_target then
			oss_target = nil;
			oss_target_alert:SetText("Ossirian's target: (unknown)");
			PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav");
		end
		return;
	end
	-- If the target has changed, update...
	if(oss_track.targetName ~= oss_target) then
		oss_target = oss_track.targetName;
		oss_target_alert:SetText("Ossirian's target: " .. oss_target);
		PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav");
	end
end

function RDXM.AQ20.OssirianActivate()
	-- Target tracking
	if not oss_track then
		oss_track = HOT.TrackTarget("Ossirian the Unscarred");
		oss_sigupdate = oss_track.SigUpdate:Connect(RDXM.AQ, "OssirianUpdate");
	end
	-- Combat log events
	VFLEvent:NamedBind("oss", BlizzEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER"), RDXM.AQ20.OssirianParse);
	VFLEvent:NamedBind("oss", BlizzEvent("CHAT_MSG_SPELL_BREAK_AURA"), RDXM.AQ20.OssirianParse);
	VFLEvent:NamedBind("oss", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"), RDXM.AQ20.OssirianParse);
	VFLEvent:NamedBind("oss", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"), RDXM.AQ20.OssirianParse);
	VFLEvent:NamedBind("oss", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"), RDXM.AQ20.OssirianParse);
	VFLEvent:NamedBind("oss", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), RDXM.AQ20.OssirianParse);	
	-- RPCs
	RPC.Bind("oss_notsupreme", RDXM.AQ20.OssirianNotSupreme);
end

function RDXM.AQ20.OssirianDeactivate()
	if oss_track then
		oss_track.SigUpdate:DisconnectByHandle(oss_sigupdate);
		oss_sigupdate = nil; oss_track = nil;
	end
	VFLEvent:NamedUnbind("oss");
	RPC.UnbindPattern("^oss_");
end

function RDXM.AQ20.OssirianStart()
	if not oss_target_alert then
		oss_target_alert = RDX.GetAlert();
		oss_target_alert:SetText("Ossirian's target: (unknown)");
		oss_target_alert.tw:Hide();
		oss_target_alert:ToCenter(); oss_target_alert:Show(); oss_target_alert:SetAlpha(0.6);
	end
	if not oss_supreme_alert then
		oss_supreme_alert = RDX.GetAlert();
		oss_supreme_alert:SetText("Ossirian goes supreme in");
		oss_supreme_alert:ToCenter(); oss_supreme_alert:Show(); oss_supreme_alert:SetAlpha(0.6);
	end
	oss_target = nil;
	RDXM.AQ20.OssirianSetSupreme();
end

function RDXM.AQ20.OssirianStop()
	if oss_supreme_alert then
		oss_supreme_alert:Fade(2,0);
		oss_supreme_alert:Schedule(3, function(self) self:Destroy(); end);
		oss_supreme_alert = nil;
	end
	if oss_target_alert then
		oss_target_alert:Fade(2,0);
		oss_target_alert:Schedule(3, function(self) self:Destroy(); end);
		oss_target_alert = nil;
	end
	oss_target = nil;
end

-- Event table
RDXM.AQ20.enctbl["oss"] = {
	DeactivateEncounter = RDXM.AQ20.OssirianDeactivate;
	ActivateEncounter = RDXM.AQ20.OssirianActivate;
	StartEncounter = RDXM.AQ20.OssirianStart;
	StopEncounter = RDXM.AQ20.OssirianStop;
};