-- Key System Framework: menampilkan Fallback GUI (GUI internal yang stabil) dan menjalankan evkey.lua saat valid
-- Diperbaiki: KeyUI v2 dihapus total. Hanya menggunakan GUI internal yang mandiri (standalone).

local Framework = {}
Framework.__index = Framework

-- CONFIG (ubah kalau mau)
local DEFAULT_EVKEY_URL = "https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"

-- util: safe parent ScreenGui
local function safeParent(screenGui)
    local RunService = game:GetService("RunService")
    local success = false
    
    -- Coba CoreGui dulu (banyak executor mendukungnya)
    success = pcall(function() 
        game:GetService("CoreGui") 
        screenGui.Parent = game:GetService("CoreGui")
    end)
    
    if success then return end

    -- Fallback: PlayerGui
    local plr = game:GetService("Players").LocalPlayer
    if plr then
        pcall(function() screenGui.Parent = plr:WaitForChild("PlayerGui") end)
    else
        -- Last resort (biasanya tidak terjadi)
        pcall(function() screenGui.Parent = workspace end)
    end
end

-- Fallback GUI Implementation (KeyUI Sederhana - Sekarang menjadi UI UTAMA)
local function createStandaloneUI(cfg, onKeySubmit)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StandaloneKeyUI"
    screenGui.DisplayOrder = 999 
    safeParent(screenGui)

    -- Ambil warna tema
    local borderColor = Color3.fromRGB(0, 255, 0)
    local textColor = Color3.fromRGB(255, 255, 255)
    if cfg.Theme and cfg.Theme.Border then
        pcall(function() borderColor = Color3.fromHex("#" .. cfg.Theme.Border) end)
    end
    if cfg.Theme and cfg.Theme.Text then
        pcall(function() textColor = Color3.fromHex("#" .. cfg.Theme.Text) end)
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = borderColor
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
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
    keyInput.Name = "KeyInput" -- Beri nama agar mudah diakses
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

    -- Objek API yang akan dikembalikan
    local api = {
        _RawGui = frame, -- Tambahkan akses ke GUI mentah untuk feedback
        Failed = function(fn) api._Failed = fn end,
        Passed = function(fn) api._Passed = fn end,
        Whitelisted = function(fn) api._Whitelisted = fn end,
        Cancelled = function(fn) api._Cancelled = fn end,
        Destroy = function() screenGui:Destroy() end,
    }

    submitButton.MouseButton1Click:Connect(function()
        onKeySubmit(keyInput.Text, api)
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if api._Cancelled then pcall(api._Cancelled) end
    end)

    return api
end
-- End of Standalone GUI Implementation

-- Override BcryptCheck (dipertahankan)
Framework.BcryptCheck = function(input, hash)
    warn("[QueryKey] BcryptCheck tidak di-override. Bcrypt tidak akan berfungsi.")
    return false
end

-- The main function to create the window (SEKARANG HANYA STANDALONE UI)
function Framework.CreateWindow(cfg)
    cfg = cfg or {}
    cfg.KeySettings = cfg.KeySettings or {}
    cfg.GetKeyLink = cfg.GetKeyLink or ""
    cfg.Whitelisted = cfg.Whitelisted or {}
    cfg.Theme = cfg.Theme or {}
    cfg.Text = cfg.Text or {}

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
                warn("[QueryKey] BcryptCheck belum di-override! Key tidak dapat divalidasi.")
                return false
            end
        end
        return false
    end

    -- Handler saat tombol Submit ditekan pada GUI
    local function handleStandaloneSubmit(inputKey, uiApi)
        local localPlayer = game:GetService("Players").LocalPlayer
        
        if table.find(cfg.Whitelisted, localPlayer.UserId) then
            uiApi.Destroy()
            if uiApi._Whitelisted then pcall(uiApi._Whitelisted) end
        elseif validateKey(inputKey) then
            uiApi.Destroy()
            if uiApi._Passed then pcall(uiApi._Passed) end
        else
            print("[QueryKey] Key validation failed.")
            
            -- Feedback visual pada GUI
            local keyInput = uiApi._RawGui:FindFirstChild("KeyInput")
            if keyInput then
                local originalPlaceholder = keyInput.PlaceholderText
                keyInput.PlaceholderText = cfg.Text.Fail or "Access denied"
                keyInput.Text = ""
                wait(2)
                keyInput.PlaceholderText = originalPlaceholder
            end
            
            if uiApi._Failed then pcall(uiApi._Failed) end
        end
    end
    
    -- Buat GUI utama
    local uiWindow = createStandaloneUI(cfg, handleStandaloneSubmit)

    if not uiWindow then
         error("[QueryKey] Gagal membuat GUI: Standalone UI gagal dimuat.")
    end

    -- Cek Whitelisted User lebih dulu (meskipun GUI sudah muncul)
    if table.find(cfg.Whitelisted, game:GetService("Players").LocalPlayer.UserId) then
        pcall(function() uiWindow.Destroy() end) -- Auto-destroy UI
    end

    -- internal handlers: run evkey when pass or whitelisted
    local function runEvkey(evurl)
        evurl = evurl or DEFAULT_EVKEY_URL
        spawn(function()
            wait(0.2)
            local ok2, err = pcall(function()
                loadstring(game:HttpGet(evurl))()
            end)
            if not ok2 then
                warn("[QueryKey] Gagal load evkey.lua dari:", evurl, "error:", err)
            end
        end)
    end

    -- Pembungkus fungsi event
    local userFailed, userPassed, userWhitelisted, userCancelled

    local function wrapFailed(fn) userFailed = fn end
    local function wrapPassed(fn) userPassed = fn end
    local function wrapWhitelisted(fn) userWhitelisted = fn end
    local function wrapCancelled(fn) userCancelled = fn end

    -- Daftarkan callbacks internal ke API GUI
    uiWindow.Failed(function()
        pcall(function() print("[QueryKey] Key validation failed") end)
        if userFailed then pcall(userFailed) end
    end)

    uiWindow.Passed(function()
        pcall(function() print("[QueryKey] Key validation passed") end)
        pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
        if userPassed then pcall(userPassed) end
    end)

    uiWindow.Whitelisted(function()
        pcall(function() print("[QueryKey] User whitelisted — bypassing key") end)
        pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
        if userWhitelisted then pcall(userWhitelisted) end
    end)

    uiWindow.Cancelled(function()
        pcall(function() print("[QueryKey] User cancelled key UI") end)
        if userCancelled then pcall(userCancelled) end
    end)

    -- Kembalikan objek API yang sudah dibungkus
    local ret = {}
    ret.Failed = wrapFailed
    ret.Passed = wrapPassed
    ret.Whitelisted = wrapWhitelisted
    ret.Cancelled = wrapCancelled
    ret.Destroy = uiWindow.Destroy 
    ret._Raw = uiWindow._RawGui

    return ret
end

return Framework
