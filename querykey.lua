-- framework.lua
-- KeySystem module (return table)
-- Bahasa: Indonesian comments

local KeySystem = {}
KeySystem.__index = KeySystem

local function newinst(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

local DEFAULT_THEME = {
    Text = "00ff00",
    Border = "00ff00",
    Background = "000000"
}

local function hexToColor3(hex)
    hex = tostring(hex):gsub("#", "")
    if #hex ~= 6 then return Color3.new(1,1,1) end
    local r = tonumber(hex:sub(1,2), 16)/255
    local g = tonumber(hex:sub(3,4), 16)/255
    local b = tonumber(hex:sub(5,6), 16)/255
    return Color3.new(r,g,b)
end

-- Bcrypt check placeholder; override jika executor mendukung binding bcrypt
KeySystem.BcryptCheck = function(_input, _hash)
    warn("Bcrypt check not available. Override KeySystem.BcryptCheck with real bcrypt binding for secure checks.")
    return false
end

local function buildGui(cfg)
    local screenGui = newinst("ScreenGui", {Name = "KeySystemUI", ResetOnSpawn = false, IgnoreGuiInset = true})
    if game:GetService("RunService"):IsStudio() then
        screenGui.Parent = game.CoreGui
    else
        screenGui.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local frame = newinst("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0,520,0,300),
        Position = UDim2.new(0.5, -260, 0.5, -150),
        BackgroundColor3 = hexToColor3(cfg.Theme.Background or DEFAULT_THEME.Background),
        BorderSizePixel = 3
    })
    frame.BorderColor3 = hexToColor3(cfg.Theme.Border or DEFAULT_THEME.Border)
    frame.Parent = screenGui

    local title = newinst("TextLabel", {
        Name = "Title",
        Text = cfg.Text.Title or "Key System",
        Font = Enum.Font.SourceSansBold,
        TextSize = 28,
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0,20,0,10),
        BackgroundTransparency = 1,
        TextColor3 = hexToColor3(cfg.Theme.Text or DEFAULT_THEME.Text)
    })
    title.Parent = frame

    local body = newinst("TextLabel", {
        Name = "Body",
        Text = cfg.Text.Body or "Enter the key to access the contents of the script.",
        Font = Enum.Font.SourceSans,
        TextSize = 20,
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0,20,0,55),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextColor3 = hexToColor3(cfg.Theme.Text or DEFAULT_THEME.Text)
    })
    body.Parent = frame

    local inputBox = newinst("TextBox", {
        Name = "KeyBox",
        Text = "",
        PlaceholderText = "Enter key",
        Font = Enum.Font.SourceSansItalic,
        TextSize = 22,
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0,20,0,140),
        BackgroundTransparency = 0.7,
        ClearTextOnFocus = false
    })
    inputBox.TextColor3 = hexToColor3(cfg.Theme.Text or DEFAULT_THEME.Text)
    inputBox.Parent = frame

    local getKeyBtn = newinst("TextButton", {
        Name = "GetKey",
        Text = "Get key",
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        Size = UDim2.new(0,140,0,40),
        Position = UDim2.new(0,20,1,-60),
        BackgroundTransparency = 0.8
    })
    getKeyBtn.TextColor3 = hexToColor3(cfg.Theme.Text or DEFAULT_THEME.Text)
    getKeyBtn.Parent = frame

    local confirmBtn = newinst("TextButton", {
        Name = "Confirm",
        Text = "Confirm",
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        Size = UDim2.new(0,140,0,40),
        Position = UDim2.new(1,-160,1,-60),
        BackgroundTransparency = 0.8
    })
    confirmBtn.TextColor3 = hexToColor3(cfg.Theme.Text or DEFAULT_THEME.Text)
    confirmBtn.Parent = frame

    local closeBtn = newinst("TextButton", {
        Name = "Close",
        Text = "X",
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        Size = UDim2.new(0,36,0,36),
        Position = UDim2.new(1,-46,0,10),
        BackgroundTransparency = 0.8
    })
    closeBtn.TextColor3 = hexToColor3(cfg.Theme.Text or DEFAULT_THEME.Text)
    closeBtn.Parent = frame

    return {
        ScreenGui = screenGui,
        Frame = frame,
        Input = inputBox,
        GetKey = getKeyBtn,
        Confirm = confirmBtn,
        Close = closeBtn
    }
