Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")

kickWaveTable = {}
config = require(script.Config)

CompareVec2 = function(v1)
	return Vector3.new(v1.X, 0, v1.Z)
end

script.Remotes.Alert.Parent = ReplicatedStorage
script.Remotes.CPS.Parent = ReplicatedStorage

script.Scripts.AntiCheat.Parent = game.StarterPlayer.StarterPlayerScripts

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		local PrimaryPart = Character.PrimaryPart
		local Humanoid = Character.Humanoid
		local inAir = Humanoid.FloorMaterial == Enum.Material.Air
		local onGround = Humanoid.FloorMaterial ~= Enum.Material.Air
		
		local airTick = 0
		local groundTick = 0
		local Flags = 0
		local joinedTicks = 0
		local lastLadderTicks = 11
		local playerCPS = 0
		local lastPlayerCPS = 0
		
		local lastPos = PrimaryPart.Position
		local lastPosOnGround = PrimaryPart.Position
		
		local setBackPlayer = function(Check : string)
			ReplicatedStorage:WaitForChild("Alert"):FireAllClients("<font color=\'rgb(230,255,176)\'>WatchBlox </font> has been flagged for <font color=\'rgb(230,255,176)\'>".. Check:upper() .." </font>")
			
			PrimaryPart.Position = lastPosOnGround
			PrimaryPart.Velocity = Vector3.zero
			Character.PrimaryPart:SetNetworkOwner(nil)
			task.delay(0.25, function()
				Character.PrimaryPart:SetNetworkOwner(Player)
			end)
		end
		
		game.ReplicatedStorage.CPS.OnServerEvent:Connect(function(v, v2)
			if v == Player then playerCPS = v2 end
		end)
		
		
		local thresholdCPSValue = 0
		local thresholdCPSValue2 = 0
		spawn(function()
			repeat
				if playerCPS == lastPlayerCPS and playerCPS > 20 then
					thresholdCPSValue += 1
					if thresholdCPSValue > 20 then
						Flags += 1
						setBackPlayer("Invalid_CPS")
						thresholdCPSValue = 0
					end
				else
					if thresholdCPSValue > 0 then
						thresholdCPSValue -= 0.05
					end
				end

				if playerCPS > 35 then
					thresholdCPSValue2 += 1
					if thresholdCPSValue2 > 20 then
						Flags += 1
						setBackPlayer("Invalid_CPS")
						thresholdCPSValue2 = 0
					end
				else
					if thresholdCPSValue2 > 0.05 then
						thresholdCPSValue2 -= 0.05
					end
				end
				task.wait()
			until Humanoid.Health < 0.1
		end)
		
		spawn(function()
			repeat
				joinedTicks += 1
				
				local Params = RaycastParams.new()
				Params.FilterType = Enum.RaycastFilterType.Exclude
				Params.FilterDescendantsInstances = {Character}
				
				local checkOnGround = workspace:Raycast(PrimaryPart.Position,PrimaryPart.CFrame.LookVector - Vector3.new(0, 4.5, 0), Params) and true or false
				local partInfrontOfPlayer = workspace:Raycast(PrimaryPart.Position,PrimaryPart.CFrame.LookVector * 3, Params)
								
				if partInfrontOfPlayer and partInfrontOfPlayer.Instance.ClassName == "TrussPart" then
					lastLadderTicks = 0
				else
					lastLadderTicks += 1
				end
				
				if joinedTicks > 30 then
					local Magnitude = (CompareVec2(PrimaryPart.Position) - CompareVec2(lastPos)).Magnitude
					if Magnitude > 2.2 and lastLadderTicks > 10 then
						Flags += 1
						setBackPlayer("Speed")
					end
					
					local maxAirticks = airTick * 0.875
					if airTick > 13 and PrimaryPart.Velocity.Y > -maxAirticks and lastLadderTicks > 10 then
						Flags += 1
						airTick = 0
						setBackPlayer("Fly")
					end
					
					if airTick > 4 and PrimaryPart.Velocity.Y > 1 and lastLadderTicks > 10 and partInfrontOfPlayer then
						print(PrimaryPart.Velocity.Y)
						Flags += 1
						setBackPlayer("Step")
					end
					
					local Magnitude2 = (PrimaryPart.Position.Y - lastPos.Y)
					local newThresFastLadder = 0
					if lastLadderTicks == 0 and Magnitude2 > 2 then
						newThresFastLadder += 1
						if newThresFastLadder > 2 then
							Flags += 1
							setBackPlayer("Fast_Ladder")
							newThresFastLadder = 0
						end
					else
						newThresFastLadder -= 0.5
					end
					
					local Magnitude3 = (PrimaryPart.Position.Y - lastPos.Y)
					local airCheck1 = (airTick > 8)
					local airCheck2 = (airTick < 3)
					local max1 = 5.5
					local max2 = 0.1
					
					local maxThresForBadJump = 0
					if ((airCheck1 and Magnitude3 > max2) or (airCheck2 and Magnitude3 > max1)) and lastLadderTicks > 10 then
						maxThresForBadJump += 1
						if maxThresForBadJump > 6 then
							Flags += 1
							setBackPlayer("Invalid_Jump")
							maxThresForBadJump = 0
						end
					else
						if maxThresForBadJump >= 0.25 then
							maxThresForBadJump -= 0.25
						end
					end
				end

				if Flags > 25 then
					if not table.find(kickWaveTable, Player) then
						table.insert(kickWaveTable, Player)
					end
					Flags = 0
				end
				
				Humanoid = Character.Humanoid
				PrimaryPart = Character.PrimaryPart
				inAir = Humanoid.FloorMaterial == Enum.Material.Air
				onGround = (Humanoid.FloorMaterial ~= Enum.Material.Air or checkOnGround)
				lastPos = PrimaryPart.Position
				lastPlayerCPS = playerCPS
				
				if inAir then
					airTick += 1
					groundTick = 0
				end
				if onGround then
					airTick = 0
					groundTick += 1
					lastPosOnGround = PrimaryPart.Position
				end
				task.wait(0.1)
			until Humanoid.Health < 0.1
		end)
	end)
end)

kickWave = function(kickTable)
	repeat
		for i,v in pairs(kickTable) do
			if config.Kicking then
				v:Kick("You have been kicked for Cheating (WATCHBLOX CHEAT DETECTION)")
			end
		end
		task.wait(math.random(10, 25))
	until false
end

task.spawn(kickWave(kickWaveTable))
