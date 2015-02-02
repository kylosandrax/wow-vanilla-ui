--[[

  HealBot: 
	
]]

--------------------------------------------------------------------------------------------------
-- Local variables
--------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
-- Internal functions
--------------------------------------------------------------------------------------------------

function HealBot_AddChat(msg)
  if ( DEFAULT_CHAT_FRAME ) then
    DEFAULT_CHAT_FRAME:AddMessage(msg);
  end
end

HealBot_Debug = false;

function HealBot_AddDebug(msg)
  if HealBot_Debug then
    --SendChatMessage(msg , "CHANNEL", nil, HealBot_Get_DebugChan());  
   	HealBot_AddChat("HealBot: " .. msg);
  end
end

function HealBot_AddError(msg)
  UIErrorsFrame:AddMessage(msg, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
  HealBot_AddChat(msg);
end

function HealBot_TogglePanel(panel)
  if (not panel) then return end
  if ( panel:IsVisible() ) then
    HideUIPanel(panel);
  else
    ShowUIPanel(panel);
  end
end

function HealBot_StartMoving(frame)
  if ( not frame.isMoving ) and ( frame.isLocked ~= 1 ) then
    frame:StartMoving();
    frame.isMoving = true;
  end
end

function HealBot_StopMoving(frame)
  if ( frame.isMoving ) then
    frame:StopMovingOrSizing();
    frame.isMoving = false;
  end
end

function HealBot_SlashCmd(cmd)
  if (cmd=="") then
    HealBot_TogglePanel(HealBot_Action);
    return
  end
  if (cmd=="options" or cmd=="opt" or cmd=="config" or cmd=="cfg") then
    HealBot_TogglePanel(HealBot_Options);
    return
  end
  if (cmd=="debug" or cmd=="dbg") then
    if HealBot_Debug then
      HealBot_AddDebug("Debug messages disabled");
      HealBot_Debug = false;
      HealBot_Clear_DebugChan();
    else
      HealBot_Debug = true;
      HealBot_AddDebug("Debug messages enabled");
      ShowUIPanel(HealBot_Action);
    end
    HealBot_RecalcSpells()
    return;
  end
  if (cmd=="reset" or cmd=="recalc" or cmd=="defaults") then
--    HealBot_RecalcSpells();
    HealBot_Options_Defaults_OnClick(HealBot_Options_Defaults);
    return
  end
  if (cmd=="screenshot" or cmd=="ss") then
    HealBot_Action_Screenshot();
    return;
  end
  if (cmd=="ui") then
    ReloadUI();
    return;
  end
  if (cmd=="init") then
  	Healbot_RegisterThis(this);
  end
  if (cmd=="x") then
  	HealBot_RecalcSpells();
    return;
  end
  HealBot_AddDebug("SlashCmd: " .. cmd);
end

local SpeedObj = {base = .011890527920967*3/1.5};
function HealBot_Speed()
  if (not SpeedObj.u) then
    SpeedObj.u = GetTime();
    local con = GetCurrentMapContinent();
    local z = GetCurrentMapZone();
    SetMapZoom(0);
    SpeedObj.x,SpeedObj.y = GetPlayerMapPosition("player");
    SetMapZoom(con,z);
    SpeedObj.s = 0;
  end
  if (GetTime() - SpeedObj.u >= 1.5) then
    local con = GetCurrentMapContinent();
    local z = GetCurrentMapZone();
    SetMapZoom(0);
    local x,y = GetPlayerMapPosition("player");
    SetMapZoom(con,z);
    local AccMod = 10^40;
    local dist = sqrt(((x*AccMod-AccMod*SpeedObj.x)*(1002/668))^2+(y*AccMod-AccMod*SpeedObj.y)^2)/(AccMod/100);
    SpeedObj.s = math.floor(dist/(GetTime()-SpeedObj.u)/SpeedObj.base*100+0.5);
    SpeedObj.u = GetTime();
    SpeedObj.x,SpeedObj.y = x,y;
  end
  HealBot_AddDebug("speed is currently " .. SpeedObj.s .."% ...");
  return SpeedObj.s;
end

function HealBot_Distance(unit)
  local con = GetCurrentMapContinent();
  if con<0 then return 0; end
  local z = GetCurrentMapZone();
  SetMapZoom(0);
  local px,py = GetPlayerMapPosition("player");
  local ux,uy = GetPlayerMapPosition(unit);
  SetMapZoom(con,z);
  if ux==0 then
    if not HealBot_Debug then return 0; end
    -- Lord Grayson (SW)
    ux = 0.71174442768097;
    uy = 0.62124902009964;
    -- Duthorian Rall (SW)
    ux = 0.71254408359528;
    uy = 0.62018293142319;
    return 0;
  end
--  HealBot_AddDebug("position of " .. UnitName(unit) .. " is (" .. ux .. "," .. uy .. ")");

--  bandage test:
--  px = 0.72215789556503;
--  py = 0.63927626609802;
--  ux = 0.72205895185471;
--  uy = 0.63870108127594;
  
  local dist = sqrt(((ux-px)*1.5)^2+(uy-py)^2);
  -- 0.00059402420794769 --> 15
--  local meters = dist/0.000038164512077295-2.857142857142857;
--  HealBot_AddDebug("distance to " .. UnitName(unit) .. " is " .. dist);
  dist = dist*27600;  -- 30:27000, 40:27600
--  HealBot_AddDebug("distance to " .. UnitName(unit) .. " is " .. dist);
  return dist;
end

function HealBot_UnitPosition(unit)
  local con = GetCurrentMapContinent();
  local z = GetCurrentMapZone();
  SetMapZoom(0);
  local x,y = GetPlayerMapPosition(unit);
  SetMapZoom(con,z);
  return x,y;
end

function HealBot_TargetName()
  if UnitIsEnemy("target","player") then return nil end
--  if not UnitPlayerControlled("target") then return nil end
  if (UnitIsPlayer("target")) then
    if UnitIsUnit("target","player") then return "player" end
    if (UnitInParty("target")) then 
      for i=1,4 do
        if UnitIsUnit("target","party"..i) then return "party"..i end
      end
    end
    if (UnitInRaid("target")) then 
      for i=1,40 do
        if UnitIsUnit("target","raid"..i) then return "raid"..i end
      end
    end
  else
    if UnitIsUnit("target","pet") then return "pet" end
    if (UnitInParty("player")) then 
      for i=1,4 do
        if UnitIsUnit("target","partypet"..i) then return "partypet"..i end
      end
    end
    if (UnitInRaid("player")) then 
      for i=1,40 do
        if UnitIsUnit("target","raidpet"..i) then return "raidpet"..i end
      end
    end
  end
  return nil
end
--/script HealBot_AddDebug(HealBot_TargetName() or "nil")

local HealBot_IsFighting = false;

local HealBot_LastX,HealBot_LastY = 0,0;
local HealBot_IsMoving = false;
function HealBot_CheckMoving()
--  local x,y = HealBot_UnitPosition("player");
  local x,y = GetPlayerMapPosition("player");
  local WasMoving = HealBot_IsMoving;
  HealBot_IsMoving = x~=HealBot_LastX or y~=HealBot_LastY;
  HealBot_LastX,HealBot_LastY = x,y;
  if WasMoving ~= HealBot_IsMoving then
    HealBot_RecalcHeals();
  end
end

function HealBot_PackBagSlot(bag,slot)
  return bag*100+slot;
end

function HealBot_UnpackBagSlot(bagslot)
  return math.floor(bagslot/100),math.mod(bagslot,100);
end

function HealBot_GetItemName(bag,slot)
  local link = GetContainerItemLink(bag,slot);
  if not link then return nil end;
  local _,_,item = string.find(link,"%[(.*)%]");
  local _,count = GetContainerItemInfo(bag,slot);
  return item,count;
end

function HealBot_GetBagSlot(item)
  local BagSlot,BestCount;
  for bag=0,NUM_BAG_FRAMES do
    for slot=1,GetContainerNumSlots(bag) do
      local bagitem,count = HealBot_GetItemName(bag,slot);
      if (item==bagitem) then
        if not BestCount or BestCount>count then
          BagSlot = HealBot_PackBagSlot(bag,slot);
          BestCount = count;
        end
      end
    end
  end
  return BagSlot;
end

function HealBot_UseItem(item)
  local bagslot = HealBot_GetBagSlot(item);
  if not bagslot then return end;
  HealBot_AddDebug("found " .. bagslot);
  local bag,slot = HealBot_UnpackBagSlot(bagslot);
  local Link = GetContainerItemLink(bag,slot);
  HealBot_AddChat(Link);
  UseContainerItem(bag,slot);
end

function HealBot_GetSpellName(id)
--  HealBot_AddDebug("GetSpellName(" .. id .. ",'" .. type .. "')");
  if (not id) then
    return nil;
  end
  local spellName, subSpellName = GetSpellName(id,BOOKTYPE_SPELL);
  if (not spellName) then
    return nil;
  end
  if (not subSpellName or subSpellName=="") then
    return spellName;
  end
  return spellName .. "(" .. subSpellName .. ")";
end

function HealBot_GetSpellId(spell)
  for id = 180,1,-1 do 
    local spellName, subSpellName = GetSpellName(id,BOOKTYPE_SPELL);
    if (spellName) then
      if (spell == spellName .. "(" .. subSpellName .. ")") then
        return id;
      end
      if (spell == spellName) then
        return id;
      end      
    end
  end
  return nil;
end

function HealBot_CastSpellByName(spell,target)
  if (HealBot_Spells[spell] and HealBot_Spells[spell].BagSlot) then
    HealBot_AddDebug("*** using an item ...");
    HealBot_UseItem(spell);
    return;
  end
  HealBot_AddDebug("*** casting a spell ...");
  local id = HealBot_GetSpellId(spell);
  if (not id) then
    return;
  end
  CastSpell(id,BOOKTYPE_SPELL);
end

HealBot_CastingSpell  = nil;
HealBot_CastingTarget = nil;

function HealBot_StartCasting(spell,target)
  if HealBot_Config.CastNotify>1 then
    if target=="target" then target = HealBot_TargetName() or "target" end
    local Notify = HealBot_Config.CastNotify;
    if Notify==5 and GetNumRaidMembers()==0 then Notify = 4 end
    if Notify==4 and GetNumPartyMembers()==0 then Notify = 3 end
    if Notify==3 and not (UnitPlayerControlled(target) and target~='player' and target~='pet') then Notify = 2 end
    if Notify==3 then
      SendChatMessage(string.format(HEALBOT_CASTINGSPELLONYOU,spell),"WHISPER",nil,UnitName(target));
    elseif Notify==4 then
      SendChatMessage(string.format(HEALBOT_CASTINGSPELLONUNIT,spell,UnitName(target)),"PARTY",nil,nil);
    elseif Notify==5 then
      SendChatMessage(string.format(HEALBOT_CASTINGSPELLONUNIT,spell,UnitName(target)),"RAID",nil,nil);
    else
      HealBot_AddChat(string.format(HEALBOT_CASTINGSPELLONUNIT,spell,UnitName(target)));
    end
  end
  HealBot_CastSpellByName(spell);
  if ( SpellIsTargeting() ) then 
    SpellTargetUnit(target);
  end
  HealBot_CastingSpell  = spell;
  HealBot_CastingTarget = target;
end

function HealBot_StopCasting()
  HealBot_Action:SetBackdropColor(0.25,0.25,0.25);
  HealBot_CastingSpell  = nil;
  HealBot_CastingTarget = nil;
end

function HealBot_AbortCasting()
  HealBot_Action:SetBackdropColor(1,0,0);
--  HealBot_AddChat(string.format(HEALBOT_ABORTEDSPELLONUNIT,HealBot_CastingSpell,UnitName(HealBot_CastingTarget)));
--  HealBot_StopCasting();
--  SpellStopCasting();
end

local HealBot_Health60 = {
  ["DRUID"]   = 3500,
  ["MAGE"]    = 2500,
  ["HUNTER"]  = 3500,
  ["PALADIN"] = 4000,
  ["PRIEST"]  = 2500,
  ["ROGUE"]   = 3500,
  ["SHAMAN"]  = 3800,
  ["WARLOCK"] = 3500,
  ["WARRIOR"] = 5000,
}
function HealBot_UnitHealth(unit)
  local Current,Desired = UnitHealth(unit),UnitHealthMax(unit);
  if unit=='target' and Desired==100 then
    -- estimate the values
    local class,level = HealBot_UnitClass(unit),UnitLevel(unit);
    if HealBot_Health60[class] and level>0 then
      Desired = math.floor(HealBot_Health60[class]/60*level+0.5)
    else
      Desired = UnitHealthMax('player');
    end
    Current = Desired/100*Current;
  end
  return Current,Desired*HealBot_Config.HealthPct;
end

function HealBot_CheckCasting(unit)
  if not HealBot_CastingSpell or HealBot_Config.HealingUsage==0 or HealBot_AlwaysHeal() then return nil end
--  if not HealBot_CastingSpell or HealBot_Config.HealingUsage==0 then return nil end
  if not HealBot_Spells[HealBot_CastingSpell] then return nil end
  if not unit then unit = HealBot_CastingTarget end
  if unit~=HealBot_CastingTarget then return nil end
  HealBot_AddDebug("checking whether " .. UnitName(HealBot_CastingTarget) .. 
    " still needs " .. HealBot_CastingSpell .. " (" .. HealBot_Spells[HealBot_CastingSpell].HealsDur .. ") ...");
  
  local Current,Desired = HealBot_UnitHealth(unit)
  local Needed = Desired-Current;
  if Needed<0 then Needed = 0 end
  HealBot_AddDebug("... needs " .. Needed .. " HP");
  if (Needed>=HealBot_Spells[HealBot_CastingSpell].HealsDur*HealBot_Config.HealingUsage) then return nil end

  HealBot_AbortCasting();
end

function HealBot_CastSpellOnTarget(spell,target)
  local old;
  if (not spell or not target or not UnitName(target)) then
    return;
  end
  if (UnitCanAttack("player","target")) then
    old = "enemy";
  else
    old = UnitName("target");
  end
  TargetUnit(target);
  HealBot_StartCasting(spell,target);
  HealBot_CastSpellByName(spell);
  if ( SpellIsTargeting() ) then 
    SpellTargetUnit(target); 
  end
  if (old=="enemy") then
    TargetLastEnemy();
  elseif (old) then
    TargetByName(old);
  else
    ClearTarget();
  end
end

function HealBot_CastSpellOnFriend(spell,target)
  HealBot_AddDebug("HealBot_CastSpellOnFriend ...");
  local old;
  if (not spell or not target or not UnitName(target)) then
    return;
  end
  if (UnitCanAttack("player","target")) then
    old = "enemy";
  else
    old = UnitName("target");
    TargetUnit(target);
  end
  HealBot_StartCasting(spell,target);
  HealBot_CastSpellByName(spell);
  if ( SpellIsTargeting() ) then 
    HealBot_AddDebug("... targeting spell");
    SpellTargetUnit(target); 
  end
  if (old=="enemy") then
--    TargetLastEnemy();
  elseif (old) then
    TargetByName(old);
  else
    ClearTarget();
  end
end

function HealBot_DumpSpellbook()
  local i = 1
  while true do
    local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
    if not spellName then
      do break end
    end
    HealBot_AddDebug(i .. ": " .. HealBot_GetSpellName(i));
    i = i + 1
  end
end

function HealBot_UnitClass(unit)
  local playerClass, englishClass = UnitClass(unit);
  return englishClass;
end

-- TBD: use the event UNIT_AURA to keep track instead of querying each time
function HealBot_UnitAffected(unit,effect)
  if not effect then return nil; end
--  HealBot_AddDebug("HealBot_UnitAffected(" .. unit .."," .. effect ..") ...");
  local i = 1
  while true do
    local buff = UnitBuff(unit,i)
    if not buff then
      do break end
    end
--    HealBot_AddDebug("UnitBuff("..unit..","..i..") = "..buff);
    if buff==effect then
      return buff
    end
    i = i + 1
  end
  i = 1
  while true do
    local debuff = UnitDebuff(unit,i)
    if not debuff then
      do break end
    end
--    HealBot_AddDebug("UnitDebuff("..unit..","..i..") = "..debuff);
    if debuff==effect then
      return debuff
    end
    i = i + 1
  end
  return nil;
end
-- safer to use GameTooltip:SetUnitBuff and read the lines in the tooltip ...
-- maybe make an additional GameTooltip frame if possible ?

--------------------------------------------------------------------------------------------------
-- data functions
--------------------------------------------------------------------------------------------------

function HealBot_DumpHeals()
  table.foreach(HealBot_Heals, function (key,val)
    HealBot_AddDebug("Healing spells for " ..key);
    table.foreachi(val, function (i,val)
      HealBot_AddDebug(val);
    end);
  end);
end

function HealBot_SetSpellDefaults(spell)
  if not HealBot_Spells[spell].Target then
    HealBot_Spells[spell].Target = {"player","party","pet"};
  end
  if not HealBot_Spells[spell].Cast then
    HealBot_Spells[spell].Cast = 0;
  else
   	casttime_reduction = HealBot_Fix_CastSpeed(spell);
  	HealBot_Spells[spell].Cast = HealBot_Spells[spell].Cast - casttime_reduction;
  end
  if not HealBot_Spells[spell].Mana then
    HealBot_Spells[spell].Mana = 0;
  else
  	mana_reduction = HealBot_Fix_ManaCost(spell);
  	HealBot_Spells[spell].Mana = HealBot_Spells[spell].Mana * mana_reduction;
  end
  if not HealBot_Spells[spell].Price then
    HealBot_Spells[spell].Price = 0;
  end
  if not HealBot_Spells[spell].Channel then
    HealBot_Spells[spell].Channel = HealBot_Spells[spell].Cast;
  end
  if not HealBot_Spells[spell].Duration then
    HealBot_Spells[spell].Duration = HealBot_Spells[spell].Channel;
  end
  if not HealBot_Spells[spell].HealsMin then
    HealBot_Spells[spell].HealsMin = 0;
  end
  if not HealBot_Spells[spell].HealsMax then
    HealBot_Spells[spell].HealsMax = 0;
  end
  --
  -- Added a little something
  --
  HealBot_AddDebug("healmod" .. HealBot_Add_HealModifier(spell));
  local healingbonus_penalty=1;
  if HealBot_Spells[spell].Level < 20 then
  	healingbonus_penalty=(1-((20-HealBot_Spells[spell].Level)*0.0375));
  end
  local temp_Spell_cast=3.5;
  if HealBot_Spells[spell].Cast <= 1.5 then
  	temp_Spell_cast=1.5;
  end
  if HealBot_Spells[spell].Cast > 1.5 and HealBot_Spells[spell].Cast < 3.5 then
  	temp_Spell_cast=HealBot_Spells[spell].Cast;
  end
  RealHealing = ((HealBot_GetBonus('HEAL') * healingbonus_penalty) * (temp_Spell_cast/3.5));
-- 
--
--
	HealBot_AddDebug("RealHealing="..RealHealing);
	local playerClass, englishClass = UnitClass("player");
	if (englishClass=="PRIEST") then
		SpiBonus = (HealBot_SpiBonus(spell) * (temp_Spell_cast/3.5));
		RealHealing = RealHealing + SpiBonus;
	end
--
  HealBot_AddDebug("RealHealing="..RealHealing);
  HealBot_AddDebug("healingbonus_penalty="..healingbonus_penalty);
  --
  HealBot_Spells[spell].HealsCast = format("%d", ((HealBot_Spells[spell].HealsMin+HealBot_Spells[spell].HealsMax)/2 * HealBot_Add_HealModifier(spell)) + RealHealing);
  if not HealBot_Spells[spell].HealsExt then
    HealBot_Spells[spell].HealsExt = 0;
  end
  HealBot_Spells[spell].HealsDur = HealBot_Spells[spell].HealsCast+HealBot_Spells[spell].HealsExt;
end

function HealBot_AddHeal(spell)
  if HealBot_Config.UseHealing[HealBot_Spells[spell].Group]==0 then return end
  HealBot_AddDebug("... " .. spell);
  HealBot_SetSpellDefaults(spell);
  table.foreachi(HealBot_Spells[spell].Target,function (i,val)
    HealBot_AddDebug("...... " .. val);
    table.insert(HealBot_Heals[val],spell);
  end);
  HealBot_Spells[spell].BagSlot = HealBot_GetBagSlot(spell);
end

function HealBot_FindHealSpells()
  local id = 1;
  HealBot_AddDebug("Searching for healing spells ...");
  HealBot_Heals = { player = {}, pet = {}, party = {} };
  while true do
    local spell = HealBot_GetSpellName(id);
    if not spell then
      do break end
    end
    if (HealBot_Spells[spell]) then
      HealBot_AddHeal(spell);
    end
    id = id + 1;
  end
  local items = {};
  for bag=0,NUM_BAG_FRAMES do
    for slot=1,GetContainerNumSlots(bag) do
      local item = HealBot_GetItemName(bag,slot);
--      if item then HealBot_AddDebug(item); end
      if HealBot_Spells[item] and not items[item] then
        HealBot_AddHeal(item);
        items[item] = 1;
      end
    end
  end
  table.foreach(HealBot_Heals, function (key,val)
    if (table.getn(val)==0) then
      HealBot_Heals[key] = nil;
    end
  end);
--  HealBot_DumpHeals();
  HealBot_Heals.target = HealBot_Heals.party;
  for i=1,4 do
    HealBot_Heals["party"..i] = HealBot_Heals.party;
    HealBot_Heals["partypet"..i] = HealBot_Heals.party;
  end
  for i=1,40 do
    HealBot_Heals["raid"..i] = HealBot_Heals.party;
    HealBot_Heals["raidpet"..i] = HealBot_Heals.party;
  end
end


function HealBot_GetShapeshiftForm()
  local forms = GetNumShapeshiftForms();
  if forms then
    local i;
    for i=1,forms do
      local icon,name,active = GetShapeshiftFormInfo(i);
--      local act = "false";
--      if active then 
--        act = "true";
--      end
--      HealBot_AddDebug(icon .. " - " .. name .. " - " .. act);
      if active and not string.find(icon,"HumanoidForm") then return i; end
    end
  end
  return nil;
end

function HealBot_CanCastSpell(spell,unit)
  local this = HealBot_Spells[spell];
  if not this then return false end;

  if this.Mana>UnitMana("player") then return false end;
  if this.Level>UnitLevel(unit)+10 then return false end;
  if this.Channel>0 and HealBot_IsMoving then return false end;
  if UnitOnTaxi("player") then return false end;
  if HealBot_UnitClass("player")=="DRUID" and HealBot_GetShapeshiftForm() then return false end;
  if HealBot_UnitAffected(unit,this.Buff) then return false end;
  if HealBot_UnitAffected(unit,this.Debuff) then return false end;
  if HealBot_Config.ProtectPvP==1 and UnitIsPVP(unit) and not UnitIsPVP("player") then return false end
  if this.BagSlot then
    local bag,slot = HealBot_UnpackBagSlot(this.BagSlot);
    local start, duration, enable = GetContainerItemCooldown(bag,slot);
    if (start > 0 and duration > 0 and enable > 0) then
      return false;
    end
  end
-- maybe range as well
  return true;
end

function HealBot_GetHealSpell(unit,pattern)
  if (not UnitName(unit)) then return nil end;
  if pattern then
    return HealBot_GetSpellName(HealBot_GetSpellId(pattern))
  end
  if (not HealBot_Heals[unit]) then return nil end
  HealBot_AddDebug("Finding healing spell for " .. UnitName(unit) .. " ...");
--  if (not UnitIsVisible(unit)) then return nil end;

  local Current,Desired = HealBot_UnitHealth(unit)
  if pattern then Current = 0 end
  local Needed = Desired-Current;
  if (Needed<=0 and not HealBot_AlwaysHeal()) then return nil end
  HealBot_AddDebug("... needs " .. math.floor(Needed+0.5) .. " HP");

  local UnitDist = HealBot_Distance(unit);
  local PlayerHealth,PlayerMana = UnitHealth('player'),UnitMana('player');
  local UnitDPS,UnitTTL = HealBot_UnitDPS(unit),HealBot_UnitTTL(unit);
  local PlayerDPS,PlayerTTH = HealBot_UnitDPS('player'),HealBot_UnitTTH('player');
  local BestSpell = nil;
  local BestScore;
  local HealModifier;
  HealBot_AddDebug("Choosing between " .. table.getn(HealBot_Heals[unit]) .. " spells ...");
  table.foreachi(HealBot_Heals[unit], function (i,spell)
    if pattern and not string.find(spell,pattern) then return end;
    local this = HealBot_Spells[spell];
--    if this.Shield and HealBot_Options.CastShields==0 and not pattern then return end;
    if (UnitDist>this.Range) then return end;
    if (HealBot_CanCastSpell(spell,unit)) then
      -- adjust for possible hit during channelling
      if this.Channel-this.Cast>PlayerTTH then
        this.HealsDur = this.HealsDur-this.HealsExt*(this.Channel-this.Cast-PlayerTTH)/(this.Channel-this.Cast);
        this.Channel = this.Cast+PlayerTTH;
        this.Duration = this.Channel; 
      end
      local Health = Current+this.HealsDur-UnitDPS*this.Duration;
      if Health>Desired then
        Health = Desired;
      end
      if this.Shield then
        Health = Current;
        this.Duration = this.Shield;
        if UnitDPS*this.Duration>this.HealsDur then
          this.Duration = this.HealsDur/UnitDPS;
        end
      end
      local Score = 0;
--      if HealBot_Config.ConserveMana==1 then
--        Score = 1;
--        Score = Score - (Current+300)/(Health+300);
--        Score = Score - this.Mana/PlayerMana;
--        Score = Score - PlayerDPS*this.Channel/PlayerHealth;
--      else
--        local mult = 1;
--        mult = (mult*UnitManaMax('player')-(mult-1)*(PlayerMana-this.Mana/2))/UnitManaMax('player');
--        Score = Score + Health;
--        Score = Score - this.Mana*mult;
--      end
      local n = HealBot_Config.ConserveMana or 0;
      if (n==1.0) then
        Score = Score + Desired*math.log(Health/Current);
        Score = Score - UnitManaMax('player')*math.log(PlayerMana/(PlayerMana-this.Mana+1));
      else
        Score = Score + math.pow(Desired,n)/(1-n)*(math.pow(Health,(1-n))-math.pow(Current,(1-n)));
        Score = Score - math.pow(UnitManaMax('player'),n)/(1-n)*(math.pow(PlayerMana,(1-n))-math.pow((PlayerMana-this.Mana+1),(1-n)));
      end
      Score = Score - (0+PlayerDPS)*this.Channel;
      Score = Score + UnitDPS*this.Duration;
      Score = Score - this.Price;
      if this.Mana>PlayerMana*(1-HealBot_Config.ManaReserve) then
        Score = Score - 5000;
      end
      if this.BagSlot and this.Price==0 then
        Score = Score - this.HealsDur/100;
      end
      if this.BagSlot and UnitPowerType('player')==0 then
        Score = Score * (1-(PlayerMana/UnitManaMax('player')-0.4)*0.5);
      end
      if this.BagSlot and not HealBot_IsFighting then
        Score = Score - 1000;
      end
      if Current-UnitDPS*this.Cast+this.HealsCast<UnitDPS*5 then
        Score = Score - 10000;
      end
      if Current-UnitDPS*this.Duration+this.HealsDur<UnitDPS*5 then
        Score = Score - 10000;
      end
      if unit~= "player" and PlayerHealth-PlayerDPS*this.Channel<UnitDPS*5 then
        Score = Score - 10000;
      end
      -- maybe:  something with HP/Mana ratio
      -- maybe:  something with player moving
      -- maybe:  something with aggro mngment
      HealBot_AddDebug("... " .. math.floor(Score+0.5) .. " - " .. spell .. " - heals " .. HealBot_Spells[spell].HealsDur .. " ...");
      if not BestSpell or Score>BestScore then
        BestSpell = spell;
        BestScore = Score;
      end
    end
  end);
  HealBot_AddDebug("... " .. (BestSpell or "none") .. " selected " .. (math.floor((BestScore or 0)+0.5)));
  return BestSpell;
end

--------------------------------------------------------------------------------------------------
-- status functions
--------------------------------------------------------------------------------------------------

function HealBot_InitStatus()
  return { Health = 0, Damage = {}, DPS = 0, TTH = 10 };
end

HealBot_UnitStatus = {
  player = HealBot_InitStatus(),
  pet    = HealBot_InitStatus(),
  target = HealBot_InitStatus(),
};

for i=1,4 do
  HealBot_UnitStatus["party"..i] = HealBot_InitStatus();
  HealBot_UnitStatus["partypet"..i] = HealBot_InitStatus();
end
for i=1,40 do
  HealBot_UnitStatus["raid"..i] = HealBot_InitStatus();
  HealBot_UnitStatus["raidpet"..i] = HealBot_InitStatus();
end

function HealBot_UpdateDPS(unit)
  local now = GetTime();
  while HealBot_UnitStatus[unit].Damage[1] and HealBot_UnitStatus[unit].Damage[1].Time<now-60.0  do
    table.remove(HealBot_UnitStatus[unit].Damage,1);
  end

  local DPS,TTH = 0,0;
  table.foreachi(HealBot_UnitStatus[unit].Damage, function (i,val) 
    DPS = DPS + val.Amount*math.exp((val.Time-now)/HEALBOT_DPS_HORIZON);
    TTH = TTH + 1*math.exp((val.Time-now)/HEALBOT_DPS_HORIZON);
  end);
  DPS = DPS/HEALBOT_DPS_HORIZON;
  TTH = TTH/HEALBOT_DPS_HORIZON;
  if TTH<0.05 then TTH = 0.05 end
  HealBot_UnitStatus[unit].DPS = math.floor(10*DPS+0.5)/10;
  HealBot_UnitStatus[unit].TTH = math.floor(10*0.5/TTH+0.5)/10;
end

function HealBot_UpdateHealth(unit)
  if (UnitHealth(unit)<HealBot_UnitStatus[unit].Health) then
    HealBot_AddDebug(UnitName(unit)..": "..HealBot_UnitStatus[unit].Health.." -> "..UnitHealth(unit));
    table.insert(HealBot_UnitStatus[unit].Damage,
      {Time = GetTime(), Amount = HealBot_UnitStatus[unit].Health-UnitHealth(unit)});
  end
  HealBot_UnitStatus[unit].Health = UnitHealth(unit);
  HealBot_UpdateDPS(unit);
end

function HealBot_UpdateReset(unit)
  HealBot_UnitStatus[unit] = HealBot_InitStatus();
  HealBot_UpdateHealth(unit);
end

--------------------------------------------------------------------------------------------------
-- DPS functions
--------------------------------------------------------------------------------------------------

HEALBOT_DPS_HORIZON = 5.0;

function HealBot_UnitDPS(unit)
  if unit=='target' then return 0; end
  if HealBot_UnitAffected(unit,HEALBOT_EFFECT_POWER_WORD_SHIELD) then return 0; end
--[[
  local now = GetTime();
  while HealBot_UnitStatus[unit].Damage[1] and HealBot_UnitStatus[unit].Damage[1].Time<now-60.0  do
    table.remove(HealBot_UnitStatus[unit].Damage,1);
  end
  local total = 0;
  table.foreachi(HealBot_UnitStatus[unit].Damage, function (i,val) 
    total = total + val.Amount*math.exp((val.Time-now)/HEALBOT_DPS_HORIZON);
  end);
  local dps = total/HEALBOT_DPS_HORIZON;
  return math.floor(10*dps+0.5)/10;
--]]
  return HealBot_UnitStatus[unit].DPS;
end

function HealBot_UnitTTL(unit)
  local dps = HealBot_UnitDPS(unit);
  local health = UnitHealth(unit);

  if (dps>0 and health>1) then
    return math.floor(health/dps+0.5);
  else
    return 3600;  -- you probably die within an hour anyway :-)
  end
