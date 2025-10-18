-- QueryKey Framework (loadstring-only, standalone GUI)
local Framework = {}
Framework.__index = Framework

local DEFAULT_EVKEY_URL = "https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"

-- Safe parent function
local function safeParent(gui)
    local plr = game:GetService("Players").LocalPlayer
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok then return end
    if plr then pcall(function() gui.Parent = plr:WaitForChild("PlayerGui") end) else pcall(function() gui.Parent = workspace end)
end

-- Create standalone key GUI
local function createStandaloneUI(cfg, onKeySubmit)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StandaloneKeyUI"
    screenGui.DisplayOrder = 999
    safeParent(screenGui)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 160)
    frame.Position = UDim2.new(0.5, -160, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0,1,0)
    frame.Parent = screenGui

    -- Tombol X pojok atas
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 28, 0, 28)
    closeButton.Position = UDim2.new(1, -32, 0, 4)
    closeButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
    closeButton.TextColor3 = Color3.new(1,1,1)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Parent = frame
    closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Title
    local title = Instance.new("TextLabel")
    title.Text = cfg.Text.Title or "Key System"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0,0,0,0)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundColor3 = Color3.fromRGB(50,50,50)
    title.Parent = frame

    -- Body
    local body = Instance.new("TextLabel")
    body.Text = cfg.Text.Body or "Enter the key:"
    body.Size = UDim2.new(1, 0, 0, 20)
    body.Position = UDim2.new(0,0,0,35)
    body.Font = Enum.Font.SourceSans
    body.TextSize = 14
    body.TextColor3 = Color3.new(0.8,0.8,0.8)
    body.BackgroundColor3 = Color3.fromRGB(30,30,30)
    body.Parent = frame

    -- Key input
    local keyInput = Instance.new("TextBox")
    keyInput.PlaceholderText = "KEY"
    keyInput.Size = UDim2.new(0.9,0,0,30)
    keyInput.Position = UDim2.new(0.05,0,0,60)
    keyInput.Font = Enum.Font.SourceSans
    keyInput.TextSize = 16
    keyInput.TextColor3 = Color3.new(1,1,1)
    keyInput.BackgroundColor3 = Color3.fromRGB(15,15,15)
    keyInput.Parent = frame

    -- Submit button
    local submitButton = Instance.new("TextButton")
    submitButton.Text = "Submit"
    submitButton.Size = UDim2.new(0.45,0,0,30)
    submitButton.Position = UDim2.new(0.05,0,0,110)
    submitButton.BackgroundColor3 = Color3.fromRGB(0,150,0)
    submitButton.TextColor3 = Color3.new(1,1,1)
    submitButton.Font = Enum.Font.SourceSansBold
    submitButton.TextSize = 18
    submitButton.Parent = frame

    -- Get Keys button (replace Cancel)
    local getKeysButton = Instance.new("TextButton")
    getKeysButton.Text = "Get Keys"
    getKeysButton.Size = UDim2.new(0.45,0,0,30)
    getKeysButton.Position = UDim2.new(0.5,0,0,110)
    getKeysButton.BackgroundColor3 = Color3.fromRGB(0,0,200)
    getKeysButton.TextColor3 = Color3.new(1,1,1)
    getKeysButton.Font = Enum.Font.SourceSansBold
    getKeysButton.TextSize = 18
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
    end)

    return api
end

-- Simple key validation
Framework.BcryptCheck = function(input, hash)
    warn("[QueryKey] BcryptCheck tidak di-override")
    return false
end

local function runEvkey(evurl)
    evurl = evurl or DEFAULT_EVKEY_URL
    spawn(function()
        wait(0.2)
        local ok, err = pcall(function()
            loadstring(game:HttpGet(evurl))()
        end)
        if not ok then warn("Gagal load evkey:", err) end
    end)
end

function Framework.CreateWindow(cfg)
    cfg = cfg or {}
    cfg.KeySettings = cfg.KeySettings or {}
    cfg.Whitelisted = cfg.Whitelisted or {}

    local function validateKey(inputKey)
        local key = cfg.KeySettings.Key or ""
        if (cfg.KeySettings.Type or "plain") == "plain" then
            return inputKey == key
        end
        return false
    end

    local function handleSubmit(inputKey, ui)
        local plr = game:GetService("Players").LocalPlayer
        if table.find(cfg.Whitelisted, plr.UserId) then
            ui.Destroy()
            pcall(runEvkey, cfg.ExecuteOnPass)
            ui._CallWhitelisted()
        elseif validateKey(inputKey) then
            ui.Destroy()
            pcall(runEvkey, cfg.ExecuteOnPass)
            ui._CallPassed()
        else
            ui._CallFailed()
        end
    end

    local ui = createStandaloneUI(cfg, handleSubmit)
    return ui
end

return Framework
