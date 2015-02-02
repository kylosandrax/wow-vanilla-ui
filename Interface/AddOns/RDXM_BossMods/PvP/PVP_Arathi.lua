
local reztimer_lock = false;

function RDXM.PVP.ArathiActivate()

end

function RDXM.PVP.ArathiDeactivate()

end

function RDXM.PVP.ArathiStart()

	reztimer_lock = false;
	 
	-- Events
	VFLEvent:NamedBind("arathi", BlizzEvent("PLAYER_DEAD"), function() RDXM.PVP.ArathiPlayerDiedEvent(); end);
	VFLEvent:NamedBind("arathi", BlizzEvent("PLAYER_UNGHOST"), function() RDXM.PVP.ArathiSpiritRezEvent(); end);
	-- RPC Binds
	RPC.Bind("arathi_reztimer", RDXM.PVP.ArathiRezTimerEvent);
	
end

function RDXM.PVP.ArathiStop()
	
	RDX.QuashAlertsByPattern("^arathi_");
	
	--remove scheduled loop
	VFL.removeScheduledEventByName("arathi_reztimer");
		
	
	-- Unbind Events
	VFLEvent:NamedUnbind("arathi");
	-- Unbind RPCs
	RPC.UnbindPattern("^arathi_");
	
end


function RDXM.PVP.ArathiRezTimerEvent()
	
	if (reztimer_lock==false) then
		reztimer_lock = true;
	
		--remove any scheduled loop
		VFL.removeScheduledEventByName("arathi_reztimer");
			
		-- start rez timer
		--RDX.QuashAlertsByPattern("^arathi_");
		--RDX.Alert.Dropdown("arathi_reztimer", "Next Resurrection", 30, 1, nil)
				
		--start recursive loop.
		RDXM.PVP.ArathiRezTimerLoop(0)
		--VFL.scheduleExclusive("arathi_reztimer", 32, function() RDXM.PVP.ArathiRezTimerLoop(); end);
		--VFL.schedule(3, function() reztimer_lock = false; end);
		--Note i set this to never unlock unless the mod is stopped and restarted cause it seems accurate
		-- and i have no way of knowing if somoene clicked "accept" to a body rez (compared to autorez)
		-- if it gets desynced the mod should just be stopped and restarted
		
	end
		
end


function RDXM.PVP.ArathiPlayerDiedEvent()
	--Auto Release!
	RepopMe();

end

function RDXM.PVP.ArathiSpiritRezEvent()
		
	--RPC the rez timer!
	RPC.Invoke("arathi_reztimer")

end

function RDXM.PVP.ArathiRezTimerLoop(cnt)
			
		if cnt == nil then cnt = 0 end
			
		--remove any scheduled loop
		VFL.removeScheduledEventByName("arathi_reztimer");
		RDX.QuashAlertsByPattern("^arathi_");
		
		--do another dropdown.
		RDX.Alert.Dropdown("arathi_reztimer", cnt .. "] Next Resurrection", 30.5, 1, nil)
		--recursive
		VFL.scheduleExclusive("arathi_reztimer", 30.5, function() RDXM.PVP.ArathiRezTimerLoop(cnt+1); end);

end




RDXM.PVP.enctbl["arathi"] = {
	ActivateEncounter = RDXM.PVP.ArathiActivate;
	DeactivateEncounter = RDXM.PVP.ArathiDeactivate;
	StartEncounter = RDXM.PVP.ArathiStart;
	StopEncounter = RDXM.PVP.ArathiStop;
};