end

function HealBot_UnitTTH(unit)
  if unit=='target' then return 10; end
  if HealBot_UnitAffected(unit,HEALBOT_EFFECT_POWER_WORD_SHIELD) then return 10; end
--[[
  local now = GetTime();
  while HealBot_UnitStatus[unit].Damage[1] and HealBot_UnitStatus[unit].Damage[1].Time<now-60.0  do
    table.remove(HealBot_UnitStatus[unit].Damage,1);
  end
  local total = 0;
  table.foreachi(HealBot_UnitStatus[unit].Damage, function (i,val) 
    total = total + 1*math.exp((val.Time-now)/HEALBOT_DPS_HORIZON);
  end);
  local dps = total/HEALBOT_DPS_HORIZON;
  if dps<0.05 then return 10; end
  return math.floor(10*0.5/dps+0.5)/10;
--]]
  return HealBot_UnitStatus[unit].TTH;
end

--------------------------------------------------------------------------------------------------
-- scripting functions
--------------------------------------------------------------------------------------------------

function HealBot_HealUnit(unit,pattern)
  HealBot_CastSpellOnFriend(HealBot_GetHealSpell(unit,pattern),unit);
end

function HealBot_RecalcHeals(unit)
  HealBot_Action_Refresh(unit);
end

function HealBot_RecalcParty()
  HealBot_Action_PartyChanged();
