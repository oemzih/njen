-- custom1.lua
-- siZhens Framework by ganteng

local Airflow = {}

-- Fungsi buat parent GUI biar aman
local function safeParent(gui)
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then
        gui.Parent = core
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- Buat Window utama
function Airflow:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = config.Name or "siZhensGUI"
    safeParent(ScreenGui)

    -- Loading screen
    local Loading = Instance.new("Frame", ScreenGui)
    Loading.Size = UDim2.new(1,0,1,0)
    Loading.BackgroundColor3 = Color3.fromRGB(10,10,10)

    local Title = Instance.new("TextLabel", Loading)
    Title.AnchorPoint = Vector2.new(0.5,0.5)
    Title.Position = UDim2.new(0.5,0,0.45,0)
    Title.Size = UDim2.new(0,400,0,50)
    Title.Text = config.LoadingTitle or "siZhens"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 40
    Title.TextColor3 = Color3.fromRGB(200,100,255)

    local Subtitle = Instance.new("TextLabel", Loading)
    Subtitle.AnchorPoint = Vector2.new(0.5,0.5)
    Subtitle.Position = UDim2.new(0.5,0,0.55,0)
    Subtitle.Size = UDim2.new(0,400,0,30)
    Subtitle.Text = config.LoadingSubtitle or "Loading..."
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 20
    Subtitle.TextColor3 = Color3.fromRGB(255,255,255)

    -- Fade out animasi
    task.spawn(function()
        task.wait(1.5)
        for i=1,20 do
            Loading.BackgroundTransparency = i/20
            Title.TextTransparency = i/20
            Subtitle.TextTransparency = i/20
            task.wait(0.05)
        end
        Loading:Destroy()
    end)

    -- Window utama
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0,500,0,300)
    MainFrame.Position = UDim2.new(0.5,-250,0.5,-150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(200,100,255)

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0,12)

    local Header = Instance.new("TextLabel", MainFrame)
    Header.Size = UDim2.new(1,0,0,40)
    Header.BackgroundTransparency = 1
    Header.Text = config.Name or "siZhens Window"
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 22
    Header.TextColor3 = Color3.fromRGB(200,100,255)

    -- Tab bar kiri
    local TabBar = Instance.new("Frame", MainFrame)
    TabBar.Size = UDim2.new(0,120,1,-40)
    TabBar.Position = UDim2.new(0,0,0,40)
    TabBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0,10)

    local ContentFrame = Instance.new("Frame", MainFrame)
    ContentFrame.Size = UDim2.new(1,-120,1,-40)
    ContentFrame.Position = UDim2.new(0,120,0,40)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0,10)

    -- Simpan tab & halaman
    local Tabs = {}
    local Pages = {}

    function Airflow:CreateTab(name)
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(1,0,0,40)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency = 1

        local page = Instance.new("Frame", ContentFrame)
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.Visible = false

        Tabs[name] = btn
        Pages[name] = page

        btn.MouseButton1Click:Connect(function()
            for _,pg in pairs(Pages) do pg.Visible = false end
            page.Visible = true
        end)

        if not ContentFrame:FindFirstChildWhichIsA("Frame", true) then
            page.Visible = true
        end

        return page
    end

    return Airflow
end

return Airflow
