
--------------------------------------
-- ANUBISATHS
--------------------------------------
local anubisath_track = nil;
local anubisath_sigupdate = nil;

local anubisath_exploding_lockout = false;

local anubisath_thunderclapAnnouncement_lockout = false;
local anubisath_plagueAnnouncement_lockout = false;
local anubisath_shadowstormAnnouncement_lockout = false;
local anubisath_meteorAnnouncement_lockout = false;



function RDXM.AQ.AnubisathActivate()

	if not anubisath_track then
		anubisath_track = HOT.TrackTarget("Anubisath Defender");
		anubisath_sigupdate = anubisath_track.SigUpdate:Connect(RDXM.AQ, "AnubisathUpdate");
	end
	
	--RPC Binds
	RPC.Bind("anubisath_exploding", RDXM.AQ.Anubisath_RPC_Exploding);
	
	--Chat Events
	VFLEvent:NamedBind("anubisath", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"), function() RDXM.AQ.AnubisathCheckExplode(arg1); end);
	VFLEvent:NamedBind("anubisath", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"), function() RDXM.AQ.AnubisathCast(arg1); end);
	VFLEvent:NamedBind("anubisath", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.AQ.AnubisathCast(arg1); end);
	VFLEvent:NamedBind("anubisath", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"), function() RDXM.AQ.AnubisathPlagueParse(arg1); end);
	VFLEvent:NamedBind("anubisath", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"), function() RDXM.AQ.AnubisathPlagueParse(arg1); end);
	VFLEvent:NamedBind("anubisath", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"), function() RDXM.AQ.AnubisathPlagueParse(arg1); end);
	
end

function RDXM.AQ.AnubisathDeactivate()
	if anubisath_track then
		anubisath_track.SigUpdate:DisconnectByHandle(anubisath_sigupdate);
		anubisath_sigupdate = nil; anubisath_track = nil;
	end
	
	-- Unbind Events
	VFLEvent:NamedUnbind("anubisath");
	-- Unbind RPCs
	RPC.UnbindPattern("^anubisath_");
	
end

function RDXM.AQ.AnubisathStart()

	--these announcements will only go off once per monster
	anubisath_exploding_lockout = false;
	anubisath_thunderclapAnnouncement_lockout = false;
	anubisath_plagueAnnouncement_lockout = false;
	anubisath_shadowstormAnnouncement_lockout = false;
	anubisath_meteorAnnouncement_lockout = false;

end

function RDXM.AQ.AnubisathStop()
	RDX.QuashAlertsByPattern("^anubisath_")
	ouro_sandblastlock = false;
	ouro_sweeplock = false
end

function RDXM.AQ.AnubisathPlagueParse(chatMsg)

	if chatMsg == nil then return; end
	
	local _,_,player = string.find(chatMsg, "^(%w+) %w+ afflicted by Plague");
	if not player then return; end
	
	-- if we're here, this is definatly a plague message
	
	local name, flash, sound = "", 0, "Sound\\Doodad\\BellTollAlliance.wav";
	if (player == "You") then
		name = UnitName("player"); flash = 20;
		RDX.QuashAlertsByPattern("^anubisath_youareplagued")
		RDX.Alert.CenterPopup("anubisath_youareplagued", "Plague: you are plagued for", 40, sound, 0, {r=0,g=.9,b=.3}, nil, true);
	else
		name = player;
		--if(RDXU.spam) then
			--SendChatMessage("YOU ARE PLAGUED!", "WHISPER", nil, player);
		--end
	end
	
	-- plague announcement
	if anubisath_plagueAnnouncement_lockout == false then
		anubisath_plagueAnnouncement_lockout = true;
		RDX.Alert.CenterPopup("anubisath_plaguewarning", "Plague (Spread Out)", 3, nil, nil, {r=0, g=.9, b=.9}, nil, true);
		RDX.Alert.Spam("PLAGUE - SPREAD OUT!");
	end
		
end


function RDXM.AQ.AnubisathCast(chatMsg)
	
	if chatMsg == nil then return; end --return if illegal chatmsg

	if not string.find(chatMsg, "Anubisath") then return; end -- we only want messages concerning anubisaths
	
	if anubisath_thunderclapAnnouncement_lockout == false then
		if string.find(chatMsg, "Thunderclap") then
			anubisath_thunderclapAnnouncement_lockout = true;
			RDX.Alert.CenterPopup("anubisath_thunderclapwarning", "Thunderclap (Heal Melee)", 3, nil, nil, {r=0, g=.9, b=.9}, nil, true);
			RDX.Alert.Spam("THUNDERCLAP! - KEEP MELEE UP!");
			return;
		end
	end
	if anubisath_meteorAnnouncement_lockout == false then
		if string.find(chatMsg, "Meteor") then
			anubisath_meteorAnnouncement_lockout = true;
			RDX.Alert.CenterPopup("anubisath_meteorwarning", "Meteor (Clump Up)", 5, nil, nil, {r=1, g=.33, b=0}, nil, true);
			RDX.Alert.Spam("METEOR - CLUMP UP!");
			return;
		end
	end
	if anubisath_shadowstormAnnouncement_lockout == false then	
		if string.find(chatMsg, "Shadow Storm") then
			anubisath_shadowstormAnnouncement_lockout = true;
			RDX.Alert.CenterPopup("anubisath_shadowstormwarning", "Shadowstorm (get within 20yd)", 5, nil, nil, {r=1, g=0.1, b=1}, nil, true);
			RDX.Alert.Spam("SHADOW STORM - GET CLOSE!");
			return;
		end
	end


end


function RDXM.AQ.AnubisathCheckExplode(chatMsg)

	if anubisath_exploding_lockout == false then
		if chatMsg == "gains Explode." then
			RPC.Invoke("anubisath_exploding");	
		end
	end

end

function RDXM.AQ.Anubisath_RPC_Exploding()
	--The monster is exploding!
	if anubisath_exploding_lockout == false then
		anubisath_exploding_lockout = true;
		VFL.schedule(15, function() anubisath_exploding_lockout = false; end);

		RDX.Alert.CenterPopup(nil, "EXPLODING!!!", 7, "Sound\\Doodad\\BellTollAlliance.wav", nil, {r=1, g=.33, b=0});
		RDX.Alert.CenterPopup(nil, "EXPLODING!!!", 7, nil, nil, {r=1, g=.33, b=0});
		RDX.Alert.CenterPopup(nil, "EXPLODING!!!", 7, nil, nil, {r=1, g=.33, b=0});
	end
end




function RDXM.AQ.AnubisathUpdate()
	RDX.AutoStartStopEncounter(anubisath_track);
	RDX.AutoUpdateEncounterPane(anubisath_track);
end



RDXM.AQ.enctbl["anubisath"] = {
	ActivateEncounter = RDXM.AQ.AnubisathActivate;
	DeactivateEncounter = RDXM.AQ.AnubisathDeactivate;
	StartEncounter = RDXM.AQ.AnubisathStart;
	StopEncounter = RDXM.AQ.AnubisathStop;
};





