-- Talentsaver AddOn by LYQ(Virose) created for ViroUI
TALENTSAVER_VERSION = 1.1

	-- INIT some vars
	local TALENTS_LOADING = false
	local TALENTS_INT = 1
	local TALENTS_NAME = "none"
	local TALENTS_LASTLOAD = 0

function TALENTSAVER_INIT()
	if TALENTS_SAVED == nil then
		TALENTS_SAVED = {
			VERSION = TALENTSAVER_VERSION,
			DELAY = -1,
			["LIST"] = {},
			["BUILDS"] = {},
			["INFO"] = {},
		}
	end
end

	-- SAVE TALENTS
local function TALENTS_SAVE(name)
	if TALENTS_SAVED == nil then TALENTS_SAVED = {["BUILDS"] = {}} end -- if it's been called the first time on this character
	if TALENTS_SAVED["BUILDS"][name] == nil then
		local template = {}
		for i=1,3 do
			-- the 3 different trees
			for t=1,25 do
				-- all the talents in this tree, idk how many max. can exist in one tree but it must be around 18-25
				if GetTalentInfo(i,t) ~= nil then
					local _, _, _, _, spent = GetTalentInfo(i,t)
					for a=1,spent do template[table.getn(template)+1] = i..t; end
				end
			end
		end
		local specinfo = ""
		for i=1,3 do
			local _, _, spent = GetTalentTabInfo(i)
			if i == 3 then specinfo = specinfo..spent
			else specinfo = specinfo..spent.." /" end
		end
		--
		TALENTS_SAVED["LIST"][table.getn(TALENTS_SAVED["LIST"])+1] = name
		TALENTS_SAVED["BUILDS"][name] = template
		TALENTS_SAVED["INFO"][name] = specinfo
		SendMSG("|cff3be7ed[Talentsaver]|r - Template '"..name.."' has been saved.")
	else
		SendMSG("|cff3be7ed[Talentsaver]|r - Template couldn't be saved. There is already a template named '"..name.."'")
	end
end

	-- LOAD TALENT
local function TALENTS_LOADIT(name,line)
	local template = TALENTS_SAVED["BUILDS"][name]
	local treeNR = tonumber(string.sub(tostring(template[line]),1,1));
	local talentNR = tonumber(string.sub(tostring(template[line]),2));
	LearnTalent( treeNR, talentNR )
end

