local PlayerService = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local lplr = PlayerService.LocalPlayer

local GuiLibrary = {
	ThemeUpdate = Instance.new("BindableEvent"),
	Theme = Color3.fromRGB(0, 200, 255),
	Windows = {}
}

local function darkenColor(clr, value)
	return Color3.fromRGB((clr.R * value) * 255,(clr.G * value) * 255,(clr.B * value) * 255)
end

local isfile = isfile or function(...)
	return false
end

local readfile = readfile or function(...)
	return '{"Toggles":[],"Sliders":[],"Pickers":[],"Buttons":[]}'
end

local isfolder = isfolder or function(...)
	return ...
end

local makefolder = makefolder or function(...)
	return ...
end

local writefile = writefile or function(...)
	return ...
end

local delfile = delfile or function(...)
	return ...
end

local start = tick()

local Config = {
	Buttons = {},
	Toggles = {},
	Sliders = {},
	Pickers = {}
}

if not isfolder("Moon") then
	makefolder("Moon")
	makefolder("Moon/Configs")
end

local canSave = true

local configPath = "Moon/Configs/"..game.PlaceId..".json"

local function saveconfig()
	if not canSave then return end

	if isfile(configPath) then
		delfile(configPath)
	end

	writefile(configPath, HttpService:JSONEncode(Config))
end

local function loadconfig()
	Config = HttpService:JSONDecode(readfile(configPath))
end

local Assets = {
	Glow = "rbxassetid://10822615828",
	Settings = "rbxassetid://11295281111",
	Info = "rbxassetid://11422155687",
	Success = "rbxassetid://11419719540",
	Error = "rbxassetid://11419709766",
	Circle = "rbxassetid://10928806245"
}

if not isfile(configPath) then
	saveconfig()
	task.wait()
end

loadconfig()

local ScreenGui = Instance.new("ScreenGui", gethui and gethui() or lplr.PlayerGui)
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local NotificationFrame = Instance.new("Frame", ScreenGui)
NotificationFrame.Size = UDim2.fromScale(0.3, 0.9)
NotificationFrame.Position = UDim2.fromScale(0.7,0)
NotificationFrame.BackgroundTransparency = 1
local NotificationFrameSorter = Instance.new("UIListLayout", NotificationFrame)
NotificationFrameSorter.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationFrameSorter.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationFrameSorter.Padding = UDim.new(0.015,0)

local ArrayListFrame = Instance.new("Frame", ScreenGui)
ArrayListFrame.Size = UDim2.fromScale(0.2,0.7)
ArrayListFrame.Position = UDim2.fromScale(0.7,0.2)
ArrayListFrame.BackgroundTransparency = 1
ArrayListFrame.Visible = false
local ArrayListFrameSorter = Instance.new("UIListLayout", ArrayListFrame)
ArrayListFrameSorter.HorizontalAlignment = Enum.HorizontalAlignment.Right
ArrayListFrameSorter.SortOrder = Enum.SortOrder.LayoutOrder

local function getAccurateTextSize(text, size)
	return TextService:GetTextSize(text, size, Enum.Font.SourceSans, Vector2.zero).X
end

local TargetHud = {}

local HudFrame = Instance.new("Frame", ScreenGui)
HudFrame.Size = UDim2.fromScale(0.14, 0.07)
HudFrame.Position = UDim2.fromScale(0.6, 0.4)
HudFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HudFrame.BackgroundTransparency = 0.5
HudFrame.BorderSizePixel = 0
HudFrame.Visible = false

local HudCorner = Instance.new("UICorner", HudFrame)
HudCorner.CornerRadius = UDim.new(0, 6)

local ProfileBack = Instance.new("Frame", HudFrame)
ProfileBack.Size = UDim2.fromScale(0.22, 0.9)
ProfileBack.Position = UDim2.fromScale(0.02, 0.05)
ProfileBack.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ProfileBack.BackgroundTransparency = 0.4
ProfileBack.BorderSizePixel = 0

local ProfileBackCorner = Instance.new("UICorner", ProfileBack)
ProfileBackCorner.CornerRadius = UDim.new(1, 0)

local ProfilePic = Instance.new("ImageLabel", ProfileBack)
ProfilePic.Size = UDim2.fromScale(1, 1)
ProfilePic.Position = UDim2.fromScale(0, 0)
ProfilePic.BackgroundTransparency = 1
ProfilePic.Image = ""
ProfilePic.Name = "ProfilePic"

