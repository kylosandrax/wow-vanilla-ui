--HIT TABLE:
--Miss
--Dodge
--Parry
--Block
--Critical Hit
--Crushing Blow
--Hit

TankStats = {}


local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:SetScript("OnEvent", function(self,event,...)
    TankStats:EHBar_OnLoad();
end);


EventFrame:RegisterEvent("UNIT_RESISTANCES")
EventFrame:SetScript("OnEvent", function(self,event,...)
    TankStats:EHBar_OnUpdate();
end);

EventFrame:RegisterEvent("UNIT_HEALTH")
EventFrame:SetScript("OnEvent", function(self,event,...)
    TankStats:EHBar_OnUpdate();
end);

EventFrame:RegisterEvent("UNIT_DEFENSE")
EventFrame:SetScript("OnEvent", function(self,event,...)
    TankStats:HitTable_OnUpdate();
end);

EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
EventFrame:SetScript("OnEvent", function(self,event,...)
    TankStats:EHBar_OnUpdate();
    TankStats:HitTable_OnUpdate();
end);

EventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
EventFrame:SetScript("OnEvent", function(self,event,...)
    TankStats:EHBar_OnUpdate();
    TankStats:HitTable_OnUpdate();
end);

EventFrame:RegisterEvent("UNIT_STATS")
EventFrame:SetScript("OnEvent", function(self,event,...)
    TankStats:EHBar_OnUpdate();
    TankStats:HitTable_OnUpdate();
end);

EventFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
EventFrame:SetScript("OnEvent", function(self,event,...)
    TankStats:EHBar_OnUpdate();
    TankStats:HitTable_OnUpdate();
end);


function TankStats:updateTargetLevel()
    TankStats.enemyLevel = UnitLevel("target");
    TankStats.playerLevel = UnitLevel("player");

    -- 0: nothing selected; use raid boss level (63)
    if (TankStats.enemyLevel == 0) then
        TankStats.enemyLevel = 63
    end

    -- -1: skull; use 63
    if (TankStats.enemyLevel == -1) then
        TankStats.enemyLevel = min(63, TankStats.playerLevel + 10);

    end
end

function TankStats:EHBar_OnLoad()
    TankStats:EHBar_OnUpdate();
    TankStats:HitTable_OnUpdate();
end

local function formatEH(x)
    if (x < 1000) then
        return format("%.1f", x);
    end

    if (x < 10000) then
        return format("%d", x);
    end

    return format("%.3fk", x/1000);
end

