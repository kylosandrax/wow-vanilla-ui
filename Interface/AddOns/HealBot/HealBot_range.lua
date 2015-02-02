-- Range crap


function HealBot_range_UnitInRange(Unit)
	
    if (not UnitIsVisible(Unit)) then
		return false;
    end
	local HealBot_Range_Slot = HealBot_Range_Slot;
        
    if (HealBot_Range_Slot ~= 0) then
		TargetUnit(Unit);
		if UnitIsUnit("target", Unit) then
		    return (IsActionInRange(HealBot_Range_Slot) == 1);
		else
		    return false; -- if we can't target... then its out of range
		end
    end

    -- we don't know... return true just in case
    return true;
end


function HealBot_range_ScanSpells()
	local playerClass, englishClass = UnitClass("player");
 	if (englishClass=="PALADIN") then
	 	targetSpell=HEALBOT_FLASH_OF_LIGHT;
	elseif (englishClass=="DRUID") then
		targetSpell=HEALBOT_REJUVENATION;
	elseif (englishClass=="PRIEST") then
		targetSpell=HEALBOT_HEAL;
	elseif (englishClass=="SHAMAN") then
		targetSpell=HEALBOT_LESSER_HEALING_WAVE;
	elseif (englishClass=="HUNTER") then
		targetSpell=HEALBOT_MEND_PET;
	elseif (englishClass=="WARLOCK") then
		targetSpell=HEALBOT_HEALTH_FUNNEL;
	else
		return;
	end
	for slot=1,108 do
		local name=HealBot_GetSpellName(slot);
		if (name==targetSpell) then
			--HealBot_RangeSpell=slot;
			HealBot_AddChat("WEE" .. slot);
			return slot;
			break;
		end
	end
end 

function HealBot_GetSpellName(id)
    local full_name, name;
    HealBotTooltip_2:SetOwner(HealBot_Options,"ANCHOR_NONE");
    HealBotTooltip_2:SetAction(id);
    full_name=HealBotTooltip_2TextLeft1:GetText();
    HealBotTooltip_2:Hide();
    return full_name;
end
