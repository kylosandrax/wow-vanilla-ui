
function HealBot_Options_AddDebug(msg)
  HealBot_AddDebug("Options: " .. msg);
end

function HealBot_Options_Pct_OnLoad(this,text)
  this.text = text;
  getglobal(this:GetName().."Text"):SetText(text);
  getglobal(this:GetName().."Low"):SetText("0%");
  getglobal(this:GetName().."High"):SetText("100%");
  this:SetMinMaxValues(0.00,1.00);
  this:SetValueStep(0.01);
end

function HealBot_Options_Pct_OnValueChanged(this)
  local pct = math.floor(this:GetValue()*100+0.5);
  getglobal(this:GetName().."Text"):SetText(this.text .. " (" .. pct .. "%)");
  return this:GetValue();
end


function HealBot_Options_ActionAlpha_OnValueChanged(this)
  HealBot_Config.ActionAlpha = HealBot_Options_Pct_OnValueChanged(this);
  HealBot_Action:SetBackdropColor(
    TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
    TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
    TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, 
    HealBot_Config.ActionAlpha*0.8);
  HealBot_Action:SetBackdropBorderColor(
    TOOLTIP_DEFAULT_COLOR.r,
    TOOLTIP_DEFAULT_COLOR.g,
    TOOLTIP_DEFAULT_COLOR.b, 
    (HealBot_Config.ActionAlpha+1)/2);
end


function HealBot_Options_HealthPct_OnValueChanged(this)
  HealBot_Config.HealthPct = HealBot_Options_Pct_OnValueChanged(this);
  if HealBot_Config.AlertLevel>HealBot_Config.HealthPct then
    HealBot_Options_AlertLevel:SetValue(HealBot_Config.HealthPct);
  end
  HealBot_Action_Refresh();
end


function HealBot_Options_AlertLevel_OnValueChanged(this)
  HealBot_Config.AlertLevel = HealBot_Options_Pct_OnValueChanged(this);
  if HealBot_Config.HealthPct<HealBot_Config.AlertLevel then
    HealBot_Options_HealthPct:SetValue(HealBot_Config.AlertLevel);
  end
  if HealBot_Config.EmergencyLevel>HealBot_Config.AlertLevel then
    HealBot_Options_EmergencyLevel:SetValue(HealBot_Config.AlertLevel);
  end
  HealBot_Action_Refresh();
end


function HealBot_Options_EmergencyLevel_OnValueChanged(this)
  HealBot_Config.EmergencyLevel = HealBot_Options_Pct_OnValueChanged(this);
  if HealBot_Config.AlertLevel<HealBot_Config.EmergencyLevel then
    HealBot_Options_AlertLevel:SetValue(HealBot_Config.EmergencyLevel);
  end
  HealBot_Action_Refresh();
end


function HealBot_Options_AutoShow_OnLoad(this)
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_AUTOSHOW);
end

function HealBot_Options_AutoShow_OnClick(this)
  HealBot_Config.AutoShow = this:GetChecked() or 0;
--  if (HealBot_Config.AutoShow) then
--    HealBot_Options_AlertLevel:Enable();
--  else
--    HealBot_Options_AlertLevel:Disable();
--  end
  HealBot_Action_Refresh();
end


function HealBot_Options_PanelSounds_OnLoad(this)
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_PANELSOUNDS);
end

function HealBot_Options_PanelSounds_OnClick(this)
  HealBot_Config.PanelSounds = this:GetChecked() or 0;
end


function HealBot_Options_ActionLocked_OnLoad(this)
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_ACTIONLOCKED);
end

function HealBot_Options_ActionLocked_OnClick(this)
  HealBot_Config.ActionLocked = this:GetChecked() or 0;
end


function HealBot_Options_GroupHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(this.text);
end

function HealBot_Options_GroupHeals_OnClick(this)
  HealBot_Config.GroupHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end


function HealBot_Options_TankHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(this.text);
end

function HealBot_Options_TankHeals_OnClick(this)
  HealBot_Config.TankHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end


function HealBot_Options_TargetHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(this.text);
end

function HealBot_Options_TargetHeals_OnClick(this)
  HealBot_Config.TargetHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end


