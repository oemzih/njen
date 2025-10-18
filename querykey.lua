-- querykey.lua
-- Key System Framework: menampilkan KeyUI (KeyUI v2) dan menjalankan evkey.lua saat valid
-- Pastikan file ini di-raw URL seperti:
-- https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/querykey.lua

local Framework = {}
Framework.__index = Framework

-- CONFIG (ubah kalau mau)
local DEFAULT_EVKEY_URL = "https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"

-- util: safe parent ScreenGui (CoreGui jika tersedia, fallback PlayerGui)
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
        -- last resort: workspace (shouldn't happen)
        pcall(function() screenGui.Parent = workspace end)
    end
end

-- Try to load KeyUI v2 (external UI lib)
local function loadKeyUI()
    local ok, ui = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/FFJ1/Roblox-Exploits/main/UIs/KeyUI/KeyUIv2.lua"))()
    end)
    if not ok or not ui then
        warn("[QueryKey] Gagal memuat KeyUI v2:", ui)
        return nil
    end
    return ui
end

-- CreateWindow API wrapper
function Framework.CreateWindow(cfg)
    cfg = cfg or {}
    cfg.KeySettings = cfg.KeySettings or {}
    cfg.GetKeyLink = cfg.GetKeyLink or ""
    cfg.Whitelisted = cfg.Whitelisted or {}
    cfg.Theme = cfg.Theme or {}
    cfg.Text = cfg.Text or {}

    -- Load the KeyUI library
    local KeyUI = loadKeyUI()
    if not KeyUI then
        -- fallback: make simple builtin GUI if KeyUI unavailable
        warn("[QueryKey] KeyUI tidak tersedia. Mencoba membuat GUI sederhana...")
        -- simple builtin will still return an object with the same event API, but minimal
        -- For brevity, we'll just error out so user knows to fix executor/network
        error("[QueryKey] KeyUI v2 required but gagal dimuat. Periksa koneksi atau URL KeyUI.")
    end

    -- Build settings to pass to KeyUI.CreateWindow (match user's expected keys)
    local keySettings = {
        Key = cfg.KeySettings.Key or "",
        Type = cfg.KeySettings.Type or "plain",
        Encryption = cfg.KeySettings.Encryption or ""
    }

    local uiWindow = nil
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
        warn("[QueryKey] Gagal membuat window KeyUI:", res)
        return nil
    end

    -- internal handlers: run evkey when pass or whitelisted
    local function runEvkey(evurl)
        evurl = evurl or DEFAULT_EVKEY_URL
        -- small delay to allow GUI to close nicely
        spawn(function()
            -- try fade/delay if UI library provides destroy; otherwise just wait a bit
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

    -- override event registrations if provided by KeyUI wrapper; else we provide them
    -- assume KeyUI.CreateWindow returns an object with .Failed/.Passed/.Whitelisted/.Cancelled setters (as earlier)
    -- We'll wrap them so both framework and user callbacks run.

    -- store original registration functions if exist
    local origFailed = uiWindow.Failed
    local origPassed = uiWindow.Passed
    local origWhitelisted = uiWindow.Whitelisted
    local origCancelled = uiWindow.Cancelled

    -- helper to set wrapped callbacks
    local function wrapFailed(fn)
        userFailed = fn
    end
    local function wrapPassed(fn)
        userPassed = fn
    end
    local function wrapWhitelisted(fn)
        userWhitelisted = fn
    end
    local function wrapCancelled(fn)
        userCancelled = fn
    end

    -- register internal callbacks with KeyUI object:
    -- KeyUI will call these when events happen; these wrappers call both user-specified and internal actions.
    origFailed(function()
        -- internal: print / optional UI feedback
        pcall(function() print("[QueryKey] Key validation failed") end)
        if userFailed then
            pcall(userFailed)
        end
    end)

    origPassed(function()
        pcall(function() print("[QueryKey] Key validation passed") end)
        -- internal: run evkey
        pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
        if userPassed then
            pcall(userPassed)
        end
    end)

    origWhitelisted(function()
        pcall(function() print("[QueryKey] User whitelisted — bypassing key") end)
        -- internal: run evkey
        pcall(runEvkey, cfg.ExecuteOnPass or DEFAULT_EVKEY_URL)
        if userWhitelisted then
            pcall(userWhitelisted)
        end
    end)

    origCancelled(function()
        pcall(function() print("[QueryKey] User cancelled key UI") end)
        if userCancelled then
            pcall(userCancelled)
        end
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