resistThreshold = 50; --below this level of resistance, the MEH bar is hidden
function TankStats:EHBar_OnUpdate()
    TankStats:updateTargetLevel();

    --Physical
    local _, effectiveArmor, _, _, _ = UnitArmor("player");
    local ACreduction = min(0.75, effectiveArmor / (effectiveArmor + 400 + 85 * TankStats.enemyLevel));
    local ACmultiplier = 1 / (1 - ACreduction);
    local health, maxHealth = UnitHealth("player"), UnitHealthMax("player");
    local EH, maxEH = health*ACmultiplier, maxHealth*ACmultiplier;

    EHFrameEHBar:SetMinMaxValues(0, maxEH);
    EHFrameEHBar:SetValue(EH);
    EHFrameEHBarText:SetText("Physical: " ..
                             formatEH(EH) ..
                             " / " ..
                             formatEH(maxEH));

    --Resists
    local maxResist = TankStats.enemyLevel * 5;
    local base, total, bonus, minus, modWidth;



    --Fire EH
    _, total, _, _ = UnitResistance("player", 2);
    local fireMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local fireEH, maxFireEH = health*fireMultiplier, maxHealth*fireMultiplier;
    if (total < resistThreshold) then
        EHFrameFireEHBar:Hide()
		EHFrameMaxFireEHBar:Hide()
    else
		EHFrameFireEHBar:Show()
		EHFrameMaxFireEHBar:Show()
        EHFrameFireEHBar:SetMinMaxValues(0, maxFireEH);
        EHFrameFireEHBar:SetValue(fireEH);
        EHFrameFireEHBarText:SetText("Fire: " ..
                                     formatEH(fireEH) ..
                                     " / " ..
                                     formatEH(maxFireEH));
    end

    --Shadow EH
    _, total, _, _ = UnitResistance("player", 5);
    local shadowMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local shadowEH, maxShadowEH = health*shadowMultiplier, maxHealth*shadowMultiplier;
    if (total < resistThreshold) then
        EHFrameShadowEHBar:Hide();
		EHFrameMaxShadowEHBar:Hide();
    else
		EHFrameShadowEHBar:Show();
		EHFrameMaxShadowEHBar:Show();
        EHFrameShadowEHBar:SetMinMaxValues(0, maxShadowEH);
        EHFrameShadowEHBar:SetValue(shadowEH);
        EHFrameShadowEHBarText:SetText("Shadow: " ..
                                       formatEH(shadowEH) ..
                                       " / " ..
                                       formatEH(maxShadowEH));
    end

    --Nature EH
    _, total, _, _ = UnitResistance("player", 3);
    local natureMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local natureEH, maxNatureEH = health*natureMultiplier, maxHealth*natureMultiplier;

    if (total < resistThreshold) then
        EHFrameNatureEHBar:Hide();
		EHFrameMaxNatureEHBar:Hide();
    else
		EHFrameNatureEHBar:Show();
		EHFrameMaxNatureEHBar:Show();
        EHFrameNatureEHBar:SetMinMaxValues(0, maxNatureEH);
        EHFrameNatureEHBar:SetValue(natureEH);
        EHFrameNatureEHBarText:SetText("Nature: " ..
                                       formatEH(natureEH) ..
                                       " / " ..
                                       formatEH(maxNatureEH));
    end

    --Frost EH
    _, total, _, _ = UnitResistance("player", 4);
    local frostMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local frostEH, maxFrostEH = health*frostMultiplier, maxHealth*frostMultiplier;
    if (total < resistThreshold) then
        EHFrameFrostEHBar:Hide();
		EHFrameMaxFrostEHBar:Hide();
    else
		EHFrameFrostEHBar:Show();
		EHFrameMaxFrostEHBar:Show();
        EHFrameFrostEHBar:SetMinMaxValues(0, maxFrostEH);
        EHFrameFrostEHBar:SetValue(frostEH);
        EHFrameFrostEHBarText:SetText("Frost: " ..
                                       formatEH(frostEH) ..
                                       " / " ..
                                       formatEH(maxFrostEH));
    end

    --Arcane EH
    _, total, _, _ = UnitResistance("player", 6);
    local arcaneMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local arcaneEH, maxArcaneEH = health*arcaneMultiplier, maxHealth*arcaneMultiplier;
    if (total < resistThreshold) then
        EHFrameArcaneEHBar:Hide()
		EHFrameMaxArcaneEHBar:Hide()
    else
		EHFrameArcaneEHBar:Show()
		EHFrameMaxArcaneEHBar:Show()
        EHFrameArcaneEHBar:SetMinMaxValues(0, maxArcaneEH);
        EHFrameArcaneEHBar:SetValue(arcaneEH);
        EHFrameArcaneEHBarText:SetText("Arcane: " ..
                                       formatEH(arcaneEH) ..
                                       " / " ..
                                       formatEH(maxArcaneEH));
    end


    --Normalize bar widths
    local maxMax = max(maxEH, maxFireEH, maxShadowEH, maxNatureEH, maxFrostEH, maxArcaneEH);
    local widthModifier = EHFrame:GetWidth() / maxMax;

    EHFrameMaxEHBar:SetWidth(maxEH * widthModifier);
    EHFrameEHBar:SetWidth(maxEH * widthModifier);
    EHFrameMaxFireEHBar:SetWidth(maxFireEH * widthModifier);
    EHFrameFireEHBar:SetWidth(maxFireEH * widthModifier);
    EHFrameMaxShadowEHBar:SetWidth(maxShadowEH * widthModifier);
    EHFrameShadowEHBar:SetWidth(maxShadowEH * widthModifier);
    EHFrameMaxNatureEHBar:SetWidth(maxNatureEH * widthModifier);
    EHFrameNatureEHBar:SetWidth(maxNatureEH * widthModifier);
    EHFrameMaxFrostEHBar:SetWidth(maxFrostEH * widthModifier);
    EHFrameFrostEHBar:SetWidth(maxFrostEH * widthModifier);
    EHFrameMaxArcaneEHBar:SetWidth(maxArcaneEH * widthModifier);
    EHFrameArcaneEHBar:SetWidth(maxArcaneEH * widthModifier);
end