function HealBot_Options_EmergencyHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(this.text);
end

function HealBot_Options_EmergencyHeals_OnClick(this)
  HealBot_Config.EmergencyHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end


function HealBot_Options_HealingUsage_OnValueChanged(this)
  HealBot_Config.HealingUsage = HealBot_Options_Pct_OnValueChanged(this);
end


function HealBot_Options_ManaReserve_OnValueChanged(this)
  HealBot_Config.ManaReserve = HealBot_Options_Pct_OnValueChanged(this);
end


function HealBot_Options_AlertSeconds_OnLoad(this)
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_ALERTSECONDS);
  getglobal(this:GetName().."Low"):SetText("0 sec");
  getglobal(this:GetName().."High"):SetText("60 sec");
  this:SetMinMaxValues(0.0,60.0);
  this:SetValueStep(1.0);
end

function HealBot_Options_AlertSeconds_OnValueChanged(this)
  HealBot_Config.AlertSeconds = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_ALERTSECONDS .. " (" .. HealBot_Config.AlertSeconds .. " sec)");
  HealBot_Action_RefreshButtons();
end


function HealBot_Options_UseHealing_OnLoad(this,text)
  this.text = text;
  getglobal(this:GetName().."Text"):SetText(this.text);
end

function HealBot_Options_UseHealing_OnClick(this)
  HealBot_Config.UseHealing[this.text] = this:GetChecked() or 0;
  HealBot_AddDebug("UseHealing[" .. this.text .. "] = " .. HealBot_Config.UseHealing[this.text]);
  HealBot_RecalcSpells();
end


function HealBot_Options_CastNotify_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_CastNotify_OnClick(this,id)
  if HealBot_Config.CastNotify>0 then
    getglobal("HealBot_Options_CastNotify"..HealBot_Config.CastNotify):SetChecked(nil);
  end
  HealBot_Config.CastNotify = id;
  if HealBot_Config.CastNotify>0 then
    getglobal("HealBot_Options_CastNotify"..HealBot_Config.CastNotify):SetChecked(1);
  end
end


function HealBot_Options_HideOptions_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_HideOptions_OnClick(this)
  HealBot_Config.HideOptions = this:GetChecked() or 0;
  HealBot_Action_PartyChanged();
end


function HealBot_Options_ShowTooltip_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_ShowTooltip_OnClick(this)
  HealBot_Config.ShowTooltip = this:GetChecked() or 0;
--  HealBot_Action_PartyChanged();
end


function HealBot_Options_GrowUpwards_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_GrowUpwards_OnClick(this)
  HealBot_Config.GrowUpwards = this:GetChecked() or 0;
--  HealBot_Action_PartyChanged();
end


function HealBot_Options_IntegratePMF_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_IntegratePMF_OnClick(this)
  HealBot_Config.IntegratePMF = this:GetChecked() or 0;
--  HealBot_Action_PartyChanged();
end


function HealBot_Options_IntegrateCTRA_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_IntegrateCTRA_OnClick(this)
  HealBot_Config.IntegrateCTRA = this:GetChecked() or 0;
--  HealBot_Action_PartyChanged();
end


function HealBot_Options_ToggleAltUse_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_ToggleAltUse_OnClick(this)
  HealBot_Config.ToggleAltUse = this:GetChecked() or 0;
--  HealBot_Action_PartyChanged();
end


function HealBot_Options_ProtectPvP_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_ProtectPvP_OnClick(this)
  HealBot_Config.ProtectPvP = this:GetChecked() or 0;
  HealBot_Action_Refresh();
end

--------------------------------------------------------------------------------

local HealBot_Options_EmergencySort_List = {
  HEALBOT_OPTIONS_SORTHEALTH,
  HEALBOT_OPTIONS_SORTPERCENT,
  HEALBOT_OPTIONS_SORTSURVIVAL,
}

function HealBot_Options_EmergencySort_DropDown()
  for i=1, getn(HealBot_Options_EmergencySort_List), 1 do
    local info = {};
    info.text = HealBot_Options_EmergencySort_List[i];
    info.func = HealBot_Options_EmergencySort_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end

