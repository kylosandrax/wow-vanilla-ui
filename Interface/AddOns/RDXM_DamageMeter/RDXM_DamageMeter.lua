if not RDXM.DamageMeter then RDXM.DamageMeter = {}; end

RDXM.DamageMeter.ResetOnCombat = true;
RDXM.DamageMeter.CombatStart = nil;
RDXM.DamageMeter.MinSaveTimer = 1;

function RDXM.DamageMeter.Init()
end

function RDXM.DamageMeter.EnterCombat()
	VFL.schedule(1, 
		function() 
			-- reset if we're supposed to
			if RDXM.DamageMeter.ResetOnCombat and IsRaidLeader() and RDX.EncounterIsRunning() then
				VFL.print("Resetting SWStats.");
				SW_SyncReset();
			end
		end
	);
end

function RDXM.DamageMeter.LeaveCombat()
	if RDX.GetEncounterRunningTime() > RDXM.DamageMeter.MinSaveTimer then
		VFL.print("Saving Damage Meter: " .. RDX.GetActiveEncounterTitle() .. ".");
		-- save the DM if the time in combat
		local stats = { RDX.GetActiveEncounterTitle(), 
				RDXM.DamageMeter.TableCopy(SW_S_Details), 
				RDXM.DamageMeter.TableCopy(SW_S_Healed), 
				RDXM.DamageMeter.TableCopy(SW_S_SpellInfo), 
				RDXM.DamageMeter.TableCopy(SW_S_ManaUsage), 
				RDXM.DamageMeter.TableCopy(SW_PetInfo), 
				};
		if not RDX5Data.SavedSWStats then
			RDX5Data.SavedSWStats = {};
		end
		tinsert(RDX5Data.SavedSWStats, stats);
	end
end


function RDXM.DamageMeter.Menu(module, tree, frame)
	if RDX5Data.SavedSWStats then
		local mnu = {};
		if RDXM.DamageMeter.ResetOnCombat then
			table.insert(mnu, { text = "Auto Reset Off", OnClick = function() tree:Release(); RDXM.DamageMeter.ResetOnCombat = false; end });
		else
			table.insert(mnu, { text = "Auto Reset On", OnClick = function() tree:Release(); RDXM.DamageMeter.ResetOnCombat = true; end });
		end
		table.insert(mnu, { text = "Clear All", OnClick = function() tree:Release(); RDX5Data.SavedSWStats = {}; end });
		for i=1, table.getn(RDX5Data.SavedSWStats) do
			local index = i;
			table.insert(mnu, {
				text = RDX5Data.SavedSWStats[i][1],
				isSubmenu = true,
				OnClick = function() RDXM.DamageMeter.MeterMenu(tree, this, index); end
			});
		end
		-- Display menu
		tree:Expand(frame, mnu);
	end
end

-- Per-window menu
function RDXM.DamageMeter.MeterMenu(tree, frame, index)
	local mnu = {};
	-- Edit
	table.insert(mnu, { text = "View", OnClick = function() RDXM.DamageMeter.ViewMeter(index); tree:Release(); end });
	-- Delete
	table.insert(mnu, { text = "Delete", 
			OnClick = function() table.remove(RDX5Data.SavedSWStats, index); tree:Release(); end });
	tree:Expand(frame, mnu);
end

function RDXM.DamageMeter.ViewMeter(index)
	-- get out of the sync channel
	if SW_Settings["SYNCLastChan"] ~= nil then
		LeaveChannelByName(SW_Settings["SYNCLastChan"]);
		SW_Settings["SYNCLastChan"] = nil;
	end

	SW_ToggleRunning(false);

	SW_S_Details = RDXM.DamageMeter.TableCopy(RDX5Data.SavedSWStats[index][2]);
	SW_S_Healed = RDXM.DamageMeter.TableCopy(RDX5Data.SavedSWStats[index][3]);
	SW_S_SpellInfo = RDXM.DamageMeter.TableCopy(RDX5Data.SavedSWStats[index][4]);
	SW_S_ManaUsage = RDXM.DamageMeter.TableCopy(RDX5Data.SavedSWStats[index][5]); 
	SW_PetInfo = RDXM.DamageMeter.TableCopy(RDX5Data.SavedSWStats[index][6]);
end

function RDXM.DamageMeter.TableCopy(t)
	local ret = {};
	for k, v in pairs(t) do
		if type(v) ~= "table" then
			ret[k] = v;
		else
			ret[k] = RDXM.DamageMeter.TableCopy(v);
		end
	end
	return ret;
end

RDXEvent:Bind("VARIABLES_LOADED", nil, function() VFL.schedule(5, function() RDXM.DamageMeter.Init(); end); end);
VFLEvent:NamedBind("damage_meter_combat", BlizzEvent("PLAYER_REGEN_DISABLED"), function() RDXM.DamageMeter.EnterCombat(); end);
VFLEvent:NamedBind("damage_meter_combat", BlizzEvent("PLAYER_REGEN_ENABLED"), function() RDXM.DamageMeter.LeaveCombat(); end);

-- Register the module
RDXM.DamageMeter.module = RDX.RegisterModule({
	name = "damagemeter";
	title = "Damage Meter";
	Menu = RDXM.DamageMeter.Menu;
});