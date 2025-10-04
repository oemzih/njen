-- source.lua
-- Loader: ambil key.lua (raw GitHub), cek/save key, lalu load Orion GUI
-- EDIT: ganti GITHUB_RAW_KEY_URL ke raw URL key.lua di repo-mu

local GITHUB_RAW_KEY_URL = "https://raw.githubusercontent.com/<username>/<repo>/main/key.lua"
local ORIONLIB_URL = "https://pastebin.com/raw/WRUyYTdY" -- ganti kalau perlu

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGUI = game:GetService("CoreGui")

local HIDEUI = get_hidden_gui or gethui
local SavedKeyPath = "ZaqueHub_key.txt" -- file lokal untuk menyimpan key

-- helper: tempatkan GUI ke parent executor-safe
local function Hide_UI(gui)
	if HIDEUI then
		gui.Parent = HIDEUI()
	elseif syn and syn.protect_gui then
		pcall(function() syn.protect_gui(gui) end)
		gui.Parent = CoreGUI
	elseif CoreGUI:FindFirstChild("RobloxGui") then
		gui.Parent = CoreGUI.RobloxGui
	else
		gui.Parent = CoreGUI
	end
end

-- helper: draggable
local function MakeDraggable(gui)
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

-- Notify simple
local function Notify(msg, dur)
	dur = dur or 2
	pcall(function()
		local m = Instance.new("Message", workspace)
		m.Text = tostring(msg)
		delay(dur, function() if m and m.Parent then m:Destroy() end end)
	end)
end

-- Load key module from GitHub raw
local KeyGenerator = nil
do
	local ok, mod = pcall(function()
		local code = game:HttpGet(GITHUB_RAW_KEY_URL, true)
		return loadstring(code)()
	end)
	if ok and mod then
		KeyGenerator = mod
	else
		-- fallback (simple) agar tidak crash
		KeyGenerator = {
			generate = function()
				local t = os.time()
				return "ZAQUE-" .. tostring(math.random(10000,99999)) .. "-" .. tostring(t) .. "-" .. tostring(t + 86400)
			end,
			isValid = function(k)
				if type(k) ~= "string" then return false end
				local exp = tonumber(string.match(k, "%-(%d+)$"))
				if not exp then return false end
				return os.time() <= exp
			end,
			remainingSeconds = function(k)
				local exp = tonumber(string.match(k, "%-(%d+)$"))
				if not exp then return nil end
				return math.max(0, exp - os.time())
			end
		}
		Notify("Warning: gagal ambil key.lua dari GitHub — pakai fallback lokal.", 4)
	end
end

-- file operations (jika executor mendukung)
local function saveKeyToFile(key)
	if writefile then
		pcall(function() writefile(SavedKeyPath, tostring(key)) end)
	end
end

local function loadSavedKey()
	if isfile and readfile and isfile(SavedKeyPath) then
		local ok, c = pcall(function() return readfile(SavedKeyPath) end)
		if ok and c then return tostring(c) end
	end
	return nil
end

local function deleteSavedKey()
	if isfile and delfile and isfile(SavedKeyPath) then
		pcall(function() delfile(SavedKeyPath) end)
	end
end

