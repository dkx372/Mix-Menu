-- CONFIGURAÇÃO
local flySpeed = 7
local keyVerificacaoURL = "https://ae0c06aa-b03c-4de4-96f4-58f6064937d7-00-3szotp5duaqa7.picard.replit.dev/" -- Altere para seu link

-- SERVIÇOS
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- VARIÁVEIS
local flying = false
local bodyGyro, bodyVelocity
local userKey = ""

-- 🖼️ INTERFACE DE KEY
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MiniMenuScript"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local background = Instance.new("Frame", screenGui)
background.Size = UDim2.new(0, 260, 0, 140)
background.Position = UDim2.new(0.5, -130, 0.5, -70)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BorderSizePixel = 0

local title = Instance.new("TextLabel", background)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "MiniMenuScript"

local input = Instance.new("TextBox", background)
input.PlaceholderText = "SuaKeyAqui"
input.Size = UDim2.new(0.9, 0, 0, 30)
input.Position = UDim2.new(0.05, 0, 0.4, 0)
input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Text = ""
input.Font = Enum.Font.Gotham
input.TextSize = 14

local validarBtn = Instance.new("TextButton", background)
validarBtn.Size = UDim2.new(0.9, 0, 0, 30)
validarBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
validarBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
validarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
validarBtn.Font = Enum.Font.GothamBold
validarBtn.TextSize = 14
validarBtn.Text = "VALIDAR KEY"

local aviso = Instance.new("TextLabel", background)
aviso.Size = UDim2.new(1, 0, 0, 20)
aviso.Position = UDim2.new(0, 0, 1, -20)
aviso.BackgroundTransparency = 1
aviso.TextColor3 = Color3.fromRGB(255, 0, 0)
aviso.Text = ""
aviso.Font = Enum.Font.Gotham
aviso.TextSize = 13

-- ✅ FLY UI
local flyGui = Instance.new("TextLabel")
flyGui.Size = UDim2.new(0, 140, 0, 40)
flyGui.Position = UDim2.new(0.4, 0, 0.05, 0)
flyGui.BackgroundColor3 = Color3.fromRGB(20, 20, 60)
flyGui.TextScaled = true
flyGui.Font = Enum.Font.GothamBold
flyGui.Text = "Fly: OFF"
flyGui.TextColor3 = Color3.fromRGB(255, 0, 0)
flyGui.BorderSizePixel = 0
flyGui.ZIndex = 10
flyGui.Visible = false
flyGui.Parent = screenGui

-- 🌐 Verifica key
local function validarKeyComServidor(key)
	local ok, resposta = pcall(function()
		return HttpService:GetAsync(keyVerificacaoURL .. key)
	end)
	print("Verificando key:", key)
	print("Resposta do servidor:", resposta)
	return ok and resposta == "VALID"
end

-- 🛫 Fly
local function iniciarFly()
	local character = player.Character or player.CharacterAdded:Wait()
	local HRP = character:WaitForChild("HumanoidRootPart")

	bodyGyro = Instance.new("BodyGyro", HRP)
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = HRP.CFrame

	bodyVelocity = Instance.new("BodyVelocity", HRP)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	game:GetService("RunService").RenderStepped:Connect(function()
		if flying then
			local cam = workspace.CurrentCamera
			local dir = Vector3.new()
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
			bodyVelocity.Velocity = dir.Magnitude == 0 and Vector3.zero or dir.Unit * flySpeed
			bodyGyro.CFrame = cam.CFrame
		end
	end)
end

-- 🔄 Toggle Fly
local function toggleFly()
	flying = not flying
	if flying then
		flyGui.Text = "Fly: ON"
		flyGui.TextColor3 = Color3.fromRGB(0, 255, 0)
		iniciarFly()
	else
		flyGui.Text = "Fly: OFF"
		flyGui.TextColor3 = Color3.fromRGB(255, 0, 0)
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVelocity then bodyVelocity:Destroy() end
	end
end

-- 🎯 Validação do botão
validarBtn.MouseButton1Click:Connect(function()
	userKey = input.Text
	if validarKeyComServidor(userKey) then
		background:Destroy()
		flyGui.Visible = true
	else
		aviso.Text = "KEY INVÁLIDA!"
	end
end)

-- 🖱️ Clique na UI para ativar o fly
flyGui.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		toggleFly()
	end
end)