function HealBot_Options_EmergencySort_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_EmergencySort,HealBot_Options_EmergencySort_DropDown)
end

function HealBot_Options_EmergencySort_Refresh(onselect)
  if not HealBot_Config.EmergencySort then return end
  if not onselect then HealBot_Options_EmergencySort_Initialize() end  -- or wrong menu may be used !
  UIDropDownMenu_SetSelectedID(HealBot_Options_EmergencySort,HealBot_Config.EmergencySort)
end

function HealBot_Options_EmergencySort_OnLoad(this)
  HealBot_Options_EmergencySort_Initialize()
  UIDropDownMenu_SetWidth(100)
end

function HealBot_Options_EmergencySort_OnSelect()
  HealBot_Config.EmergencySort = this:GetID()
  HealBot_Options_EmergencySort_Refresh(true)
  HealBot_Action_PartyChanged()
end

--------------------------------------------------------------------------------

local HealBot_Options_ComboClass_List = {
  HEALBOT_DRUID,
  HEALBOT_HUNTER,
  HEALBOT_MAGE,
  HEALBOT_PALADIN,
  HEALBOT_ROGUE,
  HEALBOT_PRIEST,
  HEALBOT_SHAMAN,
  HEALBOT_WARLOCK,
  HEALBOT_WARRIOR,
}

function HealBot_Options_ComboClass_DropDown()
  for i=1, getn(HealBot_Options_ComboClass_List), 1 do
    local info = {};
    info.text = HealBot_Options_ComboClass_List[i];
    info.func = HealBot_Options_ComboClass_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end

function HealBot_Options_ComboClass_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_ComboClass,HealBot_Options_ComboClass_DropDown)
  HealBot_Options_ComboClass.class = 1
  local class = UnitClass("player")
  for i=1, getn(HealBot_Options_ComboClass_List), 1 do
    if class==HealBot_Options_ComboClass_List[i] then
      HealBot_Options_ComboClass.class = i
      break
    end
  end
end

function HealBot_Options_ComboClass_Refresh(onselect)
  if not HealBot_Options_ComboClass.class then return end
  if not onselect then HealBot_Options_ComboClass_Initialize() end  -- or wrong menu may be used !
  UIDropDownMenu_SetSelectedID(HealBot_Options_ComboClass,HealBot_Options_ComboClass.class)
  local combo = HealBot_Config.KeyCombo[HealBot_Options_ComboClassText:GetText()]
  if combo then
    HealBot_Options_ShiftLeft:SetText(combo["ShiftLeft"] or "")
    HealBot_Options_CtrlLeft:SetText(combo["CtrlLeft"] or "")
    HealBot_Options_ShiftCtrlLeft:SetText(combo["ShiftCtrlLeft"] or "")
  end
end

function HealBot_Options_ComboClass_OnLoad(this)
  HealBot_Options_ComboClass_Initialize()
  UIDropDownMenu_SetWidth(80)
end

function HealBot_Options_ComboClass_OnSelect()
  HealBot_Options_ComboClass.class = this:GetID()
  HealBot_Options_ComboClass_Refresh(true)
--  HealBot_Action_PartyChanged()
end

--------------------------------------------------------------------------------

function HealBot_Options_EditBox_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_ShiftLeft_OnTextChanged(this)
  local combo = HealBot_Config.KeyCombo[HealBot_Options_ComboClassText:GetText()]
  combo["ShiftLeft"] = this:GetText()
end

function HealBot_Options_CtrlLeft_OnTextChanged(this)
  local combo = HealBot_Config.KeyCombo[HealBot_Options_ComboClassText:GetText()]
  combo["CtrlLeft"] = this:GetText()
end

function HealBot_Options_ShiftCtrlLeft_OnTextChanged(this)
  local combo = HealBot_Config.KeyCombo[HealBot_Options_ComboClassText:GetText()]
  combo["ShiftCtrlLeft"] = this:GetText()
end


function HealBot_Options_EnableHealthy_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_EnableHealthy_OnClick(this)
  HealBot_Config.EnableHealthy = this:GetChecked() or 0;
  HealBot_Options_AddDebug("HealBot_Config.EnableHealthy = "..HealBot_Config.EnableHealthy)
  HealBot_Action_EnableButtons();
