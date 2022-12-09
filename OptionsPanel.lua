﻿--[[ Interface options panel (Main) ]]--

-- local addonName, addonTable = ...
local OptionsPanel = NeedToKnow.OptionsPanel
local String = NeedToKnow.String

local NeedToKnow_OldProfile
local NeedToKnow_OldSettings

local MAX_GROUPS = 4
local MAX_BARS_PER_GROUP = 12


--[[ Panel functions ]]--

function OptionsPanel:UIPanel_OnLoad()
	self.name = "NeedToKnow"
	self.default = NeedToKnow.ResetCharacter
	self.cancel = NeedToKnowOptions.Cancel
	InterfaceOptions_AddCategory(self)

	-- Mixin(self, OptionsPanel)  -- Inherit OptionsPanel methods

	OptionsPanel.SetPanelText(self)
	-- OptionsPanel:SetPanelFunctions()
end

function OptionsPanel:SetPanelText()
	self.subText1:SetText(NEEDTOKNOW.UIPANEL_SUBTEXT1)
	self.version:SetText(NEEDTOKNOW.VERSION)
	self.numberBarsLabel:SetText(NEEDTOKNOW.UIPANEL_NUMBERBARS)
	self.fixedDurationLabel:SetText(NEEDTOKNOW.UIPANEL_FIXEDDURATION)
	self.configModeButton.Text:SetText(NEEDTOKNOW.UIPANEL_CONFIGMODE)
	self.playModeButton.Text:SetText(NEEDTOKNOW.UIPANEL_PLAYMODE)
	for groupID = 1, MAX_GROUPS do
		local groupOptions = self["group"..groupID]
		groupOptions.enableButton.Text:SetText(NEEDTOKNOW.UIPANEL_BARGROUP..groupID)
	end
end

function OptionsPanel:SetPanelFunctions()
end

function OptionsPanel:UIPanel_OnShow()
    NeedToKnow_OldProfile = NeedToKnow:GetProfileSettings()
    NeedToKnow_OldSettings = CopyTable(NeedToKnow:GetProfileSettings())
    OptionsPanel.UIPanel_Update(self)
end

function OptionsPanel:UIPanel_Update()
	self = self or _G["InterfaceOptionsNeedToKnowPanel"]
	if not self:IsVisible() then return end
	for groupID = 1, MAX_GROUPS do
		OptionsPanel.GroupEnableButton_Update(groupID)
		OptionsPanel.NumberbarsWidget_Update(groupID)
		local groupSettings = NeedToKnow:GetGroupSettings(groupID)
		self["group"..groupID].fixedDurationBox:SetText(groupSettings.FixedDuration or "")
    end
end

function OptionsPanel:Cancel()
    -- Can't copy the table here since ProfileSettings needs to point to the right place in
    -- NeedToKnow_Globals.Profiles or in NeedToKnow_CharSettings.Profiles
	-- FIXME: This is only restoring a small fraction of the total settings.
    NeedToKnow.RestoreTableFromCopy(NeedToKnow_OldProfile, NeedToKnow_OldSettings)
    -- FIXME: Close context menu if it's open; it may be referring to bar that doesn't exist
    NeedToKnow:Update()
end


--[[ Group options ]]--

function OptionsPanel.GroupEnableButton_Update(groupID)
	local panel = _G["InterfaceOptionsNeedToKnowPanel"]
	local button = panel["group"..groupID].enableButton
	button:SetChecked(NeedToKnow:GetGroupSettings(groupID).Enabled)
end

function OptionsPanel.GroupEnableButton_OnClick(self)
	local groupID = self:GetParent():GetID()
	local groupSettings = NeedToKnow:GetGroupSettings(groupID)
	if self:GetChecked() then
		if groupID > NeedToKnow.ProfileSettings.nGroups then
			NeedToKnow.ProfileSettings.nGroups = groupID
		end
		groupSettings.Enabled = true
	else
		groupSettings.Enabled = false
	end
	NeedToKnow.Update()
end

function OptionsPanel.NumberbarsWidget_Update(groupID)
	local panel = _G["InterfaceOptionsNeedToKnowPanel"]
	local widget = panel["group"..groupID].numberBarsWidget
	local numberBars = NeedToKnow:GetGroupSettings(groupID).NumberBars
	widget.text:SetText(numberBars)
	widget.leftButton:Enable()
	widget.rightButton:Enable()
	if numberBars == 1 then
		widget.leftButton:Disable()
	elseif numberBars == MAX_BARS_PER_GROUP then
		widget.rightButton:Disable()
	end
end

function OptionsPanel.NumberbarsButton_OnClick(self, increment)
	local groupID = self:GetParent():GetParent():GetID()
	local groupSettings = NeedToKnow:GetGroupSettings(groupID)

	local oldNumber = groupSettings.NumberBars
	if oldNumber == 1 and increment < 0 then 
		return
	elseif oldNumber == MAX_BARS_PER_GROUP and increment > 0 then
		return
	end
	groupSettings.NumberBars = oldNumber + increment

	NeedToKnow:UpdateBarGroup(groupID)
	OptionsPanel.NumberbarsWidget_Update(groupID)
end

function OptionsPanel.FixedDurationEditBox_OnTextChanged(self)
	local text = self:GetText()
	local groupID = self:GetParent():GetID()
	local groupSettings = NeedToKnow:GetGroupSettings(groupID)
	if text == "" then
		groupSettings.FixedDuration = nil
	else
		groupSettings.FixedDuration = tonumber(text)
	end
	NeedToKnow:Update()
end


