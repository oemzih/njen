--// custom1.lua
-- Pondasi sederhana Airflow GUI
local Airflow = {}

-- Buat Window
function Airflow:CreateWindow(settings)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AirflowGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 400, 0, 250)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = settings.Name or "Airflow GUI"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20

    -- simpan untuk referensi
    self.MainFrame = MainFrame
    return self
end

-- Buat Tab
function Airflow:CreateTab(name)
    local Tab = Instance.new("TextLabel", self.MainFrame)
    Tab.Size = UDim2.new(0, 100, 0, 30)
    Tab.Position = UDim2.new(0, 10, 0, 50)
    Tab.Text = name
    Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab.BackgroundTransparency = 0.5
    Tab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Tab.Font = Enum.Font.SourceSansBold
    Tab.TextSize = 16
    return Tab
end

-- Buat Button
function Airflow:CreateButton(text, callback)
    local Button = Instance.new("TextButton", self.MainFrame)
    Button.Size = UDim2.new(0, 150, 0, 40)
    Button.Position = UDim2.new(0, 10, 0, 90)
    Button.Text = text
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 18
    Button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    return Button
end

return Airflow