end

--------------------------------------------------------------------------------

function HealBot_Options_Defaults_OnClick(this)
  HealBot_Options_CastNotify_OnClick(nil,0);
--  HealBot_Config = HealBot_ConfigDefaults;
  table.foreach(HealBot_ConfigDefaults, function (key,val)
    HealBot_Config[key] = val;
  end);
  HealBot_Options_OnShow(HealBot_Options);
  HealBot_RecalcSpells();
  HealBot_Action_Reset();
  HealBot_Config.ActionVisible = HealBot_Action:IsVisible();
end

function HealBot_Options_OnLoad(this)
  table.insert(UISpecialFrames,this:GetName());

  -- Tabs
  PanelTemplates_SetNumTabs(this,5);
  this.selectedTab = 1;  --gGroupCalendar_CurrentPanel;
  PanelTemplates_UpdateTabs(this);
  HealBot_Options_ShowPanel(this.selectedTab);
end

function HealBot_Options_OnShow(this)
  HealBot_Options_ActionAlpha:SetValue(HealBot_Config.ActionAlpha);
  HealBot_Options_ActionLocked:SetChecked(HealBot_Config.ActionLocked);
  HealBot_Options_HealthPct:SetValue(HealBot_Config.HealthPct);
  HealBot_Options_AlertLevel:SetValue(HealBot_Config.AlertLevel);
  HealBot_Options_EmergencyLevel:SetValue(HealBot_Config.EmergencyLevel);
  HealBot_Options_AutoShow:SetChecked(HealBot_Config.AutoShow);
  HealBot_Options_PanelSounds:SetChecked(HealBot_Config.PanelSounds);
  HealBot_Options_AlertSeconds:SetValue(HealBot_Config.AlertSeconds);
  HealBot_Options_GroupHeals:SetChecked(HealBot_Config.GroupHeals);
  HealBot_Options_TankHeals:SetChecked(HealBot_Config.TankHeals);
  HealBot_Options_TargetHeals:SetChecked(HealBot_Config.TargetHeals);
  HealBot_Options_EmergencyHeals:SetChecked(HealBot_Config.EmergencyHeals);
  HealBot_Options_HealingUsage:SetValue(HealBot_Config.HealingUsage);
  HealBot_Options_ManaReserve:SetValue(HealBot_Config.ManaReserve);
  for i=1,17 do
    local ctl = getglobal("HealBot_Options_UseHealing"..i);
    ctl:SetChecked(HealBot_Config.UseHealing[ctl.text]);
  end
  HealBot_Options_CastNotify_OnClick(nil,HealBot_Config.CastNotify);
  HealBot_Options_HideOptions:SetChecked(HealBot_Config.HideOptions);
  HealBot_Options_ShowTooltip:SetChecked(HealBot_Config.ShowTooltip);
  HealBot_Options_GrowUpwards:SetChecked(HealBot_Config.GrowUpwards);
  HealBot_Options_IntegratePMF:SetChecked(HealBot_Config.IntegratePMF);
  HealBot_Options_IntegrateCTRA:SetChecked(HealBot_Config.IntegrateCTRA);
  HealBot_Options_ToggleAltUse:SetChecked(HealBot_Config.ToggleAltUse);
  HealBot_Options_ProtectPvP:SetChecked(HealBot_Config.ProtectPvP);
  HealBot_Options_EmergencySort_Refresh()
  HealBot_Options_ComboClass_Refresh()
  HealBot_Options_EnableHealthy:SetChecked(HealBot_Config.EnableHealthy);
end

HealBot_Options_CurrentPanel = 0;

function HealBot_Options_ShowPanel(id)
  if HealBot_Options_CurrentPanel>0 then
    getglobal("HealBot_Options_Panel"..HealBot_Options_CurrentPanel):Hide();
  end
  HealBot_Options_CurrentPanel = id;
  if HealBot_Options_CurrentPanel>0 then
    getglobal("HealBot_Options_Panel"..HealBot_Options_CurrentPanel):Show();
  end
end
