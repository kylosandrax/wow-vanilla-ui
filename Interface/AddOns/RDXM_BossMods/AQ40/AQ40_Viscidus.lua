
--------------------------------------
-- VISCIDUS
--------------------------------------


	--*****************************--
	--*      Global Variables     *--
	--*****************************--

--Counters
local viscidus_totalBolts = 0;
local viscidus_rpc_totalBolts = 0;
local viscidus_totalPhysicalHits = 0;

--Objects
local viscidus_track = nil;
local viscidus_sigupdate = nil;
local viscidus_alert = nil;

--Constants
local viscidus_freezebolts = 200; -- Amt of dmg till frozen
local viscidus_physicals = 200;  -- number of physical damage to make him explode

--Lockouts
local viscidus_frostlock = false; -- lock when frozen
local viscidus_rpcbroadcastlock = false; -- lock for 1 second after broadcasting 



	--*****************************--
	--*        Core Events        *--
	--*****************************--


function RDXM.AQ.ViscidusActivate()
	--EVENTS:

	--These events let us know whenever frost damage is done to Viscidus
	VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_SPELL_SELF_DAMAGE"), RDXM.AQ.RaidMemberDidFrostDamage);
	VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE"),RDXM.AQ.RaidMemberDidFrostDamage);
	VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_SPELL_PARTY_DAMAGE"), RDXM.AQ.RaidMemberDidFrostDamage);

	--These events fire off whenever something is hit, and are used to count the number of physical "hits" on Viscidus
	VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS"), RDXM.AQ.RaidMemberDidPhysicalDamage);
	VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_COMBAT_PARTY_HITS"), RDXM.AQ.RaidMemberDidPhysicalDamage);
	VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_COMBAT_SELF_HITS"), RDXM.AQ.RaidMemberDidPhysicalDamage);
	--VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_SPELL_SELF_DAMAGE"), RDXM.AQ.RaidMemberDidPhysicalDamage);

	--These events provide back doors to set off the events manually for testing purposes.  Comment out when comfortable with the mod
	VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_MONSTER_EMOTE"), RDXM.AQ.ViscidusEmote);
	VFLEvent:NamedBind("viscidus", BlizzEvent("CHAT_MSG_PARTY"), RDXM.AQ.partyChatMsg);


	-- Tracking  (Am I using this??)
	if not viscidus_track then
		viscidus_track = HOT.TrackTarget("Viscidus");
		viscidus_sigupdate = viscidus_track.SigUpdate:Connect(RDXM.AQ, "ViscidusUpdate");
	end

	-- RPC
	RPC.Bind("viscidus_frost_update", RDXM.AQ.RPCFrostCountUpdate);
	RPC.Bind("viscidus_frozen_update", RDXM.AQ.RPCFrozen);
end

function RDXM.AQ.ViscidusDeactivate()

	--Clean Up
	VFLEvent:NamedUnbind("viscidus");
	if viscidus_track then
		viscidus_track.SigUpdate:DisconnectByHandle(viscidus_sigupdate);
		viscidus_sigupdate = nil; viscidus_track = nil;
	end
	RPC.UnbindPattern("^viscidus_");
end

function RDXM.AQ.ViscidusStart()

	--Reset all counters to zero
	RDXM.AQ.ViscidusReset(); 

	if not viscidus_alert then
		-- create the alert
		viscidus_alert = RDX.GetAlert();

		-- "Paint" the current values (0 / 200)
		RDXM.AQ.ViscidusFrostAlertUpdate();

		-- Stylize and position
		viscidus_alert.tw:Hide();
		viscidus_alert:SetColor({r=0,g=0,b=1});
		viscidus_alert:ToCenter(); viscidus_alert:Show(); viscidus_alert:SetAlpha(0.6);
	end

end

function RDXM.AQ.ViscidusStop()

	--Clean up

	if viscidus_alert then
		viscidus_alert:Fade(2,0);
		viscidus_alert:Schedule(3, function(self) self:Destroy(); end);
		viscidus_alert = nil;
	end
	viscidus_frostlock= false;
	RDX.QuashAlertsByPattern("^viscidus_")

end

function RDXM.AQ.ViscidusUpdate()

	--Am I using this??
	RDX.AutoStartStopEncounter(viscidus_track);
	RDX.AutoUpdateEncounterPane(viscidus_track);

end

function RDXM.AQ.ViscidusReset()

	--Reset the counters
	viscidus_totalBolts = 0;
	viscidus_rpc_totalBolts = 0;
	viscidus_totalPhysicalHits = 0;
end

	--*****************************--
	--*        Chat Events        *--
	--*****************************--


function RDXM.AQ.RaidMemberDidFrostDamage()

	if viscidus_frostlock then return; end
	if string.find(arg1, "Frost damage") then
		if string.find(arg1, "Viscidus") then
			RDXM.AQ.IncreaseFrostCounter();
		end
	end
end


function RDXM.AQ.IncreaseFrostCounter()
	
	--This function keeps track of how many frost attacks we've recorded.
	--If we've recorded more than the RPC is reporting, then we will report our
	--Findings by invoking "viscidus_frost_update" to the raid.

	viscidus_totalBolts = viscidus_totalBolts + 1;
	
	--SendChatMessage("Total frost spells detected by me = " .. viscidus_totalBolts, "RAID"); --Debug

	--If our value is higher then the latest RPC, lets Invoke the frost update
		
	if (viscidus_totalBolts > viscidus_rpc_totalBolts) then
		-- but only if we don't have a lock! (we don't want to spam)
		if (viscidus_rpcbroadcastlock == false) then
			RPC.Invoke("viscidus_frost_update", viscidus_totalBolts);
			--Lock our broadcasting for 1 second.
			viscidus_rpcbroadcastlock = true;
			VFL.schedule(1, function() viscidus_rpcbroadcastlock = false; end);
		end
	end

	--Update the frost counter alert
	RDXM.AQ.ViscidusFrostAlertUpdate()

