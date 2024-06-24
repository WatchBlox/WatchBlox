repeat task.wait() until game:IsLoaded()

game.ReplicatedStorage.Alert.OnClientEvent:Connect(function(text)
	game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(text)
end)
