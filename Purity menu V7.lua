-- ╔══════════════════════════════════════════════════════════╗
-- ║   PURITY GUI  •  v7.0  •  ESP+AIMBOT+COMBAT+MISC+CFG    ║
-- ║        LocalScript — StarterPlayerScripts                ║
-- ║        RightShift → abre/fecha o menu                    ║
-- ╚══════════════════════════════════════════════════════════╝

-- ══════════════════════════════════════════════════════════
--                       SERVIÇOS
-- ══════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════
--                    ESTADO GERAL
-- ══════════════════════════════════════════════════════════

local ESP = {
	Enabled   = false,
	RGB       = false,
	Box       = false,
	Skeleton  = false,
	Names     = false,
	Distance  = false,
	HealthBar = false,
	Tracers   = false,
	Radar     = false,   -- NOVO: radar 2D
	VisionCone= false,   -- NOVO: cone de visão
}

local AIMBOT = {
	Enabled    = false,
	Silent     = false,
	Prediction = false,
	FOVCircle  = false,
	TeamCheck  = true,
	VisCheck   = false,
	AutoShoot  = false,
	AimKey     = false,   -- NOVO: só mira com tecla pressionada
	TargetSwitch = false, -- NOVO: troca de alvo ao eliminar
	AimShake   = false,   -- NOVO: oscilação humana
	FOVRadius  = 150,
	Smoothness = 8,
	MaxDist    = 500,     -- NOVO: distância máxima em studs
	ShakeAmt   = 2,       -- NOVO: intensidade do shake
	TargetPart = "Head",
	AimKeyCode = Enum.KeyCode.LeftAlt,
}

local COMBAT = {
	NoRecoil     = false,
	NoSpread     = false,
	RapidFire    = false,
	InfiniteAmmo = false,
	BunnyHop     = false,
	FastReload   = false,
	AntiRagdoll  = false, -- NOVO
	FlyHack      = false, -- NOVO
	SpeedHack    = false, -- NOVO
	JumpPower    = false, -- NOVO
	InfiniteJump = false, -- NOVO
	FireRateMult = 1,
	ReloadSpeed  = 1,
	WalkSpeed    = 50,    -- NOVO
	JumpPowerVal = 100,   -- NOVO
	FlySpeed     = 50,    -- NOVO
}

-- Conexões ativas de combat (guardamos para poder desligar)
local combatConns = {}

-- ══════════════════════════════════════════════════════════
--                    ESTADO MISC
-- ══════════════════════════════════════════════════════════

local MISC = {
	CustomFOV    = false,
	SpinBot      = false,
	BigHead      = false,
	Noclip       = false,
	WallBang     = false,
	AntiAFK      = false, -- NOVO
	TimeOfDay    = false, -- NOVO
	FOVValue     = 70,
	SpinSpeed    = 10,
	BigHeadScale = 2,
	TimeValue    = 12,    -- NOVO: hora do dia (0-24)
}

local miscConns     = {}
local originalFOV   = 70
local originalHeads = {}

-- Referência forward para a ScreenGui (preenchida quando a GUI é criada)
local _screenGuiRef = nil

-- ══════════════════════════════════════════════════════════
--                       HELPERS
-- ══════════════════════════════════════════════════════════

local function isEnemy(plr)
	if not LocalPlayer.Team or not plr.Team then return true end
	return plr.Team ~= LocalPlayer.Team
end

local function healthToColor(pct)
	pct = math.clamp(pct, 0, 1)
	if pct > 0.5 then
		return Color3.fromRGB(math.floor(255*(1-pct)*2), 255, 0)
	else
		return Color3.fromRGB(255, math.floor(255*pct*2), 0)
	end
end

-- Distância em pixels da posição de tela até o centro
local function screenDist(screenPos)
	local vp = Camera.ViewportSize
	return (Vector2.new(screenPos.X, screenPos.Y) - vp/2).Magnitude
end

-- Verifica se um player está visível (ray cast simples)
local function isVisible(plr)
	local char = plr.Character
	if not char then return false end
	local part = char:FindFirstChild(AIMBOT.TargetPart) or char:FindFirstChild("HumanoidRootPart")
	if not part then return false end

	local myChar = LocalPlayer.Character
	local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return false end

	local origin    = myHRP.Position
	local direction = (part.Position - origin)
	local ray       = RaycastParams.new()
	ray.FilterType  = Enum.RaycastFilterType.Exclude
	ray.FilterDescendantsInstances = {myChar, char}

	local result = workspace:Raycast(origin, direction, ray)
	return result == nil  -- nenhum obstáculo = visível
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  ─  HIGHLIGHT + NOME + DISTÂNCIA
-- ══════════════════════════════════════════════════════════

local drawings = {}

local function clearESP(plr)
	if drawings[plr] then
		for _, obj in pairs(drawings[plr]) do
			pcall(function() obj:Destroy() end)
			pcall(function() obj:Remove()  end)
		end
		drawings[plr] = nil
	end
end

local function createESP(plr)
	if plr == LocalPlayer then return end
	clearESP(plr)
	local char = plr.Character
	if not char then return end
	drawings[plr] = {}

	local hl = Instance.new("Highlight")
	hl.FillTransparency    = 0.5
	hl.OutlineTransparency = 0
	hl.OutlineColor        = Color3.fromRGB(168,50,255)
	hl.FillColor           = Color3.fromRGB(100,0,180)
	hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Enabled             = ESP.Box
	hl.Parent              = char

	local bill = Instance.new("BillboardGui")
	bill.Size        = UDim2.new(0,120,0,44)
	bill.AlwaysOnTop = true
	bill.StudsOffset = Vector3.new(0,3.2,0)
	bill.Enabled     = ESP.Names or ESP.Distance
	bill.Parent      = char:WaitForChild("Head")

	local layout = Instance.new("UIListLayout", bill)
	layout.SortOrder           = Enum.SortOrder.LayoutOrder
	layout.FillDirection       = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding             = UDim.new(0,2)

	local nameLbl = Instance.new("TextLabel", bill)
	nameLbl.Size                   = UDim2.new(1,0,0,18)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text                   = plr.Name
	nameLbl.TextColor3             = Color3.fromRGB(200,80,255)
	nameLbl.Font                   = Enum.Font.GothamBold
	nameLbl.TextSize               = 13
	nameLbl.TextStrokeTransparency = 0
	nameLbl.TextStrokeColor3       = Color3.fromRGB(0,0,0)
	nameLbl.Visible                = ESP.Names
	nameLbl.LayoutOrder            = 1

	local distLbl = Instance.new("TextLabel", bill)
	distLbl.Size                   = UDim2.new(1,0,0,16)
	distLbl.BackgroundTransparency = 1
	distLbl.Text                   = "0 studs"
	distLbl.TextColor3             = Color3.fromRGB(200,200,255)
	distLbl.Font                   = Enum.Font.Gotham
	distLbl.TextSize               = 11
	distLbl.TextStrokeTransparency = 0
	distLbl.TextStrokeColor3       = Color3.fromRGB(0,0,0)
	distLbl.Visible                = ESP.Distance
	distLbl.LayoutOrder            = 2

	drawings[plr].Highlight = hl
	drawings[plr].Billboard = bill
	drawings[plr].NameLabel = nameLbl
	drawings[plr].DistLabel = distLbl
end

local function applyBoxVisibility()
	for _,d in pairs(drawings) do
		if d.Highlight then d.Highlight.Enabled = ESP.Box end
	end
end
local function applyNameVisibility()
	for _,d in pairs(drawings) do
		if d.NameLabel then
			d.NameLabel.Visible = ESP.Names
			if d.Billboard then d.Billboard.Enabled = ESP.Names or ESP.Distance end
		end
	end
end
local function applyDistVisibility()
	for _,d in pairs(drawings) do
		if d.DistLabel then
			d.DistLabel.Visible = ESP.Distance
			if d.Billboard then d.Billboard.Enabled = ESP.Names or ESP.Distance end
		end
	end
end
local function refreshAllESP()
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and isEnemy(plr) then
			createESP(plr)
		end
	end
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  ─  HEALTH BAR
-- ══════════════════════════════════════════════════════════

local HealthBars = {}

local function clearHealthBar(plr)
	if HealthBars[plr] then
		pcall(function() HealthBars[plr].bg:Remove()  end)
		pcall(function() HealthBars[plr].fg:Remove()  end)
		pcall(function() HealthBars[plr].txt:Remove() end)
		HealthBars[plr] = nil
	end
end

local function createHealthBar(plr)
	if HealthBars[plr] then return end
	local bg  = Drawing.new("Line")
	bg.Thickness    = 6
	bg.Color        = Color3.fromRGB(20,20,20)
	bg.Transparency = 0.5
	bg.Visible      = false

	local fg  = Drawing.new("Line")
	fg.Thickness    = 4
	fg.Color        = Color3.fromRGB(0,255,80)
	fg.Transparency = 1
	fg.Visible      = false

	local txt = Drawing.new("Text")
	txt.Size    = 11
	txt.Font    = Drawing.Fonts.UI
	txt.Color   = Color3.fromRGB(255,255,255)
	txt.Outline = true
	txt.Visible = false

	HealthBars[plr] = {bg=bg, fg=fg, txt=txt}
end

local function updateHealthBar(plr, rgbColor)
	local char = plr.Character
	if not char then clearHealthBar(plr) return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	local hp    = hum.Health
	local maxHP = math.max(hum.MaxHealth, 1)
	local pct   = math.clamp(hp/maxHP, 0, 1)

	local head  = char:FindFirstChild("Head") or hrp
	local vHead, onH = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
	local vFoot, onF = Camera:WorldToViewportPoint(hrp.Position  - Vector3.new(0,3,0))

	if not (onH and onF) then
		if HealthBars[plr] then
			HealthBars[plr].bg.Visible  = false
			HealthBars[plr].fg.Visible  = false
			HealthBars[plr].txt.Visible = false
		end
		return
	end

	local screenH = math.max(math.abs(vFoot.Y - vHead.Y), 10)
	local halfW   = screenH * 0.28
	local xBar    = vHead.X - halfW - 8
	local yTop    = vHead.Y
	local yBot    = vFoot.Y
	local yFill   = yBot - (yBot-yTop)*pct

	if not HealthBars[plr] then createHealthBar(plr) end
	local bar = HealthBars[plr]

	bar.bg.From    = Vector2.new(xBar, yTop)
	bar.bg.To      = Vector2.new(xBar, yBot)
	bar.bg.Visible = true

	bar.fg.From    = Vector2.new(xBar, yBot)
	bar.fg.To      = Vector2.new(xBar, yFill)
	bar.fg.Color   = ESP.RGB and rgbColor or healthToColor(pct)
	bar.fg.Visible = true

	bar.txt.Text     = math.floor(hp).." HP"
	bar.txt.Position = Vector2.new(xBar-2, yTop-14)
	bar.txt.Color    = ESP.RGB and rgbColor or Color3.fromRGB(230,230,230)
	bar.txt.Visible  = true
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  ─  SKELETON
-- ══════════════════════════════════════════════════════════

local Skeletons = {}

