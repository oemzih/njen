-- Key System Framework: Standalone GUI + evkey.lua
local Framework = {}
Framework.__index = Framework

local DEFAULT_EVKEY_URL = "https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"

local function safeParent(screenGui)
    local plr = game:GetService("Players").LocalPlayer
    local success = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if success then return end
    if plr then pcall(function() screenGui.Parent = plr:WaitForChild("PlayerGui") end) else pcall(function() screenGui.Parent = workspace end)
end

local function createStandaloneUI(cfg, onKeySubmit)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StandaloneKeyUI"
    screenGui.DisplayOrder = 999
    safeParent(screenGui)

    local borderColor = Color3.new(0, 1, 0)
    local textColor = Color3.new(1, 1, 1)
    pcall(function() 
        if cfg.Theme and cfg.Theme.Border then borderColor = Color3.fromHex("#" .. cfg.Theme.Border) end
        if cfg.Theme and cfg.Theme.Text then textColor = Color3.fromHex("#" .. cfg.Theme.Text) end
    end)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = borderColor
    frame.Parent = screenGui

    -- Tombol X pojok atas
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeButton.Parent = frame
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

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

    -- Tombol GET KEYS (mengganti Cancel)
    local getKeysButton = Instance.new("TextButton")
    getKeysButton.Text = "Get Keys"
    getKeysButton.Size = UDim2.new(0.4, 0, 0, 30)
    getKeysButton.Position = UDim2.new(0.55, 0, 0, 100)
    getKeysButton.Font = Enum.Font.SourceSansBold
    getKeysButton.TextSize = 18
    getKeysButton.TextColor3 = Color3.new(1, 1, 1)
    getKeysButton.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
    getKeysButton.Parent = frame

    local userFailed, userPassed, userWhitelisted, userCancelled

    local api = {
        _RawGui = frame,
        Failed = function(fn) userFailed = fn end,
        Passed = function(fn) userPassed = fn end,
        Whitelisted = function(fn) userWhitelisted = fn end,
        Cancelled = function(fn) userCancelled = fn end,
        Destroy = function() screenGui:Destroy() end,
        _CallFailed = function() if userFailed then pcall(userFailed) end end,
        _CallPassed = function() if userPassed then pcall(userPassed) end end,
        _CallWhitelisted = function() if userWhitelisted then pcall(userWhitelisted) end end,
        _CallCancelled = function() if userCancelled then pcall(userCancelled) end end,
    }

    submitButton.MouseButton1Click:Connect(function()
        onKeySubmit(keyInput.Text, api)
    end)

    getKeysButton.MouseButton1Click:Connect(function()
        api._CallCancelled()
        print("[QueryKey] GET KEYS clicked")
    end)

    return api
end

Framework.BcryptCheck = function(input, hash)
    warn("[QueryKey] BcryptCheck tidak di-override. Bcrypt tidak akan berfungsi.")
    return false
end

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

function Framework.CreateWindow(cfg)
    cfg = cfg or {}
    cfg.KeySettings = cfg.KeySettings or {}
    cfg.Whitelisted = cfg.Whitelisted or {}

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

    local function handleStandaloneSubmit(inputKey, uiApi)
        local localPlayer = game:GetService("Players").LocalPlayer
        local isWhitelisted = table.find(cfg.Whitelisted, localPlayer.UserId)

        if isWhitelisted then
            uiApi.Destroy()
            pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
            uiApi._CallWhitelisted()
        elseif validateKey(inputKey) then
            uiApi.Destroy()
            pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
            uiApi._CallPassed()
        else
            print("[QueryKey] Key validation failed.")
            local keyInput = uiApi._RawGui:FindFirstChild("KeyInput")
            if keyInput then
                local originalPlaceholder = cfg.Text.Body or "Enter the key:"
                keyInput.PlaceholderText = cfg.Text.Fail or "Access denied"
                keyInput.Text = ""
                wait(2)
                keyInput.PlaceholderText = originalPlaceholder
            end
            uiApi._CallFailed()
        end
    end

    local uiWindow = nil
    local okCreate, err = pcall(function()
        uiWindow = createStandaloneUI(cfg, handleStandaloneSubmit)
    end)
    
    if not okCreate or not uiWindow then
         error(string.format("[QueryKey] GAGAL TOTAL membuat GUI internal. Error: %s", tostring(err)))
    end

    if table.find(cfg.Whitelisted, game:GetService("Players").LocalPlayer.UserId) then
        pcall(function() uiWindow.Destroy() end)
        pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
        return
    end

    return uiWindow
end

return Framework
