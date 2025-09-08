-- custom1.lua
-- Framework siZhens GUI by ganteng

local Airflow = {}

-- Fungsi: bikin window utama
function Airflow:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "siZhensGUI"
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game.CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Loading screen
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LoadingFrame.Parent = ScreenGui

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Size = UDim2.new(1, 0, 1, 0)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = "siZhens GUI\nLoading..."
    LoadingText.TextColor3 = Color3.fromRGB(200, 100, 255)
    LoadingText.TextSize = 32
    LoadingText.Font = Enum.Font.GothamBold
    LoadingText.Parent = LoadingFrame

    task.delay(3, function()
        LoadingFrame:Destroy()
    end)

    -- Window utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    -- Teks Judul
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "siZhens GUI"
    Title.TextColor3 = Color3.fromRGB(200, 100, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 28
    Title.Parent = MainFrame

    task.delay(3, function()
        MainFrame.Visible = true
    end)

    local Window = {}
    function Window:CreateTab(tabName)
        local Tab = Instance.new("TextButton")
        Tab.Size = UDim2.new(0, 120, 0, 30)
        Tab.Position = UDim2.new(0, 10, 0, 50)
        Tab.Text = tabName
        Tab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        Tab.Font = Enum.Font.Gotham
        Tab.TextSize = 14
        Tab.Parent = MainFrame

        local Page = Instance.new("Frame")
        Page.Size = UDim2.new(1, -140, 1, -60)
        Page.Position = UDim2.new(0, 130, 0, 50)
        Page.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Page.Visible = false
        Page.Parent = MainFrame

        Tab.MouseButton1Click:Connect(function()
            for _, v in ipairs(MainFrame:GetChildren()) do
                if v:IsA("Frame") and v ~= Page and v.Name == "Page" then
                    v.Visible = false
                end
            end
            Page.Visible = true
        end)

        Page.Name = "Page"
        return Page
    end

    return Window
end

return Airflow
