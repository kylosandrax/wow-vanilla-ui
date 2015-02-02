------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["The Prophet Skeram"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local skeramstarted = nil
----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	aetrigger = "The Prophet Skeram begins to cast Arcane Explosion.",
	mctrigger = "The Prophet Skeram begins to cast True Fulfillment.",
	splittrigger = "The Prophet Skeram casts Summon Images.",
	aewarn = "Casting Arcane Explosion!",
	mcwarn = "Casting Mind Control!",
	mcplayer = "^([^%s]+) ([^%s]+) afflicted by True Fulfillment.$",
	mcplayerwarn = "%s is mindcontrolled!",
	mcbar = "MC: %s",
	mcyou = "You",
	mcare = "are",

	win = "The Prophet Skeram has been defeated",


	pull1	= "Cower mortals!",
	pull2	= "Are you so eager to die?",
	pull3	= "Tremble!",
	
	splitwarn = "Splitting!",
	win = "You only delay... The inevitable...",

	telewarn = "Teleport in 5sec!",
	bartext = "Teleport",

	cmd = "Skeram",
	mc_cmd = "mc",
	mc_name = "Mind Control Alert",
	mc_desc = "Warn for Mind Control",

	ae_cmd = "ae",
	ae_name = "Arcane Explosion Alert",
	ae_desc = "Warn for Arcane Explosion",
	
--	split_cmd = "split",
--	split_name = "Split Alert",
--	split_desc = "Warn before Create Image",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsSkeram = BigWigs:NewModule(boss)
BigWigsSkeram.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsSkeram.enabletrigger = boss
BigWigsSkeram.toggleoptions = {"ae", "mc", "bosskill"}
BigWigsSkeram.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsSkeram:OnEnable()
	skeramstarted = nil
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
end

------------------------------
--      Event Handlers      --
------------------------------

-- Note that we do not sync the MC at the moment, since you really only care
-- about people that are MC'ed close to you anyway.
function BigWigsSkeram:CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE(msg)
	local _,_, player, type = string.find(msg, L["mcplayer"])
	if player and type then
		if player == L["mcyou"] and type == L["mcare"] then
			player = UnitName("player")
		end
		if self.db.profile.mc then
			self:TriggerEvent("BigWigs_Message", string.format(L["mcplayerwarn"], player), "Important")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["mcbar"], player), 20, "Interface\\Icons\\Spell_Shadow_ShadowWordDominate")
		end
	end
end


function BigWigsSkeram:CHAT_MSG_MONSTER_YELL(msg)
    if string.find(arg1, L["win"]) then 
        self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s has been defeated"], self:ToString()), "Bosskill", nil, "Victory")
        BigWigs:Flawless()
	self.core:ToggleModuleActive(self, false)
    elseif string.find(arg1, L["pull1"]) or string.find(arg1, L["pull2"]) or string.find(arg1, L["pull3"]) then
        self:SkeramPull()
          end
end

function BigWigsSkeram:SkeramPull()
    if not skeramstarted then
	  skeramstarted = true
          self:SkeramStart()
          end
end

function BigWigsSkeram:SkeramStart()
	self:ScheduleEvent("bwskeramstele", self.STele, 15, self)
	self:ScheduleEvent("BigWigs_Message", 10, L["telewarn"], "Urgent", true, "Alarm")
	self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 15, "Interface\\Icons\\Spell_Arcane_Blink")
	self:ScheduleEvent("BigWigs_Message", 30, L["telewarn"], "Urgent", true, "Alarm")
	self:ScheduleEvent("BigWigs_StartBar", 15, self, L["bartext"], 22.5, "Interface\\Icons\\Spell_Arcane_Blink")
end

function BigWigsSkeram:STele()
                self:ScheduleRepeatingEvent("bwskeramstelebar", self.STelebar, 22.5, self)
end

function BigWigsSkeram:STelebar()
		self:ScheduleEvent("BigWigs_Message", 17, L["telewarn"], "Urgent", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 22.5, "Interface\\Icons\\Spell_Arcane_Blink")
end

function BigWigsSkeram:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["aetrigger"] and self.db.profile.ae then
		self:TriggerEvent("BigWigs_Message", L["aewarn"], "Urgent")
	elseif msg == L["mctrigger"] and self.db.profile.mc then
		self:TriggerEvent("BigWigs_Message", L["mcwarn"], "Urgent")
	elseif msg == L["splittrigger"] and self.db.profile.split then
		self:TriggerEvent("BigWigs_Message", L["splitwarn"], "Important")
	end
end


