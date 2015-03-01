if UnitClass("player") == "Warrior" then
-- Warrior HUD by LYQ
WHUD_VERSION = 1.7
WHUD_DEFAULT_SCALE = 1.5
WHUD_DEFAULT_ICON_WIDTH = 100
WHUD_DEFAULT_ICON_HEIGHT = 100
	-- INIT some vars
	local WHUD_ALERT_TIME = 0
	local WHUD_SALVATION_WARN = false
	local _G = getfenv(0)

function WHUD_INIT()
		-- init default settings if needed
		if WHUD_VARS == nil then
			WHUD_VARS = {
				VERSION = WHUD_VERSION, -- need this var for future updates
				Ragebar = {
					enabled = true,
					X = 0,
					Y = -100,
					scale = WHUD_DEFAULT_SCALE,
					strata = "HIGH",
					transparency = 1,
					fontsize = 25,
				},
				Cooldowns = {
					enabled = true,
					X = 0,
					Y = -50,
					scale = WHUD_DEFAULT_SCALE,
					strata = "HIGH",
					transparency = 1,
					flashtime = 1.5,
					fading = true,
					fadetime = 1.5,
					trinkets = true,
				},
				Overpower = {
					enabled = true,
					X = 0,
					Y = 50,
					scale = WHUD_DEFAULT_SCALE,
					strata = "HIGH",
					MSG = "USE OVERPOWER NOW",
					mode = "text",
				},
				Alerts = {
					X = 0,
					Y = 0,
					scale = WHUD_DEFAULT_SCALE,
					strata = "HIGH",
					fontsize = 35,
					-- MODE
					["Battleshout"] = true,
					["Weightstone"] = true,
					["Salvation"] = true,
				},
			}
		else
			if WHUD_VARS.VERSION < WHUD_VERSION then
				-- the user just used a new version, use this section if there are changes in the saved Variables eg. a new variable
				if WHUD_VARS.VERSION < 1.5 then
					if WHUD_VARS.Overpower.mode == nil then
						WHUD_VARS.Overpower.mode = "text"
					end
				end
				if WHUD_VARS.VERSION < 1.6 then
					if WHUD_VARS.Cooldowns.trinkets == nil then
						WHUD_VARS.Cooldowns.trinkets = true
					end
					WHUD_VARS.VERSION = WHUD_VERSION
				end
				if WHUD_VARS.VERSION < 1.7 then
					if WHUD_VARS.Cooldowns.fadeout then
						WHUD_VARS.Cooldowns.fadeout = nil
					end
					if WHUD_VARS.Cooldowns.fading == nil then
						WHUD_VARS.Cooldowns.fading = true
						WHUD_VARS.Cooldowns.fadetime = 1.5
					end
					if WHUD_VARS.Alerts == nil then
						WHUD_VARS.Alerts = {
							X = 0,
							Y = 0,
							scale = WHUD_DEFAULT_SCALE,
							strata = "HIGH",
							fontsize = 35,
							["Battleshout"] = true,
							["Weightstone"] = true,
							["Salvation"] = true,
						}
					end
				end
			end
		end
			-- as of 1.1 hotfix, I think the function of those two tables can be simplified
		WHUD_IMPORTANTSPELLS = { 
			"Bloodthirst",
			"Whirlwind",
			"Intercept",
			"Pummel",
			"Charge",
			"Overpower",
			"Disarm",
			"Mocking Blow",
			"Bloodrage",
			"Revenge",
			"Shield Bash",
			"Retaliation",
			"Shield Wall",
			"Recklessness",
			"Death Wish",
			"Shield Block",
			"Berserker Rage",
			"Intimidating Shout",
			"Challenging Shout",
			"Taunt",
			"Mortal Strike",
			"Shield Slam",
			-- RACIALS
			"War Stomp",
			"Blood Fury",
			"Will of the Forsaken",
			"Berserking",
			"Escape Artist",
			"Shadowmeld",
			"Stone Form",
			-- ALERT
			"Battle Shout",
		}
		WHUD_SPELLINFO = {
			["Bloodthirst"] = {1,0,0},
			["Whirlwind"] = {1,0,0},
			["Intercept"] = {1,0,0},
			["Pummel"] = {1,0,0},
			["Charge"] = {1,0,0},
			["Overpower"] = {1,0,0},
			["Disarm"] = {1,0,0},
			["Mocking Blow"] = {1,0,0},
			["Bloodrage"] = {1,0,0},
			["Revenge"] = {1,0,0},
			["Shield Bash"] = {1,0,0},
			["Retaliation"] = {1,0,0},
			["Shield Wall"] = {1,0,0},
			["Recklessness"] = {1,0,0},
			["Death Wish"] = {1,0,0},
			["Shield Block"] = {1,0,0},
			["Berserker Rage"] = {1,0,0},
			["Intimidating Shout"] = {1,0,0},
			["Challenging Shout"] = {1,0,0},
			["Taunt"] = {1,0,0},
			["Mortal Strike"] = {1,0,0},
			["Shield Slam"] = {1,0,0},
			-- RACIALS
			["War Stomp"] = {1,0,0},
			["Blood Fury"] = {1,0,0},
			["Will of the Forsaken"] = {1,0,0},
			["Berserking"] = {1,0,0},
			["Escape Artist"] = {1,0,0},
			["Shadowmeld"] = {1,0,0},
			["Stone Form"] = {1,0,0},
			["Perception"] = {1,0,0},
			-- TRINKETS
			["Trinket1"] = {0,0,0},
			["Trinket2"] = {0,0,0},
			-- ALERT
			["Battle Shout"] = {1,0,0},
		}
		WHUD_UPDATE_SPELLINFO() -- should INIT the correct actionslots and overwrite the default value '1'
		
-- CREATING THE HUD ELEMENTS NOW --
	WHUD_CREATEFRAMES()
		-- init the mode
		if WHUD_VARS.Overpower.mode == "text" then
			WHUD_OP_ICON:Hide()
			WHUD_OP_TIMER3:Hide()
		else
			WHUD_OP_TEXT:Hide()
			WHUD_OP_LEFT:Hide()
			WHUD_OP_RIGHT:Hide()
			WHUD_OP_TIMER1:Hide()
			WHUD_OP_TIMER2:Hide()
		end
		-- finished loading
		WHUD_LOADED = true
		DEFAULT_CHAT_FRAME:AddMessage("|cff8f4108WarriorHUD|r v"..WHUD_VERSION.." loaded.");
end