local function getBones(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return nil end
	if hum.RigType == Enum.HumanoidRigType.R6 then
		return {
			{"Head","Torso"},
			{"Torso","Left Arm"},  {"Left Arm","Left Leg"},
			{"Torso","Right Arm"}, {"Right Arm","Right Leg"},
		}
	end
	return {
		{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
		{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
		{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
		{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
		{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
	}
end

local function clearSkeleton(plr)
	if Skeletons[plr] then
		for _,l in pairs(Skeletons[plr]) do pcall(function() l:Remove() end) end
		Skeletons[plr] = nil
	end
end

local function createSkeleton(plr, count)
	if Skeletons[plr] then return end
	Skeletons[plr] = {}
	for i = 1, count do
		local l = Drawing.new("Line")
		l.Thickness = 1.5
		l.Color     = Color3.fromRGB(168,50,255)
		l.Visible   = false
		Skeletons[plr][i] = l
	end
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  ─  TRACERS
-- ══════════════════════════════════════════════════════════

local Tracers = {}

local function clearTracer(plr)
	if Tracers[plr] then
		pcall(function() Tracers[plr]:Remove() end)
		Tracers[plr] = nil
	end
end

local function createTracer(plr)
	if Tracers[plr] then return end
	local l = Drawing.new("Line")
	l.Thickness = 1
	l.Color     = Color3.fromRGB(168,50,255)
	l.Visible   = false
	Tracers[plr] = l
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA AIMBOT
-- ══════════════════════════════════════════════════════════

-- Círculo de FOV (Drawing)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness    = 1.5
fovCircle.Color        = Color3.fromRGB(168, 50, 255)
fovCircle.Filled       = false
fovCircle.Transparency = 1
fovCircle.NumSides     = 64
fovCircle.Visible      = false

-- Encontra o melhor alvo dentro do FOV
local function getBestTarget()
	local bestPlr  = nil
	local bestDist = math.huge

	local myChar = LocalPlayer.Character
	if not myChar then return nil end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		if AIMBOT.TeamCheck and not isEnemy(plr) then continue end

		local char = plr.Character
		if not char then continue end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end

		local part = char:FindFirstChild(AIMBOT.TargetPart)
			or char:FindFirstChild("HumanoidRootPart")
		if not part then continue end

		local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end

		local dist = screenDist(screenPos)
		if dist > AIMBOT.FOVRadius then continue end

		if AIMBOT.VisCheck and not isVisible(plr) then continue end

		if dist < bestDist then
			bestDist = dist
			bestPlr  = plr
		end
	end

	return bestPlr
end

-- Prediction: estima a posição futura do alvo
-- compensando pelo tempo de voo do projétil (approx)
local function getPredictedPosition(char, part)
	if not AIMBOT.Prediction then
		return part.Position
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return part.Position end

	-- Velocidade linear do personagem via AssemblyLinearVelocity
	local vel    = hrp.AssemblyLinearVelocity
	-- Distância ao alvo
	local myHRP  = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local dist   = myHRP and (myHRP.Position - part.Position).Magnitude or 100
	-- Tempo de voo estimado (velocidade de bala genérica ~1000 studs/s)
	local tFlight = dist / 1000
	return part.Position + vel * tFlight
end

-- Variável de controle do RenderStepped do aimbot
local currentTarget = nil

-- Loop principal do aimbot (RenderStepped para suavidade)
local aimbotConn
local function startAimbotLoop()
	if aimbotConn then return end
	aimbotConn = RunService.RenderStepped:Connect(function(dt)
		-- Atualiza posição do FOV Circle
		if AIMBOT.FOVCircle then
			local vp = Camera.ViewportSize
			fovCircle.Position  = Vector2.new(vp.X/2, vp.Y/2)
			fovCircle.Radius    = AIMBOT.FOVRadius
			fovCircle.Visible   = true
		else
			fovCircle.Visible = false
		end

		if not AIMBOT.Enabled then
			currentTarget = nil
			return
		end

		-- AimKey: só mira enquanto tecla estiver pressionada
		if AIMBOT.AimKey and not UserInputService:IsKeyDown(AIMBOT.AimKeyCode) then
			currentTarget = nil
			return
		end

		-- Encontra alvo
		local prevTarget = currentTarget
		local target = getBestTarget()

		-- TargetSwitch: se o alvo anterior morreu, procura próximo imediatamente
		if AIMBOT.TargetSwitch and prevTarget then
			local prevChar = prevTarget.Character
			local prevHum  = prevChar and prevChar:FindFirstChildOfClass("Humanoid")
			if not prevHum or prevHum.Health <= 0 then
				target = getBestTarget()
			end
		end

		currentTarget = target
		if not target then return end

		local char = target.Character
		if not char then return end

		-- MaxDist: ignora alvo se muito longe
		if AIMBOT.MaxDist > 0 then
			local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local tHRP  = char:FindFirstChild("HumanoidRootPart")
			if myHRP and tHRP then
				local d = (myHRP.Position - tHRP.Position).Magnitude
				if d > AIMBOT.MaxDist then currentTarget = nil; return end
			end
		end

		local part = char:FindFirstChild(AIMBOT.TargetPart)
			or char:FindFirstChild("HumanoidRootPart")
		if not part then return end

		local aimPos = getPredictedPosition(char, part)

		-- ── NORMAL AIM ────────────────────────────────────
		if not AIMBOT.Silent then
			-- AimShake: adiciona oscilação humana leve
			local shakeOffset = Vector3.new(0,0,0)
			if AIMBOT.AimShake then
				local t = tick()
				local amt = AIMBOT.ShakeAmt * 0.01
				shakeOffset = Vector3.new(
					math.sin(t*7.3)*amt,
					math.cos(t*5.9)*amt,
					0
				)
			end
			local targetCF = CFrame.new(Camera.CFrame.Position, aimPos + shakeOffset)
			local alpha    = math.clamp(dt * (21 - AIMBOT.Smoothness), 0, 1)
			Camera.CFrame  = Camera.CFrame:Lerp(targetCF, alpha)
		end

		-- ── AUTO SHOOT ────────────────────────────────────
		if AIMBOT.AutoShoot then
			pcall(function() mouse1press() end)
		end
	end)
end

local function stopAimbotLoop()
	if aimbotConn then
		aimbotConn:Disconnect()
		aimbotConn = nil
	end
	fovCircle.Visible = false
	currentTarget     = nil
end

-- ── Silent Aim ────────────────────────────────────────────
-- Intercepta o raio do projétil no momento do disparo
-- e redireciona para a cabeça do alvo mais próximo no FOV.
-- Funciona via hook no Camera:ScreenPointToRay (técnica comum).
local silentConn
local function startSilentAim()
	if silentConn then return end
	-- Hook do WorldToScreenPoint / deflect via câmera fake
	-- A abordagem mais compatível com executores modernos:
	-- sobrescreve Camera.CFrame no momento do clique por 1 frame
	silentConn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not AIMBOT.Silent or not AIMBOT.Enabled then return end

		local target = getBestTarget()
		if not target then return end

		local char = target.Character
		if not char then return end

		local part = char:FindFirstChild(AIMBOT.TargetPart)
			or char:FindFirstChild("HumanoidRootPart")
		if not part then return end

		local aimPos  = getPredictedPosition(char, part)
		local savedCF = Camera.CFrame

		-- Redireciona a câmera por 1 frame para o alvo
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPos)

		-- Restaura no próximo frame
		task.defer(function()
			Camera.CFrame = savedCF
		end)
	end)
end

local function stopSilentAim()
	if silentConn then
		silentConn:Disconnect()
		silentConn = nil
	end
end

-- ══════════════════════════════════════════════════════════
--               LOOP PRINCIPAL DO ESP
-- ══════════════════════════════════════════════════════════

local rgbHue = 0

RunService.RenderStepped:Connect(function(dt)
	rgbHue = (rgbHue + dt*0.15) % 1
	local rgbColor = Color3.fromHSV(rgbHue, 1, 1)

	local myHRP = LocalPlayer.Character
		and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end

		local char = plr.Character
		local isEn = isEnemy(plr)

		if not ESP.Enabled or not char or not isEn then
			clearESP(plr); clearSkeleton(plr); clearTracer(plr); clearHealthBar(plr)
			continue
		end

		if not drawings[plr] then createESP(plr) end
		local d = drawings[plr]

		local espColor = ESP.RGB and rgbColor or Color3.fromRGB(168,50,255)

		if d.Highlight then
			d.Highlight.OutlineColor = espColor
			d.Highlight.FillColor    = ESP.RGB and rgbColor or Color3.fromRGB(100,0,180)
		end
		if d.NameLabel then
			d.NameLabel.TextColor3 = ESP.RGB and rgbColor or Color3.fromRGB(200,80,255)
		end

		-- Distância
		if ESP.Distance and d.DistLabel then
			if myHRP and char:FindFirstChild("HumanoidRootPart") then
				local dist = math.floor((myHRP.Position - char.HumanoidRootPart.Position).Magnitude)
				d.DistLabel.Text       = dist.." studs"
				d.DistLabel.TextColor3 = ESP.RGB and rgbColor or Color3.fromRGB(200,200,255)
				d.DistLabel.Visible    = true
			end
		elseif d.DistLabel then
			d.DistLabel.Visible = false
		end

		if d.Billboard then
			d.Billboard.Enabled = ESP.Names or ESP.Distance
		end

		-- Health Bar
		if ESP.HealthBar then updateHealthBar(plr, rgbColor) else clearHealthBar(plr) end

		-- Skeleton
		local bones = getBones(char)
		if ESP.Skeleton and bones then
			if not Skeletons[plr] then createSkeleton(plr, #bones) end
			for i, b in ipairs(bones) do
				local p1   = char:FindFirstChild(b[1])
				local p2   = char:FindFirstChild(b[2])
				local line = Skeletons[plr] and Skeletons[plr][i]
				if p1 and p2 and line then
					local v1,o1 = Camera:WorldToViewportPoint(p1.Position)
					local v2,o2 = Camera:WorldToViewportPoint(p2.Position)
					if o1 and o2 then
						line.From    = Vector2.new(v1.X,v1.Y)
						line.To      = Vector2.new(v2.X,v2.Y)
						line.Color   = espColor
						line.Visible = true
					else line.Visible = false end
				elseif line then line.Visible = false end
			end
		else clearSkeleton(plr) end

		-- Tracers
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if ESP.Tracers and hrp then
			if not Tracers[plr] then createTracer(plr) end
			local v, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			local tracer = Tracers[plr]
			if onScreen and tracer then
				local vp = Camera.ViewportSize
				tracer.From    = Vector2.new(vp.X/2, vp.Y)
				tracer.To      = Vector2.new(v.X, v.Y)
				tracer.Color   = espColor
				tracer.Visible = true
			elseif tracer then tracer.Visible = false end
		else clearTracer(plr) end
	end
end)

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  ─  RADAR 2D (Drawing)
-- ══════════════════════════════════════════════════════════

-- Radar: círculo de fundo + ponto central + pontos dos inimigos
local radarBG    = Drawing.new("Circle")
radarBG.Radius   = 70; radarBG.Color = Color3.fromRGB(10,5,20)
radarBG.Filled   = true; radarBG.Transparency = 0.45
radarBG.NumSides = 48; radarBG.Visible = false

local radarBorder = Drawing.new("Circle")
radarBorder.Radius = 70; radarBorder.Color = Color3.fromRGB(168,50,255)
radarBorder.Filled = false; radarBorder.Thickness = 1.5
radarBorder.Transparency = 1; radarBorder.NumSides = 48; radarBorder.Visible = false

local radarSelf = Drawing.new("Circle")
radarSelf.Radius = 4; radarSelf.Color = Color3.fromRGB(100,220,255)
radarSelf.Filled = true; radarSelf.Transparency = 1
radarSelf.NumSides = 16; radarSelf.Visible = false

local radarDots = {}  -- radarDots[plr] = Drawing Circle

local RADAR_POS    = Vector2.new(80, 80)   -- canto superior esquerdo
local RADAR_RADIUS = 70                    -- px do radar
local RADAR_RANGE  = 200                   -- studs representados pelo raio

local function clearRadarDot(plr)
	if radarDots[plr] then
		pcall(function() radarDots[plr]:Remove() end)
		radarDots[plr] = nil
	end
end

local function updateRadar(rgbColor)
	local myChar = LocalPlayer.Character
	local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")

	local themeColor = ESP.RGB and rgbColor or Color3.fromRGB(168,50,255)

	radarBG.Position     = RADAR_POS
	radarBorder.Position = RADAR_POS
	radarSelf.Position   = RADAR_POS
	radarBG.Visible      = true
	radarBorder.Visible  = true
	radarSelf.Visible    = true
	radarBorder.Color    = themeColor

	if not myHRP then return end

	-- Yaw da câmera: ângulo de rotação horizontal
	-- Usamos o LookVector para saber para onde a câmera aponta no plano XZ
	local camLook = Camera.CFrame.LookVector
	local camYaw  = math.atan2(camLook.X, camLook.Z)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		local char = plr.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")

		if not ESP.Enabled or not hrp or not isEnemy(plr) then
			clearRadarDot(plr); continue
		end

		if not radarDots[plr] then
			local dot      = Drawing.new("Circle")
			dot.Radius     = 4
			dot.Filled     = true
			dot.Transparency = 1
			dot.NumSides   = 12
			dot.Visible    = false
			radarDots[plr] = dot
		end

		-- Diferença de posição no plano XZ (ignoramos Y)
		local dx = hrp.Position.X - myHRP.Position.X
		local dz = hrp.Position.Z - myHRP.Position.Z

		-- Rotaciona pelo yaw da câmera para orientar o norte do radar
		-- como a frente da câmera
		local rx =  dx * math.cos(camYaw) - dz * math.sin(camYaw)
		local ry =  dx * math.sin(camYaw) + dz * math.cos(camYaw)

		-- Distância 2D
		local dist2D = math.sqrt(rx*rx + ry*ry)

		-- Clamp: se mais longe que RADAR_RANGE, coloca na borda
		local clamped = math.min(dist2D / RADAR_RANGE, 1)
		local finalRx, finalRy
		if dist2D > 0.01 then
			finalRx = (rx / dist2D) * clamped * (RADAR_RADIUS - 6)
			finalRy = (ry / dist2D) * clamped * (RADAR_RADIUS - 6)
		else
			finalRx, finalRy = 0, 0
		end

		-- No radar: X = direita, Y = cima (Z negativo no mundo = frente)
		-- Por isso invertemos ry para Y da tela
		local px = RADAR_POS.X + finalRx
		local py = RADAR_POS.Y - finalRy

		local dot    = radarDots[plr]
		dot.Position = Vector2.new(px, py)
		dot.Color    = ESP.RGB and rgbColor or Color3.fromRGB(255, 60, 60)
		dot.Visible  = true
	end
end

local function hideRadar()
	radarBG.Visible     = false
	radarBorder.Visible = false
	radarSelf.Visible   = false
	for _, plr in ipairs(Players:GetPlayers()) do clearRadarDot(plr) end
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  ─  CONE DE VISÃO (Drawing)
-- Desenha um triângulo 2D na tela indicando a direção
-- que cada inimigo está olhando.
-- ══════════════════════════════════════════════════════════

local VisionCones = {}  -- VisionCones[plr] = { l1, l2, l3 } (3 linhas = triângulo)

local CONE_LEN   = 40   -- comprimento do cone em pixels na tela
local CONE_ANGLE = 30   -- meia-abertura do cone em graus

local function clearVisionCone(plr)
	if VisionCones[plr] then
		for _, l in pairs(VisionCones[plr]) do pcall(function() l:Remove() end) end
		VisionCones[plr] = nil
	end
end

local function createVisionCone(plr)
	if VisionCones[plr] then return end
	VisionCones[plr] = {}
	for i = 1, 3 do
		local l = Drawing.new("Line")
		l.Thickness = 1.2; l.Color = Color3.fromRGB(255,200,0)
		l.Transparency = 1; l.Visible = false
		VisionCones[plr][i] = l
	end
end

local function updateVisionCones(rgbColor)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		local char = plr.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		local head = char and char:FindFirstChild("Head")

		if not ESP.Enabled or not hrp or not head or not isEnemy(plr) then
			clearVisionCone(plr); continue
		end

		-- Projeta a cabeça (origem do cone) na tela
		local vHead, onHead = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
		if not onHead then clearVisionCone(plr); continue end

		-- Usamos o LookVector do HRP para calcular a direção do cone
		-- Projetamos dois pontos mundiais e calculamos a direção 2D resultante
		local lookVec  = hrp.CFrame.LookVector
		-- Ponto na frente do inimigo a 4 studs
		local tipWorld = head.Position + lookVec * 4

		-- Projeta a ponta do cone
		local vTip, onTip = Camera:WorldToViewportPoint(tipWorld)
		if not onTip then
			-- Se a ponta saiu da tela, tentamos de qualquer forma com o vetor 2D
			-- usando apenas a direção calculada
			onTip = true
		end

		local base2D = Vector2.new(vHead.X, vHead.Y)
		local tip2D  = Vector2.new(vTip.X,  vTip.Y)

		-- Direção 2D normalizada
		local dir2D = tip2D - base2D
		if dir2D.Magnitude < 1 then
			clearVisionCone(plr); continue
		end
		dir2D = dir2D.Unit * CONE_LEN

		-- Ponta do triângulo
		local tipPt = base2D + dir2D

		-- Bordas do cone: rotacionamos dir2D por +CONE_ANGLE e -CONE_ANGLE
		local rad   = math.rad(CONE_ANGLE)
		local cos_a = math.cos(rad)
		local sin_a = math.sin(rad)

		-- Borda esquerda (rotação positiva)
		local lx = dir2D.X * cos_a - dir2D.Y * sin_a
		local ly = dir2D.X * sin_a + dir2D.Y * cos_a
		local edgeL = base2D + Vector2.new(lx, ly)

		-- Borda direita (rotação negativa)
		local rx = dir2D.X * cos_a + dir2D.Y * sin_a
		local ry = -dir2D.X * sin_a + dir2D.Y * cos_a
		local edgeR = base2D + Vector2.new(rx, ry)

		if not VisionCones[plr] then createVisionCone(plr) end
		local vc    = VisionCones[plr]
		local color = ESP.RGB and rgbColor or Color3.fromRGB(255, 200, 0)

		-- Triângulo: base → ponta, base → bordaL, base → bordaR
		-- + linha de fechamento bordaL → bordaR (para preencher o triângulo visualmente)
		vc[1].From = base2D;  vc[1].To = tipPt;  vc[1].Color = color; vc[1].Visible = true
		vc[2].From = base2D;  vc[2].To = edgeL;  vc[2].Color = color; vc[2].Visible = true
		vc[3].From = base2D;  vc[3].To = edgeR;  vc[3].Color = color; vc[3].Visible = true
	end
end

Players.PlayerRemoving:Connect(function(plr)
	clearESP(plr); clearSkeleton(plr); clearTracer(plr); clearHealthBar(plr)
	clearRadarDot(plr); clearVisionCone(plr)
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		if ESP.Enabled and isEnemy(plr) then createESP(plr) end
	end)
end)

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(refreshAllESP)

-- ══════════════════════════════════════════════════════════
--                  CALLBACKS DO MENU
-- ══════════════════════════════════════════════════════════

-- [ ESP ]
local function onESPToggle(s)
	ESP.Enabled = s
	if not s then
		for _,plr in ipairs(Players:GetPlayers()) do
			clearESP(plr); clearSkeleton(plr); clearTracer(plr); clearHealthBar(plr)
		end
	else refreshAllESP() end
end
local function onRGBToggle(s)        ESP.RGB = s end
local function onBoxToggle(s)        ESP.Box = s; applyBoxVisibility() end
local function onSkeletonToggle(s)
	ESP.Skeleton = s
	if not s then for _,p in ipairs(Players:GetPlayers()) do clearSkeleton(p) end end
end
local function onNameESPToggle(s)    ESP.Names = s; applyNameVisibility() end
local function onDistanceToggle(s)   ESP.Distance = s; applyDistVisibility() end
local function onHealthBarToggle(s)
	ESP.HealthBar = s
	if not s then for _,p in ipairs(Players:GetPlayers()) do clearHealthBar(p) end end
end
local function onTracelinesToggle(s)
	ESP.Tracers = s
	if not s then for _,p in ipairs(Players:GetPlayers()) do clearTracer(p) end end
end

local function onRadarToggle(s)
	ESP.Radar = s
	if not s then hideRadar() end
end

local function onVisionConeToggle(s)
	ESP.VisionCone = s
	if not s then
		for _,p in ipairs(Players:GetPlayers()) do clearVisionCone(p) end
	end
end

-- [ AIMBOT ]
local function onAimbotToggle(s)
	AIMBOT.Enabled = s
	if s then
		startAimbotLoop()
	else
		-- Mantém o loop rodando mas com flag desativada
		-- (para o FOV Circle continuar funcionando se ativo)
	end
end

local function onSilentAimToggle(s)
	AIMBOT.Silent = s
	if s then startSilentAim() else stopSilentAim() end
end

local function onPredictionToggle(s)
	AIMBOT.Prediction = s
end

local function onFOVCircleToggle(s)
	AIMBOT.FOVCircle = s
	if s then
		startAimbotLoop()   -- garante que o loop está ativo para desenhar o círculo
	else
		fovCircle.Visible = false
	end
end

local function onTeamCheckToggle(s)
	AIMBOT.TeamCheck = s
end

local function onVisCheckToggle(s)
	AIMBOT.VisCheck = s
end

local function onAutoShootToggle(s)
	AIMBOT.AutoShoot = s
end

local function onFOVChange(v)
	AIMBOT.FOVRadius = v
	fovCircle.Radius = v
end

local function onSmoothnessChange(v)
	AIMBOT.Smoothness = v
end

local function onTargetPartHead()   AIMBOT.TargetPart = "Head"              end
local function onTargetPartTorso()  AIMBOT.TargetPart = "HumanoidRootPart"  end

local function onAimKeyToggle(s)
	AIMBOT.AimKey = s
end

local function onTargetSwitchToggle(s)
	AIMBOT.TargetSwitch = s
end

local function onAimShakeToggle(s)
	AIMBOT.AimShake = s
end

local function onMaxDistChange(v)
	AIMBOT.MaxDist = v
end

local function onShakeAmtChange(v)
	AIMBOT.ShakeAmt = v
end

-- [ COMBAT ]

-- ── No Recoil ─────────────────────────────────────────────
-- Intercepta o evento de câmera no Stepped e compensa
-- o kick vertical/horizontal causado pelo recuo.
local lastCamCF = nil

local function onNoRecoilToggle(s)
	COMBAT.NoRecoil = s
	if s then
		combatConns.noRecoil = RunService.RenderStepped:Connect(function()
			if not COMBAT.NoRecoil then return end
			-- Salva o CFrame antes do frame de física
			lastCamCF = Camera.CFrame
		end)
		-- Após física: restaura apenas a rotação vertical (pitch)
		-- preservando yaw (rotação horizontal) para o jogador
		combatConns.noRecoilPost = RunService.Stepped:Connect(function()
			if not COMBAT.NoRecoil or not lastCamCF then return end
			local cur = Camera.CFrame
			-- Extrai os ângulos
			local _, curY, _ = cur:ToEulerAnglesYXZ()
			local _, oldY, _ = lastCamCF:ToEulerAnglesYXZ()
			-- Se o pitch mudou mais do que um threshold → recuo detectado
			-- Mantém o yaw atual (o jogador pode girar) mas trava o pitch
			local cx, _, cz = cur.Position.X, cur.Position.Y, cur.Position.Z
			if math.abs(curY - oldY) < 0.002 then
				-- Câmera não girou horizontalmente: é recuo puro
				Camera.CFrame = CFrame.new(cur.Position) * CFrame.fromEulerAnglesYXZ(0, curY, 0)
					* CFrame.fromEulerAnglesYXZ(select(1, lastCamCF:ToEulerAnglesYXZ()), 0, 0)
			end
		end)
	else
		if combatConns.noRecoil     then combatConns.noRecoil:Disconnect();     combatConns.noRecoil     = nil end
		if combatConns.noRecoilPost then combatConns.noRecoilPost:Disconnect(); combatConns.noRecoilPost = nil end
		lastCamCF = nil
	end
end

-- ── No Spread ─────────────────────────────────────────────
-- Trava a câmera no momento exato do disparo para que o
-- primeiro tiro sempre acerte o centro da mira.
local noSpreadSaved = nil

local function onNoSpreadToggle(s)
	COMBAT.NoSpread = s
	if s then
		combatConns.noSpreadDown = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				noSpreadSaved = Camera.CFrame
			end
		end)
		combatConns.noSpreadUp = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				noSpreadSaved = nil
			end
		end)
		combatConns.noSpreadStep = RunService.RenderStepped:Connect(function()
			if COMBAT.NoSpread and noSpreadSaved then
				Camera.CFrame = noSpreadSaved
			end
		end)
	else
		for _, k in ipairs({"noSpreadDown","noSpreadUp","noSpreadStep"}) do
			if combatConns[k] then combatConns[k]:Disconnect(); combatConns[k] = nil end
		end
		noSpreadSaved = nil
	end
end

-- ── Rapid Fire ────────────────────────────────────────────
-- Aumenta a cadência simulando cliques extras por frame
-- de acordo com o multiplicador FireRateMult.
local rapidConn = nil

local function applyRapidFire()
	if rapidConn then rapidConn:Disconnect(); rapidConn = nil end
	if not COMBAT.RapidFire then return end

	-- Quantidade de cliques extras = FireRateMult - 1
	rapidConn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not COMBAT.RapidFire then return end
		-- Simula cliques adicionais no executor
		for _ = 1, math.max(COMBAT.FireRateMult - 1, 0) do
			pcall(function() mouse1click() end)
		end
	end)
end

local function onRapidFireToggle(s)
	COMBAT.RapidFire = s
	applyRapidFire()
end

-- ── Infinite Ammo ─────────────────────────────────────────
-- Monitora a tool equipada e reabastece a munição toda vez
-- que ela muda, mantendo sempre no máximo.
local infiniteAmmoConn = nil
local infiniteAmmoCharConn = nil

local function hookAmmo(tool)
	if infiniteAmmoConn then infiniteAmmoConn:Disconnect(); infiniteAmmoConn = nil end
	if not tool or not COMBAT.InfiniteAmmo then return end

	-- Tenta encontrar a config de ammo comum em frameworks Roblox
	local ammoConfigs = {
		tool:FindFirstChild("AmmoInClip"),
		tool:FindFirstChild("Ammo"),
		tool:FindFirstChild("CurrentAmmo"),
	}

	for _, cfg in ipairs(ammoConfigs) do
		if cfg and cfg:IsA("NumberValue") or (cfg and cfg:IsA("IntValue")) then
			local maxVal = cfg.Value
			infiniteAmmoConn = cfg.Changed:Connect(function(v)
				if COMBAT.InfiniteAmmo and v < maxVal then
					cfg.Value = maxVal
				end
			end)
			break
		end
	end
end

local function onInfiniteAmmoToggle(s)
	COMBAT.InfiniteAmmo = s
	if s then
		-- Hookar a tool atual
		local char = LocalPlayer.Character
		if char then hookAmmo(char:FindFirstChildOfClass("Tool")) end
		-- Hookar quando equipar nova tool
		infiniteAmmoCharConn = LocalPlayer.CharacterAdded:Connect(function(c)
			c.ChildAdded:Connect(function(child)
				if child:IsA("Tool") and COMBAT.InfiniteAmmo then hookAmmo(child) end
			end)
		end)
		if LocalPlayer.Character then
			LocalPlayer.Character.ChildAdded:Connect(function(child)
				if child:IsA("Tool") and COMBAT.InfiniteAmmo then hookAmmo(child) end
			end)
		end
	else
		if infiniteAmmoConn     then infiniteAmmoConn:Disconnect();     infiniteAmmoConn     = nil end
		if infiniteAmmoCharConn then infiniteAmmoCharConn:Disconnect(); infiniteAmmoCharConn = nil end
	end
end

-- ── Bunny Hop ─────────────────────────────────────────────
-- Detecta quando o jogador mantém Espaço pressionado e
-- força o pulo toda vez que toca o chão.
local bhopConn = nil

local function onBunnyHopToggle(s)
	COMBAT.BunnyHop = s
	if s then
		bhopConn = RunService.Heartbeat:Connect(function()
			if not COMBAT.BunnyHop then return end
			local char = LocalPlayer.Character
			if not char then return end
			local hum = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hum or not hrp then return end

			local spaceHeld = UserInputService:IsKeyDown(Enum.KeyCode.Space)
			if spaceHeld and hum:GetState() == Enum.HumanoidStateType.Landed then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		if bhopConn then bhopConn:Disconnect(); bhopConn = nil end
	end
end

-- ── Fast Reload ───────────────────────────────────────────
-- Intercepta a animação de recarga e a reduz pelo fator
-- ReloadSpeed usando AnimationTrack:AdjustSpeed().
local fastReloadConn = nil

local function applyFastReload(char)
	if fastReloadConn then fastReloadConn:Disconnect(); fastReloadConn = nil end
	if not char or not COMBAT.FastReload then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then return end

	fastReloadConn = animator.AnimationPlayed:Connect(function(track)
		-- Detecta animação de recarga pelo nome (funciona na maioria dos jogos)
		local name = track.Name:lower()
		if name:find("reload") or name:find("recarg") then
			track:AdjustSpeed(COMBAT.ReloadSpeed)
		end
	end)
end

local function onFastReloadToggle(s)
	COMBAT.FastReload = s
	if s then
		applyFastReload(LocalPlayer.Character)
		LocalPlayer.CharacterAdded:Connect(function(c)
			task.wait(0.5)
			if COMBAT.FastReload then applyFastReload(c) end
		end)
	else
		if fastReloadConn then fastReloadConn:Disconnect(); fastReloadConn = nil end
	end
end

-- ── Sliders ───────────────────────────────────────────────
local function onFireRateChange(v)
	COMBAT.FireRateMult = v
	if COMBAT.RapidFire then applyRapidFire() end
end

local function onReloadSpeedChange(v)
	COMBAT.ReloadSpeed = v
end

-- ── Anti Ragdoll ──────────────────────────────────────────
local antiRagdollConn = nil

local function onAntiRagdollToggle(s)
	COMBAT.AntiRagdoll = s
	if s then
		antiRagdollConn = RunService.Stepped:Connect(function()
			if not COMBAT.AntiRagdoll then return end
			local char = LocalPlayer.Character
			local hum  = char and char:FindFirstChildOfClass("Humanoid")
			if not hum then return end
			-- Força o estado de movimento normal, impedindo ragdoll
			if hum:GetState() == Enum.HumanoidStateType.FallingDown
				or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	else
		if antiRagdollConn then antiRagdollConn:Disconnect(); antiRagdollConn = nil end
	end
end

-- ── Fly Hack ──────────────────────────────────────────────
local flyConn = nil
local flyBV   = nil   -- BodyVelocity

local function onFlyHackToggle(s)
	COMBAT.FlyHack = s
	if s then
		local char = LocalPlayer.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		local hum  = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		hum.PlatformStand = true

		-- Cria BodyVelocity para controlar voo
		flyBV          = Instance.new("BodyVelocity", hrp)
		flyBV.Velocity = Vector3.new(0,0,0)
		flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)

		flyConn = RunService.Heartbeat:Connect(function()
			if not COMBAT.FlyHack then return end
			local cf  = Camera.CFrame
			local vel = Vector3.new(0,0,0)
			local spd = COMBAT.FlySpeed

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector * spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector * spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector * spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector * spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.E) or
			   UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,spd,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vel = vel - Vector3.new(0,spd,0) end

			if flyBV and flyBV.Parent then flyBV.Velocity = vel end
		end)
	else
		if flyConn then flyConn:Disconnect(); flyConn = nil end
		if flyBV and flyBV.Parent then flyBV:Destroy(); flyBV = nil end
		local char = LocalPlayer.Character
		local hum  = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
end

local function onFlySpeedChange(v)
	COMBAT.FlySpeed = v
end

-- ── Speed Hack ────────────────────────────────────────────
local function applySpeed()
	local char = LocalPlayer.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = COMBAT.SpeedHack and COMBAT.WalkSpeed or 16
	end
end

local function onSpeedHackToggle(s)
	COMBAT.SpeedHack = s
	applySpeed()
	if s then
		-- Reaplicar ao respawnar
		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)
			if COMBAT.SpeedHack then applySpeed() end
		end)
	end
