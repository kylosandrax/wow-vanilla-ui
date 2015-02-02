-- gibt es eine Gruppe nach Strat / UBRS / Scholo ?  Jäger 60 vorhanden !

HealBot_Action_HealGroup = {
  "player",
  "pet",
  "party1",
  "party2",
  "party3",
  "party4",
};

HealBot_Action_HealTarget = {
};

HealBot_Action_HealButtons = {
};

HealBot_Action_UnitButtons = {
};

function HealBot_Action_AddDebug(msg)
  HealBot_AddDebug("Action: " .. msg);
end

function HealBot_HealthColor(unit,alpha)
  local pct = UnitHealth(unit)/UnitHealthMax(unit);
  local r,g,b = 1.0, 1.0, 0.0;
  if pct>0.6 then r = 0.0; end
  if pct<0.3 then g = 0.0; end
  return r,g,b,alpha;
end

HEALBOT_ALPHA = HealBot_Config.ActionAlpha;

function HealBot_Action_HealthBar(button)
  local name = button:GetName();
  return getglobal(name.."Bar");
end

function HealBot_AlwaysHeal()
  return HealBot_Config.EnableHealthy==1 or IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() or HealBot_Debug
end

function HealBot_MayHeal(unit)
  if not UnitName(unit) or not HealBot_Heals[unit] then return false end
  if unit ~= 'target' then return true end
  if not HealBot_Config.TargetHeals or UnitCanAttack("player",unit) then return false end
  return true;
end

function HealBot_ShouldHeal(unit)
  return HealBot_MayHeal(unit) and UnitHealth(unit)>0 and not UnitIsDeadOrGhost(unit)
    and (UnitHealth(unit)<UnitHealthMax(unit)*HealBot_Config.HealthPct or HealBot_AlwaysHeal());
end

function HealBot_Action_ShouldHealSome()
  return table.foreach(HealBot_Action_HealButtons, function (index,button)
    if (HealBot_ShouldHeal(button.unit)) then return button.unit; end
  end);
end

function HealBot_MustHeal(unit)
  return HealBot_ShouldHeal(unit) and UnitHealth(unit)<UnitHealthMax(unit)*HealBot_Config.AlertLevel
end

function HealBot_Action_MustHealSome()
  return table.foreach(HealBot_Action_HealButtons, function (index,button)
    if (HealBot_MustHeal(button.unit)) then return button.unit; end
  end);
end

function HealBot_CanHeal(unit)
  return HealBot_ShouldHeal(unit) and HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern());
end

function HealBot_Action_EnableButton(button)
  if (not HealBot_IsCasting and HealBot_CanHeal(button.unit)) then
    button:Enable();
  else
    button:Disable();
  end
end

function HealBot_Action_EnableButtons()
  table.foreach(HealBot_Action_HealButtons, function (index,button)
    HealBot_Action_EnableButton(button);
  end);
end

function HealBot_Action_RefreshButton(button)
  if not button then return end
  if type(button)~="table" then DEFAULT_CHAT_FRAME:AddMessage("***** "..type(button)) end
  local unit = button.unit;
  if HealBot_MayHeal(unit) then
    local bar = HealBot_Action_HealthBar(button);
    bar:SetMinMaxValues(0,UnitHealthMax(unit));
    bar:SetValue(UnitHealth(unit));
    bar:SetStatusBarColor(HealBot_HealthColor(unit,HEALBOT_ALPHA));

    local text = UnitName(unit);
    if string.len(text)>15 then
      text = string.sub(text,1,15) .. '...';
    end
    local secs = HealBot_UnitTTL(unit);
    if secs>0 and secs<=HealBot_Config.AlertSeconds then
      text = text .. ' (' .. secs .. ')';
    end
    button:SetText(text);
 
    HealBot_Action_EnableButton(button)
--    HealBot_Action_AddDebug("refreshing button for "..button.unit);
  end
end

function HealBot_Action_RefreshButtons()
  HealBot_Action_AddDebug("HealBot_Action_RefreshButtons");
  table.foreach(HealBot_Action_HealButtons, function (index,button)
    HealBot_Action_RefreshButton(button);
  end);