--  HealBot_Action_RefreshButtons();
end

function HealBot_RecalcSpells()
  HealBot_FindHealSpells();
  HealBot_RecalcParty();
end

--------------------------------------------------------------------------------------------------
-- OnFoo functions
--------------------------------------------------------------------------------------------------

function HealBot_OnLoad(this)
--  this:RegisterEvent("PLAYER_ENTER_COMBAT");
--  this:RegisterEvent("PLAYER_LEAVE_COMBAT");
  this:RegisterEvent("PLAYER_REGEN_DISABLED");
  this:RegisterEvent("PLAYER_REGEN_ENABLED");
  this:RegisterEvent("VARIABLES_LOADED");
  this:RegisterEvent("PLAYER_TARGET_CHANGED");
  this:RegisterEvent("PARTY_MEMBERS_CHANGED");
  this:RegisterEvent("PARTY_MEMBER_DISABLED");
  this:RegisterEvent("PARTY_MEMBER_ENABLED");
  --this:RegisterEvent("UNIT_NAME_UPDATE");
  this:RegisterEvent("PLAYER_ENTERING_WORLD");
  this:RegisterEvent("PET_BAR_SHOWGRID");
  this:RegisterEvent("PET_BAR_HIDEGRID");
  this:RegisterEvent("UNIT_HEALTH");
  this:RegisterEvent("UNIT_MANA");
  this:RegisterEvent("SPELLS_CHANGED");
  this:RegisterEvent("SPELLCAST_START");
  this:RegisterEvent("SPELLCAST_STOP");
  this:RegisterEvent("SPELLCAST_INTERRUPTED");
  this:RegisterEvent("SPELLCAST_FAILED");
  this:RegisterEvent("BAG_UPDATE");
  this:RegisterEvent("BAG_UPDATE_COOLDOWN");
  this:RegisterEvent("UNIT_AURA");
  this:RegisterEvent("ADDON_LOADED");
  -- Set up slash commands
  SLASH_HEALBOT1 = "/healbot";
  SLASH_HEALBOT2 = "/hb";
  SlashCmdList["HEALBOT"] = function(msg)
    HealBot_SlashCmd(msg);
  end

  HealBot_AddError(HEALBOT_ADDON .. HEALBOT_LOADED);
