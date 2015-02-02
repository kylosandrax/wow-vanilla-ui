HealBot_ConfigDefaults = {
  Version = HEALBOT_VERSION,
  HealthPct = 0.9,
  AlertLevel = 0.9,
  AutoShow = 1,
  PanelSounds = 1,
  TargetWhisper = 1,
  GroupHeals = 1,
  TankHeals = 1,
  TargetHeals = 1,
  EmergencyHeals = 1,
  ActionAlpha = 1.0,
  AlertSeconds = 15,
  ActionLocked = 0,
  ConserveMana = 0,
  HealingUsage = 0.5,
  ManaReserve  = 0.5,
  UseHealing = {
    [HEALBOT_FLASH_HEAL]          = 1,
    [HEALBOT_FLASH_OF_LIGHT]      = 1,
    [HEALBOT_GREATER_HEAL]        = 1,
    [HEALBOT_HEALING_TOUCH]       = 1,
    [HEALBOT_HEAL]                = 1,
    [HEALBOT_HEALING_WAVE]        = 1,
    [HEALBOT_HOLY_LIGHT]          = 1,
    [HEALBOT_LESSER_HEAL]         = 1,
    [HEALBOT_LESSER_HEALING_WAVE] = 1,
    [HEALBOT_MEND_PET]            = 1,
    [HEALBOT_POWER_WORD_SHIELD]   = 0,
    [HEALBOT_REGROWTH]            = 1,
    [HEALBOT_RENEW]               = 1,
    [HEALBOT_REJUVENATION]        = 1,
    [HEALBOT_BANDAGES]            = 1,
    [HEALBOT_HEALING_POTIONS]     = 1,
    [HEALBOT_HEALTHSTONES]        = 1,
  },
  CastNotify = 3,
  HideOptions = 0,
  ShowTooltip = 1,
  GrowUpwards = 0,
  IntegrateCTRA = 0,
  ProtectPvP = 1,
  EmergencyLevel = 0.5,
  IntegratePMF = 1,
  EmergencySort = 1,
  ToggleAltUse = 0,
  KeyCombo = {
    [HEALBOT_DRUID] = {
      ["ShiftLeft"] = HEALBOT_REJUVENATION,
      ["CtrlLeft"] = HEALBOT_REGROWTH,
    },
    [HEALBOT_HUNTER] = {
    },
    [HEALBOT_MAGE] = {
    },
    [HEALBOT_PALADIN] = {
      ["ShiftLeft"] = HEALBOT_FLASH_OF_LIGHT,
      ["CtrlLeft"] = HEALBOT_HOLY_LIGHT,
    },
    [HEALBOT_PRIEST] = {
      ["ShiftLeft"] = HEALBOT_FLASH_HEAL,
      ["CtrlLeft"] = HEALBOT_POWER_WORD_SHIELD,
    },
    [HEALBOT_ROGUE] = {
    },
    [HEALBOT_SHAMAN] = {
      ["ShiftLeft"] = HEALBOT_LESSER_HEALING_WAVE,
    },
    [HEALBOT_WARLOCK] = {
    },
    [HEALBOT_WARRIOR] = {
    },
  },
  EnableHealthy = 0,
  ActionVisible = 0,
};

HealBot_Config = {};


HealBot_Groups = {
  ["ITEMS"] = {
    HEALBOT_BANDAGES,
    HEALBOT_HEALING_POTIONS,
    HEALBOT_HEALTHSTONES,
  },
  ["PALADIN"] = {
    HEALBOT_HOLY_LIGHT,
    HEALBOT_FLASH_OF_LIGHT,
  },
}

