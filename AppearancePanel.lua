﻿-- Interface options panel: Appearance
-- Load after OptionsPanel.lua, ApperancePanel.xml

local addonName, addonTable = ...
NeedToKnow.AppearancePanel = _G["InterfaceOptionsNeedToKnowAppearancePanel"]
NeedToKnow.OptionSlider = {}
NeedToKnow.ScrollFrame = {}
local AppearancePanel = NeedToKnow.AppearancePanel
local OptionSlider = NeedToKnow.OptionSlider
local ScrollFrame = NeedToKnow.ScrollFrame

local OptionsPanel = NeedToKnow.OptionsPanel
local String = NeedToKnow.String

local LSM = LibStub("LibSharedMedia-3.0", true)
-- local textureList = LSM:List("statusbar")
-- local fontList = LSM:List("font")


--[[ Appearance panel ]]--

function AppearancePanel:OnLoad()
	self:SetScripts()
	self:SetText()

	self.name = NEEDTOKNOW.UIPANEL_APPEARANCE
	self.parent = "NeedToKnow"
	self.default = NeedToKnow.ResetCharacter
	self.cancel = NeedToKnowOptions.Cancel
	-- need different way to handle cancel?  users might open appearance panel without opening main panel
	InterfaceOptions_AddCategory(self)
end

function AppearancePanel:SetScripts()
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnSizeChanged", self.OnSizeChanged)

	self.backgroundColorButton.variable = "BkgdColor"
	self.backgroundColorButton:SetScript("OnClick", self.ChooseColor)
	self.backgroundColorButton:RegisterForClicks("LeftButtonUp")

	self.barSpacingSlider.variable = "BarSpacing"
	self.barSpacingSlider:SetMinMaxValues(0, 24)
	self.barSpacingSlider:SetValueStep(0.5)

	self.barPaddingSlider.variable = "BarPadding"
	self.barPaddingSlider:SetMinMaxValues(0, 12)
	self.barPaddingSlider:SetValueStep(0.5)

	self.fontSizeSlider.variable = "FontSize"
	self.fontSizeSlider:SetMinMaxValues(5, 20)
	self.fontSizeSlider:SetValueStep(0.5)

	for _, slider in pairs(self.sliders) do
		OptionSlider.OnLoad(slider)
	end

	-- Bar texture
	self.Textures.variable = "BarTexture"
	self.Textures.itemList = LSM:List("statusbar")
	self.Textures.List:SetScript("OnSizeChanged", ScrollFrame.OnSizeChanged)
	self.Textures.List.update = AppearancePanel.UpdateBarTextureScrollFrame
	self.Textures.updateButton = function(button, label) 
		button.Bg:SetTexture(NeedToKnow.LSM:Fetch("statusbar", label))
	end
	self.Textures.normal_color = {0.7, 0.7, 0.7, 1}
	self.Textures.onClick = AppearancePanel.OnClickScrollItem

	-- Bar font
--	self.Fonts.variable = "BarFont"
--	self.Fonts.itemList = LSM:List("font")
--	self.Fonts.List:SetScript("OnSizeChanged", ScrollFrame.OnSizeChanged)
--	self.Fonts.List.update = AppearancePanel.UpdateBarFontScrollFrame
--	self.Fonts.updateButton = function(button, label) 
--		button.text:SetFont(NeedToKnow.LSM:Fetch("font", label), 12)
--	end
--	self.Fonts.onClick = AppearancePanel.OnClickScrollItem

	self:OnLoadBarFontMenu()

	self.editModeButton:SetScript("OnEnter", OptionsPanel.OnWidgetEnter)
	self.editModeButton:SetScript("OnClick", OptionsPanel.OnConfigModeButtonClick)
	self.playModeButton:SetScript("OnEnter", OptionsPanel.OnWidgetEnter)
	self.playModeButton:SetScript("OnClick", OptionsPanel.OnPlayModeButtonClick)
end

function AppearancePanel:SetText()
	self.title:SetText(addonName.." v"..NeedToKnow.version)
	self.subText:SetText(String.OPTIONS_PANEL_SUBTEXT)

	self.backgroundColorButton.label:SetText(NEEDTOKNOW.UIPANEL_BACKGROUNDCOLOR)

	self.barSpacingSlider.label:SetText("Bar spacing")
	self.barPaddingSlider.label:SetText("Border size")
	self.fontSizeSlider.label:SetText("Font size")
	self.fontOutlineMenu.label:SetText("Font outline")
	self.barFontMenu.label:SetText("Font")

	self.Textures.title:SetText("Bar texture")
	-- self.Fonts.title:SetText("Bar font")

	self.editModeButton.Text:SetText(NeedToKnow.String.EDIT_MODE)
	self.editModeButton.tooltipText = String.EDIT_MODE_TOOLTIP
	self.playModeButton.Text:SetText(NeedToKnow.String.PLAY_MODE)
	self.playModeButton.tooltipText = String.PLAY_MODE_TOOLTIP
