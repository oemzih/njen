--// Airflow Minimal Framework v3 (Proteksi GUI)
-- By ganteng

local Airflow = {}

function Airflow:CreateWindow(config)
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- Buat ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "AirflowUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    -- Proteksi GUI agar tidak dihapus oleh game
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = gethui()
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = playerGui
    end

    -- Frame utama
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    -- Judul
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = config.Name or "Airflow Window"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame

    -- Tombol dummy
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(0.5, -100, 0.5, -20)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = "Klik Aku"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = mainFrame

    button.MouseButton1Click:Connect(function()
        print("Tombol Airflow diklik!")
    end)

    print("[Airflow] GUI berhasil dimuat.")
    return mainFrame
end

return Airflow