end

function HealBot_RegisterThis(this)

  HealBot_AddError("registered");
end 



local HealBot_Timer1,HealBot_Timer2 = 0,0;
function HealBot_OnUpdate(this,arg1)
  HealBot_Timer1 = HealBot_Timer1+arg1;
  if HealBot_Timer1>=0.2 then
    HealBot_Timer1 = 0;
    HealBot_CheckCasting();
    HealBot_CheckMoving();
  end

  HealBot_Timer2 = HealBot_Timer2+arg1;
  if HealBot_Timer2>=1.0 then
--    HealBot_AddDebug("updating DPS...");
    HealBot_Timer2 = 0;
    table.foreach(HealBot_UnitStatus, function (unit,status) 
      HealBot_UpdateDPS(unit);
    end)
    HealBot_Action_RefreshTooltip();
  end
end

function HealBot_OnEvent(this, event, arg1)
  --HealBot_AddChat("OnEvent (" .. event .. ")");
  if (event=="UNIT_HEALTH") then
    HealBot_OnEvent_UnitHealth(this,arg1);
  elseif (event=="UNIT_MANA") then
    HealBot_OnEvent_UnitMana(this,arg1);
  elseif (event=="UNIT_AURA") then
    HealBot_OnEvent_UnitAura(this,arg1);
  elseif (event=="SPELLCAST_START") then
    HealBot_OnEvent_SpellcastStart(this);
  elseif (event=="SPELLCAST_STOP") then
    HealBot_OnEvent_SpellcastStop(this);
  elseif (event=="SPELLCAST_INTERRUPTED") then
    HealBot_OnEvent_SpellcastStop(this);
  elseif (event=="SPELLCAST_FAILED") then
    HealBot_OnEvent_SpellcastStop(this);
  elseif (event=="PLAYER_REGEN_DISABLED") then
    HealBot_OnEvent_PlayerRegenDisabled(this);
  elseif (event=="PLAYER_REGEN_ENABLED") then
    HealBot_OnEvent_PlayerRegenEnabled(this);
  elseif (event=="BAG_UPDATE_COOLDOWN") then
    HealBot_OnEvent_BagUpdateCooldown(this,arg1);
  elseif (event=="BAG_UPDATE") then
    HealBot_OnEvent_BagUpdate(this,arg1);
  elseif (event=="PARTY_MEMBER_DISABLE") then
    HealBot_OnEvent_PartyMemberDisable(this,arg1);
  elseif (event=="PARTY_MEMBER_ENABLE") then
    HealBot_OnEvent_PartyMemberEnable(this,arg1);
  elseif (event=="PARTY_MEMBERS_CHANGED") then
    HealBot_OnEvent_PartyMembersChanged(this);
  elseif (event=="PLAYER_TARGET_CHANGED") then
    HealBot_OnEvent_PlayerTargetChanged(this);
  elseif (event=="PET_BAR_SHOWGRID") then
    HealBot_OnEvent_PartyMembersChanged(this);
  elseif (event=="PET_BAR_HIDEGRID") then
    HealBot_OnEvent_PartyMembersChanged(this);
  elseif (event=="SPELLS_CHANGED") then
    HealBot_OnEvent_SpellsChanged(this);
  elseif (event=="PLAYER_ENTERING_WORLD") then
    HealBot_OnEvent_PlayerEnteringWorld(this);
  elseif (event=="UNIT_NAME_UPDATE") then
    HealBot_OnEvent_UnitNameUpdate(this);
  elseif (event=="VARIABLES_LOADED") or (event=="ADDON_LOADED")then
    HealBot_OnEvent_VariablesLoaded(this);
  else
    HealBot_AddDebug("OnEvent (" .. event .. ")");
  end
