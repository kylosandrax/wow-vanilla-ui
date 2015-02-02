if not RDXM.Logistics.RaidStatus then RDXM.Logistics.RaidStatus = {} end;
local raidstatuswindow = nil; --stores a pointer to our window

local intlist = ""; local kingslist = ""; local marklist = ""; local fortlist = ""; local mightlist = ""; local salvlist = ""; local wisdomlist = ""; local lightlist = ""; local spiritlist = "";
local inttot = 0; local kingstot = 0; local marktot = 0; local forttot = 0; local mighttot = 0; local salvtot = 0; local wisdomtot = 0; local lighttot = 0; local spirittot = 0;
local intcnt = 0; local kingscnt = 0; local markcnt = 0; local fortcnt = 0; local mightcnt = 0; local salvcnt = 0; local wisdomcnt = 0; local lightcnt = 0; local spiritcnt = 0;
local totalcnt = 0; local totaltot = 0;

--******************
-- Initializaiton
--******************

function RDXM.Logistics.RaidStatus.Init()
	if RDX5Data.RaidStatuscfg then
		local cfg = RDX5Data.RaidStatuscfg;
		if cfg.active then
			--Show the raid screen and start the heartbeat
			RDXM.Logistics.RaidStatus.Show()
		end
	else
		--the config has not been defined - lets do that now just for the sake of having it.
		RDX5Data.RaidStatuscfg = {active = false, x=0, y=0};
	end	
end


--******************
-- Creates the window structure, and shows it.
-- Also defines functions for window updating, and click actions
--******************

function RDXM.Logistics.RaidStatus.Show()

	if raidstatuswindow then return; end

	
	-- First create a window.
	local w = RDXM.LogisticsWindow:new();
	w:Setup("Raid Status", 100);
		w.list = {};
	w.Repaint = function()
		-- Layout the window
		RDX.LayoutRDXWindow(w, table.getn(w.list), 0, 1, table.getn(w.list), w.fnAcquireCell);
		-- Paint the window
		RDX.PaintRDXWindow(w, w.list, 0, w.displayed, w.fnApplyData);
	end
	w.window.btnI.OnMouseUp = function()
		w.window:StopMovingOrSizing();
		RDXM.Logistics.RaidStatus.SavePosition();
	end
	w.window.btnClose.OnClick = function() 
		RDX5Data.RaidStatuscfg.active = false; --closing window is same as turning raid status off.
		w.visible = nil;
		w.window:Hide(); 
		w.grid:Destroy();
		raidstatuswindow = nil; --remove reference
	end
	-- Apply data function paints name and zone
	w.fnApplyData = function(ud, c)
		--local u = ud.unit;
		c:SetPurpose(1);
		c.text1:SetText(ud.title); 
		c.text1:SetTextColor(1,1,1);
		c.text2:SetText(ud.valuestr);
		c.text2:SetTextColor(0.8,0.8,0.8);
		c.bar1:SetStatusBarColor(ud.r, ud.g, ud.b);
		c.bar1:SetValue(ud.val);
		
		if ud.title == "Here" then
			c.OnClick = function() RDXM.Logistics.RaidStatus.PrintWhosNotHere(); end
		elseif ud.title == "Dead" then
			c.OnClick = function() RDXM.Logistics.RaidStatus.PrintWhosDead(); end
		elseif ud.title == "Mana" then
			c.OnClick = function() RDXM.Logistics.RaidStatus.TargetLowestManaHealer(); end
		elseif ud.title == "Buffs" then
			c.OnClick = function() RDXM.Logistics.RaidStatus.PrintBuffReport(arg1); end
		end
		
	end

	--do we have valid positions?
	if RDX5Data.RaidStatuscfg then
		if RDX5Data.RaidStatuscfg.x ~= 0 then
			--yes, so set position on screen
			w.window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", RDX5Data.RaidStatuscfg.x, RDX5Data.RaidStatuscfg.y);
		end
	end

	--show the window
	w:Show();
	w.Repaint();
	raidstatuswindow = w;

	RDXM.Logistics.RaidStatus.HeartBeat()
end


--******************
-- Click events - fired off when someone clicks on a status item
--******************