end

local function onWalkSpeedChange(v)
	COMBAT.WalkSpeed = v
	if COMBAT.SpeedHack then applySpeed() end
end

-- ── Jump Power ────────────────────────────────────────────
local function applyJump()
	local char = LocalPlayer.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.JumpPower = COMBAT.JumpPower and COMBAT.JumpPowerVal or 50
	end
end

local function onJumpPowerToggle(s)
	COMBAT.JumpPower = s
	applyJump()
end

local function onJumpPowerChange(v)
	COMBAT.JumpPowerVal = v
	if COMBAT.JumpPower then applyJump() end
end

-- ── Infinite Jump ─────────────────────────────────────────
local infJumpConn = nil

local function onInfiniteJumpToggle(s)
	COMBAT.InfiniteJump = s
	if s then
		infJumpConn = UserInputService.JumpRequest:Connect(function()
			if not COMBAT.InfiniteJump then return end
			local char = LocalPlayer.Character
			local hum  = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
	else
		if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
	end
end

-- ══════════════════════════════════════════════════════════
--                  CALLBACKS MISC
-- ══════════════════════════════════════════════════════════

-- ── Custom FOV ────────────────────────────────────────────
local function onCustomFOVToggle(s)
	MISC.CustomFOV = s
	if s then
		originalFOV  = Camera.FieldOfView
		Camera.FieldOfView = MISC.FOVValue
	else
		Camera.FieldOfView = originalFOV
	end
end

local function onFOVValueChange(v)
	MISC.FOVValue = v
	if MISC.CustomFOV then
		Camera.FieldOfView = v
	end
end

-- ── Spin Bot ──────────────────────────────────────────────
local spinConn = nil

local function onSpinBotToggle(s)
	MISC.SpinBot = s
	if s then
		spinConn = RunService.Heartbeat:Connect(function(dt)
			if not MISC.SpinBot then return end
			local char = LocalPlayer.Character
			local hrp  = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			-- Gira no eixo Y pelo ângulo correspondente à velocidade por frame
			local angle = math.rad(360 * MISC.SpinSpeed * dt)
			hrp.CFrame  = hrp.CFrame * CFrame.Angles(0, angle, 0)
		end)
	else
		if spinConn then spinConn:Disconnect(); spinConn = nil end
	end
end

local function onSpinSpeedChange(v)
	MISC.SpinSpeed = v
end

-- ── Big Head ──────────────────────────────────────────────
local function restoreHeads()
	for plr, origSize in pairs(originalHeads) do
		local char = plr.Character
		if char then
			local head = char:FindFirstChild("Head")
			if head then head.Size = origSize end
		end
	end
	originalHeads = {}
end

local function applyBigHead()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		local char = plr.Character
		if not char then continue end
		local head = char:FindFirstChild("Head")
		if not head then continue end
		-- Salva original se ainda não salvou
		if not originalHeads[plr] then
			originalHeads[plr] = head.Size
		end
		head.Size = originalHeads[plr] * MISC.BigHeadScale
	end
end

local bigHeadConn = nil

local function onBigHeadToggle(s)
	MISC.BigHead = s
	if s then
		applyBigHead()
		-- Reatualiza quando novos jogadores entram
		bigHeadConn = Players.PlayerAdded:Connect(function(plr)
			plr.CharacterAdded:Connect(function()
				task.wait(1)
				if MISC.BigHead then applyBigHead() end
			end)
		end)
	else
		restoreHeads()
		if bigHeadConn then bigHeadConn:Disconnect(); bigHeadConn = nil end
	end
end

local function onBigHeadScaleChange(v)
	MISC.BigHeadScale = v
	if MISC.BigHead then applyBigHead() end
end

-- ── Noclip ────────────────────────────────────────────────
local noclipConn = nil

local function onNoclipToggle(s)
	MISC.Noclip = s
	if s then
		noclipConn = RunService.Stepped:Connect(function()
			if not MISC.Noclip then return end
			local char = LocalPlayer.Character
			if not char then return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
		-- Restaura colisão do personagem
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end

-- ── Wall Bang ─────────────────────────────────────────────
-- Ignora o VisCheck do aimbot e força silent aim em alvos
-- mesmo atrás de paredes. Liga/desliga automaticamente
-- o flag VisCheck do AIMBOT para permitir wallbang.
local function onWallBangToggle(s)
	MISC.WallBang = s
	if s then
		AIMBOT.VisCheck = false
		if AIMBOT.Enabled and not AIMBOT.Silent then
			AIMBOT.Silent = true
			startSilentAim()
		end
	end
end

-- ── Anti AFK ──────────────────────────────────────────────
local afkConn = nil

local function onAntiAFKToggle(s)
	MISC.AntiAFK = s
	if s then
		afkConn = RunService.Heartbeat:Connect(function()
			if not MISC.AntiAFK then return end
			-- Simula movimento a cada ~55s para evitar kick
			if math.floor(tick()) % 55 == 0 then
				local char = LocalPlayer.Character
				local hrp  = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					-- Movimento imperceptível no eixo Y
					hrp.CFrame = hrp.CFrame * CFrame.new(0, 0.001, 0)
				end
				-- Simula clique para reset do timer de AFK
				pcall(function() VirtualUser:CaptureController() end)
				pcall(function() VirtualUser:ClickButton2(Vector2.new()) end)
			end
		end)
	else
		if afkConn then afkConn:Disconnect(); afkConn = nil end
	end
end

-- ── Time of Day ───────────────────────────────────────────
local Lighting = game:GetService("Lighting")

local function onTimeOfDayToggle(s)
	MISC.TimeOfDay = s
	if s then
		Lighting.ClockTime = MISC.TimeValue
	end
	-- Ao desligar, mantém o valor atual (não restaura)
end

local function onTimeOfDayChange(v)
	MISC.TimeValue = v
	if MISC.TimeOfDay then
		Lighting.ClockTime = v
	end
end

-- ══════════════════════════════════════════════════════════
--              SISTEMA DE CONFIGURAÇÕES / INTERFACE
-- ══════════════════════════════════════════════════════════

local CONFIG = {
	Notifications = true,   -- toast ao ativar/desativar
	Opacity       = 1.0,    -- transparência da janela (0.2–1.0)
	Theme         = "roxo", -- "roxo" | "azul" | "vermelho"
	MenuKey       = Enum.KeyCode.RightShift,
}

-- Temas de cores disponíveis
local THEMES = {
	roxo     = { border=Color3.fromRGB(110,30,200),  neon=Color3.fromRGB(155,40,240),  neonBright=Color3.fromRGB(190,70,255)  },
	azul     = { border=Color3.fromRGB(30,80,220),   neon=Color3.fromRGB(40,120,255),  neonBright=Color3.fromRGB(80,160,255)  },
	vermelho = { border=Color3.fromRGB(180,20,50),   neon=Color3.fromRGB(220,40,70),   neonBright=Color3.fromRGB(255,70,100)  },
	verde    = { border=Color3.fromRGB(20,150,60),   neon=Color3.fromRGB(30,200,80),   neonBright=Color3.fromRGB(60,255,120)  },
	laranja  = { border=Color3.fromRGB(180,80,10),   neon=Color3.fromRGB(220,110,20),  neonBright=Color3.fromRGB(255,150,40)  },
	ciano    = { border=Color3.fromRGB(10,140,180),  neon=Color3.fromRGB(20,180,220),  neonBright=Color3.fromRGB(50,220,255)  },
	rosa     = { border=Color3.fromRGB(180,20,120),  neon=Color3.fromRGB(220,40,160),  neonBright=Color3.fromRGB(255,80,200)  },
	branco   = { border=Color3.fromRGB(160,160,180), neon=Color3.fromRGB(200,200,220), neonBright=Color3.fromRGB(240,240,255)  },
}

-- ══════════════════════════════════════════════════════════
--              SISTEMA DE NOTIFICAÇÕES (TOAST)
-- ══════════════════════════════════════════════════════════

local toastQueue   = {}
local toastRunning = false

local function showToast(message, isOn)
	if not CONFIG.Notifications then return end

	local toast = Instance.new("Frame")
	toast.Size             = UDim2.new(0, 220, 0, 44)
	toast.Position         = UDim2.new(1, -230, 1, -60)
	toast.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
	toast.BorderSizePixel  = 0
	toast.ZIndex           = 50
	toast.BackgroundTransparency = 1
	toast.Parent           = _screenGuiRef or PlayerGui
	Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke", toast)
	stroke.Color       = isOn and Color3.fromRGB(100,220,100) or Color3.fromRGB(220,80,80)
	stroke.Thickness   = 1.2
	stroke.Transparency = 0.2

	local dot = Instance.new("Frame", toast)
	dot.Size             = UDim2.new(0, 8, 0, 8)
	dot.Position         = UDim2.new(0, 12, 0.5, -4)
	dot.BackgroundColor3 = isOn and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,80,80)
	dot.BorderSizePixel  = 0
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local lbl = Instance.new("TextLabel", toast)
	lbl.Size                  = UDim2.new(1, -30, 1, 0)
	lbl.Position              = UDim2.new(0, 28, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text                  = message
	lbl.TextColor3            = Color3.fromRGB(220, 200, 255)
	lbl.Font                  = Enum.Font.GothamBold
	lbl.TextSize              = 12
	lbl.TextXAlignment        = Enum.TextXAlignment.Left
	lbl.TextYAlignment        = Enum.TextYAlignment.Center
	lbl.ZIndex                = 51

	-- Animação: slide in → espera → slide out
	TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
		Position = UDim2.new(1, -230, 1, -60)
	}):Play()
	task.delay(2.2, function()
		TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -10, 1, -60)
		}):Play()
		task.delay(0.3, function() pcall(function() toast:Destroy() end) end)
	end)
