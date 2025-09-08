--// Example AirflowUI
local AirflowUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/AirflowUI.lua"))()

local Window = AirflowUI:CreateWindow({
    Title = "Auto Summit GUI"
})

local MainTab = Window:CreateTab("Main")
MainTab:CreateButton({
    Name = "Teleport ke Basecamp",
    Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-6.8, 13.1, -7.8)
    end
})

local CreditsTab = Window:CreateTab("Credits")
CreditsTab:CreateButton({
    Name = "by ganteng",
    Callback = function()
        print("Mantap, dibuat oleh ganteng 😎")
    end
})
