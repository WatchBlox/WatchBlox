repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local canSendCPS = true
local CPS = 0

AddCPS = function()
	CPS += 1
	task.delay(1, function()
		CPS -= 1
	end)
end

LocalPlayer:GetMouse().Button1Down:Connect(AddCPS)

task.spawn(function()
	repeat
		game.ReplicatedStorage.CPS:FireServer(CPS)
		task.wait(0.1)
	until false
end)
