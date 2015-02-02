-- Viro UI Config Addon
--
-- Feenix Warsong
-- Virose
local VUI_PlayerName = nil;
local VUI_default = 0;
local profile = none;
VUI_QueueMSG = {};
VUI_Queuecnt =  0;
local swsnuked = false;

function VUI_OnLoad()
	VUI_Register_Commands();
	VUI_BasicUpdates();
end
function VUI_Register_Commands()
    SLASH_VUI1 = "/VUI";
    SlashCmdList["VUI"] = function(msg)
		VUI_SlashCommand(msg);
	end
	--
	
	SLASH_EQUIP1 = "/EQUIP";
    SlashCmdList["EQUIP"] = function(msg)
		EquipItem(msg);
	end
	SLASH_EQUIPSLOT1 = "/EQUIPSLOT";
    SlashCmdList["EQUIPSLOT"] = function(msg)
			local _, _, iName, args = string.find(msg, "(%w+)%s?(.*)");
			if (tonumber(args)) then
			local slot = tonumber(args)
			EquipItemSlot(iName, slot)
			end
	end
	-- Unstuck
	SLASH_UNSTUCK1 = "/UNSTUCK";
	SLASH_UNSTUCK2 = "/STUCK";
	SlashCmdList["UNSTUCK"] = function(msg)
		Stuck()
	end
	-- Use
	SLASH_USE1 = "/USE";
    SlashCmdList["USE"] = function(msg)
		EquipItem(msg);
	end
	--
	-- PetAttack
	SLASH_PETATTACK1 = "/PETATTACK";
    SlashCmdList["PETATTACK"] = function(msg)
		PetAttack();
	end
	--
end
function VUI_Init()
    VUI_PlayerName = UnitName("player").." of "..GetCVar("realmName");

    if (VUI_CONFIG == nil) then
	VUI_CONFIG = {};
    end

    if (VUI_CONFIG[VUI_PlayerName] == nil) then
	VUI_CONFIG[VUI_PlayerName] = VUI_default;
    end
end

function VUI_SlashCommand(msg)
    local VUI_Status = "Off";
    if(msg == "setup") then
      DEFAULT_CHAT_FRAME:AddMessage("Virose UI - Setup menu", 1, 1, 0.5);
	  DEFAULT_CHAT_FRAME:AddMessage(" - tankdps : for the Tank/DPS Layout", 1, 1, 0.5);
	  DEFAULT_CHAT_FRAME:AddMessage(" - healer : for the Healer Layout", 1, 1, 0.5);
	  DEFAULT_CHAT_FRAME:AddMessage(" - alt : for the Alt Layout", 1, 1, 0.5);
	  
    elseif (msg == "setup tankdps") then
	  VUI_SETUP("tankdps")
    elseif (msg == "setup healer") then
	  VUI_SETUP("healer")
    elseif (msg == "setup bankalt") then
	  VUI_SETUP("bankalt")
    else
      if ( DEFAULT_CHAT_FRAME ) then
        DEFAULT_CHAT_FRAME:AddMessage("Virose UI Config ", 1, 1, 0.5);
        DEFAULT_CHAT_FRAME:AddMessage("Profile: "..VUI_Status, 1, 1, 0.5);
        DEFAULT_CHAT_FRAME:AddMessage("Command line options:", 1, 1, 0.5);
		DEFAULT_CHAT_FRAME:AddMessage(" - setup : for the setup menu", 1, 1, 0.5);
      end
    end
end

function VUI_Profile()
	-- getter methode
	profile = none
	-- get it mofo
	return profile
end


function VUI_OnEvent(event)
	VUI_BasicUpdates();
	VUI_CHANGE_FONTS();
	if event == "VARIABLES_LOADED" then
		VUI_CHECK_SETUPSTATUS();
		if AddonActive("SW_Stats") then SW_NukeDataCollection(); end
	elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" or event == "PARTY_MEMBERS_CHANGED" then
		
	elseif event == "NEW_AUCTION_UPDATE" then
		VUI_AHquickset();
	elseif event == "PLAYER_TARGET_CHANGED" then
		--CastSequenceReset();
	elseif event == "LOOT_CLOSED" then
		updateFarmItem();
	elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
		--IronfoeLNGblock();
	end
end


function VUI_BasicUpdates()
	if (GetNumRaidMembers()> 1) then if AddonActive("GridEnhanced") then if GridLayout ~= nil then GridLayout:Grid_UpdateSort() end end end
	if ((GetNumPartyMembers() < 1) and (GetNumRaidMembers() < 1)) or VUI_IsInBG() then
		if AddonActive("KLHThreatmeter") then if KLHTM_Frame ~= nil then if KLHTM_Frame:IsVisible() then KLHTM_Frame:Hide() end end end
		if AddonActive("SW_Stats") then if SW_BarFrame1 ~= nil then if SW_BarFrame1:IsVisible() then SW_BarFrame1:Hide() end end end
	end
	if (GetNumPartyMembers() > 1) and not VUI_IsInBG() or (GetNumRaidMembers() > 1) and not VUI_IsInBG() then if AddonActive("KLHThreatmeter") then if not KLHTM_Frame:IsVisible() then KLHTM_Frame:Show() end end end
end

