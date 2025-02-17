repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer.Character ~= nil

local GuiLibrary = shared.GuiLibrary
local Whitelist = shared.Whitelist

local Debris = game:GetService("Debris")
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

local lplr = PlayerService.LocalPlayer

local function getinstance(name, Type)
	for i,v in pairs(game:GetDescendants()) do
		if v.Name:lower() == name:lower() and v.ClassName:lower() == Type:lower() then
			return v
		end
	end

	return Instance.new(Type)
end

local EntityLib = {}
EntityLib.isAlive = function(player)
	if player.Character == nil then return false end
	if player.Character.Humanoid == nil then return false end
	if player.Character.PrimaryPart == nil then return false end
	if player.Character.Humanoid.Health <= 0 then return false end
	return true
end
function EntityLib:GetNear(range)
    local entity
	local neardist = 9e9
	for i,v in pairs(PlayerService:GetPlayers()) do
		pcall(function()
            if v.Team == lplr.Team or v == lplr then return end
			local dist = (v.Character.PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Magnitude
            if dist < range and dist <= neardist then
                if EntityLib.isAlive(v) then
                    entity = v
					neardist = dist
                end
            end
        end)
	end
    return entity
end

local isnetworkowner = isnetworkowner or function()
    return true
end

local Controllers = lplr.PlayerScripts.TS.controllers
local bedwars

local Knit = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)

bedwars = {
	GroundHit = getinstance("GroundHit", "RemoteEvent"),
	SetInvItem = getinstance("SetInvItem", "RemoteFunction"),
	PlaceBlock = getinstance("PlaceBlock", "RemoteFunction"),
	ChestGetItem = getinstance("Inventory/ChestGetItem", "RemoteFunction"),
    SetObservedChest = getinstance("Inventory/SetObservedChest", "RemoteEvent"),
	ConsumeItem = getinstance("ConsumeItem", "RemoteFunction"),
	ProjectileFire = getinstance("ProjectileFire", "RemoteFunction"),
	StepOnSnapTrap = getinstance("StepOnSnapTrap", "RemoteEvent"),
	TriggerInvisibleLandmine = getinstance("TriggerInvisibleLandmine", "RemoteEvent"),
	WeaponMeta = {
		Melee = {
            {"rageblade", 100},
            {"emerald_sword", 99},
            {"glitch_void_sword", 98},
            {"diamond_sword", 97},
            {"iron_sword", 96},
            {"stone_sword", 95},
            {"wood_sword", 94},
            {"emerald_dao", 93},
            {"diamond_dao", 99},
            {"iron_dao", 97},
            {"stone_dao", 96},
            {"wood_dao", 95},
            {"frosty_hammer", 1},
        }
	},
	Chests = {},
	Client = require(ReplicatedStorage.TS.remotes).default.Client,
	Store = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
    Knockback = require(getinstance("knockback-util", "ModuleScript")).KnockbackUtil,
	SwordController = Knit.Controllers.SwordController,
    SprintController = Knit.Controllers.SprintController,
	ProjectileController = Knit.Controllers.ProjectileController,
	ViewModel = workspace.CurrentCamera.Viewmodel.RightHand.RightWrist,
	Inventory = lplr.Character.InventoryFolder.Value,
	LastDamage = 0,
	GameTimeElapsed = {minutes = 0, seconds = 0},
	RayInfo = RaycastParams.new()
}

local oldget = clonefunction(bedwars.Client.Get)
bedwars.Client.Get = function(self, target)
	local val = oldget(self, target)

	if target == bedwars.SwordController.sendServerRequest then
		return {
			instance = val.instance,
			SendToServer = function(self2, data, ...)

				local entity = PlayerService:GetPlayerFromCharacter(data.entityInstance) or nil

				if entity then
					if Whitelist:Get(entity.UserId).type > Whitelist:Get(lplr.UserId).type then
						return
					end
				end

				return val:SendToServer(data, ...)
			end
		}
	end

	return val
end

local moonUsers = {}
TextChatService.OnIncomingMessage = function(message)
	local s, r = pcall(function()
		if message.Text then
			if not message.TextSource then
				return
			end

			local userid = message.TextSource.UserId
			if not userid then
				return
			end

			local player = PlayerService:GetPlayerByUserId(userid)
			if not player then
				return
			end

			local data = Whitelist:Get(userid)
			if not data then
				return
			end

			if message.Text:find("Ilikemoon") and tonumber(Whitelist:Get(lplr.UserId).type) > tonumber(data.type) then
				GuiLibrary:CreateNotification(player.DisplayName.." is using Moon!", 60)
				table.insert(moonUsers, userid)
			end

			if message.Text:find("Ilikemoon") then
				return
			end

			if tonumber(data.type) < 1 and table.find(moonUsers, userid) == nil then
				local newMessageProperties = Instance.new("TextChatMessageProperties")
				newMessageProperties.Text = message.Text
				newMessageProperties.PrefixText = message.PrefixText
				return newMessageProperties
			end

			local newMessage = string.format(
				"<font color='#%s'>[%s] %s:</font> ",
				data.color:ToHex(),
				data.tag,
				player.DisplayName
			)

			local newMessageProperties = Instance.new("TextChatMessageProperties")
			newMessageProperties.Text = message.Text
			newMessageProperties.PrefixText = newMessage
			return newMessageProperties
		end
	end)

	if s then return r end
