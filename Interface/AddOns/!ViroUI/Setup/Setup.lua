function VUI_SETUP(profile,skipresolution)
	if VUI_CHARset == 3 then
		SendChat("VUI is already installed")
	else
	VUI_PROFILENAME(profile);
	VUI_BASIC_SETUP(skipresolution);
	VUI_DE_USELESS_ADDONS();
	
	if AddonActive("DiscordArt") and AddonActive("DiscordArtOptions") then DART_CREATEPROFILE(VUI_PROFILENAME) end
	if AddonActive("DiscordUnitFrames") and AddonActive("DiscordUnitFramesOptions") then DUF_CREATEPROFILE(VUI_PROFILENAME) end
	if AddonActive("DiscordActionBars") and AddonActive("DiscordActionBarsOptions") then DAB_New_Profile(VUI_PROFILENAME) end
	
	if AddonActive("Atlas") then AtlasOptions["AtlasButtonShown"] = false; end
	if AddonActive("AtlasLoot") then AtlasLootOptions["MinimapButton"]= false; end
	if AddonActive("Bagnon") then BagnonSets = VUI_BAGNON; end
	if AddonActive("Prat") then PratDB = VUI_PRAT; end
	if AddonActive("SHunterTimers") then if UnitClass("player") == "Hunter" then SHTvars = VUI_SHT; else DisableAddOn("SHunterTimers"); end end
	if AddonActive("BigWigs") then BigWigsDB = VUI_BIGWIGS; end
	if AddonActive("oCB") then 
		oCBDB = {["profiles"] = {}}
		oCBDB.profiles[VUI_PROFILENAME] = VUI_OCB;
	end
	if AddonActive("Buffalo") then 
		BuffaloDB = {["profiles"] = {}}
		BuffaloDB.profiles[VUI_PROFILENAME] = VUI_BUFFALO;
	end
	if AddonActive("EQL3") then QuestlogOptions[EQL3_Player] = VUI_EQL3; end
	if AddonActive("!OmniCC") then OmniCC = VUI_OMNICC; end
	if AddonActive("oRA2") then oRADB = VUI_ORA; end
	if AddonActive("oSkin") then oSkinDB = VUI_OSKIN; end
	if AddonActive("simpleMinimap") then smmConfig = VUI_SMM; end
	if AddonActive("TipBuddy") then TipBuddy_SavedVars = VUI_TIPBUDDY; end
	if AddonActive("TotemTimers") then if UnitClass("player") == "Shaman" then TTData = VUI_TOTEMTIMER; else DisableAddOn("TotemTimers"); end end
	if AddonActive("KLHThreatMeter") then KLHTM_SavedVariables = VUI_KTM; KLHTM_Frame:SetPoint("TOPLEFT",1079,-896); end
	if AddonActive("SpellAlert") and AddonActive("SpellAlertOptions") then SAConfig = VUI_SPELLALERT; end
	if AddonActive("GridEnhanced") then
		GridLayout.db.profile.showParty = false;
		GridLayout.db.profile.FrameDisplay = "grouped";
		GridLayout.db.profile.Padding = 0;
		GridLayout.db.profile.BorderA = 0;
		GridLayout.db.profile.BackgroundA = 0;
		GridFrame.db.profile.invertBarColor = true;
		if profile == "tankdps" then
			GridLayout.db.profile.PosX = 314.94857781086;
			GridLayout.db.profile.PosY = 139.97205282295;
		elseif profile == "healer" then
			GridLayout.db.profile.PosX = 450.26299668905;
			GridLayout.db.profile.PosY = 266.21461616326;
			GridLayout.db.profile.Spacing = 3;
			GridFrame.db.profile.FontSize = 10;
			GridFrame.db.profile.FrameHeight = 32;
			GridFrame.db.profile.FrameWidth = 58;
		end
		GridLayout.db.profile.FrameLock = true;
		GridEnhancedDB.profiles.Default.showText = false;
	end
	if AddonActive("CThunWarner") then 
		CThunWarnerStatus_Alarm = 1
		CThunWarnerStatus_Timer = 1
		CThunWarnerStatus_Locked = 1
		CThunWarnerStatus_PlaySound = 0
		CThunWarnerStatus_Scale = 3
		CThunWarnerStatus_ShowList = 4
		CThunWarnerStatus_SoundPhase2 = 0
		CThunWarnerFrame:SetPoint("TOPLEFT",67,-172);
	end
	if AddonActive("MetaMap") then
		MetaMapOptions.MetaMapMiniCoords = false;
		MetaMapOptions.MetaMapButtonShown = false;
	end
	if AddonActive("SW_Stats") then SW_Settings = VUI_SWS; end
	-- SCT
	if AddonActive("sct") then
		local sctprofile = "char/"..GetUnitName("player").." of "..GetRealmName();
		SCT_CONFIG.profiles[sctprofile] = VUI_SCT;
		if AddonActive("sct_cooldowns") then sctcOptions = VUI_SCTC; end
		
	end
	-- FUBAR
	if AddonActive("FuBar") then
		FuBar2DB = VUI_FUBAR;
		if AddonActive("BigWigs") then BigWigsFubarDB = VUI_FUBAR_BIGWIGS; end
		if AddonActive("Fubar_AtlasFu2") then AtlasFuDB = VUI_FUBAR_ATLAS; end
		if AddonActive("FuBar_ClockFu") then ClockFuDB = VUI_FUBAR_CLOCK; end
		if AddonActive("FuBar_DurabilityFu") then DurabilityFuDB = VUI_FUBAR_DURABILITY; end
		if AddonActive("FuBar_FuXPFu") then FuXPDB = VUI_FUBAR_XP; end
		if AddonActive("FuBar_MailFu") then FuBar_MailDB = VUI_FUBAR_MAIL; end
		if AddonActive("FuBar_PerformanceFu") then PerformanceFuDB = VUI_FUBAR_PERFORMANCE; end
		if AddonActive("oRA2") then oRAFubarDB = VUI_FUBAR_ORA; end
	end
	if profile == "healer" then 
		VUI_DUF_HEALER(1);
		VUI_DART_HEALER();
		VUI_DAB_HEALER();
		if AddonActive("KLHThreatMeter") then DisableAddOn("KLHThreatMeter") end
	end
	
	VUI_CHARset = 1;
	ReloadUI()
	end