HealBot_Spells = {
-- Cast     = secs until effect starts
-- Channel  = secs until caster available
-- Duration = secs until effect ends
-- Shield   = maximum duration

  [HEALBOT_LINEN_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 6.0, 
    Mana =  0, HealsExt =   66, Price =   10, Level =  1,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_HEAVY_LINEN_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 6.0, 
    Mana =  0, HealsExt =  114, Price =   20, Level =  1,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_WOOL_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 7.0, 
    Mana =  0, HealsExt =  161, Price =   28, Level =  1,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_HEAVY_WOOL_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 7.0, 
    Mana =  0, HealsExt =  301, Price =   57, Level =  1,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_SILK_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 8.0, 
    Mana =  0, HealsExt =  400, Price =  200, Level =  1,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_HEAVY_SILK_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 8.0, 
    Mana =  0, HealsExt =  640, Price =  400, Level =  1,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_MAGEWEAVE_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 8.0, 
    Mana =  0, HealsExt =  800, Price =  400, Level =  1,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_HEAVY_MAGEWEAVE_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 8.0, 
    Mana =  0, HealsExt = 1104, Price =  600, Level =  1,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_RUNECLOTH_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 8.0, 
    Mana =  0, HealsExt = 1360, Price =  500, Level = 52,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },
  [HEALBOT_HEAVY_RUNECLOTH_BANDAGE] = {
    Group = HEALBOT_BANDAGES, Range = 15, Channel = 8.0, 
    Mana =  0, HealsExt = 2000, Price = 1000, Level = 58,
    Buff = HEALBOT_BUFF_FIRST_AID, Debuff = HEALBOT_DEBUFF_RECENTLY_BANDAGED },

  [HEALBOT_MINOR_HEALING_POTION] = {
    Group = HEALBOT_HEALING_POTIONS, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =   70, HealsMax =   90, Price =    5, Level =  5 },
  [HEALBOT_LESSER_HEALING_POTION] = {
    Group = HEALBOT_HEALING_POTIONS, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =  140, HealsMax =  180, Price =   25, Level = 13 },
  [HEALBOT_HEALING_POTION] = {
    Group = HEALBOT_HEALING_POTIONS, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =  280, HealsMax =  360, Price =   75, Level = 22 },
  [HEALBOT_GREATER_HEALING_POTION] = {
    Group = HEALBOT_HEALING_POTIONS, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =  455, HealsMax =  585, Price =  125, Level = 31 },
  [HEALBOT_SUPERIOR_HEALING_POTION] = {
    Group = HEALBOT_HEALING_POTIONS, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =  700, HealsMax =  900, Price =  250, Level = 45 },
  [HEALBOT_MAJOR_HEALING_POTION] = {
    Group = HEALBOT_HEALING_POTIONS, Range = 15, Target = {"player"},
    Mana =  0, HealsMin = 1050, HealsMax = 1750, Price = 1000, Level = 55 },

  [HEALBOT_MINOR_HEALTHSTONE] = {
    Group = HEALBOT_HEALTHSTONES, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =  110, HealsMax =  110, Price = 0, Level = 10 },
  [HEALBOT_LESSER_HEALTHSTONE] = {
    Group = HEALBOT_HEALTHSTONES, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =  275, HealsMax =  275, Price = 0, Level = 22 },
  [HEALBOT_HEALTHSTONE] = {
    Group = HEALBOT_HEALTHSTONES, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =  500, HealsMax =  500, Price = 0, Level = 34 },
  [HEALBOT_GREATER_HEALTHSTONE] = {
    Group = HEALBOT_HEALTHSTONES, Range = 1, Target = {"player"},
    Mana =  0, HealsMin =  880, HealsMax =  880, Price = 0, Level = 46 },
  [HEALBOT_MAJOR_HEALTHSTONE] = {
    Group = HEALBOT_HEALTHSTONES, Range = 1, Target = {"player"},
    Mana =  0, HealsMin = 1440, HealsMax = 1440, Price = 0, Level = 58 },
 
-- PALADIN

  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_1] = {
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana =  35, HealsMin =   42, HealsMax =   51, Level =  1 },
  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_2] = { 
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana =  60, HealsMin =   79, HealsMax =   94, Level =  6 },
  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_3] = { 
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana = 110, HealsMin =  159, HealsMax =  187, Level = 14 },
  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_4] = { 
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana = 190, HealsMin =  310, HealsMax =  356, Level = 22 },
  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_5] = { 
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana = 275, HealsMin =  491, HealsMax =  553, Level = 30 },
  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_6] = { 
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana = 365, HealsMin =  698, HealsMax =  780, Level = 38 },
  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_7] = { 
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana = 465, HealsMin =  945, HealsMax = 1053, Level = 46 },
  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_8] = { 
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana = 580, HealsMin = 1246, HealsMax = 1388, Level = 54 },
  [HEALBOT_HOLY_LIGHT .. HEALBOT_RANK_9] = { 
    Group = HEALBOT_HOLY_LIGHT, Range = 40, Cast = 2.5, 
    Mana = 660, HealsMin = 1590, HealsMax = 1770, Level = 60 },

  [HEALBOT_FLASH_OF_LIGHT .. HEALBOT_RANK_1] = {
    Group = HEALBOT_FLASH_OF_LIGHT, Range = 40, Cast = 1.5, 
    Mana =  35, HealsMin =   62, HealsMax =   72, Level = 20 },
  [HEALBOT_FLASH_OF_LIGHT .. HEALBOT_RANK_2] = {
    Group = HEALBOT_FLASH_OF_LIGHT, Range = 40, Cast = 1.5, 
    Mana =  50, HealsMin =   96, HealsMax =  110, Level = 26 },
  [HEALBOT_FLASH_OF_LIGHT .. HEALBOT_RANK_3] = {
    Group = HEALBOT_FLASH_OF_LIGHT, Range = 40, Cast = 1.5, 
    Mana =  70, HealsMin =  145, HealsMax =  163, Level = 34 },
  [HEALBOT_FLASH_OF_LIGHT .. HEALBOT_RANK_4] = {
    Group = HEALBOT_FLASH_OF_LIGHT, Range = 40, Cast = 1.5, 
    Mana =  90, HealsMin =  197, HealsMax =  221, Level = 42 },
  [HEALBOT_FLASH_OF_LIGHT .. HEALBOT_RANK_5] = {
    Group = HEALBOT_FLASH_OF_LIGHT, Range = 40, Cast = 1.5, 
    Mana = 115, HealsMin =  267, HealsMax =  299, Level = 50 },
  [HEALBOT_FLASH_OF_LIGHT .. HEALBOT_RANK_6] = {
    Group = HEALBOT_FLASH_OF_LIGHT, Range = 40, Cast = 1.5, 
    Mana = 140, HealsMin =  343, HealsMax =  383, Level = 58 },