function VUI_KTM_AUTOHIDE()	-- todo
	if vuiktmhidden == nil then vuiktmhidden = false end
	if not vuiktmhidden then
		if VUI_IsInBG() then 
			KLHTM_Frame:Hide()
			vuiktmhidden = true
		end
	elseif vuiktmhidden then
		if ((GetNumPartyMembers() > 1) or (GetNumRaidMembers() > 1)) then
			if not VUI_IsInBG() then 
				KLHTM_Frame:Show()
				vuiktmhidden = false
			end
		end
	end
end

function VUI_IsInBG()
	local IsInBG = false;
	for i=1,80 do
		local bgname = GetBattlefieldScore(i)	
		if bgname then
			IsInBG = true
		end
	end
	return IsInBG
end

function VUI_SendQueueMSGs(style)
	if VUI_Queuecnt > 0 then
		local post;
		if style == 1 then post = MSG; else post = SendChat; end
		local cnt = table.getn(VUI_QueueMSG)
		for i=1,cnt do
			post(VUI_QueueMSG[1]);
			table.remove(VUI_QueueMSG, 1);
		end
		VUI_Queuecnt = 0;
	end
end

function VUI_QueueThisMSG(msg)
	VUI_Queuecnt = VUI_Queuecnt+1;
	VUI_QueueMSG[VUI_Queuecnt] = msg;
end

-- AH stuff


function VUI_AHquickset()
	if GetAuctionSellItemInfo() then
		local imname ,_ , imcount = GetAuctionSellItemInfo();
		local itmname,itmcount,itmbid,itmbuyout,setbid,setbuyout;
		for i=1,50 do
			itmname ,_ , itmcount ,_ ,_ ,_ ,itmbid , _ ,itmbuyout = GetAuctionItemInfo("owner",i);
			if (itmname == imname) then 
				if (not setbid and not setbuyout) or ((itmbid < setbid) and (itmbuyout < setbuyout)) then
					if imcount ~= itmcount then
						local a = imcount/itmcount;
						setbid = itmbid * a;
						setbuyout = itmbuyout * a;
					else
						setbid = itmbid;
						setbuyout = itmbuyout;
					end
				end
			end
		end
		if setbid and setbuyout then
			StartAuction(setbid,setbuyout,1440);
		end
	end
end

-- f

function VUI_CHANGE_FONTS()
	local basicfont = "Interface\\AddOns\\!ViroUI\\Fonts\\Basic.ttf"
	local dmgfont = "Interface\\AddOns\\!ViroUI\\Fonts\\Damage.ttf"
	local numfont = "Interface\\AddOns\\!ViroUI\\Fonts\\Numbers.ttf"
	
	UNIT_NAME_FONT = basicfont;
    DAMAGE_TEXT_FONT = dmgfont;
    NAMEPLATE_FONT = basicfont;
    STANDARD_TEXT_FONT = basicfont;
	
	--GameFontNormal:SetFont(basicfont,15,"THINOUTLINE")
	--GameFontHighlight:SetFont(basicfont,12)
	
	QuestTitleFont:SetFont(basicfont, 19)
    QuestTitleFont:SetShadowOffset(1, -1)
	QuestFontHighlight:SetFont(basicfont, 22)
    QuestFontHighlight:SetShadowOffset(1, -1)
	
	ErrorFont:SetFont(basicfont, 16)
	
	ZoneTextFont:SetFont(basicfont, 106, "THICKOUTLINE")
    ZoneTextFont:SetTextColor(1.0, 0.9294, 0.7607)
    ZoneTextFont:SetShadowColor(0, 0, 0)
    ZoneTextFont:SetShadowOffset(1, -1)
	
	GameTooltipHeaderText:SetFont(basicfont, 15)
    GameTooltipHeaderText:SetTextColor(1.0, 1.0, 1.0)
	
	WorldMapTextFont:SetFont(basicfont, 106, "THICKOUTLINE")
    WorldMapTextFont:SetTextColor(1.0, 0.9294, 0.7607)
    WorldMapTextFont:SetShadowColor(0, 0, 0)
    WorldMapTextFont:SetShadowOffset(1, -1)
	
	InvoiceTextFontNormal:SetFont(basicfont, 14)
    InvoiceTextFontNormal:SetTextColor(0.18, 0.12, 0.06)
    InvoiceTextFontSmall:SetFont(basicfont, 12)
    InvoiceTextFontSmall:SetTextColor(0.18, 0.12, 0.06)
	
	NumberFontNormal:SetFont(numfont, 13, "THINOUTLINE")
    NumberFontNormal:SetTextColor(1.0, 1.0, 1.0)
    NumberFontNormalYellow:SetFont(numfont, 3, "THINOUTLINE")
    NumberFontNormalYellow:SetTextColor(1.0, 0.82, 0)
    NumberFontNormalSmall:SetFont(numfont, 11, "THINOUTLINE")
    NumberFontNormalSmall:SetTextColor(1.0, 1.0, 1.0)
    NumberFontNormalSmallGray:SetFont(numfont, 10, "THINOUTLINE")
    NumberFontNormalSmallGray:SetTextColor(0.75, 0.75, 0.75)
    NumberFontNormalLarge:SetFont(numfont, 14, "OUTLINE")
    NumberFontNormalLarge:SetTextColor(1.0, 1.0, 1.0)
    NumberFontNormalHuge:SetFont(numfont, 26, "THICKOUTLINE")
    NumberFontNormalHuge:SetTextColor(1.0, 1.0, 1.0)
	
    
end

function VUI_AUTOSAVE(nr)
	
	if nr then MSG("Character saved") end
end