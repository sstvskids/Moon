local function fetch(placeid)
	return game:HttpGet('https://raw.githubusercontent.com/ImDamc/Moon/refs/heads/main/Games/'..placeid..".lua", true)
end

local function betterReadfile(path)
	return isfile(path) and readfile(path) or "404: Not Found"
end

local gameScript = fetch("6872274481")

if shared.MoonDeveloper then
	gameScript = betterReadfile("Moon/Games/6872274481.lua")
end

if gameScript ~= "" then
	loadstring(gameScript)()
end