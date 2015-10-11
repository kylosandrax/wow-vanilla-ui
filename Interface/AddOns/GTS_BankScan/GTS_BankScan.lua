--[[
BankScan v3.0b1

Part of the GuildToolS package.
Dependancy: GTS_Core

	- Scans all posessions of the character, including bank, bags and bags in bank.

Author: Roman Tarakanov (RTE/Arthas)
Date: May 14 '06

]]--
---------------------------------------------------------------
----------------------Standart mesages-------------------------
---------------------------------------------------------------

GTS_BS_VER = "3.0b1";

GTS_MSG["BS_GREETING"]   = "GTS_BankScan v" .. GTS_BS_VER .. " is loaded.";
GTS_MSG["BS_DONE"]       = "BankScan | Success : scan was successful, now you can log out and run BankParser.bat to get html file.";
GTS_MSG["BS_BANKCLOSED"] = "BankScan | Error : bank must be opened for this script to work.";
GTS_MSG["BS_SORTON"]     = "BankScan's sort function is ENABLED";
GTS_MSG["BS_SORTOFF"]    = "BankScan varibles are cleared for this character.";

---------------------------------------------------------------
------------------Global BankScan variables--------------------
---------------------------------------------------------------

--BankOpen indicator
-- 0 - bank closed
-- 1 - bank opened
local BankStatus;
--List of the bags to look in
local BanknBags;
local MoneyScanned = 1;
local GTS_BS_PreScannedItems;

---------------------------------------------------------------
----------------Global BankScan functions--------------------
---------------------------------------------------------------

--OnLoad function
function GTS_BS_OnLoad()
	GTS_BS_PreScannedItems = {};
	BanknBags = { -1, 5, 6, 7, 8, 9, 10, 0, 1, 2, 3, 4};
	BankStatus = 0;
	
	if (not GTS_Data) then GTS_Data = {}; end
	if (not GTS_Data.BS) then GTS_Data.BS = {}; end
	
	if (not GTS_Data.BS.ScannedItems) then GTS_Data.BS.ScannedItems = {}; end
	if (not GTS_Data.BS.ScannedItems[UnitName("player")]) then GTS_Data.BS.ScannedItems[UnitName("player")] = {}; end
	if (not GTS_Data.BS.Money) then GTS_Data.BS.Money = {}; end
	--if (not GTS_Data.BS.Money[UnitName("player")]) then GTS_Data.BS.Money[UnitName("player")] = ; end
	if (not GTS_Data.BS.Date) then GTS_Data.BS.Date = {}; end
	--if (not GTS_Data.BS.Date[UnitName("player")]) then GTS_Data.BS.Date[UnitName("player")] = "0/0/0"; end
	
	GTS_Menu_BS_NL:Hide();
	GTS_Menu_BS:Show();
	GTS_Debug(">"..GTS_Menu_BS_Header:GetText())
	GTS_Echo(GTS_MSG["BS_GREETING"]);
end

--OnEvent function
function GTS_BS_OnEvent(event)	 
	--GTS_Debug("OnEvent is called");
	
	if (event == "BANKFRAME_OPENED") then
		GTS_Debug("Bank was opened.");
		BankStatus = 1;
		return 1;
		
	elseif (event == "BANKFRAME_CLOSED") then
		GTS_Debug("Bank was closed.");		
		BankStatus = 0;
		return 1;
		
	else
		return nil;
	end
end

