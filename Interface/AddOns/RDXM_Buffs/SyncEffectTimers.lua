-- SyncEffectTimers.lua
-- RDX5 - Raid Data Exchange
--
-- Synchronization code and protocol for effect timers.
VFL.debug("[RDX5] Loading SyncEffectTimers.lua", 2);

-- Player effect timers
RDX.pets = {};

-------------------------
-- UNIT EFFECT TIMER DATA
-------------------------
-- Set this unit's effect timers
function RDX.Unit:SetEffectTimers(fxt)
	self.fxTimers = fxt;
	self.fxTimersDirty = true;
	self.fxTimersTime = GetTime();
end

-- Realtime effect timer updates
function RDX.Unit:PartialSetEffectTimers(fxt)
	for k,v in fxt do self.fxTimers[k] = v; end
	self.fxTimersDirty = true;
end

-- Check if the effect timers are up to date
function RDX.Unit:EffectTimersStale()
	if not self.fxTimers then return true; end
	if ((GetTime() - self.fxTimersTime) < 20) then return false; else return true; end
end

-- Get time on effect
function RDX.Unit:EffectTime(eid, default)
	if (not self.fxTimers) or (not self.fxTimers[eid]) then return default; else return self.fxTimers[eid]; end
end

-- Remove time on effect
function RDX.Unit:RemoveEffectTime(eid)
	if(self.fxTimers) then self.fxTimers[eid] = nil; end
end

-- Reset time on effect
function RDX.Unit:ResetEffectTime(eid, val)
	if(self.fxTimers) and (self.fxTimers[eid]) then
		self.fxTimers[eid] = val;
	end
end

--------------------------------------
-- EFFECT TIMER SYNC IMPLEMENTATION
--------------------------------------
-- Iterate through the player's buffs, converting to effects and
-- deriving the timers.
function RDX.Sync.ComputeEffectTimers()
	RDX.pets = {};
	-- Iterate over player buffs
	for i=0,24 do
		local time,bn,fx,idx = 0,nil,nil,GetPlayerBuff(i, "HELPFUL|HARMFUL|PASSIVE");
		if(idx > -1) then
			VFLTipTextLeft1:SetText(nil);
			VFLTip:SetPlayerBuff(idx);
			bn = VFLTipTextLeft1:GetText();
		end
		if bn then
			fx = RDX.GetEffectFromBuffName(string.lower(bn));
			time = GetPlayerBuffTimeLeft(idx);
			if fx and (time>0) then
				RDX.pets[fx.id] = math.floor(time);
			end
		end
	end
end

-- Encode a table of effect timers into a string for dispatch across chat channel.
function RDX.Sync.EncodeEffectTimers(et)
	local str = "";
	for k,v in et do
		str = str .. k .. "~" .. v .. "&";
	end
	return str;
end

function RDX.Sync.DecodeEffectTimers(str)
	local tbl = {};
	while true do
		-- Find the pattern; escape if not found
		local s,e,k,v = string.find(str, "(%d+)~(%d+)&");
		if not s then break; end
		-- Add the decoded k/v pair to the table
		tbl[tonumber(k)] = tonumber(v);
		-- Slurp consumed data
		str = string.sub(str, e+1, -1);
	end
	return tbl;
end

-- Decode an effect-timer bundle
function RDX.Sync.ETProtoHandler(proto, sender, data)
	sender:SetEffectTimers(RDX.Sync.DecodeEffectTimers(data));
	RDX.SigUnitEffectTimersUpdated:Raise(sender);
end
function RDX.Sync.ETRProtoHandler(proto, sender, data)
	sender:PartialSetEffectTimers(RDX.Sync.DecodeEffectTimers(data));
	RDX.SigUnitEffectTimersUpdated:Raise(sender);
end

-- Recurring event to update effect timers
function RDX.Sync.ETPeriodic()
	if(RDXU.active) then
		RDX.Sync.ComputeEffectTimers();
		if(table.getn(RDX.pets) > 0) then
			RDX.EnqueueMessage(Proto_ET, RDX.Sync.EncodeEffectTimers(RDX.pets));
		end
	end
	VFL.schedule(RDXG.perf.bAuraTimerSyncDelay, RDX.Sync.ETPeriodic);
end

-- The effect-timer signals
RDX.SigUnitEffectTimersUpdated = VFL.Signal:new();

-----------------------------
-- EVENT RESPONSE
-- Whenever a unit gains a buff, we should remove his timer
-- for that buff (because it will be out of whack)
-----------------------------
function RDX.Sync.OnUnitEffectsDirty(u)
	if not u.fxTimers then return; end
	for k,v in u.flagsets[4].flags do if (v.dirty) and (v.value) then
		u.fxTimers[k] = nil;
	end end
end
RDX.SigUnitFlagsDirty[4]:Connect(nil, RDX.Sync.OnUnitEffectsDirty);

-- Register the effect-timer sync protocols
Proto_ET = RDX.RegisterProtocol({
	id = 1; name = "Effect Timers";
	replace = true; -- Replace any preexisting messages on requeue
	highPrio = false; -- Not high-priority
	realtime = false; -- Not realtime
	handler = RDX.Sync.ETProtoHandler;
});
Proto_RET = RDX.RegisterProtocol({
	id = 2; name = "Effect Timers (Realtime)";
	replace = false; highPrio = false; realtime = true;
	handler = RDX.Sync.ETRProtoHandler;
});
