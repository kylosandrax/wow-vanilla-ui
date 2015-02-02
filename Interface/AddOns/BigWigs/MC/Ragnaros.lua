
------------------------------
--      Event Handlers      --
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Ragnaros"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	knockback_trigger = "^TASTE",
	submerge_trigger = "^COME FORTH,",
	engage_trigger = "^NOW FOR YOU",

	knockback_message = "Knockback!",
	knockback_soon_message = "5 sec to knockback!",
	submerge_message = "Ragnaros down for 90 sec. Incoming Sons of Flame!",
	emerge_soon_message = "15 sec until Ragnaros emerges!",
	emerge_message = "Ragnaros emerged, 3 minutes until submerge!",
	submerge_60sec_message = "60 sec to submerge!",
	submerge_20sec_message = "20 sec to submerge!",

	knockback_bar = "AoE knockback",
	emerge_bar = "Ragnaros emerge",
	submerge_bar = "Ragnaros submerge",

	sonofflame = "Son of Flame",
	sonsdeadwarn = "%d/8 Sons of Flame dead!",

	cmd = "Ragnaros",

	emerge_cmd = "emerge",
	emerge_name = "Emerge alert",
	emerge_desc = "Warn for Ragnaros Emerge",

	sondeath_cmd = "sondeath",
	sondeath_name = "Son of Flame dies",
	sondeath_desc = "Warn when a son dies",

	submerge_cmd = "submerge",
	submerge_name = "Submerge alert",
	submerge_desc = "Warn for Ragnaros Submerge & Sons of Flame",

	aoeknock_cmd = "aoeknock",
	aoeknock_name = "Knockback alert",
	aoeknock_desc = "Warn for Wrath of Ragnaros knockback",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsRagnaros = BigWigs:NewModule(boss)
BigWigsRagnaros.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsRagnaros.enabletrigger = boss
BigWigsRagnaros.wipemobs = { L["sonofflame"] }
BigWigsRagnaros.toggleoptions = { "sondeath", "submerge", "emerge", "aoeknock", "bosskill" }
BigWigsRagnaros.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsRagnaros:OnEnable()
	started = nil
	self.sonsdead = 0

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "RagnarosSonDead", .1)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsRagnaros:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, L["sonofflame"]) then
		self:TriggerEvent("BigWigs_SendSync", "RagnarosSonDead "..tostring(self.sonsdead + 1) )
	else
		self:GenericBossDeath(msg)
	end
end

function BigWigsRagnaros:BigWigs_RecvSync(sync, rest)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	elseif sync == "RagnarosSonDead" and rest then
		rest = tonumber(rest)
		if not rest then return end
		if rest == (self.sonsdead + 1) then
			self.sonsdead = self.sonsdead + 1
			if self.db.profile.sondeath then
				self:TriggerEvent("BigWigs_Message", string.format(L["sonsdeadwarn"], self.sonsdead), "Urgent")
			end
			if self.sonsdead == 8 then
				self.sonsdead = 0 -- reset counter
			end
		end
	end
end

function BigWigsRagnaros:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["knockback_trigger"]) and self.db.profile.aoeknock then
		self:TriggerEvent("BigWigs_Message", L["knockback_message"], "Important")
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Run") end, 20)
		self:ScheduleEvent("bwragnarosaekbwarn", "BigWigs_Message", 20, L["knockback_soon_message"], "Urgent", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["knockback_bar"], 25, "Interface\\Icons\\Spell_Fire_SoulBurn")
	elseif string.find(msg, L["submerge_trigger"]) then
		self:Submerge()
	elseif string.find(msg, L["engage_trigger"]) then
		self:Emerge()
	end
end

function BigWigsRagnaros:Submerge()
	self:CancelScheduledEvent("bwragnarosaekbwarn")
	self:TriggerEvent("BigWigs_StopBar", self, L["knockback_bar"])

	if self.db.profile.submerge then
		self:TriggerEvent("BigWigs_Message", L["submerge_message"], "Important")
	end
	if self.db.profile.emerge then
		self:ScheduleEvent("bwragnarosemergewarn", "BigWigs_Message", 75, L["emerge_soon_message"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["emerge_bar"], 90, "Interface\\Icons\\Spell_Fire_Volcano")
	end
	self:ScheduleRepeatingEvent("bwragnarosemergecheck", self.EmergeCheck, 2, self)
	self:ScheduleEvent("bwragnarosemerge", self.Emerge, 90, self)
end

function BigWigsRagnaros:EmergeCheck()
	if UnitExists("target") and UnitName("target") == boss and UnitExists("targettarget") then
		self:Emerge()
		return
	end
	local num = GetNumRaidMembers()
	for i = 1, num do
		local raidUnit = string.format("raid%starget", i)
		if UnitExists(raidUnit) and UnitName(raidUnit) == boss and UnitExists(raidUnit.."target") then
			self:Emerge()
			return
		end
	end
end

function BigWigsRagnaros:Emerge()
	self:CancelScheduledEvent("bwragnarosemergecheck")
	self:CancelScheduledEvent("bwragnarosemergewarn")
	self:TriggerEvent("BigWigs_StopBar", self, L["emerge_bar"])

	if self.db.profile.emerge then
		self:TriggerEvent("BigWigs_Message", L["emerge_message"], "Attention")
	end
	if self.db.profile.submerge then
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Ragna") end, 20)
		self:ScheduleEvent("bwragnarosaekbwarn", "BigWigs_Message", 20, L["knockback_soon_message"], "Urgent", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["knockback_bar"], 25, "Interface\\Icons\\Spell_Fire_SoulBurn")
		self:ScheduleEvent("BigWigs_Message", 120, L["submerge_60sec_message"], "Urgent")
		self:ScheduleEvent("BigWigs_Message", 160, L["submerge_20sec_message"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["submerge_bar"], 180, "Interface\\Icons\\Spell_Fire_SelfDestruct")
	        self:ScheduleEvent("bwragnarossubmerge", self.Submerge, 180, self)
	end
end

