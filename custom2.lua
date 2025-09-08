--// siZhens Framework
--// custom1.lua (framework mentahan GUI + loading screen)
--// by ganteng

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "siZhensUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- =========================
-- Loading Screen
-- =========================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingFrame.BackgroundTransparency = 0.3
LoadingFrame.Parent = ScreenGui

-- Logo
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 200, 0, 200)
Logo.Position = UDim2.new(0.5, -100, 0.5, -100)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://84576903354052" -- id asset kamu
Logo.Parent = LoadingFrame

-- Text
local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 50)
LoadingText.Position = UDim2.new(0, 0, 0.7, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "siZhens GUI"
LoadingText.TextColor3 = Color3.fromRGB(200, 100, 255)
LoadingText.TextSize = 36
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Parent = LoadingFrame

-- Animasi FadeOut
task.delay(3, function()
    for i = 0, 1, 0.05 do
        LoadingFrame.BackgroundTransparency = 0.3 + i
        Logo.ImageTransparency = i
        LoadingText.TextTransparency = i
        task.wait(0.05)
    end
    LoadingFrame:Destroy()
end)

-- =========================
-- Main Frame GUI (Kosongan)
-- =========================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "siZhens Universal GUI"
Title.TextColor3 = Color3.fromRGB(200, 100, 255)
Title.TextSize = 28
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Tempat Menu (kosong dulu, nanti isi di example.lua)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
