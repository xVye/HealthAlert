local _, HealthAlert = ...

HealthAlert.HealthAlertOptions = {
	global = {
		HealthPercent = 35,
		AlertSound = "Interface\\AddOns\\HealthAlert\\Sounds\\Alerts\\BeepBeep.ogg",
		SoundChannel = "Master",
		SoundIntervalSeconds = 1,
		LastAlertUnixTime = time(),
		MuteAlertSound = false,
		DisableRaidWarning = false,
		RaidWarningText = "LOW HEALTH - HEAL UP!",
		PlayerName = GetUnitName('player'),
		PlayerHealth = UnitHealth('player'),
		DisplayVersion = GetAddOnMetadata('HealthAlert', 'Version')
	}
}

function HealthAlert:ResetSettings()
	self.db:ResetDB()
end

function SetupOptionsPanel()
	--[[ Main Panel ]]--
	local configFrame = CreateFrame('Frame', 'HealthAlertConfigFrame', InterfaceOptionsFramePanelContainer)
	configFrame:Hide()
	configFrame.name = 'HealthAlert'
	InterfaceOptions_AddCategory(configFrame)

	--[[ Title ]]--
	local titleLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	titleLabel:SetPoint('TOPLEFT', configFrame, 'TOPLEFT', 16, -16)
	titleLabel:SetText('HealthAlert')

	-- [[ Version ]] --
	local versionLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	versionLabel:SetPoint('TOP', configFrame, 'TOP', 0, -16)
	versionLabel:SetText('v' .. GetAddOnMetadata('HealthAlert', 'Version'))

	--[[ Subtitle ]]--
	local displayLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	displayLabel:SetPoint('TOPLEFT', titleLabel, 'BOTTOMLEFT', 0, -16)
	displayLabel:SetText("Alert options")

	--[[ Health Slider Title ]]--
	local healthSliderTitle = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	healthSliderTitle:SetPoint('TOPLEFT', displayLabel, 'TOPLEFT', 0, -24)
	healthSliderTitle:SetText("Health alert percentage")

	--[[ Health Slider ]]--
	local healthSlider = CreateFrame('Slider', 'HealthAlertConfigFrameHealthSlider', configFrame, 'OptionsSliderTemplate')
	healthSlider:SetPoint('RIGHT', healthSliderTitle, 'RIGHT', 182, 0)
	healthSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	healthSlider:SetMinMaxValues(5, 85)
	healthSlider:SetValueStep(1)
	healthSlider:SetValue(HealthAlert.db.global.HealthPercent)
	healthSlider:SetOrientation('HORIZONTAL')

	getglobal(healthSlider:GetName() .. 'Low'):SetText('5')
	getglobal(healthSlider:GetName() .. 'High'):SetText('85')
	getglobal(healthSlider:GetName() .. 'Text'):SetText(healthSlider:GetValue())
	healthSlider:SetScript("OnValueChanged", function(self, newvalue)
		UpdateHealthSlider(self, newvalue)
	end)

	--[[ Mute Alert Checkbox ]]--
	local muteAlert = CreateFrame('CheckButton', 'HealthAlertConfigMuteAlertCheckButton', configFrame, 'InterfaceOptionsCheckButtonTemplate')
	muteAlert:SetPoint('TOPLEFT', healthSliderTitle, 'LEFT', -4, -16)
	muteAlert:SetChecked(HealthAlert.db.global.MuteAlertSound)
	muteAlert:SetScript("OnClick", function(self)
		UpdateMuteAlertSound(self:GetChecked())
	end)

	--[[ Mute Alert Title ]]--
	local muteAlertTitle = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	muteAlertTitle:SetPoint('RIGHT', muteAlert, 'RIGHT', 106, 0)
	muteAlertTitle:SetText("Mute sound alert")

	--[[ Disable Raidwarning Checkbox ]]--
	local muteRaidwarning = CreateFrame('CheckButton', 'HealthAlertConfigDisableRaidwarningCheckButton', configFrame, 'InterfaceOptionsCheckButtonTemplate')
	muteRaidwarning:SetPoint('TOPLEFT', muteAlert, 'LEFT', 0, -10)
	muteRaidwarning:SetChecked(HealthAlert.db.global.DisableRaidWarning)
	muteRaidwarning:SetScript("OnClick", function(self)
		UpdateDisableRaidwarning(self:GetChecked())
	end)

	--[[ Disable Raidwarning Title ]]--
	local muteRaidwarningTitle = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	muteRaidwarningTitle:SetPoint('TOPLEFT', muteAlertTitle, 'LEFT', 0, -16)
	muteRaidwarningTitle:SetText("Disable raidwarning")

	--[[ Disable Raidwarning Checkbox ]]--

	--[[ Reset Settings Button ]]--
	local resetSettings = CreateFrame('Button', 'HealthAlertConfigFrameResetSettingsButton', configFrame, 'UIPanelButtonTemplate')
	resetSettings:SetPoint('BOTTOMRIGHT', InterfaceOptionsFramePanelContainer, 'BOTTOMRIGHT', -16, 16)
	resetSettings:SetWidth(128)
	resetSettings:SetHeight(24)
	resetSettings:SetText("Reset Settings")
	resetSettings:SetScript("OnClick", function()
		HealthAlert:ResetSettings()
		UpdateHealthSlider(healthSlider, HealthAlert.db.global.HealthPercent)
		healthSlider:SetValue(HealthAlert.db.global.HealthPercent)
		muteAlert:SetChecked(HealthAlert.db.global.MuteAlertSound)
		muteRaidwarning:SetChecked(HealthAlert.db.global.DisableRaidWarning)
	end)
end

function UpdateMuteAlertSound(value)
	HealthAlertOptions.global.MuteAlertSound = value
end

function UpdateDisableRaidwarning(value)
	HealthAlertOptions.global.DisableRaidWarning = value
end

function UpdateHealthSlider(self, newvalue)
	local v = math.floor(newvalue)
	HealthAlertOptions.global.HealthPercent = v
	getglobal(self:GetName() .. 'Text'):SetText(v)
end