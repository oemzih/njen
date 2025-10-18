-- Key System Framework: Stabil, Tampilan Rapi, Tengah, Animasi Slide/Fade

local Framework = {}
Framework.__index = Framework

-- CONFIG (ubah kalau mau)
local DEFAULT_EVKEY_URL = "https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"

-- Roblox Services
local TweenService = game:GetService("TweenService")
local EasingStyle = Enum.EasingStyle
local EasingDirection = Enum.EasingDirection
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

-- util: safe parent ScreenGui
local function safeParent(screenGui)
    local plr = game:GetService("Players").LocalPlayer
    
    local success = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    
    if success then return end

    if plr then
        pcall(function() screenGui.Parent = plr:WaitForChild("PlayerGui") end)
    else
        pcall(function() screenGui.Parent = workspace end)
    end
end

-- Fallback GUI Implementation (SEKARANG UI UTAMA DENGAN LAYOUT YANG DIRAPIKAN)
local function createStandaloneUI(cfg, onKeySubmit)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StandaloneKeyUI"
    screenGui.DisplayOrder = 999 
    safeParent(screenGui)

    -- Ambil warna tema
    local borderColor = Color3.new(0, 1, 0) -- Default hijau
    local textColor = Color3.new(1, 1, 1)    -- Default putih
    local bgColor = Color3.new(0.05, 0.05, 0.05)
    pcall(function() 
        if cfg.Theme and cfg.Theme.Border then borderColor = Color3.fromHex("#" .. cfg.Theme.Border) end
        if cfg.Theme and cfg.Theme.Text then textColor = Color3.fromHex("#" .. cfg.Theme.Text) end
        if cfg.Theme and cfg.Theme.Background then bgColor = Color3.fromHex("#" .. cfg.Theme.Background) end
    end)

    -- TENTUKAN DIMENSI DAN POSISI
    local GUI_WIDTH = 350
    local GUI_HEIGHT = 220 
    local FINAL_POS = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2) -- Tepat di tengah
    local START_POS = UDim2.new(0.5, -GUI_WIDTH/2, -0.5, -GUI_HEIGHT/2) -- Awal dari atas
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
    frame.Position = START_POS 
    frame.BackgroundColor3 = bgColor
    frame.BorderSizePixel = 2
    frame.BorderColor3 = borderColor
    frame.Parent = screenGui
    frame.BackgroundTransparency = 1
    
    -- UI Corner Frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- UI Stroke (Untuk efek border neon/outline)
    local stroke = Instance.new("UIStroke")
    stroke.Color = borderColor
    stroke.Thickness = 2
    stroke.Parent = frame

    -- Header (Untuk Title)
    local header = Instance.new("TextLabel")
    header.Text = cfg.Text.Title or "Key System"
    header.Size = UDim2.new(1, 0, 0, 35)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 24
    header.TextColor3 = borderColor -- Gunakan warna border untuk Title
    header.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) 
    header.BackgroundTransparency = 0.5
    header.Parent = frame
    
    -- Tombol Close (X)
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 20
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.ZIndex = 2
    closeButton.Parent = header

    -- Body Text
    local body = Instance.new("TextLabel")
    body.Text = cfg.Text.Body or "Enter the key to access the contents of the script."
    body.Size = UDim2.new(0.9, 0, 0, 30)
    body.Position = UDim2.new(0.5, 0, 0, 45) -- PUSATKAN TEKS
    body.Font = Enum.Font.SourceSans
    body.TextSize = 15
    body.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    body.BackgroundTransparency = 1
    body.Parent = frame

    -- Input Key
    local keyInput = Instance.new("TextBox")
    keyInput.PlaceholderText = "Enter key"
    keyInput.Text = ""
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(0.85, 0, 0, 40)
    keyInput.Position = UDim2.new(0.5, 0, 0, 80) -- Tepat dibawah body text
    keyInput.TextXAlignment = Enum.TextXAlignment.Center -- Teks Input di tengah
    keyInput.Font = Enum.Font.SourceSans
    keyInput.TextSize = 18
    keyInput.TextColor3 = Color3.new(1, 1, 1)
    keyInput.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    keyInput.Parent = frame
    
    local keyInputCorner = Instance.new("UICorner")
    keyInputCorner.CornerRadius = UDim.new(0, 6)
    keyInputCorner.Parent = keyInput

    -- Container untuk tombol agar sejajar
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.85, 0, 0, 40)
    buttonContainer.Position = UDim2.new(0.5, 0, 0, 145) -- Posisi lebih ke bawah dari input
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = frame
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 20) -- Jarak antara tombol
    buttonLayout.Parent = buttonContainer

    -- Tombol Get Key (sesuai gambar)
    local getButton = Instance.new("TextButton")
    getButton.Text = "Get key"
    getButton.Size = UDim2.new(0.5, -10, 1, 0) 
    getButton.LayoutOrder = 1
    getButton.Font = Enum.Font.SourceSansBold
    getButton.TextSize = 18
    getButton.TextColor3 = textColor
    getButton.BackgroundColor3 = Color3.new(0.05, 0.1, 0.05)
    getButton.BorderColor3 = borderColor
    getButton.BorderSizePixel = 1
    getButton.Parent = buttonContainer
    
    local getButtonCorner = Instance.new("UICorner")
    getButtonCorner.CornerRadius = UDim.new(0, 6)
    getButtonCorner.Parent = getButton

    -- Tombol Confirm (sesuai gambar)
    local confirmButton = Instance.new("TextButton")
    confirmButton.Text = "Confirm"
    confirmButton.Size = UDim2.new(0.5, -10, 1, 0)
    confirmButton.LayoutOrder = 2
    confirmButton.Font = Enum.Font.SourceSansBold
    confirmButton.TextSize = 18
    confirmButton.TextColor3 = textColor
    confirmButton.BackgroundColor3 = Color3.new(0.05, 0.1, 0.05)
    confirmButton.BorderColor3 = borderColor
    confirmButton.BorderSizePixel = 1
    confirmButton.Parent = buttonContainer
    
    local confirmButtonCorner = Instance.new("UICorner")
    confirmButtonCorner.CornerRadius = UDim.new(0, 6)
    confirmButtonCorner.Parent = confirmButton
    
    -- Fungsi Animasi
    local function animateShow()
        local info = TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out)
        TweenService:Create(frame, info, {Position = FINAL_POS, BackgroundTransparency = 0}):Play()
    end
    
    local function animateHide(slideUp)
        local targetPos = slideUp and START_POS or UDim2.new(0.5, -GUI_WIDTH/2, 1.5, -GUI_HEIGHT/2)
        local info = TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.In)
        
        local tween = TweenService:Create(frame, info, {Position = targetPos, BackgroundTransparency = 1})
        tween:Play()
        
        tween.Completed:Wait()
        screenGui:Destroy()
    end

    -- Simpan fungsi callback yang akan di-override oleh pengguna akhir (user)
    local userFailed, userPassed, userWhitelisted, userCancelled
    
    local api = {
        _RawGui = frame, 
        Failed = function(fn) userFailed = fn end,
        Passed = function(fn) userPassed = fn end,
        Whitelisted = function(fn) userWhitelisted = fn end,
        Cancelled = function(fn) userCancelled = fn end,
        Destroy = function() screenGui:Destroy() end,
        
        _CallFailed = function() if userFailed then pcall(userFailed) end end,
        _CallPassed = function() 
            animateHide(true) 
            if userPassed then pcall(userPassed) end 
        end,
        _CallWhitelisted = function() 
            animateHide(true) 
            if userWhitelisted then pcall(userWhitelisted) end 
        end,
        _CallCancelled = function() 
            animateHide(false) 
            if userCancelled then pcall(userCancelled) end 
        end,
    }

    -- Events
    confirmButton.MouseButton1Click:Connect(function()
        onKeySubmit(keyInput.Text, api)
    end)
    
    getButton.MouseButton1Click:Connect(function()
        local getLink = cfg.GetKeyLink or "https://example.com/getkey"
        -- Fungsi untuk membuka URL di executor:
        pcall(function() GuiService:SetBubblesVisible(false) end)
        pcall(function() StarterGui:SetCore("OpenURL", getLink) end)
    end)

    closeButton.MouseButton1Click:Connect(function()
        api._CallCancelled()
    end)
    
    -- Tampilkan Animasi
    animateShow() 

    return api
