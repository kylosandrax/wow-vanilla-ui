
StubbyConfig = {
	["addinfo"] = {
		["EnhTooltip"] = "EnhTooltip|Used to display enhanced tooltips under the original tooltip or in the original tooltip, contains hooking functions for almost all major in game item tooltips [3.9.0.1030] This AddOn is licenced under the GNU GPL, see GPL.txt for details.",
		["Auctioneer"] = "Auctioneer|Displays item info and analyzes auction data. Use \"/auctioneer scan\" at AH to collect auction data. [3.9.0.1063 (Kangaroo)] This AddOn is licenced under the GNU GPL, see GPL.txt for details.",
		["Enchantrix"] = "Enchantrix|Display information in item tooltips pertaining to the results of disenchanting said item.  [3.9.0.1000] This AddOn is licenced under the GNU GPL, see GPL.txt for details.",
		["Informant"] = "Informant|Displays detailed item information in tooltips, and can produce item reports by binding an information window to a keypress [3.9.0.1000] This AddOn is licenced under the GNU GPL, see GPL.txt for details.",
	},
	["boots"] = {
		["informant"] = {
			["commandhandler"] = "		local function cmdHandler(msg)\n			local i,j, cmd, param = string.find(string.lower(msg), \"^([^ ]+) (.+)$\")\n			if (not cmd) then cmd = string.lower(msg) end\n			if (not cmd) then cmd = \"\" end\n			if (not param) then param = \"\" end\n			if (cmd == \"load\") then\n				if (param == \"\") then\n					Stubby.Print(\"Manually loading Informant...\")\n					LoadAddOn(\"Informant\")\n				elseif (param == \"always\") then\n					Stubby.Print(\"Setting Informant to always load for this character\")\n					Stubby.SetConfig(\"Informant\", \"LoadType\", param)\n					LoadAddOn(\"Informant\")\n				elseif (param == \"never\") then\n					Stubby.Print(\"Setting Informant to never load automatically for this character (you may still load manually)\")\n					Stubby.SetConfig(\"Informant\", \"LoadType\", param)\n				else\n					Stubby.Print(\"Your command was not understood\")\n				end\n			else\n				Stubby.Print(\"Informant is currently not loaded.\")\n				Stubby.Print(\"  You may load it now by typing |cffffffff/informant load|r\")\n				Stubby.Print(\"  You may also set your loading preferences for this character by using the following commands:\")\n				Stubby.Print(\"  |cffffffff/informant load always|r - Informant will always load for this character\")\n				Stubby.Print(\"  |cffffffff/informant load never|r - Informant will never load automatically for this character (you may still load it manually)\")\n			end\n		end\n		SLASH_INFORMANT1 = \"/informant\"\n		SLASH_INFORMANT2 = \"/inform\"\n		SLASH_INFORMANT3 = \"/info\"\n		SLASH_INFORMANT4 = \"/inf\"\n		SlashCmdList[\"INFORMANT\"] = cmdHandler\n	",
			["triggers"] = "		local loadType = Stubby.GetConfig(\"Informant\", \"LoadType\")\n		if (loadType == \"always\") then\n			LoadAddOn(\"Informant\")\n		else\n			Stubby.Print(\"Informant is not loaded. Type /informant for more info.\");\n		end\n	",
		},
		["auctioneer"] = {
			["commandhandler"] = "\n		local function cmdHandler(msg)\n			local i,j, cmd, param = string.find(string.lower(msg), \"^([^ ]+) (.+)$\")\n			if (not cmd) then cmd = string.lower(msg) end\n			if (not cmd) then cmd = \"\" end\n			if (not param) then param = \"\" end\n			if (cmd == \"load\") then\n				if (param == \"\") then\n					Stubby.Print(\"Manually loading Auctioneer...\")\n					LoadAddOn(\"Auctioneer\")\n				elseif (param == \"auctionhouse\") then\n					Stubby.Print(\"Setting Auctioneer to load when this character visits the auction house\")\n					Stubby.SetConfig(\"Auctioneer\", \"LoadType\", param)\n				elseif (param == \"always\") then\n					Stubby.Print(\"Setting Auctioneer to always load for this character\")\n					Stubby.SetConfig(\"Auctioneer\", \"LoadType\", param)\n					LoadAddOn(\"Auctioneer\")\n				elseif (param == \"never\") then\n					Stubby.Print(\"Setting Auctioneer to never load automatically for this character (you may still load manually)\")\n					Stubby.SetConfig(\"Auctioneer\", \"LoadType\", param)\n				else\n					Stubby.Print(\"Your command was not understood\")\n				end\n			else\n				Stubby.Print(\"Auctioneer is currently not loaded.\")\n				Stubby.Print(\"  You may load it now by typing |cffffffff/auctioneer load|r\")\n				Stubby.Print(\"  You may also set your loading preferences for this character by using the following commands:\")\n				Stubby.Print(\"  |cffffffff/auctioneer load auctionhouse|r - Auctioneer will load when you visit the auction house\")\n				Stubby.Print(\"  |cffffffff/auctioneer load always|r - Auctioneer will always load for this character\")\n				Stubby.Print(\"  |cffffffff/auctioneer load never|r - Auctioneer will never load automatically for this character (you may still load it manually)\")\n			end\n		end\n		SLASH_AUCTIONEER1 = \"/auctioneer\"\n		SLASH_AUCTIONEER2 = \"/auction\"\n		SLASH_AUCTIONEER3 = \"/auc\"\n		SlashCmdList[\"AUCTIONEER\"] = cmdHandler\n	",
			["triggers"] = "\n		function Auctioneer_CheckLoad()\n			local loadType = Stubby.GetConfig(\"Auctioneer\", \"LoadType\")\n			if (loadType == \"auctionhouse\" or not loadType) then\n				LoadAddOn(\"Auctioneer\")\n			end\n		end\n		function Auctioneer_ShowNotLoaded()\n			BrowseNoResultsText:SetText(\"Auctioneer is not loaded. Type /auctioneer for more info.\");\n		end\n		local function onLoaded()\n			Stubby.UnregisterAddOnHook(\"Blizzard_AuctionUI\", \"Auctioneer\")\n			if (not IsAddOnLoaded(\"Auctioneer\")) then\n				Stubby.RegisterFunctionHook(\"AuctionFrame_Show\", 100, Auctioneer_ShowNotLoaded)\n			end\n		end\n		Stubby.RegisterFunctionHook(\"AuctionFrame_LoadUI\", 100, Auctioneer_CheckLoad)\n		Stubby.RegisterAddOnHook(\"Blizzard_AuctionUI\", \"Auctioneer\", onLoaded)\n		local loadType = Stubby.GetConfig(\"Auctioneer\", \"LoadType\")\n		if (loadType == \"always\") then\n			LoadAddOn(\"Auctioneer\")\n		else\n			Stubby.Print(\"Auctioneer is not loaded. Type /auctioneer for more info.\");\n		end\n	",
		},
		["enchantrix"] = {
			["commandhandler"] = "		local function cmdHandler(msg)\n			local i,j, cmd, param = string.find(string.lower(msg), \"^([^ ]+) (.+)$\")\n			if (not cmd) then cmd = string.lower(msg) end\n			if (not cmd) then cmd = \"\" end\n			if (not param) then param = \"\" end\n			if (cmd == \"load\") then\n				if (param == \"\") then\n					Stubby.Print(\"Manually loading Enchantrix...\")\n					LoadAddOn(\"Enchantrix\")\n				elseif (param == \"always\") then\n					Stubby.Print(\"Setting Enchantrix to always load for this character\")\n					Stubby.SetConfig(\"Enchantrix\", \"LoadType\", param)\n					LoadAddOn(\"Enchantrix\")\n				elseif (param == \"never\") then\n					Stubby.Print(\"Setting Enchantrix to never load automatically for this character (you may still load manually)\")\n					Stubby.SetConfig(\"Enchantrix\", \"LoadType\", param)\n				else\n					Stubby.Print(\"Your command was not understood\")\n				end\n			else\n				Stubby.Print(\"Enchantrix is currently not loaded.\")\n				Stubby.Print(\"  You may load it now by typing |cffffffff/enchantrix load|r\")\n				Stubby.Print(\"  You may also set your loading preferences for this character by using the following commands:\")\n				Stubby.Print(\"  |cffffffff/enchantrix load always|r - Enchantrix will always load for this character\")\n				Stubby.Print(\"  |cffffffff/enchantrix load never|r - Enchantrix will never load automatically for this character (you may still load it manually)\")\n			end\n		end\n		SLASH_ENCHANTRIX1 = \"/enchantrix\"\n		SLASH_ENCHANTRIX2 = \"/enchant\"\n		SLASH_ENCHANTRIX3 = \"/enx\"\n		SlashCmdList[\"ENCHANTRIX\"] = cmdHandler\n	",
			["triggers"] = "		if Stubby.GetConfig(\"Enchantrix\", \"LoadType\") == \"always\" then\n			LoadAddOn(\"Enchantrix\")\n		else\n			Stubby.Print(\"Enchantrix is not loaded. Type /enchantrix for more info.\")\n		end\n	",
		},
	},
	["inspected"] = {
		["EnhTooltip"] = true,
		["Auctioneer"] = true,
		["Enchantrix"] = true,
		["Informant"] = true,
	},
	["configs"] = {
		["informant"] = {
			["loadtype"] = "always",
		},
		["auctioneer"] = {
			["sixofnine:loadtype"] = "always",
			["zapunzel:loadtype"] = "always",
			["banjax:loadtype"] = "always",
			["kylosandrax:loadtype"] = "always",
			["stormslinger:loadtype"] = "always",
			["ryjax:loadtype"] = "always",
		},
		["enchantrix"] = {
			["sixofnine:loadtype"] = "always",
			["zapunzel:loadtype"] = "always",
			["ryjax:loadtype"] = "always",
			["kylosandrax:loadtype"] = "always",
		},
	},
}
