local LaunchId = math.random()

getgenv().loadTeleport = function()
    task.wait(1.5)
    return queueonteleport("getgenv().LoadedFromTeleport = true; loadstring(game:HttpGet('https://raw.githubusercontent.com/ImDamc/Moon/refs/heads/main/loader.lua', true))()")
end

if getgenv().LoadedFromTeleport == nil and not shared.MoonDeveloper and queueonteleport then
    loadTeleport()
end

if shared.MoonDeveloper then
	loadfile("Moon/GuiLibrary.lua")()
else
	loadstring(game:HttpGet('https://raw.githubusercontent.com/ImDamc/Moon/refs/heads/main/GuiLibrary.lua', true))()
end

repeat task.wait() until shared.GuiLibrary ~= nil

local function fetch(placeid)
	return game:HttpGet('https://raw.githubusercontent.com/ImDamc/Moon/refs/heads/main/Games/'..placeid..".lua", true)
end

local function betterReadfile(path)
	return isfile(path) and readfile(path) or "404: Not Found"
end

local gameScript = fetch(game.PlaceId)

if shared.MoonDeveloper then
	gameScript = betterReadfile("Moon/Games/"..game.PlaceId..".lua")
end

if gameScript ~= "404: Not Found" then
	loadstring(gameScript)()
else
	shared.GuiLibrary:CreateNotification("This game is not supported, loading universal.", 3)
	
	if shared.MoonDeveloper then
		loadstring(betterReadfile("Moon/Games/Universal.lua"))()
	else
		loadstring(fetch("Universal"))()
	end
	
end
