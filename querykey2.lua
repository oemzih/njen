-- ✅ Key System Framework: Stabil, Tengah, Rapi, dengan Animasi Slide/Fade
local Framework = {}
Framework.__index = Framework

-- CONFIG
local DEFAULT_EVKEY_URL = "https://raw.githubusercontent.com/oemzih/njen/refs/heads/main/evkey.lua"

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

-- Safe Parent
local function safeParent(gui)
	local plr = Players.LocalPlayer
	local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if ok then return end
	if plr then
		pcall(function() gui.Parent = plr:WaitForChild("PlayerGui") end)
	else
		pcall(function() gui.Parent = workspace end)
	end
end

-- UI
local function createStandaloneUI(cfg, onKeySubmit)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StandaloneKeyUI"
	screenGui.DisplayOrder = 999
	safeParent(screenGui)

	-- Theme
	local borderColor = Color3.new(0,1,0)
	local textColor = Color3.new(1,1,1)
	local bgColor = Color3.new(0.05,0.05,0.05)
	pcall(function()
		if cfg.Theme and cfg.Theme.Border then borderColor = Color3.fromHex("#"..cfg.Theme.Border) end
		if cfg.Theme and cfg.Theme.Text then textColor = Color3.fromHex("#"..cfg.Theme.Text) end
		if cfg.Theme and cfg.Theme.Background then bgColor = Color3.fromHex("#"..cfg.Theme.Background) end
	end)

	-- Ukuran GUI
	local GUI_WIDTH, GUI_HEIGHT = 350, 220
	local FINAL_POS = UDim2.new(0.5, 0, 0.5, 0)
	local START_POS = UDim2.new(0.5, 0, -0.5, 0)

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
	frame.Position = START_POS
	frame.BackgroundColor3 = bgColor
	frame.BorderColor3 = borderColor
	frame.BorderSizePixel = 2
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = borderColor
	stroke.Thickness = 2

	-- Header
	local header = Instance.new("TextLabel")
	header.Text = cfg.Text.Title or "Key System"
	header.Size = UDim2.new(1, 0, 0, 35)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.Font = Enum.Font.SourceSansBold
	header.TextSize = 22
	header.TextColor3 = borderColor
	header.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
	header.BackgroundTransparency = 0.4
	header.Parent = frame

	local closeButton = Instance.new("TextButton")
	closeButton.Text = "X"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 3)
	closeButton.AnchorPoint = Vector2.new(0,0)
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.new(1,1,1)
	closeButton.BackgroundColor3 = Color3.new(1,0,0)
	closeButton.Parent = frame

	-- Body Text (rata tengah)
	local body = Instance.new("TextLabel")
	body.AnchorPoint = Vector2.new(0.5, 0)
	body.Position = UDim2.new(0.5, 0, 0, 50)
	body.Size = UDim2.new(0.9, 0, 0, 30)
	body.Text = cfg.Text.Body or "Enter the key to access the contents of the script."
	body.Font = Enum.Font.SourceSans
	body.TextSize = 16
	body.TextColor3 = Color3.new(0.9,0.9,0.9)
	body.BackgroundTransparency = 1
	body.TextWrapped = true
	body.TextXAlignment = Enum.TextXAlignment.Center
	body.Parent = frame

	-- Input Key
	local keyInput = Instance.new("TextBox")
	keyInput.AnchorPoint = Vector2.new(0.5, 0)
	keyInput.Position = UDim2.new(0.5, 0, 0, 90)
	keyInput.Size = UDim2.new(0.8, 0, 0, 40)
	keyInput.PlaceholderText = "Enter key"
	keyInput.Font = Enum.Font.SourceSans
	keyInput.TextSize = 18
	keyInput.TextColor3 = Color3.new(1,1,1)
	keyInput.BackgroundColor3 = Color3.new(0.1,0.1,0.15)
	keyInput.TextXAlignment = Enum.TextXAlignment.Center
	keyInput.Parent = frame
	Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 6)

	-- Button Container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.AnchorPoint = Vector2.new(0.5, 0)
	buttonContainer.Position = UDim2.new(0.5, 0, 0, 145)
	buttonContainer.Size = UDim2.new(0.8, 0, 0, 40)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = frame

	local buttonLayout = Instance.new("UIListLayout", buttonContainer)
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buttonLayout.Padding = UDim.new(0, 15)

	-- Tombol Get Key
	local getButton = Instance.new("TextButton")
	getButton.Size = UDim2.new(0.5, -10, 1, 0)
	getButton.Font = Enum.Font.SourceSansBold
	getButton.Text = "Get Key"
	getButton.TextSize = 18
	getButton.TextColor3 = textColor
	getButton.BackgroundColor3 = Color3.new(0.05,0.1,0.05)
	getButton.BorderColor3 = borderColor
	getButton.BorderSizePixel = 1
	getButton.LayoutOrder = 1
	getButton.Parent = buttonContainer
	Instance.new("UICorner", getButton).CornerRadius = UDim.new(0, 6)

	-- Tombol Confirm
	local confirmButton = Instance.new("TextButton")
	confirmButton.Size = UDim2.new(0.5, -10, 1, 0)
	confirmButton.Font = Enum.Font.SourceSansBold
	confirmButton.Text = "Confirm"
	confirmButton.TextSize = 18
	confirmButton.TextColor3 = textColor
	confirmButton.BackgroundColor3 = Color3.new(0.05,0.1,0.05)
	confirmButton.BorderColor3 = borderColor
	confirmButton.BorderSizePixel = 1
	confirmButton.LayoutOrder = 2
	confirmButton.Parent = buttonContainer
	Instance.new("UICorner", confirmButton).CornerRadius = UDim.new(0, 6)

	-- Animasi
	local function animateShow()
		local info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		TweenService:Create(frame, info, {Position = FINAL_POS, BackgroundTransparency = 0}):Play()
	end

	local function animateHide(slideUp)
		local targetPos = slideUp and START_POS or UDim2.new(0.5, 0, 1.5, 0)
		local info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		local tween = TweenService:Create(frame, info, {Position = targetPos, BackgroundTransparency = 1})
		tween:Play()
		tween.Completed:Wait()
		screenGui:Destroy()
	end

	-- API
	local userFailed, userPassed, userWhitelisted, userCancelled
	local api = {
		_RawGui = frame,
		Failed = function(fn) userFailed = fn end,
		Passed = function(fn) userPassed = fn end,
		Whitelisted = function(fn) userWhitelisted = fn end,
		Cancelled = function(fn) userCancelled = fn end,
		Destroy = function() screenGui:Destroy() end,

		_CallFailed = function() if userFailed then pcall(userFailed) end end,
		_CallPassed = function() animateHide(true) if userPassed then pcall(userPassed) end end,
		_CallWhitelisted = function() animateHide(true) if userWhitelisted then pcall(userWhitelisted) end end,
		_CallCancelled = function() animateHide(false) if userCancelled then pcall(userCancelled) end end,
	}

	-- Event Tombol
	confirmButton.MouseButton1Click:Connect(function() onKeySubmit(keyInput.Text, api) end)
	getButton.MouseButton1Click:Connect(function()
		local link = cfg.GetKeyLink or "https://example.com/getkey"
		pcall(function() StarterGui:SetCore("OpenURL", link) end)
	end)
	closeButton.MouseButton1Click:Connect(function() api._CallCancelled() end)

	animateShow()
	return api
