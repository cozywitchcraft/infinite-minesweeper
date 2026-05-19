--!nonstrict

-- For projects gradually adopting Legacy scripts
local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

local Enum = roblox.Enum

local file = fs.readFile("./rbxl/infinite-minesweeper.rbxl")
local game = roblox.deserializePlace(file)

local function isTopLevelScript(script: LuaSourceContainer): boolean
	for _, v in script:GetDescendants() do
		if v:IsA("LuaSourceContainer") then
			return false
		end
	end

	return true
end

local function getPath(script: LuaSourceContainer): string
	local path = ""
	local parent = script.Parent

	while parent ~= game do
		path = parent.Name .. "/" .. path
		parent = parent.Parent
	end

	return "src/" .. path
end

-- TODO: Support migration to RunContext scripts
local function getSuffix(script: LuaSourceContainer): string
	if script.ClassName == "Script" then
		if script.RunContext == Enum.RunContext.Client then
			return ".client.luau"
		elseif script.RunContext == Enum.RunContext.Server then
			return ".server.luau"
		elseif script.RunContext == Enum.RunContext.Legacy then
			return ".legacy.server.luau"
		elseif script.RunContext == Enum.RunContext.Plugin then
			return ".plugin.luau"
		else
			error(`Error classifying {script:GetFullName()}: RunContext must be Client, Server, or Legacy`)
		end
	elseif script.ClassName == "LocalScript" then
		return ".legacy.client.luau"
	elseif script.ClassName == "ModuleScript" then
		return ".luau"
	else
		error(`Error classifying {script:GetFullName()}: ClassName must be Script, LocalScript, or ModuleScript`)
	end
end

local function mkdir(path: string)
	if fs.isDir(path) then
		return
	end

	fs.writeDir(path)
end

local function addScript(script: LuaSourceContainer)
	local path = getPath(script)
	local suffix = getSuffix(script)

	if isTopLevelScript(script) then
		mkdir(path)
		fs.writeFile(path .. script.Name .. suffix, script.Source)
	else
		path ..= script.Name .. "/"

		mkdir(path)
		fs.writeFile(path .. "init" .. suffix, script.Source)
	end
end

local function searchForScripts(instance: Instance)
	for _, v in instance:GetDescendants() do
		if v:IsA("LuaSourceContainer") then
			addScript(v)
		end
	end
end

searchForScripts(game:GetService("ReplicatedStorage"))
searchForScripts(game:GetService("ServerScriptService"))
searchForScripts(game:GetService("StarterPlayer"))
searchForScripts(game:GetService("ServerStorage"))
