-- Key System Framework: menampilkan Standalone GUI dengan ANIMASI FADE/SLIDE dan menjalankan evkey.lua saat valid
-- Diperbaiki: Menambahkan fungsi Show/Hide menggunakan TweenService untuk efek animasi yang smooth.

local Framework = {}
Framework.__index = Framework

-- CONFIG (ubah kalau mau)
local DEFAULT_EVKEY_URL = "https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"

-- Roblox Services
local TweenService = game:GetService("TweenService")
local EasingStyle = Enum.EasingStyle
local EasingDirection = Enum.EasingDirection

-- util: safe parent ScreenGui
local function safeParent(screenGui)
    local plr = game:GetService("Players").LocalPlayer
    
    -- Coba CoreGui (sering didukung oleh executor)
    local success = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    
    if success then return end

    -- Fallback: PlayerGui
    if plr then
        pcall(function() screenGui.Parent = plr:WaitForChild("PlayerGui") end)
    else
        pcall(function() screenGui.Parent = workspace end)
    end
end

-- Fallback GUI Implementation (SEKARANG UI UTAMA DENGAN ANIMASI)
local function createStandaloneUI(cfg, onKeySubmit)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StandaloneKeyUI"
    screenGui.DisplayOrder = 999 
    safeParent(screenGui)

    -- Ambil warna tema
    local borderColor = Color3.new(0, 1, 0) 
    local textColor = Color3.new(1, 1, 1)   
    pcall(function() 
        if cfg.Theme and cfg.Theme.Border then borderColor = Color3.fromHex("#" .. cfg.Theme.Border) end
        if cfg.Theme and cfg.Theme.Text then textColor = Color3.fromHex("#" .. cfg.Theme.Text) end
    end)

    -- TENTUKAN POSISI AWAL DAN AKHIR
    local FINAL_POS = UDim2.new(0.5, -150, 0.5, -75)
    local START_POS = UDim2.new(0.5, -150, -0.5, -75) -- Awal dari atas (tersembunyi)
    local HIDE_POS = UDim2.new(0.5, -150, 1.5, -75)  -- Akhir ke bawah (tersembunyi)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = START_POS -- Mulai dari atas
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = borderColor
    frame.Parent = screenGui
    frame.BackgroundTransparency = 1 -- Mulai dengan transparan
    
    -- Isi Frame (tanpa perubahan besar)
    local title = Instance.new("TextLabel")
    -- (kode Title, Body, Input, Buttons sama seperti sebelumnya)
    title.Text = cfg.Text.Title or "Key System"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = textColor
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.Parent = frame
    
    local body = Instance.new("TextLabel")
    body.Text = cfg.Text.Body or "Enter the key:"
    body.Size = UDim2.new(1, 0, 0, 20)
    body.Position = UDim2.new(0, 0, 0, 35)
    body.Font = Enum.Font.SourceSans
    body.TextSize = 14
    body.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    body.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    body.Parent = frame

    local keyInput = Instance.new("TextBox")
    keyInput.PlaceholderText = "KEY"
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(0.9, 0, 0, 30)
    keyInput.Position = UDim2.new(0.05, 0, 0, 60)
    keyInput.Font = Enum.Font.SourceSans
    keyInput.TextSize = 16
    keyInput.TextColor3 = Color3.new(1, 1, 1)
    keyInput.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    keyInput.Parent = frame

    local submitButton = Instance.new("TextButton")
    submitButton.Text = "Submit"
    submitButton.Size = UDim2.new(0.4, 0, 0, 30)
    submitButton.Position = UDim2.new(0.05, 0, 0, 100)
    submitButton.Font = Enum.Font.SourceSansBold
    submitButton.TextSize = 18
    submitButton.TextColor3 = Color3.new(1, 1, 1)
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    submitButton.Parent = frame

    local cancelButton = Instance.new("TextButton")
    cancelButton.Text = "Cancel"
    cancelButton.Size = UDim2.new(0.4, 0, 0, 30)
    cancelButton.Position = UDim2.new(0.55, 0, 0, 100)
    cancelButton.Font = Enum.Font.SourceSansBold
    cancelButton.TextSize = 18
    cancelButton.TextColor3 = Color3.new(1, 1, 1)
    cancelButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    cancelButton.Parent = frame
    
    -- Fungsi Animasi
    local function animateShow()
        -- Animasi muncul: Fade in dan Slide Down
        local info = TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out)
        TweenService:Create(frame, info, {Position = FINAL_POS, BackgroundTransparency = 0}):Play()
    end
    
    local function animateHide(slideUp)
        local targetPos = slideUp and START_POS or HIDE_POS -- Slide Up saat Success, Slide Down saat Cancel
        local info = TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.In)
        
        local tween = TweenService:Create(frame, info, {Position = targetPos, BackgroundTransparency = 1})
        tween:Play()
        
        -- Hapus GUI setelah animasi selesai
        tween.Completed:Wait()
        screenGui:Destroy()
    end

    -- Simpan fungsi callback yang akan di-override oleh pengguna akhir (user)
    local userFailed, userPassed, userWhitelisted, userCancelled
    
    -- Objek API yang dikembalikan
    local api = {
        _RawGui = frame, 
        Failed = function(fn) userFailed = fn end,
        Passed = function(fn) userPassed = fn end,
        Whitelisted = function(fn) userWhitelisted = fn end,
        Cancelled = function(fn) userCancelled = fn end,
        Destroy = function() screenGui:Destroy() end,
        
        _CallFailed = function() if userFailed then pcall(userFailed) end end,
        _CallPassed = function() 
            animateHide(true) -- Animasi hide ke atas (slide up)
            if userPassed then pcall(userPassed) end 
        end,
        _CallWhitelisted = function() 
            animateHide(true) -- Animasi hide ke atas (slide up)
            if userWhitelisted then pcall(userWhitelisted) end 
        end,
        _CallCancelled = function() 
            animateHide(false) -- Animasi hide ke bawah (slide down)
            if userCancelled then pcall(userCancelled) end 
        end,
    }

    submitButton.MouseButton1Click:Connect(function()
        onKeySubmit(keyInput.Text, api)
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        api._CallCancelled()
    end)
    
    -- Panggil fungsi Show setelah GUI dibuat (agar animasi terlihat)
    animateShow() 

    return api