end

for i,v in pairs(PlayerService:GetPlayers()) do
	pcall(function()
		if tonumber(Whitelist:Get(v.UserId).type) > tonumber(Whitelist:Get(lplr.UserId).type) then
			TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("/w "..v.Name.." Ilikemoon")
			TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("/w "..lplr.Name.." resetchannel")
		end
	end)
end

PlayerService.PlayerAdded:Connect(function(v)
	pcall(function()
		if tonumber(Whitelist:Get(v.UserId).type) > tonumber(Whitelist:Get(lplr.UserId).type) then
			TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("/w "..v.Name.." Ilikemoon")
			TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("/w "..lplr.Name.." resetchannel")
		end
	end)
end)

RunService.Heartbeat:Connect(function(deltaTime)
	bedwars.LastDamage = workspace:GetServerTimeNow() - lplr.Character:GetAttribute("LastDamageTakenTime")
	pcall(function()
		local gameTime = lplr.PlayerGui.TopBarAppGui.TopBarApp["2"]["5"].Text:split(":")
		bedwars.GameTimeElapsed.minutes, bedwars.GameTimeElapsed.seconds = tonumber(gameTime[1]), tonumber(gameTime[2])
	end)
end)

local function raycast(start, direction)
	return workspace:Raycast(start, direction, bedwars.RayInfo)
end

for i,v in pairs(workspace:GetChildren()) do
    if v.Name == "chest" then
        table.insert(bedwars.Chests, v)
    end
end

local function hasItem(item)
    if bedwars.Inventory:FindFirstChild(item) then
        return true
    end
    return false
end

local function shoot(item, direction, ammo)
    local pos = lplr.Character.PrimaryPart.Position
    local proj = Instance.new("Part", workspace)
    proj.Size = Vector3.new(1, 1, 1)
    proj.Position = pos + Vector3.new(0, 2, 0)
    proj.Velocity = direction * 3
	proj.CanCollide = false
    task.spawn(function()
        task.wait(5)
        if proj then proj:Destroy() end
    end)
    return bedwars.ProjectileFire:InvokeServer(item, ammo, ammo, proj.Position, pos, direction, HttpService:GenerateGUID(true), {
        drawDurationSeconds = 3,
        shotId = HttpService:GenerateGUID(false)
    }, workspace:GetServerTimeNow() - 0.01)
end

local function getItem(item)
    return bedwars.Inventory:FindFirstChild(item)
end

local switchItemSettings = {
	Whitelist = {}
}
local function switchItem(item)

	if #switchItemSettings.Whitelist > 0 then
		local foundwhitelisteditem = false
		for i,v in pairs(switchItemSettings.Whitelist) do
			if item.Name == v then
				foundwhitelisteditem = true
				break
			end
		end

		if not foundwhitelisteditem then
			return
		end
	end

	if hasItem(item.Name) then
		task.spawn(function()
			bedwars.SetInvItem:InvokeServer({hand = item})
		end)
	end
end

local blocksPlaced = {}
local function placeBlock(block, pos)
	task.spawn(function()

		pos = Vector3.new(math.round(pos.X / 3), math.round(pos.Y / 3), math.round(pos.Z / 3))
		if table.find(blocksPlaced, pos) ~= nil then
			bedwars.PlaceBlock:InvokeServer({
				blockType = block.Name,
				position = pos,
				blockData = 0
			})
		end

		table.insert(blocksPlaced, pos)
	end)
end

local function getWool()
	for i,v in pairs(bedwars.Inventory:GetChildren()) do
		if v.Name:lower():find("wool") then
			return v
		end
	end
end

local function getBows()
	local bows = {}

	for i,v in pairs(bedwars.Inventory:GetChildren()) do
		if v.Name:lower():find("bow") then
			table.insert(bows, v)
		end
	end

	return bows
end

local function getBestWeapon()
    local bestSword
    local bestSwordMeta = 0
    for i, v in pairs(bedwars.WeaponMeta.Melee) do
        local name = v[1]
        local meta = v[2]
        if meta > bestSwordMeta and hasItem(name) then
            bestSword = name
            bestSwordMeta = meta
        end
    end
    return bedwars.Inventory:FindFirstChild(bestSword)
end

local function getSpeed(base)

	if base == nil then
		base = 23

		if bedwars.LastDamage < 0.5 then
			base += 15
		end
	end

    if lplr.Character:GetAttribute("SpeedBoost") then
        base += 17
    end

    return base
