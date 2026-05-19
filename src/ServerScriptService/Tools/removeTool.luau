local function removeTool(player: Player, toolName: string)
	for _, parent in { player.Backpack, player.Character, player:FindFirstChild("StarterGear") } do
		local child = parent and parent:FindFirstChild(toolName)

		if child then
			child:Destroy()
		end
	end
end

return removeTool