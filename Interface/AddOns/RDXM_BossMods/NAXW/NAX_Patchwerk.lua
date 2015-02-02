------------------------------------------------------
-- Patchwerk
------------------------------------------------------

-- Hot-Tracking variables 
rdxpatchwerk_track = nil;
rdxpatchwerk_sigupdate = nil;
rdxpatchwerk_hatefulstrikes = {};
rdxpatchwerk_oldhatefulstrikes = {};
rdxpatchwerk_selfstrikes = {};
rdxpatchwerk_starttime = nil;


-- ****************************
-- Activate / Deactivate / Tracking / Start / Stop
-- ****************************

function RDXM.NAXW.PatchwerkActivate()
	-- Events
	VFLEvent:NamedBind("patchwerk_spell", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.NAXW.PatchwerkSpellEVENT(arg1); end);
	VFLEvent:NamedBind("patchwerk_spell", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE"), function() RDXM.NAXW.PatchwerkSpellEVENT(arg1); end);
	VFLEvent:NamedBind("patchwerk_spell", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"), function() RDXM.NAXW.PatchwerkSpellEVENT(arg1); end);
	-- RPC Binds

	-- Tracking
	rdxpatchwerk_track = HOT.TrackTarget("Patchwerk");
	rdxpatchwerk_sigupdate = rdxpatchwerk_track.SigUpdate:Connect(RDXM.NAXW, "PatchwerkUpdate");
end

function RDXM.NAXW.PatchwerkDeactivate()
	-- Unbind Events
	VFLEvent:NamedUnbind("patchwerk");
	-- Unbind RPCs

	-- Stop Tracking
	if rdxpatchwerk_track then
		rdxpatchwerk_track.SigUpdate:DisconnectByHandle(rdxpatchwerk_sigupdate);
		rdxpatchwerk_sigupdate = nil; rdxpatchwerk_track = nil;
	end
end

function RDXM.NAXW.PatchwerkUpdate()
	RDX.AutoStartStopEncounter(rdxpatchwerk_track);
	RDX.AutoUpdateEncounterPane(rdxpatchwerk_track);
end

function RDXM.NAXW.PatchwerkStart()
	-- Save old log and clear the new one
	table.insert(rdxpatchwerk_oldhatefulstrikes, VFL.copy(rdxpatchwerk_hatefulstrikes))
	rdxpatchwerk_hatefulstrikes = {}
	rdxpatchwerk_starttime = GetTime()

	RDX.Alert.Dropdown("patchwerk_enrage", "Enrage!", 7 * 60, 10, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=1, g=.2, b=.2});
end

function RDXM.NAXW.PatchwerkStop()
	RDX.QuashAlertsByPattern("^patchwerk")
end


-- ****************************
-- Blizzard Chat Message Events
-- ****************************


function RDXM.NAXW.PatchwerkSpellEVENT(msg)
	if not string.find(msg, "Hateful Strike") then return; end
	if not rdxpatchwerk_starttime then return; end
	local t = math.floor((GetTime()-rdxpatchwerk_starttime)*100)/100
	table.insert(rdxpatchwerk_hatefulstrikes, t.."s - "..msg)
	if string.find(msg, "Hateful Strike hits you") then
		local _,a = UnitArmor("player")
		local armorReduction = a/((85 * 60) + 400);
		armorReduction = 100 * (armorReduction/(armorReduction + 1));
		armorReduction = math.floor(armorReduction*1000)/100; -- to avoid .79999999999
		table.insert(rdxpatchwerk_selfstrikes, "HS# "..table.getn(rdxpatchwerk_hatefulstrikes)..", "..t.."s - "..msg.." ("..armorReduction..")")
	end
end

function RDXM.NAXW.PatchwerkStrikeParse(pattern, channel, attempt)
	local tbl = rdxpatchwerk_oldhatefulstrikes[attempt] or rdxpatchwerk_hatefulstrikes
	if not channel then channel = "self"; end
	
	if string.lower(pattern) == "order" then
		local hits = {}
		local str = "";
		for k,v in tbl do
			local x, y, p = string.find(v, "Hateful Strike hits (%w+) for")
			if p then
				if hits[table.getn(hits)] and hits[table.getn(hits)]["name"] == p then
					hits[table.getn(hits)]["num"] = hits[table.getn(hits)]["num"]+1
				else
					hits[table.getn(hits)+1] = { 
						["name"] = p,
						["num"] = 1,
					}
				end
			end
		end
		for i=1,table.getn(hits) do
			str = str..hits[i].name.."("..hits[i].num..") "
			if strlen(str) > 220 then
				RDXM.NAXW.PatchwerkStrikeParsePrint(str, channel)
				str = ""
			end
		end
		if strlen(str) > 1 then
			RDXM.NAXW.PatchwerkStrikeParsePrint(str, channel)
		end
	else
		for k,v in tbl do
			if string.find(v, pattern) then
				RDXM.NAXW.PatchwerkStrikeParsePrint(k..": "..v, channel)
			end
		end
	end
end

function RDXM.NAXW.PatchwerkStrikeParsePrint(msg, channel)
	if not channel then channel = "self"; end
	if string.lower(channel) == "self" then
		VFL.print("RDX5 HS Parse: "..msg)
	else
		SendChatMessage("RDX5 HS Parse: "..msg, string.upper(channel));
	end
end

SLASH_HSPARSE1 = "/hsparse";
SlashCmdList["HSPARSE"] = function(str) RDXM.NAXW.PatchwerkSelfStrikeParse(str); end

function RDXM.NAXW.PatchwerkSelfStrikeParse(numstrikes)
	if not numstrikes then numstrikes = 10; end
	if not tonumber(numstrikes) then VFL.print("/hsparse <# of hatefulstrikes to show>"); return; else numstrikes = tonumber(numstrikes); end
	local tbl = rdxpatchwerk_selfstrikes;
	local n = table.getn(tbl);
	local l = n-numstrikes+1;
	if l < 1 then
		l = 1
	end
	for i=l,n do
		SendChatMessage(tbl[i], "SAY")
	end		
end


-- ****************************
-- Register the encounter
-- ****************************

RDXM.NAXW.enctbl["patchwerk"] = {
	ActivateEncounter = RDXM.NAXW.PatchwerkActivate;
	DeactivateEncounter = RDXM.NAXW.PatchwerkDeactivate;
	StartEncounter = RDXM.NAXW.PatchwerkStart;
	StopEncounter = RDXM.NAXW.PatchwerkStop;
};