end

local ClientPartHolder = Instance.new("Folder", workspace)

lplr.CharacterAdded:Connect(function(char)
	task.spawn(function()
		repeat task.wait() until char ~= nil
		task.wait(0.5)
		bedwars.Inventory = lplr.Character.InventoryFolder.Value
		bedwars.RayInfo = RaycastParams.new()
		bedwars.RayInfo.FilterDescendantsInstances = {lplr.Character, ClientPartHolder}
		bedwars.RayInfo.FilterType = Enum.RaycastFilterType.Exclude
		bedwars.RayInfo.RespectCanCollide = true
	end)
end)

bedwars.RayInfo = RaycastParams.new()
bedwars.RayInfo.FilterDescendantsInstances = {lplr.Character}
bedwars.RayInfo.FilterType = Enum.RaycastFilterType.Exclude

local oldrotation = bedwars.ViewModel.C0
local function isFirstPerson()
	if not EntityLib.isAlive(lplr) then return false end
	return (lplr.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 2
end

local AuraAnimations = {
	Normal = {
		{CFrame.new(0.7, -0.4, 0.6) * CFrame.Angles(math.rad(280), math.rad(60), math.rad(280)), 0.2},
		{CFrame.new(0.6, -0.4, 0.6) * CFrame.Angles(math.rad(200), math.rad(70), math.rad(10)), 0.2},
	},
	Tweak = {
		{CFrame.new(0.7, -0.4, 0.6) * CFrame.Angles(math.rad(280), math.rad(60), math.rad(280)), 0.1},
		{CFrame.new(0.6, -0.7, 0.6) * CFrame.Angles(math.rad(100), math.rad(70), math.rad(10)), 0.4},
	},
	Xenex = {
		{CFrame.new(0.4, -2, 0) * CFrame.Angles(math.rad(200), math.rad(80), math.rad(200)), 0.2},
		{CFrame.new(-0.2, -2, 0.6) * CFrame.Angles(math.rad(200), math.rad(80), math.rad(200)), 0.2},
	},
	Woah = {
		{CFrame.new(0.4, -2, 0) * CFrame.Angles(math.rad(200), math.rad(70), math.rad(190)), 0.2},
		{CFrame.new(-0.2, -2, 0.6) * CFrame.Angles(math.rad(200), math.rad(80), math.rad(3)), 0.2},
	},
	Funny = {
		{CFrame.new(0.7, -0, 0.6) * CFrame.Angles(math.rad(280), math.rad(60), math.rad(280)), 0.2},
		{CFrame.new(0.6, -0.2, 0.6) * CFrame.Angles(math.rad(200), math.rad(20), math.rad(10)), 0.1},
		{CFrame.new(0.7, -0.4, 0.6) * CFrame.Angles(math.rad(220), math.rad(60), math.rad(280)), 0.5},
		{CFrame.new(0.6, -0.6, 0.6) * CFrame.Angles(math.rad(200), math.rad(70), math.rad(10)), 0.2},
	},
}

local AuraAttacking = false
local AuraBox = Instance.new("Part", ClientPartHolder)
AuraBox.Size = Vector3.new(4,6,4)
AuraBox.Transparency = 0.5
AuraBox.Color = GuiLibrary.Theme
AuraBox.CFrame = CFrame.new(0,10000,0)
AuraBox.CanCollide = false
AuraBox.Anchored = true
local AuraBoxHighlight = Instance.new("Highlight", AuraBox)
AuraBoxHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
AuraBoxHighlight.OutlineTransparency = 1
AuraBoxHighlight.FillColor = GuiLibrary.Theme

Killaura = GuiLibrary.Windows.Combat.CreateModuleButton({
	Name = "Killaura",
	Function = function(callback)
		if callback then

			task.spawn(function()
				repeat

					if AuraAnim.Option ~= "None" then
						if AuraAttacking and isFirstPerson() then
							local Anim = AuraAnimations[AuraAnim.Option]
							for i,v in pairs(Anim) do
								TweenService:Create(bedwars.ViewModel, TweenInfo.new(v[2]), {C0 = oldrotation * v[1]}):Play()
								task.wait(v[2] - 0.05)
							end
						else
							TweenService:Create(bedwars.ViewModel, TweenInfo.new(0.1), {C0 = oldrotation}):Play()
						end
					end
					task.wait()
				until not Killaura.Enabled
			end)

			task.spawn(function()
				repeat
					if KillauraBox.Enabled then
						local Entity = EntityLib:GetNear(KillauraRange.Value)

						if Entity then
							AuraBox.Color = GuiLibrary.Theme
							AuraBox.CFrame = Entity.Character.PrimaryPart.CFrame
							AuraBoxHighlight.FillColor = GuiLibrary.Theme
						else
							AuraBox.CFrame = CFrame.new(0,1000,0)
						end
					end
					task.wait()
				until not Killaura.Enabled
			end)

			repeat
				local Entity = EntityLib:GetNear(KillauraRange.Value)
				
				if Entity and EntityLib.isAlive(lplr) then
					local weapon = getBestWeapon()

					switchItem(weapon)

					bedwars.Client:Get("SwordHit"):SendToServer({
						weapon = weapon,
						chargedAttack = {chargeRatio = 100},
						entityInstance = Entity.Character,
						validate = {
							targetPosition = {value = Entity.Character.PrimaryPart.Position + Vector3.new(Entity.Character.PrimaryPart.Velocity.X / 20, 0, Entity.Character.PrimaryPart.Velocity.Z / 20)},
							selfPosition = {value = lplr.Character.PrimaryPart.Position + Vector3.new(lplr.Character.PrimaryPart.Velocity.X / 20, 0, lplr.Character.PrimaryPart.Velocity.Z / 20)},
						}
					})

					GuiLibrary.TargetHud.SetTarget(Entity)

					if AutoHop.Enabled and lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
						lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.PrimaryPart.Velocity.X, 30, lplr.Character.PrimaryPart.Velocity.Z)
					end

					if (not isFirstPerson()) or AuraAnim.Option == "None" then
						bedwars.SwordController:swingSwordAtMouse()
					end

					AuraAttacking = true
				else
					GuiLibrary.TargetHud.Clear()
					AuraAttacking = false
				end
				task.wait()
			until not Killaura.Enabled
		else
			AuraAttacking = false
		end
	end,
})
AuraAnim = Killaura.CreatePicker({
	Name = "Animation",
	Options = {"None", "Normal", "Tweak", "Xenex", "Woah", "Funny"}
})
AutoHop = Killaura.CreateToggle({
	Name = "AutoHop"
})
KillauraBox = Killaura.CreateToggle({
	Name = "Box"
})
KillauraRange = Killaura.CreateSlider({
	Name = "Range",
	Default = 18,
	Min = 1,
	Max = 22,
	Step = 1
})