CreateFrame("Frame","Talentsaver",UIParent)
Talentsaver:RegisterEvent("PLAYER_ENTERING_WORLD")
Talentsaver:SetScript('OnUpdate', function()
	if TALENTS_LOADING and TALENTS_NAME ~= "none" then
		local _, _, latency = GetNetStats()
		local delay = (latency/50*0.4)
		if TALENTS_SAVED.DELAY ~= -1 then delay = TALENTS_SAVED.DELAY/1000 end
		if ((TALENTS_LASTLOAD+delay) <= GetTime()) then
			TALENTS_LOADIT(TALENTS_NAME,TALENTS_INT)
			if TALENTS_INT == table.getn(TALENTS_SAVED["BUILDS"][TALENTS_NAME]) then
				-- finished, reset the process
				SendMSG("|cff3be7ed[Talentsaver]|r - Template '"..TALENTS_NAME.."' has been loaded.")
				TALENTS_LOADING = false
				TALENTS_NAME = "none"
				TALENTS_INT = 1
			else
				-- if not finished, increment the int value
				TALENTS_INT = TALENTS_INT +1
			end
			TALENTS_LASTLOAD = GetTime()
		end
	end
end)
Talentsaver:SetScript('OnEvent', function()
	if event == "PLAYER_ENTERING_WORLD" then
		TALENTSAVER_INIT()
		Talentsaver:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

function SendMSG(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

SLASH_TALENTSAVER1 = "/talentsaver";
SLASH_TALENTSAVER2 = "/talents";
SlashCmdList["TALENTSAVER"] = function(msg)
	if string.find(msg,"load") or string.find(msg,"Load") or string.find(msg,"LOAD") then
		msg = string.sub(msg,6)
		if TALENTS_SAVED["BUILDS"][msg] ~= nil then
			TALENTS_LOADING = true
			TALENTS_NAME = msg
			TALENTS_INT = 1
			SendMSG("|cff3be7ed[Talentsaver]|r - Template '"..msg.."' started loading.")
		else SendMSG("|cff3be7ed[Talentsaver]|r - No template named '"..msg.."' was found.")
		end
	elseif string.find(msg,"save") or string.find(msg,"Save") or string.find(msg,"SAVE") then
		msg = string.sub(msg,6)
		if TALENTS_SAVED["BUILDS"][msg] ~= nil then
			SendMSG("|cff3be7ed[Talentsaver]|r - A saved Talent Spec is already named like that, you'd have to delete the old one first to overwrite it.")
		else
			TALENTS_SAVE(msg)
		end
	elseif string.find(msg,"list") or string.find(msg,"List") or string.find(msg,"LIST") then
		msg = string.sub(msg,6)
		SendMSG("|cff3be7ed[Talentsaver]|r - the following Specs are saved on this character:")
		for i=1,table.getn(TALENTS_SAVED["LIST"]) do
			local name = TALENTS_SAVED["LIST"][i]
			local spec = TALENTS_SAVED["INFO"][name]
			if name ~= "" and spec then
				SendMSG(i..". Talent template - '"..name.."' ("..spec..")")
			end
		end
	elseif string.find(msg,"delete") or string.find(msg,"Delete") or string.find(msg,"DELETE") then
		msg = string.sub(msg,8)
		if TALENTS_SAVED["BUILDS"][msg] ~= nil and TALENTS_SAVED["INFO"][msg] ~= nil then
			if TALENTS_DELETE_CONFIRM == nil then
				TALENTS_DELETE_CONFIRM = true
				SendMSG("|cff3be7ed[Talentsaver]|r - If you really want to delete the template named '"..msg.."', repeat the command.")
			else
				TALENTS_DELETE_CONFIRM = nil
				TALENTS_SAVED["BUILDS"][msg] = nil
				TALENTS_SAVED["INFO"][msg] = nil
				for i=1,table.getn(TALENTS_SAVED["LIST"]) do
					if TALENTS_SAVED["LIST"][i] == msg then
						TALENTS_SAVED["LIST"][i] = ""
					end
				end
				SendMSG("|cff3be7ed[Talentsaver]|r - Template named '"..msg.."' was deleted.")
			end
		else SendMSG("|cff3be7ed[Talentsaver]|r - No template named '"..msg.."' was found.")
		end
	elseif string.find(msg,"delay") or string.find(msg,"Delay") or string.find(msg,"DELAY") then
		msg = string.sub(msg,7)
		msg = tonumber(msg)
		if msg >= -1 then
			TALENTS_SAVED.DELAY = msg
			SendMSG("|cff3be7ed[Talentsaver]|r - The Delay has been set to "..msg.."s")
		else
			SendMSG("|cff3be7ed[Talentsaver]|r - The Delay has to be higher than 0, or if you want the default latency delay set it to -1.")
		end
	else
		-- TALENTSAVER COMMAND OVERVIEW
		SendMSG("|cff3be7ed[Talentsaver]|r version "..TALENTSAVER_VERSION.." - possible config:")
		SendMSG("> save |cff1fff1fname|r - eg. 'save fury'")
		SendMSG("> load |cff1fff1fname|r - eg. 'load fury'")
		SendMSG("> delete |cff1fff1fname|r - eg. 'delete fury'")
		SendMSG("> delay |cff1fff1f"..TALENTS_SAVED.DELAY.."|r - eg. 'delay 400' for 400ms delay. (Default value is -1 which calculates the delay latency dependent)")
		SendMSG("> list - displays a list of your saved Talent templates.")
	end
end