end
-- End of Standalone GUI Implementation

-- Override BcryptCheck
Framework.BcryptCheck = function(input, hash)
    warn("[QueryKey] BcryptCheck tidak di-override. Bcrypt tidak akan berfungsi.")
    return false
end

-- Fungsi utama untuk menjalankan evkey.lua
local function runEvkey(evurl)
    evurl = evurl or DEFAULT_EVKEY_URL
    spawn(function()
        wait(0.4) -- Tunggu animasi hide selesai
        local ok2, err = pcall(function()
            print("[QueryKey] Mencoba memuat dan menjalankan EVKEY dari:", evurl)
            loadstring(game:HttpGet(evurl))()
        end)
        if not ok2 then
            warn("[QueryKey] Gagal load evkey.lua dari:", evurl, "error:", err)
        end
    end)
end

-- The main function to create the window
function Framework.CreateWindow(cfg)
    cfg = cfg or {}
    cfg.KeySettings = cfg.KeySettings or {}
    cfg.Whitelisted = cfg.Whitelisted or {}

    -- Logic validasi kunci
    local function validateKey(inputKey)
        local targetKey = cfg.KeySettings.Key or ""
        local keyType = cfg.KeySettings.Type or "plain"
        local keyEnc = cfg.KeySettings.Encryption or ""
        
        if keyType == "plain" then
            return inputKey == targetKey
        elseif keyEnc == "bcrypt" then
            if Framework.BcryptCheck then
                return Framework.BcryptCheck(inputKey, targetKey)
            else
                return false
            end
        end
        return false
    end

    -- Handler saat tombol Submit ditekan pada GUI
    local function handleStandaloneSubmit(inputKey, uiApi)
        local localPlayer = game:GetService("Players").LocalPlayer
        local isWhitelisted = table.find(cfg.Whitelisted, localPlayer.UserId)

        if isWhitelisted then
            pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
            uiApi._CallWhitelisted() -- Memulai animasi hide
        elseif validateKey(inputKey) then
            pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
            uiApi._CallPassed() -- Memulai animasi hide
        else
            print("[QueryKey] Key validation failed.")
            
            -- Feedback visual
            local keyInput = uiApi._RawGui:FindFirstChild("KeyInput")
            if keyInput then
                local originalPlaceholder = "Enter key"
                keyInput.PlaceholderText = cfg.Text.Fail or "Access denied"
                keyInput.Text = ""
                wait(2)
                keyInput.PlaceholderText = originalPlaceholder
            end
            
            uiApi._CallFailed()
        end
    end
    
    -- Buat GUI utama
    local uiWindow = nil
    local okCreate, err = pcall(function()
        uiWindow = createStandaloneUI(cfg, handleStandaloneSubmit)
    end)
    
    if not okCreate or not uiWindow then
         error(string.format("[QueryKey] GAGAL TOTAL membuat GUI internal. Executor Anda mungkin tidak mendukung GUI Roblox. Error: %s", tostring(err)))
    end

    -- Cek Whitelisted User SAAT AWAL (tanpa menampilkan UI)
    if table.find(cfg.Whitelisted, game:GetService("Players").LocalPlayer.UserId) then
        pcall(function() uiWindow.Destroy() end)
        pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
        return
    end

    return uiWindow
end

return Framework