function TankStats:HitTable_OnUpdate()
    TankStats.playerLevel = UnitLevel("player");
    TankStats:updateTargetLevel();
    local armorDefense;
    TankStats.baseDefense, armorDefense = UnitDefense("player");
    local levelDiff = TankStats.enemyLevel - TankStats.playerLevel;
    local extraFromLevel = -0.04 * (levelDiff * 5);
    local extraFromBaseDef = -0.04 * (TankStats.enemyLevel*5 - TankStats.baseDefense);
    local extraFromGear = 0.04 * armorDefense;


    TankStats.miss = max(0, 5 + extraFromBaseDef + extraFromGear);

    --Get*Chance() should already include defense from gear.
    TankStats.dodge = max(0, GetDodgeChance() + extraFromLevel);
    TankStats.parry = max(0, GetParryChance() + extraFromLevel);
    TankStats.block = max(0, GetBlockChance() + extraFromLevel);

    --ignore block?
    local link = GetInventoryItemLink("player", 17);
    if (not link) then
		-- no offhand equiped
        TankStats.block = 0;
    else
        local _,_, itemId = string.find(link, "item:(%d+):");
        local _, _, _, _, _, sSubType, _ = GetItemInfo(itemId);
        if (sSubType ~="Shields") then
            TankStats.block = 0;
        end
    end
    --if (UnitCreatureType("target") == "Elemental") then
    --    TankStats.block = 0;
    --end

    TankStats.crit = min(100, max(0, 5 - extraFromLevel - extraFromGear - extraFromBaseDef));

    local baseDef = min(TankStats.baseDefense, 5*TankStats.playerLevel);
    local crushDif = TankStats.enemyLevel*5 - baseDef;
    if (crushDif >= 15) then
        TankStats.crush = max(0, min(100, crushDif * 2 - 15));
    else
        TankStats.crush = 0;
    end

    TankStats.miss  = min(TankStats.miss,  100.0);  -- MISS/DODGE/PARRY/ASF MIN 0
    TankStats.dodge = min(TankStats.dodge, 100.0 - TankStats.miss);
    TankStats.parry = min(TankStats.parry, 100.0 - TankStats.miss - TankStats.dodge);
    TankStats.block = min(TankStats.block, 100.0 - TankStats.miss - TankStats.dodge - TankStats.parry);
    TankStats.crit  = min(TankStats.crit , 100.0 - TankStats.miss - TankStats.dodge - TankStats.parry - TankStats.block);
    TankStats.crush = min(TankStats.crush, 100.0 - TankStats.miss - TankStats.dodge - TankStats.parry - TankStats.block - TankStats.crit);
    TankStats.hit   =                      100.0 - TankStats.miss - TankStats.dodge - TankStats.parry - TankStats.block - TankStats.crit - TankStats.crush;

    local barSize = HitTable:GetWidth() * .01;

    if (TankStats.miss > 0) then HitTableMissBarText:SetText("M"); else HitTableMissBarText:SetText(""); end
    if (TankStats.dodge > 0) then HitTableDodgeBarText:SetText("D"); else HitTableDodgeBarText:SetText(""); end
    if (TankStats.parry > 0) then HitTableParryBarText:SetText("P"); else HitTableParryBarText:SetText(""); end
    if (TankStats.block > 0) then HitTableBlockBarText:SetText("B"); else HitTableBlockBarText:SetText(""); end
    if (TankStats.crit > 0) then HitTableCritBarText:SetText("Crit"); else HitTableCritBarText:SetText(""); end
    if (TankStats.crush > 0) then HitTableCrushBarText:SetText("Crush"); else HitTableCrushBarText:SetText(""); end
    if (TankStats.hit > 0) then HitTableHitBarText:SetText("Hit"); else HitTableHitBarText:SetText(""); end

    --zero-size messes up anchors
    local missSize = max(0.001, TankStats.miss);
    local dodgeSize = max(0.001, TankStats.dodge);
    local parrySize = max(0.001, TankStats.parry);
    local blockSize = max(0.001, TankStats.block);
    local critSize = max(0.001, TankStats.crit);
    local crushSize = max(0.001, TankStats.crush);
    local hitSize = max(0.001, TankStats.hit);

    HitTableMissBar:SetWidth(missSize * barSize);
    HitTableDodgeBar:SetWidth(dodgeSize * barSize);
    HitTableParryBar:SetWidth(parrySize * barSize);
    HitTableBlockBar:SetWidth(blockSize * barSize);
    HitTableCritBar:SetWidth(critSize * barSize);
    HitTableCrushBar:SetWidth(crushSize * barSize);
    HitTableHitBar:SetWidth(hitSize * barSize);

    TankStats.summaryText = "";
    if (TankStats.miss > 0) then TankStats.summaryText = TankStats.summaryText .. format("%.2f", TankStats.miss) .. "% miss" end
    if (TankStats.dodge > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.dodge) .. "% dodge" end
    if (TankStats.parry > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.parry) .. "% parry" end
    if (TankStats.block > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.block) .. "% block" end
    if (TankStats.crit > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.crit) .. "% crit" end
    if (TankStats.crush > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.crush) .. "% crush" end
    if (TankStats.hit > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.hit) .. "% hit" end
    TankStats.summaryText = TankStats.summaryText .. "  (from lvl " .. TankStats.enemyLevel .. " target)";