end
-- End of Standalone GUI Implementation

-- Override BcryptCheck (tidak diubah)
Framework.BcryptCheck = function(input, hash)
    warn("[QueryKey] BcryptCheck tidak di-override. Bcrypt tidak akan berfungsi.")
    return false
end

-- Fungsi utama untuk menjalankan evkey.lua (tidak diubah)
local function runEvkey(evurl)
    evurl = evurl or DEFAULT_EVKEY_URL
    spawn(function()
        wait(0.2)
        local ok2, err = pcall(function()
            print("[QueryKey] Mencoba memuat dan menjalankan EVKEY dari:", evurl)
            loadstring(game:HttpGet(evurl))()
        end)
        if not ok2 then
            warn("[QueryKey] Gagal load evkey.lua dari:", evurl, "error:", err)
        end
    end)
end


-- The main function to create the window (diperbaiki di bagian Destroy/Whitelisted)
function Framework.CreateWindow(cfg)
    cfg = cfg or {}
    cfg.KeySettings = cfg.KeySettings or {}
    cfg.Whitelisted = cfg.Whitelisted or {}

    -- Logic validasi kunci (tidak diubah)
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
            -- Langsung eksekusi, biarkan uiApi._CallWhitelisted yang menjalankan animateHide(true) dan Destroy
            pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
            uiApi._CallWhitelisted()
        elseif validateKey(inputKey) then
            -- Langsung eksekusi, biarkan uiApi._CallPassed yang menjalankan animateHide(true) dan Destroy
            pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
            uiApi._CallPassed()
        else
            print("[QueryKey] Key validation failed.")
            
            -- Feedback visual pada GUI (tanpa animasi Destroy)
            local keyInput = uiApi._RawGui:FindFirstChild("KeyInput")
            if keyInput then
                local originalPlaceholder = keyInput.PlaceholderText
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

    -- Kembalikan objek API Standalone (sekarang sudah dimodifikasi dengan internal callbacks)
    return uiWindow
end

return Framework