NoFallDamage = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "NoFallDamage",
	Function = function(callback)
		if callback then
			task.spawn(function()
                repeat
                    bedwars.GroundHit:FireServer()
                    task.wait(0.5)
                until not NoFallDamage.Enabled
            end)
		end
	end,
})

local origApplyVelocity = clonefunction(bedwars.Knockback.applyKnockback)
Velocity = GuiLibrary.Windows.Combat.CreateModuleButton({
	Name = "Velocity",
	Function = function(callback)
		if callback then
			bedwars.Knockback.applyKnockback = function(a, b, c, d)

                local percent = (VelocityPercent.Value + 0.001) / 100

                return origApplyVelocity(a, b * percent, c, d)
            end
		else
			bedwars.Knockback.applyKnockback = origApplyVelocity
		end
	end,
})

VelocityPercent = Velocity.CreateSlider({
	Name = "Percent",
	Default = 100,
	Min = 0,
	Max = 100,
	Step = 1
})

local FieldOfViewConnection
local FieldOfViewConnection2
FieldOfView = GuiLibrary.Windows.Render.CreateModuleButton({
	Name = "FieldOfView",
	Function = function(callback)
		if callback then

            workspace.CurrentCamera.FieldOfView = FieldOfViewSlider.Value

			FieldOfViewConnection = workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                workspace.CurrentCamera.FieldOfView = FieldOfViewSlider.Value
            end)

            FieldOfViewConnection2 = lplr.CharacterAdded:Connect(function()
                FieldOfViewConnection:Disconnect()
                FieldOfViewConnection = workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                    workspace.CurrentCamera.FieldOfView = FieldOfViewSlider.Value
                end)
            end)
		else
			pcall(function()
                FieldOfViewConnection:Disconnect()
                FieldOfViewConnection2:Disconnect()
            end)
		end
	end,
})

FieldOfViewSlider = FieldOfView.CreateSlider({
	Name = "FOV",
	Default = 120,
	Min = 30,
	Max = 120,
	Step = 1,
    Function = function(v)
        workspace.CurrentCamera.FieldOfView = v
    end
})

Sprint = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Sprint",
	Function = function(callback)
		if callback then
			task.spawn(function()
				repeat
					if not bedwars.SprintController.issprinting then
						bedwars.SprintController:startSprinting()
					end
					task.wait()
				until not Sprint.Enabled
			end)
		else
			bedwars.SprintController:stopSprinting()
		end
	end,
})