end

VUI_CHARprofiles = {}
VUI_PROFILENAME = ""
function VUI_PROFILENAME(profile)
	local prname = "";
	if profile == "tankdps" then prname = "Tank/DPS"
	elseif profile == "healer" then prname = "Healer"
	elseif profile == "bankalt" then prname = "Bank" end
	VUI_CHARprofile = profile;
	if profile ~= nil then VUI_PROFILENAME = UnitName("player").." - "..prname; end
	
	local cp = table.getn(VUI_CHARprofiles)
	for a=1,cp do
		if VUI_PROFILENAME ~= VUI_CHARprofiles[a] then 
			local b = a+1;
			VUI_CHARprofiles[b] = VUI_PROFILENAME end
	end
end

local CHARset,ACCset;
local vuian = false;
function VUI_CHECK_SETUPSTATUS()
	if VUI_ACCset == nil then 
		VUI_ACCset = true; 
		VUI_BASIC_SETUP();
		end
	if VUI_CHARset == nil then VUI_CHARset = 0; end
	if VUI_CHARset == 0 then
		if vuian == false then MSG("VUI hasn't been installed yet"); vuian = true; end
	elseif VUI_CHARset == 1 then
		MSG("VUI has been installed");
		VUI_SetupFailed();
		VUI_CHARset = 2;
		VUI_SETUPONCE()
	elseif VUI_CHARset == 2 then
		SendChat("ViroUI loaded..");
	end
	VUI_ADDONCHECK();
end

