if not RDXM.ThreatMeter then RDXM.ThreatMeter = {}; end

function RDXM.ThreatMeter.Init()
	if klhtm then
		if klhtm.boss then
			klhtm.boss.newmastertarget = function(author, target)
				klhtm.boss.mastertarget = target
				klhtm.out.print(string.format(klhtm.string.get("print", "network", "newmt"), target, author))
			end
		end
	end
end

function RDXM.ThreatMeter.SendMasterTarget(monsterName)
	if klhtm.net.checkpermission() == nil then
		return
	end

	klhtm.net.sendmessage("target " .. monsterName)
end

-- set the ktm channel override
RDXEvent:Bind("VARIABLES_LOADED", nil, function() VFL.schedule(5, function() RDXM.ThreatMeter.Init(); end); end);