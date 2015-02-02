local AceLocale = AceLibrary("AceLocale-2.1")

AceLocale:RegisterTranslation("simpleMinimap", "enUS", function() return({
	alpha = "alpha",
		alpha_desc = "minimap alpha when outdoors",
	bgs = "battlegrounds",
		bgs_desc = "battlegrounds indicator",
	location = "location bar",
		location_desc = "location display bar",
	lock = "lock minimap",
		lock_desc = "lock minimap movement and hide movers",
	mail = "mail indicator",
		mail_desc = "unread mail indicator",
	meet = "meeting stone",
		meet_desc = "meeting stone indicator",
	modules = "modules",
		modules_desc = "installed module options",
	reset = "reset profile",
		reset_desc = "reset current profile to defaults",
	scale = "scale",
		scale_desc = "set minimap cluster scale",
	show = "show / hide",
		show_desc = "show and hide minimap / UI elements",
	strata = "strata",
		show_desc = "changes how the frame is overlayed on others",
	time = "time indicator",
		time_desc = "day / night indicator",
	track = "track button",
		track_desc = "tracking indicator",
	zoom = "zoom in / out",
		zoom_desc = "zoon in / out buttons",
	reset_popup = "Reset this simpleMinimap profile to defaults?"
}) end)

BINDING_HEADER_smmTITLE = "simpleMinimap"
BINDING_NAME_smmTOGGLE = "Toggle Minimap"