-- fungsi untuk format remaining jadi jam/menit
local function formatRemaining(sec)
	if not sec then return "unknown" end
	local h = math.floor(sec / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = sec % 60
	return string.format("%02dh %02dm %02ds", h, m, s)
end

-- UI untuk input & generate key
local function CreateKeyUI(onSuccess)
	if CoreGUI:FindFirstChild("ZaqueKeyUI") then return end

	local screen = Instance.new("ScreenGui")
	screen.Name = "ZaqueKeyUI"
	Hide_UI(screen)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 420, 0, 240)
	frame.Position = UDim2.new(0.5, -210, 0.5, -120)
	frame.BackgroundColor3 = Color3.fromRGB(26,26,26)
	frame.Parent = screen
	MakeDraggable(frame)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,0,0,44)
	title.Position = UDim2.new(0,0,0,0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(230,230,230)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Text = "Zaque Hub - Key System"
	title.Parent = frame

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,-20,0,28)
	info.Position = UDim2.new(0,10,0,44)
	info.BackgroundTransparency = 1
	info.TextColor3 = Color3.fromRGB(190,190,190)
	info.Font = Enum.Font.Gotham
	info.TextSize = 14
	info.Text = "Masukkan key (valid 24 jam). Tekan Generate untuk menyalin key."
	info.TextWrapped = true
	info.Parent = frame

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(0, 380, 0, 44)
	input.Position = UDim2.new(0, 20, 0, 80)
	input.BackgroundColor3 = Color3.fromRGB(40,40,40)
	input.TextColor3 = Color3.fromRGB(230,230,230)
	input.PlaceholderText = "Enter key..."
	input.ClearTextOnFocus = false
	input.Font = Enum.Font.Gotham
	input.TextSize = 16
	input.Parent = frame

	local checkBtn = Instance.new("TextButton")
	checkBtn.Size = UDim2.new(0, 180, 0, 44)
	checkBtn.Position = UDim2.new(0, 20, 0, 136)
	checkBtn.Text = "Check Key"
	checkBtn.Font = Enum.Font.Gotham
	checkBtn.TextSize = 16
	checkBtn.Parent = frame

	local genBtn = Instance.new("TextButton")
	genBtn.Size = UDim2.new(0, 180, 0, 44)
	genBtn.Position = UDim2.new(0, 220, 0, 136)
	genBtn.Text = "Generate (Copy)"
	genBtn.Font = Enum.Font.Gotham
	genBtn.TextSize = 16
	genBtn.Parent = frame

	local remainingLabel = Instance.new("TextLabel")
	remainingLabel.Size = UDim2.new(1,-20,0,18)
	remainingLabel.Position = UDim2.new(0,10,0,192)
	remainingLabel.BackgroundTransparency = 1
	remainingLabel.Font = Enum.Font.Gotham
	remainingLabel.TextSize = 12
	remainingLabel.TextColor3 = Color3.fromRGB(170,170,170)
	remainingLabel.Parent = frame

	-- show saved info if exists
	local saved = loadSavedKey()
	if saved and KeyGenerator and type(KeyGenerator.remainingSeconds) == "function" then
		local rem = KeyGenerator:remainingSeconds(saved)
		if rem and rem > 0 then
			remainingLabel.Text = "Saved key found — remaining: " .. formatRemaining(rem)
		else
			remainingLabel.Text = "Saved key found but expired. Please generate / enter new key."
		end
	else
		remainingLabel.Text = ""
	end

	checkBtn.MouseButton1Click:Connect(function()
		local val = tostring(input.Text or ""):gsub("%s+", "")
		if val == "" then Notify("Masukkan key dulu!",2); return end
		local ok = pcall(function()
			return KeyGenerator and KeyGenerator:isValid(val)
		end)
		local okRes = ok and KeyGenerator:isValid(val)
		if okRes then
			-- simpan & panggil sukses
			saveKeyToFile(val)
			Notify("Key valid. Menyimpan & memuat GUI...",2)
			pcall(function() screen:Destroy() end)
			if type(onSuccess) == "function" then onSuccess(val) end
		else
			Notify("Key invalid atau expired!", 2)
		end
	end)

	genBtn.MouseButton1Click:Connect(function()
		local okg, newKey = pcall(function()
			if KeyGenerator and type(KeyGenerator.generate) == "function" then
				return KeyGenerator:generate()
			end
			return "ZAQUE-" .. tostring(math.random(10000,99999)) .. "-" .. tostring(os.time()) .. "-" .. tostring(os.time() + 86400)
		end)
		if okg and newKey then
			if setclipboard then
				pcall(setclipboard, tostring(newKey))
				Notify("Key disalin ke clipboard.",2)
			else
				input.Text = tostring(newKey)
				Notify("Key dihasilkan. Salin manual dari kotak input.",2)
			end
			-- tampilkan remaining di label
			local rem = nil
			if KeyGenerator and type(KeyGenerator.remainingSeconds) == "function" then
				rem = KeyGenerator:remainingSeconds(newKey)
			else
				rem = tonumber(string.match(tostring(newKey), "%-(%d+)$")) and (tonumber(string.match(tostring(newKey), "%-(%d+)$")) - os.time())
			end
			if rem then remainingLabel.Text = "New key — remaining: " .. formatRemaining(rem) end
		else
			Notify("Gagal menghasilkan key.",2)
		end
	end)
end