local VUI_ADDONLIST = {"Atlas",
	"AtlasLoot",
	"Bagnon",
	"Bagnon_Core",
	"Bagnon_Forever",
	"Bagnon_Options",
	"Banknon",
	"BigWigs",
	"Buffalo",
	"Decursive",
	"DiscordActionBarsOptions",
	"DiscordActionBars",
	"DiscordArt",
	"DiscordArtOptions",
	"DiscordLibrary",
	"DiscordUnitFrames",
	"DiscordUnitFramesOptions",
	"EQL3",
	"Fubar_AtlasFu2",
	"FuBar_ClockFu",
	"FuBar_DurabilityFu",
	"FuBar_FuXPFu",
	"FuBar_MailFu",
	"FuBar_MoneyFu",
	"FuBar_PerformanceFu",
	"FuBar",
	"GridEnhanced",
	"KLHThreatMeter",
	"MetaMap",
	"CEnemyCastBar",
	"CECB_Options",
	"oCB",
	"oSkin",
	"Prat",
	"sct",
	"sctd",
	"sct_cooldowns",
	"sct_killingblows",
	"sct_options",
	"sctd_options",
	"simpleMinimap",
	"simpleMinimap_Autozoom",
	"simpleMinimap_Coords",
	"simpleMinimap_GUI",
	"simpleMinimap_Location",
	"simpleMinimap_Movers",
	"simpleMinimap_Pings",
	"simpleMinimap_Skins",
	"SHunterTimers",
	"SpellAlert",
	"SpellAlertOptions",
	"SW_Stats",
	"TipBuddy",
	"TotemTimers",
	"XLoot"
}
local VUI_ADDONNOTFOUND = {}

function VUI_ADDONCHECK()
	local al = table.getn(VUI_ADDONLIST);
	for i=1,al do
		if not AddonActive(VUI_ADDONLIST[i]) then 
			local ant = table.getn(VUI_ADDONNOTFOUND) + 1;
			VUI_ADDONNOTFOUND[ant] = VUI_ADDONLIST[i];
		end
	end
end

function VUI_SetupFailed()
	local ant = table.getn(VUI_ADDONNOTFOUND);
	if ant > 0 then
		for b=1,ant do
			SendChat("VUI Setup - "..VUI_ADDONNOTFOUND[b].." was not found and got skipped.")
		end
	end
end

function VUI_BASIC_SETUP(skipresolution)
	if not skipresolution then SetCVar("gxResolution", "1680x1050") end
	SetCVar("useUiScale", 1)
	SetCVar("UIScale", 0.69999998807907)
	SetCVar("minimapZoom", 0)
	SetCVar("minimapInsideZoom", 0)
	SetCVar("profanityFilter", 0)
	SetCVar("farclip",177)
end

function VUI_DE_USELESS_ADDONS()
	local pclass = UnitClass("player");
	if AddonActive("Casterstats") then
		if pclass == "Warrior" or pclass == "Rogue" or pclass == "Hunter" then
		DisableAddOn("Casterstats");
		end
	end
	if AddonActive("Totemtimers") and pclass ~= "Shaman" then
		DisableAddOn("Totemtimers");
	end
	if AddonActive("Decursive") then
		if pclass == "Rogue" or pclass == "Warrior" or pclass == "Hunter" or pclass == "Warlock" then
		DisableAddOn("Decursive");
		end
	end
end

local VUI_SHITTERLIST = {}
function VUI_DEACTIVATE_SHITTERS()

end

-- Discord setup functions
function VUI_DUF_HEALER(toggle)
	if (not DUF_VUI_HEALER) then
		DL_Feedback(DUF_TEXT.NoDefaultSettings);
		return;
	end
	DUF_Settings[DUF_INDEX] = {nil};
	DL_Copy_Table(DUF_VUI_HEALER, DUF_Settings[DUF_INDEX]);
	DUF_Settings[DUF_PLAYER_INDEX] = DUF_INDEX;
	if (not toggle) then
		DUF_Initialize_NewSettings();
		DUF_Initialize_AllFrames();
		DL_Feedback(DUF_TEXT.DefaultSettingsLoaded);
	end