end

function HealBot_Action_RefreshButtons(unit)
  if unit and HealBot_Action_UnitButtons[unit] then
    HealBot_Action_AddDebug("HealBot_Action_RefreshButtons ("..unit..")");
    table.foreach(HealBot_Action_UnitButtons[unit], function (index,button)
      HealBot_Action_RefreshButton(button);
    end);
  else
    HealBot_Action_AddDebug("HealBot_Action_RefreshButtons (nil)");
    table.foreach(HealBot_Action_HealButtons, function (index,button)
      HealBot_Action_RefreshButton(button);
    end);
    HealBot_Action_AddDebug("refreshing all buttons");
    
  end
end

function HealBot_Action_PositionButton(button,offset)
  local unit = button.unit;
  button:SetText(UnitName(unit) or (string.upper(string.sub(unit,1,1)) .. string.sub(unit,2)));
  if (HealBot_MayHeal(unit)) then
    button:Show();
    button:ClearAllPoints();
    button:SetPoint("TOP","HealBot_Action","TOP",0,-offset);
--    button:SetPoint("TOPRIGHT","HealBot_Action","TOPRIGHT",-10,-offset);
    offset = offset+button:GetHeight()+6;
  else
    button:Hide();
  end
  return offset;
end

function HealBot_Action_SetHeight(height)
-- due to strange behavior for saved window pos from last session:
  if HealBot_Config.ActionHeight then
    HealBot_Action:SetHeight(HealBot_Config.ActionHeight);
  end
  HealBot_Action_AddDebug("height="..height..", growup="..HealBot_Config.GrowUpwards);
  if HealBot_Config.GrowUpwards==1 then
    local left,bottom = HealBot_Action:GetLeft(),HealBot_Action:GetBottom();
    if left and bottom then
      HealBot_Action:ClearAllPoints();
--      HealBot_Action:SetPoint("TOPLEFT","UIParent","BOTTOMLEFT",left,bottom+height);
      HealBot_Action:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT",left,bottom);
    end
  else
    local left,top = HealBot_Action:GetLeft(),HealBot_Action:GetTop();
    if left and top then
      HealBot_Action:ClearAllPoints();
      HealBot_Action:SetPoint("TOPLEFT","UIParent","BOTTOMLEFT",left,top);
    end
  end
  HealBot_Action:SetHeight(height);
  HealBot_Config.ActionHeight = height;
end

function HealBot_Action_SetHealButton(index,unit)
  if not index then
    HealBot_Action_HealButtons = {};
    HealBot_Action_UnitButtons = {};
    return nil
  end
  local button = getglobal("HealBot_Action_HealUnit"..index);
  button.unit = unit;
  if unit then
    table.insert(HealBot_Action_HealButtons,button);
    if not HealBot_Action_UnitButtons[unit] then HealBot_Action_UnitButtons[unit] = {} end
    table.insert(HealBot_Action_UnitButtons[unit],button);
  else
    button:Hide();
  end
  return button;
end