end

function AppearancePanel:OnShow()
	self:Update()
	-- Kitjan: Cache this? Update needs it to
	ScrollFrame.OnShow(self.Textures)
	-- ScrollFrame.OnShow(self.Fonts)
end

function AppearancePanel:Update()
	if not self:IsVisible() then return end
	local settings = NeedToKnow.ProfileSettings

	local r, g, b = unpack(settings.BkgdColor)
	self.backgroundColorButton.normalTexture:SetVertexColor(r, g, b, 1)

	for _, slider in pairs(self.sliders) do
		slider:Update()
	end
	self:UpdateFontOutlineMenu()
	self:UpdateBarFontMenu()

	self:UpdateBarTextureScrollFrame()
	-- self:UpdateBarFontScrollFrame()
end

function AppearancePanel:OnSizeChanged()
	-- Kitjan: Despite my best efforts, the scroll bars insist on being outside the width of their
	local mid = self:GetWidth()/2 --+ _G[self:GetName().."TexturesListScrollBar"]:GetWidth()
	local textures = self.Textures
	local leftTextures = textures:GetLeft()
	if mid and mid > 0 and textures and leftTextures then
		local ofs = leftTextures - self:GetLeft()
		textures:SetWidth(mid - ofs)
	end
end


--[[ Scroll frames (BarTexture, BarFont) ]]--

ScrollFrame.normalColor = {0.7, 0.7, 0.7, 0}
ScrollFrame.selectedColor = {0.1, 0.6, 0.8, 1}

function ScrollFrame:OnLoad()
end

function ScrollFrame:OnShow()
	-- Scroll to selected option
	local scrollIndex = 1
	for i = 1, #self.itemList do
		if NeedToKnow.ProfileSettings[self.variable] == self.itemList[i] then
			scrollIndex = i
			break
		end
	end
	scrollIndex = scrollIndex - 1
	self.List.scrollBar:SetValue(scrollIndex * self.List.buttonHeight + 0.1)
	HybridScrollFrame_OnMouseWheel(self.List, 1, 0.1)  -- Neph: Why is this here?
end

function ScrollFrame:OnSizeChanged()
	-- called with self = scrollFrame.List
    HybridScrollFrame_CreateButtons(self, "NeedToKnowScrollItemTemplate")
	for _, button in pairs(self.buttons) do
		button:SetScript("OnClick", 
			function()
				local scrollFrame = self:GetParent()
				scrollFrame.onClick(button)
			end
		)
	end
    local old_value = self.scrollBar:GetValue()
    local max_value = self.range or self:GetHeight()
    self.scrollBar:SetValue(min(old_value, max_value))
end

-- function NeedToKnowOptions.OnScrollFrameScrolled(self)
	-- local scrollPanel = self:GetParent()
	-- local fn = scrollPanel.Update
	-- if fn then fn(scrollPanel) end
-- end

