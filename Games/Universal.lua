local GuiLibrary = shared.GuiLibrary
local lplr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local oldGravity = workspace.Gravity

local getSpeed = function(speedVal, Delta, removeWs: boolean, Mode)
	speedVal = speedVal - (removeWs and lplr.Character.Humanoid.WalkSpeed or 0)

	if Mode == "Velocity" then
		return Vector3.new(lplr.Character.Humanoid.MoveDirection.X * speedVal, lplr.Character.PrimaryPart.Velocity.Y, lplr.Character.Humanoid.MoveDirection.Z * speedVal)
	end
	
	return (lplr.Character.Humanoid.MoveDirection * speedVal) * Delta
end

local Speed, SpeedCon
Speed = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Speed",
	Function = function(callback)
		if callback then
			SpeedCon = RunService.Heartbeat:Connect(function(Delta)				
				if SpeedMode.Option == "Velocity" then
					lplr.Character.PrimaryPart.Velocity = getSpeed(SpeedSlider.Value, Delta, false, SpeedMode.Option)
				elseif SpeedMode.Option == "CFrame" then
					lplr.Character.PrimaryPart.CFrame += getSpeed(SpeedSlider.Value, Delta, true, SpeedMode.Option))
				end
			end)
		else
			SpeedCon:Disconnect()
		end
	end,
})
SpeedMode = Speed.CreatePicker({
	Name = "Mode",
	Options = {"CFrame", "Velocity"}
})
SpeedSlider = Speed.CreateSlider({
	Name = "Speed",
	Default = 16,
	Min = 1,
	Max = 50,
	Step = 1
})

local Fly, FlyVelo, FlyRun, FlyVertSpeed
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
			FlyRun:Disconnect()
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

local Longjump, LongjumpSpeed, LongjumpVelo, LongjumpRun, speeds
speeds = {x = 1,y = 1,z = 1}

Longjump = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Longjump",
	Function = function(callback)
		if callback then
			local goTo = lplr.Character.PrimaryPart.CFrame.LookVector
			lplr.Character.PrimaryPart.CFrame += Vector3.new(0, 2, 0)

			workspace.Gravity = 30
			
			LongjumpRun = RunService.Heartbeat:Connect(function()
				speeds.y = LongjumpJumpMode.Option == "Velocity" and LongjumpVelo.Value or lplr.Character.PrimaryPart.Velocity.Y
				speeds.x = LongjumpDirMode.Option == "NoMovement" and goTo.X * LongjumpSpeed.Value or lplr.Character.Humanoid.MoveDirection.X * LongjumpSpeed.Value
				speeds.z = LongjumpDirMode.Option == "NoMovement" and goTo.X * LongjumpSpeed.Value or lplr.Character.Humanoid.MoveDirection.Z * LongjumpSpeed.Value

				lplr.Character.PrimaryPart.Velocity = Vector3.new(speeds.x, speeds.y, speeds.z)

				if LongjumpJumpMode.Option == "Jump" and lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)

			if LongjumpJumpMode.Option == "Jump" then
				repeat task.wait() until lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air
				Longjump:Toggle()
			end
		else
			workspace.Gravity = oldGravity
			LongjumpRun:Disconnect()
		end
	end,
})
LongjumpDirMode = Longjump.CreatePicker({
	Name = "Jump Mode",
	Options = {"NoMovement", "Movement"}
})
LongjumpJumpMode = Longjump.CreatePicker({
	Name = "Jump Mode",
	Options = {"Velocity", "Jump"}
})
LongjumpSpeed = Longjump.CreateSlider({
	Name = "Speed",
	Default = 16,
	Min = 1,
	Max = 50,
	Step = 1
})
LongjumpVelo = Longjump.CreateSlider({
	Name = "VelocityY",
	Default = 2.5,
	Min = 0,
	Max = 50,
	Step = 1
})

Gravity = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Gravity",
	Function = function(callback)
		if callback then
			repeat
				workspace.Gravity = GravityVal.Value
				task.wait()
			until not Gravity.Enabled
		else
			workspace.Gravity = oldGravity
		end
	end
})
GravityVal = Gravity.CreateSlider({
	Name = "Value",
	Default = 196,
	Min = 0,
	Max = 500,
	Step = 0.5
})

local toteleport = Vector3.zero
Teleport = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Teleport",
	Function = function(callback)
		if callback then
			if TeleportMode.Option == "MousePos" and lplr:GetMouse().Hit ~= nil then
				local posToTP = lplr:GetMouse().Hit + Vector3.new(0,5,0)

				lplr.Character.PrimaryPart.CFrame = CFrame.new(posToTP)
			elseif TeleportMode.Option == "Vec3" then
				lplr.Character.PrimaryPart.CFrame = CFrame.new(toteleport)
			end
		end
	end
})
TeleportMode = Teleport.CreatePicker({
	Name = "Mode",
	Options = {"MousePos", "Vec3"}
})
TeleportX = Teleport.CreateSlider({
	Name = "X", Default = 0, Min = -500, Max = 500, Step = 5,
	Function = function(value)
		toteleport = Vector3.new(value, toteleport.Y, toteleport.Z)
	end,
})
TeleportY = Teleport.CreateSlider({
	Name = "Y", Default = 0, Min = -500, Max = 500, Step = 5,
	Function = function(value)
		toteleport = Vector3.new(toteleport.X, value, toteleport.Z)
	end,
})
TeleportZ = Teleport.CreateSlider({
	Name = "Z", Default = 0, Min = -500, Max = 500, Step = 5,
	Function = function(value)
		toteleport = Vector3.new(toteleport.X, toteleport.Y, value)
	end,
})

Highjump = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Highjump",
	Function = function(callback)
		if callback then
			repeat
				lplr.Character.PrimaryPart.Velocity += Vector3.new(lplr.Character.PrimaryPart.Velocity.X, HighjumpVal.Value, lplr.Character.PrimaryPart.Velocity.Z)
				task.wait()
			until not Highjump.Enabled
		else
			if HighjumpFS.Enabled then
				lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.PrimaryPart.Velocity.X, 10, lplr.Character.PrimaryPart.Velocity.Z)
			end
		end
	end,
})
HighjumpFS = Highjump.CreateToggle({
	Name = "Fast Stop",
})
HighjumpVal = Highjump.CreateSlider({
	Name = "Value",
	Default = 0,
	Min = 0,
	Max = 25,
	Step = 0.5
})