function WHUD_CREATEFRAMES()
	-- RAGE BAR --
		CreateFrame("Frame", "WHUD_RBAR", UIParent)
		WHUD_RBAR:SetHeight(500)
		WHUD_RBAR:SetWidth(500)
		WHUD_RBAR:EnableMouse(false)
		WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
		WHUD_RBAR:SetScale(WHUD_VARS.Ragebar.scale)
		WHUD_RBAR:SetAlpha(WHUD_VARS.Ragebar.transparency)
		WHUD_RBAR:SetPoint("CENTER", UIParent, WHUD_VARS.Ragebar.X ,WHUD_VARS.Ragebar.Y)
		WHUD_RBAR:Show()
		-- create the texture now
        WHUD_RBAR:CreateTexture("WHUD_RAGE", "ARTWORK")
        WHUD_RAGE:SetTexture("Interface\\AddOns\\WarriorHUD\\texture.tga")
        WHUD_RAGE:SetBlendMode("ADD")
        WHUD_RAGE:SetWidth(256)
        WHUD_RAGE:SetHeight(64) 
        WHUD_RAGE:SetPoint("CENTER",WHUD_RBAR,0,0)
		WHUD_RAGE:SetVertexColor(1,0,0,0) -- just a default value, red but hidden
		-- create its text display
		WHUD_RAGE_TEXT = WHUD_RBAR:CreateFontString(nil, "OVERLAY")
		WHUD_RAGE_TEXT:SetParent(WHUD_RBAR)
		WHUD_RAGE_TEXT:SetFont("Interface\\AddOns\\WarriorHUD\\Fishfingers.ttf", WHUD_VARS.Ragebar.fontsize,"THINOUTLINE")
		WHUD_RAGE_TEXT:SetPoint("CENTER",WHUD_RAGE,0,-50)
		WHUD_RAGE_TEXT:SetText("")
		WHUD_RAGE_TEXT:SetJustifyH("CENTER")
			WHUD_RAGE_EDIT = 0 -- var for the edit mode
		
	-- COOLDOWN BAR --
		-- create the anchor frame
		CreateFrame("Frame", "WHUD_CDBAR", UIParent)
		WHUD_CDBAR:SetHeight(500)
		WHUD_CDBAR:SetWidth(500)
		WHUD_CDBAR:EnableMouse(false)
		WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
		WHUD_CDBAR:SetScale(WHUD_VARS.Cooldowns.scale)
		WHUD_CDBAR:SetAlpha(WHUD_VARS.Cooldowns.transparency)
		WHUD_CDBAR:SetPoint("CENTER", "UIParent", WHUD_VARS.Cooldowns.X ,WHUD_VARS.Cooldowns.Y)
		WHUD_CDBAR:Show()
		-- create the icons now
		for i=1,6 do
			CreateFrame("Frame", "WHUD_CDBAR"..i, WHUD_CDBAR)
			_G["WHUD_CDBAR"..i]:SetHeight(35)
			_G["WHUD_CDBAR"..i]:SetWidth(35)
			_G["WHUD_CDBAR"..i]:CreateTexture("WHUD_CD"..i, "ARTWORK")
			_G["WHUD_CD"..i]:SetTexture("")
			_G["WHUD_CD"..i]:SetBlendMode("BLEND")
			_G["WHUD_CD"..i]:SetWidth(35)
			_G["WHUD_CD"..i]:SetHeight(35)
			_G["WHUD_CD"..i]:SetPoint("CENTER","WHUD_CDBAR"..i,0,0)
			-- INIT vars
			_G["WHUD_CD"..i.."_USED"] = ""
			_G["WHUD_CD"..i.."_TIME"] = 0
			_G["WHUD_CD"..i.."_CLOCK"] = false
			if WHUD_VARS.Cooldowns.fading then
				_G["WHUD_CD"..i.."_LAST"] = 0
			else
				_G["WHUD_CD"..i.."_LAST"] = WHUD_VARS.Cooldowns.transparency 
			end
		end
		-- position them correctly
		WHUD_CDBAR1:SetPoint("CENTER",WHUD_CDBAR,0,0)
		WHUD_CDBAR2:SetPoint("CENTER",WHUD_CDBAR1,-38,0)
		WHUD_CDBAR3:SetPoint("CENTER",WHUD_CDBAR1,38,0)
		WHUD_CDBAR4:SetPoint("CENTER",WHUD_CDBAR1,0,38)
		WHUD_CDBAR5:SetPoint("CENTER",WHUD_CDBAR4,-38,0)
		WHUD_CDBAR6:SetPoint("CENTER",WHUD_CDBAR4,38,0)
		
	-- OVERPOWER ALERT BAR --
		CreateFrame("Frame","WHUD_OP", UIParent)
		WHUD_OP:SetHeight(500)
		WHUD_OP:SetWidth(500)
		WHUD_OP:EnableMouse(false)
		WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
		WHUD_OP:SetScale(WHUD_VARS.Overpower.scale)
		WHUD_OP:SetPoint("CENTER", "UIParent",WHUD_VARS.Overpower.X,WHUD_VARS.Overpower.Y)
		WHUD_OP:Show()
		-- text mode
			-- overpower text
			WHUD_OP_TEXT = WHUD_OP:CreateFontString(nil, "OVERLAY")
			WHUD_OP_TEXT:SetParent(WHUD_OP)
			WHUD_OP_TEXT:SetFont("Interface\\AddOns\\WarriorHUD\\Fishfingers.ttf", 35,"THINOUTLINE")
			WHUD_OP_TEXT:SetPoint("CENTER",WHUD_OP,0,0)
			WHUD_OP_TEXT:SetText(WHUD_VARS.Overpower.MSG)
			WHUD_OP_TEXT:SetJustifyH("CENTER")
			-- overpower icons
			WHUD_OP:CreateTexture("WHUD_OP_LEFT", "ARTWORK")
			WHUD_OP_LEFT:SetPoint("LEFT",WHUD_OP_TEXT,-(WHUD_OP_LEFT:GetWidth()+2),2)
				WHUD_OP_LEFT:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
				WHUD_OP_LEFT:SetWidth(25)
				WHUD_OP_LEFT:SetHeight(25) 
			WHUD_OP:CreateTexture("WHUD_OP_RIGHT", "ARTWORK")
			WHUD_OP_RIGHT:SetPoint("RIGHT",WHUD_OP_TEXT,(WHUD_OP_RIGHT:GetWidth()+2),2)
				WHUD_OP_RIGHT:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
				WHUD_OP_RIGHT:SetWidth(25)
				WHUD_OP_RIGHT:SetHeight(25) 
		-- icon mode
			WHUD_OP:CreateTexture("WHUD_OP_ICON", "ARTWORK")
			WHUD_OP_ICON:SetPoint("CENTER",WHUD_OP)
				WHUD_OP_ICON:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
				WHUD_OP_ICON:SetWidth(65)
				WHUD_OP_ICON:SetHeight(65) 
		WHUD_OP_TIME = 0 -- var to check how long op is usable
		-- overpower timer
			-- timer for text mode
			for i=1,3 do
				WHUD_OP:CreateFontString("WHUD_OP_TIMER"..i, "OVERLAY")
				getglobal("WHUD_OP_TIMER"..i):SetParent(WHUD_OP)
				getglobal("WHUD_OP_TIMER"..i):SetFont("Interface\\AddOns\\WarriorHUD\\Fishfingers.ttf", 25,"THINOUTLINE")
				getglobal("WHUD_OP_TIMER"..i):SetText("")
				getglobal("WHUD_OP_TIMER"..i):SetJustifyH("CENTER")
				getglobal("WHUD_OP_TIMER"..i):SetVertexColor(1,1,0,0.9)
			end
			WHUD_OP_TIMER1:SetPoint("CENTER",WHUD_OP_LEFT,0,0)
			WHUD_OP_TIMER2:SetPoint("CENTER",WHUD_OP_RIGHT,0,0)
			-- timer for icon mode
			WHUD_OP_TIMER3:SetPoint("CENTER",WHUD_OP_ICON,0,0)
			WHUD_OP_TIMER3:SetFont("Interface\\AddOns\\WarriorHUD\\Fishfingers.ttf", 40,"OUTLINE")
	-- MISC ALERT --
		CreateFrame("Frame","WHUD_ALERT", UIParent)
		WHUD_ALERT:SetHeight(500)
		WHUD_ALERT:SetWidth(500)
		WHUD_ALERT:EnableMouse(false)
		WHUD_ALERT:SetFrameStrata(WHUD_VARS.Alerts.strata)
		WHUD_ALERT:SetScale(WHUD_VARS.Alerts.scale)
		WHUD_ALERT:SetPoint("CENTER", "UIParent",WHUD_VARS.Alerts.X,WHUD_VARS.Alerts.Y)
		WHUD_ALERT:Show()
		-- text
			WHUD_ALERT_TEXT = WHUD_ALERT:CreateFontString(nil, "OVERLAY")
			WHUD_ALERT_TEXT:SetParent(WHUD_ALERT)
			WHUD_ALERT_TEXT:SetFont("Interface\\AddOns\\WarriorHUD\\Fishfingers.ttf", WHUD_VARS.Alerts.fontsize,"THINOUTLINE")
			WHUD_ALERT_TEXT:SetPoint("CENTER",WHUD_ALERT,0,0)
			WHUD_ALERT_TEXT:SetText("")
			WHUD_ALERT_TEXT:SetJustifyH("CENTER")
end

function WHUD_UPDATE_SPELLINFO()
	-- updating the spellinfos, if the actionbar has been modified
	for i=1,100 do
		local name = GetSpellName(i,"player")
		if name == nil then return
		else
			for check=1,table.getn(WHUD_IMPORTANTSPELLS)do
				if name == WHUD_IMPORTANTSPELLS[check] then
										-- slotID,startTime,endTime
					WHUD_SPELLINFO[name] = {i,0,0};
				end
			end 
		end 
	end
end

	-- EVENT HANDLER --
CreateFrame("Frame", "WHUD_CORE")
	WHUD_CORE:RegisterEvent("PLAYER_ENTERING_WORLD")
WHUD_CORE:SetScript('OnEvent', function() 
	if event == "PLAYER_ENTERING_WORLD" then
		WHUD_INIT()
		WHUD_CORE:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "UNIT_RAGE" then
	-- RAGE CHANGED, UPDATE THE RAGEBAR
		local rage = UnitMana("player")
		if UnitIsDeadOrGhost("player") then rage=0 end
		if rage > 0 then WHUD_RAGE_TEXT:SetText(rage) else WHUD_RAGE_TEXT:SetText("") end
		if rage == 0 then						WHUD_RAGE:SetVertexColor(0,0,0,0) 			WHUD_RAGE_TEXT:SetTextColor(1,1,1)
		elseif rage > 0 and rage < 10 then 		WHUD_RAGE:SetVertexColor(1,0,0,0.3) 	WHUD_RAGE_TEXT:SetTextColor(0.5,0.5,0.5)
		elseif rage > 10 and rage < 25 then		WHUD_RAGE:SetVertexColor(1,0,0,0.4)		WHUD_RAGE_TEXT:SetTextColor(1,1,0.38)
		elseif rage > 25 and rage < 30 then		WHUD_RAGE:SetVertexColor(1,1,0,0.5)			WHUD_RAGE_TEXT:SetTextColor(1,1,0)
		elseif rage > 30 and rage < 60 then		WHUD_RAGE:SetVertexColor(1,1,0,1)		WHUD_RAGE_TEXT:SetTextColor(1,0.66,0)
		elseif rage > 60 and rage < 80 then 	WHUD_RAGE:SetVertexColor(0,1,0,1)	WHUD_RAGE_TEXT:SetTextColor(1,0.34,0.34)
		elseif rage > 80 and rage <= 100 then 	WHUD_RAGE:SetVertexColor(0,1,0,1)			WHUD_RAGE_TEXT:SetTextColor(1,0,0)		
		end
		if WHUD_RAGE_EDIT > 0 and WHUD_RAGE_EDIT <= GetTime() then
			-- edit mode is on, make it visible for 5sec
			WHUD_RAGE:SetVertexColor(1,0,0,0.5)			
			WHUD_RAGE_TEXT:SetTextColor(1,0,0)
			WHUD_RAGE_TEXT:SetText("1337")
		elseif WHUD_RAGE_EDIT > 0 then
			-- reset it
			WHUD_RAGE:SetVertexColor(1,0,0,0)			
			WHUD_RAGE_TEXT:SetTextColor(1,0,0)
			WHUD_RAGE_TEXT:SetText("")
		end
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		WHUD_UPDATE_SPELLINFO()
	elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" or event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" or event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
	-- CREDITS TO ANARON (EHAUGW) @ Feenix (wow-one.com)
		if (GetUnitName("target")) then
			if (arg1 == string.format(VSDODGESELFOTHER,GetUnitName("target"))) or (string.find(arg1,"Your") and string.find(arg1,"was dodged by "..UnitName("target"))) then
				WHUD_OP_TIME = GetTime() + 4
			elseif string.find(arg1,"Your Overpower") then
				WHUD_OP_TIME = 0
			end
		end
	elseif event == "PLAYER_AURAS_CHANGED" then
		-- SALVATION ALERT
		local salvationfound = false
		for i=0,16 do
			local texture = GetPlayerBuffTexture(GetPlayerBuff(i))
			if texture ~= nil then
				if texture == ("Interface\\Icons\\Spell_Holy_SealOfSalvation") or texture == ("Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation") then
					salvationfound = true
				end
			end
		end
		if salvationfound and not WHUD_SALVATION_WARN then
			WHUD_ALERT_TEXT:SetText("! YOU RECEIVED SALVATION !")
			WHUD_ALERT_TIME = GetTime()
			WHUD_SALVATION_WARN = true
		elseif not salvationfound and WHUD_SALVATION_WARN then
			WHUD_SALVATION_WARN = false
		end
	end
end);

