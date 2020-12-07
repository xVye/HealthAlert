local addonName, HealthAlert = ...

LibStub('AceAddon-3.0'):NewAddon(HealthAlert, 'HealthAlert', 'AceConsole-3.0', 'AceEvent-3.0')

--- @class HealthAlert
_G[addonName] = HealthAlert

local f = CreateFrame("Frame", "HealthAlert", UIParent)
f:SetScript("OnUpdate", function()
	HealthAlert:OnUpdate()
end)
HealthAlert.MainFrame = f

function HealthAlert:OnInitialize()
	self.db = LibStub('AceDB-3.0'):New('HealthAlertOptions', self.HealthAlertOptions)
end

function HealthAlert:OnEnable()
	SetupOptionsPanel()
end

function HealthAlert:OnUpdate()
	local s = self.db.global
	if (s.LastAlertUnixTime + s.SoundIntervalSeconds) < time() then
		self.db.global.LastAlertUnixTime = time()

		if UnitAffectingCombat('player') and
			(UnitHealth('player') / UnitHealthMax('player') * 100) <= s.HealthPercent
		then
			self:RunAlerts()
		end
	end
end

function HealthAlert:PlayAlertSound(s)
	PlaySoundFile(s, self.db.global.SoundChannel)
end

function HealthAlert:ShowRaidWarning(text)
	RaidNotice_AddMessage(RaidWarningFrame, text, ChatTypeInfo["RAID_WARNING"]);
end

function HealthAlert:RunAlerts()
	local s = self.db.global

	if not s.MuteAlertSound then
		self:PlayAlertSound(s.AlertSound)
	end
	if not s.DisableRaidWarning then
		self:ShowRaidWarning(s.RaidWarningText)
	end
end