function HealBot_Action_PartyChanged()
  -- assign units to 17 heal buttons
  HealBot_Action_SetHealButton();
  local i = 0;
  local last = 0;

  -- first, add own group
  last = last+6
  if HealBot_Config.GroupHeals==1 then
    for _,unit in ipairs(HealBot_Action_HealGroup) do
      if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
        i = i+1;
        HealBot_Action_SetHealButton(i,unit);
      end
      if i==last then break end
    end
  end
  while i<last do
    i = i+1;
    HealBot_Action_SetHealButton(i,nil);
  end

  -- second, add CTRA main tanks
  last = last+10
  if HealBot_Config.TankHeals==1 then
    if GetNumRaidMembers()>0 and HealBot_Config.IntegrateCTRA==1 then
      for j=1,10 do
        if CT_RA_MainTanks[j] then
          for k=1,GetNumRaidMembers() do
            local unit = "raid"..k;
            if UnitName(unit)==CT_RA_MainTanks[j] then
              if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
                i = i+1;
                HealBot_Action_SetHealButton(i,unit);
              end
            end
          end
        end
      if i==last then break end
      end
    end
  end
  while i<last do
    i = i+1;
    HealBot_Action_SetHealButton(i,nil);
  end

  -- third, add extra targets
  last = last+5
  if HealBot_Config.TargetHeals==1 then
    for _,unit in ipairs(HealBot_Action_HealTarget) do
      if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
        i = i+1;
        HealBot_Action_SetHealButton(i,unit);
        local check = getglobal("HealBot_Action_HealUnit"..i.."Check");
        check.unit = unit;
        check:SetChecked(1);
        check:Show();
      end
      if i==last then break end
    end

  -- fourth, add mouse target
    last = last+1
    unit = HealBot_TargetName()
    if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal("target") then
      i = i+1;
      HealBot_Action_SetHealButton(i,"target");
      local check = getglobal("HealBot_Action_HealUnit"..i.."Check");
      check:SetChecked(0);
      check.unit = unit;
      if check.unit and i<last then
        check:Show();
      else
        check:Hide();
      end
    end
  end
  while i<last do
    i = i+1;
    HealBot_Action_SetHealButton(i,nil);
  end

  -- fifth, add emergency raid
  last = last+5
  if HealBot_Config.EmergencyHeals==1 then
    local order = {};
    local units = {};
    if GetNumRaidMembers()>0 then
      for j=1,40 do
        local unit = "raid"..j;
        if not HealBot_Action_UnitButtons[unit] and HealBot_MustHeal(unit) then
          if UnitHealth(unit)<UnitHealthMax(unit)*HealBot_Config.EmergencyLevel then
            if HealBot_Config.EmergencySort==1 then
              order[unit] = UnitHealth(unit);
            elseif HealBot_Config.EmergencySort==2 then
              order[unit] = UnitHealth(unit)/UnitHealthMax(unit);
            else
              order[unit] = HealBot_UnitTTL(unit);
            end
            table.insert(units,unit);
          end
        end
      end
    else
      for _,unit in ipairs(HealBot_Action_HealGroup) do
        if not HealBot_Action_UnitButtons[unit] and HealBot_MustHeal(unit) then
          if UnitHealth(unit)<UnitHealthMax(unit)*HealBot_Config.EmergencyLevel then
            order[unit] = UnitHealth(unit);
            table.insert(units,unit);
          end
        end
      end
    end
    table.sort(units,function (a,b)
--      return order[a]<order[b] or a<b;
      if not a or not order[a] or not b or not order[b] then
        DEFAULT_CHAT_FRAME:AddMessage("***** a="..(a or "nil").." -> "..(order[a] or "nil"))
        DEFAULT_CHAT_FRAME:AddMessage("***** b="..(b or "nil").." -> "..(order[b] or "nil"))
      end
      if order[a]<order[b] then return true end
      if order[a]>order[b] then return false end
      return a<b
    end)
    for j=1,40 do
      if not units[j] then break end
      i = i+1;
      HealBot_Action_SetHealButton(i,units[j]);
      if i==last then break end
    end
  end
  while i<last do
    i = i+1;
    HealBot_Action_SetHealButton(i,nil);
  end  

  local OffsetY = 10;
  table.foreach(HealBot_Action_HealButtons, function (index,button)
    OffsetY = HealBot_Action_PositionButton(button,OffsetY);
  end);
  if HealBot_Config.HideOptions==1 then
    HealBot_Action_OptionsButton:Hide();
  else
    HealBot_Action_OptionsButton:Show();
    OffsetY = OffsetY+25;
  end
  HealBot_Action_SetHeight(OffsetY+10);
  HealBot_Action_RefreshButtons();
  HealBot_Action_AddDebug("target is " .. (HealBot_TargetName() or UnitName("target") or "nothing"));
end

function HealBot_Action_Reset()
  HealBot_Action:ClearAllPoints();
  HealBot_Action:SetPoint("TOP","MinimapCluster","BOTTOM",7,10);
  HealBot_Action_HealTarget = {};
  HealBot_Action_PartyChanged();