-- DRUID

  [HEALBOT_REJUVENATION .. HEALBOT_RANK_1 ] = { 
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana =  25, HealsMin = 0, HealsMax = 0, HealsExt =  32, Level =  4,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_2 ] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana =  40, HealsMin = 0, HealsMax = 0, HealsExt =  56, Level = 10,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_3 ] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana =  75, HealsMin = 0, HealsMax = 0, HealsExt = 116, Level = 16,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_4 ] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana = 105, HealsMin = 0, HealsMax = 0, HealsExt = 180, Level = 22,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_5 ] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana = 135, HealsMin = 0, HealsMax = 0, HealsExt = 244, Level = 28,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_6 ] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana = 160, HealsMin = 0, HealsMax = 0, HealsExt = 304, Level = 34,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_7 ] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana = 195, HealsMin = 0, HealsMax = 0, HealsExt = 388, Level = 40,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_8 ] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana = 235, HealsMin = 0, HealsMax = 0, HealsExt = 488, Level = 46,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_9 ] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana = 280, HealsMin = 0, HealsMax = 0, HealsExt = 608, Level = 52,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_10] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana = 335, HealsMin = 0, HealsMax = 0, HealsExt = 756, Level = 58,
    Buff = HEALBOT_BUFF_REJUVENATION },
  [HEALBOT_REJUVENATION .. HEALBOT_RANK_11] = {
    Group = HEALBOT_REJUVENATION, Range = 40, Duration = 12, 
    Mana = 360, HealsMin = 0, HealsMax = 0, HealsExt = 888, Level = 60,
    Buff = HEALBOT_BUFF_REJUVENATION },

  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_1 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 1.5, 
    Mana =  30, HealsMin =   37, HealsMax =   51, Level  = 1 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_2 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 2.0, 
    Mana =  60, HealsMin =   88, HealsMax =  112, Level =  8 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_3 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 2.5, 
    Mana = 120, HealsMin =  195, HealsMax =  243, Level = 14 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_4 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 3.0, 
    Mana = 205, HealsMin =  363, HealsMax =  445, Level = 20 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_5 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 3.5, 
    Mana = 300, HealsMin =  572, HealsMax =  694, Level = 26 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_6 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 3.5, 
    Mana = 370, HealsMin =  742, HealsMax =  894, Level = 32 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_7 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 3.5, 
    Mana = 445, HealsMin =  935, HealsMax = 1120, Level = 38 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_8 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 3.5, 
    Mana = 545, HealsMin = 1199, HealsMax = 1427, Level = 44 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_9 ] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 3.5, 
    Mana = 660, HealsMin = 1516, HealsMax = 1796, Level = 50 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_10] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 3.5, 
    Mana = 790, HealsMin = 1890, HealsMax = 2230, Level = 56 },
  [HEALBOT_HEALING_TOUCH .. HEALBOT_RANK_11] = {
    Group = HEALBOT_HEALING_TOUCH, Range = 40, Cast = 3.5, 
    Mana = 880, HealsMin = 2267, HealsMax = 2677, Level = 60 },

  [HEALBOT_REGROWTH .. HEALBOT_RANK_1] = {
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 120, HealsMin =   84, HealsMax =   98, HealsExt =   98, Level = 12,
    Buff = HEALBOT_BUFF_REGROWTH },
  [HEALBOT_REGROWTH .. HEALBOT_RANK_2] = {
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 205, HealsMin =  164, HealsMax =  188, HealsExt =  175, Level = 18,
    Buff = HEALBOT_BUFF_REGROWTH },
  [HEALBOT_REGROWTH .. HEALBOT_RANK_3] = {
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 280, HealsMin =  240, HealsMax =  274, HealsExt =  259, Level = 24,
    Buff = HEALBOT_BUFF_REGROWTH },
  [HEALBOT_REGROWTH .. HEALBOT_RANK_4] = { 
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 350, HealsMin =  318, HealsMax =  360, HealsExt =  343, Level = 30,
    Buff = HEALBOT_BUFF_REGROWTH },
  [HEALBOT_REGROWTH .. HEALBOT_RANK_5] = {
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 420, HealsMin =  405, HealsMax =  457, HealsExt =  427, Level = 36,
    Buff = HEALBOT_BUFF_REGROWTH },
  [HEALBOT_REGROWTH .. HEALBOT_RANK_6] = {
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 510, HealsMin =  511, HealsMax =  576, HealsExt =  546, Level = 42,
    Buff = HEALBOT_BUFF_REGROWTH },
  [HEALBOT_REGROWTH .. HEALBOT_RANK_7] = {
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 615, HealsMin =  646, HealsMax =  724, HealsExt =  686, Level = 48,
    Buff = HEALBOT_BUFF_REGROWTH },
  [HEALBOT_REGROWTH .. HEALBOT_RANK_8] = {
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 740, HealsMin =  809, HealsMax =  905, HealsExt =  861, Level = 54,
    Buff = HEALBOT_BUFF_REGROWTH },
  [HEALBOT_REGROWTH .. HEALBOT_RANK_9] = {
    Group = HEALBOT_REGROWTH, Range = 40, Cast = 2, Duration = 2+21, 
    Mana = 880, HealsMin = 1003, HealsMax = 1119, HealsExt = 1064, Level = 60,
    Buff = HEALBOT_BUFF_REGROWTH },

