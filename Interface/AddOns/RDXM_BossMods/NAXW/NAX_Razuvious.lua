-------------------------------------
-- Instructor Razuvious
-------------------------------------
local raz_charm_duration = 60;
understudies = {};
local raz_track = nil;
local raz_sigupdate = nil;
local raz_heartbeat = nil;
local raz_shoutLOCKOUTb = nil;

--[[ Table structure:
understudies = {
	1 = {
		["icon"] = 1-9,
		["hp"] = 0-100,
		["timecharmed"] = gettime(),
		["timelastcharmbroke"] = gettime();
		["currentlycharmed"] = 1,0,
		["lastcharmedby"]
		["currentlyshieldwalled"] = 1,0,
		["lastupdate"] = gettime();
	},
	2 = {
		etc
	},
}
]]

function RDXM.NAXW.RazDeactivate()
	-- Cleanup tracking
	if raz_track then
		raz_track.SigUpdate:DisconnectByHandle(raz_sigupdate);
		raz_sigupdate = nil; raz_track = nil;
	end
	-- Hide the frame
	RazuviousFrame:Hide()
	-- Stop the heartbeat
	raz_heartbeat = nil;
	-- Cleanup RPCs
	RPC.UnbindPattern("^raz");
	-- Cleanup alerts
	RDX.QuashAlertsByPattern("^raz");
end

function RDXM.NAXW.RazActivate()
	-- Tracking
	if not raz_track then
		raz_track = HOT.TrackTarget("Instructor Razuvious");
		raz_sigupdate = raz_track.SigUpdate:Connect(RDXM.NAXW, "RazUpdate");
	end
	-- Event binds
	VFLEvent:NamedBind("raz_shout", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.NAXW.RazShoutEVENT(arg1); end);
	-- RPC Binds
	RPC.Bind("raz_shout", RDXM.NAXW.RazShoutAlert);
	-- Show the frame
	RazuviousFrame:Show()
	-- Start the heartbeat
	raz_heartbeat = true;
	RDXM.NAXW.RazHeatbeat()
	-- Clear the data table
	understudies = {}
end

function RDXM.NAXW.RazShoutEVENT(msg)
	if string.find(msg, "Instructor Razuvious's Disrupting Shout") then
		if raz_shoutLOCKOUTb then return; end
		RPC.Invoke("raz_shout")
		RDXM.NAXW.RazShoutAlert()
	end
end


function RDXM.NAXW.RazShoutAlert()
	if raz_shoutLOCKOUTb then return; end
	RDX.Alert.Dropdown("raz_shout", "Mana Drain + Dmg Shout", 25, 5, "Sound\\Doodad\\BellTollAlliance.wav", {r=0,g=0,b=1}, nil, nil);
	raz_shoutLOCKOUTb = true;
	VFL.scheduleExclusive("raz_shoutlockout", 15, function() raz_shoutLOCKOUTb = nil; end);
end

function RDXM.NAXW.RazStart()
	-- Prewarning
	RDXM.NAXW.RazShoutAlert()
end

function RDXM.NAXW.RazStop()
	RDX.QuashAlertsByPattern("^raz");
	-- clear lockout
	raz_shoutLOCKOUTb = nil;
end

function RDXM.NAXW.RazHeatbeat()
	if not raz_heartbeat then return; end
	RDXM.NAXW.RazUpdateState();
	VFL.scheduleExclusive("raz_heartbeat", .5, function() RDXM.NAXW.RazHeatbeat(); end);
end

function RDXM.NAXW.RazUpdate()
	RDX.AutoStartStopEncounter(raz_track);
	RDX.AutoUpdateEncounterPane(raz_track);
end

