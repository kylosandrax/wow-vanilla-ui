
function AddonActive(addname)
	local _, _, _, addon = GetAddOnInfo(addname)
	if addon == nil or addon == 0 then addon = false; end
	return addon
end

function EquipItem(iName)
CloseMerchant();
CloseBankFrame();
CloseTradeSkill();
	for bagID = 0,4 do
		for slotID = 1,GetContainerNumSlots(bagID) do
		local itemLink = GetContainerItemLink(bagID,slotID)
			if itemLink and string.find(itemLink,iName) then
				UseContainerItem(bagID, slotID);
			end
		end
	end
end

function EquipItemSlot(iName, slot)
if ( slot < 0 ) or ( slot > 19 ) then
	DEFAULT_CHAT_FRAME:AddMessage("VUI EQUIPSLOT - Wrong SlotID !!", 1, 1, 0.5);
	return
end
for bagID = 0,4 do
		for slotID = 1,GetContainerNumSlots(bagID) do
		local itemLink = GetContainerItemLink(bagID,slotID)
			if itemLink and string.find(itemLink,iName) then
				ClearCursor()
				PickupContainerItem(bagID, slotID);
				PickupInventoryItem(slot);
			end
		end
	end
end

function GetDebuffTextures()
	for i=1,20 do
	local txtname = UnitDebuff("TARGET",i)
		if txtname then
		DEFAULT_CHAT_FRAME:AddMessage("Debuff Nr."..i..":  "..txtname);
		end
	end
end

function GetBuffTextures()
	for i=1,20 do
	local txtname = UnitBuff("TARGET",i)
		if txtname then
		DEFAULT_CHAT_FRAME:AddMessage("Buff Nr."..i..":  "..txtname);
		end
	end
end

function CountItems(itemname)
local count = 0;
for bagID = 0,4 do
		for slotID = 1,GetContainerNumSlots(bagID) do
		local itemLink = GetContainerItemLink(bagID,slotID)
			if itemLink and string.find(itemLink,itemname) then
				local _, ic = GetContainerItemInfo(bagID,slotID);
				count=count+ic;
			end
		end
	end
	return count;
end

-- Farmcounter
local farminame,farmcount,oldcount,atmcount
function setFarmItem(itemname,count)
	farminame = itemname;
	farmcount = count;
	oldcount = 0;
	atmcount = CountItems(farminame);
	MSG(itemname.." "..atmcount.."/"..count.." - farmmode: on")
end

function updateFarmItem()
	if farminame and farmcount then
		atmcount = CountItems(farminame);
		if atmcount ~= oldcount then
			MSG(atmcount.."/"..farmcount.." "..farminame);
			oldcount = atmcount;
		end
		if atmcount == farmcount then
			MSG("farming completed! farmmode: off");
			setFarmItemOff(0)
		end
	end
end

function setFarmItemOff(nr)
	if nr == nil then MSG("farmmode: off") end
	farminame = nil;
	farmcount = nil;
end
-- end Farmcounter

function MSG(text)
	UIErrorsFrame:Clear()
	UIErrorsFrame:AddMessage(text)
end

function SendChat(text)
	DEFAULT_CHAT_FRAME:AddMessage(text);
end

function AutoSave()
	SendChatMessage(".save", "SAY");
	MSG("Character saved");
end