-- HUNTER

  [HEALBOT_MEND_PET .. HEALBOT_RANK_1] = {
    Group = HEALBOT_MEND_PET, Range = 20, Channel = 5, Target = {"pet"}, 
    Mana =  50, HealsMin = 0, HealsMax = 0, HealsExt =  20*5, Level = 12 },
  [HEALBOT_MEND_PET .. HEALBOT_RANK_2] = {
    Group = HEALBOT_MEND_PET, Range = 20, Channel = 5, Target = {"pet"},
    Mana =  90, HealsMin = 0, HealsMax = 0, HealsExt =  38*5, Level = 20 },
  [HEALBOT_MEND_PET .. HEALBOT_RANK_3] = {
    Group = HEALBOT_MEND_PET, Range = 20, Channel = 5, Target = {"pet"},
    Mana = 155, HealsMin = 0, HealsMax = 0, HealsExt =  68*5, Level = 28 },
  [HEALBOT_MEND_PET .. HEALBOT_RANK_4] = {
    Group = HEALBOT_MEND_PET, Range = 20, Channel = 5, Target = {"pet"},
    Mana = 225, HealsMin = 0, HealsMax = 0, HealsExt = 103*5, Level = 36 },
  [HEALBOT_MEND_PET .. HEALBOT_RANK_5] = {
    Group = HEALBOT_MEND_PET, Range = 20, Channel = 5, Target = {"pet"},
    Mana = 300, HealsMin = 0, HealsMax = 0, HealsExt = 142*5, Level = 44 },
  [HEALBOT_MEND_PET .. HEALBOT_RANK_6] = {
    Group = HEALBOT_MEND_PET, Range = 20, Channel = 5, Target = {"pet"},
    Mana = 385, HealsMin = 0, HealsMax = 0, HealsExt = 189*5, Level = 52 },
  [HEALBOT_MEND_PET .. HEALBOT_RANK_7] = {
    Group = HEALBOT_MEND_PET, Range = 20, Channel = 5, Target = {"pet"},
    Mana = 480, HealsMin = 0, HealsMax = 0, HealsExt = 245*5, Level = 60 },

