------------------------------------
-- Gothik
------------------------------------
local gothik_track
local gothik_sigupdate

local gothik_traineewave
local gothik_deathknightwave
local gothik_riderwave

function RDXM.NAXE.GothikActivate()
	-- Tracking
	gothik_track = HOT.TrackTarget("Gothik the Harvester");
	gothik_sigupdate = gothik_track.SigUpdate:Connect(RDXM.NAXE, "GothikUpdate");
	VFLEvent:NamedBind("gothik", BlizzEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH"), function() RDXM.NAXE.GothikUnitDeath(arg1); end);
	VFLEvent:NamedBind("gothik", BlizzEvent("SPELLCAST_START"), function() RDXM.NAXE.GothikStartCast(arg1); end);
	VFLEvent:NamedBind("gothik", BlizzEvent("CHAT_MSG_MONSTER_YELL"), function() if string.find(arg2, "Gothik") then RDX.StartEncounter(); end; end);
end

function RDXM.NAXE.GothikStartCast(arg1)
	if arg1 == "Shackle Undead" then
		RPC.Invoke("gothik_shackle");
	end
end

function RDXM.NAXE.GothikShackle_RPC(sender)
	if IsRaidLeader() then
		local priestCount = 0;
		for i = 1, GetNumRaidMembers() do
			local unit = "raid" .. i;
			if UnitClass(unit) == "Priest" then
				priestCount = priestCount + 1;
				if string.lower(UnitName(unit)) == sender.name then
					SetRaidTarget(unit .. "target", priestCount);
					break;
				end
			end
		end	
	end
end
RPC.Bind("gothik_shackle", RDXM.NAXE.GothikShackle_RPC);

function RDXM.NAXE.GothikUpdate()
	RDX.AutoStartStopEncounter(gothik_track);
	RDX.AutoUpdateEncounterPane(gothik_track);
end

function RDXM.NAXE.GothikRiderDied_RPC(sender)
	if sender:IsLeader() then
		RDX.Alert.Simple("Unrelenting Rider has died!", "Sound\\Doodad\\BellTollAlliance.wav", 5, 1);
	end
end
RPC.Bind("gothik_rider_died", RDXM.NAXE.GothikRiderDied_RPC);

function RDXM.NAXE.GothikUnitDeath(arg1)
	if (IsRaidLeader()) then
		if (string.find(arg1, "Unrelenting Rider")) then
			RPC.Invoke("gothik_rider_died");
		end
	end
end

function RDXM.NAXE.GothikDeactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("gothik");
	
	if gothik_track then
		gothik_track.SigUpdate:DisconnectByHandle(gothik_track);
		gothik_sigupdate = nil; gothik_track = nil;
	end
end

function RDXM.NAXE.GothikStart()
	gothik_traineewave = 1
	gothik_deathknightwave = 1
	gothik_riderwave = 1

	--Start the spawn timers
	-- trainees
	VFL.scheduleExclusive("gothik_trainees", 25, function() RDXM.NAXE.GothikStartTraineeTimer(); end);
	RDX.Alert.Dropdown("gothik_trainees", "Trainees (" .. gothik_traineewave .. " of 11)", 25, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});

	-- deathknights
	VFL.scheduleExclusive("gothik_deathknights", 75, function() RDXM.NAXE.GothikStartDeathknightTimer(); end);
	RDX.Alert.Dropdown("gothik_deathknights", "Deathknights (" .. gothik_deathknightwave .. " of 7)", 75, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});

	-- riders
	VFL.scheduleExclusive("gothik_riders", 135, function() RDXM.NAXE.GothikStartRiderTimer(); end);
	RDX.Alert.Dropdown("gothik_riders", "Riders (" .. gothik_riderwave .. " of 4)", 135, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});

	-- gothik
	VFL.scheduleExclusive("gothik_coming", 225, function() RDXM.NAXE.GothikStartGothikTimer(); end);
end

function RDXM.NAXE.GothikStartTraineeTimer()
	gothik_traineewave = gothik_traineewave + 1
	VFL.scheduleExclusive("gothik_trainees", 20, function() RDXM.NAXE.GothikStartTraineeTimer(); end);
	RDX.Alert.Dropdown("gothik_trainees", "Trainees (" .. gothik_traineewave .. " of 11)", 20, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
end

function RDXM.NAXE.GothikStartDeathknightTimer()
	gothik_deathknightwave = gothik_deathknightwave + 1
	VFL.scheduleExclusive("gothik_deathknights", 25, function() RDXM.NAXE.GothikStartDeathknightTimer(); end);
	RDX.Alert.Dropdown("gothik_deathknights", "Deathknights (" .. gothik_deathknightwave .. " of 7)", 25, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
end

function RDXM.NAXE.GothikStartRiderTimer()
	gothik_riderwave = gothik_riderwave + 1
	VFL.scheduleExclusive("gothik_riders", 30, function() RDXM.NAXE.GothikStartRiderTimer(); end);
	RDX.Alert.Dropdown("gothik_riders", "Riders (" .. gothik_riderwave .. " of 4)", 30, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
end

function RDXM.NAXE.GothikStartGothikTimer()
	--remove any lingering alerts
	RDX.QuashAlertsByPattern("^gothik_")

	VFL.removeScheduledEventByName("gothik_trainees");
	VFL.removeScheduledEventByName("gothik_deathknights");
	VFL.removeScheduledEventByName("gothik_riders");

	RDX.Alert.Dropdown("gothik_coming", "Gothik", 40, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
end

function RDXM.NAXE.GothikStop()
	--remove any lingering alerts
	RDX.QuashAlertsByPattern("^gothik_")

	VFL.removeScheduledEventByName("gothik_trainees");
	VFL.removeScheduledEventByName("gothik_deathknights");
	VFL.removeScheduledEventByName("gothik_riders");
	VFL.removeScheduledEventByName("gothik_coming");

	
end

RDXM.NAXE.enctbl["gothik"] = {
	ActivateEncounter = RDXM.NAXE.GothikActivate;
	DeactivateEncounter = RDXM.NAXE.GothikDeactivate;
	StartEncounter = RDXM.NAXE.GothikStart;
	StopEncounter = RDXM.NAXE.GothikStop;
};