end

function HealBot_OnEvent_VariablesLoaded(this)
  HealBot_AddDebug("VARIABLES_LOADED");

  table.foreach(HealBot_ConfigDefaults, function (key,val)
    if not HealBot_Config[key] then
      HealBot_Config[key] = val;
    end
  end);

  table.foreach(HealBot_Spells, function (key,val)
    HealBot_SetSpellDefaults(key)
  end)

  HealBot_Options_ActionAlpha:SetValue(HealBot_Config.ActionAlpha);
  HealBot_Set_Alpha(HealBot_Config.ActionAlpha);
  if HealBot_Config.ActionVisible==1 then HealBot_Action:Show() end
  HealBot_RecalcSpells();
end

function HealBot_OnEvent_UnitHealth(this,unit)
--  HealBot_AddDebug("UNIT_HEALTH (" .. unit .. ")");
  if (not HealBot_Heals[unit]) then return end
  HealBot_UpdateHealth(unit);
  HealBot_CheckCasting(unit)
  HealBot_RecalcHeals(unit);
end

function HealBot_OnEvent_UnitMana(this,unit)
--  HealBot_AddDebug("UNIT_MANA (" .. unit .. ")");
  if (unit~='player') then return end
  HealBot_RecalcHeals();
end

function HealBot_OnEvent_UnitAura(this,unit)
--  HealBot_AddDebug("UNIT_AURA (" .. unit .. ")");
  if (not HealBot_Heals[unit]) then
    return;
  end
  HealBot_RecalcHeals(unit);
