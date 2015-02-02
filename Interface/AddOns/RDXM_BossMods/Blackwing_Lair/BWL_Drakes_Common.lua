
-------------------------------------
-- DRAKES (COMMON)
-------------------------------------
function RDXM.BWL.ShadowflameParse(line)
	if string.find(line, "begins to cast Shadow Flame") then
		RDXM.BWL.Shadowflame();
	end
end

function RDXM.BWL.Shadowflame()
	local sound = "Sound\\Doodad\\BellTollAlliance.wav";
	for _,alert in RDX.alerts do
		if alert.name and (alert.name == "sf") and alert.GetCountdown and (alert.GetCountdown() > 10) then return; end
	end
	RDX.QuashAlertsByPattern("sf");
	RDX.Alert.CenterPopup(nil, "SHADOW FLAME", 2, sound, nil, {r=.7,g=.3,b=.3});
	--Edited to delay 2 seconds before starting a new timer - this also extends it 2 seconds which is good also
	VFL.schedule(2, function() RDX.Alert.Dropdown("sf", "Next Shadow Flame", 20, 3, nil, {r=.7,g=.3,b=.3}); end);
end


function RDXM.BWL.WingBuffetParse(line)
	if string.find(line, "begins to cast Wing Buffet") then
		-- BUGFIX: For double wing buffet warning -- check to see if there's already a high WB countdown before
		-- moving on.
		for _,alert in RDX.alerts do
			if alert.name and (alert.name == "wb") and alert.GetCountdown and (alert.GetCountdown() > 10) then return; end
		end
		RDX.QuashAlertsByPattern("wb");
		RDX.Alert.CenterPopup(nil, "Wing Buffet - Aggro Reduce", 2, nil, nil);
		--Edited to delay 2 seconds before starting a new timer - this also extends it 2 seconds which is good also
		VFL.schedule(2, function() RDX.Alert.Dropdown("wb", "Next wing buffet", 30, 3, nil); end);
	end
end	

