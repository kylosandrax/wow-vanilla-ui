HEALBOT_VERSION = "v0.35b";

-------------
-- ENGLISH --
-------------

-------------------
-- Compatibility --
-------------------

HEALBOT_FLASH_HEAL          = "Flash Heal";
HEALBOT_FLASH_OF_LIGHT      = "Flash of Light";
HEALBOT_HOLY_SHOCK			= "Holy Shock";
HEALBOT_GREATER_HEAL        = "Greater Heal";
HEALBOT_HEALING_TOUCH       = "Healing Touch";
HEALBOT_HEAL                = "Heal";
HEALBOT_HEALING_WAVE        = "Healing Wave";
HEALBOT_HOLY_LIGHT          = "Holy Light";
HEALBOT_LESSER_HEAL         = "Lesser Heal";
HEALBOT_LESSER_HEALING_WAVE = "Lesser Healing Wave";
HEALBOT_MEND_PET            = "Mend Pet";
HEALBOT_REGROWTH            = "Regrowth";
HEALBOT_RENEW               = "Renew";
HEALBOT_REJUVENATION        = "Rejuvenation";

HEALBOT_RANK_1              = "(Rank 1)";
HEALBOT_RANK_2              = "(Rank 2)";
HEALBOT_RANK_3              = "(Rank 3)";
HEALBOT_RANK_4              = "(Rank 4)";
HEALBOT_RANK_5              = "(Rank 5)";
HEALBOT_RANK_6              = "(Rank 6)";
HEALBOT_RANK_7              = "(Rank 7)";
HEALBOT_RANK_8              = "(Rank 8)";
HEALBOT_RANK_9              = "(Rank 9)";
HEALBOT_RANK_10             = "(Rank 10)";

-----------------
-- Translation --
-----------------

HEALBOT_ADDON = "HealBot " .. HEALBOT_VERSION;
HEALBOT_LOADED = " loaded.";

HEALBOT_CASTINGSPELLONYOU  = "Casting %s on you ...";
HEALBOT_CASTINGSPELLONUNIT = "Casting %s on %s ...";

HEALBOT_OPTIONS_TITLE         = HEALBOT_ADDON;
HEALBOT_OPTIONS_HEALLEVEL     = "Healing Level";
HEALBOT_OPTIONS_ALERTLEVEL    = "Alert Level";
HEALBOT_OPTIONS_AUTOSHOW      = "Open/close panel automatically";
HEALBOT_OPTIONS_PANELSOUNDS   = "Play sound on open/close panel";
HEALBOT_OPTIONS_ACTIONLOCKED  = "Lock main panel position";
HEALBOT_OPTIONS_ACTIONALPHA   = "Main panel opacity";
HEALBOT_OPTIONS_TARGETWHISPER = "Whisper target when healing";
HEALBOT_OPTIONS_TARGETHEALS   = "Heal friendly targets";
HEALBOT_OPTIONS_ALERTSECONDS  = "Death countdown timer";
HEALBOT_OPTIONS_CONSERVEMANA  = "Mana conservation (experimental)";
HEALBOT_OPTIONS_DEFAULTS      = "Defaults";
HEALBOT_OPTIONS_CLOSE         = "Close";

HEALBOT_ACTION_TITLE      = "HealBot";
HEALBOT_ACTION_OPTIONS    = "Options";

BINDING_HEADER_HEALBOT  = "HealBot";
BINDING_NAME_TOGGLEMAIN = "Toggle main panel";
BINDING_NAME_HEALPLAYER = "Heal player";
BINDING_NAME_HEALPET    = "Heal pet";
BINDING_NAME_HEALPARTY1 = "Heal party1";
BINDING_NAME_HEALPARTY2 = "Heal party2";
BINDING_NAME_HEALPARTY3 = "Heal party3";
BINDING_NAME_HEALPARTY4 = "Heal party4";
BINDING_NAME_HEALTARGET = "Heal target";


------------
-- GERMAN --
------------

-- Ä = \195\132
-- Ö = \195\150
-- Ü = \195\156
-- ß = \195\159
-- ä = \195\164
-- ö = \195\182
-- ü = \195\188


if (GetLocale() == "deDE") then

-------------------
-- Compatibility --
-------------------

HEALBOT_FLASH_HEAL          = "Blitzheilung";
HEALBOT_FLASH_OF_LIGHT      = "Lichtblitz";
HEALBOT_HOLY_SHOCK			= "Holy Shock";
--HEALBOT_GREATER_HEAL        = "Gro\195\159e Heilung";
HEALBOT_GREATER_HEAL        = "Gr\195\182\195\159ere Heilung";
--HEALBOT_HEALING_TOUCH       = "Heilende H\195\164nde";
HEALBOT_HEALING_TOUCH       = "Heilende Ber\195\188hrung";
HEALBOT_HEAL                = "Heilung";
HEALBOT_HEALING_WAVE        = "Welle der Heilung";
HEALBOT_HOLY_LIGHT          = "Heiliges Licht";
--HEALBOT_LESSER_HEAL         = "Geringe Heilung";
HEALBOT_LESSER_HEAL         = "Geringere Heilung";
HEALBOT_LESSER_HEALING_WAVE = "Geringe Welle der Heilung";
HEALBOT_MEND_PET            = "Tier Heilen";
HEALBOT_REGROWTH            = "Nachwachsen";
HEALBOT_RENEW               = "Erneuerung";
HEALBOT_REJUVENATION        = "Verj\195\188ngung";