end

function VUI_DAB_HEALER()
	DAB_Settings[DAB_INDEX] = {};
	if (DAB_VUI_HEALER) then
		DL_Copy_Table(DAB_VUI_HEALER, DAB_Settings[DAB_INDEX]);
	else
		return true;
	end
end

function VUI_DART_HEALER()
	DART_Settings[DART_INDEX] = {};
	if (DART_VUI_HEALER) then DL_Copy_Table(DART_VUI_HEALER, DART_Settings[DART_INDEX]); end
end

function DUF_CREATEPROFILE(index)
	if (not index) then
		index = DUF_MiscOptions_SaveSettings:GetText();
	end
	if (index == "" or (not index)) then
		return;
	end
	if (DUF_Settings[index]) then
		DL_Error("You are attempting to create a new profile using the same name as an existing profile.  You must delete the existing profile first.");
		return;
	end
	DUF_Settings[index] = {};
	DL_Copy_Table(DUF_Settings[DUF_INDEX], DUF_Settings[index]);
	DUF_INDEX = index;
	DUF_Settings[DUF_PLAYER_INDEX] = index;
	DL_Feedback(DUF_TEXT.ProfileCreated);
end

function DART_CREATEPROFILE(index)
	DART_Settings[index] = {};
	DL_Copy_Table(DART_Settings[DART_INDEX], DART_Settings[index]);
	DART_INDEX = index;
	DART_Settings[DART_PROFILE_INDEX] = index;
	DART_Init_ProfileList();
	DL_Feedback(DART_TEXT.NewProfileCreated..DART_INDEX);
end

function DART_Init_ProfileList()
	DART_PROFILE_LIST = {};
	local i = 0;
	for profile in DART_Settings do
		if (profile ~= "CustomTextures" and (not string.find(profile, " : "))) then
			i = i + 1;
			DART_PROFILE_LIST[i] = { text=profile, value=profile };
		end
	end
end
-- -- --

function VUI_CHAT_SETUP()
	-- left window
	ChatFrame1:ClearAllPoints();
	ChatFrame1:SetFrameStrata("MEDIUM");
	ChatFrame1:SetPoint("TOPLEFT",8,-901);
	ChatFrame1:SetWidth(437);
	ChatFrame1:SetHeight(139);
	ChatFrame1:SetUserPlaced(true);
	
	-- right window
	if ChatFrame3:IsVisible() then
		ChatFrame3:ClearAllPoints();
		ChatFrame3:SetFrameStrata("MEDIUM");
		ChatFrame3:SetWidth(437);
		ChatFrame3:SetHeight(139);
		ChatFrame3:SetPoint("TOPLEFT",1307,-901);
		ChatFrame3:SetUserPlaced(true);
		
	-- right window if combat log
	elseif ChatFrame2:IsVisible() then
		ChatFrame2:ClearAllPoints();
		ChatFrame2:SetFrameStrata("MEDIUM");
		ChatFrame2:SetWidth(437);
		ChatFrame2:SetHeight(139);
		ChatFrame2:SetPoint("TOPLEFT",1307,-901);
		ChatFrame2:SetUserPlaced(true);
	end
end

function VUI_SWS_SETUP()
	local ang = 239; local r = 90; SW_IconFrame:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 58 - (r * cos(ang)), (r * sin(ang)) - 58);
	-- resizing the mainframe
	SW_BarFrame1:SetWidth(378);
	SW_BarFrame1:SetHeight(175);
	-- positioning the mainframe
	SW_BarFrame1:SetPoint("TOPLEFT",186,-30);
end

function VUI_SETUPONCE()
	VUI_PROFILENAME(VUI_CHARprofile);
	VUI_CHAT_SETUP();
	if AddonActive("SW_Stats") then VUI_SWS_SETUP(); end
	oCB:SetProfile(VUI_PROFILENAME);
	Buffalo:SetProfile(VUI_PROFILENAME);
end