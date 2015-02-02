------------------------
-- Grobbulus
------------------------

local grob_spraylock = nil;
local grob_injected = {
	["name"] = nil,
	["time"] = nil,
	}
local grob_track = nil;
local grob_sigupdate = nil;
local grob_heartbeat = nil;

function RDXM.NAXW.GrobDeactivate()
	-- Cleanup binds
	VFLEvent:NamedUnbind("grob");
	RPC.UnbindPattern("^grob_");
	-- Cleanup tracking
	if grob_track then
		grob_track.SigUpdate:DisconnectByHandle(grob_sigupdate);
		grob_sigupdate = nil; grob_track = nil;
	end
	-- Cleanup alerts
	RDX.QuashAlertsByPattern("^grob");
end

function RDXM.NAXW.GrobActivate()
	-- Event Binds
	VFLEvent:NamedBind("grob", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.NAXW.GrobAbility(arg1); end); -- Slime Spray/cloud
	VFLEvent:NamedBind("grob", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE"), function() RDXM.NAXW.GrobAbility(arg1); end); -- Slime Spray/cloud
	VFLEvent:NamedBind("grob", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"), function() RDXM.NAXW.GrobAbility(arg1); end); -- Slime Spray/cloud
	VFLEvent:NamedBind("grob", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.NAXW.GrobAbility(arg1); end); -- Gain mutating injection
	VFLEvent:NamedBind("grob", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"), function() RDXM.NAXW.GrobAbility(arg1); end); -- cloud
	-- RPC Binds
	RPC.Bind("grob_spray", RDXM.NAXW.GrobSprayDetected);
	-- Tracking
	grob_track = HOT.TrackTarget("Grobbulus");
	grob_sigupdate = grob_track.SigUpdate:Connect(RDXM.NAXW, "GrobUpdate");


	--if i'm the raid leader, set the master target to glutch after a 2 second pause
	if IsRaidLeader() then
		RDXM.BossMods.SetThreatMasterTarget("Grobbulus", 2)
	end
end

function RDXM.NAXW.GrobStart()
	-- Clear any existing timers
	RDX.QuashAlertsByPattern("^grob")
	-- Setup slime spray prewarning
	RDXM.NAXW.GrobSprayWarn();
	-- Start heartbeat
	grob_heartbeat = true;
	RDXM.NAXW.GrobHeartbeat()	
end

function RDXM.NAXW.GrobStop()
	-- Stop heartbeat
	grob_heartbeat = false;
	-- Clear any existing timers
	RDX.QuashAlertsByPattern("^grob");
end

function RDXM.NAXW.GrobUpdate()
	RDX.AutoStartStopEncounter(grob_track);
	RDX.AutoUpdateEncounterPane(grob_track);
end

function RDXM.NAXW.GrobAbility(arg)
	-- Detect Locust swarm
	if string.find(arg, "Grobbulus's Slime Spray") then
		RDXM.NAXW.GrobSprayDetected();
		if grob_spraylock then return; end
		RPC.Invoke("grob_spray");
	elseif string.find(arg, "casts Poison.") then
		local c = UnitClass("player")
		if c == "Rogue" or c == "Warrior" then
			RDXM.NAXW.GrobCloudWarn();
		end
	elseif string.find(arg,  "Mutating Injection") then
		RDXM.NAXW.GrobMutating()
	end
end

function RDXM.NAXW.GrobSprayDetected()
	-- Make sure there is no lockout
	if grob_spraylock then return; end
	-- Create lockout so it doesn't misfire
	grob_sprayock = true;
	-- Remove lockout in x seconds for next swarm
	VFL.schedule(20, function() grob_spraylock = false; end);
	RDXM.NAXW.GrobSprayWarn()
end

local lastperson;
local grob_injectlockout = nil;
function RDXM.NAXW.GrobInjectBar(name)
	if lastperson == name or grob_injectlockout then return; end
	lastperson = name
	grob_injectlockout = true;
	RDX.Alert.Dropdown("grob_inject", "Mutating Injection: "..name, 10, -5, nil, {r=1, g=1, b=0});
	VFL.schedule(6, function() grob_injectlockout = false; end);
end

function RDXM.NAXW.GrobSprayWarn()
	-- Create new timer and get rid of the old
	RDX.QuashAlertsByPattern("^grob_spray")
	RDX.Alert.Dropdown("grob_spray", "Slime Spray", 30, 5, nil, {r=0, g=1, b=0});
end

function RDXM.NAXW.GrobMutating()
	RDX.Alert.CenterPopup("grob_mutate", "MUTATING, RLAB!", 10, "Sound\\Doodad\\BellTollAlliance.wav", 0, {r=1, g=1, b=0}, nil, true);
	RDX.Alert.CenterPopup("grob_mutate", "MUTATING, RLAB!", 10, "Sound\\Doodad\\BellTollAlliance.wav", 0, {r=1, g=1, b=0}, nil, true);
	RDX.Alert.CenterPopup("grob_mutate", "MUTATING, RLAB!", 10, "Sound\\Doodad\\BellTollAlliance.wav", 0, {r=1, g=1, b=0}, nil, true);
end

function RDXM.NAXW.GrobCloudWarn()
	RDX.QuashAlertsByPattern("^grobuluscloud")
	RDX.Alert.CenterPopup("grobuluscloud", "Next Feet Cloud", 15, "Sound\\Doodad\\BellTollHorde.wav", 0, {r=0,g=.9,b=.3}, nil, true);
	--RDX.Alert.Simple("Poison Cloud Nearby", , 3, true)
end

function RDXM.NAXW.GrobHeartbeat()
	if not grob_heartbeat then return; end
	VFL.scheduleExclusive("grob_heartbeat", .25, function() RDXM.NAXW.GrobHeartbeat(); end);
	for i=1,GetNumRaidMembers() do
		if RDX.unit[i]:HasDebuff("mutating injection") then
			RDXM.NAXW.GrobInjectBar(UnitName(RDX.unit[i].uid))
			if GetRaidTargetIndex(RDX.unit[i].uid) ~= 8 and IsRaidOfficer() then
				SetRaidTargetIcon(RDX.unit[i].uid, 8)
			end
		else
			if GetRaidTargetIndex(RDX.unit[i].uid) == 8 and IsRaidOfficer() then
				SetRaidTargetIcon(RDX.unit[i].uid, 9)
			end
			if UnitIsUnit(RDX.unit[i].uid, "player") then
				RDX.QuashAlertsByPattern("^grob_mutate");
			end				
		end
	end
end
	

RDXM.NAXW.enctbl["grobbulus"] = {
	DeactivateEncounter = RDXM.NAXW.GrobDeactivate;
	ActivateEncounter = RDXM.NAXW.GrobActivate;
	StartEncounter = RDXM.NAXW.GrobStart;
	StopEncounter = RDXM.NAXW.GrobStop;
};