ChestStealer = GuiLibrary.Windows.World.CreateModuleButton({
	Name = "ChestStealer",
	Function = function(callback)
		if callback then
			task.spawn(function()
				repeat

					if EntityLib.isAlive(lplr) then
						for i, v in pairs(bedwars.Chests) do
							local dist = (v.Position - lplr.Character.PrimaryPart.Position).Magnitude
							if dist <= 18 then
								local folder = v.ChestFolderValue.Value
								if StealerOpenChest.Enabled then
									bedwars.SetObservedChest:FireServer(folder)
								end
								for i, v in pairs(folder:GetChildren()) do
									if v:IsA("Accessory") then
										task.spawn(function()
											bedwars.ChestGetItem:InvokeServer(folder, v)
										end)
									end
								end
								if StealerOpenChest.Enabled then
									bedwars.SetObservedChest:FireServer(nil)
								end
							end
						end
					end

					task.wait(0.1)
				until not ChestStealer.Enabled
			end)
		end
	end,
})

StealerOpenChest = ChestStealer.CreateToggle({
	Name = "Open Chest",
	Function = function() end,
})

local FlyRun
Fly = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Fly",
	Function = function(callback)
		if callback then
			FlyRun = RunService.Heartbeat:Connect(function()
				FlyVertSpeed = FlyVelo.Value
				if FlyVertical.Enabled then
					if UserInputService:IsKeyDown("Space") then
						FlyVertSpeed = FlyYSpeed.Value
					elseif UserInputService:IsKeyDown("LeftShift") then
						FlyVertSpeed = -FlyYSpeed.Value
					end
				end
				lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.PrimaryPart.Velocity.X, FlyVertSpeed, lplr.Character.PrimaryPart.Velocity.Z)
			end)
		else
			pcall(function()
                FlyRun:Disconnect()
            end)
		end
	end,
})
FlyVertical = Fly.CreateToggle({
	Name = "Vertical",
	Function = function() end,
})
FlyYSpeed = Fly.CreateSlider({
	Name = "Vertical Velocity",
	Default = 44,
	Min = 1,
	Max = 100,
	Step = 0.5
})
FlyVelo = Fly.CreateSlider({
	Name = "Velocity",
	Default = 0,
	Min = -10,
	Max = 10,
	Step = 0.5
})

local SpeedCon
Speed = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Speed",
	Function = function(callback)
		if callback then
			SpeedCon = RunService.Heartbeat:Connect(function(Delta)	
                pcall(function()
                    lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.Humanoid.MoveDirection.X * getSpeed(), lplr.Character.PrimaryPart.Velocity.Y, lplr.Character.Humanoid.MoveDirection.Z * getSpeed())
                end)		
			end)
		else
			pcall(function()
                SpeedCon:Disconnect()
            end)
		end
	end,
})

LagbackDetector = GuiLibrary.Windows.Utility.CreateModuleButton({
	Name = "LagbackDetector",
	Function = function(callback)
		if callback then
            local lagback = false
			task.spawn(function()
                repeat

					if EntityLib.isAlive(lplr) then
						if isnetworkowner(lplr.Character.PrimaryPart) then
							lagback = true
						else
	
							if lagback then
								GuiLibrary:CreateNotification("Lagback Detected!", 5)
							end
	
							lagback = false
						end
					end

                    task.wait()
                until not LagbackDetector.Enabled
            end)
		end
	end,
})

local espConnections = {}
local espSubInstances = {Names = {}}

local espTable = {Instances={}, DrawEsp = function(v)
	local ESP = Instance.new("BillboardGui", v.Character.PrimaryPart)
	ESP.Name = "MoonEsp"
	ESP.Size = UDim2.fromScale(4,6)
	ESP.StudsOffset = Vector3.new(0, 0, 0)
	ESP.AlwaysOnTop = true
	
	local Frame = Instance.new("Frame", ESP)
	Frame.Size = UDim2.fromScale(1,1)
	Frame.BackgroundTransparency = 1
	
	local Thickness = 1
	local Lines = {}
	for i = 1, 4 do
		Lines[i] = Instance.new("Frame", Frame)
		Lines[i].BackgroundColor3 = GuiLibrary.Theme
		Lines[i].BorderSizePixel = 0

		table.insert(espConnections, GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
			Lines[i].BackgroundColor3 = newTheme
		end))
	end
	
	Lines[1].Size = UDim2.new(1, 0, 0, Thickness)
	Lines[2].Size = UDim2.new(1, 0, 0, Thickness)
	Lines[2].Position = UDim2.new(0, 0, 1, -Thickness)
	Lines[3].Size = UDim2.new(0, Thickness, 1, 0)
	Lines[4].Size = UDim2.new(0, Thickness, 1, 0)
	Lines[4].Position = UDim2.new(1, -Thickness, 0, 0)

	local ESPName = Instance.new("TextLabel", ESP)
	ESPName.BackgroundTransparency = 0.5
	ESPName.BorderSizePixel = 0
	ESPName.TextScaled = true
	ESPName.Size = UDim2.new(0,TextService:GetTextSize(v.DisplayName, 9, ESPName.Font, Vector2.zero).X,0,15)
	ESPName.BackgroundColor3 = Color3.fromRGB(0,0,0)
	ESPName.TextColor3 = GuiLibrary.Theme
	ESPName.Visible = ESPNametags.Enabled
	ESPName.Text = v.DisplayName
	ESPName.AnchorPoint = Vector2.new(0.5,0.5)
	ESPName.Position = UDim2.fromScale(0.5,0)
	table.insert(espConnections, GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
		ESPName.TextColor3 = newTheme
	end))

	table.insert(espSubInstances.Names, ESPName)

	return ESP, Lines
