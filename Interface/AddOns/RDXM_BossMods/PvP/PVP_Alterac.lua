
local reztimer_lock = false;

function RDXM.PVP.AlteracActivate()

end

function RDXM.PVP.AlteracDeactivate()

end

function RDXM.PVP.AlteracStart()

	reztimer_lock = false;
	 
	-- Events
	VFLEvent:NamedBind("alterac", BlizzEvent("PLAYER_DEAD"), function() RDXM.PVP.AlteracPlayerDiedEvent(); end);
	VFLEvent:NamedBind("alterac", BlizzEvent("PLAYER_UNGHOST"), function() RDXM.PVP.AlteracSpiritRezEvent(); end);
	-- RPC Binds
	RPC.Bind("alterac_reztimer", RDXM.PVP.AlteracRezTimerEvent);
	
end

function RDXM.PVP.AlteracStop()
	
	RDX.QuashAlertsByPattern("^alterac_");
	
	--remove scheduled loop
	VFL.removeScheduledEventByName("alterac_reztimer");
		
	
	-- Unbind Events
	VFLEvent:NamedUnbind("alterac");
	-- Unbind RPCs
	RPC.UnbindPattern("^alterac_");
	
end


function RDXM.PVP.AlteracRezTimerEvent()
	
	if (reztimer_lock==false) then
		reztimer_lock = true;
	
		--remove any scheduled loop
		VFL.removeScheduledEventByName("alterac_reztimer");
			
		-- start rez timer
		--RDX.QuashAlertsByPattern("^alterac_");
		--RDX.Alert.Dropdown("alterac_reztimer", "Next Resurrection", 30, 1, nil)
				
		--start recursive loop.
		RDXM.PVP.AlteracRezTimerLoop(0)
		--VFL.scheduleExclusive("alterac_reztimer", 32, function() RDXM.PVP.AlteracRezTimerLoop(); end);
		--VFL.schedule(3, function() reztimer_lock = false; end);
		--Note i set this to never unlock unless the mod is stopped and restarted cause it seems accurate
		-- and i have no way of knowing if somoene clicked "accept" to a body rez (compared to autorez)
		-- if it gets desynced the mod should just be stopped and restarted
		
	end
		
end


function RDXM.PVP.AlteracPlayerDiedEvent()
	--Auto Release!
	RepopMe();

end

function RDXM.PVP.AlteracSpiritRezEvent()
		
	--RPC the rez timer!
	RPC.Invoke("alterac_reztimer")

end

function RDXM.PVP.AlteracRezTimerLoop(cnt)
		
		if cnt == nil then cnt = 0 end
		--remove any scheduled loop
		VFL.removeScheduledEventByName("alterac_reztimer");
		RDX.QuashAlertsByPattern("^alterac_");
		
		--do another dropdown.
		RDX.Alert.Dropdown("alterac_reztimer", cnt .. "] Next Resurrection", 33.5, 1, nil)
		--recursive
		VFL.scheduleExclusive("alterac_reztimer", 33.5, function() RDXM.PVP.AlteracRezTimerLoop(cnt+1); end);

end




RDXM.PVP.enctbl["alterac"] = {
	ActivateEncounter = RDXM.PVP.AlteracActivate;
	DeactivateEncounter = RDXM.PVP.AlteracDeactivate;
	StartEncounter = RDXM.PVP.AlteracStart;
	StopEncounter = RDXM.PVP.AlteracStop;
};



--function RDX.PrintScheduledEvents()
--		table.foreachi(VFL_sched, function(i) if (VFL_sched[i].name ~= nil) then VFL.print(i .. " - " .. VFL_sched[i].name); else	VFL.print(i);	end end);
--end

	

