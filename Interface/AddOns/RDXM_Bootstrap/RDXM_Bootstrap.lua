if not RDXM.Bootstrap then RDXM.Bootstrap = {}; end

----------------------------
-- BOOTSTRAP FUNCTIONALITY
----------------------------
function RDXM.Bootstrap.CheckBootstrap()
	if(not RDX5Data.Bootstrap) then 
		return false; 
	else 
		return true; 
	end
end

function RDXM.Bootstrap.RunBootstrap()
	if not RDXM.Bootstrap.CheckBootstrap() then return; end
	for k,v in pairs(RDX5Data.Bootstrap) do 
		RunScript(v); 
	end
end

function RDXM.Bootstrap.ClearBootstrap()
	RDX5Data.Bootstrap = nil;
end

function RDXM.Bootstrap.AddBootstrap(name, code)
	if not RDX5Data.Bootstrap then 
		RDX5Data.Bootstrap = {}; 
	end
	RDX5Data.Bootstrap[name] = code;
end

function RDXM.Bootstrap.RemoveBootstrap(name)
	RDX5Data.Bootstrap[name] = nil;
end

function RDXM.Bootstrap.GetBootstrap(name)
	if (not RDX5Data.Bootstrap) then
		return nil;
	end
	return RDX5Data.Bootstrap[name];
end

function RDXM.Bootstrap.GetBootstraps()
	if (RDX5Data.Bootstrap) then
		return pairs(RDX5Data.Bootstrap);
	end
	return {};
end

----------------------------
-- EDITOR FUNCTIONALITY
----------------------------
RDXM.Bootstrap.CurrentScript = nil;

function RDXM.Bootstrap.CommitScriptChanges()
	if (RDXM.Bootstrap.CurrentScript) then
		local code = RDXM_ScriptEditBox:GetText();
		local reloadui;
		if VFL.CC.Chk_Get(RDXM_ScriptEditFrameReloadUICheck) then
			reloadui = "reloadui";
		else
			reloadui = "noreloadui";
		end
		RDXM.Bootstrap.SendPatch(code, RDXM.Bootstrap.CurrentScript, reloadui)
	end
end

function RDXM.Bootstrap.EditScript(str)
	local name = string.lower(str);
	RDXM.Bootstrap.CurrentScript = name;
	local script = RDXM.Bootstrap.GetBootstrap(name);
	if (script) then
		RDXM_ScriptEditBox:SetText(script);
	else
		RDXM_ScriptEditBox:SetText("");
	end
	RDXM_ScriptEditFrame:Show();
end

function RDXM.Bootstrap.DeleteScript()
	RDXM.Bootstrap.RemoveBootstrap(RDXM.Bootstrap.CurrentScript);
end

-- New Script creation
function RDXM.Bootstrap.NewScript()
	-- Pop up a name prompt
	VFL.CC.Popup(RDXM.Bootstrap.NewScriptCallback, "New Script", "Enter the name of the new script", "");
end

function RDXM.Bootstrap.NewScriptCallback(flg, name)
	-- They clicked " cancel", just ignore
	if not flg then return; end
	-- Ignore invalid names
	if not VFL.isValidName(name) then return; end
	local title = name; name = string.lower(name);
	-- Ignore preexisting names
	if RDXM.Bootstrap.GetBootstrap(name) then return; end
	-- OK, create the script
	RDXM.Bootstrap.EditScript(name);
end

function RDXM.Bootstrap.Menu(module, tree, frame)
	local mnu = {};

	table.insert(mnu, { text = "New Script...", OnClick = function() tree:Release(); RDXM.Bootstrap.NewScript(); end });
	table.insert(mnu, { text = "Request Trust", OnClick = function() tree:Release(); RPC.Invoke("rdx_requesttrust"); end });
	table.insert(mnu, { text = "Clear Trusts", OnClick = function() tree:Release(); RDX5Data.TrustedBootstrapSources = {}; end });
	for k,v in RDXM.Bootstrap.GetBootstraps() do
		local dname = k;
		table.insert(mnu, {
			text = k,
			isSubmenu = true,
			OnClick = function() RDXM.Bootstrap.ScriptMenu(tree, this, dname); end
		});
	end
	-- Display menu
	tree:Expand(frame, mnu);
end

-- Per-window menu
function RDXM.Bootstrap.ScriptMenu(tree, frame, dname)


	local mnu = {};
	-- Edit
	table.insert(mnu, { text = "Edit", OnClick = function() RDXM.Bootstrap.EditScript(dname); tree:Release(); end });
	-- Delete
	table.insert(mnu, { text = "Delete", 
			OnClick = function() 		
					VFL.CC.Popup(function(arg) if arg then RDXM.Bootstrap.RemoveBootstrap(dname); end; end,
						"RDX Patch: "..dname, 
						"Are you sure you want to delete the update for RDX: \""..dname.."\". Press 'ok' to delete, or 'cancel' to leave it. NOTE: Changes do not take effect until the UI is reloaded.");
						tree:Release(); end });
	tree:Expand(frame, mnu);