-- PRIEST

  [HEALBOT_LESSER_HEAL .. HEALBOT_RANK_1] = {
    Group = HEALBOT_LESSER_HEAL, Range = 40, Cast = 2.0, 
    Mana =  35, HealsMin =   46, HealsMax =   57, Level =  1 }, 
  [HEALBOT_LESSER_HEAL .. HEALBOT_RANK_2] = {
    Group = HEALBOT_LESSER_HEAL, Range = 40, Cast = 2.0, 
    Mana =  50, HealsMin =   71, HealsMax =   85, Level =  4 }, 
  [HEALBOT_LESSER_HEAL .. HEALBOT_RANK_3] = {
    Group = HEALBOT_LESSER_HEAL, Range = 40, Cast = 2.5, 
    Mana =  85, HealsMin =  135, HealsMax =  157, Level = 10 }, 

  [HEALBOT_HEAL .. HEALBOT_RANK_1] = {
    Group = HEALBOT_HEAL, Range = 40, Cast = 3.0, 
    Mana = 170, HealsMin =  295, HealsMax =  341, Level = 16 }, 
  [HEALBOT_HEAL .. HEALBOT_RANK_2] = {
    Group = HEALBOT_HEAL, Range = 40, Cast = 3.5, 
    Mana = 265, HealsMin =  499, HealsMax =  571, Level = 22 }, 
  [HEALBOT_HEAL .. HEALBOT_RANK_3] = {
    Group = HEALBOT_HEAL, Range = 40, Cast = 4.0, 
    Mana = 375, HealsMin =  754, HealsMax =  856, Level = 28 }, 
  [HEALBOT_HEAL .. HEALBOT_RANK_4] = {
    Group = HEALBOT_HEAL, Range = 40, Cast = 4.0, 
    Mana = 450, HealsMin =  948, HealsMax = 1072, Level = 34 }, 

  [HEALBOT_GREATER_HEAL .. HEALBOT_RANK_1] = {
    Group = HEALBOT_GREATER_HEAL, Range = 40, Cast = 4.0, 
    Mana =  545, HealsMin = 1201, HealsMax = 1353, Level = 40 }, 
  [HEALBOT_GREATER_HEAL .. HEALBOT_RANK_2] = {
    Group = HEALBOT_GREATER_HEAL, Range = 40, Cast = 4.0, 
    Mana =  665, HealsMin = 1531, HealsMax = 1717, Level = 46 }, 
  [HEALBOT_GREATER_HEAL .. HEALBOT_RANK_3] = {
    Group = HEALBOT_GREATER_HEAL, Range = 40, Cast = 4.0, 
    Mana =  800, HealsMin = 1919, HealsMax = 2147, Level = 52 }, 
  [HEALBOT_GREATER_HEAL .. HEALBOT_RANK_4] = {
    Group = HEALBOT_GREATER_HEAL, Range = 40, Cast = 4.0, 
    Mana =  960, HealsMin = 2396, HealsMax = 2674, Level = 58 }, 
  [HEALBOT_GREATER_HEAL .. HEALBOT_RANK_5] = {
    Group = HEALBOT_GREATER_HEAL, Range = 40, Cast = 4.0, 
    Mana = 1040, HealsMin = 2618, HealsMax = 2922, Level = 60 }, 

  [HEALBOT_RENEW .. HEALBOT_RANK_1] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana =  30, HealsMin = 0, HealsMax = 0, HealsExt =  45, Level =  8,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_2] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana =  65, HealsMin = 0, HealsMax = 0, HealsExt = 100, Level = 14,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_3] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana = 105, HealsMin = 0, HealsMax = 0, HealsExt = 175, Level = 20,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_4] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana = 140, HealsMin = 0, HealsMax = 0, HealsExt = 245, Level = 26,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_5] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana = 170, HealsMin = 0, HealsMax = 0, HealsExt = 315, Level = 32,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_6] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana = 205, HealsMin = 0, HealsMax = 0, HealsExt = 400, Level = 38,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_7] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana = 250, HealsMin = 0, HealsMax = 0, HealsExt = 510, Level = 44,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_8] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana = 305, HealsMin = 0, HealsMax = 0, HealsExt = 650, Level = 50,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_9] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana = 365, HealsMin = 0, HealsMax = 0, HealsExt = 810, Level = 56,
    Buff = HEALBOT_BUFF_RENEW }, 
  [HEALBOT_RENEW .. HEALBOT_RANK_10] = {
    Group = HEALBOT_RENEW, Range = 40, Duration = 15, 
    Mana = 410, HealsMin = 0, HealsMax = 0, HealsExt = 970, Level = 60,
    Buff = HEALBOT_BUFF_RENEW }, 

  [HEALBOT_FLASH_HEAL .. HEALBOT_RANK_1] = {
    Group = HEALBOT_FLASH_HEAL, Range = 40, Cast = 1.5, 
    Mana = 125, HealsMin = 193, HealsMax = 237, Level = 20 }, 
  [HEALBOT_FLASH_HEAL .. HEALBOT_RANK_2] = {
    Group = HEALBOT_FLASH_HEAL, Range = 40, Cast = 1.5, 
    Mana = 155, HealsMin = 258, HealsMax = 314, Level = 26 }, 
  [HEALBOT_FLASH_HEAL .. HEALBOT_RANK_3] = {
    Group = HEALBOT_FLASH_HEAL, Range = 40, Cast = 1.5, 
    Mana = 185, HealsMin = 327, HealsMax = 393, Level = 32 }, 
  [HEALBOT_FLASH_HEAL .. HEALBOT_RANK_4] = {
    Group = HEALBOT_FLASH_HEAL, Range = 40, Cast = 1.5, 
    Mana = 215, HealsMin = 400, HealsMax = 478, Level = 38 }, 
  [HEALBOT_FLASH_HEAL .. HEALBOT_RANK_5] = {
    Group = HEALBOT_FLASH_HEAL, Range = 40, Cast = 1.5, 
    Mana = 265, HealsMin = 518, HealsMax = 616, Level = 44 }, 
  [HEALBOT_FLASH_HEAL .. HEALBOT_RANK_6] = {
    Group = HEALBOT_FLASH_HEAL, Range = 40, Cast = 1.5, 
    Mana = 315, HealsMin = 644, HealsMax = 764, Level = 50 }, 
  [HEALBOT_FLASH_HEAL .. HEALBOT_RANK_7] = { 
    Group = HEALBOT_FLASH_HEAL, Range = 40, Cast = 1.5, 
    Mana = 380, HealsMin = 812, HealsMax = 958, Level = 56 }, 

  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_1] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana =  45, HealsMin =  44, HealsMax =  44, Level =  6,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_2] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana =  80, HealsMin =  88, HealsMax =  88, Level = 12,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_3] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana = 130, HealsMin = 158, HealsMax = 158, Level = 18,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_4] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana = 175, HealsMin = 234, HealsMax = 234, Level = 24,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_5] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana = 210, HealsMin = 301, HealsMax = 301, Level = 30,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_6] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana = 250, HealsMin = 381, HealsMax = 381, Level = 36,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_7] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana = 300, HealsMin = 484, HealsMax = 484, Level = 42,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_8] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana = 355, HealsMin = 605, HealsMax = 605, Level = 48,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_9] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana = 425, HealsMin = 763, HealsMax = 763, Level = 54,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 
  [HEALBOT_POWER_WORD_SHIELD .. HEALBOT_RANK_10] = {
    Group = HEALBOT_POWER_WORD_SHIELD, Range = 40, Shield = 30, 
    Mana = 500, HealsMin = 942, HealsMax = 942, Level = 60,
    Buff= HEALBOT_BUFF_POWER_WORD_SHIELD, Debuff = HEALBOT_DEBUF_WEAKENED_SOUL }, 

