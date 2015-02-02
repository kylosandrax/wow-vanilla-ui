--[[
	Turn-In Mod
	version 1.3
	Authored by Ian Friedman
		Sabindeus of Skullcrusher (Alliance)
	The repeatable quest turn in automating machine.
	
	todo: always select certain types of gossip options? kill off those pesky gryphon dialogues!
]]

TI_Version = 1.3;
local TI_slashtable;
local TI_gossipclosed;
local TI_gossipnumber;
TI_gossipopts = {};
local TI_GossipTypes = {"binder", "gossip", "vendor", "taxi", "quest", "battlemaster"};

local TI_DefaultStatus = {
	switch = false,
	qnum = 0,
	rnum = 0,
	greedy = true,
	version = 1.3
};

local TI_events = {
	"GOSSIP_SHOW",
	"GOSSIP_CLOSED",
	"QUEST_DETAIL",
	"QUEST_COMPLETE",
	"QUEST_PROGRESS",
	"QUEST_GREETING",
	"QUEST_FINISHED"
};

function TI_message(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function TI_OnLoad()
	SlashCmdList["TI"]=TI_SlashCmdHandler;
	SLASH_TI1="/turnin";
	SLASH_TI2="/ti";
	TI_message("Turn-In Mod loaded");
	TI_slashtable = {};
	TI_gossipopts = {};
	TI_gossipclosed = false;
	TurnIn:RegisterEvent("VARIABLES_LOADED");
	TI_gossipnumber = 1;
end

function TI_VarInit()
	if(not TI_status) then
		TI_status = TI_copyTable(TI_DefaultStatus);
		return;
	end
	if(TI_status.version ~= TI_Version) then
		TI_status = TI_copyTable(TI_DefaultStatus);
	end
end

function TI_LoadEvents() 
	for k,v in pairs(TI_events) do 
		TurnIn:RegisterEvent(v);
	end
end

function TI_UnloadEvents() 
	for k,v in pairs(TI_events) do 
		TurnIn:UnregisterEvent(v);
	end
end

function TI_SlashCmdHandler(cmd)
	cmdlist = TI_split(cmd, " ");
	if(cmdlist[1] == "on") then
		TI_status.switch = true;
		TI_LoadEvents();
		TI_message("Turn-In Mod On");
	end
	if(cmdlist[1] == "off") then
		TI_status.switch = false;
		TI_UnloadEvents();
		TI_message("Turn-In Mod Off");
	end
	if(cmdlist[1] == "toggle") then
		if(TI_status.switch) then
			TI_status.switch = false;
			TI_UnloadEvents();
			TI_message("Turn-In Mod Off");
		else
			TI_status.switch = true;
			TI_LoadEvents();
			TI_message("Turn-In Mod On");
		end
	end
	if(cmdlist[1] == "status") then
		if(TI_status.switch) then
			TI_message("Turn-In Mod On");
		else
			TI_message("Turn-In Mod Off");
		end
		TI_message(string.format("Option Number set to %d", TI_status.qnum));
		TI_message(string.format("Reward Number set to %d", TI_status.rnum));
		if(TI_status.greedy) then 
			TI_message("Turn-In Greedy Mode On");
		else
			TI_message("Turn-In Greedy Mode Off");
		end
		TI_message("Automatic Gossip Options:");
		
	end
	if(cmdlist[1] == "qnum") then
		newqnum = tonumber(cmdlist[2]);
		TI_status.qnum = newqnum;
		TI_message(string.format("Option Number set to %d", TI_status.qnum));
	end
	if(cmdlist[1] == "rnum") then
		newrnum = tonumber(cmdlist[2]);
		TI_status.rnum = newrnum;
		TI_message(string.format("Option Number set to %d", TI_status.rnum));
	end
	if(cmdlist[1] == "greedy") then
		if(TI_status.greedy) then 
			TI_status.greedy = false;
			TI_message("Turn-In Greedy Mode Off");
		else
			TI_status.greedy = true;
			TI_message("Turn-In Greedy Mode On");
		end
	end
	if(cmdlist[1] == "auto") then
		
	end
end


function TI_OnEvent(event)
	if(event == "VARIABLES_LOADED") then
		TI_VarInit();
		if(TI_status.switch) then 
			TI_LoadEvents();
		end
	end
	if(TI_status.switch) then 
		if(event == "QUEST_GREETING") then
			TI_HandleQuestGreeting();
		end
		if(event == "GOSSIP_SHOW") then
			TI_HandleGossipWindow();
		end
		if(event == "GOSSIP_CLOSED") then
			TI_gossipclosed = true;
		end
		if(event == "QUEST_COMPLETE") then
			GetQuestReward(TI_status.rnum);
		end
		if(event == "QUEST_PROGRESS") then
			if(IsQuestCompletable()) then
				CompleteQuest();
				TI_gossipnumber = 1;
			else
				DeclineQuest();
				TI_gossipnumber = TI_gossipnumber + 1;
			end
		end
		if(event == "QUEST_DETAIL") then
			AcceptQuest();
			TI_gossipnumber = 1;
		end
	end
end

function TI_HandleGossipWindow()
	-- according to GossipFrame.lua, the order in which things are put into gossip option buttons is: Available, Active, Options
	local AvailableQuests = TI_StripDescriptors(GetGossipAvailableQuests());
	local ActiveQuests = TI_StripDescriptors(GetGossipActiveQuests());
	local GossipOptions = TI_StripDescriptors(GetGossipOptions());
	
	local TotalOptions = AvailableQuests.n+ActiveQuests.n+GossipOptions.n;
	
	TI_gossipopts = TI_consolidateopts(AvailableQuests, ActiveQuests, GossipOptions);
	if(TI_gossipnumber > TotalOptions) then 
		TI_gossipnumber = 1;
		return;
	end;
	
	if(TotalOptions > 0) then
		-- first check the option we want
		if(TI_status.qnum > 0 and TI_status.qnum <= TotalOptions) then
			local x = TI_gossipopts[TI_status.qnum];
			x.f(x.n);
		else
			-- well if our option was out of range.. and we're being greedy we need to pick the first one
			if(TI_status.greedy) then
				local x = TI_gossipopts[TI_gossipnumber];
				x.f(x.n);
			end
		end
		
	end
end

function TI_HandleQuestGreeting()
-- according to my observations... active then available
	local AvailableQuests = {n=GetNumAvailableQuests()};
	local ActiveQuests = {n=GetNumActiveQuests()};
	local TotalOptions = AvailableQuests.n+ActiveQuests.n;
	if(TI_gossipnumber > TotalOptions) then 
		TI_gossipnumber = 1;
		return;
	end;
	if(TotalOptions > 0) then
		-- first check the option we want
		if(TI_status.qnum > 0 and TI_status.qnum <= TotalOptions) then
			if(TI_status.qnum <= ActiveQuests.n) then
				SelectActiveQuest(TI_status.qnum);
			elseif(TI_status.qnum <= AvailableQuests.n+ActiveQuests.n) then
				SelectAvailableQuest(TI_status.qnum-ActiveQuests.n);
			end
		else
			-- well if our option was out of range.. and we're being greedy we need to pick the first one
			-- rules for quest windows is that you want to get all the quests first then turn them in... right?
			if(TI_status.greedy) then
				if(AvailableQuests.n > 0) then 
					SelectAvailableQuest(TI_gossipnumber);
				elseif(ActiveQuests.n > 0) then
					SelectActiveQuest(TI_gossipnumber);
				end
			end
		end
		
	end
end

function TI_consolidateopts(availables, actives, gossips)
	local t, oldn = TI_gossipopts, 0;
	
	if ( not t ) then
		t = {};
	else
		oldn = table.getn(t);
		table.setn(t, 0);
	end
	
	for i=1, availables.n, 1 do
		local newentry = {};
		newentry.f = SelectGossipAvailableQuest;
		newentry.n = i;
		table.insert(t, newentry);
	end
	for i=1, actives.n, 1 do
		local newentry = {};
		newentry.f = SelectGossipActiveQuest;
		newentry.n = i;
		table.insert(t, newentry);
	end
	for i=1, gossips.n, 1 do
		local newentry = {};
		newentry.f = SelectGossipOption;
		newentry.n = i;
		table.insert(t, newentry);
	end
			
	
	for i = table.getn(t)+1, oldn do
		t[i] = nil;
	end
	
	return t;

end


function TI_OnUpdate(dt)
	if(TI_status.switch) then
		if(TI_gossipclosed) then
			TI_gossipclosed = false;
			CompleteQuest();
		end
	end
end

function TI_StripDescriptors(...)
	local x = {n=0};
	for i=1, arg.n, 2 do
		table.insert(x,arg[i]);
	end
	return x;
end

--[[	This split function shamelessly pirated from the Sea library. 
		Credit goes to Thott and Legorol and the whole Cosmos team... I only stole it to remove dependencies.
		Some people don't like to have to install libraries. :/
	]]
function TI_split ( text, separator) 
		local value;
    	local init, mstart, mend = 1;
		local t, oldn = TI_slashtable, 0;
		
		if ( not t ) then
			t = {};
		else
			oldn = table.getn(t);
			table.setn(t, 0);
		end
				
    	repeat
			mstart, mend, value = string.find(text, "([^"..separator.."]+)", init);
			if ( value ) then
				table.insert(t, value)
				init = mend + 1;
			end
    	until not value;
		
		for i = table.getn(t)+1, oldn do
			t[i] = nil;
		end
		
		return t;
end;
	
	
--[[this function stolen from WhisperCast by Sarris, whom I love dearly for his contribution to Paladins everywhere. 
]]
function TI_copyTable( src )
    local copy = {}
    for k1,v1 in src do
        if ( type(v1) == "table" ) then
            copy[k1]=TI_copyTable(v1)
        else
            copy[k1]=v1
        end
    end
    
    return copy
end