--[[
GTS_Core v3.0b1

Addon that allows you to store in game info into SV.lua for further parsing.
Contains: 
BankScan     		- Scans all posessions of the character, including bank, bags and bags in bank.
IncomingMail 		- Keeps track of all the incoming mail including sender, item sent and date when 
					the message was received.
OutgoingMail 		- Keeps track of all the outgoing mail including receiver, item sent and date when 
					he message was sent.
GuildRosterScaner 	- Scans the entire guild roster including name, level, class, rank, professions*,
					main-alt relations*. 
					* - only if the guild note was properly entered (see manual).

Author: Roman Tarakanov (RTE/Arthas)
Date: May 14 '06

]]--
---------------------------------------------------------------
----------------------Standard mesages-------------------------
---------------------------------------------------------------

local GTS_Core_VER    = "3.0b1";

GTS_MSG = {};

GTS_MSG["GREETING"]  = "GuildToolS v" .. GTS_Core_VER .. " is loaded.";
GTS_MSG["ADDONOFF"]  = "AddOn is turned off, use /gts on to turn it on for this character";
GTS_MSG["CLEARED"]   = "Variables have been cleared.";
GTS_MSG["INVALID"]   = "Not a valid command. See /gts info for list of commands.";
GTS_MSG["DEBUG_ON"]  = "Debug mode is now ENABLED for this character";
GTS_MSG["DEBUG_OFF"] = "Debug mode is now DISABLED for this character";

---------------------------------------------------------------
----------------Global GuildToolS variables--------------------
---------------------------------------------------------------

--GTS_Position in the array GTS_Options of the current character 
-- -1 - not in array
GTS_Position=-1;
--Debug mode indicator 
-- 1 - debug mode on
-- 0 - debug mode off (default)
GTS_DebugMode = 0;

---------------------------------------------------------------
----------------Global GuildToolS functions--------------------
---------------------------------------------------------------

--OnEvent function
function GTS_OnEvent()	 
	--GTS_Debug("OnEvent is called");

	if (event == "VARIABLES_LOADED") then
		GTS_Debug("Variables are loaded.");
		SlashCmdList["GTS_CORE"] = GTS_SlashCommand;
		SLASH_GTS_CORE1 = "/guildtools";
		SLASH_GTS_CORE2 = "/gts";
		
		GTS_OnLoad();
		
	else
		-- Call other addon's OnEvent functions
		if (IsAddOnLoaded("GTS_BankScan")) then GTS_BS_OnEvent(event); end
		if (IsAddOnLoaded("GTS_IncomingMail")) then GTS_IM_OnEvent(event); end
		if (IsAddOnLoaded("GTS_OutgoingMail")) then GTS_OM_OnEvent(event); end
		if (IsAddOnLoaded("GTS_GuildRosterScan")) then GTS_GRS_OnEvent(event); end
		
	end
end

--OnLoad function
function GTS_OnLoad()
	--Saved variables of the AddOn
	--Initialize if blank		
	if (not GTS_Options) then
		GTS_Options = {};
	end
	
	-- varibles in GTS_Options if exist
	local i;
	GTS_Debug("GTS_Options size: "..table.getn(GTS_Options));
	if (GTS_Options) then
		for  i = 1, table.getn(GTS_Options), 1 do
			if (string.find(GTS_Options[i].name, UnitName("player")) and string.find(GTS_Options[i].server, GetCVar("realmName"))) then
				if (not GTS_Options[i].addonOn) then GTS_Options[i].addonOn=false; end
				if (not GTS_Options[i].BSOn) then GTS_Options[i].BSOn=false; end
				if (not GTS_Options[i].mailOn) then GTS_Options[i].mailOn=false; end
				GTS_Position = i;
			end
		end
	end
	
	--If new character is observed - initialize the data.
	--On new character AddOn and mail grabber part (future functionality) are off by default
	if (GTS_Position == -1) then
		if (GTS_Options) then
			i = table.getn(GTS_Options)+1;
		else
			i = 1;
		end		
		GTS_Options[i] = { name=UnitName("player"), server=GetCVar("realmName"), 
			mailOn=false, addonOn=false, BSOn=false, BSSort=1};
		GTS_Position = i;
	end
	
	GTS_Debug("GTS_Position: "..GTS_Position);
	
	if (not GTS_Data) then GTS_Data = {}; end
	
	--Manu set up for future GUI
	local tabwindow = getglobal("GTS_Menu");
	PanelTemplates_SetNumTabs(tabwindow, 2);
	tabwindow.selectedTab = 1;
	PanelTemplates_UpdateTabs(tabwindow);
	
	GTS_Echo(GTS_MSG["GREETING"]);
	
end

