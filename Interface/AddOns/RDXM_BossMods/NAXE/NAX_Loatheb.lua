------------------------------------
-- Loatheb
------------------------------------
local loatheb_track
local loatheb_sigupdate
local loatheb_doomcount
local loatheb_hadspore

function RDXM.NAXE.LoathebActivate()
	-- Tracking
	loatheb_track = HOT.TrackTarget("Loatheb");
	loatheb_sigupdate = loatheb_track.SigUpdate:Connect(RDXM.NAXE, "LoathebUpdate");

	VFLEvent:NamedBind("loatheb", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.NAXE.LoathebParseFungalBloom(arg1); end);

	if IsRaidLeader() then
		RDXM.BossMods.SetThreatMasterTarget("Loatheb", 2)
	end
end

function RDXM.NAXE.LoathebParseFungalBloom(arg)
	if string.find(arg, "Fungal Bloom") then
		RDX.Alert.Dropdown("loatheb_spore", "Spore!", 90, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
	end
end

function RDXM.NAXE.LoathebDeactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("loatheb");
	
	if loatheb_track then
		loatheb_track.SigUpdate:DisconnectByHandle(loatheb_track);
		loatheb_sigupdate = nil; loatheb_track = nil;
	end
end

function RDXM.NAXE.LoathebSetupSporeOrder()
	local loatheb_sporeorder = {};
	local classPriority = { "Warrior", "Mage", "Rogue", "Shaman", "Hunter", "Druid", "Priest", "Warlock" };
	for i = 1, 8 do
		for j = 1, GetNumRaidMembers() do
			local unit = "raid" .. j;
			if (UnitClass(unit) == classPriority[i]) then
				tinsert(loatheb_sporeorder, table.getn(loatheb_sporeorder), UnitName(unit));
			end
		end
	end
	RPC.Invoke("loatheb_sporeorder", loatheb_sporeorder);
end

function RDXM.NAXE.LoathebSetupHealerOrder()
	if loatheb_healers then
		RPC.Invoke("loatheb_healerorder", loatheb_healers);
	end
end

function RDXM.NAXE.LoathebSetupHealerChannel()
	if loatheb_healerchannel then
		RPC.Invoke("loatheb_healerchannel", loatheb_healerchannel);
	end
end

function RDXM.NAXE.LoathebStart()
	loatheb_hadspore = nil;
	loatheb_doomcount = 1;
	VFL.scheduleExclusive("loatheb_doom", 120, function() RDXM.NAXE.LoathebStartDoomTimer(); end);
	RDX.Alert.Dropdown("loatheb_doom", "Impending Doom - Bandage After", 120, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=1, g=.2, b=.2});

	if (IsRaidLeader()) then
		RDXM.NAXE.LoathebSetupSporeOrder();
		RDXM.NAXE.LoathebSetupHealerOrder();
		RDXM.NAXE.LoathebSetupHealerChannel();
	end
end

function RDXM.NAXE.LoathebStop()
	--remove any lingering alerts
	RDX.QuashAlertsByPattern("^loatheb_")

	--unschedule everything else
	VFL.removeScheduledEventByName("loatheb_doom");
	VFL.removeScheduledEventByName("loatheb_healstart");
end

function RDXM.NAXE.LoathebStartDoomTimer()
	-- Show next Web Spray timer
	loatheb_doomcount = loatheb_doomcount + 1;
	if (loatheb_doomcount < 8) then
		local text = "Impending Doom";
		local consumable = "";
		if (loatheb_doomcount == 2) then
			consumable = " - Small Healsthone + Greater Shadow Protection After";
		elseif (loatheb_doomcount == 3) then
			consumable = " - Bandage After";
		elseif (loatheb_doomcount == 4) then
			if (UnitClass("player") == "Mage" or UnitClass("player") == "Priest" or UnitClass("player") == "Shaman") then
				consumable = " - Lightwell After";
			elseif (UnitClass("player") == "Druid") then
				consumable = " - Frenzied Regeneration After";
			end
		elseif (loatheb_doomcount == 5) then
			consumable = " - Bandage After";
		elseif (loatheb_doomcount == 6) then
			consumable = " - Big Healthstone + Greater Shadow Protection After";
		elseif (loatheb_doomcount == 7) then
			consumable = " - Bandage After";
		end

		if (UnitClass("player") == "Warlock") then
			consumable = consumable .. " (AND SHADOW WARD!)";
		end

		text = text .. consumable;

		RDX.Alert.Dropdown("loatheb_doom", text, 30, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=1, g=.2, b=.2});
		VFL.scheduleExclusive("loatheb_doom", 30, function() RDXM.NAXE.LoathebStartDoomTimer(); end);
	else
		RDX.Alert.Dropdown("loatheb_doom", "Impending Doom", 15, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=1, g=.2, b=.2});
		VFL.scheduleExclusive("loatheb_doom", 15, function() RDXM.NAXE.LoathebStartDoomTimer(); end);
	end
end

function RDXM.NAXE.LoathebUpdate()
	RDX.AutoStartStopEncounter(loatheb_track);
	RDX.AutoUpdateEncounterPane(loatheb_track);
end

function RDXM.NAXE.LoathebSporeOrder_RPC(sender, order)
	if sender:IsLeader() then
		for i=1, table.getn(order) do
			if order[i] == UnitName("player") then
				local group = math.ceil(i / 5);
				local sporetime = 10 + (group - 1) * 15;
				RDX.Alert.Dropdown("loatheb_spore", "Spore!", sporetime, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.2, g=1, b=.2});
				return;
			end
		end
	end
end
RPC.Bind("loatheb_sporeorder", RDXM.NAXE.LoathebSporeOrder_RPC);

function RDXM.NAXE.LoathebStartingHeal()
	if loatheb_healerchannel then
		local channel = GetChannelName(loatheb_healerchannel);
		if (channel) then
			SendChatMessage(UnitName("player") .. " is starting to heal!", "CHANNEL", nil, channel);
		end
	end
end

function RDXM.NAXE.LoathebHealerOrder_RPC(sender, order)
	if sender:IsLeader() then
		for i=1, table.getn(order) do
			if order[i] == UnitName("player") then
				local healspacing = 60 / table.getn(order);
				local healstart = i * healspacing;
				RDX.Alert.Dropdown("loatheb_heal", "Heal!", healstart, 5, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=1, g=.2, b=.2});
				VFL.scheduleExclusive("loatheb_healstart", healstart, function() RDXM.NAXE.LoathebStartingHeal(); end);
				return;
			end
		end
	end
end
RPC.Bind("loatheb_healerorder", RDXM.NAXE.LoathebHealerOrder_RPC);

function RDXM.NAXE.LoathebHealerChannel_RPC(sender, channel)
	loatheb_healerchannel = channel;
end
RPC.Bind("loatheb_healerchannel", RDXM.NAXE.LoathebHealerChannel_RPC);

RDXM.NAXE.enctbl["loatheb"] = {
	ActivateEncounter = RDXM.NAXE.LoathebActivate;
	DeactivateEncounter = RDXM.NAXE.LoathebDeactivate;
	StartEncounter = RDXM.NAXE.LoathebStart;
	StopEncounter = RDXM.NAXE.LoathebStop;
};