end

local HealBot_Action_TooltipUnit = nil;
function HealBot_Action_RefreshTooltip(unit)
  if HealBot_Config.ShowTooltip==0 then return end
  if not unit then unit = HealBot_Action_TooltipUnit end
  if not unit then return end;
  GameTooltip:ClearLines();
  local spell = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern());
  GameTooltip:SetText(spell or "none available");
  if spell and HealBot_Spells[spell] then
    if HealBot_Spells[spell].HealsDur>0 then
      if HealBot_Spells[spell].Cast>0 then
        GameTooltip:AddLine("Casting time is "..HealBot_Spells[spell].Cast.." sec.");
        RealHealing = (HealBot_GetBonus('HEAL') * (HealBot_Spells[spell].Cast/3.5));
      else
      	RealHealing = (HealBot_GetBonus('HEAL') * (1.5/3.5));
      end
      if HealBot_Spells[spell].HealsMax>0 then
        local Heals = "Heals "
        if HealBot_Spells[spell].Shield then
          Heals = "Wards "
        end
        if HealBot_Spells[spell].HealsMin<HealBot_Spells[spell].HealsMax then
          GameTooltip:AddLine(Heals..format("%d", HealBot_Spells[spell].HealsMin + RealHealing ) .." to "..format("%d",HealBot_Spells[spell].HealsMax  + RealHealing)..".");
        else
          GameTooltip:AddLine(Heals..HealBot_Spells[spell].HealsMax  + RealHealing..".");
        end
      end
      if HealBot_Spells[spell].HealsExt>0 then
        GameTooltip:AddLine("Heals "..HealBot_Spells[spell].HealsExt.." over "..HealBot_Spells[spell].Duration-HealBot_Spells[spell].Cast.." sec.");
      end
      if tonumber(HealBot_GetBonus('HEAL'))>0 then
        GameTooltip:AddLine("Healing bonus is +"..HealBot_GetBonus('HEAL')..".");
      end
    end
  end
  if HealBot_Debug then
    GameTooltip:AddLine(" ");
    GameTooltip:AddLine(UnitName(unit));
    GameTooltip:AddDoubleLine("Incoming DPS",HealBot_UnitStatus[unit].DPS,1,1,1);
    GameTooltip:AddDoubleLine("Seconds to hit",HealBot_UnitStatus[unit].TTH,1,1,1);
--[[
    if HealBot_UnitStatus[unit].Damage[1] then
      GameTooltip:AddLine("");
      local now = GetTime();
      table.foreachi(HealBot_UnitStatus[unit].Damage, function (i,val) 
        GameTooltip:AddDoubleLine("Now-"..math.floor((now-val.Time)*10+0.5)/10,val.Amount,1,1,1);
      end)
    end
--]]
  end
  GameTooltip:Show();
end

function HealBot_Action_ShowTooltip(this)
  if HealBot_Config.ShowTooltip==0 then return end
  if not this.unit then return end;
  if not this:IsEnabled() then return end;
  GameTooltip_SetDefaultAnchor(GameTooltip,this);
  HealBot_Action_TooltipUnit = this.unit;
  HealBot_Action_RefreshTooltip(this.unit);
end

function HealBot_Action_HideTooltip(this)
  if HealBot_Config.ShowTooltip==0 then return end
  GameTooltip:Hide();
  HealBot_Action_TooltipUnit = nil;
end

function HealBot_Action_Refresh(unit)
  HealBot_Action_RefreshButtons(unit);
  HealBot_Set_Alpha(HealBot_Config.ActionAlpha);
  if HealBot_Config.AutoShow~=1 then return end 
  if (UnitIsDeadOrGhost("player")) then
    HideUIPanel(HealBot_Action);
  elseif (HealBot_Action_MustHealSome()) then
    ShowUIPanel(HealBot_Action);
  elseif (not HealBot_Action_ShouldHealSome()) then
    HideUIPanel(HealBot_Action);
  end
  HealBot_Action_RefreshTooltip(HealBot_Action_TooltipUnit);