end}

ESP = GuiLibrary.Windows.Render.CreateModuleButton({
	Name = "ESP",
	Function = function(callback)
		if callback then
			for i, v in pairs(PlayerService:GetPlayers()) do
				if v == lplr then continue end
				pcall(function()
					if not v.Character.PrimaryPart:FindFirstChild("MoonEsp") then
						local box, lines = espTable.DrawEsp(v)
						table.insert(espTable.Instances, {box, lines})
					end
				end)

				table.insert(espConnections, v.CharacterAdded:Connect(function(char)
					task.spawn(function()
						repeat task.wait() until char ~= nil
						local box, lines = espTable.DrawEsp(v)
						table.insert(espTable.Instances, {box, lines})
					end)
				end))
			end

			table.insert(espConnections, PlayerService.PlayerAdded:Connect(function(v)
				table.insert(espConnections, v.CharacterAdded:Connect(function(char)
					task.spawn(function()
						if v == lplr then return end
						repeat task.wait() until char ~= nil
						local box, lines = espTable.DrawEsp(v)
						table.insert(espTable.Instances, {box, lines})
					end)
				end))
			end))
			
		else

			for i,v in pairs(espConnections) do
				pcall(function()
					v:Disconnect()
				end)
			end

			for i,v in pairs(espTable.Instances) do
				pcall(function()
					table.clear(v[2])
					v[1]:Destroy()
				end)
			end

			table.clear(espTable.Instances)
			table.clear(espConnections)

		end
	end,
})

ESPNametags = ESP.CreateToggle({
	Name = "Names",
	Function = function(enabled)
		for i,v in pairs(espSubInstances.Names) do
			v.Visible = enabled
		end
	end,
})

--workspace.ItemDrops

PickupRange = GuiLibrary.Windows.Utility.CreateModuleButton({
	Name = "PickupRange",
	Function = function(callback)
		if callback then
            repeat
                    
				for i,v in pairs(workspace.ItemDrops:GetChildren()) do
					if not EntityLib.isAlive(lplr) then continue end
					local dist = (v.Position - lplr.Character.PrimaryPart.Position).Magnitude

					if dist <= 12 then			
						v.CFrame = lplr.Character.PrimaryPart.CFrame - Vector3.new(0,2,0)
					end
				end

				task.wait()
			until not PickupRange.Enabled
		end
	end,
})

Scaffold = GuiLibrary.Windows.World.CreateModuleButton({
	Name = "Scaffold",
	Function = function(callback)
		if callback then
			local startY = lplr.Character.PrimaryPart.Position.Y - 5
            repeat
                    
				local wool = getWool()

				if wool then
					startY = lplr.Character.PrimaryPart.Position.Y - 5
						local placePos = Vector3.new(lplr.Character.PrimaryPart.Position.X, startY, lplr.Character.PrimaryPart.Position.Z)
						placeBlock(wool, placePos)
						for i = 1, ScaffoldExpand.Value * 3 do
							if not Scaffold.Enabled then break end
							local dir = lplr.Character.Humanoid.MoveDirection
							if dir == Vector3.zero then
								dir = lplr.Character.PrimaryPart.CFrame.LookVector
							end
							placePos = Vector3.new(lplr.Character.PrimaryPart.Position.X, startY, lplr.Character.PrimaryPart.Position.Z)
							
							placeBlock(wool, (placePos + (dir * i)))
						end
				end

				task.wait(0.1)
			until not Scaffold.Enabled
		end
	end,
})

ScaffoldExpand = Scaffold.CreateSlider({
	Name = "Expand",
	Default = 1,
	Min = 0,
	Max = 10,
	Step = 1
})

AutoConsume = GuiLibrary.Windows.Utility.CreateModuleButton({
	Name = "AutoConsume",
	Function = function(callback)
		if callback then
            repeat
                    
				if hasItem("speed_potion") then
					bedwars.ConsumeItem:InvokeServer({item = getItem("speed_potion")})
				end

				task.wait()
			until not AutoConsume.Enabled
		end
	end,
})

ChestOpener = GuiLibrary.Windows.World.CreateModuleButton({
	Name = "ChestOpener",
	Function = function(callback)
		if callback then
            repeat
				for i,v in pairs(bedwars.Chests) do
					local folder = v.ChestFolderValue.Value
					bedwars.SetObservedChest:FireServer(folder)
				end
				bedwars.SetObservedChest:FireServer(nil)
				task.wait(2)
			until not ChestOpener.Enabled
		end
	end,
})