WHUD_CORE:SetScript('OnUpdate', function()
	if WHUD_LOADED then
		-- INIT SOME SHIT ONE MORE TIME
		if WHUD_INIT_ONCE == nil then
			WHUD_OP_LEFT:SetPoint("LEFT",WHUD_OP_TEXT,-(WHUD_OP_LEFT:GetWidth()+2),2)
			WHUD_OP_RIGHT:SetPoint("RIGHT",WHUD_OP_TEXT,(WHUD_OP_RIGHT:GetWidth()+2),2)	
		-- REGISTER THE NEEDED EVENTS --
			if WHUD_VARS.Ragebar.enabled then 
				WHUD_CORE:RegisterEvent("UNIT_RAGE")
			end
			if WHUD_VARS.Cooldowns.enabled then 
				WHUD_CORE:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
			end
			if WHUD_VARS.Overpower.enabled then
				WHUD_CORE:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
				WHUD_CORE:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
				WHUD_CORE:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
			end
			if WHUD_VARS.Alerts["Salvation"] then
				WHUD_CORE:RegisterEvent("PLAYER_AURAS_CHANGED")
			end
			WHUD_INIT_ONCE = true
		end
		-- Misc Alert code
			-- clear the textelement if needed
			if WHUD_ALERT_TIME+2 <= GetTime() then WHUD_ALERT_TEXT:SetText("") end
			-- Battleshout announce
			if WHUD_VARS.Alerts["Battleshout"] then
				for i=0,16 do
					local buff = GetPlayerBuff(i)
					if GetPlayerBuffTexture(buff) == GetSpellTexture(WHUD_SPELLINFO["Battle Shout"][1],"BOOKTYPE_SPELL") then
						if GetPlayerBuffTimeLeft(buff) <= 10 and WHUD_BATTLESHOUT_WARN then
							-- 10seconds battle shout warning
							WHUD_ALERT_TEXT:SetText("BATTLESHOUT IS ABOUT TO RUN OUT")
							WHUD_ALERT_TIME = GetTime()
							WHUD_BATTLESHOUT_WARN = false
						elseif GetPlayerBuffTimeLeft(buff) > 10 then
							WHUD_BATTLESHOUT_WARN = true
						elseif GetPlayerBuffTimeLeft(buff) <= 1 then
							WHUD_ALERT_TEXT:SetText("! BATTLESHOUT RAN OUT !")
							WHUD_ALERT_TIME = GetTime()
						end
					end
				end
				end
			if WHUD_VARS.Alerts["Weightstone"] then
				if WHUD_LASTALERT == nil then WHUD_LASTALERT = GetTime() end
				if WHUD_RUNNINGOUT == nil then WHUD_RUNNINGOUT = 0 end
				if WHUD_RANOUT == nil then WHUD_RANOUT = 0 end
				if WHUD_WEIGHTSTONE_WARN == nil then WHUD_WEIGHTSTONE_WARN = 0 end
				local mainhand, mhDur, _, offhand, ohDur = GetWeaponEnchantInfo()
				if mainhand then
					if mhDur > 0 then mhDur = mhDur / 1000 end
					WHUD_MAINHAND_ACTIVE = true
					if mhDur < 600 and WHUD_MAINHAND_WARN then
						if WHUD_RUNNINGOUT == 2 then WHUD_RUNNINGOUT = 3 else WHUD_RUNNINGOUT = 1 end
						WHUD_MAINHAND_WARN = false
					elseif mhDur > 600 then
						WHUD_MAINHAND_WARN = true
					end
				elseif WHUD_MAINHAND_ACTIVE then
					if WHUD_RANOUT == 2 then WHUD_RANOUT = 3 else WHUD_RANOUT = 1 end
					WHUD_MAINHAND_ACTIVE = false
				end
				if offhand then
					if ohDur > 0 then ohDur = ohDur / 1000 end
					WHUD_OFFHAND_ACTIVE = true
					if ohDur < 600 and WHUD_OFFHAND_WARN then
						if WHUD_RUNNINGOUT == 1 then WHUD_RUNNINGOUT = 3 else WHUD_RUNNINGOUT = 2 end
						WHUD_OFFHAND_WARN = false
					elseif ohDur > 600 then
						WHUD_OFFHAND_WARN = true
					end
				elseif WHUD_OFFHAND_ACTIVE then
					if WHUD_RANOUT == 1 then WHUD_RANOUT = 3 else WHUD_RANOUT = 2 end
					WHUD_OFFHAND_ACTIVE = false
				end
				if WHUD_LASTALERT+120 <= GetTime() then
					-- wait 2mins before displaying, in case both weightstones are on but within <2min difference
					if WHUD_RUNNINGOUT > 0 then
						-- display shit here
						if WHUD_RUNNINGOUT == 3 then
							WHUD_ALERT_TEXT:SetText("BOTH WEIGHTSTONES ARE RUNNING OUT")
						elseif WHUD_RUNNINGOUT == 2 then
							WHUD_ALERT_TEXT:SetText("OFFHAND WEIGHTSTONE IS RUNNING OUT")
						elseif WHUD_RUNNINGOUT == 1 then
							WHUD_ALERT_TEXT:SetText("MAINHAND WEIGHTSTONE IS RUNNING OUT")
						end
						WHUD_ALERT_TIME = GetTime()
						WHUD_WEIGHTSTONE_WARN = GetTime()
						WHUD_RUNNINGOUT = 0
					end
					WHUD_LASTALERT = GetTime()
				elseif WHUD_WEIGHTSTONE_WARN+480 <= GetTime() then
					-- 8mins after the last alert
					if WHUD_RANOUT > 0 then
						if WHUD_RANOUT == 3 then
							WHUD_ALERT_TEXT:SetText("!! BOTH WEIGHTSTONES RAN OUT !!")
						elseif WHUD_RANOUT == 2 then
							WHUD_ALERT_TEXT:SetText("! OFFHAND WEIGHTSTONE RAN OUT !")
						elseif WHUD_RANOUT == 1 then
							WHUD_ALERT_TEXT:SetText("! MAINHAND WEIGHTSTONE RAN OUT !")
						end
						WHUD_ALERT_TIME = GetTime()
						WHUD_WEIGHTSTONE_WARN = 0
						WHUD_RANOUT = 0
						WHUD_LASTALERT = GetTime()
					end
				end
			end
		-- OVERPOWER ALERT
		if WHUD_VARS.Overpower.enabled then
			if WHUD_OP_TIME > GetTime() then
				WHUD_OP:Show()
				-- update timer
				local timeleft = math.floor(WHUD_OP_TIME - GetTime())
				if WHUD_VARS.Overpower.mode == "text" then
					WHUD_OP_TIMER1:SetText(timeleft)
					WHUD_OP_TIMER2:SetText(timeleft)
					if timeleft <= 1 then
						WHUD_OP_TIMER1:SetVertexColor(1,0,0,0.9)
						WHUD_OP_TIMER2:SetVertexColor(1,0,0,0.9)
					else
						WHUD_OP_TIMER1:SetVertexColor(1,1,0,0.9)
						WHUD_OP_TIMER2:SetVertexColor(1,1,0,0.9)
					end
				else
					WHUD_OP_TIMER3:SetText(timeleft)
					if timeleft <= 1 then
						WHUD_OP_TIMER3:SetVertexColor(1,0,0,0.9)
					else
						WHUD_OP_TIMER3:SetVertexColor(1,1,0,0.9)
					end
				end
			else
				WHUD_OP:Hide()
			end
		end
		if WHUD_VARS.Cooldowns.enabled then
			-- CLEARING THE COOLDOWN ICON SLOTS IF NEEDED
			for i=1,6 do
				if _G["WHUD_CD"..i.."_USED"] ~= "" and _G["WHUD_CD"..i.."_TIME"] > 0 then
					if WHUD_VARS.Cooldowns.fading and WHUD_SPELLINFO[_G["WHUD_CD"..i.."_USED"]][3] <= GetTime() then
						local value = (1-(((_G["WHUD_CD"..i.."_TIME"]+WHUD_VARS.Cooldowns.fadetime) - GetTime())/WHUD_VARS.Cooldowns.fadetime))* WHUD_VARS.Cooldowns.transparency
						if value > _G["WHUD_CD"..i.."_LAST"] and value > 0 and value <= 1 then 
							_G["WHUD_CD"..i.."_LAST"] = value
							_G["WHUD_CD"..i]:SetAlpha(value) 
							--if not _G["WHUD_CD"..i.."_CLOCK"] then WHUD_CLOCK(_G["WHUD_CD"..i]) end
						end
					end
					if _G["WHUD_CD"..i.."_TIME"]+WHUD_VARS.Cooldowns.flashtime <= GetTime() then
						WHUD_StartToShine(_G["WHUD_CD"..i])
						if WHUD_VARS.Cooldowns.fading and _G["WHUD_CD"..i.."_TIME"]+WHUD_VARS.Cooldowns.flashtime+1 <= GetTime() then
							return
						end
						WHUD_SPELLINFO[_G["WHUD_CD"..i.."_USED"]][2] = 0
						WHUD_SPELLINFO[_G["WHUD_CD"..i.."_USED"]][3] = 0
						_G["WHUD_CD"..i.."_USED"] = ""
						_G["WHUD_CD"..i.."_TIME"] = 0
						_G["WHUD_CD"..i.."_CLOCK"] = false
						_G["WHUD_CD"..i]:SetTexture("")
						if WHUD_VARS.Cooldowns.fading then _G["WHUD_CD"..i.."_LAST"] = 0 else _G["WHUD_CD"..i.."_LAST"] = WHUD_VARS.Cooldowns.transparency end
					end
				end
			end
			-- UPDATING SPELL&RACIAL COOLDOWN INFO
				for impspells=1,table.getn(WHUD_IMPORTANTSPELLS) do
					local name = WHUD_IMPORTANTSPELLS[impspells]
					local id = WHUD_SPELLINFO[name][1]
					local startTime, duration = GetSpellCooldown(id,"player")
					local endTime
					if WHUD_SPELLINFO[name][2] == 0 or WHUD_SPELLINFO[name][3] == 0 then
						if startTime > 0 and duration > 0 then
							endTime = startTime + duration
							if endTime-GetTime() > 1.5 then -- this prevents the global cooldown to fuck shit up
								if WHUD_VARS.Cooldowns.fading then
									WHUD_SPELLINFO[name][2] = startTime
									WHUD_SPELLINFO[name][3] = endTime - WHUD_VARS.Cooldowns.fadetime
								else
									WHUD_SPELLINFO[name][2] = startTime
									WHUD_SPELLINFO[name][3] = endTime 
								end
							end
						end
					else
						if WHUD_VARS.Cooldowns.fading then
							startTime = WHUD_SPELLINFO[name][2]
							endTime = WHUD_SPELLINFO[name][3]
						else
							startTime = WHUD_SPELLINFO[name][2]
							endTime = WHUD_SPELLINFO[name][3]
						end
					end
					
					if startTime > 0 and endTime <= GetTime() then
				-- DISPLAYING THE SPELL&RACIAL COOLDOWNS HERE
						for i=1,6 do
							if _G["WHUD_CD"..i.."_USED"] == name then	-- checking if the spell is already being displayed
								return
							end
							if name == "Revenge" then	-- otherwise those spells would appear twice at a time
								if _G["WHUD_CD"..i.."_USED"] == "Overpower" then
									return
								end
							elseif name == "Overpower" then
								if _G["WHUD_CD"..i.."_USED"] == "Revenge" then
									return
								end
							elseif name == "Pummel" then
								if _G["WHUD_CD"..i.."_USED"] == "Shield Bash" then
									return
								end
							elseif name == "Shield Bash" then
								if _G["WHUD_CD"..i.."_USED"] == "Pummel" then
									return
								end
							end 
						end 
						for i=1,6 do
							if _G["WHUD_CD"..i.."_USED"] == "" then
								local _, _, defstance = GetShapeshiftFormInfo(2)
								if name == "Revenge" or name == "Overpower" then
									if defstance then 
										_G["WHUD_CD"..i]:SetTexture(GetSpellTexture(WHUD_SPELLINFO["Revenge"][1],"BOOKTYPE_SPELL"))
									else
										_G["WHUD_CD"..i]:SetTexture(GetSpellTexture(WHUD_SPELLINFO["Overpower"][1],"BOOKTYPE_SPELL"))
									end
								elseif name == "Pummel" or name == "Shield Bash" then
									if defstance then 
										_G["WHUD_CD"..i]:SetTexture(GetSpellTexture(WHUD_SPELLINFO["Shield Bash"][1],"BOOKTYPE_SPELL"))
									else
										_G["WHUD_CD"..i]:SetTexture(GetSpellTexture(WHUD_SPELLINFO["Pummel"][1],"BOOKTYPE_SPELL"))
									end
								else
									_G["WHUD_CD"..i]:SetTexture(GetSpellTexture(id,"BOOKTYPE_SPELL"))
								end
								_G["WHUD_CD"..i.."_USED"] = name
								_G["WHUD_CD"..i.."_TIME"] = GetTime()
								if WHUD_VARS.Cooldowns.fading then _G["WHUD_CD"..i]:SetAlpha(0) else _G["WHUD_CD"..i]:SetAlpha(WHUD_VARS.Cooldowns.transparency) end
								return
							end
						end
					end
				end
			if WHUD_VARS.Cooldowns.trinkets then
			-- UPDATING TRINKET COOLDOWN INFO
				if GetInventoryItemCooldown("player",13) > 0 and WHUD_SPELLINFO["Trinket1"][3] == 0 then
					local tr1start, tr1dur = GetInventoryItemCooldown("player",13)
					local tr1end = tr1start + tr1dur
					if WHUD_VARS.Cooldowns.fading then tr1end = tr1end - WHUD_VARS.Cooldowns.fadetime  end
					if tr1start > 0 and tr1dur > 0 then -- TRNKET 1 is on Cooldown
						WHUD_SPELLINFO["Trinket1"] = {0,tr1start,tr1end}
					end
				end
				if GetInventoryItemCooldown("player",14) > 0 and WHUD_SPELLINFO["Trinket2"][3] == 0 then
					local tr2start, tr2dur = GetInventoryItemCooldown("player",14)
					local tr2end = tr2start + tr2dur
					if WHUD_VARS.Cooldowns.fading then tr2end = tr2end - WHUD_VARS.Cooldowns.fadetime  end
					if tr2start > 0 and tr2dur > 0 then	-- TRINKET 2 is on Cooldown
						WHUD_SPELLINFO["Trinket2"] = {0,tr2start,tr2end}
					end
				end
			-- INIT TRINKET DATA TO CHECK
				for i=1,2 do
					local name,slot
					if i == 1 then
						name = "Trinket1"
						slot = 13
					else
						name = "Trinket2"
						slot = 14
					end
					if WHUD_SPELLINFO[name][3] > 0 and WHUD_SPELLINFO[name][3] <= GetTime() then
				-- DISPLAYING TRINKET COOLDOWNS HERE
						for y=1,6 do
							if _G["WHUD_CD"..y.."_USED"] == name then
								return
							end
						end
						for x=1,6 do
							if _G["WHUD_CD"..x.."_USED"] == "" then
								_G["WHUD_CD"..x]:SetTexture(GetInventoryItemTexture("player",slot))
								_G["WHUD_CD"..x.."_USED"] = name
								_G["WHUD_CD"..x.."_TIME"] = GetTime()
								if WHUD_VARS.Cooldowns.fading then _G["WHUD_CD"..x]:SetAlpha(0) else _G["WHUD_CD"..x]:SetAlpha(WHUD_VARS.Cooldowns.transparency) end
								break
							end
						end
					end
				end
			end
		end
	end
end);
	--