-- SHAMAN

  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_1] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 1.5, 
    Mana =  45, HealsMin =   34, HealsMax =   44, Level =  1 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_2] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 2.0, 
    Mana =  50, HealsMin =   64, HealsMax =   78, Level =  6 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_3] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 2.5, 
    Mana =  90, HealsMin =  129, HealsMax =  155, Level = 12 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_4] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 3.0, 
    Mana = 170, HealsMin =  268, HealsMax =  316, Level = 18 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_5] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 3.0, 
    Mana = 220, HealsMin =  376, HealsMax =  440, Level = 24 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_6] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 3.0, 
    Mana = 290, HealsMin =  536, HealsMax =  622, Level = 32 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_7] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 3.0, 
    Mana = 375, HealsMin =  740, HealsMax =  854, Level = 40 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_8] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 3.0, 
    Mana = 485, HealsMin = 1017, HealsMax = 1167, Level = 48 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_9] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 3.0, 
    Mana = 615, HealsMin = 1367, HealsMax = 1561, Level = 56 }, 
  [HEALBOT_HEALING_WAVE .. HEALBOT_RANK_10] = {
    Group = HEALBOT_HEALING_WAVE, Range = 40, Cast = 3.0, 
    Mana = 680, HealsMin = 1620, HealsMax = 1850, Level = 60 }, 

  [HEALBOT_LESSER_HEALING_WAVE .. HEALBOT_RANK_1] = {
    Group = HEALBOT_LESSER_HEALING_WAVE, Range = 40, Cast = 1.5, 
    Mana = 105, HealsMin = 162, HealsMax = 186, Level = 20 }, 
  [HEALBOT_LESSER_HEALING_WAVE .. HEALBOT_RANK_2] = {
    Group = HEALBOT_LESSER_HEALING_WAVE, Range = 40, Cast = 1.5, 
    Mana = 145, HealsMin = 247, HealsMax = 281, Level = 28 }, 
  [HEALBOT_LESSER_HEALING_WAVE .. HEALBOT_RANK_3] = {
    Group = HEALBOT_LESSER_HEALING_WAVE, Range = 40, Cast = 1.5, 
    Mana = 185, HealsMin = 337, HealsMax = 381, Level = 36 }, 
  [HEALBOT_LESSER_HEALING_WAVE .. HEALBOT_RANK_4] = {
    Group = HEALBOT_LESSER_HEALING_WAVE, Range = 40, Cast = 1.5, 
    Mana = 235, HealsMin = 458, HealsMax = 514, Level = 44 }, 
  [HEALBOT_LESSER_HEALING_WAVE .. HEALBOT_RANK_5] = {
    Group = HEALBOT_LESSER_HEALING_WAVE, Range = 40, Cast = 1.5, 
    Mana = 306, HealsMin = 631, HealsMax = 705, Level = 52 }, 
  [HEALBOT_LESSER_HEALING_WAVE .. HEALBOT_RANK_6] = {
    Group = HEALBOT_LESSER_HEALING_WAVE, Range = 40, Cast = 1.5, 
    Mana = 380, HealsMin = 832, HealsMax = 928, Level = 60 }, 