local NameLabel = Instance.new("TextLabel", HudFrame)
NameLabel.Size = UDim2.fromScale(0.7, 0.4)
NameLabel.Position = UDim2.fromScale(0.28, 0.1)
NameLabel.BackgroundTransparency = 1
NameLabel.TextScaled = true
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.Text = ""
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Name = "NameLabel"

local HealthBack = Instance.new("Frame", HudFrame)
HealthBack.Size = UDim2.fromScale(0.7, 0.2)
HealthBack.Position = UDim2.fromScale(0.28, 0.65)
HealthBack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
HealthBack.BorderSizePixel = 0

local HealthBackCorner = Instance.new("UICorner", HealthBack)
HealthBackCorner.CornerRadius = UDim.new(1, 0)

local HealthBar = Instance.new("Frame", HealthBack)
HealthBar.Size = UDim2.fromScale(1, 1)
HealthBar.Position = UDim2.fromScale(0, 0)
HealthBar.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
HealthBar.BorderSizePixel = 0
HealthBar.Name = "HealthBar"

GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
	HealthBar.BackgroundColor3 = newTheme
end)

local HealthCorner = Instance.new("UICorner", HealthBar)
HealthCorner.CornerRadius = UDim.new(1, 0)

HealthBar.Parent = HealthBack
ProfileBack.Parent = HudFrame

local TargetHudEvent

function TargetHud.SetTarget(player)
    task.spawn(function()
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            HudFrame.Visible = true
            NameLabel.Text = player.Name
            ProfilePic.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&Format=Png&username=" .. player.Name

            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
				local healthPercentage = humanoid.Health / humanoid.MaxHealth
                TargetHudEvent = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
					task.spawn(function()
						healthPercentage = humanoid.Health / humanoid.MaxHealth
						TweenService:Create(HealthBar, TweenInfo.new(0.3), {
							Size = UDim2.fromScale(healthPercentage, 1)
						}):Play()

						HealthBar.BackgroundColor3 = GuiLibrary.Theme
					end)
				end)
                HealthBar.Size = UDim2.fromScale(healthPercentage, 1)
            end
        end
    end)
end

function TargetHud.Clear()
	task.spawn(function()
		HudFrame.Visible = false

		pcall(function()
			TargetHudEvent:Disconnect()
		end)
	end)
end

GuiLibrary.TargetHud = TargetHud

local ArrayItems = {}
local ArrayList = {
	Create = function(name)
		local Item = Instance.new("TextLabel", ArrayListFrame)
		Item.Text = name
		Item.TextSize = 22
		Item.TextColor3 = GuiLibrary.Theme
		Item.BackgroundTransparency = 0.5
		Item.BorderSizePixel = 0
		Item.Font = Enum.Font.SourceSans
		Item.ZIndex = 3

		local size = getAccurateTextSize(name, 22)

		Item.Size = UDim2.new(0.03, size, 0.048, 0)
		Item.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

		local Shadow = Item:Clone()
		Shadow.Parent = Item
		Shadow.TextColor3 = Color3.fromRGB(50,50,50)
		Shadow.Size = UDim2.fromScale(1,1)
		Shadow.Position = UDim2.fromScale(0.02,0.02)
		Shadow.ZIndex = 2		
		Shadow.BackgroundTransparency = 1
		Shadow.Name = "Shadow"
		Shadow.Visible = false

		local Line = Instance.new("Frame", Item)
		Line.Name = "Line"
		Line.Size = UDim2.new(0,3,1,0)
		Line.BorderSizePixel = 0
		Line.BackgroundColor3 = GuiLibrary.Theme
		Line.Position = UDim2.fromScale(1,0)

		ArrayItems[name] = Item

		local SortedArray = {}
		for i, v in pairs(ArrayItems) do
			table.insert(SortedArray, v)
		end

		table.sort(SortedArray, function(a, b)
			return getAccurateTextSize(a.Text, a.TextSize) > getAccurateTextSize(b.Text, b.TextSize)
		end)

		for i, v in ipairs(SortedArray) do
			v.LayoutOrder = i
		end
	end,

	Remove = function(name)
		pcall(function()
			if ArrayItems[name] then
				ArrayItems[name]:Destroy()
				ArrayItems[name] = nil
			end

			local SortedArray = {}
			for i, v in pairs(ArrayItems) do
				table.insert(SortedArray, v)
			end

			table.sort(SortedArray, function(a, b)
				return getAccurateTextSize(a.Text, a.TextSize) > getAccurateTextSize(b.Text, b.TextSize)
			end)

			for i, v in ipairs(SortedArray) do
				v.LayoutOrder = i
			end
		end)
	end,
}

