
ItemRack_Users = {
	["Kylosandrax of Warsong [12x] Blizzlike"] = {
		["Visible"] = "ON",
		["MainScale"] = 0.9185225963592529,
		["XPos"] = 2.42053532925439,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
			[13] = 1,
			[14] = 1,
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "ON",
		["YPos"] = 309.674735925117,
		["Spaces"] = {
		},
		["Bar"] = {
			[1] = 13,
			[2] = 14,
		},
	},
	["Kylosandrax of Al'Akir [instant 60] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	["Ryjax of Warsong [12x] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	["Stormslinger of Warsong [12x] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	["Ryvok of Warsong [12x] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	["Nameplate of Emerald Dream [1x] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	["Banjax of Warsong [12x] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	["Sixofnine of Warsong [12x] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	["Ryvok of Emerald Dream [1x] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	["Zapunzel of Warsong [12x] Blizzlike"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
}
ItemRack_Settings = {
	["Notify"] = "ON",
	["AllowHidden"] = "OFF",
	["Minimap"] = {
	},
	["ShowEmpty"] = "ON",
	["SquareMinimap"] = "ON",
	["Soulbound"] = "OFF",
	["EnableEvents"] = "OFF",
	["RotateMenu"] = "OFF",
	["AutoToggle"] = "OFF",
	["BigCooldown"] = "OFF",
	["ShowAllEvents"] = "OFF",
	["ShowIcon"] = "OFF",
	["IconPos"] = 162.6867869007372,
	["TooltipFollow"] = "ON",
	["RightClick"] = "OFF",
	["SetLabels"] = "ON",
	["FlipMenu"] = "OFF",
	["NotifyThirty"] = "ON",
	["FlipBar"] = "OFF",
	["ShowTooltips"] = "ON",
	["TinyTooltip"] = "OFF",
	["DisableToggle"] = "ON",
	["Bindings"] = "ON",
	["CompactList"] = "OFF",
	["CooldownNumbers"] = "OFF",
	["MenuShift"] = "OFF",
	["LargeFont"] = "OFF",
}
ItemRack_Events = {
	["Druid:Caster Form"] = {
		["script"] = "if not ItemRack_GetForm() and IR_FORM then EquipSet() IR_FORM=nil end --[[Equip a set when not in an animal form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Druid:Aquatic Form"] = {
		["script"] = "local form=ItemRack_GetForm() if form==\"Aquatic Form\" and IR_FORM~=form then EquipSet() IR_FORM=form end --[[Equip a set when in aquatic form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Druid:Moonkin Form"] = {
		["script"] = "local form=ItemRack_GetForm() if form==\"Moonkin Form\" and IR_FORM~=form then EquipSet() IR_FORM=form end --[[Equip a set when in moonkin form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["events_version"] = 1.975,
	["Plaguelands"] = {
		["script"] = "local zone = GetRealZoneText(),0\nif (zone==\"Western Plaguelands\" or zone==\"Eastern Plaguelands\" or zone==\"Scholomance\" or zone==\"Stratholme\") and not IR_PLAGUE then\n    EquipSet() IR_PLAGUE=1\nelseif IR_PLAGUE then\n    LoadSet() IR_PLAGUE=nil\nend\n--[[Equips set to be worn while in plaguelands.]]",
		["trigger"] = "ZONE_CHANGED_NEW_AREA",
		["delay"] = 1,
	},
	["About Town"] = {
		["script"] = "if IsResting() and not IR_TOWN then EquipSet() IR_TOWN=1 elseif IR_TOWN then LoadSet() IR_TOWN=nil end\n--[[Equips a set while in a city or inn.]]",
		["trigger"] = "PLAYER_UPDATE_RESTING",
		["delay"] = 0,
	},
	["Druid:Cat Form"] = {
		["script"] = "local form=ItemRack_GetForm() if form==\"Cat Form\" and IR_FORM~=form then EquipSet(\"Feral\") IR_FORM=form end --[[Equip a set when in cat form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 1,
	},
	["Low Mana"] = {
		["script"] = "local mana = UnitMana(\"player\") / UnitManaMax(\"player\")\nif mana < .5 and not IR_OOM then\n  SaveSet()\n  EquipSet()\n  IR_OOM = 1\nelseif IR_OOM and mana > .75 then\n  LoadSet()\n  IR_OOM = nil\nend\n--[[Equips a set when mana is below 50% and re-equips previous gear at 75% mana. Remember: You can't swap non-weapons in combat.]]",
		["trigger"] = "UNIT_MANA",
		["delay"] = 0.5,
	},
	["Rogue:Stealth"] = {
		["script"] = "local _,_,isActive = GetShapeshiftFormInfo(1)\nif isActive and not IR_FORM then\n  EquipSet() IR_FORM=1\nelseif not isActive and IR_FORM then\n  LoadSet() IR_FORM=nil\nend\n--[[Equips set to be worn while stealthed.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Mage:Evocation"] = {
		["script"] = "local evoc=arg1[\"Interface\\\\Icons\\\\Spell_Nature_Purge\"]\nif evoc and not IR_EVOC then\n  EquipSet() IR_EVOC=1\nelseif not evoc and IR_EVOC then\n  LoadSet() IR_EVOC=nil\nend\n--[[Equips a set to wear while channeling Evocation.]]",
		["trigger"] = "ITEMRACK_BUFFS_CHANGED",
		["delay"] = 0.25,
	},
	["Warrior:Berserker"] = {
		["script"] = "local _,_,isActive = GetShapeshiftFormInfo(3) if isActive and IR_FORM~=\"Berserker\" then EquipSet() IR_FORM=\"Berserker\" end --[[Equips set to be worn in Berserker stance.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Druid:Bear Form"] = {
		["script"] = "local form = ItemRack_GetForm()\nif (form==\"Dire Bear Form\" or form==\"Bear Form\") and IR_FORM~=\"Bear Form\" then EquipSet(\"Feral\") IR_FORM=\"Bear Form\" end --[[Equip a set when in bear form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Warrior:Battle"] = {
		["script"] = "local _,_,isActive = GetShapeshiftFormInfo(1) if isActive and IR_FORM~=\"Battle\" then EquipSet() IR_FORM=\"Battle\" end --[[Equips set to be worn in battle stance.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Skinning"] = {
		["script"] = "if UnitIsDead(\"mouseover\") and GameTooltipTextLeft3:GetText()==UNIT_SKINNABLE then\n  local r,g,b = GameTooltipTextLeft3:GetTextColor()\n  if r>.9 and g<.2 and b<.2 and not IR_SKIN then\n    EquipSet() IR_SKIN=1\n  end\nelseif IR_SKIN then\n  LoadSet() IR_SKIN=nil\nend\n--[[Equips a set when you mouseover something that can be skinned but you have insufficient skill.]]\n",
		["trigger"] = "UPDATE_MOUSEOVER_UNIT",
		["delay"] = 0,
	},
	["Warrior:Overpower End"] = {
		["script"] = "--[[Equip a set five seconds after opponent dodged: your normal weapons. ]]\nif IR_OVERPOWER==1 then\nEquipSet()\nIR_OVERPOWER=nil\nend",
		["trigger"] = "CHAT_MSG_COMBAT_SELF_MISSES",
		["delay"] = 5,
	},
	["Priest:Spirit Tap End"] = {
		["script"] = "local found=arg1[\"Interface\\\\Icons\\\\Spell_Shadow_Requiem\"]\nif IR_SPIRIT and not found then\nLoadSet() IR_SPIRIT = nil\nend\n--[[Returns to normal gear when Spirit Tap ends. Associate the same spirit set as Spirit Tap Begin.]]",
		["trigger"] = "ITEMRACK_BUFFS_CHANGED",
		["delay"] = 0.5,
	},
	["Insignia Used"] = {
		["script"] = "if arg1==\"Insignia of the Alliance\" or arg1==\"Insignia of the Horde\" then EquipSet() end --[[Equips a set when the Insignia of the Alliance/Horde has been used.]]",
		["trigger"] = "ITEMRACK_ITEMUSED",
		["delay"] = 0.5,
	},
	["Swimming"] = {
		["script"] = "local i,found\nfor i=1,3 do\n  if getglobal(\"MirrorTimer\"..i):IsVisible() and getglobal(\"MirrorTimer\"..i..\"Text\"):GetText() == BREATH_LABEL then\n    found = 1\n  end\nend\nif found then\n  EquipSet()\nend\n--[[Equips a set when the breath gauge appears. NOTE: This will not re-equip gear when you leave water.  There's no reliable way to know when you leave water. Also note: Won't work with eCastingBar.]]",
		["trigger"] = "MIRROR_TIMER_START",
		["delay"] = 0,
	},
	["Warrior:Defensive"] = {
		["script"] = "local _,_,isActive = GetShapeshiftFormInfo(2) if isActive and IR_FORM~=\"Defensive\" then EquipSet() IR_FORM=\"Defensive\" end --[[Equips set to be worn in Defensive stance.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Druid:Travel Form"] = {
		["script"] = "local form=ItemRack_GetForm() if form==\"Travel Form\" and IR_FORM~=form then EquipSet() IR_FORM=form end --[[Equip a set when in travel form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Mount"] = {
		["script"] = "local mount\nif UnitIsMounted then mount = UnitIsMounted(\"player\") else mount = ItemRack_PlayerMounted() end\nif not IR_MOUNT and mount then\n  EquipSet()\nelseif IR_MOUNT and not mount then\n  LoadSet()\nend\nIR_MOUNT=mount\n--[[Equips set to be worn while mounted.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Eating-Drinking"] = {
		["script"] = "local found=arg1[\"Interface\\\\Icons\\\\INV_Misc_Fork&Knife\"] or arg1[\"Drink\"]\nif not IR_DRINK and found then\nEquipSet() IR_DRINK=1\nelseif IR_DRINK and not found then\nLoadSet() IR_DRINK=nil\nend\n--[[Equips a set while eating or drinking.]]",
		["trigger"] = "ITEMRACK_BUFFS_CHANGED",
		["delay"] = 0,
	},
	["Insignia"] = {
		["script"] = "if arg1==\"Insignia of the Alliance\" or arg1==\"Insignia of the Horde\" then EquipSet() end --[[Equips a set when the Insignia of the Alliance/Horde finishes cooldown.]]",
		["trigger"] = "ITEMRACK_NOTIFY",
		["delay"] = 0,
	},
	["Priest:Spirit Tap Begin"] = {
		["script"] = "local found=ItemRack.Buffs[\"Interface\\\\Icons\\\\Spell_Shadow_Requiem\"]\nif not IR_SPIRIT and found then\nEquipSet() IR_SPIRIT=1\nend\n--[[Equips a set when you leave combat with Spirit Tap. Associate a set of spirit gear to this event.]]",
		["trigger"] = "PLAYER_REGEN_ENABLED",
		["delay"] = 0.25,
	},
	["Priest:Shadowform"] = {
		["script"] = "local f=arg1[\"Interface\\\\Icons\\\\Spell_Shadow_Shadowform\"]\nif not IR_Shadowform and f then\n  EquipSet() IR_Shadowform=1\nelseif IR_Shadowform and not f then\n  LoadSet() IR_Shadowform=nil\nend\n--[[Equips a set while under Shadowform]]",
		["trigger"] = "ITEMRACK_BUFFS_CHANGED",
		["delay"] = 0,
	},
	["Warrior:Overpower Begin"] = {
		["script"] = "--[[Equip a set when the opponent dodges.  Associate a heavy-hitting 2h set with this event. ]]\nlocal _,_,i = GetShapeshiftFormInfo(1)\nif string.find(arg1 or \"\",\"^You.+dodge[sd]\") and i then\nEquipSet()\nIR_OVERPOWER=1\nend",
		["trigger"] = "CHAT_MSG_COMBAT_SELF_MISSES",
		["delay"] = 0,
	},
}
Rack_User = {
	["Kylosandrax of Warsong [12x] Blizzlike"] = {
		["Sets"] = {
			["Tank"] = {
				[1] = {
					["name"] = "Gyth's Skull of Frost Resistance",
					["id"] = "12952:2545:1366",
					["old"] = "12640:0:0",
				},
				[2] = {
					["name"] = "Talisman of Protection",
					["id"] = "19871:0:0",
					["old"] = "21809:0:0",
				},
				[3] = {
					["name"] = "Darksoul Shoulders",
					["id"] = "19695:0:0",
					["old"] = "12927:0:0",
				},
				[5] = {
					["name"] = "Darksoul Breastplate",
					["id"] = "19693:1892:0",
					["old"] = "11926:928:0",
				},
				[6] = {
					["name"] = "Belt of the Sand Reaver",
					["id"] = "21503:0:0",
					["old"] = "20216:0:0",
				},
				[7] = {
					["name"] = "Darksoul Leggings",
					["id"] = "19694:2545:0",
					["old"] = "22385:0:0",
				},
				[8] = {
					["name"] = "Bloodsoaked Greaves",
					["id"] = "19913:929:0",
					["old"] = "21490:1887:0",
				},
				[9] = {
					["name"] = "Bracers of Heroism",
					["id"] = "21996:1886:0",
					["old"] = "21457:927:0",
				},
				[10] = {
					["name"] = "Gauntlets of the Immovable",
					["id"] = "21479:856:0",
					["old"] = "22714:856:0",
				},
				[11] = {
					["name"] = "Naglering",
					["id"] = "11669:0:0",
					["old"] = "13217:0:0",
				},
				[12] = {
					["name"] = "Band of the Steadfast Hero",
					["id"] = "22331:0:0",
					["old"] = "21393:0:0",
				},
				[13] = {
					["name"] = "Zandalarian Hero Badge",
					["id"] = "19948:0:0",
					["old"] = "20130:0:0",
				},
				[14] = {
					["name"] = "Mark of Tyranny",
					["id"] = "13966:0:0",
					["old"] = "11815:0:0",
				},
				[15] = {
					["name"] = "Sandstorm Cloak",
					["id"] = "21456:0:0",
					["old"] = "11930:247:0",
				},
				[16] = {
					["name"] = "Thekal's Grasp",
					["id"] = "19896:1900:0",
					["old"] = "12940:1900:0",
				},
				[17] = {
					["name"] = "Aegis of the Blood God",
					["id"] = "19862:929:0",
					["old"] = "19852:1900:0",
				},
				[18] = {
					["name"] = "Willey's Portable Howitzer",
					["id"] = "13380:0:0",
					["old"] = "22347:2523:0",
				},
				["key"] = "F10",
				["keyindex"] = 2,
				["oldsetname"] = "DPS",
				["icon"] = "Interface\\Icons\\INV_Helmet_20",
				[0] = {
					["name"] = "Accurate Slugs",
					["id"] = "11284:0:0",
					["old"] = "11285:0:0",
				},
			},
			["DPS"] = {
				[1] = {
					["name"] = "Lionheart Helm",
					["id"] = "12640:0:0",
					["old"] = "20408:0:0",
				},
				[2] = {
					["name"] = "Fury of the Forgotten Swarm",
					["id"] = "21809:0:0",
					["old"] = "19871:0:0",
				},
				[3] = {
					["name"] = "Truestrike Shoulders",
					["id"] = "12927:0:0",
					["old"] = "20406:0:0",
				},
				[5] = {
					["name"] = "Deathdealer Breastplate",
					["id"] = "11926:928:0",
					["old"] = "20407:0:0",
				},
				[6] = {
					["name"] = "Belt of Preserved Heads",
					["id"] = "20216:0:0",
					["old"] = "21503:0:0",
				},
				[7] = {
					["name"] = "Titanic Leggings",
					["id"] = "22385:0:0",
					["old"] = "19694:2545:0",
				},
				[8] = {
					["name"] = "Slime Kickers",
					["id"] = "21490:1887:0",
					["old"] = "19913:929:0",
				},
				[9] = {
					["name"] = "Bracers of Brutality",
					["id"] = "21457:927:0",
					["old"] = "21996:1886:0",
				},
				[10] = {
					["name"] = "Sacrificial Gauntlets",
					["id"] = "22714:856:0",
					["old"] = "21479:856:0",
				},
				[11] = {
					["name"] = "Band of the Penitent",
					["id"] = "13217:0:0",
					["old"] = "11669:0:0",
				},
				[12] = {
					["name"] = "Signet of Unyielding Strength",
					["id"] = "21393:0:0",
					["old"] = "22331:0:0",
				},
				[13] = {
					["name"] = "Diamond Flask",
					["id"] = "20130:0:0",
					["old"] = "19948:0:0",
				},
				[14] = {
					["name"] = "Hand of Justice",
					["id"] = "11815:0:0",
					["old"] = "13966:0:0",
				},
				[15] = {
					["name"] = "The Emperor's New Cape",
					["id"] = "11930:247:0",
					["old"] = "21456:0:0",
				},
				[16] = {
					["name"] = "Dal'Rend's Sacred Charge",
					["id"] = "12940:1900:0",
					["old"] = "19896:1900:0",
				},
				[17] = {
					["name"] = "Ancient Hakkari Manslayer",
					["id"] = "19852:1900:0",
					["old"] = "19862:929:0",
				},
				[18] = {
					["name"] = "Fahrad's Reloading Repeater",
					["id"] = "22347:2523:0",
					["old"] = "13380:0:0",
				},
				["key"] = "F9",
				[0] = {
					["name"] = "Jagged Arrow",
					["id"] = "11285:0:0",
					["old"] = "11284:0:0",
				},
				["keyindex"] = 1,
				["icon"] = "Interface\\Icons\\Ability_BackStab",
				["oldsetname"] = "DPS",
			},
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
			["Nekkid"] = {
				[1] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "12640:0:0",
				},
				[2] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "21809:0:0",
				},
				[3] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "19695:0:0",
				},
				[5] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "11926:1892:0",
				},
				[6] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "20216:0:0",
				},
				[7] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "22385:0:0",
				},
				[8] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "21490:1887:0",
				},
				[9] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "21457:927:0",
				},
				[10] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "18349:856:0",
				},
				[11] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "13217:0:0",
				},
				[12] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "12002:0:1202",
				},
				[13] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "20130:0:0",
				},
				[14] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "19120:0:0",
				},
				[15] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "11930:0:0",
				},
				[16] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "12940:1900:0",
				},
				[17] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "19852:1900:0",
				},
				[18] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "22347:2523:0",
				},
				["oldsetname"] = "DPS",
				["icon"] = "Interface\\Icons\\Ability_CheapShot",
			},
			["Tank-MaxDEF"] = {
				[1] = {
					["id"] = "12952:2545:1366",
					["name"] = "Gyth's Skull of Frost Resistance",
				},
				[2] = {
					["id"] = "19871:0:0",
					["name"] = "Talisman of Protection",
				},
				[3] = {
					["name"] = "Polished Obsidian Pauldrons",
					["id"] = "21805:0:0",
					["old"] = "19695:0:0",
				},
				[5] = {
					["name"] = "Kromcrush's Chestplate",
					["id"] = "18503:1892:0",
					["old"] = "19693:1892:0",
				},
				[6] = {
					["id"] = "21503:0:0",
					["name"] = "Belt of the Sand Reaver",
				},
				[7] = {
					["name"] = "Deathbone Legguards",
					["id"] = "14623:2545:0",
					["old"] = "19694:2545:0",
				},
				[8] = {
					["id"] = "19913:929:0",
					["name"] = "Bloodsoaked Greaves",
				},
				[9] = {
					["id"] = "21996:1886:0",
					["name"] = "Bracers of Heroism",
				},
				[10] = {
					["id"] = "21479:856:0",
					["name"] = "Gauntlets of the Immovable",
				},
				[11] = {
					["id"] = "11669:0:0",
					["name"] = "Naglering",
				},
				[12] = {
					["id"] = "22331:0:0",
					["name"] = "Band of the Steadfast Hero",
				},
				[13] = {
					["name"] = "Force of Will",
					["id"] = "11810:0:0",
					["old"] = "19948:0:0",
				},
				[14] = {
					["id"] = "13966:0:0",
					["name"] = "Mark of Tyranny",
				},
				[15] = {
					["id"] = "21456:0:0",
					["name"] = "Sandstorm Cloak",
				},
				[16] = {
					["id"] = "19896:1900:0",
					["name"] = "Thekal's Grasp",
				},
				[17] = {
					["id"] = "19862:929:0",
					["name"] = "Aegis of the Blood God",
				},
				[18] = {
					["id"] = "13380:0:0",
					["name"] = "Willey's Portable Howitzer",
				},
				["oldsetname"] = "Tank",
				[0] = {
					["id"] = "11284:0:0",
					["name"] = "Accurate Slugs",
				},
				["icon"] = "Interface\\Icons\\Ability_Warrior_Safeguard",
			},
		},
		["CurrentSet"] = "DPS",
	},
	["Kylosandrax of Al'Akir [instant 60] Blizzlike"] = {
		["Sets"] = {
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
		},
	},
	["Ryjax of Warsong [12x] Blizzlike"] = {
		["Sets"] = {
			["DPS"] = {
				[1] = {
					["name"] = "Eye of Rend",
					["id"] = "12587:0:0",
					["old"] = "16900:0:0",
				},
				[2] = {
					["name"] = "Obsidian Pendant of the Bear",
					["id"] = "12035:0:1201",
					["old"] = "19923:0:0",
				},
				[3] = {
					["name"] = "Nightshade Spaulders of the Bear",
					["id"] = "10228:0:1215",
					["old"] = "22234:0:0",
				},
				[5] = {
					["name"] = "Mixologist's Tunic",
					["id"] = "12793:1892:0",
					["old"] = "16833:913:0",
				},
				[6] = {
					["name"] = "Belt of Preserved Heads",
					["id"] = "20216:0:0",
					["old"] = "18327:0:0",
				},
				[7] = {
					["name"] = "Blademaster Leggings",
					["id"] = "12963:0:0",
					["old"] = "18386:0:0",
				},
				[8] = {
					["name"] = "Abyssal Leather Boots of Striking",
					["id"] = "20658:852:2149",
					["old"] = "22275:929:0",
				},
				[9] = {
					["name"] = "Feralheart Bracers",
					["id"] = "22108:927:0",
					["old"] = "19840:905:0",
				},
				[10] = {
					["name"] = "Blooddrenched Grips",
					["id"] = "19869:0:0",
					["old"] = "20655:0:2146",
				},
				[11] = {
					["name"] = "Marble Circle of the Gorilla",
					["id"] = "12002:0:947",
					["old"] = "19863:0:0",
				},
				[12] = {
					["name"] = "Band of the Ogre King",
					["id"] = "18522:0:0",
					["old"] = "16058:0:0",
				},
				[13] = {
					["name"] = "Rune of the Guard Captain",
					["id"] = "19120:0:0",
					["old"] = "18470:0:0",
				},
				[14] = {
					["name"] = "Blackhand's Breadth",
					["id"] = "13965:0:0",
					["old"] = "11819:0:0",
				},
				[15] = {
					["name"] = "Righteous Cloak of the Monkey",
					["id"] = "10071:0:604",
					["old"] = "21470:0:0",
				},
				[16] = {
					["name"] = "Bonecrusher",
					["id"] = "18420:1896:0",
					["old"] = "22713:0:0",
				},
				[17] = {
					["id"] = 0,
					["old"] = "11928:0:0",
				},
				[18] = {
					["name"] = "Idol of Ferocity",
					["id"] = "22397:0:0",
					["old"] = "22398:0:0",
				},
				["key"] = "F9",
				["keyindex"] = 1,
				["icon"] = "Interface\\Icons\\Ability_Druid_CatForm",
				["oldsetname"] = "HealBot",
			},
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
			["Tanking"] = {
				[1] = {
					["name"] = "Blooddrenched Mask",
					["id"] = "22718:0:0",
					["old"] = "16900:0:0",
				},
				[2] = {
					["name"] = "Obsidian Pendant of the Bear",
					["id"] = "12035:0:1201",
					["old"] = "19923:0:0",
				},
				[3] = {
					["name"] = "Golden Mantle of the Dawn",
					["id"] = "19058:0:0",
					["old"] = "22234:0:0",
				},
				[5] = {
					["name"] = "Mixologist's Tunic",
					["id"] = "12793:1892:0",
					["old"] = "16833:913:0",
				},
				[6] = {
					["name"] = "Serpentine Sash",
					["id"] = "13118:0:0",
					["old"] = "18327:0:0",
				},
				[7] = {
					["name"] = "Warstrife Leggings",
					["id"] = "11821:2545:0",
					["old"] = "18386:0:0",
				},
				[8] = {
					["name"] = "Abyssal Leather Boots of Striking",
					["id"] = "20658:852:2149",
					["old"] = "22275:929:0",
				},
				[9] = {
					["name"] = "Wristguards of Renown",
					["id"] = "22204:1886:0",
					["old"] = "19840:905:0",
				},
				[10] = {
					["name"] = "Toughened Silithid Hide Gloves",
					["id"] = "21501:904:0",
					["old"] = "20655:0:2146",
				},
				[11] = {
					["name"] = "Thrall's Resolve",
					["id"] = "12544:0:0",
					["old"] = "19863:0:0",
				},
				[12] = {
					["name"] = "Ring of Protection",
					["id"] = "15855:0:0",
					["old"] = "16058:0:0",
				},
				[13] = {
					["name"] = "Mark of Tyranny",
					["id"] = "13966:0:0",
					["old"] = "18470:0:0",
				},
				[14] = {
					["name"] = "Smoking Heart of the Mountain",
					["id"] = "11811:0:0",
					["old"] = "11819:0:0",
				},
				[15] = {
					["name"] = "Overlord's Embrace",
					["id"] = "19888:849:0",
					["old"] = "21470:0:0",
				},
				[16] = {
					["name"] = "Warden Staff",
					["id"] = "943:249:0",
					["old"] = "22713:0:0",
				},
				[17] = {
					["id"] = 0,
					["old"] = "11928:0:0",
				},
				[18] = {
					["name"] = "Idol of Brutality",
					["id"] = "23198:0:0",
					["old"] = "22398:0:0",
				},
				["key"] = "F10",
				["keyindex"] = 3,
				["icon"] = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
				["oldsetname"] = "HealBot",
			},
			["HealBot"] = {
				[1] = {
					["name"] = "Stormrage Cover",
					["id"] = "16900:0:0",
					["old"] = "12587:0:0",
				},
				[2] = {
					["name"] = "Jeklik's Opaline Talisman",
					["id"] = "19923:0:0",
					["old"] = "12035:0:1201",
				},
				[3] = {
					["name"] = "Mantle of Lost Hope",
					["id"] = "22234:0:0",
					["old"] = "10228:0:1215",
				},
				[5] = {
					["name"] = "Cenarion Vestments",
					["id"] = "16833:913:0",
					["old"] = "12793:1892:0",
				},
				[6] = {
					["name"] = "Whipvine Cord",
					["id"] = "18327:0:0",
					["old"] = "20216:0:0",
				},
				[7] = {
					["name"] = "Padre's Trousers",
					["id"] = "18386:0:0",
					["old"] = "12963:0:0",
				},
				[8] = {
					["name"] = "Firemoss Boots",
					["id"] = "22275:929:0",
					["old"] = "20658:852:2149",
				},
				[9] = {
					["name"] = "Zandalar Haruspex's Bracers",
					["id"] = "19840:905:0",
					["old"] = "22108:927:0",
				},
				[10] = {
					["name"] = "Abyssal Cloth Handwraps of Restoration",
					["id"] = "20655:0:2146",
					["old"] = "19869:0:0",
				},
				[11] = {
					["name"] = "Primalist's Seal",
					["id"] = "19863:0:0",
					["old"] = "12002:0:947",
				},
				[12] = {
					["name"] = "Fordring's Seal",
					["id"] = "16058:0:0",
					["old"] = "18522:0:0",
				},
				[13] = {
					["name"] = "Royal Seal of Eldre'Thalas",
					["id"] = "18470:0:0",
					["old"] = "19120:0:0",
				},
				[14] = {
					["name"] = "Second Wind",
					["id"] = "11819:0:0",
					["old"] = "13965:0:0",
				},
				[15] = {
					["name"] = "Cloak of the Savior",
					["id"] = "21470:0:0",
					["old"] = "10071:0:604",
				},
				[16] = {
					["name"] = "Zulian Scepter of Rites",
					["id"] = "22713:0:0",
					["old"] = "18420:1896:0",
				},
				[17] = {
					["name"] = "Thaurissan's Royal Scepter",
					["id"] = "11928:0:0",
					["old"] = 0,
				},
				[18] = {
					["name"] = "Idol of Rejuvenation",
					["id"] = "22398:0:0",
					["old"] = "22397:0:0",
				},
				["key"] = "F12",
				["keyindex"] = 2,
				["icon"] = "Interface\\Icons\\Ability_DeathKnight_RemorselessWinters",
				["oldsetname"] = "DPS",
			},
		},
		["CurrentSet"] = "HealBot",
	},
	["Stormslinger of Warsong [12x] Blizzlike"] = {
		["Sets"] = {
			["Healbot-MaxMP5"] = {
				[1] = {
					["id"] = "18870:0:0",
					["name"] = "Helm of the Lifegiver",
				},
				[2] = {
					["id"] = "19303:0:0",
					["name"] = "Darkmoon Necklace",
				},
				[3] = {
					["id"] = "22234:0:0",
					["name"] = "Mantle of Lost Hope",
				},
				[5] = {
					["id"] = "10007:0:0",
					["name"] = "Red Mageweave Vest",
				},
				[6] = {
					["id"] = "18104:0:0",
					["name"] = "Feralsurge Girdle",
				},
				[7] = {
					["name"] = "Earthfury Legguards",
					["id"] = "16843:0:0",
					["old"] = "18682:0:0",
				},
				[8] = {
					["name"] = "Abyssal Mail Sabatons of Restoration",
					["id"] = "20656:0:2153",
					["old"] = "22275:0:0",
				},
				[9] = {
					["id"] = "22095:0:0",
					["name"] = "Bindings of The Five Thunders",
				},
				[10] = {
					["name"] = "Abyssal Mail Handguards of Restoration",
					["id"] = "20659:0:2153",
					["old"] = "12554:0:0",
				},
				[11] = {
					["id"] = "22257:0:0",
					["name"] = "Bloodclot Band",
				},
				[12] = {
					["id"] = "17110:0:0",
					["name"] = "Seal of the Archmagus",
				},
				[13] = {
					["id"] = "12930:0:0",
					["name"] = "Briarwood Reed",
				},
				[14] = {
					["id"] = "18371:0:0",
					["name"] = "Mindtap Talisman",
				},
				[15] = {
					["id"] = "11623:0:0",
					["name"] = "Spritecaster Cape",
				},
				[16] = {
					["id"] = "17105:0:0",
					["name"] = "Aurastone Hammer",
				},
				[17] = {
					["id"] = "22319:0:0",
					["name"] = "Tome of Divine Right",
				},
				[18] = {
					["id"] = "22395:0:0",
					["name"] = "Totem of Rage",
				},
				["oldsetname"] = "Healbot-MaxSP",
				["icon"] = "Interface\\Icons\\Ability_Druid_TreeofLife",
			},
			["Melee"] = {
				[1] = {
					["name"] = "Ghostshroud",
					["id"] = "11925:0:0",
					["old"] = "18870:0:0",
				},
				[2] = {
					["name"] = "Selenium Chain of the Eagle",
					["id"] = "12025:0:861",
					["old"] = "19303:0:0",
				},
				[3] = {
					["name"] = "Wyrmtongue Shoulders",
					["id"] = "13358:0:0",
					["old"] = "22234:0:0",
				},
				[5] = {
					["name"] = "Deathdealer Breastplate",
					["id"] = "11926:0:0",
					["old"] = "10007:0:0",
				},
				[6] = {
					["name"] = "Beaststalker's Belt",
					["id"] = "16680:0:0",
					["old"] = "18104:0:0",
				},
				[7] = {
					["name"] = "Leggings of Destruction",
					["id"] = "18524:0:0",
					["old"] = "16843:0:0",
				},
				[8] = {
					["name"] = "Abyssal Mail Sabatons of Striking",
					["id"] = "20656:0:2151",
					["old"] = "22275:0:0",
				},
				[9] = {
					["name"] = "Wristguards of Renown",
					["id"] = "22204:0:0",
					["old"] = "22095:0:0",
				},
				[10] = {
					["name"] = "Molten Fists",
					["id"] = "11814:0:0",
					["old"] = "12554:0:0",
				},
				[11] = {
					["name"] = "Seal of Sylvanas",
					["id"] = "6414:0:0",
					["old"] = "22257:0:0",
				},
				[12] = {
					["name"] = "Band of the Ogre King",
					["id"] = "18522:0:0",
					["old"] = "17110:0:0",
				},
				[14] = {
					["name"] = "Hand of Justice",
					["id"] = "11815:0:0",
					["old"] = "18371:0:0",
				},
				[15] = {
					["name"] = "Battlehard Cape",
					["id"] = "11858:0:0",
					["old"] = "11623:0:0",
				},
				[16] = {
					["name"] = "Willey's Back Scratcher",
					["id"] = "22404:0:0",
					["old"] = "17105:0:0",
				},
				[17] = {
					["name"] = "Observer's Shield",
					["id"] = "18485:0:0",
					["old"] = "22319:0:0",
				},
				[18] = {
					["id"] = "22395:0:0",
					["name"] = "Totem of Rage",
				},
				["key"] = "F9",
				["keyindex"] = 2,
				["icon"] = "Interface\\Icons\\Ability_DualWield",
				["oldsetname"] = "Healbot-MaxSP",
			},
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
			["Healbot-MaxSP"] = {
				[1] = {
					["id"] = "18870:0:0",
					["name"] = "Helm of the Lifegiver",
				},
				[2] = {
					["id"] = "19303:0:0",
					["name"] = "Darkmoon Necklace",
				},
				[3] = {
					["id"] = "18810:0:0",
					["name"] = "Wild Growth Spaulders",
				},
				[5] = {
					["id"] = "10007:0:0",
					["name"] = "Red Mageweave Vest",
				},
				[6] = {
					["id"] = "18104:0:0",
					["name"] = "Feralsurge Girdle",
				},
				[7] = {
					["id"] = "16843:0:0",
					["name"] = "Earthfury Legguards",
				},
				[8] = {
					["id"] = "22275:0:0",
					["name"] = "Firemoss Boots",
				},
				[9] = {
					["id"] = "22095:0:0",
					["name"] = "Bindings of The Five Thunders",
				},
				[10] = {
					["id"] = "12554:0:0",
					["name"] = "Hands of the Exalted Herald",
				},
				[11] = {
					["id"] = "22257:0:0",
					["name"] = "Bloodclot Band",
				},
				[12] = {
					["id"] = "17110:0:0",
					["name"] = "Seal of the Archmagus",
				},
				[13] = {
					["id"] = "12930:0:0",
					["name"] = "Briarwood Reed",
				},
				[14] = {
					["id"] = "18371:0:0",
					["name"] = "Mindtap Talisman",
				},
				[15] = {
					["id"] = "11623:0:0",
					["name"] = "Spritecaster Cape",
				},
				[16] = {
					["id"] = "17105:0:0",
					["name"] = "Aurastone Hammer",
				},
				[17] = {
					["id"] = "22319:0:0",
					["name"] = "Tome of Divine Right",
				},
				[18] = {
					["id"] = "22395:0:0",
					["name"] = "Totem of Rage",
				},
				["icon"] = "Interface\\Icons\\Ability_Druid_TreeofLife",
			},
		},
		["CurrentSet"] = "Healbot-MaxSP",
	},
	["Ryvok of Warsong [12x] Blizzlike"] = {
		["Sets"] = {
			["Ret"] = {
				[1] = {
					["name"] = "Ornate Mithril Helm",
					["id"] = "7937:0:0",
					["old"] = "22720:0:0",
				},
				[3] = {
					["name"] = "Lightforge Spaulders",
					["id"] = "16729:0:0",
					["old"] = "22234:0:0",
				},
				[5] = {
					["id"] = "18312:0:0",
					["name"] = "Energized Chestplate",
				},
				[6] = {
					["name"] = "Cord of Elements",
					["id"] = "16673:0:0",
					["old"] = "21500:0:0",
				},
				[7] = {
					["name"] = "Scarlet Leggings",
					["id"] = "10330:18:0",
					["old"] = "18386:0:0",
				},
				[8] = {
					["name"] = "Scarlet Boots",
					["id"] = "10332:0:0",
					["old"] = "22275:0:0",
				},
				[9] = {
					["name"] = "Bracers of Valor",
					["id"] = "16735:0:0",
					["old"] = "16671:66:0",
				},
				[10] = {
					["name"] = "Molten Fists",
					["id"] = "11814:0:0",
					["old"] = "19123:0:0",
				},
				[11] = {
					["id"] = "11992:0:778",
					["name"] = "Vermilion Band of the Owl",
				},
				[12] = {
					["id"] = "11669:0:0",
					["name"] = "Naglering",
				},
				[15] = {
					["id"] = "9838:0:1187",
					["name"] = "Banded Cloak of the Bear",
				},
				[16] = {
					["name"] = "Twig of the World Tree",
					["id"] = "13047:0:0",
					["old"] = "22713:0:0",
				},
				["oldsetname"] = "Holy",
				[17] = {
					["id"] = 0,
				},
				["icon"] = "Interface\\Icons\\Ability_Paladin_SanctifiedWrath",
			},
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
			["Holy"] = {
				[1] = {
					["name"] = "Zulian Headdress",
					["id"] = "22720:0:0",
					["old"] = "7937:0:0",
				},
				[2] = {
					["id"] = "18723:0:0",
					["name"] = "Animated Chain Necklace",
				},
				[3] = {
					["name"] = "Mantle of Lost Hope",
					["id"] = "22234:0:0",
					["old"] = "16729:0:0",
				},
				[5] = {
					["id"] = "18312:0:0",
					["name"] = "Energized Chestplate",
				},
				[6] = {
					["name"] = "Belt of the Inquisition",
					["id"] = "21500:0:0",
					["old"] = "16673:0:0",
				},
				[7] = {
					["name"] = "Padre's Trousers",
					["id"] = "18386:0:0",
					["old"] = "10330:18:0",
				},
				[8] = {
					["name"] = "Firemoss Boots",
					["id"] = "22275:0:0",
					["old"] = "10332:0:0",
				},
				[9] = {
					["name"] = "Bindings of Elements",
					["id"] = "16671:66:0",
					["old"] = "16735:0:0",
				},
				[10] = {
					["name"] = "Everwarm Handwraps",
					["id"] = "19123:0:0",
					["old"] = "11814:0:0",
				},
				[11] = {
					["id"] = "11992:0:778",
					["name"] = "Vermilion Band of the Owl",
				},
				[15] = {
					["id"] = "9838:0:1187",
					["name"] = "Banded Cloak of the Bear",
				},
				[16] = {
					["name"] = "Zulian Scepter of Rites",
					["id"] = "22713:0:0",
					["old"] = "13047:0:0",
				},
				["oldsetname"] = "Ret",
				[17] = {
					["name"] = "Tome of Divine Right",
					["id"] = "22319:0:0",
					["old"] = 0,
				},
				["icon"] = "Interface\\Icons\\Ability_Vehicle_ShellShieldGenerator",
			},
		},
		["CurrentSet"] = "Ret",
	},
	["Nameplate of Emerald Dream [1x] Blizzlike"] = {
		["Sets"] = {
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
		},
	},
	["Banjax of Warsong [12x] Blizzlike"] = {
		["Sets"] = {
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
		},
	},
	["Sixofnine of Warsong [12x] Blizzlike"] = {
		["Sets"] = {
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
		},
	},
	["Ryvok of Emerald Dream [1x] Blizzlike"] = {
		["Sets"] = {
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
		},
	},
	["Zapunzel of Warsong [12x] Blizzlike"] = {
		["Sets"] = {
			["Frost"] = {
				[1] = {
					["name"] = "Bonecaster's Crown of Frozen Wrath",
					["id"] = "14307:0:1976",
					["old"] = "10041:0:0",
				},
				[2] = {
					["id"] = "22403:0:0",
					["name"] = "Diana's Pearl Necklace",
				},
				[3] = {
					["id"] = "13185:0:0",
					["name"] = "Sunderseer Mantle",
				},
				[5] = {
					["name"] = "Frostweave Tunic",
					["id"] = "13869:0:0",
					["old"] = "10021:0:0",
				},
				[6] = {
					["id"] = "16685:0:0",
					["name"] = "Magister's Belt",
				},
				[7] = {
					["name"] = "Frostweave Pants",
					["id"] = "13871:0:0",
					["old"] = "10009:0:0",
				},
				[8] = {
					["id"] = "20652:0:2143",
					["name"] = "Abyssal Cloth Slippers of Sorcery",
				},
				[9] = {
					["id"] = "18497:0:0",
					["name"] = "Sublime Wristguards",
				},
				[10] = {
					["name"] = "Frostweave Gloves",
					["id"] = "13870:0:0",
					["old"] = "10019:0:0",
				},
				[11] = {
					["id"] = "12038:0:0",
					["name"] = "Lagrave's Seal",
				},
				[12] = {
					["id"] = "12001:0:943",
					["name"] = "Onyx Ring of the Gorilla",
				},
				[13] = {
					["id"] = "11819:0:0",
					["name"] = "Second Wind",
				},
				[14] = {
					["id"] = "18468:0:0",
					["name"] = "Royal Seal of Eldre'Thalas",
				},
				[15] = {
					["id"] = "10212:0:1963",
					["name"] = "Elegant Cloak of Frozen Wrath",
				},
				[16] = {
					["id"] = "20258:0:0",
					["name"] = "Zulian Ceremonial Staff",
				},
				[18] = {
					["id"] = "15280:0:936",
					["name"] = "Wizard's Hand of the Gorilla",
				},
				["icon"] = "Interface\\Icons\\Ability_Hunter_GlacialTrap",
				["oldsetname"] = "General",
			},
			["General"] = {
				[1] = {
					["name"] = "Dreamweave Circlet",
					["id"] = "10041:0:0",
					["old"] = "14307:0:1976",
				},
				[2] = {
					["id"] = "22403:0:0",
					["name"] = "Diana's Pearl Necklace",
				},
				[3] = {
					["id"] = "13185:0:0",
					["name"] = "Sunderseer Mantle",
				},
				[5] = {
					["name"] = "Dreamweave Vest",
					["id"] = "10021:0:0",
					["old"] = "13869:0:0",
				},
				[6] = {
					["id"] = "16685:0:0",
					["name"] = "Magister's Belt",
				},
				[7] = {
					["name"] = "Red Mageweave Pants",
					["id"] = "10009:0:0",
					["old"] = "13871:0:0",
				},
				[8] = {
					["id"] = "20652:0:2143",
					["name"] = "Abyssal Cloth Slippers of Sorcery",
				},
				[9] = {
					["id"] = "18497:0:0",
					["name"] = "Sublime Wristguards",
				},
				[10] = {
					["name"] = "Dreamweave Gloves",
					["id"] = "10019:0:0",
					["old"] = "13870:0:0",
				},
				[11] = {
					["id"] = "12038:0:0",
					["name"] = "Lagrave's Seal",
				},
				[12] = {
					["id"] = "12001:0:943",
					["name"] = "Onyx Ring of the Gorilla",
				},
				[13] = {
					["id"] = "11819:0:0",
					["name"] = "Second Wind",
				},
				[14] = {
					["id"] = "18468:0:0",
					["name"] = "Royal Seal of Eldre'Thalas",
				},
				[15] = {
					["id"] = "10212:0:1963",
					["name"] = "Elegant Cloak of Frozen Wrath",
				},
				[16] = {
					["id"] = "20258:0:0",
					["name"] = "Zulian Ceremonial Staff",
				},
				[18] = {
					["id"] = "15280:0:936",
					["name"] = "Wizard's Hand of the Gorilla",
				},
				["icon"] = "Interface\\Icons\\Ability_Mage_ArcaneBarrage",
				["oldsetname"] = "Frost",
			},
			["Rack-CombatQueue"] = {
				[1] = {
				},
				[2] = {
				},
				[3] = {
				},
				[4] = {
				},
				[5] = {
				},
				[6] = {
				},
				[7] = {
				},
				[8] = {
				},
				[9] = {
				},
				[10] = {
				},
				[11] = {
				},
				[12] = {
				},
				[13] = {
				},
				[14] = {
				},
				[15] = {
				},
				[16] = {
				},
				[17] = {
				},
				[18] = {
				},
				[19] = {
				},
				[0] = {
				},
			},
			["Nekkid"] = {
				[1] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "14307:0:1976",
				},
				[2] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "22403:0:0",
				},
				[3] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "4734:0:0",
				},
				[5] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "13869:0:0",
				},
				[6] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "16685:0:0",
				},
				[7] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "13871:0:0",
				},
				[8] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "20652:0:2143",
				},
				[9] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "18497:0:0",
				},
				[10] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "13870:0:0",
				},
				[11] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "12038:0:0",
				},
				[12] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "12001:0:943",
				},
				[13] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "12846:0:0",
				},
				[14] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "12846:0:0",
				},
				[15] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "10212:0:1963",
				},
				[16] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "20258:0:0",
				},
				[17] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "7611:0:0",
				},
				[18] = {
					["name"] = "(empty)",
					["id"] = 0,
					["old"] = "15280:0:936",
				},
				["oldsetname"] = "Frost",
				["icon"] = "Interface\\Icons\\Ability_Kick",
			},
		},
		["CurrentSet"] = "Frost",
	},
}