end

function TankStats:showHitTableText()
    HitTableText:SetText(TankStats.summaryText);
end

function TankStats:hideHitTableText()
    HitTableText:SetText("");
end

function TankStats:stats()
    TankStats:HitTable_OnUpdate();

    DEFAULT_CHAT_FRAME:AddMessage("Target level: " .. TankStats.enemyLevel);

    local avoidance = TankStats.miss +TankStats.dodge +TankStats.parry
    DEFAULT_CHAT_FRAME:AddMessage("Avoidance: " .. format("%.2f", avoidance ) .. "%");
    DEFAULT_CHAT_FRAME:AddMessage("Avoidance + Block: " .. format("%.2f", avoidance + TankStats.block ) .. "%");
    if (TankStats.crit > 0) then DEFAULT_CHAT_FRAME:AddMessage("incoming Crit: " .. format("%.2f", TankStats.crit) .. "%"); end
    if (TankStats.crush > 0) then DEFAULT_CHAT_FRAME:AddMessage("incoming Crush: " .. format("%.2f", TankStats.crush) .. "%"); end
end

local function toggleEHBar()
	if EHFrameMaxEHBar:IsShown() then
		EHFrameMaxEHBar:Hide()
		EHFrameEHBar:Hide()
	else
		EHFrameMaxEHBar:Show()
		EHFrameEHBar:Show()
	end
end

--save state to make one toggle for all Bars
MEhBarsHidden = false;

local function toggleMEhBars()
	if MEhBarsHidden then
		TankStats:EHBar_OnUpdate()
		MEhBarsHidden = false;
	else
		EHFrameFireEHBar:Hide()
		EHFrameMaxFireEHBar:Hide()
		EHFrameShadowEHBar:Hide();
		EHFrameMaxShadowEHBar:Hide();
		EHFrameNatureEHBar:Hide();
		EHFrameMaxNatureEHBar:Hide();
		EHFrameFrostEHBar:Hide();
		EHFrameMaxFrostEHBar:Hide();
		EHFrameArcaneEHBar:Hide()
		EHFrameMaxArcaneEHBar:Hide()
		MEhBarsHidden = true;
	end
end

local function toggleHitTable()
	if HitTable:IsShown() then
		HitTable:Hide()
	else
		HitTable:Show()
	end
end

local function setResistThreshold(param)
	resistThreshold = tonumber(param);
	if (not resistThreshold) then
		DEFAULT_CHAT_FRAME:AddMessage('the parameter was not a number.')
		DEFAULT_CHAT_FRAME:AddMessage('Use /tstats resTh <number> to set the resistance threshold, at which the EH is shown.')
	else
		TankStats:EHBar_OnUpdate()
	end
end

SLASH_TANKSTATS1 = "/tankstats";
SLASH_TANKSTATS2 = "/tstats";

local function handler(msg, editbox)
 -- Any leading non-whitespace is captured into command;
 -- the rest (minus leading whitespace) is captured into rest.

	local i,j, command, param = string.find(string.lower(msg), "^([^ ]+) (.+)$")
	if (not command) then command = string.lower(msg) end
	if (not command) then command = "" end
	if (not param) then param = "" end

	if command == 'stats' then
		TankStats:stats()
	elseif command == 'ehbar' then
		toggleEHBar()
	elseif command == 'mehbars' then
		toggleMEhBars()
	elseif command == 'hittable' then
		toggleHitTable()
	elseif command == 'all' then
		toggleEHBar()
		toggleMEhBars()
		toggleHitTable()
	elseif command == 'resth' then
		setResistThreshold(param)
	else
		DEFAULT_CHAT_FRAME:AddMessage('unknown tankstats command.')
		DEFAULT_CHAT_FRAME:AddMessage('Use /tstats [EhBar | MEhBars | HitTable | All] to toggle visibility')
		DEFAULT_CHAT_FRAME:AddMessage('Use /tstats resTh <number> to set the resistance threshold, at which the MEH is shown.')
		DEFAULT_CHAT_FRAME:AddMessage('Use /tstats stats to get a stat summary')
	end
end

SlashCmdList["TANKSTATS"] = handler;
