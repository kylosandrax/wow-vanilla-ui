
-------------------------------------
-- CHROMAGGUS
-------------------------------------
local chrom_track = nil;
local chrom_sigupdate = nil;

-- Deactivate Chromaggus mod
function RDXM.BWL.ChromDeactivate()
	VFLEvent:NamedUnbind("chrom");
	RPC.UnbindPattern("^chrom");
	if chrom_track then
		chrom_track.SigUpdate:DisconnectByHandle(chrom_sigupdate);
		chrom_sigupdate = nil;
		chrom_track = nil;
	end
end
-- Activate Chromaggus mod
function RDXM.BWL.ChromActivate()
	VFLEvent:NamedBind("chrom", BlizzEvent("CHAT_MSG_MONSTER_EMOTE"), function() RDXM.BWL.ChromOnEmote(arg1); end);
	VFLEvent:NamedBind("chrom", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.BWL.ChromOnCVCD(arg1); end);
	RPC.Bind("chrom_breath", function(sender, n) RDXM.BWL.ChromBreath(n, true); end);
	if not chrom_track then
		chrom_track = HOT.TrackTarget("Chromaggus");
		chrom_sigupdate = chrom_track.SigUpdate:Connect(RDXM.BWL, "ChromUpdate");
	end
end

function RDXM.BWL.ChromUpdate()
	RDX.AutoStartStopEncounter(chrom_track);
	RDX.AutoUpdateEncounterPane(chrom_track);
end

-- Chromaggus encounter on-start
function RDXM.BWL.ChromStart()
	VFL.debug("RDXM.BWL.ChromStart()", 4);
	-- Create timers for the first two unknown breaths.
	RDX.Alert.Dropdown("chrom", "Unknown breath", 30, 8, "Sound\\Doodad\\BellTollAlliance.wav", {r=.5,g=.5,b=.5});
	RDX.Alert.Dropdown("chrom", "Unknown breath", 62, 8, "Sound\\Doodad\\BellTollAlliance.wav", {r=.5,g=.5,b=.5});
end

-- Chromaggus encounter on-stop (remove all breath handlers)
function RDXM.BWL.ChromStop()
	RDX.QuashAlertsByPattern("^chrom");
end

-- Chromaggus mod emote handler
function RDXM.BWL.ChromOnEmote(arg)
	if(arg == "goes into a killing frenzy!") then
		if UnitClass("player") == "Hunter" then
			RDX.Alert.Simple("CHROMAGGUS FRENZY!", "Sound\\Doodad\\BellTollAlliance.wav", 5, true);
		end
	elseif(arg == "flinches as its skin shimmers.") then
		if UnitClass("player") == "Mage" or UnitClass("player") == "Warlock" then
			RDX.Alert.Simple("Chromaggus Resists Changed!", nil, 5, true);
		end
	end
end

-- Chromaggus mod CVCD handler
function RDXM.BWL.ChromOnCVCD(arg)
	if(arg == "Chromaggus begins to cast Time Lapse.") then
		RDXM.BWL.ChromBreath(1);
	elseif(arg == "Chromaggus begins to cast Ignite Flesh.") then
		RDXM.BWL.ChromBreath(2);
	elseif(arg == "Chromaggus begins to cast Corrosive Acid.") then
		RDXM.BWL.ChromBreath(3);
	elseif(arg == "Chromaggus begins to cast Incinerate.") then
		RDXM.BWL.ChromBreath(4);
	elseif(arg == "Chromaggus begins to cast Frost Burn.") then
		RDXM.BWL.ChromBreath(5);
	end
end

-- Chromaggus breath table
RDXM.BWL.chrom_breaths = {
	{name = "chrom_tl", text = "Time Lapse - 8 sec stun/deaggro", color={r=.65,g=.30,b=.16}},
	{name = "chrom_if", text = "Ignite Flesh - bigass DoT", color={r=1, g=.33, b=0}},
	{name = "chrom_ca", text = "Corrosive Acid - Nature nuke/sunder", color={r=.2, g=.75, b=.12}},
	{name = "chrom_in", text = "Incinerate - Fire nuke", color={r=1, g=.33, b=0}},
	{name = "chrom_fb", text = "Frost Burn - Frost nuke/slow", color={r=.1, g=.45, b=.8}},
};

-- Chromaggus breath type multiplexer
function RDXM.BWL.ChromBreath(n, nosync)
	local breathTime, leadTime, sound = 62, 10, "Sound\\Doodad\\BellTollAlliance.wav";
	-- Get breath data
	local btbl = RDXM.BWL.chrom_breaths[n];
	if not btbl then 
		VFL.debug("RDXM.BWL.ChromBreath(): recieved invalid breath id ("..n..")", 3);
		return; 
	end
	-- If there's already a high-timer alert for this breath, ignore
	for _,alert in RDX.alerts do
		if(alert.name == btbl.name) and alert.GetCountdown and (alert.GetCountdown() > 10) then return; end
	end
	-- Create the alert
	RDX.Alert.Dropdown(btbl.name, btbl.text, breathTime, leadTime, sound, btbl.color);
	-- If announce is on, broadcast on bossmob sync channel
	if(not nosync) and (RDXU.spam) then
		RPC.Invoke("chrom_breath", n);
	end
end


-- Chromaggus event map
RDXM.BWL.enctbl["chromaggus"] = {
	DeactivateEncounter = RDXM.BWL.ChromDeactivate;
	ActivateEncounter = RDXM.BWL.ChromActivate;
	StartEncounter = RDXM.BWL.ChromStart;
	StopEncounter = RDXM.BWL.ChromStop;
};