HEALBOT_RANK_1              = "(Rang 1)";
HEALBOT_RANK_2              = "(Rang 2)";
HEALBOT_RANK_3              = "(Rang 3)";
HEALBOT_RANK_4              = "(Rang 4)";
HEALBOT_RANK_5              = "(Rang 5)";
HEALBOT_RANK_6              = "(Rang 6)";
HEALBOT_RANK_7              = "(Rang 7)";
HEALBOT_RANK_8              = "(Rang 8)";
HEALBOT_RANK_9              = "(Rang 9)";
HEALBOT_RANK_10             = "(Rang 10)";

-----------------
-- Translation --
-----------------

HEALBOT_ADDON = "Holgaard's HealBot " .. HEALBOT_VERSION;
HEALBOT_LOADED = " geladen.";

HEALBOT_CASTINGSPELLONYOU  = "Wirke %s auf Euch ...";
HEALBOT_CASTINGSPELLONUNIT = "Wirke %s auf %s ...";

HEALBOT_OPTIONS_TITLE         = HEALBOT_ADDON;
HEALBOT_OPTIONS_HEALLEVEL     = "Heilstufe";
HEALBOT_OPTIONS_ALERTLEVEL    = "Alarmstufe";
HEALBOT_OPTIONS_AUTOSHOW      = "Fenster \195\182ffnen wenn Heilung ben\195\182tigt wird";
HEALBOT_OPTIONS_PANELSOUNDS   = "Ton beim \195\182ffnen/schlie\195\159en";
HEALBOT_OPTIONS_ACTIONLOCKED  = "Hauptfenster sperren";
HEALBOT_OPTIONS_ACTIONALPHA   = "Transparenz des Hauptfensters";
HEALBOT_OPTIONS_TARGETWHISPER = "Ziel bei Heilung anfl\195\188stern";
HEALBOT_OPTIONS_TARGETHEALS   = "Freundliche Ziele heilen";
HEALBOT_OPTIONS_ALERTSECONDS  = "Todescountdown";
HEALBOT_OPTIONS_CONSERVEMANA  = "Mana sparen (experimentell)";
HEALBOT_OPTIONS_DEFAULTS      = "Reset";
HEALBOT_OPTIONS_CLOSE         = "Schlie\195\159en";

HEALBOT_ACTION_TITLE      = "HealBot";
HEALBOT_ACTION_OPTIONS    = "Optionen";

BINDING_HEADER_HEALBOT  = "HeilBot";
BINDING_NAME_TOGGLEMAIN = "Hauptfenster an-/ausschalten";
BINDING_NAME_HEALPLAYER = "Spieler heilen";
BINDING_NAME_HEALPET    = "Begleiter heilen";
BINDING_NAME_HEALPARTY1 = "Gruppenmitglied 1 heilen";
BINDING_NAME_HEALPARTY2 = "Gruppenmitglied 2 heilen";
BINDING_NAME_HEALPARTY3 = "Gruppenmitglied 3 heilen";
BINDING_NAME_HEALPARTY4 = "Gruppenmitglied 4 heilen";
BINDING_NAME_HEALTARGET = "Ziel heilen";

end


------------
-- FRENCH --
------------

-- à = \195\160
-- â = \195\162
-- é = \195\169
-- ê = \195\170
-- ï = \195\175
-- ô = \195\180


if (GetLocale() == "frFR") then

-------------------
-- Compatibility --
-------------------

HEALBOT_FLASH_HEAL          = "Soins Rapides";
HEALBOT_FLASH_OF_LIGHT      = "Eclair Lumineux";
HEALBOT_HOLY_SHOCK			= "Holy Shock";
HEALBOT_GREATER_HEAL        = "Soins Sup\195\169rieurs";
HEALBOT_HEALING_TOUCH       = "Toucher Gu\195\169risseur";
HEALBOT_HEAL                = "Soins";
HEALBOT_HEALING_WAVE        = "Vague de Soins";
HEALBOT_HOLY_LIGHT          = "Feu Sacr\195\169e";
HEALBOT_LESSER_HEAL         = "Soins Mineurs";
HEALBOT_LESSER_HEALING_WAVE = "Vague de Soins Mineurs";
HEALBOT_MEND_PET            = "Soigner un Familier";
HEALBOT_REGROWTH            = "R\195\169tablissement";
HEALBOT_RENEW               = "R\195\169novation";
HEALBOT_REJUVENATION        = "R\195\169cup\195\169ration";

HEALBOT_RANK_1              = "(Niveau 1)";
HEALBOT_RANK_2              = "(Niveau 2)";
HEALBOT_RANK_3              = "(Niveau 3)";
HEALBOT_RANK_4              = "(Niveau 4)";
HEALBOT_RANK_5              = "(Niveau 5)";
HEALBOT_RANK_6              = "(Niveau 6)";
HEALBOT_RANK_7              = "(Niveau 7)";
HEALBOT_RANK_8              = "(Niveau 8)";
HEALBOT_RANK_9              = "(Niveau 9)";
HEALBOT_RANK_10             = "(Niveau 10)";

-----------------
-- Translation --
-----------------

HEALBOT_ADDON = "Holgaard's HealBot " .. HEALBOT_VERSION;
HEALBOT_LOADED = " loaded.";

end