end


function HealBot_Action_Screenshot()
  local OffsetY = 10;
  OffsetY = HealBot_PositionButton(HealBot_Action_HealButtons[1],OffsetY);
  OffsetY = HealBot_PositionButton(HealBot_Action_HealButtons[2],OffsetY);

  local button = HealBot_Action_HealButtons[3];
  button:SetText("Thott");
  button:Show();
  button:ClearAllPoints();
  button:SetPoint("TOP","HealBot_Action","TOP",0,-OffsetY);
  OffsetY = OffsetY+button:GetHeight()+6;

  button = HealBot_Action_HealButtons[4];
  button:SetText("Voohm");
  button:Show();
  button:ClearAllPoints();
  button:SetPoint("TOP","HealBot_Action","TOP",0,-OffsetY);
  OffsetY = OffsetY+button:GetHeight()+6;

  OffsetY = HealBot_PositionButton(HealBot_Action_HealButtons[5],OffsetY);
  OffsetY = HealBot_PositionButton(HealBot_Action_HealButtons[6],OffsetY);
  OffsetY = HealBot_PositionButton(HealBot_Action_HealButtons[7],OffsetY);
  HealBot_Action:SetHeight(OffsetY+35);

  HealBot_Action_RefreshButton(HealBot_Action_HealButtons[1]);
  local bar = HealBot_Action_HealthBar(HealBot_Action_HealButtons[1]);
  bar:SetMinMaxValues(0,100);
  bar:SetValue(70);
  bar:SetStatusBarColor(1.0,1.0,0.0,1.0);
  HealBot_Action_RefreshButton(HealBot_Action_HealButtons[2]);
  bar = HealBot_Action_HealthBar(HealBot_Action_HealButtons[3]);
  bar:SetMinMaxValues(0,100);
  bar:SetValue(30);
  bar:SetStatusBarColor(1.0,0.0,0.0,1.0);
  button = HealBot_Action_HealButtons[3];
  button:SetText(button:GetText().." (8)");
  bar = HealBot_Action_HealthBar(HealBot_Action_HealButtons[4]);
  bar:SetMinMaxValues(0,100);
  bar:SetValue(100);
  bar:SetStatusBarColor(0.0,1.0,0.0,1.0);
  HealBot_Action_RefreshButton(HealBot_Action_HealButtons[5]);
  HealBot_Action_RefreshButton(HealBot_Action_HealButtons[6]);
  HealBot_Action_RefreshButton(HealBot_Action_HealButtons[7]);

  HealBot_Action_HealButtons[1]:Enable();
  HealBot_Action_EnableButton(HealBot_Action_HealButtons[2])
  HealBot_Action_HealButtons[3]:Enable();
  HealBot_Action_EnableButton(HealBot_Action_HealButtons[4])
  HealBot_Action_EnableButton(HealBot_Action_HealButtons[5])
  HealBot_Action_EnableButton(HealBot_Action_HealButtons[6])
  HealBot_Action_EnableButton(HealBot_Action_HealButtons[7])
end

function HealBot_Action_SpellPattern()
  local combos = HealBot_Config.KeyCombo[UnitClass("player")]
  if not combos then return nil end
  local press = "Left"
  if IsControlKeyDown() then press = "Ctrl"..press end
  if IsShiftKeyDown() then press = "Shift"..press end
  return combos[press]
end

--------------------------------------------------------------------------------------------------
-- Widget_OnFoo functions
--------------------------------------------------------------------------------------------------

function HealBot_Action_HealUnit_OnLoad(this)
  HealBot_Action_AddDebug("OnLoad");
  this:RegisterForClicks("LeftButtonUp","RightButtonUp");
end

function HealBot_Action_HealUnit_OnEnter(this)
  HealBot_Action_ShowTooltip(this);
end

function HealBot_Action_HealUnit_OnLeave(this)
  HealBot_Action_HideTooltip(this);
end

