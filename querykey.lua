-- Key System Framework: menampilkan KeyUI (KeyUI v2) atau Fallback GUI dan menjalankan evkey.lua saat valid
-- Diperbaiki: Menambahkan Fallback UI Sederhana jika KeyUI v2 gagal dimuat.

local Framework = {}
Framework.__index = Framework

-- CONFIG (ubah kalau mau)
local DEFAULT_EVKEY_URL = "https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"

-- util: safe parent ScreenGui
local function safeParent(screenGui)
    local RunService = game:GetService("RunService")
    if RunService:IsStudio() then
        pcall(function() screenGui.Parent = game.CoreGui end)
        return
    end
    -- try CoreGui first (some executors allow it)
    local ok = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if ok then return end
    -- fallback: PlayerGui
    local plr = game:GetService("Players").LocalPlayer
    if plr then
        pcall(function() screenGui.Parent = plr:WaitForChild("PlayerGui") end)
    else
        pcall(function() screenGui.Parent = workspace end)
    end
end

-- Fallback GUI Implementation (KeyUI Simpel)
-- Ini akan berfungsi jika KeyUI v2 gagal dimuat.
local function createFallbackUI(cfg, onKeySubmit)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FallbackKeyUI"
    screenGui.DisplayOrder = 999 -- Pastikan muncul di atas
    safeParent(screenGui)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Menggunakan warna tema jika tersedia
    if cfg.Theme and cfg.Theme.Border then
        local ok, color = pcall(Color3.fromHex, "#" .. cfg.Theme.Border)
        if ok then frame.BorderColor3 = color end
    end
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Text = cfg.Text.Title or "Key System"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.Parent = frame
    
    local body = Instance.new("TextLabel")
    body.Text = cfg.Text.Body or "Enter the key:"
    body.Size = UDim2.new(1, 0, 0, 20)
    body.Position = UDim2.new(0, 0, 0, 35)
    body.Font = Enum.Font.SourceSans
    body.TextSize = 14
    body.TextColor3 = Color3.fromRGB(0.8, 0.8, 0.8)
    body.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    body.Parent = frame

    local keyInput = Instance.new("TextBox")
    keyInput.PlaceholderText = "KEY"
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

    local api = {
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
-- End of Fallback GUI Implementation

-- Try to load KeyUI v2 (external UI lib)
local function loadKeyUI()
    local ok, ui = pcall(function()
        -- Ensure this URL is correct and accessible!
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/FFJ1/Roblox-Exploits/main/UIs/KeyUI/KeyUIv2.lua"))()
    end)
    if not ok or not ui then
        warn("[QueryKey] Gagal memuat KeyUI v2:", ui)
        return nil
    end
    return ui
end

-- Override BcryptCheck: jika user ingin menggunakan bcrypt dan override
Framework.BcryptCheck = function(input, hash)
    -- Ini adalah placeholder. Perlu implementasi bcrypt yang kompatibel dengan executor.
    warn("[QueryKey] BcryptCheck tidak di-override. Bcrypt tidak akan berfungsi.")
    return false
end

-- The main function to create the window (either KeyUI or Fallback)
function Framework.CreateWindow(cfg)
    cfg = cfg or {}
    cfg.KeySettings = cfg.KeySettings or {}
    cfg.GetKeyLink = cfg.GetKeyLink or ""
    cfg.Whitelisted = cfg.Whitelisted or {}
    cfg.Theme = cfg.Theme or {}
    cfg.Text = cfg.Text or {}

    local KeyUI = loadKeyUI()
    local uiWindow = nil

    -- Use KeyUI v2 if available
    if KeyUI and KeyUI.CreateWindow then
        local keySettings = {
            Key = cfg.KeySettings.Key or "",
            Type = cfg.KeySettings.Type or "plain",
            Encryption = cfg.KeySettings.Encryption or ""
        }
        
        local okCreate, res = pcall(function()
            uiWindow = KeyUI.CreateWindow({
                KeySettings = keySettings,
                GetKeyLink = cfg.GetKeyLink,
                Whitelisted = cfg.Whitelisted,
                Theme = cfg.Theme,
                Text = cfg.Text
            })
        end)

        if not okCreate or not uiWindow then
            warn(string.format("[QueryKey] Gagal membuat window KeyUI. Kesalahan: %s. Mencoba Fallback UI...", tostring(res)))
            -- Fall through to Fallback UI
            KeyUI = nil 
        end
    else
        warn("[QueryKey] KeyUI v2 tidak tersedia. Menggunakan Fallback UI sederhana...")
    end

    -- Use Fallback UI if KeyUI is not available
    if not uiWindow then
        -- Key validation logic for fallback
        local function validateKey(inputKey)
            local targetKey = cfg.KeySettings.Key or ""
            local keyType = cfg.KeySettings.Type or "plain"
            local keyEnc = cfg.KeySettings.Encryption or ""
            
            if keyType == "plain" then
                return inputKey == targetKey
            elseif keyEnc == "bcrypt" then
                -- Requires user to implement Framework.BcryptCheck in their script!
                if Framework.BcryptCheck then
                    return Framework.BcryptCheck(inputKey, targetKey)
                else
                    warn("[QueryKey] BcryptCheck belum di-override! Key tidak dapat divalidasi.")
                    return false
                end
            end
            return false
        end

        local function handleFallbackSubmit(inputKey, fallbackApi)
            if table.find(cfg.Whitelisted, game:GetService("Players").LocalPlayer.UserId) then
                fallbackApi.Destroy()
                if fallbackApi._Whitelisted then pcall(fallbackApi._Whitelisted) end
            elseif validateKey(inputKey) then
                fallbackApi.Destroy()
                if fallbackApi._Passed then pcall(fallbackApi._Passed) end
            else
                print("[QueryKey] Key validation failed (Fallback)")
                -- Simple feedback loop: clear input or show fail text briefly
                local input = fallbackApi._Raw.Frame.KeyInput
                local originalText = input.PlaceholderText
                input.PlaceholderText = cfg.Text.Fail or "Access denied"
                wait(2)
                input.PlaceholderText = originalText
                input.Text = ""
                
                if fallbackApi._Failed then pcall(fallbackApi._Failed) end
            end
        end
        
        -- Create the fallback GUI, passing the submit handler
        uiWindow = createFallbackUI(cfg, handleFallbackSubmit)
    end
    
    if not uiWindow then
         error("[QueryKey] Gagal membuat GUI: KeyUI v2 gagal dan Fallback UI gagal.")
    end

    -- Check for Whitelisted User first
    if table.find(cfg.Whitelisted, game:GetService("Players").LocalPlayer.UserId) then
        pcall(function() uiWindow.Destroy() end) -- Auto-destroy UI
    end

    -- internal handlers: run evkey when pass or whitelisted
    local function runEvkey(evurl)
        evurl = evurl or DEFAULT_EVKEY_URL
        -- small delay to allow GUI to close nicely
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

    -- wire default events: if user passed their own functions, keep them
    local userFailed = nil
    local userPassed = nil
    local userWhitelisted = nil
    local userCancelled = nil

    -- store original registration functions if exist
    local origFailed = uiWindow.Failed
    local origPassed = uiWindow.Passed
    local origWhitelisted = uiWindow.Whitelisted
    local origCancelled = uiWindow.Cancelled

    -- helper to set wrapped callbacks
    local function wrapFailed(fn) userFailed = fn end
    local function wrapPassed(fn) userPassed = fn end
    local function wrapWhitelisted(fn) userWhitelisted = fn end
    local function wrapCancelled(fn) userCancelled = fn end

    -- register internal callbacks with UI object:
    origFailed(function()
        pcall(function() print("[QueryKey] Key validation failed") end)
        if userFailed then pcall(userFailed) end
    end)

    origPassed(function()
        pcall(function() print("[QueryKey] Key validation passed") end)
        pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
        if userPassed then pcall(userPassed) end
    end)

    origWhitelisted(function()
        pcall(function() print("[QueryKey] User whitelisted — bypassing key") end)
        pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
        if userWhitelisted then pcall(userWhitelisted) end
    end)

    origCancelled(function()
        pcall(function() print("[QueryKey] User cancelled key UI") end)
        if userCancelled then pcall(userCancelled) end
    end)

    -- return an object that lets caller set their callbacks, destroy, and access raw GUI if needed
    local ret = {}
    ret.Failed = wrapFailed
    ret.Passed = wrapPassed
    ret.Whitelisted = wrapWhitelisted
    ret.Cancelled = wrapCancelled
    ret.Destroy = function()
        pcall(function() uiWindow.Destroy() end)
    end
    ret._Raw = uiWindow

    return ret
end

return Framework