--Slash command handler
function GTS_BS_SlashCommand(msg)
	if (msg == "bscan") then
		if (BankStatus == 1) then
			GTS_BS_PreScannedItems = {};
			GTS_Debug("GTS_BS_DoScan is called.");
			GTS_BS_DoScan();
			GTS_Debug("GTS_BS_DoScan exited.");
			GTS_BS_Finalize();
			GTS_Echo(GTS_MSG["BS_DONE"]);
		else
			GTS_Echo(GTS_MSG["BS_BANKCLOSED"]);
		end
		return 1;
		
	elseif (msg == "bsclear") then
		GTS_Data.BS.ScannedItems[UnitName("player")] = {};
		GTS_Data.BS.Money[UnitName("player")] = nil;
		GTS_Data.BS.Date[UnitName("player")] = nil;
		GTS_Echo(GTS_MSG["BS_SORTOFF"]);
		return 1;
		
	elseif (msg == "bsclearall") then
		GTS_Data.BS.ScannedItems = {};
		GTS_Data.BS.ScannedItems[UnitName("player")] = {};
		GTS_Data.BS.Money = {};
		GTS_Data.BS.Date = {};
		return 1;
		
	elseif (msg == "bssort") then
		if (GTS_Options[GTS_Position].BSSort==1) then
			GTS_Options[GTS_Position].BSSort=2;		
			GTS_Echo(GTS_MSG["BS_SORTOFF"]);
			return 1;
		else
			GTS_Options[GTS_Position].BSSort=1;		
			GTS_Echo(GTS_MSG["BS_SORTON"]);
			return 1;
		end
		
	elseif (msg == "bsinfo") then
		GTS_Echo("Scans possesions of the char, including bank into SV.lua.");
		GTS_Echo("Available commands:");
		GTS_Echo("/gts bssort     tuggles the BankScan's sorting function on/off for this char.");
		GTS_Echo("/gts bscan      performs the scan of possesions of this char for parsing into SV.lua.");
		GTS_Echo("/gts bsclear    clears all the data scanned for this character form SV.lua.");
		GTS_Echo("/gts bsinfo     shows this screen.");
		return 1;
	else
		return nil;
	end

end

---------------------------------------------------------------
---------------------BankScan functions------------------------
---------------------------------------------------------------

--This function actually scans all bags for items
function GTS_BS_DoScan()
	--Array of items that will be saved in SavedVariables.lua
	--Initiated as empty, if BankScan is not called during the session all data will be wiped upon logout
	GTS_Data.BS.ScannedItems[UnitName("player")] = {};

	local index, bag_id, slot_id, count, texture, itemLink, itemName, i, command, itemQuality, itemDesc, itemType, itemSubType, itemId, price;

	--Go through every slot in the bags (and bank)
	for index, bag_id in BanknBags do
		if (GetContainerNumSlots(bag_id)) then
			for slot_id = 1, GetContainerNumSlots(bag_id), 1 do
				if (GetContainerItemLink(bag_id, slot_id)) then
					
					itemName, itemQuality, itemDesc, count, texture, itemType, itemSubType, itemId, price = GTS_GetContainerItemInfo(bag_id, slot_id);
					
					--Save info on current item in the array
					if (not GTS_BS_PreScannedItems[itemName]) then
						GTS_BS_PreScannedItems[itemName] = {description=" "..itemDesc.." ",
														number=count,
														pic=" "..texture.." ", 
														quality=itemQuality,
														subtype = " "..itemSubType.." ",
														type = " "..itemType.." ",
														id = " "..itemId.." ",
														price = " "..price.." "};
						--Sorting function
						if (GTS_Options[GTS_Position].BSSort == 1) then
							if(itemType=="Trade Goods") then 
								GTS_BS_PreScannedItems[itemName].sort = 900;
								if (itemSubType=="Devices") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 36 - 300;
								elseif (itemSubType=="Explosives") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 35 - 300;
								elseif (itemSubType=="Parts") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 58;
								elseif (itemSubType=="Trade Goods") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 59;
								elseif (itemSubType=="Enchanting") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 57;
								end 
							elseif(itemType=="Reagent") then 
								GTS_BS_PreScannedItems[itemName].sort = 895;
							elseif(itemType=="Weapon") then 
								GTS_BS_PreScannedItems[itemName].sort = 700;
								if (itemSubType=="Fishing Pole") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 39 - 100;
								elseif (itemSubType=="Miscellaneous") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 38 - 100;
								elseif (itemSubType=="Thrown") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 9 - 200;
								else GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 50;
								end 
							elseif(itemType=="Armor") then 
								GTS_BS_PreScannedItems[itemName].sort = 600;
								if (itemSubType=="Shield") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 60;
								elseif (itemSubType=="Cloth") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 59;
								elseif (itemSubType=="Leather") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 58;
								elseif (itemSubType=="Mail") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 57;
								elseif (itemSubType=="Plate") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 56;
								elseif (itemSubType=="Miscellaneous") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 37;
								end 
							elseif(itemType=="Recipe") then 
								GTS_BS_PreScannedItems[itemName].sort = 500;
								if (itemSubType=="Book") then GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 59;
								else GTS_BS_PreScannedItems[itemName].sort = GTS_BS_PreScannedItems[itemName].sort + 50;
								end
							elseif(itemType=="Projectile") then 
								GTS_BS_PreScannedItems[itemName].sort = 450;
							elseif(itemType=="Consumable") then 
								GTS_BS_PreScannedItems[itemName].sort = 350;
							elseif(itemType=="Container") then 
								GTS_BS_PreScannedItems[itemName].sort = 250;
							else GTS_BS_PreScannedItems[itemName].sort = 50; end
						else
							GTS_BS_PreScannedItems[itemName].sort = 10000 - (bag_id+2)*100 - (slot_id+2);
						end
					else
						GTS_BS_PreScannedItems[itemName].number = GTS_BS_PreScannedItems[itemName].number + count;
					end
				end
			end
		end
	end