function HealBot_Action_HealUnit_OnClick(this,button)
  if button=="RightButton" then
    if this.unit=="target" then
      local unit = HealBot_TargetName();
      if unit and table.getn(HealBot_Action_HealTarget)<5 then
        table.insert(HealBot_Action_HealTarget,unit)
      end
    else
      for i=1,table.getn(HealBot_Action_HealTarget) do
        if HealBot_Action_HealTarget[i]==this.unit then
          table.remove(HealBot_Action_HealTarget,i);
          break;
        end
      end
    end
    HealBot_Action_PartyChanged();
  else
    HealBot_HealUnit(this.unit,HealBot_Action_SpellPattern());
  end
end

function HealBot_Action_HealUnitCheck_OnClick(this)
  if not this.unit then return end
  if this:GetChecked() then
--    HealBot_Action_AddDebug("inserting unit "..this.unit);
    table.insert(HealBot_Action_HealTarget,this.unit)
  else
--    HealBot_Action_AddDebug("removing unit "..this.unit);
    for i=1,table.getn(HealBot_Action_HealTarget) do
      if HealBot_Action_HealTarget[i]==this.unit then
        table.remove(HealBot_Action_HealTarget,i);
        break;
      end
    end
  end
  HealBot_Action_PartyChanged();
end

function HealBot_Action_OptionsButton_OnClick(this)
  HealBot_TogglePanel(HealBot_Options);
end

function HealBot_Action_IntegrationActive(type)
  return HealBot_Config["Integrate"..type]==1 and (IsAltKeyDown() or 0)==1-(HealBot_Config.ToggleAltUse or 0);
end

--------------------------------------------------------------------------------------------------
-- CT_RaidAssist integration
--------------------------------------------------------------------------------------------------

local HealBot_CT_RA_CustomOnClickFunction_Old;
function HealBot_CT_RA_CustomOnClickFunction(button,unit)
  if HealBot_Action_IntegrationActive("CTRA") then
    HealBot_HealUnit(unit,HealBot_Action_SpellPattern())
    return true;
  end
  if (type(HealBot_CT_RA_CustomOnClickFunction_Old)=="function") then
    return HealBot_CT_RA_CustomOnClickFunction_Old(button,unit);
  end
  return false;
end

local HealBot_CT_RA_UpdateMTs_Old;
function HealBot_CT_RA_UpdateMTs()
  local value = HealBot_CT_RA_UpdateMTs_Old();
  if HealBot_Config.IntegrateCTRA==1 then
    HealBot_Action_PartyChanged();
  end
  return value;
end

function HealBot_CT_RaidAssist()
  if (type(CT_RA_MemberFrame_OnClick)=="function") then
    HealBot_CT_RA_CustomOnClickFunction_Old = CT_RA_CustomOnClickFunction;
    CT_RA_CustomOnClickFunction = HealBot_CT_RA_CustomOnClickFunction;
  end
  if (type(CT_RA_UpdateMTs)=="function") then
    HealBot_CT_RA_UpdateMTs_Old = CT_RA_UpdateMTs;
    CT_RA_UpdateMTs = HealBot_CT_RA_UpdateMTs;
  end
end

--------------------------------------------------------------------------------------------------
-- PartyMemberFrame integration
--------------------------------------------------------------------------------------------------

local HealBot_PlayerFrame_OnClick_Old = PlayerFrame_OnClick
function HealBot_PlayerFrame_OnClick(this)
  if HealBot_Action_IntegrationActive("PMF") then
    local unit = "player" 
    HealBot_HealUnit(unit,HealBot_Action_SpellPattern())
    return
  end
  HealBot_PlayerFrame_OnClick_Old(this)
end
PlayerFrame_OnClick = HealBot_PlayerFrame_OnClick

local HealBot_PetFrame_OnClick_Old = PetFrame_OnClick
function HealBot_PetFrame_OnClick(this)
  if HealBot_Action_IntegrationActive("PMF") then
    local unit = "pet" 
    HealBot_HealUnit(unit,HealBot_Action_SpellPattern())
    return
  end
  HealBot_PetFrame_OnClick_Old(this)
