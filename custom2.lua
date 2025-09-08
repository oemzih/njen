--// siZhens Custom Framework
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "siZhensUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "siZhens Universal GUI"
Title.TextColor3 = Color3.fromRGB(200, 100, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- ContentFrame tempat menu nempel
local Content = Instance.new("Frame")
Content.Name = "MainContent"
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Loading Screen
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingFrame.BackgroundTransparency = 0.3
LoadingFrame.Parent = ScreenGui

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 128, 0, 128)
Logo.Position = UDim2.new(0.5, -64, 0.5, -64)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://84576903354052"
Logo.Parent = LoadingFrame

-- Fade out setelah 3 detik
task.delay(3, function()
    for i = 0, 1, 0.05 do
        LoadingFrame.BackgroundTransparency = i
        Logo.ImageTransparency = i
        task.wait(0.05)
    end
    LoadingFrame:Destroy()
    MainFrame.Visible = true
end)

-- Return API
local Framework = {}
Framework.ContentFrame = Content
return Framework