task.spawn(function()
	repeat task.wait()
		pcall(function()

			local SortedArray = {}
			for i, v in pairs(ArrayItems) do
				table.insert(SortedArray, v)
			end

			table.sort(SortedArray, function(a, b)
				return getAccurateTextSize(a.Text, a.TextSize) > getAccurateTextSize(b.Text, b.TextSize)
			end)

			local index = 0
			for i,v in ipairs(SortedArray) do
				index += 1
				v.BackgroundTransparency = ArrayBackground.Enabled and 0.4 or 1
				v.Line.BackgroundTransparency = ArrayLine.Enabled and 0 or 1
				v.Shadow.Visible = ArrayShadow.Enabled

				if CustomThemeRainbow.Enabled then
					local hue = (tick() * 0.5 + (index / #SortedArray)) % 1
					local rainbowColor = Color3.fromHSV(hue, 1, 1)

					v.TextColor3 = rainbowColor
					v.Line.BackgroundColor3 = rainbowColor
				else
					v.TextColor3 = GuiLibrary.Theme
					v.Line.BackgroundColor3 = GuiLibrary.Theme
				end

			end

			table.clear(SortedArray)
		end)
	until false
end)

function GuiLibrary:CreateNotification(text, duration)

	local Notification = Instance.new("TextLabel", NotificationFrame)
	Notification.BorderSizePixel = 0
	Notification.BackgroundColor3 = Color3.fromRGB(40,40,40)
	Notification.Text = "  "..text
	Notification.TextColor3 = Color3.fromRGB(255,255,255)
	Notification.TextSize = 22
	Notification.TextXAlignment = Enum.TextXAlignment.Left
	Notification.Font = Enum.Font.SourceSans

	local size = getAccurateTextSize("  "..text, 22)

	Notification.Size = UDim2.new(0.05,size,0.055,0)

	local NotificationDuration = Instance.new("Frame", Notification)
	NotificationDuration.Size = UDim2.fromScale(1, 0.05)
	NotificationDuration.BorderSizePixel = 0
	NotificationDuration.BackgroundColor3 = GuiLibrary.Theme
	NotificationDuration.Position = UDim2.fromScale(0,0.95)

	local themeEvent = GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
		NotificationDuration.BackgroundColor3 = newTheme
	end)

	TweenService:Create(NotificationDuration, TweenInfo.new(duration + 0.3), {
		Size = UDim2.fromScale(0, 0.05)
	}):Play()

	task.delay(duration, function()
		TweenService:Create(Notification, TweenInfo.new(0.3), {
			Size = UDim2.fromScale(0, 0.055)
		}):Play()

		Debris:AddItem(Notification, 0.35)

		task.delay(0.35, function()
			themeEvent:Disconnect()
		end)
	end)
end

local WindowCount = 0
function GuiLibrary:CreateWindow(name)

	local Top = Instance.new("TextLabel", ScreenGui)
	Top.Size = UDim2.fromScale(0.1, 0.04)
	Top.Position = UDim2.fromScale(0.15 + (0.12 * WindowCount), 0.15)
	Top.BorderSizePixel = 0
	Top.BackgroundColor3 = Color3.fromRGB(40,40,40)
	Top.Text = "  "..name
	Top.TextColor3 = Color3.fromRGB(255,255,255)
	Top.TextSize = 12
	Top.TextXAlignment = Enum.TextXAlignment.Left

	local TopLine = Instance.new("Frame", Top)
	TopLine.Size = UDim2.fromScale(1,0.05)
	TopLine.Position = UDim2.fromScale(0,0.95)
	TopLine.BorderSizePixel = 0
	TopLine.BackgroundColor3 = GuiLibrary.Theme

	local TopLineSoftGlow = Instance.new("ImageLabel", Top)
	TopLineSoftGlow.BackgroundTransparency = 1
	TopLineSoftGlow.Image = Assets.Glow
	TopLineSoftGlow.Size = UDim2.fromScale(1.56,0.5)
	TopLineSoftGlow.ZIndex = 3
	TopLineSoftGlow.ImageColor3 = GuiLibrary.Theme
	TopLineSoftGlow.ImageTransparency = 0.8
	TopLineSoftGlow.Position = UDim2.fromScale(-0.3,0.725)

	GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
		TopLine.BackgroundColor3 = newTheme
		TopLineSoftGlow.ImageColor3 = newTheme
	end)

	local ModuleFrame = Instance.new("ScrollingFrame", Top)
	ModuleFrame.Position = UDim2.fromScale(0,1)
	ModuleFrame.Size = UDim2.fromScale(1,15)
	ModuleFrame.BackgroundTransparency = 1
	local ModuleFrameSorter = Instance.new("UIListLayout", ModuleFrame)
	ModuleFrameSorter.SortOrder = Enum.SortOrder.LayoutOrder

	local Modules = {}

	GuiLibrary.Windows[name] = {
		CreateModuleButton = function(tab)

			if Config.Buttons[tab.Name] == nil then
				Config.Buttons[tab.Name] = {Enabled = false, Keybind = "Unknown"}
			end

			local Button = Instance.new("TextButton", ModuleFrame)
			Button.Size = UDim2.fromScale(1,0.07)
			Button.BorderSizePixel = 0
			Button.BackgroundColor3 = Color3.fromRGB(50,50,50)
			Button.TextColor3 = Color3.fromRGB(255,255,255)
			Button.TextSize = 10
			Button.Text = "  "..tab.Name
			Button.TextXAlignment = Enum.TextXAlignment.Left
			Button.LayoutOrder = #ModuleFrame:GetChildren()
			Button.BorderSizePixel = 0

			local SettingsLogo = Instance.new("ImageLabel", Button)
			SettingsLogo.BackgroundTransparency = 1
			SettingsLogo.Image = Assets.Settings
			SettingsLogo.Size = UDim2.fromScale(0.16,0.8)
			SettingsLogo.Position = UDim2.fromScale(0.84,0.12)
			SettingsLogo.ZIndex = 4

			local SettingsFrame = Instance.new("Frame", ModuleFrame)
			SettingsFrame.Size = UDim2.fromScale(1,0)
			SettingsFrame.AutomaticSize = Enum.AutomaticSize.Y
			SettingsFrame.LayoutOrder = Button.LayoutOrder + 1
			SettingsFrame.Visible = false
			SettingsFrame.BackgroundTransparency = 1

			local KeybindButton = Instance.new("TextButton", SettingsFrame)
			KeybindButton.Size = UDim2.new(1, 0, 0, 30)
			KeybindButton.BorderSizePixel = 0
			KeybindButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
			KeybindButton.TextColor3 = Color3.fromRGB(255,255,255)
			KeybindButton.TextSize = 10
			KeybindButton.Text = "  Keybind: NONE"
			KeybindButton.TextXAlignment = Enum.TextXAlignment.Left
			KeybindButton.LayoutOrder = 1

			local KeybindConnection
			local Keybind = Enum.KeyCode.Unknown
			KeybindButton.MouseButton1Down:Connect(function()
				task.wait()
				UserInputService.InputBegan:Once(function(key, gpe)
					if gpe then return end
					if key.KeyCode == Keybind then
						Keybind = Enum.KeyCode.Unknown
						return
					end
					task.wait()
					Keybind = key.KeyCode

					KeybindButton.Text = "  Keybind: "..tostring(Keybind):split(".")[3]:upper()

					Config.Buttons[tab.Name].Keybind = tostring(Keybind):split(".")[3]:upper()
					task.delay(0.1, saveconfig)
				end)
			end)

			local KeybindSideLine = Instance.new("Frame", KeybindButton)
			KeybindSideLine.Size = UDim2.fromScale(0.015,1)
			KeybindSideLine.Position = UDim2.fromScale(0,0)
			KeybindSideLine.BorderSizePixel = 0
			KeybindSideLine.BackgroundColor3 = GuiLibrary.Theme

			
			GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
				KeybindSideLine.BackgroundColor3 = darkenColor(newTheme, 0.6)
			end)


			local SettingsFrameSorter = Instance.new("UIListLayout", SettingsFrame)
			SettingsFrameSorter.SortOrder = Enum.SortOrder.LayoutOrder
			SettingsFrameSorter.FillDirection = Enum.FillDirection.Vertical
			SettingsFrameSorter.VerticalAlignment = Enum.VerticalAlignment.Bottom

			local ButtonFunctions = {Enabled = false}
			local DuplicateButton
			local DuplicateConnection
			local DuplicateColorConnection
			local DuplicateB2Connection

			function ButtonFunctions:Toggle()
				ButtonFunctions.Enabled = not ButtonFunctions.Enabled

				if ButtonFunctions.Enabled then
					DuplicateButton = Button:Clone()
					DuplicateButton.ImageLabel:Destroy()
					DuplicateButton.ZIndex = 2
					DuplicateButton.Parent = Button
					DuplicateButton.Size = UDim2.fromScale(0,1)
					DuplicateButton.BackgroundColor3 = GuiLibrary.Theme
					TweenService:Create(DuplicateButton, TweenInfo.new(0.3), {
						Size = UDim2.fromScale(1,1)
					}):Play()

					DuplicateConnection = DuplicateButton.MouseButton1Down:Connect(function()
						ButtonFunctions:Toggle()
					end)
					DuplicateB2Connection = DuplicateButton.MouseButton2Down:Connect(function()
						SettingsFrame.Visible = not SettingsFrame.Visible
					end)
					DuplicateColorConnection = GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
						if CustomThemeRainbow.Enabled then
							DuplicateButton.BackgroundColor3 = darkenColor(newTheme,0.8)
							return
						end


						DuplicateButton.BackgroundColor3 = newTheme
					end)
					ArrayList.Create(tab.Name)
					GuiLibrary:CreateNotification("Module ".. tab.Name .." has been Enabled!", 1)
				else
					ArrayList.Remove(tab.Name)
					TweenService:Create(DuplicateButton, TweenInfo.new(0.3), {
						Size = UDim2.fromScale(0,1)
					}):Play()

					task.delay(0.3, function()
						DuplicateButton:Destroy()
						pcall(function()
							DuplicateConnection:Disconnect()
							DuplicateColorConnection:Disconnect()
							DuplicateB2Connection:Disconnect()
						end)
					end)

					GuiLibrary:CreateNotification("Module ".. tab.Name .." has been Disabled!", 1)
				end

				Config.Buttons[tab.Name].Enabled = ButtonFunctions.Enabled

				task.spawn(tab.Function, ButtonFunctions.Enabled)

				task.delay(0.1, saveconfig)
			end

			function ButtonFunctions.CreateToggle(tab2)
				local toggleKey = tab.Name.."_"..tab2.Name

				if type(Config.Toggles[toggleKey]) ~= "table" then
					Config.Toggles[toggleKey] = {Enabled = false}
				elseif Config.Toggles[toggleKey].Enabled == nil then
					Config.Toggles[toggleKey].Enabled = false
				end

				local Toggle = Instance.new("TextButton", SettingsFrame)
				Toggle.Size = UDim2.new(1, 0, 0, 30)
				Toggle.BorderSizePixel = 0
				Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
				Toggle.TextSize = 10
				Toggle.Text = "  " .. tab2.Name
				Toggle.TextXAlignment = Enum.TextXAlignment.Left

				local SettingsSideLine = Instance.new("Frame", Toggle)
				SettingsSideLine.Size = UDim2.fromScale(0.015, 1)
				SettingsSideLine.Position = UDim2.fromScale(0, 0)
				SettingsSideLine.BorderSizePixel = 0
				SettingsSideLine.BackgroundColor3 = darkenColor(GuiLibrary.Theme, 0.6)

				local ToggleFunctions = {Enabled = false}

				local FakeToggleText = Toggle:Clone()
				FakeToggleText.Frame:Destroy()
				FakeToggleText.Visible = false
				FakeToggleText.BackgroundTransparency = 1
				FakeToggleText.ZIndex = 6
				FakeToggleText.Parent = Toggle
				FakeToggleText.Size = UDim2.fromScale(1, 1)

				function ToggleFunctions:Toggle()
					ToggleFunctions.Enabled = not ToggleFunctions.Enabled

					if tab2.Function then
						tab2.Function(ToggleFunctions.Enabled)
					end

					if ToggleFunctions.Enabled then
						TweenService:Create(SettingsSideLine, TweenInfo.new(0.3), {
							Size = UDim2.fromScale(1, 1)
						}):Play()
						FakeToggleText.Visible = true
					else
						TweenService:Create(SettingsSideLine, TweenInfo.new(0.3), {
							Size = UDim2.fromScale(0.015, 1)
						}):Play()
						task.delay(0.3, function()
							FakeToggleText.Visible = false
						end)
					end

					if type(Config.Toggles[toggleKey]) ~= "table" then
						Config.Toggles[toggleKey] = {}
					end
					Config.Toggles[toggleKey].Enabled = ToggleFunctions.Enabled

					task.delay(0.1, saveconfig)
				end

				Toggle.MouseButton1Down:Connect(function()
					ToggleFunctions:Toggle()
				end)

				FakeToggleText.MouseButton1Down:Connect(function()
					ToggleFunctions:Toggle()
				end)

				if Config.Toggles[toggleKey].Enabled then
					ToggleFunctions:Toggle()
				end

				GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
					SettingsSideLine.BackgroundColor3 = darkenColor(newTheme, 0.6)
				end)

				return ToggleFunctions
			end


			function ButtonFunctions.CreatePicker(tab2)
				local pickerKey = tab.Name .. "_" .. tab2.Name
			
				if not Config.Pickers[pickerKey] or not Config.Pickers[pickerKey].Option then
					Config.Pickers[pickerKey] = { Option = tab2.Options[1] }
				end
			
				local Picker = Instance.new("TextButton", SettingsFrame)
				Picker.Size = UDim2.new(1, 0, 0, 30)
				Picker.BorderSizePixel = 0
				Picker.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				Picker.TextColor3 = Color3.fromRGB(255, 255, 255)
				Picker.TextSize = 10
				Picker.TextXAlignment = Enum.TextXAlignment.Left
			
				local SettingsSideLine = Instance.new("Frame", Picker)
				SettingsSideLine.Size = UDim2.fromScale(0.015, 1)
				SettingsSideLine.Position = UDim2.fromScale(0, 0)
				SettingsSideLine.BorderSizePixel = 0
				SettingsSideLine.BackgroundColor3 = GuiLibrary.Theme
			
				local PickerFunctions = { Option = Config.Pickers[pickerKey].Option }
			
				local function updatePickerText()
					Picker.Text = "  " .. tab2.Name .. ": " .. (PickerFunctions.Option or "N/A")
				end
			
				local index = table.find(tab2.Options, PickerFunctions.Option) or 1
			
				function PickerFunctions:Select(selection)
					if selection == nil then
						index = index % #tab2.Options + 1
					else
						for i, v in ipairs(tab2.Options) do
							if v:lower() == selection:lower() then
								index = i
								break
							end
						end
					end
			
					PickerFunctions.Option = tab2.Options[index] or tab2.Options[1]
					Config.Pickers[pickerKey].Option = PickerFunctions.Option
					updatePickerText()
					task.delay(0.1, saveconfig)
			
					if tab2.Function then
						tab2.Function(PickerFunctions.Option)
					end
				end
			
				Picker.MouseButton1Down:Connect(function()
					PickerFunctions:Select()
				end)

				GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
					SettingsSideLine.BackgroundColor3 = darkenColor(newTheme, 0.6)
				end)
			
				updatePickerText()
				return PickerFunctions
			end
			
			

			function ButtonFunctions.CreateSlider(tab2)

				if Config.Sliders[tab.Name.."_"..tab2.Name] == nil then
					Config.Sliders[tab.Name.."_"..tab2.Name] = {Value = tab2.Default}
				end

				local SliderFrame = Instance.new("Frame", SettingsFrame)
				SliderFrame.Size = UDim2.new(1, 0, 0, 40)
				SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				SliderFrame.BorderSizePixel = 0

				local SettingsSideLine = Instance.new("Frame", SliderFrame)
				SettingsSideLine.Size = UDim2.fromScale(0.015,1)
				SettingsSideLine.Position = UDim2.fromScale(0,0)
				SettingsSideLine.BorderSizePixel = 0
				SettingsSideLine.BackgroundColor3 = Color3.fromRGB(30,30,30)

				local SliderName = Instance.new("TextLabel", SliderFrame)
				SliderName.Size = UDim2.new(1, 0, 0.5, 0)
				SliderName.Position = UDim2.new(0, 5, 0, 0)
				SliderName.Text = tab2.Name .. " (" .. tab2.Default .. ")"
				SliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
				SliderName.BackgroundTransparency = 1
				SliderName.TextXAlignment = Enum.TextXAlignment.Center
				SliderName.TextSize = 10

				local SliderBar = Instance.new("Frame", SliderFrame)
				SliderBar.Size = UDim2.fromScale(0.7, 0.3)
				SliderBar.Position = UDim2.fromScale(0.15, 0.55)
				SliderBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
				SliderBar.ClipsDescendants = true
				local SliderBarRound = Instance.new("UICorner", SliderBar)

				local SliderFill = Instance.new("Frame", SliderBar)
				SliderFill.Size = UDim2.new(0, 0, 1, 0)
				SliderFill.BackgroundColor3 = Color3.fromRGB(30,30,30)
				local SliderFillRound = Instance.new("UICorner", SliderFill)

				local SliderButton = Instance.new("TextButton", SliderBar)
				SliderButton.Size = UDim2.fromScale(0.1,1)
				SliderButton.Position = UDim2.fromScale(0,0)
				SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SliderButton.AutoButtonColor = false
				SliderButton.Text = ""
				SliderButton.BorderSizePixel = 0
				local SliderButtonRound = Instance.new("UICorner", SliderButton)
				SliderButtonRound.CornerRadius = UDim.new(1,0)

				local SliderFunctions = {}
				SliderFunctions.Value = tab2.Default

				function SliderFunctions.UpdateSlide(inputX)
					local barSize = SliderBar.AbsoluteSize.X
					local relativeX = math.clamp((inputX - SliderBar.AbsolutePosition.X) / barSize, 0, 1)
					local value = math.floor((relativeX * (tab2.Max - tab2.Min) + tab2.Min) / tab2.Step) * tab2.Step

					SliderFunctions.Value = value
					Config.Sliders[tab.Name.."_"..tab2.Name].Value = value
					SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
					SliderName.Text = tab2.Name .. " (" .. value .. ")"

					TweenService:Create(SliderButton, TweenInfo.new(0.1), {Position = UDim2.new(relativeX, -7, 0, 0)}):Play()

					if tab2.Function then
						tab2.Function(value)
					end

					task.delay(0.1,saveconfig)

					return value
				end


				function SliderFunctions.Input(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local moveConnection, releaseConnection

						local initialX = input.Position.X
						local snapPosition = (initialX - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
						snapPosition = math.clamp(snapPosition, 0, 1)
						SliderFunctions.UpdateSlide(SliderBar.AbsolutePosition.X + snapPosition * SliderBar.AbsoluteSize.X)

						moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
							if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
								SliderFunctions.UpdateSlide(moveInput.Position.X)
							end
						end)

						releaseConnection = UserInputService.InputEnded:Connect(function(releaseInput)
							if releaseInput.UserInputType == Enum.UserInputType.MouseButton1 then
								moveConnection:Disconnect()
								releaseConnection:Disconnect()
							end
						end)
					end
				end

				function SliderFunctions.SetValue(value)
					SliderFunctions.Value = value
					Config.Sliders[tab.Name.."_"..tab2.Name].Value = value
					SliderFill.Size = UDim2.new((value - tab2.Min) / (tab2.Max - tab2.Min), 0, 1, 0)
					SliderName.Text = tab2.Name .. " (" .. value .. ")"
					TweenService:Create(SliderButton, TweenInfo.new(0.1), {Position = UDim2.new((value - tab2.Min) / (tab2.Max - tab2.Min), -7, 0, 0)}):Play()
					if tab2.Function then
						tab2.Function(value)
					end
					task.delay(0.1,saveconfig)
				end

				SliderFunctions.SetValue(Config.Sliders[tab.Name.."_"..tab2.Name].Value)

				SliderButton.InputBegan:Connect(SliderFunctions.Input)
				SliderBar.InputBegan:Connect(SliderFunctions.Input)

				GuiLibrary.ThemeUpdate.Event:Connect(function(newTheme)
					SettingsSideLine.BackgroundColor3 = darkenColor(newTheme, 0.6)
					SliderFill.BackgroundColor3 = darkenColor(newTheme, 0.6)
				end)

				return SliderFunctions
			end


			Button.MouseButton1Down:Connect(function()
				ButtonFunctions:Toggle()
			end)

			Button.MouseButton2Down:Connect(function()
				SettingsFrame.Visible = not SettingsFrame.Visible
			end)

			UserInputService.InputBegan:Connect(function(key, gpe)
				if gpe or key.KeyCode ~= Keybind or Keybind == Enum.KeyCode.Unknown then return end
				ButtonFunctions:Toggle()
			end)

			if Config.Buttons[tab.Name].Enabled then
				task.delay(0.5, function()
					ButtonFunctions:Toggle()
				end)
			end

			Keybind = Enum.KeyCode[Config.Buttons[tab.Name].Keybind]
			if Keybind ~= Enum.KeyCode.Unknown then
				KeybindButton.Text = "  Keybind: "..Config.Buttons[tab.Name].Keybind
			end

			table.insert(Modules, ButtonFunctions)

			return ButtonFunctions
		end,
		Toggle = function()
			Top.Visible = not Top.Visible
		end,
		GetModules = function()
			return Modules
		end,
	}

	WindowCount += 1