end

function HealBot_OnEvent_PlayerRegenDisabled(this)
  HealBot_AddDebug("PLAYER_REGEN_DISABLED");
  HealBot_IsFighting = true;
  HealBot_RecalcHeals();
end

function HealBot_OnEvent_PlayerRegenEnabled(this)
  HealBot_AddDebug("PLAYER_REGEN_ENABLED");
  HealBot_IsFighting = false;
  HealBot_RecalcHeals();
end

function HealBot_OnEvent_PlayerTargetChanged(this)
  HealBot_AddDebug("PLAYER_TARGET_CHANGED");
  HealBot_UpdateReset("target");
  HealBot_RecalcParty();
end

function HealBot_OnEvent_PartyMembersChanged(this)
  HealBot_AddDebug("PARTY_MEMBERS_CHANGED");
  HealBot_RecalcParty();
end

function HealBot_OnEvent_PartyMemberDisable(this,unit)
  HealBot_AddDebug("PARTY_MEMBER_DISABLE (" .. unit .. ")");
  HealBot_RecalcParty();
end

function HealBot_OnEvent_PartyMemberEnable(this,unit)
  HealBot_AddDebug("PARTY_MEMBER_ENABLE (" .. unit .. ")");
  HealBot_RecalcParty();
end

function HealBot_OnEvent_SpellsChanged(this)
  HealBot_AddDebug("SPELLS_CHANGED");
  HealBot_RecalcSpells();