end
PetFrame_OnClick = HealBot_PetFrame_OnClick

local HealBot_PartyMemberFrame_OnClick_Old = PartyMemberFrame_OnClick
function HealBot_PartyMemberFrame_OnClick(this)
  if HealBot_Action_IntegrationActive("PMF") then
    local unit = "party"..this:GetID() 
    HealBot_HealUnit(unit,HealBot_Action_SpellPattern())
    return
  end
  HealBot_PartyMemberFrame_OnClick_Old(this)
end
PartyMemberFrame_OnClick = HealBot_PartyMemberFrame_OnClick

local HealBot_TargetFrame_OnClick_Old = TargetFrame_OnClick
function HealBot_TargetFrame_OnClick(this)
  if HealBot_Action_IntegrationActive("PMF") then
    local unit = "target" 
    HealBot_HealUnit(unit,HealBot_Action_SpellPattern())
    return
  end
  HealBot_TargetFrame_OnClick_Old(this)
end
TargetFrame_OnClick = HealBot_TargetFrame_OnClick

--------------------------------------------------------------------------------------------------
-- Frame_OnFoo functions
--------------------------------------------------------------------------------------------------

function HealBot_Action_OnLoad(this)
  HealBot_Action_AddDebug("OnLoad");
  HealBot_CT_RaidAssist();
--  this:RegisterForDrag("LeftButton", "RightButton");
--  this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	
end

function HealBot_Action_OnShow(this)
  HealBot_RecalcSpells();
  HealBot_Action_AddDebug("OnShow 1");
  if HealBot_Config.PanelSounds==1 then
    PlaySound("igAbilityOpen");
  end
  HealBot_Config.ActionVisible = 1
end

function HealBot_Action_OnHide(this)
  HealBot_Action_AddDebug("OnHide");
  HealBot_StopMoving(this);
  if HealBot_Config.PanelSounds==1 then
    PlaySound("igAbilityClose");
  end
  HealBot_Config.ActionVisible = 0
end

function HealBot_Action_OnMouseDown(this,button)
  HealBot_Action_AddDebug("OnMouseDown("..button..")");
  if button~="RightButton" then
    if HealBot_Config.ActionLocked==0 then
      HealBot_StartMoving(this);
    end
  end
end

function HealBot_Action_OnMouseUp(this,button)
  HealBot_Action_AddDebug("OnMouseUp("..button..")");
  if button~="RightButton" then
    HealBot_StopMoving(this);
  else
    HealBot_Action_OptionsButton_OnClick();
  end
end

function HealBot_Action_OnClick(this,button)
  HealBot_Action_AddDebug("OnClick("..button..")");
end

function HealBot_Action_OnDragStart(this,button)
  HealBot_Action_AddDebug("OnDragStart("..button..")");
  if HealBot_Config.ActionLocked==0 then
    HealBot_StartMoving(this);
  end
end

function HealBot_Action_OnDragStop(this)
  HealBot_Action_AddDebug("OnDragStop");
  HealBot_StopMoving(this);
end

-- http://www.flexbarforums.com/viewtopic.php?t=66
function HealBot_Action_OnKey(this,key,state)
  local command = GetBindingAction(key); 
  if command then 
    DEFAULT_CHAT_FRAME:AddMessage(key.." "..state.." "..(command or "nil"));
    keystate = state
    RunBinding(command,keystate)
  end 

  DEFAULT_CHAT_FRAME:AddMessage("HealBot_Action_OnKey - "..key);
  if key=="SHIFT" or key=="CTRL" or key=="ALT" then
    DEFAULT_CHAT_FRAME:AddMessage((IsShiftKeyDown() or 0).." "..(IsControlKeyDown() or 0).." "..(IsAltKeyDown() or 0));
    HealBot_Action_Refresh();
  end
end

--[[
      <OnKeyDown> 
        HealBot_Action_OnKey(this,arg1,"down");
      </OnKeyDown> 
      <OnKeyUp> 
        HealBot_Action_OnKey(this,arg1,"up");
      </OnKeyUp> 
--]]