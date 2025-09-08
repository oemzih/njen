--// custom1.lua
-- Framework Airflow GUI (dengan fade-in + draggable)

local Airflow = {}

-- Dapatkan layanan TweenService
local TweenService = game:GetService("TweenService")

-- Buat Window
function Airflow:CreateWindow(settings)
    local Player = game.Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    -- GUI utama
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AirflowGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BackgroundTransparency = 0.3
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true

    -- Fade-in animasi yang lebih baik menggunakan TweenService
    MainFrame.BackgroundTransparency = 1 -- Atur transparansi awal ke 1 (tidak terlihat)
    
    local tweenInfo = TweenInfo.new(
        0.5, -- Durasi animasi (detik)
        Enum.EasingStyle.Quad, -- Gaya animasi
        Enum.EasingDirection.Out -- Arah animasi
    )
    
    local tweenProperties = { BackgroundTransparency = 0.3 } -- Properti yang akan dianimasikan
    
    local tween = TweenService:Create(MainFrame, tweenInfo, tweenProperties)
    tween:Play()

    -- Judul
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = settings.Name or "Airflow GUI"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20

    -- Draggable support
    local dragging, dragInput, dragStart, startPos
    MainFrame.Active = true
    MainFrame.Draggable = false

    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Object Window
    local Window = {}
    Window.MainFrame = MainFrame

    -- Tab Creator
    function Window:CreateTab(tabName)
        local TabFrame = Instance.new("Frame", MainFrame)
        TabFrame.Size = UDim2.new(1, -20, 1, -60)
        TabFrame.Position = UDim2.new(0, 10, 0, 50)
        TabFrame.BackgroundTransparency = 1

        local TabTitle = Instance.new("TextLabel", TabFrame)
        TabTitle.Size = UDim2.new(1, 0, 0, 25)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Text = tabName
        TabTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabTitle.Font = Enum.Font.SourceSansBold
        TabTitle.TextSize = 18

        local Tab = {}
        Tab.TabFrame = TabFrame
        local YPos = 40

        -- Button Creator
        function Tab:CreateButton(data)
            local Button = Instance.new("TextButton", TabFrame)
            Button.Size = UDim2.new(0, 160, 0, 35)
            Button.Position = UDim2.new(0, 10, 0, YPos)
            Button.Text = data.Name or "Button"
            Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Font = Enum.Font.SourceSans
            Button.TextSize = 16

            Button.MouseButton1Click:Connect(function()
                if data.Callback then
                    data.Callback()
                end
            end)

            YPos = YPos + 45
            return Button
        end

        return Tab
    end

    return Window
end

return Airflow