end

----------------------------------------------
-- REMOTE UPDATE FUNCTIONS (ADD TO BOOTSTRAP)
----------------------------------------------

function RDXM.Bootstrap.SendPatch(code, name, reloadui)
	VFL.print("Sending patch '"..name.."'. Estimated upload time: "..math.floor(strlen(code)/200)+1 .." seconds.")
	local codex
	local msg
	if not name then
		name = "No Name"
	end
	local patch = { name, code, reloadui };
	RPC.Invoke("rdx_patchreceived", patch);
end

function RDXM.Bootstrap.ApplyPatch(name, code, reloadui)
	RDXM.Bootstrap.SendToBootStrap(name, code);
	if not string.find(reloadui, "noreloadui") then
		VFL.CC.Popup(function() ReloadUI() end,
			"RDX Update: "..name, 
			"You have received an update for RDX that requires you to restart. It doesn't matter what you click, it's going to happen!"
		);
	end
end

function RDXM.Bootstrap.PatcherCallback(name, code, reloadui)
	local ret = function (dlgresult, text)
			if (dlgresult) then
				RDXM.Bootstrap.ApplyPatch(name, code, reloadui);
			end
		end

	return ret;
end

function RDXM.Bootstrap.PatchReceived(sender, patch)
	local name = patch[1];
	local code = patch[2];
	local reloadui = patch[3];
	if RDXM.Bootstrap.IsUniqueUpdate(code) == true then
		if RDX5Data.TrustedBootstrapSources then
			if RDX5Data.TrustedBootstrapSources[sender.name] then
				RDXM.Bootstrap.ApplyPatch(name, code, reloadui);
				return;
			end
		end				
		VFL.CC.Popup(RDXM.Bootstrap.PatcherCallback(name, code, reloadui),
			"RDX Update: "..name, 
			sender.name.." has sent you an update for RDX: \""..name.."\". Press 'ok' to install, or 'cancel' to disregard it. NOTE: Changes now take effect immediately"
		);
	end
end
RPC.Bind("rdx_patchreceived", RDXM.Bootstrap.PatchReceived);

function RDXM.Bootstrap.TrustRequestReceived(sender)
	if not RDX5Data.TrustedBootstrapSources then
		RDX5Data.TrustedBootstrapSources = {};
	end

	VFL.CC.Popup(function(dlgresult, text) if (dlgresult) then RDX5Data.TrustedBootstrapSources[sender.name] = 1; end; end,
		"RDX Trust Request: "..sender:GetProperName(), 
		sender:GetProperName().." asked to become a trusted Bootstrap Source. Press 'ok' to accept, or 'cancel' to decline."
	);
end
RPC.Bind("rdx_requesttrust", RDXM.Bootstrap.TrustRequestReceived);

-- Boolean function to see if you already have the update
function RDXM.Bootstrap.IsUniqueUpdate(code)
	if RDXM.Bootstrap.CheckBootstrap() then
		for k,v in pairs(RDX5Data.Bootstrap) do
			if code == v then
				return false;
			end;
		end;
	end
	return true;
end;

function RDXM.Bootstrap.SendToBootStrap(name, code)
	RDX.ChatMessage(RDX.ccn, "Installed update: "..name)
	RDXM.Bootstrap.AddBootstrap(name, code)
	RunScript(code);
end


----------------------------------------------
-- INIT FUNCTIONS
----------------------------------------------

function RDXM.Bootstrap.Init()
	if RDXM.Bootstrap.CheckBootstrap() then
		if RDX5Data.BootstrapVer == RDX.CurrentVersion then	
			RDXM.Bootstrap.RunBootstrap()
		else
			RDXM.Bootstrap.ClearBootstrap()
			RDX5Data.BootstrapVer = RDX.CurrentVersion
		end
	else
		RDX5Data.BootstrapVer = RDX.CurrentVersion
		RDX5Data.Bootstrap = {}
		RDX5Data.TrustedBootstrapSources = {}
	end
end
RDXEvent:Bind("VARIABLES_LOADED", nil, function() VFL.schedule(1, function() RDXM.Bootstrap.Init(); end); end);

-- Register the module
RDXM.Bootstrap.module = RDX.RegisterModule({
	name = "bootstrap";
	title = "Bootstrap";
	Menu = RDXM.Bootstrap.Menu;
});