end

local function isWhitelisted(cfg)
    local plr = game.Players.LocalPlayer
    if not plr then return false end
    local wl = cfg.Whitelisted
    if not wl then return false end
    if type(wl) == "table" then
        for _, id in ipairs(wl) do
            if tonumber(id) == plr.UserId then return true end
        end
    elseif type(wl) == "string" then
        return false
    end
    return false
end

function KeySystem.CreateWindow(cfg)
    cfg = cfg or {}
    cfg.KeySettings = cfg.KeySettings or {}
    cfg.Theme = cfg.Theme or DEFAULT_THEME
    cfg.Text = cfg.Text or {}

    local ui = buildGui(cfg)

    local events = {
        Failed = function() end,
        Passed = function() end,
        Whitelisted = function() end,
        Cancelled = function() end
    }

    local destroyed = false
    local function destroy()
        if destroyed then return end
        destroyed = true
        pcall(function() ui.ScreenGui:Destroy() end)
    end

    if isWhitelisted(cfg) then
        spawn(function()
            events.Whitelisted()
            destroy()
        end)
    end

    ui.GetKey.MouseButton1Click:Connect(function()
        local link = cfg.GetKeyLink
        if link and link ~= "" then
            local success = pcall(function() setclipboard(link) end)
            if success then
                print("[KeySystem] Key link copied to clipboard:", link)
            else
                print("[KeySystem] Key link: ", link)
            end
        else
            print("[KeySystem] No GetKeyLink provided.")
        end
    end)

    ui.Close.MouseButton1Click:Connect(function()
        events.Cancelled()
        destroy()
    end)

    ui.Confirm.MouseButton1Click:Connect(function()
        local entered = tostring(ui.Input.Text or "")
        local ks = cfg.KeySettings or {}
        local keyType = ks.Type or "plain"
        local keyVal = ks.Key or ""
        local encryption = ks.Encryption or nil

        local passed = false

        if keyType == "plain" then
            passed = (entered == tostring(keyVal))
        elseif keyType == "url" then
            passed = (entered == tostring(keyVal))
        else
            if encryption and encryption:lower() == "bcrypt" then
                local ok, ret = pcall(function()
                    return KeySystem.BcryptCheck(entered, keyVal)
                end)
                if ok and ret == true then passed = true end
            else
                passed = false
            end
        end

        if passed then
            events.Passed()
            destroy()
        else
            events.Failed()
        end
    end)

    local window = {}
    window.Failed = function(fn) events.Failed = fn end
    window.Passed = function(fn) events.Passed = fn end
    window.Whitelisted = function(fn) events.Whitelisted = fn end
    window.Cancelled = function(fn) events.Cancelled = fn end
    window.Destroy = destroy-- framework.lua
if success then
print("[KeySystem] Key link copied to clipboard:", link)
else
print("[KeySystem] Key link: ", link)
end
else
print("[KeySystem] No GetKeyLink provided.")
end
end)


ui.Close.MouseButton1Click:Connect(function()
events.Cancelled()
destroy()
end)


ui.Confirm.MouseButton1Click:Connect(function()
local entered = tostring(ui.Input.Text or "")
local ks = cfg.KeySettings or {}
local keyType = ks.Type or "plain"
local keyVal = ks.Key or ""
local encryption = ks.Encryption or nil


local passed = false


if keyType == "plain" then
passed = (entered == tostring(keyVal))
elseif keyType == "url" then
passed = (entered == tostring(keyVal))
else
if encryption and encryption:lower() == "bcrypt" then
local ok, ret = pcall(function()
return KeySystem.BcryptCheck(entered, keyVal)
end)
if ok and ret == true then passed = true end
else
passed = false
end
end


if passed then
events.Passed()
destroy()
else
events.Failed()
end
end)


local window = {}
window.Failed = function(fn) events.Failed = fn end
window.Passed = function(fn) events.Passed = fn end
window.Whitelisted = function(fn) events.Whitelisted = fn end
window.Cancelled = function(fn) events.Cancelled = fn end
window.Destroy = destroy
window._Gui = ui


return window
end


return KeySystem
    window._Gui = ui

    return window
end

return KeySystem
