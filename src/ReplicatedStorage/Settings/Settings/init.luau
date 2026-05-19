local DefaultSettings = require(script.Parent.DefaultSettings)
local createSetting = require(script.createSetting)

export type Setting<T> = createSetting.Setting<T>

return {
	announcementsEnabled = createSetting(DefaultSettings.announcementsEnabled),
	explosionsEnabled = createSetting(DefaultSettings.explosionsEnabled),
	sparklesEnabled = createSetting(DefaultSettings.sparklesEnabled),
	
	skybox = createSetting(DefaultSettings.skybox),

	chordingEnabled = createSetting(DefaultSettings.chordingEnabled),
	ignoreFlags = createSetting(DefaultSettings.ignoreFlags),

	highlightEnabled = createSetting(DefaultSettings.highlightEnabled),
	highlightColor = createSetting(DefaultSettings.highlightColor),
	highlightSpeed = createSetting(DefaultSettings.highlightSpeed),

	fieldColorLight = createSetting(DefaultSettings.fieldColorLight),
	fieldColorDark = createSetting(DefaultSettings.fieldColorDark),

	groundColorLight = createSetting(DefaultSettings.groundColorLight),
	groundColorDark = createSetting(DefaultSettings.groundColorDark),

	fieldMaterial = createSetting(DefaultSettings.fieldMaterial),
	groundMaterial = createSetting(DefaultSettings.groundMaterial),

	cameraShake = createSetting(DefaultSettings.cameraShake),
	topdownView = createSetting(DefaultSettings.topdownView),
	freezeCameraOnDeath = createSetting(DefaultSettings.freezeCameraOnDeath),

	vignetteEnabled = createSetting(DefaultSettings.vignetteEnabled),

	characterVolume = createSetting(DefaultSettings.characterVolume),
	explosionVolume = createSetting(DefaultSettings.explosionVolume),
	flagVolume = createSetting(DefaultSettings.flagVolume),
	alertVolume = createSetting(DefaultSettings.alertVolume),

	showTileCount = createSetting(DefaultSettings.showTileCount),
	showMineCount = createSetting(DefaultSettings.showMineCount),
	showFlagCount = createSetting(DefaultSettings.showFlagCount),

	showCoords = createSetting(DefaultSettings.showCoords),
	showRoundTimer = createSetting(DefaultSettings.showRoundTimer),
	showSessionTimer = createSetting(DefaultSettings.showSessionTimer),
	
	showScore = createSetting(DefaultSettings.showScore),
}
