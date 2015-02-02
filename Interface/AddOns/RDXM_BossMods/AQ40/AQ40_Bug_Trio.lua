--------------------------------------
-- Bug Trio
--------------------------------------
local princess_fear_lock = nil;
local princess_heal_lock = nil;

function RDXM.AQ.BugTrioActivate()

	princess_fear_lock = false;
	princess_heal_lock = false;

	-- Events
	VFLEvent:NamedBind("bugtrio", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE"), function() RDXM.AQ.BugTrioPossibleFear(arg1); end);
	VFLEvent:NamedBind("bugtrio", BlizzEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"), function() RDXM.AQ.BugTrioPossibleHeal(arg1); end);

	-- RPC Binds
	RPC.Bind("bugtrio_princessfear", RDXM.AQ.BugTrio_RPC_PrincessFear);
	RPC.Bind("bugtrio_princessheal", RDXM.AQ.BugTrio_RPC_PrincessHeal);
	
end

function RDXM.AQ.BugTrioDeactivate()

	-- Unbind Events
	VFLEvent:NamedUnbind("bugtrio");
	-- Unbind RPCs
	RPC.UnbindPattern("^bugtrio_");
	
	--qualch any stuffs
	RDX.QuashAlertsByPattern("^bugtrio_")
	
end

function RDXM.AQ.BugTrioStop()

	RDX.QuashAlertsByPattern("^bugtrio_")
	
end

function RDXM.AQ.BugTrioStart()

end


function RDXM.AQ.BugTrioPossibleFear(chatMsg)

	if princess_fear_lock == false then
		if chatMsg ~= nil then
			if string.find(chatMsg, "Fear") then
				RPC.Invoke("bugtrio_princessfear");
			end
		end
	end
	
end

function RDXM.AQ.BugTrioPossibleHeal(chatMsg)

	if princess_heal_lock == false then
		if chatMsg ~= nil then
			if string.find(chatMsg, "Princess Yauj begins to cast Great") then
				RPC.Invoke("bugtrio_princessheal");
			end
		end
	end
	
end

function RDXM.AQ.BugTrio_RPC_PrincessFear()

	--fear timer
	if princess_fear_lock == false then
		princess_fear_lock = true;
		VFL.schedule(10, function() princess_fear_lock = false; end);
		RDX.Alert.Dropdown("bugtrio_princessfear", "Next Fear", 20, 5, nil);
	end

end

function RDXM.AQ.BugTrio_RPC_PrincessHeal()

	--heal timer
	if princess_heal_lock == false then
		princess_heal_lock = true;
		VFL.schedule(7, function() princess_heal_lock = false; end);
		RDX.Alert.Dropdown("bugtrio_princesshealing", "Heal - INTERUPT!!!", 4, 4, "Sound\\Doodad\\BellTollAlliance.wav", {r=.1, g=.45, b=.8},{r=.1, g=.45, b=.8});
	end

end


RDXM.AQ.enctbl["bugtrio"] = {
	ActivateEncounter = RDXM.AQ.BugTrioActivate;
	DeactivateEncounter = RDXM.AQ.BugTrioDeactivate;
	StartEncounter = RDXM.AQ.BugTrioStart;
	StopEncounter = RDXM.AQ.BugTrioStop;
};