end


-- ══════════════════════════════════════════════════════════
--                        PALETA
-- ══════════════════════════════════════════════════════════

local C = {
	bg          = Color3.fromRGB(10,  7,  18),
	panel       = Color3.fromRGB(18, 12, 30),
	header      = Color3.fromRGB(22, 14, 38),
	card        = Color3.fromRGB(26, 17, 44),
	cardHover   = Color3.fromRGB(36, 24, 60),
	border      = Color3.fromRGB(110, 30, 200),
	neon        = Color3.fromRGB(155, 40, 240),
	neonBright  = Color3.fromRGB(190, 70, 255),
	neonSoft    = Color3.fromRGB(130, 50, 200),
	tabActive   = Color3.fromRGB(100, 20, 175),
	tabInactive = Color3.fromRGB(22, 14, 38),
	btnOff      = Color3.fromRGB(32, 22, 50),
	btnOn       = Color3.fromRGB(90, 18, 160),
	textPrim    = Color3.fromRGB(235, 210, 255),
	textSec     = Color3.fromRGB(140, 105, 180),
	textDim     = Color3.fromRGB(90,  65, 120),
	white       = Color3.fromRGB(255, 255, 255),
	closeRed    = Color3.fromRGB(190, 35,  80),
	minGray     = Color3.fromRGB(55,  38,  80),
	sliderTrack = Color3.fromRGB(38, 25, 62),
	sliderFill  = Color3.fromRGB(120, 30, 210),
	sliderKnob  = Color3.fromRGB(200, 80, 255),
}

