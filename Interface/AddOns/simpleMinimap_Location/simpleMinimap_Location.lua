simpleMinimap_Location = simpleMinimap:NewModule("location")
local L = AceLibrary("AceLocale-2.1"):GetInstance("simpleMinimap_Location", true)
--
function simpleMinimap_Location:OnInitialize()
	self.db = simpleMinimap:AcquireDBNamespace("location")
	self.positions = {
		{ "BOTTOM", "BOTTOM" },
		{ "TOP", "BOTTOM" },
		{ "TOP", "TOP" },
		{ "BOTTOM", "TOP" },
		{ "TOPLEFT", "TOPLEFT" },
		{ "BOTTOMLEFT", "BOTTOMLEFT" },
		{ "TOPRIGHT", "TOPRIGHT" },
		{ "BOTTOMRIGHT", "BOTTOMRIGHT" }
	}
	
	self.defaults = { enabled=true, position=4, backdrop=false, border=false, scale=0.95, alpha=1.0, fontR=0.819, fontG=0.819, fontB=0.819, time=1 }
	self.options = {
		type="group", name=L.location, desc=L.location_desc,
		args={
			title={
				type="header", order=1, name="simpleMinimap |cFFFFFFCC"..L.location
			},
			spacer1={
				type="header", order=2
			},
			enabled={
				type="toggle", order=3, name=L.enabled, desc=L.enabled_desc,
				get=function() return(self.db.profile.enabled) end,
				set=function(x) self.db.profile.enabled=x simpleMinimap:ToggleModuleActive(self,x) end
			},
			spacer2={
				type="header", order=4, name="---"
			},
			alpha={
				type="range", order=10, name=L.alpha, desc=L.alpha_desc,
				min=0, max=1, step=0.05, isPercent=true,
				get=function() return(self.db.profile.alpha) end,
				set=function(x) self.db.profile.alpha=x self:UpdateScreen() end
			},
			backdrop={
				type="toggle", order=11, name=L.backdrop, desc=L.backdrop_desc,
				get=function() return(self.db.profile.backdrop) end,
				set=function(x) self.db.profile.backdrop=x self:UpdateScreen() end
			},
			border={
				type="toggle", order=12, name=L.border, desc=L.border_desc,
				get=function() return(self.db.profile.border) end,
				set=function(x) self.db.profile.border=x self:UpdateScreen() end
			},
			fontColor={
				type="color", order=13, name=L.fontColor, desc=L.fontColor_desc,
				get = function() return self.db.profile.fontR, self.db.profile.fontG, self.db.profile.fontB end,
				set = function(r, g, b) self.db.profile.fontR=r self.db.profile.fontG=g self.db.profile.fontB=b self:UpdateScreen() end
			},
			position = {
				type="group", order=14, name=L.position, desc=L.position_desc,
				args = {
					["1"]={
						type="toggle", order=1, name=L.position1, desc=L.position1_desc,
						get=function() return(self.db.profile.position==1) end,
						set=function() self.db.profile.position=1 self:UpdateScreen() end
					},
					["2"]={
						type="toggle", order=2, name=L.position2, desc=L.position2_desc,
						get=function() return(self.db.profile.position==2) end,
						set=function() self.db.profile.position=2 self:UpdateScreen() end
					},
					["3"]={
						type="toggle", order=3, name=L.position3, desc=L.position3_desc,
						get=function() return(self.db.profile.position==3) end,
						set=function() self.db.profile.position=3 self:UpdateScreen() end
					},
					["4"]={
						type="toggle", order=4, name=L.position4, desc=L.position4_desc,
						get=function() return(self.db.profile.position==4) end,
						set=function() self.db.profile.position=4 self:UpdateScreen() end
					},
					["5"]={
						type="toggle", order=5, name=L.position5, desc=L.position5_desc,
						get=function() return(self.db.profile.position==5) end,
						set=function() self.db.profile.position=5 self:UpdateScreen() end
					},
					["6"]={
						type="toggle", order=6, name=L.position6, desc=L.position6_desc,
						get=function() return(self.db.profile.position==6) end,
						set=function() self.db.profile.position=6 self:UpdateScreen() end
					},
					["7"]={
						type="toggle", order=7, name = L.position7, desc = L.position7_desc,
						get=function() return(self.db.profile.position==7) end,
						set=function() self.db.profile.position=7 self:UpdateScreen() end
					},
					["8"]={
						type="toggle", order=8, name=L.position8, desc=L.position8_desc,
						get=function() return(self.db.profile.position==8) end,
						set=function() self.db.profile.position=8 self:UpdateScreen() end
					}
				}
			},
			scale={
				type="range", order=15, name=L.scale, desc=L.scale_desc,
				min=0.5, max=2, step=0.05,
				get=function() return(self.db.profile.scale) end,
				set=function(x) self.db.profile.scale=x self:UpdateScreen() end
			},
			time={
				type="range", order=16, name=L.time, desc=L.time_desc,
				min=0, max=5, step=1,
				get=function() return(self.db.profile.time) end,
				set=function(x) self.db.profile.time=x self:UpdateEvent() end
			},
		}
	}
	simpleMinimap.options.args.modules.args.location = self.options
	simpleMinimap:RegisterDefaults("location", "profile", self.defaults)
	smmLocationFrameText:SetText("Location unknown")
	smmLocationFrame:SetWidth(smmLocationFrameText:GetWidth() + 16)
	smmLocationFrame:SetHeight(smmLocationFrameText:GetHeight() + 12)
end
--
function simpleMinimap_Location:OnEnable()
	if(self.db.profile.enabled) then
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:UpdateEvent()
		self:UpdateScreen()
	else
		simpleMinimap:ToggleModuleActive(self, false)
	end
end
--
function simpleMinimap_Location:OnDisable()
	self:CancelAllScheduledEvents()
	smmLocationFrame:SetScript("OnUpdate", nil)
	self:UpdateScreen()
end
--
function simpleMinimap_Location:UpdateScreen()
	if(simpleMinimap:IsModuleActive(self)) then
		smmLocationFrame:Show()
		smmLocationFrame:ClearAllPoints()
		smmLocationFrame:SetPoint(self.positions[self.db.profile.position][1], "Minimap", self.positions[self.db.profile.position][2])
		smmLocationFrame:SetAlpha(self.db.profile.alpha)
		smmLocationFrame:SetScale(self.db.profile.scale)
		smmLocationFrameText:SetTextColor(self.db.profile.fontR, self.db.profile.fontG, self.db.profile.fontB)
		if(self.db.profile.backdrop) then
			smmLocationFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, 1)
		else
			smmLocationFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, 0)
		end
		if(self.db.profile.border) then
			smmLocationFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 1)
		else
			smmLocationFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 0)
		end
	else
		smmLocationFrame:Hide()
	end
end
--
function simpleMinimap_Location:UpdateEvent()
	if(self.db.profile.time > 0) then
		smmLocationFrame:SetScript("OnUpdate", nil)
		self:ScheduleRepeatingEvent("smmLocationUpdate", function()
			local name = GetMinimapZoneText();
			smmLocationFrameText:SetText(name)
			if not (name) then
				smmLocationFrame:Hide()
			end
		end, self.db.profile.time, self)
	else
		self:CancelAllScheduledEvents()
		smmLocationFrame:SetScript("OnUpdate", function()
			local name = GetMinimapZoneText();
			smmLocationFrameText:SetText(name)
			if not (name) then
				smmLocationFrame:Hide()
			end
		end)
	end
end
--
function simpleMinimap_Location:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
	smmLocationFrame:Show()
end