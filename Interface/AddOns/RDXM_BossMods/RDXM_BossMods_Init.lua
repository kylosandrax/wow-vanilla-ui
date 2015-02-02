if not RDXM.BossMods then RDXM.BossMods = {}; end

------------------------------
-- Initalize Encounter Tables
------------------------------

if not RDXM.MC then RDXM.MC = {}; end
if not RDXM.MC.enctbl then RDXM.MC.enctbl = {}; end

if not RDXM.BWL then RDXM.BWL = {}; end
if not RDXM.BWL.enctbl then RDXM.BWL.enctbl = {}; end

if not RDXM.ZG then RDXM.ZG = {}; end
if not RDXM.ZG.enctbl then RDXM.ZG.enctbl = {}; end

if not RDXM.AQ20 then RDXM.AQ20 = {}; end
if not RDXM.AQ20.enctbl then RDXM.AQ20.enctbl = {}; end

if not RDXM.AQ then RDXM.AQ = {}; end
if not RDXM.AQ.enctbl then RDXM.AQ.enctbl = {}; end

if not RDXM.World then RDXM.World = {}; end
if not RDXM.World.enctbl then RDXM.World.enctbl = {}; end

if not RDXM.PVP then RDXM.PVP = {}; end
if not RDXM.PVP.enctbl then RDXM.PVP.enctbl = {}; end

if not RDXM.NAXW then RDXM.NAXW = {}; end
if not RDXM.NAXW.enctbl then RDXM.NAXW.enctbl = {}; end

if not RDXM.NAXE then RDXM.NAXE = {}; end
if not RDXM.NAXE.enctbl then RDXM.NAXE.enctbl = {}; end

function RDXM.BossMods.SetThreatMasterTarget(monsterName, delay)
	--error check
	if not IsAddOnLoaded("RDXM_ThreatMeter") then 
		VFL.print("[RDX] Could not find the Threat Meter module.");
		return; 
	end

	if not monsterName then 
		VFL.print("Error:  SetThreatMasterTarget requires a monsterName");
		return; 
	end

	if not delay then
		--send right away
		RDXM.ThreatMeter.SendMasterTarget(monsterName);
	else
		--they want to delay the message
		VFL.schedule(delay, function() RDXM.ThreatMeter.SendMasterTarget(monsterName); end);
	end
end

