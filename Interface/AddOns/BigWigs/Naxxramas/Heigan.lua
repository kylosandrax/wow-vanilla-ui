------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Heigan the Unclean"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Heigan",

	teleport_cmd = "teleport",
	teleport_name = "Teleport Alert",
	teleport_desc = "Warn for Teleports.",

	engage_cmd = "engage",
	engage_name = "Engage Alert",
	engage_desc = "Warn when Heigan is engaged.",

	-- [[ Triggers ]]--
	starttrigger = "You are mine now!",
	starttrigger2 = "You...are next!",
	starttrigger3 = "I see you!",
	teleport_trigger = "The end is upon you.",
	die_trigger = "%s takes his last breath.",

	-- [[ Warnings ]]--
	engage_message = "Heigan the Unclean engaged! 90 sec to teleport!",

	teleport_1min_message = "Teleport in 1 min",
	teleport_30sec_message = "Teleport in 30 sec",
	teleport_10sec_message = "Teleport in 10 sec!",
	on_platform_message = "Teleport! On platform for %d sec!",

	to_floor_30sec_message = "Back in 30 sec",
	to_floor_10sec_message = "Back in 10 sec!",
	on_floor_message = "Back on the floor! 90 sec to next teleport!",

	-- [[ Bars ]]--
	teleport_bar = "Teleport!",
	back_bar = "Back on the floor!",

	-- [[ Dream Room Mobs ]] --
	["Eye Stalk"] = true,
	["Rotting Maggot"] = true,
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsHeigan = BigWigs:NewModule(boss)
BigWigsHeigan.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsHeigan.enabletrigger = boss
BigWigsHeigan.wipemobs = { L["Eye Stalk"], L["Rotting Maggot"] }
BigWigsHeigan.toggleoptions = {"engage", "teleport", "bosskill"}
BigWigsHeigan.revision = tonumber(string.sub("$Revision: 17550 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsHeigan:OnEnable()
	self.toRoomTime = 45
	self.toPlatformTime = 90
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("CHAT_MSG_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "HeiganTeleport", 10)
end

function BigWigsHeigan:CHAT_MSG_MONSTER_EMOTE( msg )
	if msg == L["die_trigger"] then
		if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s has been defeated"], boss), "Bosskill", nil, "Victory") end
		self.core:ToggleModuleActive(self, false)
	end
end

function BigWigsHeigan:CHAT_MSG_MONSTER_YELL( msg )
	if string.find(msg, L["starttrigger"]) or string.find(msg, L["starttrigger2"]) or string.find(msg, L["starttrigger3"]) then
		if self.db.profile.engage then
			self:TriggerEvent("BigWigs_Message", L["engage_message"], "Important")
		end
		if self.db.profile.teleport then
			self:TriggerEvent("BigWigs_StartBar", self, L["teleport_bar"], self.toPlatformTime, "Interface\\Icons\\Spell_Arcane_Blink")
			self:ScheduleEvent("bwheiganwarn1", "BigWigs_Message", self.toPlatformTime-60, L["teleport_1min_message"], "Attention")
			self:ScheduleEvent("bwheiganwarn2", "BigWigs_Message", self.toPlatformTime-30, L["teleport_30sec_message"], "Urgent")
			self:ScheduleEvent("bwheiganwarn3", "BigWigs_Message", self.toPlatformTime-10, L["teleport_10sec_message"], "Important")
		end
	elseif string.find(msg, L["teleport_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "HeiganTeleport")
	end
end

function BigWigsHeigan:BigWigs_RecvSync( sync )
	if sync ~= "HeiganTeleport" then return end

	self:ScheduleEvent( self.BackToRoom, self.toRoomTime, self )
        BigWigsThaddiusArrows:Direction("Run")

	if self.db.profile.teleport then
		self:TriggerEvent("BigWigs_Message", string.format(L["on_platform_message"], self.toRoomTime), "Attention")
		self:ScheduleEvent("bwheiganwarn2","BigWigs_Message", self.toRoomTime-30, L["to_floor_30sec_message"], "Urgent")
		self:ScheduleEvent("bwheiganwarn3","BigWigs_Message", self.toRoomTime-10, L["to_floor_10sec_message"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["back_bar"], self.toRoomTime, "Interface\\Icons\\Spell_Magic_LesserInvisibilty")
	end
end

function BigWigsHeigan:BackToRoom()
	if self.db.profile.teleport then
		self:TriggerEvent("BigWigs_Message", L["on_floor_message"], "Attention")
		self:ScheduleEvent("bwheiganwarn2","BigWigs_Message", self.toPlatformTime-30, L["teleport_30sec_message"], "Urgent")
		self:ScheduleEvent("bwheiganwarn3","BigWigs_Message", self.toPlatformTime-10, L["teleport_10sec_message"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["teleport_bar"], self.toPlatformTime, "Interface\\Icons\\Spell_Arcane_Blink")
	end
end


