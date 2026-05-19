local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Util.Signal)

export type Setting<T> = {
	value: T,
	changeValue: (setting: Setting<T>, newValue: T) -> (),
	changed: Signal.Signal<>,
}

local function changeValue<T>(setting: Setting<T>, newValue: T)
	if setting.value :: any ~= newValue :: any then
		setting.value = newValue
		setting.changed:fire()
	end
end

local function createSetting<T>(defaultValue: T): Setting<T>
	return {
		value = defaultValue,
		changeValue = changeValue,
		changed = Signal.new(),
	}
end

return createSetting
