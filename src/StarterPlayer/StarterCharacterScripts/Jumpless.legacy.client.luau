--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientConfig = require(ReplicatedStorage.Board.ClientConfig)

local character = assert(script.Parent, "Parent is nil")
local humanoid = assert(character:FindFirstChildOfClass("Humanoid"), "Cannot find humanoid")

local function toggleJumpless()
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, not ClientConfig.config.jumpless)
end

toggleJumpless()

ClientConfig.changed:connect(toggleJumpless)