function ScrollFrame:UpdateScrollItems(selectedItem, checkedItem)
	-- Called with self = scrollFrame
	local itemList = self.itemList
	local listFrame = self.List
	local buttons = listFrame.buttons
	HybridScrollFrame_Update(listFrame, #(itemList) * buttons[1]:GetHeight(), listFrame:GetHeight())

	local label
	for i, button in ipairs(buttons) do
		label = itemList[i + HybridScrollFrame_GetOffset(listFrame)]
		if label then
			button:Show()
			button.text:SetText(label)

			if label == selectedItem then
				local color = self.selected_color or ScrollFrame.selectedColor
				button.Bg:SetVertexColor(unpack(color))
			else
				local color = self.normal_color or ScrollFrame.normalColor
				button.Bg:SetVertexColor(unpack(color))
			end

			if label == checkedItem then
				button.Check:Show()
			else
				button.Check:Hide()
			end

			self.updateButton(button, label)
		else
			button:Hide()
		end
	end
end

function AppearancePanel:UpdateBarTextureScrollFrame()
	-- called by AppearancePanel:Update(), HybridScrollFrame_SetOffset()
	local scrollFrame = AppearancePanel.Textures
	local settings = NeedToKnow.ProfileSettings
	ScrollFrame.UpdateScrollItems(scrollFrame, settings.BarTexture, settings.BarTexture)
end

function AppearancePanel:UpdateBarFontScrollFrame()
	-- called by AppearancePanel:Update(), HybridScrollFrame_SetOffset()
	local scrollFrame = AppearancePanel.Fonts
	local settings = NeedToKnow.ProfileSettings
	ScrollFrame.UpdateScrollItems(scrollFrame, nil, settings.BarFont)
end

function AppearancePanel:OnClickScrollItem()
	-- Called with self = list button
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	scrollFrame = self:GetParent():GetParent():GetParent()
	NeedToKnow.ProfileSettings[scrollFrame.variable] = self.text:GetText()
	NeedToKnow:Update()
	AppearancePanel:Update()
end


--[[ Bar font menu ]]--

local barFontMenuContents = NeedToKnow.LSM:List("font")

function AppearancePanel:OnLoadBarFontMenu()
	local menu = self.barFontMenu
	menu.customButtons = {}
	local button
	for i, fontName in ipairs(barFontMenuContents) do
		menu.customButtons[i] = CreateFrame("Button", menu:GetName().."Button"..i, menu, "NeedToKnowBarFontMenuButtonTemplate")
		button = menu.customButtons[i]
		button.text:SetText(fontName)
		button.text:SetFont(NeedToKnow.LSM:Fetch("font", fontName), 10)
		button:SetScript("OnClick", AppearancePanel.OnClickBarFontMenuItem)
	end
end

function AppearancePanel:UpdateBarFontMenu()
	local menu = self.barFontMenu
	UIDropDownMenu_SetWidth(menu, 180)
	UIDropDownMenu_Initialize(menu, AppearancePanel.MakeBarFontMenu)
	UIDropDownMenu_OnHide(DropDownList1)  -- So custom buttons don't show in other menus

	-- Show current setting
	local setting = NeedToKnow.ProfileSettings.BarFont
	for _, fontName in ipairs(barFontMenuContents) do
		if fontName == setting then
			UIDropDownMenu_SetText(menu, fontName)
			menu.Text:SetFont(NeedToKnow.LSM:Fetch("font", fontName), 10)
			break
		end
	end
end

function AppearancePanel:MakeBarFontMenu()
	-- Called with self = menu
	local info = {}
	local button
	local fontName = NeedToKnow.ProfileSettings.BarFont
	for i, customButton in ipairs(self.customButtons) do
		info.customFrame = customButton
		button = UIDropDownMenu_AddButton(info)
		customButton = button.customFrame
		if fontName == customButton.text:GetText() then
			customButton.check:Show()
			customButton.uncheck:Hide()
		else
			customButton.check:Hide()
			customButton.uncheck:Show()
		end
	end
end

function AppearancePanel:OnClickBarFontMenuItem()
	-- Called with self = customButton
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	NeedToKnow.ProfileSettings.BarFont = self.text:GetText()
	AppearancePanel:Update()
	NeedToKnow:Update()
end


--[[ Color buttons (background color) ]]--

function AppearancePanel:ChooseColor()
	local variable = self.variable
	info = UIDropDownMenu_CreateInfo()
	info.r, info.g, info.b, info.opacity = unpack(NeedToKnow.ProfileSettings[variable])
	info.opacity = 1 - info.opacity
	info.hasOpacity = true
	info.swatchFunc = AppearancePanel.SetColor
	info.opacityFunc = AppearancePanel.SetOpacity
	info.cancelFunc = AppearancePanel.CancelColor
	info.extraInfo = variable
	-- Kitjan: Not sure if I should leave this state around or not.  It seems like the
	-- correct strata to have it at anyway, so I'm going to leave it there for now
	ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	OpenColorPicker(info)
end

function AppearancePanel.SetColor()
	local variable = ColorPickerFrame.extraInfo
	local r, g, b = ColorPickerFrame:GetColorRGB()
	NeedToKnow.ProfileSettings[variable][1] = r
	NeedToKnow.ProfileSettings[variable][2] = g
	NeedToKnow.ProfileSettings[variable][3] = b
	NeedToKnow:Update()
	AppearancePanel:Update()
end

function AppearancePanel.SetOpacity()
	local variable = ColorPickerFrame.extraInfo
	NeedToKnow.ProfileSettings[variable][4] = 1 - OpacitySliderFrame:GetValue()
	NeedToKnow:Update()
	AppearancePanel:Update()
end

function AppearancePanel.CancelColor(previousValues)
	if previousValues then
		local variable = ColorPickerFrame.extraInfo
		NeedToKnow.ProfileSettings[variable] = {previousValues.r, previousValues.g, previousValues.b, previousValues.opacity}
		NeedToKnow:Update()
		AppearancePanel:Update()
	end
end


--[[ Sliders (bar spacing, bar padding, font size) ]]--

function OptionSlider:OnLoad()
	self.Update = OptionSlider.Update
	self:SetScript("OnValueChanged", OptionSlider.OnValueChanged)
	self.editBox:SetScript("OnTextChanged", OptionSlider.OnEditBoxTextChanged)
	self.editBox:SetScript("OnEnterPressed", EditBox_ClearFocus)
	self.editBox:SetScript("OnEscapePressed", OptionSlider.OnEditBoxEscapePressed)
	self.editBox:SetScript("OnEditFocusLost", OptionSlider.OnEditBoxFocusLost)
end

function OptionSlider:Update()
	local value = NeedToKnow.ProfileSettings[self.variable]
	self:SetValue(value)
	self.editBox:SetText(value)
	self.editBox.oldValue = value
end

function OptionSlider:OnValueChanged(value, isUserInput)
	if isUserInput then
		NeedToKnow.ProfileSettings[self.variable] = value
		self.editBox:SetText(value)
		self.editBox.oldValue = value
		NeedToKnow:Update()
	end
end

function OptionSlider:OnEditBoxTextChanged(isUserInput)
	-- Called with self = editBox
	local value = tonumber(self:GetText())
	if value and isUserInput then
		NeedToKnow.ProfileSettings[self:GetParent().variable] = value
		self:GetParent():SetValue(value)
		NeedToKnow:Update()
	end
end

function OptionSlider:OnEditBoxEscapePressed()
	-- Called with self = editBox
	if self.oldValue then
		NeedToKnow.ProfileSettings[self:GetParent().variable] = self.oldValue
		self:GetParent():SetValue(self.oldValue)
		NeedToKnow:Update()
	end
	EditBox_ClearFocus(self)
end

function OptionSlider:OnEditBoxFocusLost(value)
	-- Called with self = editBox
	local value = tonumber(self:GetText())
	if value then
		self.oldValue = value
	elseif self.oldValue then
		self:SetText(self.oldValue)
	end
	EditBox_ClearHighlight(self)
end


--[[ Font outline menu ]]--

local fontOutlineMenuContents = {
	{text = "None", arg1 = 0}, 
	{text = "Thin", arg1 = 1}, 
	{text = "Thick", arg1 = 2}, 
}

function AppearancePanel:UpdateFontOutlineMenu()
	local menu = self.fontOutlineMenu
	UIDropDownMenu_SetWidth(menu, 96)
	UIDropDownMenu_Initialize(menu, AppearancePanel.MakeFontOutlineMenu)

	-- Show current setting
	local setting = NeedToKnow.ProfileSettings.FontOutline
	for i, entry in ipairs(fontOutlineMenuContents) do
		if entry.arg1 == setting then
			UIDropDownMenu_SetText(menu, entry.text)
			break
		end
	end
end

function AppearancePanel:MakeFontOutlineMenu()
	-- Called with self = menu
	local info = {}
	local setting = NeedToKnow.ProfileSettings.FontOutline
	info.func = AppearancePanel.OnFontOutlineMenuClick
	for i, entry in ipairs(fontOutlineMenuContents) do
		info.text = entry.text
		info.arg1 = entry.arg1
		info.arg2 = entry.text
		info.checked = (entry.arg1 == setting)
		UIDropDownMenu_AddButton(info)
	end
end

function AppearancePanel:OnFontOutlineMenuClick(arg1, arg2)
	-- called with self = DropDownList button
	NeedToKnow.ProfileSettings.FontOutline = arg1
	NeedToKnow:Update()
	-- local panel = _G["InterfaceOptionsNeedToKnowAppearancePanel"]
	UIDropDownMenu_SetText(AppearancePanel.fontOutlineMenu, arg2)
	-- UIDropDownMenu_SetText(AppearancePanel.fontOutlineMenu, arg2)
end


do
	AppearancePanel:OnLoad()
end