end

-- Jalankan evkey.lua
local function runEvkey(evurl)
	evurl = evurl or DEFAULT_EVKEY_URL
	task.spawn(function()
		task.wait(0.4)
		local ok, err = pcall(function()
			loadstring(game:HttpGet(evurl))()
		end)
		if not ok then warn("[QueryKey] Gagal load evkey:", err) end
	end)
end

function Framework.CreateWindow(cfg)
	cfg = cfg or {}
	cfg.KeySettings = cfg.KeySettings or {}
	cfg.Whitelisted = cfg.Whitelisted or {}

	local function validateKey(input)
		local target = cfg.KeySettings.Key or ""
		return input == target
	end

	local function handleSubmit(input, api)
		local plr = Players.LocalPlayer
		if table.find(cfg.Whitelisted, plr.UserId) then
			runEvkey(cfg.ExecuteOnPass)
			api._CallWhitelisted()
		elseif validateKey(input) then
			runEvkey(cfg.ExecuteOnPass)
			api._CallPassed()
		else
			local box = api._RawGui:FindFirstChild("KeyInput")
			if box then
				box.PlaceholderText = cfg.Text.Fail or "Access denied"
				box.Text = ""
				task.wait(2)
				box.PlaceholderText = "Enter key"
			end
			api._CallFailed()
		end
	end

	local ok, ui = pcall(function()
		return createStandaloneUI(cfg, handleSubmit)
	end)
	if not ok or not ui then
		error("[QueryKey] Gagal membuat GUI Key System: " .. tostring(ui))
	end

	if table.find(cfg.Whitelisted, Players.LocalPlayer.UserId) then
		pcall(function() ui.Destroy() end)
		runEvkey(cfg.ExecuteOnPass)
		return
	end

	return ui
end

return Framework