ChestESP = GuiLibrary.Windows.Render.CreateModuleButton({
	Name = "ChestESP",
	Function = function(callback)
		if callback then
            for i,v in pairs(bedwars.Chests) do
				local ESP = Instance.new("BillboardGui", v)
				ESP.Name = "MoonEsp"
				ESP.AlwaysOnTop = true
				ESP.StudsOffset = Vector3.new(0,3,0)
				ESP.Size = UDim2.fromScale(10,5)

				local ItemList = Instance.new("Frame", ESP)
				ItemList.Size = UDim2.fromScale(1, 1)
				ItemList.BackgroundTransparency = 1
				Instance.new("UIListLayout", ItemList)

				local folder = v.ChestFolderValue.Value
				for i,v in pairs(folder:GetChildren()) do
					if v.Name:lower():find("speed") or v.Name:lower():find("emerald") then
						local Item = Instance.new("TextLabel", ItemList)
						Item.Size = UDim2.new(0,TextService:GetTextSize(v.Name:gsub("_"," "), Item.TextSize, Item.Font, Vector2.zero).X,0,25)
						Item.Text = v.Name:gsub("_"," ")
						Item.BackgroundTransparency = 0.2
						Item.TextColor3 = Color3.fromRGB(255, 255, 255)
						Item.BackgroundColor3 = Color3.fromRGB(0,0,0)
						v.Destroying:Connect(function()
							Item:Destroy()
						end)
					end
				end
			end
		else
            for i,v in pairs(bedwars.Chests) do
				pcall(function()
					v.MoonEsp:Destroy()
				end)
			end
		end
	end,
})

local LongjumpDir, oldWSLJ
local LongjumpMethods = {
    fireball = function(item)

		table.insert(switchItemSettings.Whitelist, "fireball")

        switchItem(item)
        shoot(item, Vector3.new(0,-50,0), "fireball")

        local speedToggled = Speed.Enabled

        lplr.Character.PrimaryPart.Anchored = true
        
        repeat task.wait() until bedwars.LastDamage < 0.5 or not Longjump.Enabled
		table.clear(switchItemSettings.Whitelist)

        lplr.Character.PrimaryPart.Anchored = false

        if speedToggled then
            Speed:Toggle()
        end

        local startY = 21

        if LongjumpHigh.Enabled then
            startY = 60
        end

        local tic = tick()
        oldWSLJ = lplr.Character.Humanoid.WalkSpeed

        repeat
            local Velo = lplr.Character.PrimaryPart.Velocity
            local startSpeed = getSpeed(LongjumpSpeed.Value)
            local newVelo = Vector3.new(LongjumpDir.X * startSpeed, startY, LongjumpDir.Z * startSpeed)

            if bedwars.LastDamage > 1.2 then
                newVelo = Vector3.new(LongjumpDir.X * 23, startY * 1.5, LongjumpDir.Z * 23)
            end
            --lplr.Character.PrimaryPart.Velocity = newVelo
            lplr.Character.Humanoid.WalkSpeed = 0
            lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.PrimaryPart.Velocity.X, startY, lplr.Character.PrimaryPart.Velocity.Z)
            lplr.Character.PrimaryPart.CFrame += (LongjumpDir * startSpeed) * (tick() - tic)
            startY -= LongjumpHigh.Enabled and 0.16 or 0.1
            newVelo = Vector3.new(newVelo.X - 0.1, newVelo.Y, newVelo.Z - 0.1)
            tic = tick()

            if lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                startY = 21
            end

            task.wait()
        until not Longjump.Enabled
        lplr.Character.Humanoid.WalkSpeed = oldWSLJ

        if speedToggled and not Speed.Enabled then
            Speed:Toggle()
        end
        
        lplr.Character.PrimaryPart.Anchored = false
    end,
}

Longjump = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Longjump",
	Function = function(callback)
		if callback then

			LongjumpDir = lplr.Character.PrimaryPart.CFrame.LookVector
			for i,v in pairs(bedwars.Inventory:GetChildren()) do
				for i2,v2 in pairs(LongjumpMethods) do
					if v.Name:lower() == i2:lower() then
						v2(v)
						break
					end
				end
			end
		else
			lplr.Character.PrimaryPart.Anchored = false
		end
	end,
})
LongjumpHigh = Longjump.CreateToggle({
	Name = "High"
})
LongjumpSpeed = Longjump.CreateSlider({
	Name = "Speed",
	Default = 45,
	Min = 1,
	Max = 60,
	Step = 1
})

