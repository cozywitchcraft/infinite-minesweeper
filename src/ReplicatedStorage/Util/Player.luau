local Players = game:GetService("Players")

local Player = {}

function Player.getDisplayName(player: Player): string
	if player.Name ~= player.DisplayName then
		return `{player.DisplayName} (@{player.Name})`
	end

	return `@{player.Name}`
end

-- TODO: Fuzzy finding
function Player.getPlayerByName(name: string): Player?
	name = name:lower()

	for _, player in Players:GetPlayers() do
		if player.Name:sub(1, #name):lower() == name then
			return player
		end
	end
	
	return nil
end

return Player