function WHUD_CDedit()
	local name = "Bloodrage"
	for i=1,6 do
		_G["WHUD_CD"..i]:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
		_G["WHUD_CD"..i.."_USED"] = name
		_G["WHUD_CD"..i.."_TIME"] = GetTime()
		if WHUD_VARS.Cooldowns.fading then _G["WHUD_CD"..i]:SetAlpha(0) else _G["WHUD_CD"..i]:SetAlpha(WHUD_VARS.Cooldowns.transparency) end
	end
end
	-- COOLDOWN CLOCK EFFECT --
function WHUD_CLOCK(Frame)
	local clockFrame = CreateFrame("Model", Frame:GetParent():GetName().."_CLOCK", Frame:GetParent(), "CooldownFrameTemplate")
    CooldownFrame_SetTimer(clockFrame, GetTime(), WHUD_VARS.Cooldowns.fadetime, 1)
end
	--
	
	-- SHINE CODE FROM OmniCC --
local function Shine_Update()
	local shine = this.shine;
	local alpha = shine:GetAlpha();
	shine:SetAlpha(alpha * 0.95);
	
	if alpha < 0.1 then
		this:Hide();
	else
		shine:SetHeight(alpha * this:GetHeight() * 6);
		shine:SetWidth(alpha * this:GetWidth() * 6);
	end
