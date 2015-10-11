--[[
OutgoingMail v3.0b1

Part of the GuildToolS package.
Dependancy: GTS_Core

	- Keeps track of all the outgoing mail including receiver, item sent and date when 
	he message was sent.

Author: Roman Tarakanov (RTE/Arthas)
Date: May 14 '06

]]--
---------------------------------------------------------------
----------------------Standart mesages-------------------------
---------------------------------------------------------------

local GTS_OM_VER = "3.0b1";

GTS_MSG["OM_GREETING"] = "GTS_OutgoingMail v" .. GTS_OM_VER .. " is loaded.";
GTS_MSG["OM_CLEARED"]  = "OutgoingMail varibles are cleared for this character.";
GTS_MSG["OM_RESET"]    = "All OutgoingMail varibles are cleared.";
GTS_MSG["OM_REEVAL"]   = "All prices were updated.";
GTS_MSG["OM_NOLL"]     = "Error: LootLink is not installed.";

---------------------------------------------------------------
---------------Global OutgoingMail functions-------------------
---------------------------------------------------------------

--OnEvent function
function GTS_OM_OnEvent(event)	 

	return nil;
end

--OnLoad function
function GTS_OM_OnLoad()	
	if (not GTS_Data) then GTS_Data = {}; end
	if (not GTS_Data.OM) then GTS_Data.OM = {}; end
	
	if (not GTS_Data.OM.SentItems) then GTS_Data.OM.SentItems = {}; end
	if (not GTS_Data.OM.GlobalID) then GTS_Data.OM.GlobalID = {}; end
	if (not GTS_Data.OM.GlobalID[UnitName("player")]) then GTS_Data.OM.GlobalID[UnitName("player")] = 1; end
	if (not GTS_Data.OM.SentItems[UnitName("player")]) then GTS_Data.OM.SentItems[UnitName("player")] = {}; end
	
	GTS_Menu_OM_NL:Hide();
	GTS_Echo(GTS_MSG["OM_GREETING"]);
	return nil;
end

--Slash command handler
function GTS_OM_SlashCommand(msg)
	if (msg == "omclear") then
		GTS_Data.OM.ReceivedItems[UnitName("player")] = {};
		GTS_Echo(GTS_MSG["OM_CLEARED"]);
		return 1;
		
	elseif (msg == "omclearall") then
		GTS_Data.OM.ReceivedItems = {};
		GTS_Data.OM.ReceivedItems[UnitName("player")] = {};
		GTS_Echo(GTS_MSG["OM_CLEARED"]);
		return 1;
		
	elseif (msg == "omreset") then
		GTS_Data.OM.ReceivedItems = {}; 
		GTS_Data.OM.GlobalID = {};
		GTS_Data.OM.GlobalID[UnitName("player")] = 1; 
		GTS_Data.OM.ReceivedItems[UnitName("player")] = {}; 
		GTS_Echo(GTS_MSG["OM_RESET"]);
		return 1;
		
	elseif (msg == "omreeval") then
		local index, id;
		if (not IsAddOnLoaded("LootLink")) then GTS_Echo(GTS_MSG["OM_NOLL"]); return 1; end
		for index, element in GTS_Data.OM.SentItems[UnitName("player")] do
			local name = string.sub(element.name,2,string.len(element.name)-1);
			if (IsAddOnLoaded("LootLink") and ItemLinks and ItemLinks[name] and ItemLinks[name].p and (not element.price or element.price == " 0 ")) then
				GTS_Data.OM.SentItems[UnitName("player")][index].price = " "..ItemLinks[name].p.." ";
				GTS_Debug(element.name..":Price is updated.");
			end
		end
		GTS_Echo(GTS_MSG["OM_REEVAL"]);
		return 1;
	
	elseif (msg == "ominfo") then
		GTS_Echo("Stores info about all the outgoing items in SV.lua.");
		GTS_Echo("Available commands:");
		GTS_Echo("/gts omclear    clears database for this character.");
		GTS_Echo("/gts omreeval   updates all the vendor prices for items in SV.lua (LootLink required).");
		GTS_Echo("/gts ominfo     shows this screen.");
		return 1;
		
	else
		return nil;
	end

end

---------------------------------------------------------------
-------------------OutgoingMail functions----------------------
---------------------------------------------------------------

--Replaces standard SendMail function with local one that also logs all outgoing items.
GTS_OM_oldSendMail = SendMail;

function GTS_OM_SendMail(to, subj, body)
	GTS_Debug("SendMail is called.");
	local itemName, itemQuality, itemDesc, count, texture, itemType, itemSubType, itemId, price = GTS_GetMailItemInfo(-1);
	local receiver = to;
	
	local GlobalID = GTS_Data.OM.GlobalID[UnitName("player")].."";
	
	GTS_Data.OM.GlobalID[UnitName("player")] = GTS_Data.OM.GlobalID[UnitName("player")] + 1;
	
	if (not itemName) then return GTS_OM_oldSendMail(to, subj, body); end
	
	local element = {name = " "..itemName.." ", description = " "..itemDesc.." ", 
					number = " "..count.." ", pic = " "..texture.." ", quality = " "..itemQuality.." ",
					type = " "..itemType.." ", subtype = " "..itemSubType.." ", id = " "..itemId.." ",
					globalid = " "..GlobalID.." ", to = " "..receiver.." ", date = " "..date("%y-%m-%d").." ",
					price = " "..price.." "};
	table.insert(GTS_Data.OM.SentItems[UnitName("player")], element);
	table.sort(GTS_Data.OM.SentItems[UnitName("player")], function(i,j) return i.globalid>j.globalid; end);
	
	return GTS_OM_oldSendMail(to, subj, body);
	
end

SendMail = GTS_OM_SendMail;