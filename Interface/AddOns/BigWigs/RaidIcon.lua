assert(BigWigs, "BigWigs not found!")

------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.0"):new("BigWigsRaidIcon")
local lastplayer = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["Raid Icons"] = true,

	["raidicon"] = true,
	["place"] = true,
	["icon"] = true,

	["Place"] = true,
	["Place Raid Icons"] = true,
	["Toggle placing of Raid Icons on players."] = true,
	
	["Icon"] = true,
	["Set Icon"] = true,
	["Set which icon to place on players."] = true,
	
	["Options for Raid Icons."] = true,

	["star"] = true,
	["circle"] = true,
	["diamond"] = true,
	["triangle"] = true,
	["moon"] = true,
	["square"] = true,
	["cross"] = true,
	["skull"] = true,
} end )

L:RegisterTranslations("koKR", function() return {
	["Raid Icons"] = "??? ???",

	["Place"] = "??",
	["Place Raid Icons"] = "??? ??? ??",
	["Toggle placing of Raid Icons on players."] = "????? ??? ??? ?? ??",
	
	["Icon"] = "???",
	["Set Icon"] = "??? ??",
	["Set which icon to place on players."] = "????? ??? ??? ?? ??",
	
	["Options for Raid Icons."] = "??? ???? ?? ??",

	["star"] = "?",
	["circle"] = "?",
	["diamond"] = "?????",
	["triangle"] = "??",
	["moon"] = "?",
	["square"] = "??",
	["cross"] = "???",
	["skull"] = "??",

} end )

L:RegisterTranslations("zhCN", function() return {
	["Raid Icons"] = "????",

	["Place"] = "??",
	["Place Raid Icons"] = "??????",
	["Toggle placing of Raid Icons on players."] = "???????????????",
	
	["Icon"] = "??",
	["Set Icon"] = "????",
	["Set which icon to place on players."] = "????????????",
	
	["Options for Raid Icons."] = "??????",
	
	["star"] = "??",
	["circle"] = "??",
	["diamond"] = "??",
	["triangle"] = "??",
	["moon"] = "??",
	["square"] = "??",
	["cross"] = "??",
	["skull"] = "??",
} end )

L:RegisterTranslations("deDE", function() return {
	["Raid Icons"] = "Schlachtzug Symbole",

	-- ["raidicon"] = true,
	-- ["place"] = true,
	-- ["icon"] = true,

	["Place"] = "Platzierung",
	["Place Raid Icons"] = "Platziere Schlachtzug Symbole",
	["Toggle placing of Raid Icons on players."] = "W\195\164hle, ob Schlachtzug Symbole auf Spieler gesetzt werden.",
	
	["Icon"] = "Symbol",
	["Set Icon"] = "Symbol",
	["Set which icon to place on players."] = "W\195\164hle, welches Symbol auf Spieler gesetzt wird.",
	
	["Options for Raid Icons."] = "Optionen f\195\188r Schlachtzug Symbole.",

	["star"] = "Stern",
	["circle"] = "Kreis",
	["diamond"] = "Diamant",
	["triangle"] = "Dreieck",
	["moon"] = "Mond",
	["square"] = "Quadrat",
	["cross"] = "Kreuz",
	["skull"] = "Totenkopf",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsRaidIcon = BigWigs:NewModule(L["Raid Icons"])
BigWigsRaidIcon.defaultDB = {
	place = true,
	icon = L["skull"],
}
BigWigsRaidIcon.icontonumber = {
	[L["star"]] = 1,
	[L["circle"]] = 2,
	[L["diamond"]] = 3,
	[L["triangle"]] = 4,
	[L["moon"]] = 5,
	[L["square"]] = 6,
	[L["cross"]] = 7,
	[L["skull"]] = 8,
}
BigWigsRaidIcon.consoleCmd = L["raidicon"]
BigWigsRaidIcon.consoleOptions = {
	type = "group",
	name = L["Raid Icons"],
	desc = L["Options for Raid Icons."],
	args   = {
		[L["place"]] = {
			type = "toggle",
			name = L["Place Raid Icons"],
			desc = L["Toggle placing of Raid Icons on players."],
			get = function() return BigWigsRaidIcon.db.profile.place end,
			set = function(v) BigWigsRaidIcon.db.profile.place = v end,		
		},
		[L["icon"]] = {
			type = "text",
			name = L["Set Icon"],
			desc = L["Set which icon to place on players."],
			get = function() return BigWigsRaidIcon.db.profile.icon end,
			set = function(v) BigWigsRaidIcon.db.profile.icon = v end,
			validate = {L["star"], L["circle"], L["diamond"], L["triangle"], L["moon"], L["square"], L["cross"], L["skull"] },
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsRaidIcon:OnEnable()
	self:RegisterEvent("BigWigs_SetRaidIcon")
	self:RegisterEvent("BigWigs_RemoveRaidIcon")
end

function BigWigsRaidIcon:BigWigs_SetRaidIcon(player)
	if not self.db.profile.place or not player then return end
	local icon = self.db.profile.icon
	if not self.icontonumber[icon] then
		icon = L["skull"]
	end
	icon = self.icontonumber[icon]
	for i=1,GetNumRaidMembers() do
		if UnitName("raid"..i) == player then
			if not GetRaidTargetIndex("raid"..i) then
				SetRaidTargetIcon("raid"..i, icon)
				lastplayer = player
			end
		end
	end
end

function BigWigsRaidIcon:BigWigs_RemoveRaidIcon()
	if not self.db.profile.place or not lastplayer then return end
	for i=1,GetNumRaidMembers() do
		if UnitName("raid"..i) == lastplayer then
			SetRaidTargetIcon("raid"..i, 0)
		end
	end
	lastplayer = nil
end