end
local function CreateShineFrame(parent)
	local shineFrame = CreateFrame("Frame", nil, parent);
	shineFrame:SetAllPoints(parent);
	
	local shine = shineFrame:CreateTexture(nil, "OVERLAY");
	shine:SetTexture("Interface\\Cooldown\\star4");
	shine:SetPoint("CENTER", shineFrame, "CENTER");
	shine:SetBlendMode("ADD");
	shineFrame.shine = shine;
	
	shineFrame:Hide();
	shineFrame:SetScript("OnUpdate", Shine_Update);
	shineFrame:SetAlpha(parent:GetAlpha());
	
	return shineFrame;
end
function WHUD_StartToShine(Frame)
	local shineFrame = CreateShineFrame(Frame:GetParent());
	
	shineFrame.shine:SetAlpha(shineFrame:GetParent():GetAlpha());
	shineFrame.shine:SetHeight(shineFrame:GetHeight() * 6);
	shineFrame.shine:SetWidth(shineFrame:GetWidth() * 6);
	
	shineFrame:Show();
end	
	--
	
	-- CHAT MESSAGE --
local function Chat(text)
	-- (CHAT USES THE DEFAULT CHATFRAME AND SENDS A LOCAL MESSAGE TO THE USER)
	DEFAULT_CHAT_FRAME:AddMessage(text);
end
	--
	
	-- COMMAND HANDLER --