end

function HealBot_OnEvent_BagUpdate(this,bag)
  HealBot_AddDebug("BAG_UPDATE (" .. bag .. ")");
  HealBot_RecalcSpells();
end

function HealBot_OnEvent_BagUpdateCooldown(this,bag)
  if not bag then bag = "undef"; end
  HealBot_AddDebug("BAG_UPDATE_COOLDOWN (" .. bag .. ")");
  HealBot_RecalcSpells();
end

function HealBot_OnEvent_UnitNameUpdate(this,unit)
  if not unit then unit = "undef"; end
  -- NOTE: has no spellbook on initial UI load
  -- Handle this by using PLAYER_ENTERING_WORLD
  HealBot_AddDebug("UNIT_NAME_UPDATE (" .. unit .. ")");
  HealBot_RecalcSpells();
end

function HealBot_OnEvent_PlayerEnteringWorld(this)
  -- NOTE: is not called on UI reload
  -- Handle this by using UNIT_NAME_UPDATE
  HealBot_AddDebug("PLAYER_ENTERING_WORLD");
  HealBot_RecalcSpells();
end

HealBot_IsCasting = false;

function HealBot_OnEvent_SpellcastStart(this)
  HealBot_AddDebug("SPELLCAST_START");
  HealBot_IsCasting = true;
  HealBot_RecalcHeals();
end

function HealBot_OnEvent_SpellcastStop(this)
  HealBot_AddDebug("SPELLCAST_STOP");
  HealBot_StopCasting();
  HealBot_IsCasting = false;
  HealBot_RecalcHeals();
end
---
-- Here begins oscars hacks
---
function HealBot_Add_HealModifier(spell)
	local heals_modifer = 1;
	local playerClass, englishClass = UnitClass("player");
	--HealBot_AddDebug("entered with " .. spell);
 	--HealBot_AddDebug("entered with " .. strsub(spell, 0, 10));
 	if (englishClass == "PALADIN") then
	 	if (strsub(spell, 0, 6) == strsub(HEALBOT_FLASH_OF_LIGHT, 0, 6)) or (strsub(spell, 0, 6) == strsub(HEALBOT_HOLY_LIGHT, 0, 6)) then
	    	nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(1,5); -- Healing Light
	       	heals_modifer = heals_modifer + (currRank*0.04);
	  	end
	elseif (englishClass == "DRUID") then
		if (strsub(spell, 0, 6) == strsub(HEALBOT_REJUVENATION, 0, 6)) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(3,10); -- Imp Rejuv
	        heals_modifer = heals_modifer + (currRank*0.05);
		end
		if (strsub(spell, 0, 6) == strsub(HEALBOT_REJUVENATION, 0, 6) or (strsub(spell, 0, 6) == strsub(HEALBOT_HEALING_TOUCH, 0, 6)) or (strsub(spell, 0, 6) == strsub(HEALBOT_REGROWTH, 0, 6))) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(3,12); -- Gift of Nature
			heals_modifer = heals_modifer + (currRank*0.02);
	    end
	elseif (englishClass=="PRIEST") then
		if (strsub(spell, 0, 4) == strsub(HEALBOT_RENEW, 0, 4)) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2,2); -- Imp Renew
	        heals_modifer = heals_modifer + (currRank*0.05);
		end	
		if strsub(spell, 0, 4) == strsub(HEALBOT_RENEW, 0, 4) or strsub(spell, 0, 6) == strsub(HEALBOT_FLASH_HEAL, 0, 6) or strsub(spell, 0, 6) == strsub(HEALBOT_GREATER_HEAL, 0, 6) or strsub(spell, 0, 6) == strsub(HEALBOT_LESSER_HEAL, 0, 6) or strsub(spell, 0, 3) == strsub(HEALBOT_HEAL, 0, 3) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2,15); -- Spiritual Healing
			heals_modifer = heals_modifer + (currRank*0.02);
			--nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2,14); -- Spiritual guidence
			--spiGuideBonus = HealBot_GetBonus('Spirit') * 0.05;
			--heals_modifer = heals_modifer + (currRank * spiGuideBonus);
	    end
	elseif (englishClass=="SHAMAN") then
		if (strsub(spell, 0, 6) == strsub(HEALBOT_LESSER_HEALING_WAVE, 0, 6) or (strsub(spell, 0, 6) == strsub(HEALBOT_HEALING_WAVE, 0, 6))) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(3,14); -- Purification
			heals_modifer = heals_modifer + (currRank*0.02);
	    end
	elseif (englishClass=="HUNTER") then
		-- Nothing to do
	elseif (englishClass=="WARLOCK") then
		if (strsub(spell, 0, 6) == strsub(HEALBOT_HEALTH_FUNNEL, 0, 6)) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2,4); -- Imp Health funnel
			heals_modifer = heals_modifer + (currRank*0.10);
	    end
	else
		-- Nothing to do
	end 
  	return heals_modifer;