end

function RDXM.AQ.ViscidusFrostAlertUpdate()

	--This routine updates the viscidus_alert window with frost counter information.
	if not viscidus_alert then return; end
	
	local maxBolts = RDXM.AQ.ViscidusGetMaxBolts();

	viscidus_alert:SetText("Frost counter: " .. maxBolts .. " / " .. viscidus_freezebolts);
	viscidus_alert.statusBar:SetValue(maxBolts / viscidus_freezebolts);

end

function RDXM.AQ.ViscidusEmote()
	if string.find(arg1, "frozen solid") then
		RDXM.AQ.ViscidusFrozen();
		return;
	end
end


function RDXM.AQ.ViscidusFrozen()

	--Lockout Code
	if viscidus_frostlock then return; end
	viscidus_frostlock = true;
	VFL.schedule(15, function() RDXM.AQ.ViscidusUnfrozen(); end); 

	--Print out a debug type message informing us of how many bolts were counted before he froze
	local maxBolts = RDXM.AQ.ViscidusGetMaxBolts();
	VFL.print("[Viscidus] " .. maxBolts .. " frost attacks were parsed before freezing.");
		
	--Reset all counters and show the "Hit" counter
	RDXM.AQ.ViscidusReset();
	RDXM.AQ.ViscidusPhysicalAlertUpdate()
	
	-- Timer Alarm for unfreezing
	RDX.Alert.CenterPopup("viscidus_frozenalert", "VISCIDUS FROZEN! KILL!", 15, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=.1,g=.4,b=.95});
	
	-- RPC invoke the event in case anyone missed it.
	RPC.Invoke("viscidus_frozen_update");
end


function RDXM.AQ.RaidMemberDidPhysicalDamage()

	--Something was hit by melee. We only care about this if viscidus is currently frozen (for our melee hits counter)
	--which is when frostlock = true.
	--Note that we assume the damage was done to viscidous, since no other melee damage should
	--be occurring...

	if viscidus_frostlock then
		--Viscidous is frozen...
		--Update our tally
		viscidus_totalPhysicalHits = viscidus_totalPhysicalHits + 1;

		--Paint the results
		RDXM.AQ.ViscidusPhysicalAlertUpdate(); 
	end
end


function RDXM.AQ.ViscidusPhysicalAlertUpdate()

	--Paint the alert with physical hit data

	if not viscidus_alert then return; end

	viscidus_alert:SetText("Number of \"Hits\": " .. viscidus_totalPhysicalHits);
	viscidus_alert.statusBar:SetValue(viscidus_totalPhysicalHits / viscidus_physicals);

end

function RDXM.AQ.ViscidusUnfrozen()

	--Unlock the frost spell counter
	viscidus_frostlock = false;  

	--Print out a debug type message informing of us of how many physical hits were executed
	VFL.print("[Viscidus] " .. viscidus_totalPhysicalHits .. " physical hits were parsed during the frozen phase.");

	--Show the Frost counter
	RDXM.AQ.ViscidusFrostAlertUpdate();

end


	--*****************************--
	--*     Helper Functions      *--
	--*****************************--


function RDXM.AQ.ViscidusGetMaxBolts()

	--Returns the larger of the two frost tallys (local or RPC)
	local maxBolts;
	if (viscidus_totalBolts > viscidus_rpc_totalBolts) then
		maxBolts = viscidus_totalBolts
	else
		maxBolts = viscidus_rpc_totalBolts
	end
	return maxBolts;
end

function RDXM.AQ.partyChatMsg()

	--This function is a backdoor for use in testing this mod.
	--Typing the strings below into party chat will manually trigger the routines.
	if arg1 == "FORCEBOLT" then
		if viscidus_frostlock then return; end
		RDXM.AQ.IncreaseFrostCounter();
	end
	if arg1 == "FORCEFREEZE" then
		RDXM.AQ.ViscidusFrozen();
	end

end


	--*****************************--
	--*       RPC Functions       *--
	--*****************************--

function RDXM.AQ.RPCFrostCountUpdate(sender, n)

	--Update our RPC total if it is a "new high score"
	if (n > viscidus_rpc_totalBolts) then 
		viscidus_rpc_totalBolts = n;
	end

	--VFL.print("RPC remote function called, with frostbolt value of: " .. n); --Debug

	--Paint the new result
	RDXM.AQ.ViscidusFrostAlertUpdate();

end


function RDXM.AQ.RPCFrozen()

	--Just call the ViscidusFrozen event as normal
	RDXM.AQ.ViscidusFrozen() 

end

	--*****************************--
	--* Main Encounter Definition *--
	--*****************************--

RDXM.AQ.enctbl["viscidus"] = {
	ActivateEncounter = RDXM.AQ.ViscidusActivate;
	DeactivateEncounter = RDXM.AQ.ViscidusDeactivate;
	StartEncounter = RDXM.AQ.ViscidusStart;
	StopEncounter = RDXM.AQ.ViscidusStop;
};