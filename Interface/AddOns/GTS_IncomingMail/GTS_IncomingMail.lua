--[[
IncomingMail v3.0b1

Part of the GuildToolS package.
Dependancy: GTS_Core

	- Keeps track of all the incoming mail including sender, item sent and date when 
	the message was received.
	
Author: Roman Tarakanov (RTE/Arthas)
Date: May 14 '06

]]--
---------------------------------------------------------------
----------------------Standart mesages-------------------------
---------------------------------------------------------------

local GTS_IM_VER = "3.0b1";

GTS_MSG["IM_GREETING"] = "GTS_IncomingMail v" .. GTS_IM_VER .. " is loaded.";
GTS_MSG["IM_CLEARED"]  = "IncomingMail varibles are cleared for this character.";
GTS_MSG["IM_RESET"]    = "All IncomingMail varibles are cleared.";
GTS_MSG["IM_REEVAL"]   = "All prices were updated.";
GTS_MSG["IM_NOLL"]     = "Error: LootLink is not installed.";

local GTS_IM_NeedScan = 0;
---------------------------------------------------------------
----------------Global IncomingMail functions------------------
---------------------------------------------------------------

--OnEvent function
function GTS_IM_OnEvent(event)	 
	if (event == "MAIL_SHOW") then
		GTS_IM_NeedScan = 1;
		
	elseif (event == "MAIL_INBOX_UPDATE") then
		if (GTS_IM_NeedScan == 1) then
			GTS_Debug("Loading tooltips for "..GetInboxNumItems().." items.");
			local i;
			for i=1,GetInboxNumItems() do
				GTS_ItemTooltip:ClearLines();
				GTS_ItemTooltip:SetInboxItem(i);
			end
			GTS_IM_NeedScan = 0;
		end
		
	end
	return nil;
end

--OnLoad function
function GTS_IM_OnLoad()	
	if (not GTS_Data) then GTS_Data = {}; end
	if (not GTS_Data.IM) then GTS_Data.IM = {}; end
	
	if (not GTS_Data.IM.ReceivedItems) then GTS_Data.IM.ReceivedItems = {}; end
	if (not GTS_Data.IM.GlobalID) then GTS_Data.IM.GlobalID = {}; end
	if (not GTS_Data.IM.GlobalID[UnitName("player")]) then GTS_Data.IM.GlobalID[UnitName("player")] = 1; end
	if (not GTS_Data.IM.ReceivedItems[UnitName("player")]) then GTS_Data.IM.ReceivedItems[UnitName("player")] = {}; end
	
	GTS_Echo(GTS_MSG["IM_GREETING"]);
	
	GTS_Menu_IM_NL:Hide();
	return nil;
end

--Slash command handler
function GTS_IM_SlashCommand(msg)
	if (msg == "imclear") then
		GTS_Data.IM.ReceivedItems[UnitName("player")] = {};
		GTS_Echo(GTS_MSG["IM_CLEARED"]);
		return 1;
		
	elseif (msg == "imclearall") then
		GTS_Data.IM.ReceivedItems = {};
		GTS_Data.IM.ReceivedItems[UnitName("player")] = {};
		GTS_Echo(GTS_MSG["IM_CLEARED"]);
		return 1;
		
	elseif (msg == "imreset") then
		GTS_Data.IM.ReceivedItems = {}; 
		GTS_Data.IM.GlobalID = {};
		GTS_Data.IM.GlobalID[UnitName("player")] = 1; 
		GTS_Data.IM.ReceivedItems[UnitName("player")] = {}; 
		GTS_Echo(GTS_MSG["IM_RESET"]);
		return 1;
		
	elseif (msg == "imreeval") then
		local index, id;
		if (not IsAddOnLoaded("LootLink")) then GTS_Echo(GTS_MSG["IM_NOLL"]); return 1; end
		for index, element in GTS_Data.IM.ReceivedItems[UnitName("player")] do
			local name = string.sub(element.name,2,string.len(element.name)-1);
			if (IsAddOnLoaded("LootLink") and ItemLinks and ItemLinks[name] and ItemLinks[name].p and (not element.price or element.price == " 0 ")) then
				GTS_Data.IM.ReceivedItems[UnitName("player")][index].price = " "..ItemLinks[name].p.." ";
				GTS_Debug(element.name..":Price is updated.");
			end
		end
		GTS_Echo(GTS_MSG["IM_REEVAL"]);
		return 1;
		
	elseif (msg == "iminfo") then
		GTS_Echo("Stores info about all the incoming items in SV.lua.");
		GTS_Echo("Available commands:");
		GTS_Echo("/gts imclear    clears database for this character.");
		GTS_Echo("/gts imreeval   updates all the vendor prices for items in SV.lua (LootLink required).");
		GTS_Echo("/gts iminfo     shows this screen.");
		return 1;
	
	else
		return nil;
	end

end

---------------------------------------------------------------
-------------------IncomingMail functions----------------------
---------------------------------------------------------------

--Replaces standard TakeInboxItem function with local one that also logs all incoming items.
GTS_IM_oldTakeInboxItem = TakeInboxItem;

function GTS_IM_TakeInboxItem(id)
	GTS_Debug("TakeInboxItem is called.");
	local itemName, itemQuality, itemDesc, count, texture, itemType, itemSubType, itemId, price = GTS_GetMailItemInfo(id);
	local _, _, sender = GetInboxHeaderInfo(id);
	
	local GlobalID = GTS_Data.IM.GlobalID[UnitName("player")].."";
	
	GTS_Data.IM.GlobalID[UnitName("player")] = GTS_Data.IM.GlobalID[UnitName("player")] + 1;
	
	local element = {name = " "..itemName.." ", description = " "..itemDesc.." ", 
					number = " "..count.." ", pic = " "..texture.." ", quality = " "..itemQuality.." ",
					type = " "..itemType.." ", subtype = " "..itemSubType.." ", id = " "..itemId.." ",
					globalid = " "..GlobalID.." ", from = " "..sender.." ", date = " "..date("%y-%m-%d").." ",
					price = " "..price.." "};
	table.insert(GTS_Data.IM.ReceivedItems[UnitName("player")], element);
	table.sort(GTS_Data.IM.ReceivedItems[UnitName("player")], function(i,j) return i.globalid>j.globalid; end);
	
	return GTS_IM_oldTakeInboxItem(id);
	
end

TakeInboxItem = GTS_IM_TakeInboxItem;