local TW      = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
local TW_SLOW = TweenInfo.new(0.28, Enum.EasingStyle.Quad)

-- ══════════════════════════════════════════════════════════
--                      SCREEN GUI
-- ══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "PurityGUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = PlayerGui
_screenGuiRef            = ScreenGui  -- preenche a referência forward

local Glow = Instance.new("ImageLabel")
Glow.Size               = UDim2.new(0,380,0,520)
Glow.Position           = UDim2.new(0.5,-190,0.5,-260)
Glow.BackgroundTransparency = 1
Glow.Image              = "rbxassetid://5028857084"
Glow.ImageColor3        = Color3.fromRGB(120,20,200)
Glow.ImageTransparency  = 0.6
Glow.ZIndex             = 1
Glow.Parent             = ScreenGui

local Main = Instance.new("Frame")
Main.Name             = "Main"
Main.Size             = UDim2.new(0,340,0,480)
Main.Position         = UDim2.new(0.5,-170,0.5,-240)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel  = 0
Main.ZIndex           = 2
Main.ClipsDescendants = true
Main.Parent           = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color        = C.border
MainStroke.Thickness    = 1.5
MainStroke.Transparency = 0.05

-- ── HEADER ────────────────────────────────────────────────

local Header = Instance.new("Frame")
Header.Size             = UDim2.new(1,0,0,56)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel  = 0
Header.ZIndex           = 3
Header.Parent           = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,14)

local HFix = Instance.new("Frame")
HFix.Size             = UDim2.new(1,0,0,14)
HFix.Position         = UDim2.new(0,0,1,-14)
HFix.BackgroundColor3 = C.header
HFix.BorderSizePixel  = 0
HFix.ZIndex           = 3
HFix.Parent           = Header

local HLine = Instance.new("Frame")
HLine.Size              = UDim2.new(1,0,0,1)
HLine.Position          = UDim2.new(0,0,1,-1)
HLine.BackgroundColor3  = C.border
HLine.BackgroundTransparency = 0.4
HLine.BorderSizePixel   = 0
HLine.ZIndex            = 4
HLine.Parent            = Header

local LogoDot = Instance.new("Frame")
LogoDot.Size             = UDim2.new(0,12,0,12)
LogoDot.Position         = UDim2.new(0,16,0.5,-6)
LogoDot.BackgroundColor3 = C.neonBright
LogoDot.BorderSizePixel  = 0
LogoDot.ZIndex           = 5
LogoDot.Parent           = Header
Instance.new("UICorner", LogoDot).CornerRadius = UDim.new(1,0)