end

UserInputService.InputBegan:Connect(function(key, gpe)
	if gpe or key.KeyCode ~= Enum.KeyCode.RightShift then
		return
	end

	for i,v in pairs(GuiLibrary.Windows) do
		v:Toggle()
	end
end)

GuiLibrary:CreateWindow("Combat")
GuiLibrary:CreateWindow("Movement")
GuiLibrary:CreateWindow("Render")
GuiLibrary:CreateWindow("World")
GuiLibrary:CreateWindow("Utility")

local origArraySize = ArrayListFrame.Size
ArrayListModule = GuiLibrary.Windows.Render.CreateModuleButton({
	Name = "ArrayList",
	Function = function(callback)
		ArrayListFrame.Visible = callback

		task.spawn(function()
			repeat

				local suc, ret = pcall(function()
					return ArrayScale.Value / 100
				end)

				if suc then
					ArrayListFrame.Size = UDim2.fromScale(origArraySize.X.Scale * ret, origArraySize.Y.Scale * ret)
				end

				task.wait()
			until not ArrayListModule.Enabled
		end)
	end,
})

ArrayBackground = ArrayListModule.CreateToggle({
	Name = "Background",
	Function = function() end,
})

ArrayLine = ArrayListModule.CreateToggle({
	Name = "Line",
	Function = function() end,
})