--Tab handler for future GUI
function GTS_TabHandler(button)
	local tabwindow = getglobal("GTS_Menu");
	local currenttab = getglobal("GTS_Menu_Tab"..tabwindow.selectedTab);
	local nexttab = getglobal("GTS_Menu_Tab"..button);
	
	currenttab:Hide();
	nexttab:Show();
end

--Slash command handler
function GTS_SlashCommand(msg)
	msg = string.lower(msg);
	GTS_Debug("/command: "..msg);
	
	if (msg == nil or msg == "") then 
		GTS_Menu_Header:SetText("GuildToolS v"..GTS_Core_VER);
		GTS_Menu_Header2:SetText("Profile: "..UnitName("player"));
		GTS_Menu:Show();
		return;
	
	elseif (msg == "clear") then 
		GTS_Data = {}; 
		GTS_Echo(GTS_MSG["CLEARED"]);
		return; 
	
	elseif (msg == "debug") then
		
		if (GTS_DebugMode == 1) then
			GTS_Echo(GTS_MSG["DEBUG_OFF"]);
			GTS_DebugMode = 0;
		else
			GTS_Echo(GTS_MSG["DEBUG_ON"]);
			GTS_DebugMode = 1;
		end
	
	elseif (msg == "info") then
		GTS_Echo("Tool for guild use that help export various info in SV.lua.");
		GTS_Echo("List of components:");
		GTS_Echo("BankScan - scanns possesions of char. See /gts bsinfo for more info.");
		GTS_Echo("IncomingMail - tracks incoming mail. See /gts iminfo for more info.");
		GTS_Echo("OutgoingMail - tracks outgoing mail. See /gts ominfo for more info.");
		GTS_Echo("GuildRosterScaner - scans guild roster. See /gts grsinfo for more info.");
		GTS_Echo("-------------------------------------------------------------------");
		GTS_Echo("Available commands:");
		GTS_Echo("/gts clear    clears all saved variables for this addon. If used all data will be lost.");
		GTS_Echo("/gts debug    tuggles Debug Mode on/off.");
		GTS_Echo("/gts info     shows this screen.");
	
	--Call other mod's SlashCommand handlers
	
	elseif (IsAddOnLoaded("GTS_BankScan") and GTS_BS_SlashCommand(msg)) then return; 
	
	elseif (IsAddOnLoaded("GTS_IncomingMail")and GTS_IM_SlashCommand(msg)) then return; 
	
	elseif (IsAddOnLoaded("GTS_OutgoingMail") and GTS_OM_SlashCommand(msg)) then return;
	
	elseif (IsAddOnLoaded("GTS_GuildRosterScan") and GTS_GRS_SlashCommand(msg)) then return; 
	
	else 
		GTS_Echo(GTS_MSG["INVALID"]);
	end
end

--Returns full info of the item on bag_id, slot_id, nil if item is not there
function GTS_GetContainerItemInfo(bag_id, slot_id)
	local count, texture, itemLink, itemName, itemQuality, itemDesc, itemType, itemSubType, itemId, price;
	
	if (not GetContainerItemInfo(bag_id, slot_id)) then 
		GTS_Debug("No item in the slot "..bag_id..", "..slot_id);
		return nil;
	end
	
	--Get texture and count of the item in the current slot
	_, count = GetContainerItemInfo(bag_id, slot_id);
	
	--Get link and the name of the item in the current slot
	itemLink = GetContainerItemLink(bag_id, slot_id);
	GTS_Debug("itemLink: "..itemLink);
	
	itemName, itemQuality, itemDesc, texture, itemType, itemSubType, itemId, price = GTS_GetItemInfo(itemLink);
	GTS_Debug("Price: "..price);
	
	return itemName, itemQuality, itemDesc, count, texture, itemType, itemSubType, itemId, price;
end