-- fungsi untuk memuat Orion GUI (script ke-2)
local function loadOrionGUI()
	local ok, Orion = pcall(function()
		return loadstring(game:HttpGet(ORIONLIB_URL, true))()
	end)
	if not ok or not Orion then
		Notify("Gagal memuat OrionLib. Periksa koneksi/URL.", 3)
		return
	end

	-- === BEGIN: Orion GUI script (script ke-2) ===
	local Window = Orion:MakeWindow({
		Name = "zaque hub",
		HidePremium = false,
		SaveConfig = true,
		ConfigFolder = "zaque hub | 💪 muscle legends"
	})

	local Tab = Window:MakeTab({ Name = "Info", Icon = "rbxassetid://4483345998", PremiumOnly = false })
	local Section = Tab:AddSection({ Name = "Info" })
	local playerName = Players.LocalPlayer.Name
	Tab:AddLabel("Ola " .. playerName .. "! obrigado por usar o zaque hub")
	Tab:AddLabel("Bem aqui estão as informações")

	local Section2 = Tab:AddSection({ Name = "Sobre o Criador" })
	Tab:AddLabel("Feito por { zaque_blox } ou { zaquel }")
	Tab:AddLabel("Eu tenho 11 anos")

	local Section3 = Tab:AddSection({ Name = "Game" })
	Tab:AddLabel("💪 Muscle Legends")

	local Section4 = Tab:AddSection({ Name = "Sociais" })
	Tab:AddButton({ Name = "Discord oficial", Callback = function() pcall(setclipboard, "https://discord.gg/") end })
	Tab:AddButton({ Name = "Grupo do Zap Oficial", Callback = function() pcall(setclipboard, "https://chat.whatsapp.com/CpJRk0pToQsKx94iKIm2a7") end })
	Tab:AddButton({ Name = "Tiktok Oficial", Callback = function() pcall(setclipboard, "https://") end })

	local TabMain = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false })
	local SectionFarm = TabMain:AddSection({ Name = "Farm" })
	local autoPunch, autoTrain, speedEnabled, jumpEnabled = false, false, false, false
	local walkSpeed, jumpPower = 16, 50

	TabMain:AddToggle({
		Name = "Auto Punch",
		Default = false,
		Callback = function(Value)
			autoPunch = Value
			spawn(function()
				while autoPunch do
					local character = Players.LocalPlayer.Character
					if character and character:FindFirstChildOfClass("Tool") then
						pcall(function() character:FindFirstChildOfClass("Tool"):Activate() end)
					end
					wait(0.3)
				end
			end)
		end
	})

	local function equipHalter()
		local character = Players.LocalPlayer.Character
		local backpack = Players.LocalPlayer.Backpack
		for _, tool in pairs(character:GetChildren()) do if tool:IsA("Tool") then return tool end end
		for _, tool in pairs(backpack:GetChildren()) do if tool:IsA("Tool") then tool.Parent = character; return tool end end
		return nil
	end
	TabMain:AddToggle({
		Name = "Auto Train",
		Default = false,
		Callback = function(Value)
			autoTrain = Value
			spawn(function()
				while autoTrain do
					local character = Players.LocalPlayer.Character
					if character then
						local tool = equipHalter()
						if tool then pcall(function() tool:Activate() end) end
					end
					wait(0.5)
				end
			end)
		end
	})

	TabMain:AddToggle({
		Name = "Speed",
		Default = false,
		Callback = function(Value)
			speedEnabled = Value
			pcall(function()
				if speedEnabled then
					Players.LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
				else
					Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
				end
			end)
		end
	})

	local speedOptions = {}
	for i = 1, 500 do table.insert(speedOptions, tostring(i)) end
	TabMain:AddDropdown({
		Name = "Set Speed",
		Default = "16",
		Options = speedOptions,
		Callback = function(Value)
			if speedEnabled then
				walkSpeed = tonumber(Value)
				pcall(function() Players.LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed end)
			end
		end
	})

	TabMain:AddToggle({
		Name = "Jump Power",
		Default = false,
		Callback = function(Value)
			jumpEnabled = Value
			pcall(function()
				if jumpEnabled then
					Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
					Players.LocalPlayer.Character.Humanoid.JumpPower = jumpPower
				else
					Players.LocalPlayer.Character.Humanoid.JumpPower = 50
				end
			end)
		end
	})

	local jumpOptions = {}
	for i = 50, 500, 10 do table.insert(jumpOptions, tostring(i)) end
	TabMain:AddDropdown({
		Name = "Set Jump Power",
		Default = "50",
		Options = jumpOptions,
		Callback = function(Value)
			if jumpEnabled then
				jumpPower = tonumber(Value)
				pcall(function() Players.LocalPlayer.Character.Humanoid.JumpPower = jumpPower end)
			end
		end
	})

	local TabScript = Window:MakeTab({ Name = "script", Icon = "rbxassetid://4483345998", PremiumOnly = false })
	local SectionScript = TabScript:AddSection({ Name = "universal" })
	TabScript:AddButton({
		Name = "Infinite Yield",
		Callback = function()
			pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source', true))() end)
		end
	})
	-- === END Orion GUI script ===
end

-- MAIN FLOW
local saved = loadSavedKey()
if saved then
	-- jika saved expired -> hapus
	local ok, valid = pcall(function() return KeyGenerator and KeyGenerator:isValid(saved) end)
	if not ok or not valid then
		-- expired: hapus file dan tampilkan UI
		deleteSavedKey()
		Notify("Saved key expired atau invalid. Input/generate key baru.", 3)
		CreateKeyUI(function(_) loadOrionGUI() end)
	else
		-- valid -> langsung load GUI
		Notify("Saved key valid. Memuat GUI...", 2)
		loadOrionGUI()
	end
else
	-- tidak ada saved -> tampilkan UI
	CreateKeyUI(function(_) loadOrionGUI() end)
end
