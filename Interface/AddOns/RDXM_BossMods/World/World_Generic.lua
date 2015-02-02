
--------------------------------------
-- Generic
--------------------------------------

generic_triggerlock = false;

function RDXM.World.GenericActivate()
	--RDX.Alert.Simple("Generic Mod Loaded.", nil, 3, true);
	
end

function RDXM.World.GenericDeactivate()
	RDX.QuashAlertsByPattern("^generic_")
	RDX.QuashAlertsByPattern("^gentriggers_")

	VFLEvent:NamedUnbind("gentriggers");
	VFLEvent:NamedUnbind("generic");
end

function RDXM.World.GenericStart()

	RPC.Bind("generic_simple_alert", RDXM.World.GenericSimpleAlert);
	RPC.Bind("generic_simple_alert_withsound", RDXM.World.GenericSimpleAlertWithsound);
	RPC.Bind("generic_simple_dropdowntimer", RDXM.World.GenericSimpleDropdownTimer);
	RPC.Bind("generic_unique_dropdowntimer", RDXM.World.GenericUniqueDropdownTimer);
end


function RDXM.World.GenericStop()

	RDX.QuashAlertsByPattern("^generic_")
	VFLEvent:NamedUnbind("generic");
end



	--*************************************************************************************--
	--*  The generic simple alert pops up a simple alert in the middle of the screen      *--
	--*************************************************************************************--

function RDXM.World.GenericSimpleAlert(sender, n)
	RDX.Alert.Simple(n, nil, 3, true);
end
function RDXM.World.GenericSendSimpleAlert(txt)
	RPC.Invoke("generic_simple_alert", txt);
end


	--*************************************************************************************--
	--*  		The generic simple alert with added sound effect  		      *--
	--*************************************************************************************--

function RDXM.World.GenericSimpleAlertWithsound(sender, n)
	RDX.Alert.Simple(n, "Sound\\Doodad\\BellTollNightElf.wav", 3, true);
end
function RDXM.World.GenericSendSimpleAlertWithsound(txt)
	RPC.Invoke("generic_simple_alert_withsound", txt);
end


	--*************************************************************************************--
	--*  		A simple countdown alert which goes to the middle   		      *--
	--*  		of the screen and flashes red at 5 seconds to go   		      *--
	--*************************************************************************************--

function RDXM.World.GenericSimpleDropdownTimer(sender, n, secs)

	RDX.Alert.Dropdown("generic_customdropdowntimer",n, secs, 5, "Sound\\Doodad\\BellTollAlliance.wav")
end
function RDXM.World.GenericSendSimpleDropdownTimer(txt, secs)
	RPC.Invoke("generic_simple_dropdowntimer", txt, secs)
end


	--*************************************************************************************--
	--*  		A same as dropdown timer except that only 1 instance   		      *--
	--*  		will exist at a time.  If the function is called again 		      *--
	--*  		with the same identifier, the old one is replaced by the new          *--
	--*  		instead of a 2nd one created			  		      *--
	--*************************************************************************************--


function RDXM.World.GenericUniqueDropdownTimer(sender, n, secs, identifier)
	RDX.QuashAlertsByPattern("^generic_customuniquedropdowntimer_" .. identifier)
	RDX.Alert.Dropdown("generic_customuniquedropdowntimer_" .. identifier, n, secs, 5, "Sound\\Doodad\\BellTollAlliance.wav")
end

function RDXM.World.GenericSendUniqueDropdownTimer(txt, secs, identifier)
	RPC.Invoke("generic_unique_dropdowntimer", txt, secs, identifier)
end



	--*************************************************************************************--
	--*  		This function allows anyone to bind a countdowntimer   		      *--
	--*  		based on string "searchstring" being in a chat message 		      *--
	--*  		of channel "triggerchannel".  It will last duration "duration"	      *--
	--*  		and show the message "desc".  Identifier is used to overlap the msg   *--
	--*  		if it's popped up again.					      *--
	--*************************************************************************************--


function RDXM.World.BindTimerTrigger(desc, duration, triggerchannel, searchstring, identifier)
	VFL.print("Binding Trigger...");

	VFLEvent:NamedBind("gentriggers", BlizzEvent(triggerchannel), 
		function()
			--VFL.print("Trigger has fired!!!!");	
			if string.find(arg1, searchstring) then
				--VFL.print("String was in it!!");
				if generic_triggerlock == false then
					generic_triggerlock = true;
					RDXM.World.GenericSendUniqueDropdownTimer(desc, duration, identifier); 
					VFL.schedule(1, function() generic_triggerlock = false; end);
				end
			end
		end
	);
end


function RDXM.World.ClearTriggers()

	RDX.QuashAlertsByPattern("^gentriggers_")
	VFLEvent:NamedUnbind("gentriggers");

end


	--*****************************--
	--* Main Encounter Definition *--
	--*****************************--

RDXM.World.enctbl["generic"] = {

	ActivateEncounter = RDXM.World.GenericActivate;
	DeactivateEncounter = RDXM.World.GenericDeactivate;
	StartEncounter = RDXM.World.GenericStart;
	StopEncounter = RDXM.World.GenericStop;
};