local DotGlow = Instance.new("Frame")
DotGlow.Size              = UDim2.new(0,6,0,6)
DotGlow.Position          = UDim2.new(0.5,-3,0.5,-3)
DotGlow.BackgroundColor3  = C.white
DotGlow.BackgroundTransparency = 0.3
DotGlow.BorderSizePixel   = 0
DotGlow.ZIndex            = 6
DotGlow.Parent            = LogoDot
Instance.new("UICorner", DotGlow).CornerRadius = UDim.new(1,0)

local Title = Instance.new("TextLabel")
Title.Size             = UDim2.new(0,120,0,22)
Title.Position         = UDim2.new(0,36,0,10)
Title.BackgroundTransparency = 1
Title.Text             = "PURITY"
Title.TextColor3       = C.white
Title.Font             = Enum.Font.GothamBold
Title.TextSize         = 20
Title.TextXAlignment   = Enum.TextXAlignment.Left
Title.ZIndex           = 5
Title.Parent           = Header

local Badge = Instance.new("TextLabel")
Badge.Size             = UDim2.new(0,42,0,16)
Badge.Position         = UDim2.new(0,36,0,32)
Badge.BackgroundColor3 = C.btnOn
Badge.Text             = "v7.0"
Badge.TextColor3       = C.neonBright
Badge.Font             = Enum.Font.GothamBold
Badge.TextSize         = 10
Badge.ZIndex           = 5
Badge.Parent           = Header
Instance.new("UICorner", Badge).CornerRadius = UDim.new(0,4)

local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0,28,0,28)
MinBtn.Position         = UDim2.new(1,-64,0.5,-14)
MinBtn.BackgroundColor3 = C.minGray
MinBtn.BorderSizePixel  = 0
MinBtn.Text             = "–"
MinBtn.TextColor3       = C.textSec
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.TextSize         = 16
MinBtn.ZIndex           = 6
MinBtn.Parent           = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,7)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0,28,0,28)
CloseBtn.Position         = UDim2.new(1,-30,0.5,-14)
CloseBtn.BackgroundColor3 = C.closeRed
CloseBtn.BorderSizePixel  = 0
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = C.white
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 12
CloseBtn.ZIndex           = 6
CloseBtn.Parent           = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,7)

-- ── TAB BAR ───────────────────────────────────────────────

local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1,-24,0,34)
TabBar.Position         = UDim2.new(0,12,0,62)
TabBar.BackgroundColor3 = C.btnOff
TabBar.BorderSizePixel  = 0
TabBar.ZIndex           = 3
TabBar.Parent           = Main
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0,9)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
TabLayout.Padding       = UDim.new(0,3)

local TabPad = Instance.new("UIPadding", TabBar)
TabPad.PaddingLeft = UDim.new(0,3); TabPad.PaddingRight  = UDim.new(0,3)
TabPad.PaddingTop  = UDim.new(0,3); TabPad.PaddingBottom = UDim.new(0,3)

-- ── BODY ──────────────────────────────────────────────────

local Body = Instance.new("ScrollingFrame")
Body.Size             = UDim2.new(1,-24,1,-108)
Body.Position         = UDim2.new(0,12,0,104)
Body.BackgroundTransparency = 1
Body.BorderSizePixel  = 0
Body.ScrollBarThickness = 3
Body.ScrollBarImageColor3 = C.neonSoft
Body.CanvasSize       = UDim2.new(0,0,0,0)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.ZIndex           = 3
Body.Parent           = Main

local BodyLayout = Instance.new("UIListLayout", Body)
BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
BodyLayout.Padding   = UDim.new(0,10)

local BodyPad = Instance.new("UIPadding", Body)
BodyPad.PaddingTop = UDim.new(0,6); BodyPad.PaddingBottom = UDim.new(0,10)

-- ══════════════════════════════════════════════════════════
--                    COMPONENTES GUI
-- ══════════════════════════════════════════════════════════

local function makeSection(parent, title, order)
	local S = Instance.new("Frame")
	S.Size             = UDim2.new(1,0,0,0)
	S.AutomaticSize    = Enum.AutomaticSize.Y
	S.BackgroundColor3 = C.panel
	S.BorderSizePixel  = 0
	S.LayoutOrder      = order
	S.Parent           = parent
	Instance.new("UICorner", S).CornerRadius = UDim.new(0,10)

	local SS = Instance.new("UIStroke", S)
	SS.Color = C.border; SS.Thickness = 1; SS.Transparency = 0.55

	local SP = Instance.new("UIPadding", S)
	SP.PaddingLeft = UDim.new(0,10); SP.PaddingRight  = UDim.new(0,10)
	SP.PaddingTop  = UDim.new(0,10); SP.PaddingBottom = UDim.new(0,10)

	local SL = Instance.new("UIListLayout", S)
	SL.SortOrder = Enum.SortOrder.LayoutOrder; SL.Padding = UDim.new(0,7)

	local SH = Instance.new("Frame")
	SH.Size = UDim2.new(1,0,0,20); SH.BackgroundTransparency = 1
	SH.LayoutOrder = 0; SH.Parent = S

	local SHLine = Instance.new("Frame")
	SHLine.Size = UDim2.new(1,0,0,1); SHLine.Position = UDim2.new(0,0,1,0)
	SHLine.BackgroundColor3 = C.border; SHLine.BackgroundTransparency = 0.65
	SHLine.BorderSizePixel  = 0; SHLine.Parent = SH

	local STick = Instance.new("Frame")
	STick.Size = UDim2.new(0,3,1,0); STick.BackgroundColor3 = C.neon
	STick.BorderSizePixel = 0; STick.Parent = SH
	Instance.new("UICorner", STick).CornerRadius = UDim.new(1,0)

	local ST = Instance.new("TextLabel")
	ST.Size = UDim2.new(1,-10,1,0); ST.Position = UDim2.new(0,10,0,0)
	ST.BackgroundTransparency = 1; ST.Text = string.upper(title)
	ST.TextColor3 = C.neon; ST.Font = Enum.Font.GothamBold; ST.TextSize = 11
	ST.TextXAlignment = Enum.TextXAlignment.Left; ST.ZIndex = 2; ST.Parent = SH
	return S
end

local function makeToggle(parent, label, desc, order, callback)
	local state = false

	local Row = Instance.new("Frame")
	Row.Size             = UDim2.new(1,0,0, desc ~= "" and 48 or 40)
	Row.BackgroundColor3 = C.card
	Row.BorderSizePixel  = 0
	Row.LayoutOrder      = order
	Row.Parent           = parent
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0,8)

	local RS = Instance.new("UIStroke", Row)
	RS.Color = Color3.fromRGB(60,40,90); RS.Thickness = 1; RS.Transparency = 0.4

	local Bar = Instance.new("Frame")
	Bar.Size             = UDim2.new(0,3,0, desc~="" and 28 or 20)
	Bar.Position         = UDim2.new(0,8,0.5, desc~="" and -14 or -10)
	Bar.BackgroundColor3 = C.textDim; Bar.BorderSizePixel = 0; Bar.Parent = Row
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

	local Lbl = Instance.new("TextLabel")
	Lbl.Size = UDim2.new(1,-70,0,18)
	Lbl.Position = UDim2.new(0,20, desc~="" and 0.2 or 0.5, desc~="" and 0 or -9)
	Lbl.BackgroundTransparency = 1; Lbl.Text = label
	Lbl.TextColor3 = C.textSec; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 13
	Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Row

	if desc ~= "" then
		local Desc = Instance.new("TextLabel")
		Desc.Size = UDim2.new(1,-70,0,14); Desc.Position = UDim2.new(0,20,0,24)
		Desc.BackgroundTransparency = 1; Desc.Text = desc
		Desc.TextColor3 = C.textDim; Desc.Font = Enum.Font.Gotham; Desc.TextSize = 10
		Desc.TextXAlignment = Enum.TextXAlignment.Left; Desc.Parent = Row
	end

	local Switch = Instance.new("Frame")
	Switch.Size = UDim2.new(0,42,0,22); Switch.Position = UDim2.new(1,-50,0.5,-11)
	Switch.BackgroundColor3 = Color3.fromRGB(42,28,65); Switch.BorderSizePixel = 0
	Switch.Parent = Row
	Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0,16,0,16); Knob.Position = UDim2.new(0,3,0.5,-8)
	Knob.BackgroundColor3 = C.textDim; Knob.BorderSizePixel = 0; Knob.Parent = Switch
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1,0,1,0); Btn.BackgroundTransparency = 1
	Btn.Text = ""; Btn.ZIndex = 5; Btn.Parent = Row

	local function refreshToggle()
		if state then
			TweenService:Create(Row,    TW, {BackgroundColor3 = C.btnOn}):Play()
			TweenService:Create(Lbl,    TW, {TextColor3 = C.textPrim}):Play()
			TweenService:Create(Bar,    TW, {BackgroundColor3 = C.neonBright}):Play()
			TweenService:Create(Switch, TW, {BackgroundColor3 = Color3.fromRGB(75,15,135)}):Play()
			TweenService:Create(Knob,   TW, {Position = UDim2.new(1,-19,0.5,-8), BackgroundColor3 = C.neonBright}):Play()
			RS.Color = C.border; RS.Transparency = 0.1
		else
			TweenService:Create(Row,    TW, {BackgroundColor3 = C.card}):Play()
			TweenService:Create(Lbl,    TW, {TextColor3 = C.textSec}):Play()
			TweenService:Create(Bar,    TW, {BackgroundColor3 = C.textDim}):Play()
			TweenService:Create(Switch, TW, {BackgroundColor3 = Color3.fromRGB(42,28,65)}):Play()
			TweenService:Create(Knob,   TW, {Position = UDim2.new(0,3,0.5,-8), BackgroundColor3 = C.textDim}):Play()
			RS.Color = Color3.fromRGB(60,40,90); RS.Transparency = 0.4
		end
	end

	Btn.MouseButton1Click:Connect(function()
		state = not state
		refreshToggle()
		callback(state)
		-- Notificação automática para qualquer toggle
		showToast((state and "✅ " or "❌ ") .. label, state)
	end)
	Btn.MouseEnter:Connect(function()
		if not state then TweenService:Create(Row, TweenInfo.new(0.1), {BackgroundColor3 = C.cardHover}):Play() end
	end)
	Btn.MouseLeave:Connect(function()
		if not state then TweenService:Create(Row, TweenInfo.new(0.1), {BackgroundColor3 = C.card}):Play() end
	end)
end

