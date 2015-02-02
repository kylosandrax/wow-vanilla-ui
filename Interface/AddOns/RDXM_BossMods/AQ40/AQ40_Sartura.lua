
--------------------------------------
-- BATTLEGUARD SARTURA
--------------------------------------
local sart_track = nil;
local sart_sigupdate = nil;
local sart_alert = nil;
local sart_target = nil;

local whirlwindStart_lock = nil;
local whirlwindFades_lock = nil;

function RDXM.AQ.SarturaActivate()
	-- Establish tracking/signaling
	if not sart_track then
		sart_track = HOT.TrackTarget("Battleguard Sartura");
		sart_sigupdate = sart_track.SigUpdate:Connect(RDXM.AQ, "SarturaUpdate");
	end
	sart_target = nil;
end
function RDXM.AQ.SarturaDeactivate()
	-- Tear down tracking system
	if sart_track then
		sart_track.SigUpdate:DisconnectByHandle(sart_sigupdate);
		sart_sigupdate = nil;
		sart_track = nil;
	end
end
function RDXM.AQ.SarturaStart()
	whirlwindStart_lock = false;
	whirlwindFades_lock = false;
	
	--rpc bind
	RPC.Bind("sartura_whirlwindstart", RDXM.AQ.Sartiura_RPC_WhirlwindStart);
	RPC.Bind("sartura_whirlwindfades", RDXM.AQ.Sartiura_RPC_WhirlwindFades);
	
	if not sart_alert then
	--6/8/06 disabled this alert - it is annoying.
		--sart_alert = RDX.GetAlert();
		--sart_alert:SetText("Sartura's target: (unknown)");
		--sart_alert.tw:Hide();
		--sart_alert:ToCenter(); sart_alert:Show(); sart_alert:SetAlpha(0.6);
	end
	--RDX.Alert.Dropdown("sartura", "Sartura goes supreme in", 600, 30, "Sound\\Doodad\\BellTollAlliance.wav");
	
	--bind chat events
	VFLEvent:NamedBind("sartura", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"), function() RDXM.AQ.SarturaWhirlwind(arg1); end);
	VFLEvent:NamedBind("sartura", BlizzEvent("CHAT_MSG_MONSTER_EMOTE"), function() RDXM.AQ.SarturaWhirlwind(arg1); end);
		

end

function RDXM.AQ.SarturaStop()
	--if sart_alert then
		---sart_alert:Fade(2,0);
		--sart_alert:Schedule(3, function(self) self:Destroy(); end);
		--sart_alert = nil;
	--end
	--unbind events
	VFLEvent:NamedUnbind("sartura");
	--unbind RPC
	RPC.UnbindPattern("^ouro_");
	--Quash
	RDX.QuashAlertsByPattern("^sartura");
	
	sart_target = nil;
end

function RDXM.AQ.SarturaWhirlwind(arg1)

--add code for when sartura gains / loses whirlwind
	if string.find(arg1, "gains Whirlwind")  then
		--RPC the message if we aren't locked
		if (whirlwindStart_lock == false) then
			RPC.Invoke("sartura_whirlwindstart")
		end
	end
	if string.find(arg1, "Whirlwind fades") then
		--RPC the message if we aren't locked
		if (whirlwindFades_lock == false) then
			RPC.Invoke("sartura_whirlwindfades")
		end
	end

end

function RDXM.AQ.Sartiura_RPC_WhirlwindFades()

	if (whirlwindFades_lock == false) then
		whirlwindFades_lock = true;
		VFL.schedule(5, function() whirlwindFades_lock = false; end);
		RDX.Alert.Dropdown("sartura_whirlwindfades", "Next Whirlwind (stun now!)", 8, 8, nil, {r=.1, g=.45, b=.8},{r=.1, g=.45, b=.8});
	end

end


function RDXM.AQ.Sartiura_RPC_WhirlwindStart()

	if (whirlwindStart_lock) == false then
			whirlwindStart_lock = true;
			VFL.schedule(10, function() whirlwindStart_lock = false; end);
		RDX.Alert.Dropdown("sartura_whirlwindstart", "Whirlwind", 15, 15, nil, {r=.65,g=.30,b=.16}, {r=.65,g=.30,b=.16});
	end
end




function RDXM.AQ:SarturaUpdate()
	RDX.AutoUpdateEncounterPane(sart_track);
	RDX.AutoStartStopEncounter(sart_track);
	if not RDX.EncounterIsRunning() then return; end
	-- If there's no target, set to unknown
	if (not sart_track:IsTracking()) or (not sart_track.targetIsRaider) then
		--if sart_target then
			--sart_target = nil;
			--sart_alert:SetText("Sartura's target: (unknown)");
			--PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav");
		--end
		return;
	end
	-- If the target has changed, update...
	if(sart_track.targetName ~= sart_target) then
		sart_target = sart_track.targetName;
		--sart_alert:SetText("Sartura's target: " .. sart_target);
		-- If it's me, oh noes
		if(sart_target == UnitName("player")) then
			RDX.Alert.CenterPopup(nil, "SARTURA IS ON YOU!", 5, "Sound\\Doodad\\BellTollAlliance.wav");
		else
			--PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav");
		end
	end		
end

RDXM.AQ.enctbl["sartura"] = {
	DeactivateEncounter = RDXM.AQ.SarturaDeactivate;
	ActivateEncounter = RDXM.AQ.SarturaActivate;
	StartEncounter = RDXM.AQ.SarturaStart;
	StopEncounter = RDXM.AQ.SarturaStop;
};