-- Retunrs all info about the item specified as item link.
function GTS_GetItemInfo(itemLink)
	local texture, count, itemName, itemQuality, itemDesc, itemType, itemSubType, itemId, price;
	local i, command;
	
	GTS_Debug("itemLink: "..itemLink);
	_, _, itemLink, itemName = string.find(itemLink,"|H(item:%d+:%d+:%d+:%d+)|h%[([^]]+)%]|h|r$");
	_,_,itemId = string.find(itemLink,"item:(%d+):%d+:%d+:%d+");
	GTS_Debug("ID: "..itemId);
	
	_, _, itemQuality, _, itemType, itemSubType, _, _, texture = GetItemInfo(itemId);
	_,_,texture = string.find(texture, "%a+\\%a+\\([%w_]+)");
	
	GTS_Debug("Link: "..itemLink);
	--Set tooltip to the current item
	GTS_ItemTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT");
	GTS_ItemTooltip:ClearLines();
	GTS_ItemTooltip:SetHyperlink(itemLink);
	
	--Copy the description test from the tooltip to the variable
	--<n> - new line symbol
	--<t> - tab symbol
	for i=1, GTS_ItemTooltip:NumLines(),1 do
	
		command = getglobal("GTS_ItemTooltipTextLeft" .. i);
		if (command:IsShown()) then
			text_left = command:GetText();
		else
			text_left = nil;
		end
		
		command = getglobal("GTS_ItemTooltipTextRight" .. i);
		if (command:IsShown()) then
			text_right = command:GetText();
		else
			text_right = nil;
		end
		
		if (text_left and string.find(text_left, "\n")) then
			text_left = " ";
		end
		
		if (text_right and string.find(text_right, "\n")) then
			text_right = " ";
		end
		
		if (i == 1) then 
			itemDesc = text_left;
		else
			if (text_left) then 
				itemDesc = itemDesc.." <n> "..text_left;
			end
		end
		if (text_right) then
			itemDesc = itemDesc.." <t> "..text_right;
		end
	end
	
	price = 0;
	if (IsAddOnLoaded("LootLink") and ItemLinks and ItemLinks[itemName] and ItemLinks[itemName].p) then
		price = ItemLinks[itemName].p;
	end
	
	return itemName, itemQuality, itemDesc, texture, itemType, itemSubType, itemId, price;
end

-- Retunrs all info about the item specified as mail id.
-- if mail id >0 - inbox, 
-- -1 - outbox
function GTS_GetMailItemInfo(id)
	local texture, itemName, count, itemQuality, itemDesc, itemType, itemSubType, itemId, price;
	local i, command;
	
	GTS_Debug("MailID: "..id);
	
	if (id>0) then 
		itemName, texture, count = GetInboxItem(id);
	else 
		itemName, texture, count = GetSendMailItem();
	end
	if (not itemName) then return itemName; end
	_,_,texture = string.find(texture, "%a+\\%a+\\([%w_]+)");
	
	--Set tooltip to the current item
	GTS_ItemTooltip:SetOwner(UIParent, "ANCHOR_BOTTOMRIGHT");
	GTS_ItemTooltip:ClearLines();
	if (id>0) then 
		GTS_ItemTooltip:SetInboxItem(id);
	else
		GTS_ItemTooltip:SetSendMailItem();
	end
	
	--Copy the description test from the tooltip to the variable
	--<n> - new line symbol
	--<t> - tab symbol
	for i=1, GTS_ItemTooltip:NumLines(),1 do
	
		command = getglobal("GTS_ItemTooltipTextLeft" .. i);
		if (command:IsShown()) then
			text_left = command:GetText();
		else
			text_left = nil;
		end
		
		command = getglobal("GTS_ItemTooltipTextRight" .. i);
		if (command:IsShown()) then
			text_right = command:GetText();
		else
			text_right = nil;
		end
		
		if (text_left and string.find(text_left, "\n")) then
			text_left = " ";
		end
		
		if (text_right and string.find(text_right, "\n")) then
			text_right = " ";
		end
		
		if (i == 1) then 
			itemDesc = text_left;
		else
			if (text_left) then 
				itemDesc = itemDesc.." <n> "..text_left;
			end
		end
		if (text_right) then
			itemDesc = itemDesc.." <t> "..text_right;
		end
	end

	for i=3, 28000 do
		local name, _, _ = GetItemInfo(i);
		if ( name ) then
			local nameLength = strlen(name);
			if ( name == itemName or string.sub(itemName, 1, nameLength) == name) then
				-- Doesn't deal with same name, different item since none of these can be mailed
				itemId = i;
				break;
			end
		end
	end
	
	_, _, itemQuality, _, itemType, itemSubType = GetItemInfo(itemId);
	
	price = 0;
	if (IsAddOnLoaded("LootLink") and ItemLinks and ItemLinks[itemName] and ItemLinks[itemName].p) then
		price = ItemLinks[itemName].p;
	end
	
	return itemName, itemQuality, itemDesc, count, texture, itemType, itemSubType, itemId, price;
end

--Prints message into the text chat window
function GTS_Echo(message)
	if ( DEFAULT_CHAT_FRAME ) then 
		DEFAULT_CHAT_FRAME:AddMessage("GTS> "..message, 0.5, 0.5, 1.0);
	end
end

--Prints debug message into the chat window iff local variable GTS_DebugMode is set to 1
--otherwise does nothing
function GTS_Debug(message)
	if (GTS_DebugMode == 1) then
		message = "GTS><**Debug**> " .. message;
		if ( DEFAULT_CHAT_FRAME ) then 
			DEFAULT_CHAT_FRAME:AddMessage(message, 1.0, 0.0, 0.0);
		end
	end
end