local function makeSlider(parent, label, minV, maxV, defaultV, suffix, order, callback)
	local value = defaultV

	local Wrap = Instance.new("Frame")
	Wrap.Size = UDim2.new(1,0,0,56); Wrap.BackgroundColor3 = C.card
	Wrap.BorderSizePixel = 0; Wrap.LayoutOrder = order; Wrap.Parent = parent
	Instance.new("UICorner", Wrap).CornerRadius = UDim.new(0,8)

	local WS = Instance.new("UIStroke", Wrap)
	WS.Color = Color3.fromRGB(60,40,90); WS.Thickness = 1; WS.Transparency = 0.4

	local Bar = Instance.new("Frame")
	Bar.Size = UDim2.new(0,3,0,16); Bar.Position = UDim2.new(0,8,0.5,-8)
	Bar.BackgroundColor3 = C.neonSoft; Bar.BorderSizePixel = 0; Bar.Parent = Wrap
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

	local Lbl = Instance.new("TextLabel")
	Lbl.Size = UDim2.new(1,-80,0,16); Lbl.Position = UDim2.new(0,20,0,8)
	Lbl.BackgroundTransparency = 1; Lbl.Text = label
	Lbl.TextColor3 = C.textSec; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12
	Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Wrap

	local ValLbl = Instance.new("TextLabel")
	ValLbl.Size = UDim2.new(0,60,0,16); ValLbl.Position = UDim2.new(1,-68,0,8)
	ValLbl.BackgroundTransparency = 1; ValLbl.Text = tostring(defaultV)..suffix
	ValLbl.TextColor3 = C.neon; ValLbl.Font = Enum.Font.GothamBold; ValLbl.TextSize = 12
	ValLbl.TextXAlignment = Enum.TextXAlignment.Right; ValLbl.Parent = Wrap

	local Track = Instance.new("Frame")
	Track.Size = UDim2.new(1,-28,0,6); Track.Position = UDim2.new(0,20,0,36)
	Track.BackgroundColor3 = C.sliderTrack; Track.BorderSizePixel = 0; Track.Parent = Wrap
	Instance.new("UICorner", Track).CornerRadius = UDim.new(1,0)

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((defaultV-minV)/(maxV-minV),0,1,0)
	Fill.BackgroundColor3 = C.sliderFill; Fill.BorderSizePixel = 0; Fill.Parent = Track
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

	local SKnob = Instance.new("Frame")
	SKnob.Size = UDim2.new(0,14,0,14)
	SKnob.Position = UDim2.new((defaultV-minV)/(maxV-minV),-7,0.5,-7)
	SKnob.BackgroundColor3 = C.sliderKnob; SKnob.BorderSizePixel = 0
	SKnob.ZIndex = 2; SKnob.Parent = Track
	Instance.new("UICorner", SKnob).CornerRadius = UDim.new(1,0)

	local draggingSlider = false
	local function updateSlider(inputX)
		local rel = math.clamp((inputX - Track.AbsolutePosition.X)/Track.AbsoluteSize.X, 0, 1)
		value = math.floor(minV + rel*(maxV-minV))
		Fill.Size = UDim2.new(rel,0,1,0); SKnob.Position = UDim2.new(rel,-7,0.5,-7)
		ValLbl.Text = tostring(value)..suffix; callback(value)
	end

	local CZ = Instance.new("TextButton")
	CZ.Size = UDim2.new(1,0,1,0); CZ.BackgroundTransparency = 1
	CZ.Text = ""; CZ.ZIndex = 3; CZ.Parent = Track

	CZ.MouseButton1Down:Connect(function(x) draggingSlider = true; updateSlider(x) end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
	end)
	Wrap.MouseEnter:Connect(function()
		TweenService:Create(Wrap, TweenInfo.new(0.1), {BackgroundColor3 = C.cardHover}):Play()
	end)
	Wrap.MouseLeave:Connect(function()
		TweenService:Create(Wrap, TweenInfo.new(0.1), {BackgroundColor3 = C.card}):Play()
	end)
end

-- ── Botão de seleção simples (para Target Part) ───────────
local function makeOptionRow(parent, labelA, labelB, order, callbackA, callbackB)
	local Wrap = Instance.new("Frame")
	Wrap.Size = UDim2.new(1,0,0,36); Wrap.BackgroundColor3 = C.card
	Wrap.BorderSizePixel = 0; Wrap.LayoutOrder = order; Wrap.Parent = parent
	Instance.new("UICorner", Wrap).CornerRadius = UDim.new(0,8)

	local WS = Instance.new("UIStroke", Wrap)
	WS.Color = Color3.fromRGB(60,40,90); WS.Thickness = 1; WS.Transparency = 0.4

	-- Botão A
	local BtnA = Instance.new("TextButton")
	BtnA.Size = UDim2.new(0.5,-6,0,26); BtnA.Position = UDim2.new(0,5,0.5,-13)
	BtnA.BackgroundColor3 = C.btnOn; BtnA.BorderSizePixel = 0
	BtnA.Text = labelA; BtnA.TextColor3 = C.textPrim
	BtnA.Font = Enum.Font.GothamBold; BtnA.TextSize = 11; BtnA.Parent = Wrap
	Instance.new("UICorner", BtnA).CornerRadius = UDim.new(0,6)

	-- Botão B
	local BtnB = Instance.new("TextButton")
	BtnB.Size = UDim2.new(0.5,-6,0,26); BtnB.Position = UDim2.new(0.5,1,0.5,-13)
	BtnB.BackgroundColor3 = C.btnOff; BtnB.BorderSizePixel = 0
	BtnB.Text = labelB; BtnB.TextColor3 = C.textSec
	BtnB.Font = Enum.Font.GothamBold; BtnB.TextSize = 11; BtnB.Parent = Wrap
	Instance.new("UICorner", BtnB).CornerRadius = UDim.new(0,6)

	BtnA.MouseButton1Click:Connect(function()
		BtnA.BackgroundColor3 = C.btnOn;  BtnA.TextColor3 = C.textPrim
		BtnB.BackgroundColor3 = C.btnOff; BtnB.TextColor3 = C.textSec
		callbackA()
	end)
	BtnB.MouseButton1Click:Connect(function()
		BtnB.BackgroundColor3 = C.btnOn;  BtnB.TextColor3 = C.textPrim
		BtnA.BackgroundColor3 = C.btnOff; BtnA.TextColor3 = C.textSec
		callbackB()
	end)
end

-- ══════════════════════════════════════════════════════════
--                    SISTEMA DE ABAS
-- ══════════════════════════════════════════════════════════

local tabs     = {}
local tabPages = {}
local activeTab = nil

local function createTab(name, icon, order)
	local TBtn = Instance.new("TextButton")
	TBtn.Size = UDim2.new(0,58,1,0); TBtn.BackgroundColor3 = C.tabInactive
	TBtn.BorderSizePixel = 0; TBtn.Text = icon.." "..name
	TBtn.TextColor3 = C.textDim; TBtn.Font = Enum.Font.GothamBold
	TBtn.TextSize = 11; TBtn.LayoutOrder = order; TBtn.ZIndex = 4; TBtn.Parent = TabBar
	Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0,7)

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0.6,0,0,2); Indicator.Position = UDim2.new(0.2,0,1,-3)
	Indicator.BackgroundColor3 = C.neonBright; Indicator.BackgroundTransparency = 1
	Indicator.BorderSizePixel  = 0; Indicator.Parent = TBtn
	Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1,0)

	local Page = Instance.new("Frame")
	Page.Size = UDim2.new(1,0,0,0); Page.AutomaticSize = Enum.AutomaticSize.Y
	Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0
	Page.LayoutOrder = order; Page.Visible = false; Page.Parent = Body

	local PL = Instance.new("UIListLayout", Page)
	PL.SortOrder = Enum.SortOrder.LayoutOrder; PL.Padding = UDim.new(0,8)

	tabs[name]     = {btn = TBtn, indicator = Indicator}
	tabPages[name] = Page

	TBtn.MouseButton1Click:Connect(function()
		for n, page in pairs(tabPages) do
			page.Visible = false
			TweenService:Create(tabs[n].btn, TW, {BackgroundColor3 = C.tabInactive, TextColor3 = C.textDim}):Play()
			TweenService:Create(tabs[n].indicator, TW, {BackgroundTransparency = 1}):Play()
		end
		Page.Visible = true
		TweenService:Create(TBtn, TW, {BackgroundColor3 = C.tabActive, TextColor3 = C.textPrim}):Play()
		TweenService:Create(Indicator, TW, {BackgroundTransparency = 0}):Play()
		activeTab = name
	end)

	return Page
end

local pageESP      = createTab("ESP",    "◈", 1)
local pageAimbot   = createTab("Aimbot", "◎", 2)
local pageCombat   = createTab("Combat", "⚡", 3)
local pageMisc     = createTab("Misc",   "✦", 4)
local pageSettings = createTab("Config", "⚙", 5)

-- ══════════════════════════════════════════════════════════
--                   POPULANDO AS ABAS
-- ══════════════════════════════════════════════════════════

-- ── ABA ESP ───────────────────────────────────────────────
do
	local sec = makeSection(pageESP, "ESP / Highlights", 1)
	makeToggle(sec, "ESP Ativo",       "Liga/desliga todo o sistema ESP",        1, onESPToggle)
	makeToggle(sec, "RGB",             "Cores animadas em arco-íris",            2, onRGBToggle)
	makeToggle(sec, "Caixa (Box ESP)", "Silhueta/highlight ao redor do player",  3, onBoxToggle)
	makeToggle(sec, "Esqueleto",       "Linhas do esqueleto sobre o personagem", 4, onSkeletonToggle)
	makeToggle(sec, "Nome (Name ESP)", "Exibe o nome acima do player",           5, onNameESPToggle)
	makeToggle(sec, "Distância",       "Mostra quantos studs o inimigo está",    6, onDistanceToggle)
	makeToggle(sec, "Health Bar",      "Barra de vida na lateral do personagem", 7, onHealthBarToggle)
	makeToggle(sec, "Tracelines",      "Linha do centro da tela até o player",   8, onTracelinesToggle)

	local sec2 = makeSection(pageESP, "Extras", 2)
	makeToggle(sec2, "Radar 2D",       "Minimapa com pontos dos inimigos",        1, onRadarToggle)
	makeToggle(sec2, "Cone de Visão",  "Triângulo indicando direção do inimigo",  2, onVisionConeToggle)
end

-- ── ABA AIMBOT ────────────────────────────────────────────
do
	-- Seção principal
	local sec1 = makeSection(pageAimbot, "Aimbot", 1)
	makeToggle(sec1, "Aimbot Ativo",  "Mira automaticamente no alvo no FOV",    1, onAimbotToggle)
	makeToggle(sec1, "Silent Aim",    "Desvia o projétil sem mover a câmera",   2, onSilentAimToggle)
	makeToggle(sec1, "Prediction",    "Compensa velocidade do alvo em movimento",3, onPredictionToggle)
	makeToggle(sec1, "FOV Circle",    "Exibe o círculo de campo de visão",      4, onFOVCircleToggle)
	makeToggle(sec1, "Auto Shoot",    "Atira automaticamente ao travar no alvo",5, onAutoShootToggle)

	-- Seção de filtros
	local sec2 = makeSection(pageAimbot, "Filtros", 2)
	makeToggle(sec2, "Team Check",    "Ignora players do mesmo time",           1, onTeamCheckToggle)
	makeToggle(sec2, "Vis. Check",    "Só mira em players visíveis (sem parede)",2, onVisCheckToggle)

	-- Parte do corpo alvo
	local sec3 = makeSection(pageAimbot, "Parte Alvo", 3)
	makeOptionRow(sec3, "◎ Cabeça", "◈ Torso", 1, onTargetPartHead, onTargetPartTorso)

	-- Extras do aimbot
	local sec3b = makeSection(pageAimbot, "Extras", 3)
	makeToggle(sec3b, "Aim Key (LAlt)", "Só mira com Left Alt pressionado",       1, onAimKeyToggle)
	makeToggle(sec3b, "Target Switch",  "Troca de alvo ao eliminar",              2, onTargetSwitchToggle)
	makeToggle(sec3b, "Aim Shake",      "Oscilação humana no movimento da mira",  3, onAimShakeToggle)

	-- Configurações numéricas
	local sec4 = makeSection(pageAimbot, "Configurações", 4)
	makeSlider(sec4, "FOV Size",    20,  500, 150, " px", 1, onFOVChange)
	makeSlider(sec4, "Smoothness",   1,   20,   8, "x",   2, onSmoothnessChange)
	makeSlider(sec4, "Max Distance", 50, 1000, 500, " st", 3, onMaxDistChange)
	makeSlider(sec4, "Shake Amount", 1,   10,   2, "x",   4, onShakeAmtChange)
end