function RDXM.Logistics.RaidStatus.TargetLowestManaHealer()
	--target the healer in the raid who is the lowest mana.
	
	local lowestHealer = ""
	local lowestHealerMana = 1.1; --fraction
	local unitToTarget = nil;
	
	for i=1,40 do
		if RDX.unit[i].valid and RDX.unit[i]:IsHealer() and RDX.unit[i]:IsOnline() and RDX.unit[i]:IsInDataRange() then
		
			if RDX.unit[i]:FracMana() < lowestHealerMana then
				lowestHealerMana = RDX.unit[i]:FracMana()
				unitToTarget = i;
			end
		end
	end
	if unitToTarget then
		TargetUnit(RDX.unit[unitToTarget].uid);
	end
end

function RDXM.Logistics.RaidStatus.PrintWhosNotHere()
	--print out everyone who is not here.
	local printStr = "";
	for i=1,40 do
		
		if RDX.unit[i].valid then
			--is the player "here"?
			
			if not RDX.unit[i]:IsInDataRange() then
				printStr = printStr .. RDX.unit[i].name .. " "
			end
		end

	end
	
	if printStr == "" then
		VFL.CC.Popup(nil, "Raid Status: Here", "Everyone is here.");
	else
		VFL.CC.Popup(nil, "Raid Status: Here", "Players not here: " .. printStr);
	end
	
end

function RDXM.Logistics.RaidStatus.PrintWhosDead()
	--print out everyone is slained
	local printStr = "";
	for i=1,40 do
		
		if RDX.unit[i].valid then
			--is the player "here"?
			
			if RDX.unit[i]:IsDead() then
				printStr = printStr .. RDX.unit[i].name .. " "
			end
		end

	end
	
	if printStr == "" then
		VFL.CC.Popup(nil, "Raid Status: Dead", "Everyone is alive.");
	else
		VFL.CC.Popup(nil, "Raid Status: Dead", "Players who are dead: " .. printStr);
	end
end

function RDXM.Logistics.RaidStatus.PrintBuffReport(arg1)

	if arg1 == "RightButton" then
		--VFL.print(lightcnt .. ">>" .. lighttot);
		--VFL.print(kingscnt .. ">>" .. kingstot);
		--VFL.print(markcnt .. ">>" .. marktot);
		--VFL.print(fortcnt .. ">>" .. forttot);
		--VFL.print(mightcnt .. ">>" .. mighttot);
		--VFL.print(salvcnt .. ">>" .. salvtot);
		--VFL.print(wisdomcnt .. ">>" .. wisdomtot);
		--VFL.print(spiritcnt .. ">>" .. spirittot);
	
		--right click
		local printStr = "";
		if fortlist ~= "" then
			printStr = printStr .. "Fortitude: " .. fortlist .. "\n\n";
		end
		if marklist ~= "" then
			printStr = printStr .. "Mark: " .. marklist .. "\n\n";
		end
		if kingslist ~= "" then
			printStr = printStr .. "Kings: " .. kingslist .. "\n\n";
		end
		--if lightlist ~= "" then
		--	printStr = printStr .. "Light: " .. lightlist .. "\n\n";
		--end
		if mightlist ~= "" then
			printStr = printStr .. "Might: " .. mightlist .. "\n\n";
		end
		if salvlist ~= "" then
			printStr = printStr .. "Salvation: " .. salvlist .. "\n\n";
		end
		if wisdomlist ~= "" then
			printStr = printStr .. "Wisdom: " .. wisdomlist .. "\n\n";
		end
		if intlist ~= "" then
			printStr = printStr .. "Arcane Intellect: " .. intlist .. "\n\n";
		end
		if spiritlist ~= "" then
			printStr = printStr .. "Spirit: " .. spiritlist .. "\n\n";
		end

		if printStr == "" then
			VFL.CC.Popup(nil, "Missing Buffs Report", "Everyone is buffed!");
		else
			VFL.CC.Popup(nil, "Missing Buffs Report", printStr, nil, 250);
		end
	else
		--left click
		if RDXM.Buffs.Autobuff then
			RDXM.Buffs.Autobuff();
		else
			VFL.print("Error.. Do you have the buff module installed?");
		end
	end
end

--******************
-- Save the x,y positions (called when the window is moved)
--******************

