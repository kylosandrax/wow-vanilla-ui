
--------------------------------------
-- TWIN EMPS
--------------------------------------
-- Emp status variables
local emp_lor_side = nil
local emp_telelock = false;

local emp_mutlock = false;
local emp_explock = false;

local emp_lor_track = nil;
local emp_lor_sigupdate = nil;
local emp_lash_track = nil;
local emp_lash_sigupdate = nil;

function RDXM.AQ.EmpsResetData()
	emp_lor_side = "Right";
	emp_telelock = false;
	RDXM.AQ.EmpsRepaintWindow();
end


-- Teleportation
function RDXM.AQ.EmpsCast(arg)
	if string.find(arg, "gains Mutate Bug") then
		--RPC.Invoke("emps_mut");
		--I dont much care about the dumb mutate bugs...
		return;
	end
	if string.find(arg, "gains Explode Bug") then
		--RPC.Invoke("emps_exp");
		--instead of invoking, lets just show the message...
			RDXM.AQ.EmpsExplode()
		return;
	end
	if not string.find(arg, "Emperor") then return; end
	if string.find(arg, "Teleport") then
		RDXM.AQ.EmpsTeleport();
		return;
	end
end

function RDXM.AQ.EmpsMutate()
	if emp_mutlock then return; end
	emp_mutlock = true; VFL.schedule(2, function() emp_mutlock = false; end);
	RDX.Alert.Simple("Mutant bug! Kill it!", "Sound\\Doodad\\BellTollNightElf.wav", 3, true);
end

function RDXM.AQ.EmpsExplode()
	if emp_explock then return; end
	emp_explock = true; VFL.schedule(2, function() emp_explock = false; end);
	RDX.Alert.Simple("Exploding bug! Run!", "Sound\\Doodad\\BellTollNightElf.wav", 3, true);
end

function RDXM.AQ.EmpsTeleport()
	-- Spamlock
	if emp_telelock then return; end
	emp_telelock = true;
	VFL.schedule(20, function() emp_telelock = false; end);
	-- Propagate teleport signal
	RPC.Invoke("emps_tele");
	-- Dingit baby
	RDX.Alert.Simple("Teleport!", "Sound\\Doodad\\BellTollAlliance.wav", 3);
	-- Switch sides
	if emp_lor_side == "Left" then emp_lor_side = "Right"; else emp_lor_side = "Left"; end

	-- Repaint window
	RDXM.AQ.EmpsRepaintWindow();
	-- Post-teleport activities
	RDXM.AQ.EmpsPostTeleport();
end

function RDXM.AQ.EmpsPostTeleport()
	RDX.Alert.Dropdown("emps_nextteleport", "Next Teleport", 30, 7, "Sound\\Doodad\\BellTollAlliance.wav");
end

-- Window
function RDXM.AQ.EmpsRepaintWindow()
	local emp_lash_side = "Left";
	if emp_lor_side == "Left" then emp_lash_side = "Right"; end
	RDXM.AQ.EmpsRepaintLor(getglobal("AQEmpsFrameTextTop" .. emp_lor_side), getglobal("AQEmpsFrameText" .. emp_lor_side));
	RDXM.AQ.EmpsRepaintLash(getglobal("AQEmpsFrameTextTop" .. emp_lash_side), getglobal("AQEmpsFrameText" .. emp_lash_side));
end

function RDXM.AQ.EmpsRepaintLor(txt1, txt2)
	txt1:SetText(strcolor(0,0.8,0.7) .. "Vek'lor (Magic)|r");
	local tname = strcolor(.5,.5,.5) .. "(unknown)|r";
	if emp_lor_track and emp_lor_track:IsTracking() and emp_lor_track.target then
		tname = emp_lor_track.targetName;
	end
	local ptext = "";
	txt2:SetText("Target: " .. tname .. ptext);
end

function RDXM.AQ.EmpsRepaintLash(txt1, txt2)
	txt1:SetText(strcolor(0.9,0.4,0.0) .. "Vek'nilash (Melee)|r");
	local tname = strcolor(.5,.5,.5) .. "(unknown)|r";
	if emp_lash_track and emp_lash_track:IsTracking() and emp_lash_track.target then
		tname = emp_lash_track.targetName;
	end
	txt2:SetText("Target: " .. tname);
end

-- Metacontrol
function RDXM.AQ:EmpsUpdate()
	RDX.AutoUpdateEncounterPane(emp_lash_track);
	RDX.AutoStartStopEncounter(emp_lash_track);
	if not RDX.EncounterIsRunning() then return; end
	RDXM.AQ.EmpsRepaintWindow();
end

function RDXM.AQ.EmpsDeactivate()
	-- Hide UI
	AQEmpsFrame:Hide();
	-- Unbind events
	VFLEvent:NamedUnbind("emps");
	RPC.UnbindPattern("^emps_");
	-- Remove signals
	if emp_lor_track then
		emp_lor_track.SigUpdate:DisconnectByHandle(emp_lor_sigupdate);
		emp_lor_sigupdate = nil;
	end
	if emp_lash_track then
		emp_lash_track.SigUpdate:DisconnectByHandle(emp_lash_sigupdate);
		emp_lash_sigupdate = nil;
	end
	-- Deestablish tracking
	emp_lor_track = nil;
	emp_lash_track = nil;
end

function RDXM.AQ.EmpsActivate()
	-- Show UI
	AQEmpsFrame:Show();
	--set parent so if we hide the enc pane, this will hide as well
	AQEmpsFrame:SetParent("RDXEncPane");
	-- Bind events
	VFLEvent:NamedBind("emps", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"), function() RDXM.AQ.EmpsCast(arg1); end);
	VFLEvent:NamedBind("emps", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"), function() RDXM.AQ.EmpsCast(arg1); end);
	VFLEvent:NamedBind("emps", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"), function() RDXM.AQ.EmpsCast(arg1); end);
	VFLEvent:NamedBind("emps", BlizzEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"), function() RDXM.AQ.EmpsCast(arg1); end);

	-- Bind RPCs
	RPC.Bind("emps_tele", RDXM.AQ.EmpsTeleport);
	RPC.Bind("emps_mut", RDXM.AQ.EmpsMutate);
	RPC.Bind("emps_exp", RDXM.AQ.EmpsExplode);
	-- Reset data
	RDXM.AQ.EmpsResetData();
	-- Establish tracking
	emp_lor_track = HOT.TrackTarget("Emperor Vek'lor");
	emp_lor_sigupdate = emp_lor_track.SigUpdate:Connect(RDXM.AQ, "EmpsUpdate");
	emp_lash_track = HOT.TrackTarget("Emperor Vek'nilash");
	emp_lash_sigupdate = emp_lash_track.SigUpdate:Connect(RDXM.AQ, "EmpsUpdate");
end

function RDXM.AQ.EmpsStart()
	RDXM.AQ.EmpsResetData();
	RDXM.AQ.EmpsPostTeleport();
	
end

function RDXM.AQ.EmpsStop()

	RDX.QuashAlertsByPattern("^emps_")
		
end

RDXM.AQ.enctbl["emps"] = {
	DeactivateEncounter = RDXM.AQ.EmpsDeactivate;
	ActivateEncounter = RDXM.AQ.EmpsActivate;
	StartEncounter = RDXM.AQ.EmpsStart;
	StopEncounter = RDXM.AQ.EmpsStop;
};