-- ── ABA COMBAT ────────────────────────────────────────────
do
	-- Modificações de arma
	local sec1 = makeSection(pageCombat, "Weapon Mods", 1)
	makeToggle(sec1, "No Recoil",     "Trava o pitch da câmera ao atirar",         1, onNoRecoilToggle)
	makeToggle(sec1, "No Spread",     "Mantém câmera travada durante o disparo",   2, onNoSpreadToggle)
	makeToggle(sec1, "Rapid Fire",    "Simula cliques extras por disparo",         3, onRapidFireToggle)
	makeToggle(sec1, "Infinite Ammo", "Reabastece munição automaticamente",        4, onInfiniteAmmoToggle)

	-- Mobilidade
	local sec2 = makeSection(pageCombat, "Mobilidade", 2)
	makeToggle(sec2, "Bunny Hop",      "Pula automaticamente ao manter Espaço",    1, onBunnyHopToggle)
	makeToggle(sec2, "Infinite Jump",  "Permite pular infinitamente no ar",        2, onInfiniteJumpToggle)
	makeToggle(sec2, "Fly Hack",       "Voa livremente com WASD + E/Q",           3, onFlyHackToggle)
	makeToggle(sec2, "Speed Hack",     "Aumenta a velocidade do personagem",       4, onSpeedHackToggle)
	makeToggle(sec2, "Jump Power",     "Aumenta o poder de pulo",                  5, onJumpPowerToggle)
	makeToggle(sec2, "Anti Ragdoll",   "Impede o estado de ragdoll",               6, onAntiRagdollToggle)

	-- Recarga
	local sec3 = makeSection(pageCombat, "Recarga", 3)
	makeToggle(sec3, "Fast Reload",    "Acelera a animação de recarga",            1, onFastReloadToggle)

	-- Configurações numéricas
	local sec4 = makeSection(pageCombat, "Configurações", 4)
	makeSlider(sec4, "Fire Rate Mult",  1,  10,  1, "x",   1, onFireRateChange)
	makeSlider(sec4, "Reload Speed",    1,   5,  1, "x",   2, onReloadSpeedChange)
	makeSlider(sec4, "Walk Speed",     16, 200, 50, " ws", 3, onWalkSpeedChange)
	makeSlider(sec4, "Jump Power",     50, 500,100, " jp", 4, onJumpPowerChange)
	makeSlider(sec4, "Fly Speed",       5, 200, 50, " ws", 5, onFlySpeedChange)
end

-- ── ABA MISC ─────────────────────────────────────────────
do
	-- Câmera
	local sec1 = makeSection(pageMisc, "Câmera", 1)
	makeToggle(sec1, "Custom FOV",    "Altera o campo de visão da câmera",       1, onCustomFOVToggle)
	makeSlider(sec1, "FOV",           50, 120, 70, "°",  2, onFOVValueChange)

	-- Personagem
	local sec2 = makeSection(pageMisc, "Personagem", 2)
	makeToggle(sec2, "Spin Bot",      "Gira o personagem continuamente",         1, onSpinBotToggle)
	makeSlider(sec2, "Spin Speed",    1, 20, 10, " rot/s", 2, onSpinSpeedChange)
	makeToggle(sec2, "Noclip",        "Atravessa paredes desativando colisão",   3, onNoclipToggle)

	-- Inimigos
	local sec3 = makeSection(pageMisc, "Inimigos", 3)
	makeToggle(sec3, "Big Head",      "Aumenta a cabeça dos inimigos",           1, onBigHeadToggle)
	makeSlider(sec3, "Head Scale",    1, 50, 2, "x",        2, onBigHeadScaleChange)

	-- Arma
	local sec4 = makeSection(pageMisc, "Arma", 4)
	makeToggle(sec4, "Wall Bang",    "Bala atravessa paredes (Silent Aim sem VisCheck)", 1, onWallBangToggle)

	-- Utilidade
	local sec5 = makeSection(pageMisc, "Utilidade", 5)
	makeToggle(sec5, "Anti AFK",     "Evita kick por inatividade automaticamente", 1, onAntiAFKToggle)
	makeToggle(sec5, "Time of Day",  "Controla a hora do dia do mapa",             2, onTimeOfDayToggle)
	makeSlider(sec5, "Hora do Dia",  0, 24, 12, "h",  3, onTimeOfDayChange)
end

-- ── ABA SETTINGS ─────────────────────────────────────────
do
	local sec1 = makeSection(pageSettings, "Interface", 1)
	makeToggle(sec1, "Notificações",   "Toast ao ativar/desativar funções",        1, function(s) CONFIG.Notifications = s end)

	local sec2 = makeSection(pageSettings, "Visual", 2)
	makeSlider(sec2, "Opacidade",      20, 100, 100, "%", 1, function(v)
		CONFIG.Opacity = v / 100
		Main.BackgroundTransparency = 1 - (v/100)
	end)

	-- Seletor de tema
	local sec3 = makeSection(pageSettings, "Tema de Cores", 3)
	local function applyTheme(name)
		CONFIG.Theme = name
		local t = THEMES[name]
		if not t then return end
		C.border     = t.border
		C.neon       = t.neon
		C.neonBright = t.neonBright
		-- Aplica nas UIStrokes e elementos principais
		MainStroke.Color = t.border
		HLine.BackgroundColor3 = t.neon
		fovCircle.Color = t.neonBright
	end
	makeOptionRow(sec3, "🟣 Roxo",     "🔵 Azul",       1,
		function() applyTheme("roxo")     end,
		function() applyTheme("azul")     end)
	makeOptionRow(sec3, "🔴 Vermelho", "🟢 Verde",     2,
		function() applyTheme("vermelho") end,
		function() applyTheme("verde")    end)
	makeOptionRow(sec3, "🟠 Laranja",  "🩵 Ciano",     3,
		function() applyTheme("laranja")  end,
		function() applyTheme("ciano")    end)
	makeOptionRow(sec3, "🩷 Rosa",     "⬜ Branco",    4,
		function() applyTheme("rosa")     end,
		function() applyTheme("branco")   end)

	-- Info
	local sec4 = makeSection(pageSettings, "Info", 4)
	local infoRow = Instance.new("Frame")
	infoRow.Size = UDim2.new(1,0,0,36); infoRow.BackgroundColor3 = C.card
	infoRow.BorderSizePixel = 0; infoRow.LayoutOrder = 1; infoRow.Parent = sec4
	Instance.new("UICorner", infoRow).CornerRadius = UDim.new(0,8)
	local infoLbl = Instance.new("TextLabel", infoRow)
	infoLbl.Size = UDim2.new(1,-20,1,0); infoLbl.Position = UDim2.new(0,10,0,0)
	infoLbl.BackgroundTransparency = 1
	infoLbl.Text = "Purity v7.0  |  UserId: "..tostring(LocalPlayer.UserId)
	infoLbl.TextColor3 = C.textSec; infoLbl.Font = Enum.Font.Gotham
	infoLbl.TextSize = 11; infoLbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- ── ATIVA ABA ESP POR PADRÃO ──────────────────────────────
pageESP.Visible = true
tabs["ESP"].btn.BackgroundColor3             = C.tabActive
tabs["ESP"].btn.TextColor3                   = C.textPrim
tabs["ESP"].indicator.BackgroundTransparency = 0
activeTab = "ESP"

-- ══════════════════════════════════════════════════════════
--                         DRAG
-- ══════════════════════════════════════════════════════════

local dragging  = false
local dragStart = nil
local startPos  = nil

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = Main.Position
	end
end)
Header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
		                          startPos.Y.Scale, startPos.Y.Offset+d.Y)
		Glow.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset-20,
		                          Main.Position.Y.Scale, Main.Position.Y.Offset-20)
	end
end)

-- ══════════════════════════════════════════════════════════
--               FECHAR / MINIMIZAR / KEYBIND
-- ══════════════════════════════════════════════════════════

local minimized  = false
local guiVisible = true
local originalH  = 480

CloseBtn.MouseButton1Click:Connect(function()
	stopAimbotLoop(); stopSilentAim()
	fovCircle.Visible = false
	-- Limpa conexões de combat
	for _, conn in pairs(combatConns) do pcall(function() conn:Disconnect() end) end
	if bhopConn         then bhopConn:Disconnect()         end
	if fastReloadConn   then fastReloadConn:Disconnect()   end
	if infiniteAmmoConn then infiniteAmmoConn:Disconnect() end
	-- Limpa conexões misc
	for _, conn in pairs(miscConns) do pcall(function() conn:Disconnect() end) end
	if spinConn    then spinConn:Disconnect()    end
	if noclipConn  then noclipConn:Disconnect()  end
	if bigHeadConn then bigHeadConn:Disconnect() end
	-- Restaura estados misc
	restoreHeads()
	if MISC.CustomFOV then Camera.FieldOfView = originalFOV end
	if MISC.Noclip then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		clearESP(plr); clearSkeleton(plr); clearTracer(plr); clearHealthBar(plr)
	end
	TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Size = UDim2.new(0,300,0,0), BackgroundTransparency = 1}):Play()
	TweenService:Create(Glow, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
	task.delay(0.25, function() ScreenGui:Destroy() end)
end)

MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(Main, TW_SLOW, {Size = UDim2.new(0,340,0,56)}):Play()
		MinBtn.Text = "□"
	else
		TweenService:Create(Main, TW_SLOW, {Size = UDim2.new(0,340,0,originalH)}):Play()
		MinBtn.Text = "–"
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		guiVisible   = not guiVisible
		Main.Visible = guiVisible
		Glow.Visible = guiVisible
	end
end)


-- ══════════════════════════════════════════════════════════
--                  RGB ANIMADO NO HEADER-- ══════════════════════════════════════════════════════════

local headerHue = 0
RunService.Heartbeat:Connect(function(dt)
	headerHue = (headerHue + dt*0.12) % 1
	local rgb = Color3.fromHSV(headerHue, 0.8, 1)
	LogoDot.BackgroundColor3 = rgb
	HLine.BackgroundColor3   = rgb
	DotGlow.BackgroundColor3 = rgb
	-- FOV Circle também fica RGB se ESP.RGB ativo
	if ESP.RGB and AIMBOT.FOVCircle then
		fovCircle.Color = rgb
	else
		fovCircle.Color = Color3.fromRGB(168,50,255)
	end
end)

-- ══════════════════════════════════════════════════════════
--                  ANIMAÇÃO DE ENTRADA
-- ══════════════════════════════════════════════════════════

-- Inicia o loop do aimbot (vai ficar idle até ser ativado)
startAimbotLoop()

Main.Size = UDim2.new(0,340,0,0)
Main.BackgroundTransparency = 0.8
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{Size = UDim2.new(0,340,0,originalH), BackgroundTransparency = 0}):Play()
TweenService:Create(Glow, TweenInfo.new(0.4), {ImageTransparency = 0.6}):Play()

-- ╔══════════════════════════════════════════════════════════╗
-- ║   PURITY v7.0  —  VERSÃO COMPLETA                       ║
-- ║                                                          ║
-- ║  CORREÇÕES E MELHORIAS v7.0                              ║
-- ║  ◈ Radar 2D         → Matemática corrigida              ║
-- ║  ◈ Cone de Visão    → Projeção 3D→2D corrigida          ║
-- ║  ⚙ Sem botão flutuante (minimiza normalmente)           ║
-- ║  ⚙ RightShift restaurado para abrir/fechar             ║
-- ║  ⚙ 8 temas de cor: Roxo, Azul, Vermelho, Verde,        ║
-- ║     Laranja, Ciano, Rosa, Branco                        ║
-- ║  ⚙ Toast automático em TODOS os toggles                ║
-- ║                                                          ║
-- ║  RightShift → mostra/esconde o menu                     ║
-- ╚══════════════════════════════════════════════════════════╝
