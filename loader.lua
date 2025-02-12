if getgenv().LoadedFromTeleport == nil then
	queue_on_teleport("getgenv().LoadedFromTeleport = true; loadstring(game:HttpGet('https://raw.githubusercontent.com/ImDamc/Moon/refs/heads/main/loader.lua', true))()")
end

loadstring(game:HttpGet('https://raw.githubusercontent.com/ImDamc/Moon/refs/heads/main/GuiLibrary.lua', true))()

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
end