end

function HealBot_Fix_CastSpeed(spell)
	local speed_fix=0;
	local playerClass, englishClass = UnitClass("player");
 	if (englishClass == "PALADIN") then
	 	-- Do nothing
	elseif (englishClass == "DRUID") then
		if (strsub(spell, 0, 6) == strsub(HEALBOT_HEALING_TOUCH, 0, 6)) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(3,3); -- Imp Healing touch
	        speed_fix = (currRank*0.1);
		end
	elseif (englishClass == "PRIEST") then
		if strsub(spell, 0, 4) == strsub(HEALBOT_RENEW, 0, 4) or strsub(spell, 0, 6) == strsub(HEALBOT_FLASH_HEAL, 0, 6) or strsub(spell, 0, 6) == strsub(HEALBOT_GREATER_HEAL, 0, 6) or strsub(spell, 0, 6) == strsub(HEALBOT_LESSER_HEAL, 0, 6) or strsub(spell, 0, 3) == strsub(HEALBOT_HEAL, 0, 3) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2,2); -- Imp Renew
	        speed_fix = (currRank*0.05);
		end	
		if strsub(spell, 0, 6) == strsub(HEALBOT_GREATER_HEAL, 0, 6) or strsub(spell, 0, 3) == strsub(HEALBOT_HEAL, 0, 3) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2,5) -- Devine fury
			speed_fix = (currRank*0.1);
	    end
	elseif (englishClass == "SHAMAN") then
		if strsub(spell, 0, 6) == strsub(HEALBOT_LESSER_HEALING_WAVE, 0, 6) or strsub(spell, 0, 6) == strsub(HEALBOT_HEALING_WAVE, 0, 6) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(3,2) -- Tidal focus
			speed_fix = (currRank*0.1);
	    end
	elseif (englishClass=="HUNTER") then
		-- Nothing to do
	elseif (englishClass=="WARLOCK") then
		-- Nothing to do
	else
		-- Nothing to do
	end 
	return speed_fix;
end

function HealBot_Fix_Range(spell)
	-- no talents that affect healing, yet.
	local range_fix=0;
	local playerClass, englishClass = UnitClass("player");
 	if (englishClass=="PALADIN") then
	 	-- Do nothing
	elseif (englishClass=="DRUID") then
		-- Do nothing
	elseif (englishClass=="PRIEST") then
		-- Nothing to do unless I implement holy nova
	elseif (englishClass=="SHAMAN") then
		-- Do nothing
	elseif (englishClass=="HUNTER") then
		-- Nothing to do
	elseif (englishClass=="WARLOCK") then
		-- Nothing to do
	else
		-- Nothing to do
	end 
	return range_fix;
end

function HealBot_Fix_ManaCost(spell)
	local mana_fix=1;
	local playerClass, englishClass = UnitClass("player");
 	if (englishClass=="PALADIN") then
	 	-- Do nothing
	elseif (englishClass=="DRUID") then
		-- Do nothing
		if strsub(spell, 0, 6) == strsub(HEALBOT_HEALING_TOUCH, 0, 6) or strsub(spell, 0, 6) == strsub(HEALBOT_REJUVENATION, 0, 6) or strsub(spell, 0, 6) == strsub(HEALBOT_REGROWTH, 0, 6) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(1,14) -- Moonglow
			mana_fix=mana_fix - (currRank*0.03);
		end
		if strsub(spell, 0, 4) == strsub(HEALBOT_HEALING_TOUCH, 0, 6)then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(3,9) -- Tranquil spirit
			mana_fix=mana_fix - (currRank*0.02);
		end
	elseif (englishClass=="PRIEST") then
		if strsub(spell, 0, 6) == strsub(HEALBOT_GREATER_HEAL, 0, 6) or strsub(spell, 0, 3) == strsub(HEALBOT_HEAL, 0, 3) or strsub(spell, 0, 6) == strsub(HEALBOT_LESSER_HEAL, 0, 6) then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(3,1) -- Imp healing
			mana_fix=mana_fix - (currRank*0.05);
		end
		if strsub(spell, 0, 4) == strsub(HEALBOT_RENEW, 0, 4)then
			nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(1,10) -- Mental agility
			mana_fix=mana_fix - (currRank*0.02);
		end
	elseif (englishClass=="SHAMAN") then
		-- Do nothing
	elseif (englishClass=="HUNTER") then
		-- Nothing to do
	elseif (englishClass=="WARLOCK") then
		-- Nothing to do
	else
		-- Nothing to do
	end 
	return mana_fix;
end

function HealBot_Set_Alpha(alpha)
  HealBot_Action:SetBackdropColor(
    TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
    TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
    TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, 
    alpha*0.8);
  HealBot_Action:SetBackdropBorderColor(
    TOOLTIP_DEFAULT_COLOR.r,
    TOOLTIP_DEFAULT_COLOR.g,
    TOOLTIP_DEFAULT_COLOR.b, 
    (alpha+1)/2);
end





function HealBot_Check_Buff(sBuffname) 
  local iIterator = 1
  sUnitname = "player"
  while (UnitBuff(sUnitname, iIterator)) do
    if (string.find(UnitBuff(sUnitname, iIterator), sBuffname)) then
      return true
    end
    iIterator = iIterator + 1
  end
  return false
end

function HealBot_GetBonus(stat)
  local loaded, reason = LoadAddOn("BonusScanner");
  if (not loaded) then
  	return 0;
  else
  	return BonusScanner:GetBonus(stat);
  end
end

function HealBot_Get_DebugChan()
	local index = GetChannelName("HBdbg");
	if (index>0) then
		return index;
	else
		HealBot_AddError("channel setup");
		index = JoinChannelByName("HBdbg",nil, ChatFrame1:GetID());
		return index;
	end
end

function HealBot_Clear_DebugChan()
	LeaveChannelByName("HBdbg");
end

--
--
function HealBot_SpiBonus(spell)
	local heals_modifer = 1;
	local base, stat, posBuff, negBuff = UnitStat("player",5);
	nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2,14); -- Spiritual guidence
	spiGuideBonus = stat * 0.05;
	heals_modifer = heals_modifer + (currRank * spiGuideBonus);
	return heals_modifer;
end