ProjectileAura = GuiLibrary.Windows.Combat.CreateModuleButton({
	Name = "ProjectileAura",
	Function = function(callback)
		if callback then
			repeat
				
				if EntityLib.isAlive(lplr) then
					local entity = EntityLib:GetNear(50)

					if entity and not AuraAttacking then

						local bows = getBows()

						for i,v in pairs(bows) do
							local Direction = (entity.Character.PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Unit
							local Distance = (entity.Character.PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Magnitude

							local travelTime = Distance / 25
							local predictionOffset = Vector3.new(entity.Character.PrimaryPart.Velocity.X, 0, entity.Character.PrimaryPart.Velocity) * travelTime

							local ray = raycast(lplr.Character.PrimaryPart.Position, Direction * 45)

							if ray == nil then
								continue
							end

							switchItem(v)
							task.wait(0.05)
							shoot(v, (Direction * Distance) + Vector3.new(0, (Distance / 15) + 10, 0) + predictionOffset, "arrow")
							task.wait(0.05)
						end 
						
						table.clear(bows)
					end
				end

				task.wait(0.15)
			until not ProjectileAura.Enabled
		end
	end,
})

local StaffDetectorConnection 
StaffDetector = GuiLibrary.Windows.Utility.CreateModuleButton({
	Name = "StaffDetector",
	Function = function(callback)
		if callback then
			StaffDetectorConnection = PlayerService.PlayerAdded:Connect(function(plr)

				if bedwars.GameTimeElapsed.seconds < 5 and bedwars.GameTimeElapsed.minutes < 1 then
					return
				end

				local isFriendWithSomeone = false
				for i, v in ipairs(PlayerService:GetPlayers()) do
					if plr ~= v and plr:IsFriendsWith(v.UserId) then
						isFriendWithSomeone = true
						break
					end
				end
			
				if not isFriendWithSomeone then
					GuiLibrary:CreateNotification("Staff Detected "..plr.DisplayName.."!", 60)
				end
			end)
		else
			pcall(function()
				StaffDetectorConnection:Disconnect()
			end)
		end
	end,
})

local AntivoidPart
Antivoid = GuiLibrary.Windows.World.CreateModuleButton({
	Name = "Antivoid",
	Function = function(callback)
		if callback then
			AntivoidPart = Instance.new("Part", ClientPartHolder)
			AntivoidPart.Size = Vector3.new(9999,1,9999)
			AntivoidPart.CanCollide = false
			AntivoidPart.CFrame = CFrame.new(0,-5,0)
			AntivoidPart.Color = GuiLibrary.Theme
			AntivoidPart.Transparency = 0.4
			AntivoidPart.Anchored = true

			local lastGroundPosition = lplr.Character.PrimaryPart.Position + Vector3.new(0,1000,0)
			repeat

				if EntityLib.isAlive(lplr) then
					pcall(function()
						if lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air and lplr.Character.PrimaryPart.Position.Y > (AntivoidPart.Position.Y + 10) then
							lastGroundPosition = lplr.Character.PrimaryPart.Position
						end
		
						if lplr.Character.PrimaryPart.Position.Y < AntivoidPart.Position.Y then
							while task.wait() and lplr.Character.PrimaryPart.Position.Y < lastGroundPosition.Y do
								local velo, pos = lplr.Character.PrimaryPart.Velocity, lplr.Character.PrimaryPart.Position
								lplr.Character.PrimaryPart.Velocity = Vector3.new(velo.X,100,velo.Z)
							end
	
							if AntivoidLimit.Enabled then
								lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.PrimaryPart.Velocity.X,45,lplr.Character.PrimaryPart.Velocity.Z)
							end
	
						end
					end)
				end

				AntivoidPart.Color = GuiLibrary.Theme
				task.wait()
			until not Antivoid.Enabled
		else
			pcall(function()
				AntivoidPart:Destroy()
			end)
		end
	end,
})
AntivoidLimit = Antivoid.CreateToggle({
	Name = "Limit"
})

local InfiniteJumpConnection
InfiniteJump = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "InfiniteJump",
	Function = function(callback)
		if callback then
			InfiniteJumpConnection = UserInputService.InputBegan:Connect(function(key, gpe)
				if gpe or not EntityLib.isAlive(lplr) then return end
				if key.KeyCode == Enum.KeyCode.Space then
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		else
			pcall(function()
				InfiniteJumpConnection:Disconnect()
			end)
		end
	end,
})

local oldParent = bedwars.StepOnSnapTrap.Parent
local oldParent2 = bedwars.TriggerInvisibleLandmine.Parent
TrapDisabler = GuiLibrary.Windows.Utility.CreateModuleButton({
	Name = "TrapDisabler",
	Function = function(callback)
		if callback then
			bedwars.StepOnSnapTrap.Parent = nil
			bedwars.TriggerInvisibleLandmine.Parent = nil
		else
			bedwars.StepOnSnapTrap.Parent = oldParent
			bedwars.TriggerInvisibleLandmine.Parent = oldParent2
		end
	end,
})
