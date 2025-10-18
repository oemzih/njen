local function createStandaloneUI(cfg, onKeySubmit)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StandaloneKeyUI"
    screenGui.DisplayOrder = 999 
    safeParent(screenGui)

    local borderColor = Color3.new(0, 1, 0)
    local textColor = Color3.new(1, 1, 1)
    local bgColor = Color3.new(0.05, 0.05, 0.05)
    pcall(function() 
        if cfg.Theme and cfg.Theme.Border then borderColor = Color3.fromHex("#" .. cfg.Theme.Border) end
        if cfg.Theme and cfg.Theme.Text then textColor = Color3.fromHex("#" .. cfg.Theme.Text) end
        if cfg.Theme and cfg.Theme.Background then bgColor = Color3.fromHex("#" .. cfg.Theme.Background) end
    end)

    local GUI_WIDTH = 360
    local GUI_HEIGHT = 230 
    local FINAL_POS = UDim2.new(0.5, 0, 0.5, 0)
    local START_POS = UDim2.new(0.5, 0, -0.5, 0)

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
    frame.Position = START_POS
    frame.BackgroundColor3 = bgColor
    frame.BorderSizePixel = 2
    frame.BorderColor3 = borderColor
    frame.BackgroundTransparency = 1
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = borderColor
    stroke.Thickness = 2
    stroke.Parent = frame

    local header = Instance.new("TextLabel")
    header.Text = cfg.Text.Title or "Key System"
    header.Size = UDim2.new(1, 0, 0, 35)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 24
    header.TextColor3 = borderColor
    header.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    header.BackgroundTransparency = 0.5
    header.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 3)
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 20
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.ZIndex = 2
    closeButton.Parent = frame

    local body = Instance.new("TextLabel")
    body.Text = cfg.Text.Body or "Enter the key to access the contents of the script."
    body.AnchorPoint = Vector2.new(0.5, 0)
    body.Position = UDim2.new(0.5, 0, 0, 45)
    body.Size = UDim2.new(0.9, 0, 0, 30)
    body.Font = Enum.Font.SourceSans
    body.TextSize = 15
    body.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    body.BackgroundTransparency = 1
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Center
    body.Parent = frame

    local keyInput = Instance.new("TextBox")
    keyInput.AnchorPoint = Vector2.new(0.5, 0)
    keyInput.PlaceholderText = "Enter key"
    keyInput.Text = ""
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(0.85, 0, 0, 40)
    keyInput.Position = UDim2.new(0.5, 0, 0, 85)
    keyInput.TextXAlignment = Enum.TextXAlignment.Center
    keyInput.Font = Enum.Font.SourceSans
    keyInput.TextSize = 18
    keyInput.TextColor3 = Color3.new(1, 1, 1)
    keyInput.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    keyInput.Parent = frame

    local keyInputCorner = Instance.new("UICorner")
    keyInputCorner.CornerRadius = UDim.new(0, 6)
    keyInputCorner.Parent = keyInput

    local buttonContainer = Instance.new("Frame")
    buttonContainer.AnchorPoint = Vector2.new(0.5, 0)
    buttonContainer.Size = UDim2.new(0.85, 0, 0, 40)
    buttonContainer.Position = UDim2.new(0.5, 0, 0, 145)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = frame

    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 20)
    buttonLayout.Parent = buttonContainer

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

    local function animateShow()
        local info = TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.Out)
        TweenService:Create(frame, info, {Position = FINAL_POS, BackgroundTransparency = 0}):Play()
    end
    
    local function animateHide(slideUp)
        local targetPos = slideUp and START_POS or UDim2.new(0.5, 0, 1.5, 0)
        local info = TweenInfo.new(0.4, EasingStyle.Quart, EasingDirection.In)
        local tween = TweenService:Create(frame, info, {Position = targetPos, BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Wait()
        screenGui:Destroy()
    end

    local userFailed, userPassed, userWhitelisted, userCancelled
    local api = {
        _RawGui = frame, 
        Failed = function(fn) userFailed = fn end,
        Passed = function(fn) userPassed = fn end,
        Whitelisted = function(fn) userWhitelisted = fn end,
        Cancelled = function(fn) userCancelled = fn end,
        Destroy = function() screenGui:Destroy() end,
        _CallFailed = function() if userFailed then pcall(userFailed) end end,
        _CallPassed = function() animateHide(true); if userPassed then pcall(userPassed) end end,
        _CallWhitelisted = function() animateHide(true); if userWhitelisted then pcall(userWhitelisted) end end,
        _CallCancelled = function() animateHide(false); if userCancelled then pcall(userCancelled) end end,
    }

    confirmButton.MouseButton1Click:Connect(function()
        onKeySubmit(keyInput.Text, api)
    end)
    getButton.MouseButton1Click:Connect(function()
        local getLink = cfg.GetKeyLink or "https://example.com/getkey"
        pcall(function() StarterGui:SetCore("OpenURL", getLink) end)
    end)
    closeButton.MouseButton1Click:Connect(function() api._CallCancelled() end)

    animateShow()
    return api
end