end

--after routine for DoScan
function GTS_BS_Finalize()
	--Array of items that will be saved in SavedVariables.lua
	--Initiated as empty, if BankScan is not called during the session all data will be wiped upon logout
	GTS_Data.BS.ScannedItems[UnitName("player")] = {};
	
	for itemName, param in pairs(GTS_BS_PreScannedItems) do
		
		local element = {name = itemName, description = param.description, 
					number = param.number, pic = param.pic, quality = param.quality,
					sort = param.sort, type = param.type, subtype = param.subtype, id = param.id, price=param.price};
		table.insert(GTS_Data.BS.ScannedItems[UnitName("player")], element);
		GTS_Debug("itemName: "..itemName..", = "..GTS_Data.BS.ScannedItems[UnitName("player")][1].name);
	end
	GTS_BS_PreScannedItems = {};
	
	--Sorting done in the following way:
	--first sort according to sort function, then alphabetically by subtype then by quality, then alphabeticaly by name
	table.sort(GTS_Data.BS.ScannedItems[UnitName("player")], function(i,j) return ((i.sort>j.sort) or (i.sort==j.sort and i.subtype<j.subtype) or 
										(i.sort==j.sort and i.subtype==j.subtype and i.quality>j.quality) or
										(i.sort==j.sort and i.subtype==j.subtype and i.quality==j.quality and i.name<j.name)) end);
	
	for itemName, param in pairs(GTS_Data.BS.ScannedItems[UnitName("player")]) do
		GTS_Debug("itemName: "..itemName);
		GTS_Data.BS.ScannedItems[UnitName("player")][itemName].name = " "..param.name.." ";
		GTS_Data.BS.ScannedItems[UnitName("player")][itemName].number = " "..param.number.." ";
		GTS_Data.BS.ScannedItems[UnitName("player")][itemName].quality = " "..param.quality.." ";
	end 
	if (not GTS_Data.BS.Money[UnitName("player")]) then GTS_Data.BS.Money[UnitName("player")] = " 0 "; end
	if (not GTS_Data.BS.Date[UnitName("player")]) then GTS_Data.BS.Date[UnitName("player")] = " 00-0-0 "; end
	GTS_Data.BS.Date[UnitName("player")] = " "..date("%y-%m-%d").." ";
	GTS_Data.BS.Money[UnitName("player")] = " "..GetMoney().." ";
	GTS_Debug("BS Date: "..GTS_Data.BS.Date[UnitName("player")]);
	GTS_Debug("BS Money: "..GTS_Data.BS.Money[UnitName("player")]);
end