SLASH_WHUD1 = "/whud";
SLASH_WHUD2 = "/warriorhud";
SlashCmdList["WHUD"] = function(msg)
	if string.find(msg,"Overpower") or string.find(msg,"overpower") then
		-- OVERPOWER SETTINGS
		msg = string.sub(msg,11)
		if string.find(msg,"enable") or string.find(msg,"Enable") or string.find(msg,"ENABLE") then
			WHUD_VARS.Overpower.enabled = true
			WHUD_CORE:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
			WHUD_CORE:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF") 
			WHUD_CORE:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")			
			Chat(" >> |cff8f4108WarriorHUD|r enabled the Overpower Alert.")
		elseif string.find(msg,"disable") or string.find(msg,"Disable") or string.find(msg,"DISABLE") then
			WHUD_VARS.Overpower.enabled = false 
			WHUD_CORE:UnregisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
			WHUD_CORE:UnregisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
			WHUD_CORE:UnregisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
			Chat(" >> |cff8f4108WarriorHUD|r disabled the Overpower Alert.")
		elseif string.find(msg,"MSG") or string.find(msg,"msg") then
			msg = string.sub(msg,5)
			if string.len(msg) <= 30 then
				WHUD_VARS.Overpower.MSG = msg
				WHUD_OP_TEXT:SetText(WHUD_VARS.Overpower.MSG)
				WHUD_OP_TIME = GetTime()+10 -- just for editing shit
				Chat(" >> |cff8f4108WarriorHUD|r changed the message of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.MSG.."|r")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the message because it was longer than 30 digits.)")
			end
		elseif string.find(msg,"mode") or string.find(msg,"MODE") then
			msg = string.sub(msg,6)
			if string.find(msg,"text") or string.find(msg,"TEXT") then
				WHUD_VARS.Overpower.mode = "text"
				WHUD_OP_TEXT:Show()
				WHUD_OP_LEFT:Show()
				WHUD_OP_RIGHT:Show()
				WHUD_OP_TIMER1:Show()
				WHUD_OP_TIMER2:Show()
				WHUD_OP_ICON:Hide()
				WHUD_OP_TIMER3:Hide()
				Chat(" >> |cff8f4108WarriorHUD|r changed the mode to |cff1fff1f"..WHUD_VARS.Overpower.mode.."|r.")
			elseif string.find(msg,"icon") or string.find(msg,"ICON") then
				WHUD_VARS.Overpower.mode = "icon"
				WHUD_OP_ICON:Show()
				WHUD_OP_TIMER3:Show()
				WHUD_OP_TEXT:Hide()
				WHUD_OP_LEFT:Hide()
				WHUD_OP_RIGHT:Hide()
				WHUD_OP_TIMER1:Hide()
				WHUD_OP_TIMER2:Hide()
				Chat(" >> |cff8f4108WarriorHUD|r changed the mode to |cff1fff1f"..WHUD_VARS.Overpower.mode.."|r.")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the mode. It is either 'text' or 'icon'.)")
			end
		elseif string.find(msg,"X") or string.find(msg,"x") then
			msg = string.sub(msg,3)
			WHUD_VARS.Overpower.X = tonumber(msg);
			WHUD_OP_TIME = GetTime()+10 -- just for editing shit
			WHUD_OP:SetPoint("CENTER", "UIParent", WHUD_VARS.Overpower.X ,WHUD_VARS.Overpower.Y)
			Chat(" >> |cff8f4108WarriorHUD|r changed the X Position of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.X.."|r")
		elseif string.find(msg,"Y") or string.find(msg,"y") then
			msg = string.sub(msg,3)
			WHUD_VARS.Overpower.Y = tonumber(msg);
			WHUD_OP_TIME = GetTime()+10 -- just for editing shit
			WHUD_OP:SetPoint("CENTER", "UIParent", WHUD_VARS.Overpower.X ,WHUD_VARS.Overpower.Y)
			Chat(" >> |cff8f4108WarriorHUD|r changed the Y Position of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.Y.."|r")
		elseif string.find(msg,"scale") or string.find(msg,"Scale") or string.find(msg,"SCALE") then
			msg = string.sub(msg,7)
			msg = tonumber(msg)
			if msg > 0 and msg <= 10 then
				WHUD_VARS.Overpower.scale = msg
				WHUD_OP_TIME = GetTime()+10 -- just for editing shit
				WHUD_OP:SetScale(WHUD_VARS.Overpower.scale)
				Chat(" >> |cff8f4108WarriorHUD|r changed the scale of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.scale.."|r")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the scale because it was larger than 10.)")
			end
		elseif string.find(msg,"strata") or string.find(msg,"Strata") or string.find(msg,"STRATA") then
			msg = string.sub(msg,8)
			if msg == "PARENT" or msg == "parent" then
				WHUD_VARS.Overpower.strata = "PARENT"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			elseif msg == "BACKGROUND" or msg == "background" then
				WHUD_VARS.Overpower.strata = "BACKGROUND"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			elseif msg == "LOW" or msg == "low" then
				WHUD_VARS.Overpower.strata = "LOW"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			elseif msg == "MEDIUM" or msg == "medium" then
				WHUD_VARS.Overpower.strata = "MEDIUM"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			elseif msg == "HIGH" or msg == "high" then
				WHUD_VARS.Overpower.strata = "HIGH"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			elseif msg == "DIALOG" or msg == "dialog" then
				WHUD_VARS.Overpower.strata = "DIALOG"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			elseif msg == "FULLSCREEN" or msg == "fullscreen" then
				WHUD_VARS.Overpower.strata = "FULLSCREEN"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			elseif msg == "FULLSCREEN_DIALOG" or msg == "fullscreen_dialog" then
				WHUD_VARS.Overpower.strata = "FULLSCREEN_DIALOG"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			elseif msg == "TOOLTIP" or msg == "tooltip" then
				WHUD_VARS.Overpower.strata = "TOOLTIP"
				WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Overpower alert to |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the strata. Possible options PARENT|BACKGROUND|LOW|MEDIUM|HIGH|DIALOG|FULLSCREEN|FULLSCREEN_DIALOG|TOOLTIP)")
			end 
		else
			-- OVERPOWER OVERVIEW
			Chat(" > |cff8f4108WarriorHUD|r>Overpower  Config:")
			if WHUD_VARS.Overpower.enabled then
				Chat("|cfff94040disable|r - to disable the entire Overpower alert.")
				Chat("|cff3be7edX|r |cff1fff1f"..WHUD_VARS.Overpower.X.."|r - move it right/left.")
				Chat("|cff3be7edY|r |cff1fff1f"..WHUD_VARS.Overpower.Y.."|r - move it up/down.")
				Chat("|cff3be7edmode|r |cff1fff1f"..WHUD_VARS.Overpower.mode.."|r - change its alert mode.")
				if WHUD_VARS.Overpower.mode == "text" then Chat("|cff3be7edMSG|r |cff1fff1f"..WHUD_VARS.Overpower.MSG.."|r - change its alert message.") end
				Chat("|cff3be7edscale|r |cff1fff1f"..WHUD_VARS.Overpower.scale.."|r - scale it bigger/smaller.")
				Chat("|cff3be7edstrata|r |cff1fff1f"..WHUD_VARS.Overpower.strata.."|r - change its layer position.")
			else
				Chat("|cff1fff1fenable|r - to enable the Overpower alert.")
			end
		end
	elseif string.find(msg,"Alerts") or string.find(msg,"alerts") then
		-- ALERTS SETTINGS
		msg = string.sub(msg,8)
		if string.find(msg,"X") or string.find(msg,"x") then
			msg = string.sub(msg,3)
			WHUD_VARS.Alerts.X = tonumber(msg);
			WHUD_ALERT_TEXT:SetText("! ALERT BAR EDIT !")
			WHUD_ALERT_TIME = GetTime()+5
			WHUD_ALERT:SetPoint("CENTER", "UIParent", WHUD_VARS.Alerts.X ,WHUD_VARS.Alerts.Y)
			Chat(" >> |cff8f4108WarriorHUD|r changed the X Position of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.X.."|r)")
		elseif string.find(msg,"Y") or string.find(msg,"y") then
			msg = string.sub(msg,3)
			WHUD_VARS.Alerts.Y = tonumber(msg);
			WHUD_ALERT_TEXT:SetText("! ALERT BAR EDIT !")
			WHUD_ALERT_TIME = GetTime()+5
			WHUD_ALERT:SetPoint("CENTER", "UIParent", WHUD_VARS.Alerts.X ,WHUD_VARS.Alerts.Y)
			Chat(" >> |cff8f4108WarriorHUD|r changed the Y Position of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.Y.."|r)")
		elseif string.find(msg,"scale") or string.find(msg,"Scale") or string.find(msg,"SCALE") then
			msg = string.sub(msg,7)
			msg = tonumber(msg)
			if msg > 0 and msg <= 10 then
				WHUD_VARS.Alerts.scale = msg
				WHUD_ALERT_TEXT:SetText("! ALERT BAR EDIT !")
				WHUD_ALERT_TIME = GetTime()+5
				WHUD_ALERT:SetScale(WHUD_VARS.Alerts.scale)
				Chat(" >> |cff8f4108WarriorHUD|r changed the scale of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.scale.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the scale because it was larger than 10.)")
			end
		elseif string.find(msg,"strata") or string.find(msg,"Strata") or string.find(msg,"STRATA") then
			msg = string.sub(msg,8)
			if msg == "PARENT" or msg == "parent" then
				WHUD_VARS.Alerts.strata = "PARENT"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			elseif msg == "BACKGROUND" or msg == "background" then
				WHUD_VARS.Alerts.strata = "BACKGROUND"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			elseif msg == "LOW" or msg == "low" then
				WHUD_VARS.Alerts.strata = "LOW"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			elseif msg == "MEDIUM" or msg == "medium" then
				WHUD_VARS.Alerts.strata = "MEDIUM"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			elseif msg == "HIGH" or msg == "high" then
				WHUD_VARS.Alerts.strata = "HIGH"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			elseif msg == "DIALOG" or msg == "dialog" then
				WHUD_VARS.Alerts.strata = "DIALOG"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			elseif msg == "FULLSCREEN" or msg == "fullscreen" then
				WHUD_VARS.Alerts.strata = "FULLSCREEN"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			elseif msg == "FULLSCREEN_DIALOG" or msg == "fullscreen_dialog" then
				WHUD_VARS.Alerts.strata = "FULLSCREEN_DIALOG"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			elseif msg == "TOOLTIP" or msg == "tooltip" then
				WHUD_VARS.Alerts.strata = "TOOLTIP"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Alerts.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Alerts to |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the strata. Possible options PARENT|BACKGROUND|LOW|MEDIUM|HIGH|DIALOG|FULLSCREEN|FULLSCREEN_DIALOG|TOOLTIP)")
			end 
		elseif string.find(msg,"fontsize") or string.find(msg,"Fontsize") or string.find(msg,"FONTSIZE") then
			msg = string.sub(msg,10)
			msg = tonumber(msg)
			if msg > 0 and msg < 100 then
				WHUD_VARS.Alerts.fontsize = msg
				WHUD_ALERT_TEXT:SetText("! ALERT BAR EDIT !")
				WHUD_ALERT_TIME = GetTime()+5
				WHUD_ALERT_TEXT:SetFont("Interface\\AddOns\\WarriorHUD\\Fishfingers.ttf", WHUD_VARS.Alerts.fontsize,"THINOUTLINE")
				Chat(" >> |cff8f4108WarriorHUD|r changed the size of the Font to |cff1fff1f"..WHUD_VARS.Alerts.fontsize.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the size of the Font because it wasn't between 1-100)")
			end
		elseif string.find(msg,"battleshout") or string.find(msg,"Battleshout") or string.find(msg,"BattleShout") or string.find(msg,"BATTLESHOUT") then
			msg = string.sub(msg,13)
			if msg == "off" or msg == "OFF" then
				if WHUD_VARS.Alerts["Battleshout"] then
					WHUD_VARS.Alerts["Battleshout"] = false
					Chat(" >> |cff8f4108WarriorHUD|r disabled the Battle Shout Alert.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Battle Shout Alert was already disabled.")
				end
			elseif msg == "on" or msg == "ON" then
				if not WHUD_VARS.Alerts["Battleshout"] then
					WHUD_VARS.Alerts["Battleshout"] = true
					Chat(" >> |cff8f4108WarriorHUD|r enabled the Battle Shout Alert.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Battle Shout Alert was already enabled.")
				end
			else
				Chat(" >> |cff8f4108WarriorHUD|r - to modify the Battle Shout Alert use either 'on' or 'off'.")
			end
		elseif string.find(msg,"weightstone") or string.find(msg,"Weightstone") or string.find(msg,"WeightStone") or string.find(msg,"WEIGHTSTONE") then
			msg = string.sub(msg,13)
			if msg == "off" or msg == "OFF" then
				if WHUD_VARS.Alerts["Weightstone"] then
					WHUD_VARS.Alerts["Weightstone"] = false
					Chat(" >> |cff8f4108WarriorHUD|r disabled the Weightstone Alert.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Weightstone Alert was already disabled.")
				end
			elseif msg == "on" or msg == "ON" then
				if not WHUD_VARS.Alerts["Weightstone"] then
					WHUD_VARS.Alerts["Weightstone"] = true
					Chat(" >> |cff8f4108WarriorHUD|r enabled the Weightstone Alert.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Weightstone Alert was already enabled.")
				end
			else
				Chat(" >> |cff8f4108WarriorHUD|r - to modify the Weightstone Alert use either 'on' or 'off'.")
			end
		elseif string.find(msg,"salvation") or string.find(msg,"Salvation") or string.find(msg,"SALVATION") then
			msg = string.sub(msg,11)
			if msg == "off" or msg == "OFF" then
				if WHUD_VARS.Alerts["Salvation"] then
					WHUD_VARS.Alerts["Salvation"] = false
					Chat(" >> |cff8f4108WarriorHUD|r disabled the Salvation Alert.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Salvation Alert was already disabled.")
				end
			elseif msg == "on" or msg == "ON" then
				if not WHUD_VARS.Alerts["Salvation"] then
					WHUD_VARS.Alerts["Salvation"] = true
					Chat(" >> |cff8f4108WarriorHUD|r enabled the Salvation Alert.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Salvation Alert was already enabled.")
				end
			else
				Chat(" >> |cff8f4108WarriorHUD|r - to modify the Salvation Alert use either 'on' or 'off'.")
			end
		else
			-- ALERTS OVERVIEW
			Chat(" > |cff8f4108WarriorHUD|r>|cff3be7edAlerts|r  Config:")
			Chat("|cff3be7edX|r |cff1fff1f"..WHUD_VARS.Alerts.X.."|r - move it right/left.")
			Chat("|cff3be7edY|r |cff1fff1f"..WHUD_VARS.Alerts.Y.."|r - move it up/down.")
			Chat("|cff3be7edscale|r |cff1fff1f"..WHUD_VARS.Alerts.scale.."|r - scale it bigger/smaller.")
			Chat("|cff3be7edstrata|r |cff1fff1f"..WHUD_VARS.Alerts.strata.."|r - change its layer position.")
			Chat("|cff3be7edfontsize|r |cff1fff1f"..WHUD_VARS.Alerts.fontsize.."|r - change the size of the Font.")
			if WHUD_VARS.Alerts["Battleshout"] then
				Chat("|cff3be7edBattleshout|r |cff1fff1fON|r - disables the Battle Shout Alert.")
			else
				Chat("|cff3be7edBattleshout|r |cff1fff1fOFF|r - enables the Battle Shout Alert.")
			end
			if WHUD_VARS.Alerts["Weightstone"] then
				Chat("|cff3be7edWeightstone|r |cff1fff1fON|r - disables the Weightstone Alert.")
			else
				Chat("|cff3be7edWeightstone|r |cff1fff1fOFF|r - enables the Weightstone Alert.")
			end
			if WHUD_VARS.Alerts["Salvation"] then
				Chat("|cff3be7edSalvation|r |cff1fff1fON|r - disables the Salvation Alert.")
			else
				Chat("|cff3be7edSalvation|r |cff1fff1fOFF|r - enables the Salvation Alert.")
			end
		end 
	elseif string.find(msg,"Ragebar") or string.find(msg,"ragebar") then
		-- RAGEBAR SETTINGS
		msg = string.sub(msg,9)
		if string.find(msg,"enable") or string.find(msg,"Enable") or string.find(msg,"ENABLE") then
			WHUD_VARS.Ragebar.enabled = true
			WHUD_RBAR:Show()
			WHUD_CORE:RegisterEvent("UNIT_RAGE")
			Chat(" >> |cff8f4108WarriorHUD|r enabled the Ragebar.")
		elseif string.find(msg,"disable") or string.find(msg,"Disable") or string.find(msg,"DISABLE") then
			WHUD_VARS.Ragebar.enabled = false 
			WHUD_RBAR:Show()
			WHUD_CORE:UnregisterEvent("UNIT_RAGE")
			Chat(" >> |cff8f4108WarriorHUD|r disabled the Ragebar.")
		elseif string.find(msg,"X") or string.find(msg,"x") then
			msg = string.sub(msg,3)
			WHUD_VARS.Ragebar.X = tonumber(msg);
			WHUD_RAGE_EDIT = GetTime()+5;
			WHUD_RBAR:SetPoint("CENTER", "UIParent", WHUD_VARS.Ragebar.X ,WHUD_VARS.Ragebar.Y)
			Chat(" >> |cff8f4108WarriorHUD|r changed the X Position of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.X.."|r)")
		elseif string.find(msg,"Y") or string.find(msg,"y") then
			msg = string.sub(msg,3)
			WHUD_VARS.Ragebar.Y = tonumber(msg);
			WHUD_RAGE_EDIT = GetTime()+5;
			WHUD_RBAR:SetPoint("CENTER", "UIParent", WHUD_VARS.Ragebar.X ,WHUD_VARS.Ragebar.Y)
			Chat(" >> |cff8f4108WarriorHUD|r changed the Y Position of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.Y.."|r)")
		elseif string.find(msg,"scale") or string.find(msg,"Scale") or string.find(msg,"SCALE") then
			msg = string.sub(msg,7)
			msg = tonumber(msg)
			if msg > 0 and msg <= 10 then
				WHUD_VARS.Ragebar.scale = msg
				WHUD_RAGE_EDIT = GetTime()+5;
				WHUD_RBAR:SetScale(WHUD_VARS.Ragebar.scale)
				Chat(" >> |cff8f4108WarriorHUD|r changed the scale of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.scale.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the scale because it was larger than 10.)")
			end
		elseif string.find(msg,"strata") or string.find(msg,"Strata") or string.find(msg,"STRATA") then
			msg = string.sub(msg,8)
			if msg == "PARENT" or msg == "parent" then
				WHUD_VARS.Ragebar.strata = "PARENT"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			elseif msg == "BACKGROUND" or msg == "background" then
				WHUD_VARS.Ragebar.strata = "BACKGROUND"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			elseif msg == "LOW" or msg == "low" then
				WHUD_VARS.Ragebar.strata = "LOW"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			elseif msg == "MEDIUM" or msg == "medium" then
				WHUD_VARS.Ragebar.strata = "MEDIUM"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			elseif msg == "HIGH" or msg == "high" then
				WHUD_VARS.Ragebar.strata = "HIGH"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			elseif msg == "DIALOG" or msg == "dialog" then
				WHUD_VARS.Ragebar.strata = "DIALOG"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			elseif msg == "FULLSCREEN" or msg == "fullscreen" then
				WHUD_VARS.Ragebar.strata = "FULLSCREEN"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			elseif msg == "FULLSCREEN_DIALOG" or msg == "fullscreen_dialog" then
				WHUD_VARS.Ragebar.strata = "FULLSCREEN_DIALOG"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			elseif msg == "TOOLTIP" or msg == "tooltip" then
				WHUD_VARS.Ragebar.strata = "TOOLTIP"
				WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the strata. Possible options PARENT|BACKGROUND|LOW|MEDIUM|HIGH|DIALOG|FULLSCREEN|FULLSCREEN_DIALOG|TOOLTIP)")
			end 
		elseif string.find(msg,"alpha") or string.find(msg,"Alpha") or string.find(msg,"ALPHA") then
			msg = string.sub(msg,7)
			msg = tonumber(msg)
			if msg >= 0.1 and msg <= 1 then
				WHUD_VARS.Ragebar.transparency = msg
				WHUD_RAGE_EDIT = GetTime()+10;
				WHUD_RBAR:SetAlpha(WHUD_VARS.Ragebar.transparency)
				Chat(" >> |cff8f4108WarriorHUD|r changed the transparency of the Ragebar to |cff1fff1f"..WHUD_VARS.Ragebar.alpha.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the transparency because it wasn't between 0.1-1.0)")
			end
		elseif string.find(msg,"fontsize") or string.find(msg,"Fontsize") or string.find(msg,"FONTSIZE") then
			msg = string.sub(msg,10)
			msg = tonumber(msg)
			if msg > 0 and msg < 100 then
				WHUD_VARS.Ragebar.fontsize = msg
				WHUD_RAGE_EDIT = GetTime()+10;
				WHUD_RAGE_TEXT:SetFont("Interface\\AddOns\\WarriorHUD\\Fishfingers.ttf", WHUD_VARS.Ragebar.fontsize,"THINOUTLINE")
				Chat(" >> |cff8f4108WarriorHUD|r changed the size of the Font to |cff1fff1f"..WHUD_VARS.Ragebar.fontsize.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the size of the Font because it wasn't between 1-100)")
			end
		else
			-- RAGEBAR OVERVIEW
			Chat(" > |cff8f4108WarriorHUD|r>|cff3be7edRagebar|r  Config:")
			if WHUD_VARS.Ragebar.enabled then
				Chat("|cfff94040disable|r - to disable the entire Ragebar.")
				Chat("|cff3be7edX|r |cff1fff1f"..WHUD_VARS.Ragebar.X.."|r - move it right/left.")
				Chat("|cff3be7edY|r |cff1fff1f"..WHUD_VARS.Ragebar.Y.."|r - move it up/down.")
				Chat("|cff3be7edscale|r |cff1fff1f"..WHUD_VARS.Ragebar.scale.."|r - scale it bigger/smaller.")
				Chat("|cff3be7edstrata|r |cff1fff1f"..WHUD_VARS.Ragebar.strata.."|r - change its layer position.")
				Chat("|cff3be7edalpha|r |cff1fff1f"..WHUD_VARS.Ragebar.transparency.."|r - change its transparency.")
				Chat("|cff3be7edfontsize|r |cff1fff1f"..WHUD_VARS.Ragebar.fontsize.."|r - change the size of the Font.")
			else
				Chat("|cff1fff1fenable|r - to enable the Ragebar.")
			end
		end
	elseif string.find(msg,"Cooldowns") or string.find(msg,"cooldowns") then
		-- COOLDOWN SETTINGS
		msg = string.sub(msg,11)
		if string.find(msg,"enable") or string.find(msg,"Enable") or string.find(msg,"ENABLE") then
			WHUD_VARS.Cooldowns.enabled = true
			WHUD_CORE:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
			Chat(" >> |cff8f4108WarriorHUD|r enabled the Cooldown alert.")
		elseif string.find(msg,"disable") or string.find(msg,"Disable") or string.find(msg,"DISABLE") then
			WHUD_VARS.Cooldowns.enabled = false 
			WHUD_CORE:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
			Chat(" >> |cff8f4108WarriorHUD|r disabled the Cooldown alert.")
		elseif string.find(msg,"trinkets") or string.find(msg,"Trinkets") or string.find(msg,"TRINKETS") then
			msg = string.sub(msg,10)
			if msg == "off" or msg == "OFF" then
				if WHUD_VARS.Cooldowns.trinkets then
					WHUD_VARS.Cooldowns.trinkets = false
					Chat(" >> |cff8f4108WarriorHUD|r disabled the Cooldown trinket display.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Cooldown trinket display was already disabled.")
				end
			elseif msg == "on" or msg == "ON" then
				if not WHUD_VARS.Cooldowns.trinkets then
					WHUD_VARS.Cooldowns.trinkets = true
					Chat(" >> |cff8f4108WarriorHUD|r enabled the Cooldown trinket display.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Cooldown trinket display was already enabled.")
				end
			else
				Chat(" >> |cff8f4108WarriorHUD|r - to modify the Cooldown trinket display use either 'on' or 'off'.")
			end
		elseif string.find(msg,"fading") or string.find(msg,"Fading") or string.find(msg,"FADING") then
			msg = string.sub(msg,9)
			if msg == "off" or msg == "OFF" then
				if WHUD_VARS.Cooldowns.fading then
					WHUD_VARS.Cooldowns.fading = false
					for i=1,6 do
						_G["WHUD_CD"..i.."_LAST"] = WHUD_VARS.Cooldowns.transparency
					end
					Chat(" >> |cff8f4108WarriorHUD|r disabled the Cooldown fading.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Cooldown fading was already disabled.")
				end
			elseif msg == "on" or msg == "ON" then
				if not WHUD_VARS.Cooldowns.fading then
					WHUD_VARS.Cooldowns.fading = true	
					for i=1,6 do
						_G["WHUD_CD"..i.."_LAST"] = 0
					end
					Chat(" >> |cff8f4108WarriorHUD|r enabled the Cooldown fading.")
				else
					Chat(" >> |cff8f4108WarriorHUD|r - the Cooldown fading was already enabled.")
				end
			else
				Chat(" >> |cff8f4108WarriorHUD|r - to modify the Cooldown fading use either 'on' or 'off'.")
			end
		elseif string.find(msg,"fadetime") or string.find(msg,"Fadetime") or string.find(msg,"FadeTime") or string.find(msg,"FADETIME") then
			msg = string.sub(msg,10)
			if msg > 0 and msg < 10 then
				WHUD_VARS.Cooldowns.fadetime = msg
				Chat(" >> |cff8f4108WarriorHUD|r changed the Fade time of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.fadetime.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the Fade time because it was larger than 10.")
			end
		elseif string.find(msg,"X") or string.find(msg,"x") then
			msg = string.sub(msg,3)
			WHUD_VARS.Cooldowns.X = tonumber(msg);
			WHUD_CDedit()
			WHUD_CDBAR:SetPoint("CENTER", "UIParent", WHUD_VARS.Cooldowns.X ,WHUD_VARS.Cooldowns.Y)
			Chat(" >> |cff8f4108WarriorHUD|r changed the X Position of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.X.."|r)")
		elseif string.find(msg,"Y") or string.find(msg,"y") then
			msg = string.sub(msg,3)
			WHUD_VARS.Cooldowns.Y = tonumber(msg);
			WHUD_CDedit()
			WHUD_CDBAR:SetPoint("CENTER", "UIParent", WHUD_VARS.Cooldowns.X ,WHUD_VARS.Cooldowns.Y)
			Chat(" >> |cff8f4108WarriorHUD|r changed the Y Position of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.Y.."|r)")
		elseif string.find(msg,"scale") or string.find(msg,"Scale") or string.find(msg,"SCALE") then
			msg = string.sub(msg,7)
			msg = tonumber(msg)
			WHUD_CDedit()
			if msg > 0 and msg <= 10 then
				WHUD_VARS.Cooldowns.scale = msg
				WHUD_CDBAR:SetScale(WHUD_VARS.Cooldowns.scale)
				Chat(" >> |cff8f4108WarriorHUD|r changed the scale of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.scale.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the scale because it was larger than 10.)")
			end
		elseif string.find(msg,"strata") or string.find(msg,"Strata") or string.find(msg,"STRATA") then
			msg = string.sub(msg,8)
			if msg == "PARENT" or msg == "parent" then
				WHUD_VARS.Cooldowns.strata = "PARENT"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			elseif msg == "BACKGROUND" or msg == "background" then
				WHUD_VARS.Cooldowns.strata = "BACKGROUND"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			elseif msg == "LOW" or msg == "low" then
				WHUD_VARS.Cooldowns.strata = "LOW"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			elseif msg == "MEDIUM" or msg == "medium" then
				WHUD_VARS.Cooldowns.strata = "MEDIUM"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			elseif msg == "HIGH" or msg == "high" then
				WHUD_VARS.Cooldowns.strata = "HIGH"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			elseif msg == "DIALOG" or msg == "dialog" then
				WHUD_VARS.Cooldowns.strata = "DIALOG"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			elseif msg == "FULLSCREEN" or msg == "fullscreen" then
				WHUD_VARS.Cooldowns.strata = "FULLSCREEN"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			elseif msg == "FULLSCREEN_DIALOG" or msg == "fullscreen_dialog" then
				WHUD_VARS.Cooldowns.strata = "FULLSCREEN_DIALOG"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			elseif msg == "TOOLTIP" or msg == "tooltip" then
				WHUD_VARS.Cooldowns.strata = "TOOLTIP"
				WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
				Chat(" >> |cff8f4108WarriorHUD|r changed the strata of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the strata. Possible options PARENT|BACKGROUND|LOW|MEDIUM|HIGH|DIALOG|FULLSCREEN|FULLSCREEN_DIALOG|TOOLTIP)")
			end 
		elseif string.find(msg,"alpha") or string.find(msg,"Alpha") or string.find(msg,"ALPHA") then
			msg = string.sub(msg,7)
			msg = tonumber(msg)
			WHUD_CDedit()
			if msg >= 0.1 and msg <= 1 then
				WHUD_VARS.Cooldowns.transparency = msg
				WHUD_CDBAR:SetAlpha(WHUD_VARS.Cooldowns.transparency)
				Chat(" >> |cff8f4108WarriorHUD|r changed the transparency of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.transparency.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the transparency because it wasn't between 0.1-1.0)")
			end
		elseif string.find(msg,"flashtime") or string.find(msg,"Flashtime") or string.find(msg,"FLASHTIME") then
			msg = string.sub(msg,11)
			msg = tonumber(msg)
			if msg > 0 and msg < 10 then
				WHUD_VARS.Cooldowns.flashtime = msg
				Chat(" >> |cff8f4108WarriorHUD|r changed the Flashtime of the Cooldown alert to |cff1fff1f"..WHUD_VARS.Cooldowns.flashtime.."|r)")
			else
				Chat(" >> |cff8f4108WarriorHUD|r couldn't change the Flashtime because it wasn't between 0.1-10)")
			end
		else
			-- COOLDOWNS OVERVIEW
			Chat(" > |cff8f4108WarriorHUD|r>Cooldowns  Config:")
			if WHUD_VARS.Cooldowns.enabled then
				Chat("|cfff94040disable|r - to disable the entire Cooldown alert.")
				Chat("|cff3be7edX|r |cff1fff1f"..WHUD_VARS.Cooldowns.X.."|r - move it right/left.")
				Chat("|cff3be7edY|r |cff1fff1f"..WHUD_VARS.Cooldowns.Y.."|r - move it up/down.")
				Chat("|cff3be7edscale|r |cff1fff1f"..WHUD_VARS.Cooldowns.scale.."|r - scale it bigger/smaller.")
				Chat("|cff3be7edstrata|r |cff1fff1f"..WHUD_VARS.Cooldowns.strata.."|r - change its layer position.")
				Chat("|cff3be7edalpha|r |cff1fff1f"..WHUD_VARS.Cooldowns.transparency.."|r - change its transparency.")
				Chat("|cff3be7edflashtime|r |cff1fff1f"..WHUD_VARS.Cooldowns.flashtime.."|r - change the timelength of flashing CD Icons.")
				if WHUD_VARS.Cooldowns.fading then
					Chat("|cff3be7edfading|r |cff1fff1fON|r - disables the Icons fading.")
					Chat("|cff3be7edfadetime|r |cff1fff1f"..WHUD_VARS.Cooldowns.fadetime.."|r - changes the time fading.")
				else
					Chat("|cff3be7edfading|r |cff1fff1fOFF|r - enables the Icons fading.")
				end
				if WHUD_VARS.Cooldowns.trinkets then
					Chat("|cff3be7edtrinkets|r |cff1fff1fON|r - disables the Cooldown trinket display.")
				else
					Chat("|cff3be7edtrinkets|r |cff1fff1fOFF|r - enables the Cooldown trinket display.")
				end
			else
				Chat("|cff1fff1fenable|r - to enable the Cooldown alert.")
			end
		end
	else
		-- GENERAL SETTINGS
		if msg == "reset" then
			if WHUD_RESET == nil then 
				WHUD_RESET = 1
				Chat(" >> ! Do you really want to reset your |cff8f4108WarriorHUD|r Settings? If so repeat the command ! <<")
			elseif WHUD_RESET == 1 then
				WHUD_VARS = {
					VERSION = WHUD_VERSION,
					Ragebar = {
						enabled = true,
						X = 0,
						Y = -100,
						scale = WHUD_DEFAULT_SCALE,
						strata = "HIGH",
						transparency = 1,
						fontsize = 25,
					},
					Cooldowns = {
						enabled = true,
						X = 0,
						Y = -50,
						scale = WHUD_DEFAULT_SCALE,
						strata = "HIGH",
						transparency = 1,
						flashtime = 1.5,
						fading = true,
						fadetime = 1.5,
						trinkets = true,
					},
					Overpower = {
						enabled = true,
						X = 0,
						Y = 50,
						scale = WHUD_DEFAULT_SCALE,
						strata = "HIGH",
						MSG = "USE OVERPOWER NOW",
						mode = "text",
					},
					Alerts = {
						X = 0,
						Y = 0,
						scale = WHUD_DEFAULT_SCALE,
						strata = "HIGH",
						fontsize = 25,
						["Battleshout"] = true,
						["Weightstone"] = true,
						["Salvation"] = true,
					},
				}
				-- now reload the frames with default values
					-- Ragebar
					WHUD_RBAR:SetPoint("CENTER", "UIParent", WHUD_VARS.Ragebar.X ,WHUD_VARS.Ragebar.Y)
					WHUD_RBAR:SetFrameStrata(WHUD_VARS.Ragebar.strata)
					WHUD_RBAR:SetScale(WHUD_VARS.Ragebar.scale)
					WHUD_RBAR:SetAlpha(WHUD_VARS.Ragebar.transparency)
					-- CD bar
					WHUD_CDBAR:SetPoint("CENTER", "UIParent", WHUD_VARS.Cooldowns.X ,WHUD_VARS.Cooldowns.Y)
					WHUD_CDBAR:SetFrameStrata(WHUD_VARS.Cooldowns.strata)
					WHUD_CDBAR:SetScale(WHUD_VARS.Cooldowns.scale)
					WHUD_CDBAR:SetAlpha(WHUD_VARS.Cooldowns.transparency)
					-- OP bar
					WHUD_OP:SetPoint("CENTER", "UIParent",WHUD_VARS.Overpower.X,WHUD_VARS.Overpower.Y)
					WHUD_OP:SetFrameStrata(WHUD_VARS.Overpower.strata)
					WHUD_OP:SetScale(WHUD_VARS.Overpower.scale)
					
				WHUD_RESET = nil
				Chat(" >> |cff8f4108WarriorHUD|r reset complete. Loaded default settings.")
			end
		else
			-- COMMAND OVERVIEW
			Chat(" > |cff8f4108WarriorHUD|r v"..WHUD_VERSION.." Config:")
			Chat("|cff3be7edRagebar|r - all settings related to the Ragebar.")
			Chat("|cff3be7edCooldowns|r - all settings related to the Cooldowns alert.")
			Chat("|cff3be7edOverpower|r - all settings related to the Overpower alert.")
			Chat("|cff3be7edAlerts|r - all settings related to the misc Alerts.")
			Chat("|cfff94040reset|r - resetting your WarriorHUD Settings back to default.")
		end
	end
end
end