ArrayShadow = ArrayListModule.CreateToggle({
	Name = "Shadow",
	Function = function() end,
})

ArrayScale = ArrayListModule.CreateSlider({
	Name = "Scale",
	Default = 100,
	Min = 0,
	Max = 100,
	Step = 1,
})

CustomTheme = GuiLibrary.Windows.Render.CreateModuleButton({
	Name = "CustomTheme",
	Function = function(callback)
		if callback then
			task.spawn(function()
				local last = GuiLibrary.Theme
				repeat
					pcall(function()
						if CustomThemeRainbow.Enabled then
							local hue = (tick() * 0.5 + (0.1)) % 1
							local rainbowColor = Color3.fromHSV(hue, 1, 1)
							GuiLibrary.Theme = rainbowColor
							GuiLibrary.ThemeUpdate:Fire(GuiLibrary.Theme)
						else
							GuiLibrary.Theme = Color3.fromRGB(CustomThemeColorRed.Value,CustomThemeColorGreen.Value,CustomThemeColorBlue.Value)

							if GuiLibrary.Theme ~= last then
								GuiLibrary.ThemeUpdate:Fire(GuiLibrary.Theme)
							end

							last = GuiLibrary.Theme
						end
					end)
					task.wait()
				until not CustomTheme.Enabled
			end)
		else
			task.delay(0.1, function()
				GuiLibrary.Theme = Color3.fromRGB(0, 200, 255)
			end)
		end
	end,
})

CustomThemeRainbow = CustomTheme.CreateToggle({
	Name = "Rainbow",
	Function = function() end,
})

CustomThemeColorRed = CustomTheme.CreateSlider({
	Name = "Red",
	Default = 0,
	Min = 0,
	Max = 255,
	Step = 1,
})

CustomThemeColorGreen = CustomTheme.CreateSlider({
	Name = "Green",
	Default = 200,
	Min = 0,
	Max = 255,
	Step = 1
})

CustomThemeColorBlue = CustomTheme.CreateSlider({
	Name = "Blue",
	Default = 255,
	Min = 0,
	Max = 255,
	Step = 1
})

Uninject = GuiLibrary.Windows.Utility.CreateModuleButton({
	Name = "Uninject",
	Function = function(callback)
		canSave = false
		task.wait(0.5)
		for i,v in pairs(GuiLibrary.Windows) do
			for i2,v2 in pairs(v:GetModules()) do
				if v2.Enabled then
					v2:Toggle()
				end
			end
		end

		ScreenGui:Destroy()
		shared.GuiLibrary = nil
	end,
})

shared.GuiLibrary = GuiLibrary
