
-------------------------------------
-- FIREMAW
------------------------------------
RDXM.BWL.fbEnabled = nil;
RDXM.BWL.fbCurrent = 0;
RDXM.BWL.fbAlert = nil;

---------- Flame Buffet handling
function RDXM.BWL.FBCheck()
	-- Find the Flame Buffet debuff
	local i = 1;
	while UnitDebuff("player", i) do
		-- Get info from tip
		VFLTipTextLeft1:SetText(nil);
		VFLTipTextLeft2:SetText(nil);
		VFLTip:SetUnitDebuff("player", i);
		local dn, dd = VFLTipTextLeft1:GetText(), VFLTipTextLeft2:GetText();
		-- Check for flame buffet
		if dn and dn == "Flame Buffet" then
			-- Extract flamebuffet status
			local s,e,v = string.find(dd, "(%d+)");
			if(v) then RDXM.BWL.FBSet(tonumber(v)); end
			return;
		end
		i = i + 1;
	end
	-- No flame buffet!
	RDXM.BWL.FBSet(0);
end

function RDXM.BWL.FBSet(n)
	local alert = RDXM.BWL.fbAlert;
	if not alert then return; end
	if(n == RDXM.BWL.fbCurrent) then return; end
	RDXM.BWL.fbCurrent = n;
	alert:SetText("Your flame buffet: " .. strcolor(1,0,0) .. n .. "|r");
	PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav");
end

function RDXM.BWL.FBTick()
	if(RDXM.BWL.fbEnabled) then
		RDXM.BWL.FBCheck();
		VFL.schedule(1, RDXM.BWL.FBTick);
	end
end

-- Encounter metacontrol
local fm_track = nil;
local fm_sigupdate = nil;
function RDXM.BWL.FiremawActivate()
	VFLEvent:NamedBind("firemaw", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.BWL.WingBuffetParse(arg1); end);
	VFLEvent:NamedBind("firemaw", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.BWL.ShadowflameParse(arg1); end);
	if not fm_track then
		fm_track = HOT.TrackTarget("Firemaw");
		fm_sigupdate = fm_track.SigUpdate:Connect(RDXM.BWL, "FiremawUpdate");
	end
end
function RDXM.BWL.FiremawDeactivate()
	VFLEvent:NamedUnbind("firemaw");
	if fm_track then
		fm_track.SigUpdate:DisconnectByHandle(fm_sigupdate);
		fm_sigupdate = nil; fm_track = nil;
	end
end
function RDXM.BWL.FiremawStart()
	if not RDXM.BWL.fbEnabled then
		-- Start flame buffet
		RDXM.BWL.fbEnabled = true;
		local alert = RDX.GetAlert();
		alert:SetText("Your flame buffet: " .. strcolor(1,0,0) .. "0|r");
		alert.tw:Hide();
		alert:ToCenter(); alert:Show(); alert:SetAlpha(0.5);
		RDXM.BWL.fbAlert = alert;
		VFL.schedule(1, RDXM.BWL.FBTick);
	end
end
function RDXM.BWL.FiremawStop()
	-- Shutoff flame buffet
	RDXM.BWL.fbEnabled = false;
	if RDXM.BWL.fbAlert then
		RDXM.BWL.fbAlert:Fade(2,0);
		RDXM.BWL.fbAlert:Schedule(3, function(self) self:Destroy(); end);
		RDXM.BWL.fbAlert = nil;
	end
end

function RDXM.BWL.FiremawUpdate()
	RDX.AutoStartStopEncounter(fm_track);
	RDX.AutoUpdateEncounterPane(fm_track);
end

-- Firemaw event map
RDXM.BWL.enctbl["firemaw"] = {
	DeactivateEncounter = RDXM.BWL.FiremawDeactivate;
	ActivateEncounter = RDXM.BWL.FiremawActivate;
	StartEncounter = RDXM.BWL.FiremawStart;
	StopEncounter = RDXM.BWL.FiremawStop;
};