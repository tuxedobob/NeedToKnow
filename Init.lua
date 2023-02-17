-- Load after libs and before everything else

local addonName, addonTable = ...

-- Declare global variables
NeedToKnow = {}
NeedToKnow.version = GetAddOnMetadata(addonName, "Version")

-- Deprecated:
NEEDTOKNOW = {}
NEEDTOKNOW.VERSION = GetAddOnMetadata(addonName, "Version")
NeedToKnowLoader = {}  -- Used by Profile.lua
NeedToKnowOptions = {}  -- Used by NeedToKnow_Options.lua

-- Namespaces
NeedToKnow.ExecutiveFrame = CreateFrame("Frame", "NeedToKnow_ExecutiveFrame")
NeedToKnow.BarGroup = {}
NeedToKnow.ResizeButton = {}

NeedToKnow.Bar = {}
NeedToKnow.FindAura = {}
NeedToKnow.Cooldown = {}
NeedToKnow.BarMenu = {}
NeedToKnow.Dialog = {}

NeedToKnow.ProfilePanel = {}  -- Temporary


--[[ Default settings ]]--

NeedToKnow.DefaultSettings = {}
local DefaultSettings = NeedToKnow.DefaultSettings

DefaultSettings.bar = {}
DefaultSettings.barGroup = {}
DefaultSettings.profile = {}

DefaultSettings.character = {
    Specs = {},
    Locked = false,
    Profiles = {},
}

DefaultSettings.global = {
    Version = NeedToKnow.version,
    OldVersion = NeedToKnow.version,
    Profiles = {},
    Chars = {},
}



NEEDTOKNOW.BAR_DEFAULTS = {
    Enabled         = true,
    AuraName        = "",
    Unit            = "player",
    BuffOrDebuff    = "HELPFUL",
    OnlyMine        = true,
    BarColor        = {r = 0.6, g = 0.6, b = 0.6, a = 1.0},
    MissingBlink    = {r = 1, g = 0, b = 0, a = 1},
    TimeFormat      = "Fmt_SingleUnit",
    vct_enabled     = false,
    vct_color       = {r = 0, g = 0, b = 0, a = 0.4},
    vct_spell       = "",
    vct_extra       = 0,
    bDetectExtends  = false,
    show_text       = true,
    show_count      = true,
    show_time       = true,
    show_spark      = true,
    show_icon       = false,
    show_all_stacks = false,
    show_charges    = true,
    show_text_user  = "",
    blink_enabled   = false,
    blink_ooc       = true,
    blink_boss      = false,
    blink_label     = "",
    buffcd_duration = 45,  -- Most procs have 45 sec internal cooldown
    buffcd_reset_spells = "",
    usable_duration = 0,
    append_cd       = false,
    append_usable   = false,
}
NEEDTOKNOW.GROUP_DEFAULTS = {
    Enabled = true,
    NumberBars = 3,
    Position = {"TOPLEFT", "TOPLEFT", 100, -100},
    Scale = 1,
    Width = 270,
    direction = "down", 
    condenseGroup = false, 
    FixedDuration = 0, 
    Bars = {NEEDTOKNOW.BAR_DEFAULTS, NEEDTOKNOW.BAR_DEFAULTS, NEEDTOKNOW.BAR_DEFAULTS},
}
NEEDTOKNOW.PROFILE_DEFAULTS = {
	name = "Default",
	nGroups = 4,
	Groups = {NEEDTOKNOW.GROUP_DEFAULTS},
	BarTexture = "BantoBar",
	BkgdColor = {0, 0, 0, 0.8},
	BorderColor = {0, 0, 0, 1}, 
	BarSpacing = 3,
	BarPadding = 3,  -- border size
	BarFont = "Fritz Quadrata TT",
	FontOutline = 0,
	FontSize = 12,
	FontColor = {1, 1, 1, 1}, 
}
NEEDTOKNOW.CHARACTER_DEFAULTS = {
    Specs       = {},
    Locked      = false,
    Profiles    = {},
}
NEEDTOKNOW.DEFAULTS = {
    Version     = NeedToKnow.version,
    OldVersion  = NeedToKnow.version,
    Profiles    = {},
    Chars       = {},
}


-- LibSharedMedia library support
NeedToKnow.LSM = LibStub("LibSharedMedia-3.0", true)
local barTextures = {
	["Aluminum"]   = [[Interface\Addons\NeedToKnow\Textures\Aluminum.tga]],
	["Armory"]     = [[Interface\Addons\NeedToKnow\Textures\Armory.tga]],
	["BantoBar"]   = [[Interface\Addons\NeedToKnow\Textures\BantoBar.tga]],
	["DarkBottom"] = [[Interface\Addons\NeedToKnow\Textures\Darkbottom.tga]],
	["Default"]    = [[Interface\Addons\NeedToKnow\Textures\Default.tga]],
	["Flat"]       = [[Interface\Addons\NeedToKnow\Textures\Flat.tga]],
	["Glaze"]      = [[Interface\Addons\NeedToKnow\Textures\Glaze.tga]],
	["Gloss"]      = [[Interface\Addons\NeedToKnow\Textures\Gloss.tga]],
	["Graphite"]   = [[Interface\Addons\NeedToKnow\Textures\Graphite.tga]],
	["Minimalist"] = [[Interface\Addons\NeedToKnow\Textures\Minimalist.tga]],
	["Otravi"]     = [[Interface\Addons\NeedToKnow\Textures\Otravi.tga]],
	["Smooth"]     = [[Interface\Addons\NeedToKnow\Textures\Smooth.tga]],
	["Smooth v2"]  = [[Interface\Addons\NeedToKnow\Textures\Smoothv2.tga]],
	["Striped"]    = [[Interface\Addons\NeedToKnow\Textures\Striped.tga]]
}
for k, v in pairs(barTextures) do
	NeedToKnow.LSM:Register("statusbar", k, v) 
end


-- Kitjan's addon locals
NeedToKnow.m_last_guid = {}  -- For ExtendedTime
-- Used by Executive Frame:
addonTable.m_last_cast = {}
addonTable.m_last_cast_head = {}
addonTable.m_last_cast_tail = {}