function RDXM.NAXW.RazUpdateState()
	understudies.temp = {}
	for i=1,GetNumRaidMembers() do
		if UnitName("raid"..i.."target") == "Deathknight Understudy" then
			RDXM.NAXW.RazUpdateUnderstudyInTempTable("raid"..i.."target")
		elseif UnitName("raid"..i.."targettarget") == "Deathknight Understudy" then
			RDXM.NAXW.RazUpdateUnderstudyInTempTable("raid"..i.."targettarget")
		end
	end
	
	-- We found the adds and read their icons + recorded their unit reference, now update their attributes
	RDXM.NAXW.RazTemptoData(understudies.temp)
end

-- find the four adds and find their icon
function RDXM.NAXW.RazUpdateUnderstudyInTempTable(unit)
	local icon = GetRaidTargetIndex(unit)
	
	-- loop through existing table and look for the add, report if it's there
	local found = nil;
	for i=1,table.getn(understudies.temp) do
		if understudies.temp[i].icon == icon then
			-- yup it's here, no need to add it
			found = true;
		end
	end
	
	-- if it wasn't found, add it
	if not found then 
		local newi = table.getn(understudies.temp)+1;
		understudies.temp[newi] = {}
		understudies.temp[newi].icon = icon;
		understudies.temp[newi].unit = unit;
	end
end

function RDXM.NAXW.RazTemptoData(tt)
	-- Is data table created yet?
	if table.getn(understudies) ~= 0 then
		local mt = {}
		local changedentry = nil;
		-- Match up temp table with data table, check for icon discrepencies
		-- More specifically, check to see if the temp table has something new
		for i=1,table.getn(tt) do
			local found = nil;
			for x=1,table.getn(understudies) do
				if tt[i].icon == understudies[x].icon then
					-- understudies.temp[i].icon was found in data table
					found = tt[i].icon;
					RDXM.NAXW.RazUpdateAttributes(x, tt[i].unit);
				end
			end
			if found then 
				table.insert(mt, found)
			elseif table.getn(understudies) == 4 then
				changedentry = true;
			end
		end
		if changedentry then
				-- Clear data, create new data
				RDXM.NAXW.RazNewData(tt)
		end				
	else
		RDXM.NAXW.RazNewData(tt)
	end
	RDXM.NAXW.RazRepaintWindow()
end

-- Creates 4 table entries in the main data table and fills in the attributes it can (clearing any and all old data)
function RDXM.NAXW.RazNewData(tt)
	local temp = VFL.copy(tt);
	understudies = {}
	for i=1,4 do
		understudies[i] = {}
	end
	for i=1,table.getn(temp) do
		local unit = temp[i].unit;
		RDXM.NAXW.RazUpdateAttributes(i, unit)
	end
end

function RDXM.NAXW.RazUpdateAttributes(i, unit)
	-- Updates attributes for a specific add
	understudies[i].icon = GetRaidTargetIndex(unit);
	if UnitHealthMax(unit) == 100 then
		understudies[i].hp = UnitHealth(unit)/100;
	elseif UnitHealthMax(unit) > 100 then
		understudies[i].hp = UnitHealth(unit)/UnitHealthMax(unit);
	end
	local charmedby = RDXM.NAXW.RazIsUnitCharmed(unit)
	if charmedby then
		understudies[i].currentlycharmed = true;
		understudies[i].lastcharmedby = charmedby;
		if not understudies[i].timecharmed then
			understudies[i].timecharmed = GetTime();
		end
	else
		if understudies[i].currentlycharmed then
			understudies[i].currentlycharmed = nil;
			understudies[i].timelastcharmbroke = GetTime();
		end
		understudies[i].timecharmed = nil;
	end
	understudies[i].currentlyshieldwalled = RDXM.NAXW.RazIsUnitShieldWalled(unit); 
	understudies[i].lastupdate = GetTime();
end

