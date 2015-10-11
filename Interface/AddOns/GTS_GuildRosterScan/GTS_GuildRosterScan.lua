--[[
GuildRosterScaner v3.0b1

Part of the GuildToolS package.
Dependancy: GTS_Core

	- Scans the entire guild roster including name, level, class, rank, professions*,
	main-alt relations*. 
	* - only if the guild note was properly entered (see manual).

Author: Roman Tarakanov (RTE/Arthas)
Date: May 14 '06

]]--
---------------------------------------------------------------
----------------------Standart mesages-------------------------
---------------------------------------------------------------

GTS_GRS_VER = "3.0b1";

GTS_MSG["GRS_GREETING"]   = "GTS_GuildRosterScan v" .. GTS_GRS_VER .. " is loaded.";
GTS_MSG["GRS_DONE"]       = "GuildRosterScan | Success : scan was successful, now you can log out and run GuildRosterParser.exe to get html file.";
GTS_MSG["GRS_NOGUILD"]    = "GuildRosterScan | Error : this character does not belong to any guild.";
GTS_MSG["GRS_CLEARED"]     = "GuildRosterScan varibles are cleared for this character.";

---------------------------------------------------------------
--------------Global GuildRosterScan variables-----------------
---------------------------------------------------------------

local prof={};
prof["A"]="Alchemy";
prof["B"]="Blacksmith";
prof["BM"]="Macesmith";
prof["BS"]="Swordsmith";
prof["BA"]="Axesmith";
prof["Q"]="Armorsmith";
prof["C"]="Enchanting";
prof["E"]="Engineering";
prof["EN"]="Gnome Engineering";
prof["EO"]="Goblin Engineering";
prof["H"]="Herbalism";
prof["L"]="Leatherworking";
prof["LE"]="Elemental Leatherworking";
prof["LD"]="Dragonscale Leatherworking";
prof["LT"]="Tribal Leatherworking";
prof["M"]="Mining";
prof["S"]="Skinning";
prof["T"]="Tailoring";
prof["N"]="None";

---------------------------------------------------------------
-------------Global GuildRosterScan functions------------------
---------------------------------------------------------------

--OnLoad function
function GTS_GRS_OnLoad()
	
	if (not GTS_Data) then GTS_Data = {}; end
	if (not GTS_Data.GRS) then GTS_Data.GRS = {}; end
	
	if (not GTS_Data.GRS.GuildRoster) then GTS_Data.GRS.GuildRoster = {}; end
	if (GetGuildInfo("player") and not GTS_Data.GRS.GuildRoster[GetGuildInfo("player")]) then GTS_Data.GRS.GuildRoster[GetGuildInfo("player")] = {}; end
	
	--GTS_Menu_GRS_NL:Hide();
	GTS_Echo(GTS_MSG["GRS_GREETING"]);
end

--OnEvent function
function GTS_GRS_OnEvent(event)	 
	--GTS_Debug("OnEvent is called");
	
	if (event == "BANKFRAME_OPENED") then
		GTS_Debug("Bank was opened.");
		return 1;
		
	else
		return nil;
	end
end

--Slash command handler
function GTS_GRS_SlashCommand(msg)
	if (msg == "grscan") then
		if (GetGuildInfo("player")) then
			GTS_Debug("GTS_GRS_DoScan is called.");
			GTS_GRS_DoScan();
			GTS_Echo(GTS_MSG["GRS_DONE"]);
		else
			GTS_Echo(GTS_MSG["GRS_NOGUILD"]);
		end
		return 1;
		
	elseif (msg == "grsclear") then
		GTS_Data.GRS.GuildRoster = {};
		GTS_Echo(GTS_MSG["GRS_CLEARED"]);
		return 1;
		
	elseif (msg == "grsclearall") then
		GTS_Data.GRS.GuildRoster = {};
		return 1;
		
	elseif (msg == "grsinfo") then
		GTS_Echo("Stores info about all guildmembers in SV.lua.");
		GTS_Echo("Available commands:");
		GTS_Echo("/gts grscan     performs a guild roster scan (make sure you load guildroster beforehand).");
		GTS_Echo("/gts grsclear   clears database for this character.");
		GTS_Echo("/gts grsinfo    shows this screen.");
		return 1;
		
	else
		return nil;
	end

end

---------------------------------------------------------------
-----------------GuildRosterScan functions---------------------
---------------------------------------------------------------

--This function actually scans all the guild members
function GTS_GRS_DoScan()
	GTS_Data.GRS.GuildRoster[GetGuildInfo("player")] = {};
	for i=1,GetNumGuildMembers(true),1 do
		--Get available guild member information
		local name, rank, rankIndex, level, class, _, note = GetGuildRosterInfo(i);
		--Get guild note and see if it matches the template
		local main, prof1, prof2, prof1lvl, prof2lvl, sorter = 1, "n/a", "n/a", 0, 0, name;
		--If it does - parse it
		if (strfind(note, "GTS%-")) then
			GTS_Debug("note="..note);
			local _,_, ma,m,p1,p1lvl,p2,p2lvl = strfind(note, "GTS%-(%a-):(%a-);(%a-):(%d-);(%a-):(%d-);");
			GTS_Debug("name="..name);
			GTS_Debug("ma="..ma);
			--GTS_Debug("m="..m);
			--local m = "Rte";
			GTS_Debug("p1="..p1);
			GTS_Debug("pp1="..p1lvl);
			GTS_Debug("p2="..p2);
			GTS_Debug("pp2="..p2lvl);
			if (ma == "Main") then  main=1; else main = m; end
			if (p1 ~= "N") then prof1=prof[p1]; else prof1 = "None"; end
			if (p2 ~= "N") then prof2=prof[p2]; else prof2 = "None"; end
			prof1lvl = p1lvl;
			prof2lvl = p2lvl;
			if (ma == "A") then sorter = m..sorter; end
		end
		
		local element = {	name = " "..name.." ",
							main = " "..main.." ",
							rank = " "..rank.." ",
							rankNum = " "..rankIndex.." ",
							level = " "..level.." ",
							class = " "..class.." ",
							prof1 = " "..prof1.." ",
							prof1lvl = " "..prof1lvl.." ",
							prof2 = " "..prof2.." ",
							prof2lvl = " "..prof2lvl.." ",
							sorter = sorter};
		
		table.insert(GTS_Data.GRS.GuildRoster[GetGuildInfo("player")], element)
	end
	table.sort(GTS_Data.GRS.GuildRoster[GetGuildInfo("player")], function(i,j) return (i.sorter<j.sorter) end);
	GTS_Echo(GetNumGuildMembers(true).." players scanned.");
end