-- WARLOCK

  [HEALBOT_HEALTH_FUNNEL .. HEALBOT_RANK_1] = {
    Group = HEALBOT_HEALTH_FUNNEL, Range = 20, Channel = 10, Target = {"pet"}, 
    Mana = 0, HealsMin = 0, HealsMax = 0, HealsExt =  12*10, Health = 11, HealthExt =  5*10, Level = 12 },
  [HEALBOT_HEALTH_FUNNEL .. HEALBOT_RANK_2] = {
    Group = HEALBOT_HEALTH_FUNNEL, Range = 20, Channel = 10, Target = {"pet"}, 
    Mana = 0, HealsMin = 0, HealsMax = 0, HealsExt =  24*10, Health = 15, HealthExt = 10*10, Level = 20 },
  [HEALBOT_HEALTH_FUNNEL .. HEALBOT_RANK_3] = {
    Group = HEALBOT_HEALTH_FUNNEL, Range = 20, Channel = 10, Target = {"pet"}, 
    Mana = 0, HealsMin = 0, HealsMax = 0, HealsExt =  43*10, Health = 24, HealthExt = 17*10, Level = 28 },
  [HEALBOT_HEALTH_FUNNEL .. HEALBOT_RANK_4] = {
    Group = HEALBOT_HEALTH_FUNNEL, Range = 20, Channel = 10, Target = {"pet"}, 
    Mana = 0, HealsMin = 0, HealsMax = 0, HealsExt =  64*10, Health = 39, HealthExt = 24*10, Level = 36 },
  [HEALBOT_HEALTH_FUNNEL .. HEALBOT_RANK_5] = {
    Group = HEALBOT_HEALTH_FUNNEL, Range = 20, Channel = 10, Target = {"pet"}, 
    Mana = 0, HealsMin = 0, HealsMax = 0, HealsExt =  89*10, Health = 45, HealthExt = 33*10, Level = 44 },
  [HEALBOT_HEALTH_FUNNEL .. HEALBOT_RANK_6] = {
    Group = HEALBOT_HEALTH_FUNNEL, Range = 20, Channel = 10, Target = {"pet"}, 
    Mana = 0, HealsMin = 0, HealsMax = 0, HealsExt = 119*10, Health = 62, HealthExt = 42*10, Level = 52 },
  [HEALBOT_HEALTH_FUNNEL .. HEALBOT_RANK_7] = {
    Group = HEALBOT_HEALTH_FUNNEL, Range = 20, Channel = 10, Target = {"pet"}, 
    Mana = 0, HealsMin = 0, HealsMax = 0, HealsExt = 153*10, Health = 79, HealthExt = 52*10, Level = 60 },

  [HEALBOT_SACRIFICE .. HEALBOT_RANK_1] = {
    Group = HEALBOT_SACRIFICE, Range = 1000, Shield = 30, 
    Mana = 0, HealsMin =  305, HealsMax =  305, Level = 16 },
  [HEALBOT_SACRIFICE .. HEALBOT_RANK_2] = {
    Group = HEALBOT_SACRIFICE, Range = 1000, Shield = 30, 
    Mana = 0, HealsMin =  510, HealsMax =  510, Level = 24 },
  [HEALBOT_SACRIFICE .. HEALBOT_RANK_3] = {
    Group = HEALBOT_SACRIFICE, Range = 1000, Shield = 30, 
    Mana = 0, HealsMin =  770, HealsMax =  770, Level = 32 },
  [HEALBOT_SACRIFICE .. HEALBOT_RANK_4] = {
    Group = HEALBOT_SACRIFICE, Range = 1000, Shield = 30, 
    Mana = 0, HealsMin = 1095, HealsMax = 1095, Level = 40 },
  [HEALBOT_SACRIFICE .. HEALBOT_RANK_5] = {
    Group = HEALBOT_SACRIFICE, Range = 1000, Shield = 30, 
    Mana = 0, HealsMin = 1470, HealsMax = 1470, Level = 48 },
  [HEALBOT_SACRIFICE .. HEALBOT_RANK_6] = {
    Group = HEALBOT_SACRIFICE, Range = 1000, Shield = 30, 
    Mana = 0, HealsMin = 1905, HealsMax = 1905, Level = 56 },

};

HealBot_Heals = {};