function RDXM.Logistics.RaidStatus.SavePosition()

	if not raidstatuswindow then return; end
	--save our x, y coordinates
	RDX5Data.RaidStatuscfg.x = raidstatuswindow.window:GetLeft();
	RDX5Data.RaidStatuscfg.y = raidstatuswindow.window:GetTop();
	
end

--******************
-- calculate values and repaint the window.
--******************


	
function RDXM.Logistics.RaidStatus.Update()
	if not raidstatuswindow then return; end
	if not RDX.unit then return; end
	
	--lets loop through our DB and tally our healer mana, the number of dead people, and the number
	--of people who are not in data range.
	local totalmanapercentages = 0;	local deadcount = 0; local numhealers = 0; local not_here_count = 0;

--clear lists
 intlist = ""; kingslist = "";  marklist = "";  fortlist = "";  mightlist = "";  salvlist = "";  wisdomlist = "";  lightlist = "";  spiritlist = "";
 inttot = 0; kingstot = 0;  marktot = 0;  forttot = 0;  mighttot = 0;  salvtot = 0;  wisdomtot = 0;  lighttot = 0;  spirittot = 0;
 intcnt = 0; kingscnt = 0;  markcnt = 0;  fortcnt = 0;  mightcnt = 0;  salvcnt = 0;  wisdomcnt = 0;  lightcnt = 0;  spiritcnt = 0;
 totaltot = 0; totalcnt = 0;


	for i=1,40 do
		if RDX.unit[i].valid then
			
			--is the player "here"?
			local p = RDX.unit[i]:IsInDataRange()
			if not p then
				not_here_count = not_here_count + 1;
			end

			--is the player dead?
			if RDX.unit[i]:IsDead() then
				deadcount = deadcount + 1;
			end
			
			if RDX.unit[i]:IsHealer() and RDX.unit[i]:IsOnline() then
				--this is a healer and online - lets do some math
					totalmanapercentages = totalmanapercentages + RDX.unit[i]:FracMana();
					numhealers = numhealers + 1;
			end
		end
		
		--'*******  Keep an eye on Buff Status as well.  *******
		--1 - warrior; 2 - priest; 3 - mage; 4 - rogue; 5 - paladin; 6 - warlock; 7 - hunter; 8 - druid; 9 - shaman;

		if RDX.unit[i]:IsInDataRange() and not RDX.unit[i]:IsDead() then
			if UnitFactionGroup("player") == "Alliance" then
				--everyone needs kings, mark, fort, light
				kingstot = kingstot + 1;
				--lighttot = lighttot + 1;
			end

			marktot = marktot + 1;
			forttot = forttot + 1;
			if RDX.unit[i]:HasEffect(1) == true then --fort
				fortcnt = fortcnt + 1;
			else
				fortlist = fortlist .. RDX.unit[i].name .. " ";
			end
			if RDX.unit[i]:HasEffect(2) == true then --mark
				markcnt = markcnt + 1;
			else
				marklist = marklist .. RDX.unit[i].name .. " ";
			end	

			--if RDX.unit[i]:HasEffect(44) == true then --light
			--	lightcnt = lightcnt + 1;
			--else
			--	lightlist = lightlist .. RDX.unit[i].name .. " ";
			--end
				
			--people with mana need wisdom and spirit and int (so no warriors or rogues)
			if RDX.unit[i].class ~= 1 and RDX.unit[i].class ~= 4 then
				spirittot = spirittot + 1;
				inttot = inttot + 1;
				if RDX.unit[i]:HasEffect(4) == true then --divine spirit
					spiritcnt = spiritcnt + 1;
				else
					spiritlist = spiritlist .. RDX.unit[i].name .. " ";
				end
				if RDX.unit[i]:HasEffect(3) == true then --arcane intellect
					intcnt = intcnt + 1;
				else
					intlist = intlist .. RDX.unit[i].name .. " ";
				end
			end

			if UnitFactionGroup("player") == "Alliance" then
				--people with mana need wisdom and spirit and int (so no warriors or rogues)
				if RDX.unit[i].class ~= 1 and RDX.unit[i].class ~= 4 then
					wisdomtot = wisdomtot + 1;
					if RDX.unit[i]:HasEffect(42) == true then --wisdom
						wisdomcnt = wisdomcnt + 1;
					else
						wisdomlist = wisdomlist .. RDX.unit[i].name .. " ";
					end	
				end

				if RDX.unit[i]:HasEffect(45) == true then
					 --kings;
					kingscnt = kingscnt + 1;
				else
					kingslist = kingslist .. RDX.unit[i].name .. " ";			
				end
				--Only warriors and rogues for might
				if RDX.unit[i].class == 1 or RDX.unit[i].class == 4 then -- Warrior, rogue
					mighttot = mighttot + 1;
				if RDX.unit[i]:HasEffect(41) == true then --might
						mightcnt = mightcnt + 1;
					else
						mightlist = mightlist .. RDX.unit[i].name .. " ";					
					end	
				end
				--Everyone but warriors and paladins need salv
				if RDX.unit[i].class ~= 1 and RDX.unit[i].class ~= 5 then
					salvtot = salvtot + 1;
					if RDX.unit[i]:HasEffect(43) == true then --salvation
						salvcnt = salvcnt + 1;
					else
						salvlist = salvlist .. RDX.unit[i].name .. " ";
					end			
				end
			end
		end
		
		--'******************************************************		
	end
	

	totaltot = inttot + kingstot + marktot + forttot +  mighttot + salvtot + wisdomtot + lighttot +  spirittot;
	totalcnt = intcnt + kingscnt + markcnt + fortcnt +  mightcnt + salvcnt + wisdomcnt + lightcnt +  spiritcnt;
	local finalBuffVal = 0; --number between 0 and 1
	if totaltot > 0 then
		finalBuffVal = totalcnt / totaltot;
	else
		finalBuffVal = 0;
	end
	
	
	local raidmana;	local deadval; local here_val;
	local numRaidMembers = GetNumRaidMembers();
	
	if numhealers > 0 then raidmana = totalmanapercentages / numhealers; else raidmana = 0;	end
	--for the deadval basically i'm saying the bar will fill up when 10 people are dead, other wise it's #dead/10 %
	deadval = deadcount / 10;
	if deadval > 1 then deadval = 1; end
	
	if numRaidMembers > 0 then
		here_val = (numRaidMembers - not_here_count) / numRaidMembers;
	else
		here_val = 1
		numRaidMembers = 1
	end
	
	raidstatuswindow.list = {}
	table.insert(raidstatuswindow.list, {title="Mana", valuestr = string.format("%0.0f", raidmana * 100) .. "%", val=raidmana, r=.1, g=.1, b=1});
	table.insert(raidstatuswindow.list, {title="Dead",  valuestr= deadcount, val=deadval, r=.8, g=.1, b=.1});
	table.insert(raidstatuswindow.list, {title="Here",  valuestr= numRaidMembers - not_here_count .. " / " .. numRaidMembers, val=here_val, r=.8, g=.2, b=.8});
	table.insert(raidstatuswindow.list, {title="Buffs",  valuestr= totalcnt .. " / " .. totaltot, val=finalBuffVal, r=.5, g=.9, b=.5});
	
	raidstatuswindow.Repaint();
	
end



--******************
-- Heartbeat - update the window every 2 seconds.
--******************


function RDXM.Logistics.RaidStatus.HeartBeat()
	if not raidstatuswindow then return; end
	
	RDXM.Logistics.RaidStatus.Update()	
	VFL.scheduleExclusive("raidstatus_heartbeat", 2, function() RDXM.Logistics.RaidStatus.HeartBeat(); end); --2 second heartbeat
		
end


--******************
-- Toggle - Turn Raid Status monitor on / off
--******************

function RDXM.Logistics.RaidStatus.Toggle()
	if not RDX5Data.RaidStatuscfg then RDX5Data.RaidStatuscfg = {active = false, x=0, y=0}; end
	if raidstatuswindow then --monitor is on.
		--if they turn it off by the slash command then reset the window position as well
		RDX5Data.RaidStatuscfg = nil;
		raidstatuswindow.visible = nil;
		raidstatuswindow.window:Hide(); 
		raidstatuswindow.grid:Destroy();
		raidstatuswindow = nil;
		VFL.print("Raid Status Monitor has been turned off.")
	else
		RDX5Data.RaidStatuscfg.active = true;
		RDXM.Logistics.RaidStatus.Show()
		VFL.print("Raid Status Monitor has been turned on.")
	end
end

