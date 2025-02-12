local GuiLibrary = shared.GuiLibrary
local lplr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

local getSpeed = function(speedVal)
	speedVal = speedVal - lplr.Character.Humanoid.WalkSpeed
	
	return speedVal
end

local Speed, SpeedCon
Speed = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Speed",
	Function = function(callback)
		if callback then
			SpeedCon = RunService.Heartbeat:Connect(function(Delta)				
				if SpeedMode.Option == "Velocity" then
					lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.Humanoid.MoveDirection.X * getSpeed(SpeedSlider.Value + lplr.Character.Humanoid.WalkSpeed), lplr.Character.PrimaryPart.Velocity.Y, lplr.Character.Humanoid.MoveDirection.Z * getSpeed(SpeedSlider.Value + lplr.Character.Humanoid.WalkSpeed))
				elseif SpeedMode.Option == "CFrame" then
					lplr.Character.PrimaryPart.CFrame += (lplr.Character.Humanoid.MoveDirection * getSpeed(SpeedSlider.Value)) * Delta
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

local Fly, FlyVelo, FlyRun
Fly = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Fly",
	Function = function(callback)
		if callback then
			FlyRun = RunService.Heartbeat:Connect(function()
				lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.PrimaryPart.Velocity.X, FlyVelo.Value, lplr.Character.PrimaryPart.Velocity.Z)
			end)
		else
			FlyRun:Disconnect()
		end
	end,
})
FlyVelo = Fly.CreateSlider({
	Name = "Velocity",
	Default = 0,
	Min = -10,
	Max = 10,
	Step = 0.5
})

local Longjump, LongjumpSpeed, LongjumpVelo, LongjumpRun
Longjump = GuiLibrary.Windows.Movement.CreateModuleButton({
	Name = "Longjump",
	Function = function(callback)
		if callback then
			local goTo = lplr.Character.PrimaryPart.CFrame.LookVector
			lplr.Character.PrimaryPart.CFrame += Vector3.new(0, 2, 0)
			
			LongjumpRun = RunService.Heartbeat:Connect(function()
				lplr.Character.PrimaryPart.Velocity = Vector3.new(goTo.X * LongjumpSpeed.Value, LongjumpVelo.Value, goTo.Z * LongjumpSpeed.Value)
			end)
		else
			LongjumpRun:Disconnect()
		end
	end,
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