function RDXM.NAXW.RazRepaintWindow()
	local boxnum = 1;
	-- Hide them, then show as they get updated
	for i=1,4 do
		getglobal("RazuviousFrameBox"..i):Hide()
	end
	-- This fancy looping bit is just to fill the boxes in order, starting with the lowest icon index
	for i=1,8 do
		for x=1,table.getn(understudies) do
			if understudies[x].icon == i then
				local us = understudies[x];
				if GetTime()-us.lastupdate < 5 then
					getglobal("RazuviousFrameBox"..boxnum):Show()
					getglobal("RazuviousFrameBox"..boxnum.."Icon"):SetTexture("Interface\\AddOns\\RDX\\Skin\\raidicon"..us.icon)
					
					if us.currentlyshieldwalled then
						getglobal("RazuviousFrameBox"..boxnum.."Buff"):Show()
					else
						getglobal("RazuviousFrameBox"..boxnum.."Buff"):Hide()
					end
				
					if us.lastcharmedby then
						getglobal("RazuviousFrameBox"..boxnum.."Txt"):SetText(us.lastcharmedby)
					else
						getglobal("RazuviousFrameBox"..boxnum.."Txt"):SetText("No one")
					end
				
					getglobal("RazuviousFrameBox"..boxnum.."HPBar"):SetValue(us.hp)
								
					if not us.currentlycharmed then
						if not us.timelastcharmbroke then
							-- no idea, show that we are unsure
							getglobal("RazuviousFrameBox"..boxnum.."Bkg"):SetTexture(1, 1, 1, .2) --grey
							getglobal("RazuviousFrameBox"..boxnum.."CharmBar"):Show()
							getglobal("RazuviousFrameBox"..boxnum.."CharmBar"):SetValue(0)
							getglobal("RazuviousFrameBox"..boxnum.."CharmBarTxt"):SetText("Unsure")
						elseif ((GetTime()-us.timelastcharmbroke) > 60) then
							-- looks good, give the go ahead!
							getglobal("RazuviousFrameBox"..boxnum.."Bkg"):SetTexture(0, 1, 0, .2) --green
							getglobal("RazuviousFrameBox"..boxnum.."CharmBar"):Hide()
						else
							-- within 60 seconds of broken charm, show that they are immune
							getglobal("RazuviousFrameBox"..boxnum.."Bkg"):SetTexture(1, 0, 0, .2) --red
							getglobal("RazuviousFrameBox"..boxnum.."CharmBar"):Show()
							getglobal("RazuviousFrameBox"..boxnum.."CharmBar"):SetValue(1-(GetTime()-us.timelastcharmbroke)/60)
							getglobal("RazuviousFrameBox"..boxnum.."CharmBarTxt"):SetText("Charm Immune")
						end
					else
						getglobal("RazuviousFrameBox"..boxnum.."Bkg"):SetTexture(1, 1, 0, .2) --yellow
						getglobal("RazuviousFrameBox"..boxnum.."CharmBar"):Show()
						getglobal("RazuviousFrameBox"..boxnum.."CharmBar"):SetValue(1-(GetTime()-us.timecharmed)/raz_charm_duration)
						getglobal("RazuviousFrameBox"..boxnum.."CharmBarTxt"):SetText("Charmed")
					end
				end
				boxnum = boxnum + 1;
			end
		end
	end
end

-- Utility functions

function RDXM.NAXW.RazIsUnitCharmed(unit)
	local charmedby = nil;
	if UnitIsCharmed(unit) then
		return " ";
	end
end

function RDXM.NAXW.RazIsUnitShieldWalled(unit)
	-- Determine if unit has shield wall buff
	for i=1,8 do
		if UnitBuff(unit, i) then
		if string.find(UnitBuff(unit, i), "ShieldWall") then
			return true;
		end
		end
	end
	return false;
end

RDXM.NAXW.enctbl["razuvious"] = {
	DeactivateEncounter = RDXM.NAXW.RazDeactivate;
	ActivateEncounter = RDXM.NAXW.RazActivate;
	StartEncounter = RDXM.NAXW.RazStart;
	StopEncounter = RDXM.NAXW.RazStop;
};
