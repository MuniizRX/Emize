-- ╔══════════════════════════════════════════════════════════╗
-- ║        PURITY GUI  •  v2.2  •  ESP COMPLETO             ║
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

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════
--                    ESTADO DO ESP
-- ══════════════════════════════════════════════════════════

local ESP = {
	Enabled    = false,
	RGB        = false,
	Box        = false,
	Skeleton   = false,
	Names      = false,
	Distance   = false,   -- NOVO: distância em studs
	HealthBar  = false,   -- NOVO: barra de vida
	Tracers    = false,
}

-- ══════════════════════════════════════════════════════════
--              HELPERS
-- ══════════════════════════════════════════════════════════

local function isEnemy(plr)
	if not LocalPlayer.Team or not plr.Team then return true end
	return plr.Team ~= LocalPlayer.Team
end

-- Converte HP (0–100) para uma cor:
--   100% = verde, 50% = amarelo, 0% = vermelho
local function healthToColor(pct)
	pct = math.clamp(pct, 0, 1)
	if pct > 0.5 then
		-- verde → amarelo
		return Color3.fromRGB(
			math.floor(255 * (1 - pct) * 2),
			255,
			0
		)
	else
		-- amarelo → vermelho
		return Color3.fromRGB(
			255,
			math.floor(255 * pct * 2),
			0
		)
	end
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  —  HIGHLIGHT + NOME + DISTÂNCIA
-- ══════════════════════════════════════════════════════════

local drawings = {}
--[[
drawings[plr] = {
	Highlight  = Highlight,
	Billboard  = BillboardGui,   ← contém NameLabel e DistLabel
	NameLabel  = TextLabel,
	DistLabel  = TextLabel,
}
]]

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

	-- ── Highlight ──────────────────────────────────────
	local hl = Instance.new("Highlight")
	hl.FillTransparency    = 0.5
	hl.OutlineTransparency = 0
	hl.OutlineColor        = Color3.fromRGB(168, 50, 255)
	hl.FillColor           = Color3.fromRGB(100,  0, 180)
	hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Enabled             = ESP.Box
	hl.Parent              = char

	-- ── Billboard (nome + distância juntos) ─────────────
	-- Altura maior para acomodar 2 labels empilhados
	local bill = Instance.new("BillboardGui")
	bill.Size        = UDim2.new(0, 120, 0, 44)
	bill.AlwaysOnTop = true
	bill.StudsOffset = Vector3.new(0, 3.2, 0)
	bill.Enabled     = ESP.Names or ESP.Distance
	bill.Parent      = char:WaitForChild("Head")

	-- Layout vertical dentro do billboard
	local layout = Instance.new("UIListLayout", bill)
	layout.SortOrder        = Enum.SortOrder.LayoutOrder
	layout.FillDirection    = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding          = UDim.new(0, 2)

	-- Label do nome
	local nameLbl = Instance.new("TextLabel", bill)
	nameLbl.Size                   = UDim2.new(1, 0, 0, 18)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text                   = plr.Name
	nameLbl.TextColor3             = Color3.fromRGB(200, 80, 255)
	nameLbl.Font                   = Enum.Font.GothamBold
	nameLbl.TextSize               = 13
	nameLbl.TextStrokeTransparency = 0
	nameLbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
	nameLbl.Visible                = ESP.Names
	nameLbl.LayoutOrder            = 1

	-- Label da distância
	local distLbl = Instance.new("TextLabel", bill)
	distLbl.Size                   = UDim2.new(1, 0, 0, 16)
	distLbl.BackgroundTransparency = 1
	distLbl.Text                   = "0 studs"
	distLbl.TextColor3             = Color3.fromRGB(200, 200, 255)
	distLbl.Font                   = Enum.Font.Gotham
	distLbl.TextSize               = 11
	distLbl.TextStrokeTransparency = 0
	distLbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
	distLbl.Visible                = ESP.Distance
	distLbl.LayoutOrder            = 2

	drawings[plr].Highlight = hl
	drawings[plr].Billboard = bill
	drawings[plr].NameLabel = nameLbl
	drawings[plr].DistLabel = distLbl
end

local function applyBoxVisibility()
	for _, d in pairs(drawings) do
		if d.Highlight then d.Highlight.Enabled = ESP.Box end
	end
end

local function applyNameVisibility()
	for _, d in pairs(drawings) do
		if d.NameLabel then
			d.NameLabel.Visible = ESP.Names
			-- Mantém billboard ativo se qualquer label estiver visível
			if d.Billboard then
				d.Billboard.Enabled = ESP.Names or ESP.Distance
			end
		end
	end
end

local function applyDistVisibility()
	for _, d in pairs(drawings) do
		if d.DistLabel then
			d.DistLabel.Visible = ESP.Distance
			if d.Billboard then
				d.Billboard.Enabled = ESP.Names or ESP.Distance
			end
		end
	end
end

local function refreshAllESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and isEnemy(plr) then
			createESP(plr)
		end
	end
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  —  HEALTH BAR (Drawing)
--
--  Cada player tem 3 objetos Drawing:
--    HealthBG  = fundo escuro da barra
--    HealthFG  = preenchimento colorido (verde→vermelho)
--    HealthTxt = texto "XX HP" acima da barra
-- ══════════════════════════════════════════════════════════

local HealthBars = {}
--[[
HealthBars[plr] = {
	bg  = Drawing (Line largo = barra de fundo),
	fg  = Drawing (Line largo = barra colorida),
	txt = Drawing (Text),
}
]]

local HBAR_W   = 6    -- largura da barra em pixels
local HBAR_H   = 40   -- altura máxima da barra em pixels
local HBAR_OFF = 8    -- deslocamento horizontal da borda esquerda do personagem

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

	-- Fundo (barra preta/semi-transparente)
	local bg = Drawing.new("Line")
	bg.Thickness = HBAR_W
	bg.Color     = Color3.fromRGB(20, 20, 20)
	bg.Transparency = 0.5
	bg.Visible   = false

	-- Preenchimento
	local fg = Drawing.new("Line")
	fg.Thickness = HBAR_W - 2
	fg.Color     = Color3.fromRGB(0, 255, 80)
	fg.Transparency = 1
	fg.Visible   = false

	-- Texto de HP
	local txt = Drawing.new("Text")
	txt.Size      = 11
	txt.Font      = Drawing.Fonts.UI   -- fonte limpa disponível no executor
	txt.Color     = Color3.fromRGB(255, 255, 255)
	txt.Outline   = true
	txt.Visible   = false

	HealthBars[plr] = { bg = bg, fg = fg, txt = txt }
end

--[[
  Atualiza a posição e tamanho da health bar para `plr`.
  Chamado dentro do RenderStepped.
  Usa a BoundingBox do personagem projetada na tela para
  alinhar a barra na lateral esquerda do modelo.
]]
local function updateHealthBar(plr, rgbColor)
	local char = plr.Character
	if not char then clearHealthBar(plr) return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	local hp    = hum.Health
	local maxHP = hum.MaxHealth
	if maxHP <= 0 then maxHP = 100 end
	local pct = math.clamp(hp / maxHP, 0, 1)

	-- Projeção dos pés e cabeça na tela
	local head = char:FindFirstChild("Head") or hrp
	local foot = char:FindFirstChild("HumanoidRootPart")

	local vHead, onH = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
	local vFoot, onF = Camera:WorldToViewportPoint(foot.Position - Vector3.new(0, 3,   0))

	if not (onH and onF) then
		if HealthBars[plr] then
			HealthBars[plr].bg.Visible  = false
			HealthBars[plr].fg.Visible  = false
			HealthBars[plr].txt.Visible = false
		end
		return
	end

	-- Altura real da barra na tela (em pixels)
	local screenH = math.max(math.abs(vFoot.Y - vHead.Y), 10)
	-- Metade da largura do modelo para posicionar na esquerda
	local halfW   = screenH * 0.28

	local xBar    = vHead.X - halfW - HBAR_OFF
	local yTop    = vHead.Y
	local yBot    = vFoot.Y

	-- Ponto de fim do preenchimento (proporcional ao HP)
	local yFill   = yBot - (yBot - yTop) * pct

	if not HealthBars[plr] then createHealthBar(plr) end
	local bar = HealthBars[plr]

	-- Fundo da barra (do topo ao fundo)
	bar.bg.From    = Vector2.new(xBar, yTop)
	bar.bg.To      = Vector2.new(xBar, yBot)
	bar.bg.Visible = true

	-- Preenchimento (do fundo até o nível de HP)
	bar.fg.From    = Vector2.new(xBar, yBot)
	bar.fg.To      = Vector2.new(xBar, yFill)
	bar.fg.Color   = ESP.RGB and rgbColor or healthToColor(pct)
	bar.fg.Visible = true

	-- Texto de HP acima da barra
	local hpInt = math.floor(hp)
	bar.txt.Text     = hpInt .. " HP"
	bar.txt.Position = Vector2.new(xBar - 2, yTop - 14)
	bar.txt.Color    = ESP.RGB and rgbColor or Color3.fromRGB(230, 230, 230)
	bar.txt.Visible  = true
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  —  SKELETON (Drawing)
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
		{"Head","UpperTorso"},
		{"UpperTorso","LowerTorso"},
		{"UpperTorso","LeftUpperArm"},  {"LeftUpperArm","LeftLowerArm"},   {"LeftLowerArm","LeftHand"},
		{"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
		{"LowerTorso","LeftUpperLeg"},  {"LeftUpperLeg","LeftLowerLeg"},   {"LeftLowerLeg","LeftFoot"},
		{"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
	}
end

local function clearSkeleton(plr)
	if Skeletons[plr] then
		for _, l in pairs(Skeletons[plr]) do pcall(function() l:Remove() end) end
		Skeletons[plr] = nil
	end
end

local function createSkeleton(plr, count)
	if Skeletons[plr] then return end
	Skeletons[plr] = {}
	for i = 1, count do
		local l = Drawing.new("Line")
		l.Thickness = 1.5
		l.Color     = Color3.fromRGB(168, 50, 255)
		l.Visible   = false
		Skeletons[plr][i] = l
	end
end

-- ══════════════════════════════════════════════════════════
--            LÓGICA ESP  —  TRACERS (Drawing)
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
	l.Color     = Color3.fromRGB(168, 50, 255)
	l.Visible   = false
	Tracers[plr] = l
end

-- ══════════════════════════════════════════════════════════
--               LOOP PRINCIPAL DO ESP
-- ══════════════════════════════════════════════════════════

local rgbHue = 0

RunService.RenderStepped:Connect(function(dt)
	rgbHue = (rgbHue + dt * 0.15) % 1
	local rgbColor = Color3.fromHSV(rgbHue, 1, 1)

	-- Posição do LocalPlayer para calcular distância
	local myHRP = LocalPlayer.Character and
	              LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end

		local char = plr.Character
		local isEn = isEnemy(plr)

		-- ESP desativado ou player inválido → limpa tudo
		if not ESP.Enabled or not char or not isEn then
			clearESP(plr)
			clearSkeleton(plr)
			clearTracer(plr)
			clearHealthBar(plr)
			continue
		end

		-- Cria ESP base se não existir
		if not drawings[plr] then createESP(plr) end

		local d = drawings[plr]

		-- ── Cores (RGB ou padrão) ─────────────────────────
		local espColor = ESP.RGB and rgbColor or Color3.fromRGB(168, 50, 255)

		if d.Highlight then
			d.Highlight.OutlineColor = espColor
			d.Highlight.FillColor    = ESP.RGB and rgbColor or Color3.fromRGB(100, 0, 180)
		end
		if d.NameLabel then
			d.NameLabel.TextColor3 = ESP.RGB and rgbColor or Color3.fromRGB(200, 80, 255)
		end

		-- ── DISTÂNCIA ─────────────────────────────────────
		if ESP.Distance and d.DistLabel then
			if myHRP and char:FindFirstChild("HumanoidRootPart") then
				local dist = math.floor(
					(myHRP.Position - char.HumanoidRootPart.Position).Magnitude
				)
				d.DistLabel.Text    = dist .. " studs"
				d.DistLabel.TextColor3 = ESP.RGB and rgbColor or Color3.fromRGB(200, 200, 255)
				d.DistLabel.Visible = true
			end
		elseif d.DistLabel then
			d.DistLabel.Visible = false
		end

		-- Garante que o billboard fique visível/invisível corretamente
		if d.Billboard then
			d.Billboard.Enabled = ESP.Names or ESP.Distance
		end

		-- ── HEALTH BAR ────────────────────────────────────
		if ESP.HealthBar then
			updateHealthBar(plr, rgbColor)
		else
			clearHealthBar(plr)
		end

		-- ── SKELETON ──────────────────────────────────────
		local bones = getBones(char)
		if ESP.Skeleton and bones then
			if not Skeletons[plr] then createSkeleton(plr, #bones) end
			for i, b in ipairs(bones) do
				local p1   = char:FindFirstChild(b[1])
				local p2   = char:FindFirstChild(b[2])
				local line = Skeletons[plr] and Skeletons[plr][i]
				if p1 and p2 and line then
					local v1, o1 = Camera:WorldToViewportPoint(p1.Position)
					local v2, o2 = Camera:WorldToViewportPoint(p2.Position)
					if o1 and o2 then
						line.From    = Vector2.new(v1.X, v1.Y)
						line.To      = Vector2.new(v2.X, v2.Y)
						line.Color   = espColor
						line.Visible = true
					else
						line.Visible = false
					end
				elseif line then
					line.Visible = false
				end
			end
		else
			clearSkeleton(plr)
		end

		-- ── TRACERS ───────────────────────────────────────
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if ESP.Tracers and hrp then
			if not Tracers[plr] then createTracer(plr) end
			local v, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			local tracer = Tracers[plr]
			if onScreen and tracer then
				local vp = Camera.ViewportSize
				tracer.From    = Vector2.new(vp.X / 2, vp.Y)
				tracer.To      = Vector2.new(v.X, v.Y)
				tracer.Color   = espColor
				tracer.Visible = true
			elseif tracer then
				tracer.Visible = false
			end
		else
			clearTracer(plr)
		end
	end
end)

-- Limpeza ao sair
Players.PlayerRemoving:Connect(function(plr)
	clearESP(plr)
	clearSkeleton(plr)
	clearTracer(plr)
	clearHealthBar(plr)
end)

-- Recria ESP quando personagem respawna
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

local function onESPToggle(state)
	ESP.Enabled = state
	if not state then
		for _, plr in ipairs(Players:GetPlayers()) do
			clearESP(plr)
			clearSkeleton(plr)
			clearTracer(plr)
			clearHealthBar(plr)
		end
	else
		refreshAllESP()
	end
end

local function onRGBToggle(state)
	ESP.RGB = state
end

local function onBoxToggle(state)
	ESP.Box = state
	applyBoxVisibility()
end

local function onSkeletonToggle(state)
	ESP.Skeleton = state
	if not state then
		for _, plr in ipairs(Players:GetPlayers()) do clearSkeleton(plr) end
	end
end

local function onNameESPToggle(state)
	ESP.Names = state
	applyNameVisibility()
end

local function onDistanceToggle(state)
	ESP.Distance = state
	applyDistVisibility()
end

local function onHealthBarToggle(state)
	ESP.HealthBar = state
	if not state then
		for _, plr in ipairs(Players:GetPlayers()) do clearHealthBar(plr) end
	end
end

local function onTracelinesToggle(state)
	ESP.Tracers = state
	if not state then
		for _, plr in ipairs(Players:GetPlayers()) do clearTracer(plr) end
	end
end

-- Hooks aimbot/combat (prontos para implementação futura)
local function onAimbotToggle(s)       print("[Purity] Aimbot:", s)       end
local function onSilentAimToggle(s)    print("[Purity] Silent Aim:", s)   end
local function onPredictionToggle(s)   print("[Purity] Prediction:", s)   end
local function onFOVCircleToggle(s)    print("[Purity] FOV Circle:", s)   end
local function onFOVChange(v)          print("[Purity] FOV Size:", v)     end
local function onSmoothnessChange(v)   print("[Purity] Smoothness:", v)   end
local function onNoRecoilToggle(s)     print("[Purity] No Recoil:", s)    end
local function onNoSpreadToggle(s)     print("[Purity] No Spread:", s)    end
local function onRapidFireToggle(s)    print("[Purity] Rapid Fire:", s)   end
local function onInfiniteAmmoToggle(s) print("[Purity] Inf. Ammo:", s)    end
local function onFireRateChange(v)     print("[Purity] Fire Rate:", v)    end

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

local Glow = Instance.new("ImageLabel")
Glow.Size               = UDim2.new(0, 380, 0, 520)
Glow.Position           = UDim2.new(0.5, -190, 0.5, -260)
Glow.BackgroundTransparency = 1
Glow.Image              = "rbxassetid://5028857084"
Glow.ImageColor3        = Color3.fromRGB(120, 20, 200)
Glow.ImageTransparency  = 0.6
Glow.ZIndex             = 1
Glow.Parent             = ScreenGui

local Main = Instance.new("Frame")
Main.Name             = "Main"
Main.Size             = UDim2.new(0, 340, 0, 480)
Main.Position         = UDim2.new(0.5, -170, 0.5, -240)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel  = 0
Main.ZIndex           = 2
Main.ClipsDescendants = true
Main.Parent           = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color        = C.border
MainStroke.Thickness    = 1.5
MainStroke.Transparency = 0.05

-- ── HEADER ───────────────────────────────────────────────

local Header = Instance.new("Frame")
Header.Size             = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel  = 0
Header.ZIndex           = 3
Header.Parent           = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local HFix = Instance.new("Frame")
HFix.Size             = UDim2.new(1, 0, 0, 14)
HFix.Position         = UDim2.new(0, 0, 1, -14)
HFix.BackgroundColor3 = C.header
HFix.BorderSizePixel  = 0
HFix.ZIndex           = 3
HFix.Parent           = Header

local HLine = Instance.new("Frame")
HLine.Size              = UDim2.new(1, 0, 0, 1)
HLine.Position          = UDim2.new(0, 0, 1, -1)
HLine.BackgroundColor3  = C.border
HLine.BackgroundTransparency = 0.4
HLine.BorderSizePixel   = 0
HLine.ZIndex            = 4
HLine.Parent            = Header

local LogoDot = Instance.new("Frame")
LogoDot.Size             = UDim2.new(0, 12, 0, 12)
LogoDot.Position         = UDim2.new(0, 16, 0.5, -6)
LogoDot.BackgroundColor3 = C.neonBright
LogoDot.BorderSizePixel  = 0
LogoDot.ZIndex           = 5
LogoDot.Parent           = Header
Instance.new("UICorner", LogoDot).CornerRadius = UDim.new(1, 0)

local DotGlow = Instance.new("Frame")
DotGlow.Size              = UDim2.new(0, 6, 0, 6)
DotGlow.Position          = UDim2.new(0.5, -3, 0.5, -3)
DotGlow.BackgroundColor3  = C.white
DotGlow.BackgroundTransparency = 0.3
DotGlow.BorderSizePixel   = 0
DotGlow.ZIndex            = 6
DotGlow.Parent            = LogoDot
Instance.new("UICorner", DotGlow).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size             = UDim2.new(0, 120, 0, 22)
Title.Position         = UDim2.new(0, 36, 0, 10)
Title.BackgroundTransparency = 1
Title.Text             = "PURITY"
Title.TextColor3       = C.white
Title.Font             = Enum.Font.GothamBold
Title.TextSize         = 20
Title.TextXAlignment   = Enum.TextXAlignment.Left
Title.ZIndex           = 5
Title.Parent           = Header

local Badge = Instance.new("TextLabel")
Badge.Size             = UDim2.new(0, 42, 0, 16)
Badge.Position         = UDim2.new(0, 36, 0, 32)
Badge.BackgroundColor3 = C.btnOn
Badge.Text             = "v2.2"
Badge.TextColor3       = C.neonBright
Badge.Font             = Enum.Font.GothamBold
Badge.TextSize         = 10
Badge.ZIndex           = 5
Badge.Parent           = Header
Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 4)

local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0, 28, 0, 28)
MinBtn.Position         = UDim2.new(1, -64, 0.5, -14)
MinBtn.BackgroundColor3 = C.minGray
MinBtn.BorderSizePixel  = 0
MinBtn.Text             = "–"
MinBtn.TextColor3       = C.textSec
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.TextSize         = 16
MinBtn.ZIndex           = 6
MinBtn.Parent           = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 7)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 28, 0, 28)
CloseBtn.Position         = UDim2.new(1, -30, 0.5, -14)
CloseBtn.BackgroundColor3 = C.closeRed
CloseBtn.BorderSizePixel  = 0
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = C.white
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 12
CloseBtn.ZIndex           = 6
CloseBtn.Parent           = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)

-- ── TAB BAR ──────────────────────────────────────────────

local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1, -24, 0, 34)
TabBar.Position         = UDim2.new(0, 12, 0, 62)
TabBar.BackgroundColor3 = C.btnOff
TabBar.BorderSizePixel  = 0
TabBar.ZIndex           = 3
TabBar.Parent           = Main
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 9)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
TabLayout.Padding       = UDim.new(0, 3)

local TabPad = Instance.new("UIPadding", TabBar)
TabPad.PaddingLeft   = UDim.new(0, 3)
TabPad.PaddingRight  = UDim.new(0, 3)
TabPad.PaddingTop    = UDim.new(0, 3)
TabPad.PaddingBottom = UDim.new(0, 3)

-- ── BODY ─────────────────────────────────────────────────

local Body = Instance.new("ScrollingFrame")
Body.Size             = UDim2.new(1, -24, 1, -108)
Body.Position         = UDim2.new(0, 12, 0, 104)
Body.BackgroundTransparency = 1
Body.BorderSizePixel  = 0
Body.ScrollBarThickness = 3
Body.ScrollBarImageColor3 = C.neonSoft
Body.CanvasSize       = UDim2.new(0, 0, 0, 0)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.ZIndex           = 3
Body.Parent           = Main

local BodyLayout = Instance.new("UIListLayout", Body)
BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
BodyLayout.Padding   = UDim.new(0, 10)

local BodyPad = Instance.new("UIPadding", Body)
BodyPad.PaddingTop    = UDim.new(0, 6)
BodyPad.PaddingBottom = UDim.new(0, 10)

-- ══════════════════════════════════════════════════════════
--                   COMPONENTES GUI
-- ══════════════════════════════════════════════════════════

local function makeSection(parent, title, order)
	local S = Instance.new("Frame")
	S.Size             = UDim2.new(1, 0, 0, 0)
	S.AutomaticSize    = Enum.AutomaticSize.Y
	S.BackgroundColor3 = C.panel
	S.BorderSizePixel  = 0
	S.LayoutOrder      = order
	S.Parent           = parent
	Instance.new("UICorner", S).CornerRadius = UDim.new(0, 10)

	local SS = Instance.new("UIStroke", S)
	SS.Color       = C.border
	SS.Thickness   = 1
	SS.Transparency = 0.55

	local SP = Instance.new("UIPadding", S)
	SP.PaddingLeft   = UDim.new(0, 10)
	SP.PaddingRight  = UDim.new(0, 10)
	SP.PaddingTop    = UDim.new(0, 10)
	SP.PaddingBottom = UDim.new(0, 10)

	local SL = Instance.new("UIListLayout", S)
	SL.SortOrder = Enum.SortOrder.LayoutOrder
	SL.Padding   = UDim.new(0, 7)

	local SH = Instance.new("Frame")
	SH.Size                  = UDim2.new(1, 0, 0, 20)
	SH.BackgroundTransparency = 1
	SH.LayoutOrder           = 0
	SH.Parent                = S

	local SHLine = Instance.new("Frame")
	SHLine.Size              = UDim2.new(1, 0, 0, 1)
	SHLine.Position          = UDim2.new(0, 0, 1, 0)
	SHLine.BackgroundColor3  = C.border
	SHLine.BackgroundTransparency = 0.65
	SHLine.BorderSizePixel   = 0
	SHLine.Parent            = SH

	local STick = Instance.new("Frame")
	STick.Size             = UDim2.new(0, 3, 1, 0)
	STick.BackgroundColor3 = C.neon
	STick.BorderSizePixel  = 0
	STick.Parent           = SH
	Instance.new("UICorner", STick).CornerRadius = UDim.new(1, 0)

	local ST = Instance.new("TextLabel")
	ST.Size            = UDim2.new(1, -10, 1, 0)
	ST.Position        = UDim2.new(0, 10, 0, 0)
	ST.BackgroundTransparency = 1
	ST.Text            = string.upper(title)
	ST.TextColor3      = C.neon
	ST.Font            = Enum.Font.GothamBold
	ST.TextSize        = 11
	ST.TextXAlignment  = Enum.TextXAlignment.Left
	ST.ZIndex          = 2
	ST.Parent          = SH

	return S
end

local function makeToggle(parent, label, desc, order, callback)
	local state = false

	local Row = Instance.new("Frame")
	Row.Size             = UDim2.new(1, 0, 0, desc ~= "" and 48 or 40)
	Row.BackgroundColor3 = C.card
	Row.BorderSizePixel  = 0
	Row.LayoutOrder      = order
	Row.Parent           = parent
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

	local RS = Instance.new("UIStroke", Row)
	RS.Color       = Color3.fromRGB(60, 40, 90)
	RS.Thickness   = 1
	RS.Transparency = 0.4

	local Bar = Instance.new("Frame")
	Bar.Size             = UDim2.new(0, 3, 0, desc ~= "" and 28 or 20)
	Bar.Position         = UDim2.new(0, 8, 0.5, desc ~= "" and -14 or -10)
	Bar.BackgroundColor3 = C.textDim
	Bar.BorderSizePixel  = 0
	Bar.Parent           = Row
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

	local Lbl = Instance.new("TextLabel")
	Lbl.Size            = UDim2.new(1, -70, 0, 18)
	Lbl.Position        = UDim2.new(0, 20, desc ~= "" and 0.2 or 0.5, desc ~= "" and 0 or -9)
	Lbl.BackgroundTransparency = 1
	Lbl.Text            = label
	Lbl.TextColor3      = C.textSec
	Lbl.Font            = Enum.Font.Gotham
	Lbl.TextSize        = 13
	Lbl.TextXAlignment  = Enum.TextXAlignment.Left
	Lbl.Parent          = Row

	if desc ~= "" then
		local Desc = Instance.new("TextLabel")
		Desc.Size                  = UDim2.new(1, -70, 0, 14)
		Desc.Position              = UDim2.new(0, 20, 0, 24)
		Desc.BackgroundTransparency = 1
		Desc.Text                  = desc
		Desc.TextColor3            = C.textDim
		Desc.Font                  = Enum.Font.Gotham
		Desc.TextSize              = 10
		Desc.TextXAlignment        = Enum.TextXAlignment.Left
		Desc.Parent                = Row
	end

	local Switch = Instance.new("Frame")
	Switch.Size             = UDim2.new(0, 42, 0, 22)
	Switch.Position         = UDim2.new(1, -50, 0.5, -11)
	Switch.BackgroundColor3 = Color3.fromRGB(42, 28, 65)
	Switch.BorderSizePixel  = 0
	Switch.Parent           = Row
	Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

	local Knob = Instance.new("Frame")
	Knob.Size             = UDim2.new(0, 16, 0, 16)
	Knob.Position         = UDim2.new(0, 3, 0.5, -8)
	Knob.BackgroundColor3 = C.textDim
	Knob.BorderSizePixel  = 0
	Knob.Parent           = Switch
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

	local Btn = Instance.new("TextButton")
	Btn.Size                  = UDim2.new(1, 0, 1, 0)
	Btn.BackgroundTransparency = 1
	Btn.Text                  = ""
	Btn.ZIndex                = 5
	Btn.Parent                = Row

	local function refreshToggle()
		if state then
			TweenService:Create(Row,    TW, {BackgroundColor3 = C.btnOn}):Play()
			TweenService:Create(Lbl,    TW, {TextColor3 = C.textPrim}):Play()
			TweenService:Create(Bar,    TW, {BackgroundColor3 = C.neonBright}):Play()
			TweenService:Create(Switch, TW, {BackgroundColor3 = Color3.fromRGB(75, 15, 135)}):Play()
			TweenService:Create(Knob,   TW, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = C.neonBright}):Play()
			RS.Color = C.border; RS.Transparency = 0.1
		else
			TweenService:Create(Row,    TW, {BackgroundColor3 = C.card}):Play()
			TweenService:Create(Lbl,    TW, {TextColor3 = C.textSec}):Play()
			TweenService:Create(Bar,    TW, {BackgroundColor3 = C.textDim}):Play()
			TweenService:Create(Switch, TW, {BackgroundColor3 = Color3.fromRGB(42, 28, 65)}):Play()
			TweenService:Create(Knob,   TW, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = C.textDim}):Play()
			RS.Color = Color3.fromRGB(60, 40, 90); RS.Transparency = 0.4
		end
	end

	Btn.MouseButton1Click:Connect(function()
		state = not state
		refreshToggle()
		callback(state)
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
	Wrap.Size             = UDim2.new(1, 0, 0, 56)
	Wrap.BackgroundColor3 = C.card
	Wrap.BorderSizePixel  = 0
	Wrap.LayoutOrder      = order
	Wrap.Parent           = parent
	Instance.new("UICorner", Wrap).CornerRadius = UDim.new(0, 8)

	local WS = Instance.new("UIStroke", Wrap)
	WS.Color       = Color3.fromRGB(60, 40, 90)
	WS.Thickness   = 1
	WS.Transparency = 0.4

	local Bar = Instance.new("Frame")
	Bar.Size             = UDim2.new(0, 3, 0, 16)
	Bar.Position         = UDim2.new(0, 8, 0.5, -8)
	Bar.BackgroundColor3 = C.neonSoft
	Bar.BorderSizePixel  = 0
	Bar.Parent           = Wrap
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

	local Lbl = Instance.new("TextLabel")
	Lbl.Size            = UDim2.new(1, -80, 0, 16)
	Lbl.Position        = UDim2.new(0, 20, 0, 8)
	Lbl.BackgroundTransparency = 1
	Lbl.Text            = label
	Lbl.TextColor3      = C.textSec
	Lbl.Font            = Enum.Font.Gotham
	Lbl.TextSize        = 12
	Lbl.TextXAlignment  = Enum.TextXAlignment.Left
	Lbl.Parent          = Wrap

	local ValLbl = Instance.new("TextLabel")
	ValLbl.Size            = UDim2.new(0, 60, 0, 16)
	ValLbl.Position        = UDim2.new(1, -68, 0, 8)
	ValLbl.BackgroundTransparency = 1
	ValLbl.Text            = tostring(defaultV)..suffix
	ValLbl.TextColor3      = C.neon
	ValLbl.Font            = Enum.Font.GothamBold
	ValLbl.TextSize        = 12
	ValLbl.TextXAlignment  = Enum.TextXAlignment.Right
	ValLbl.Parent          = Wrap

	local Track = Instance.new("Frame")
	Track.Size             = UDim2.new(1, -28, 0, 6)
	Track.Position         = UDim2.new(0, 20, 0, 36)
	Track.BackgroundColor3 = C.sliderTrack
	Track.BorderSizePixel  = 0
	Track.Parent           = Wrap
	Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

	local Fill = Instance.new("Frame")
	Fill.Size             = UDim2.new((defaultV-minV)/(maxV-minV), 0, 1, 0)
	Fill.BackgroundColor3 = C.sliderFill
	Fill.BorderSizePixel  = 0
	Fill.Parent           = Track
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	local SKnob = Instance.new("Frame")
	SKnob.Size             = UDim2.new(0, 14, 0, 14)
	SKnob.Position         = UDim2.new((defaultV-minV)/(maxV-minV), -7, 0.5, -7)
	SKnob.BackgroundColor3 = C.sliderKnob
	SKnob.BorderSizePixel  = 0
	SKnob.ZIndex           = 2
	SKnob.Parent           = Track
	Instance.new("UICorner", SKnob).CornerRadius = UDim.new(1, 0)

	local draggingSlider = false

	local function updateSlider(inputX)
		local rel   = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		value = math.floor(minV + rel * (maxV - minV))
		Fill.Size      = UDim2.new(rel, 0, 1, 0)
		SKnob.Position = UDim2.new(rel, -7, 0.5, -7)
		ValLbl.Text    = tostring(value)..suffix
		callback(value)
	end

	local CZ = Instance.new("TextButton")
	CZ.Size                  = UDim2.new(1, 0, 1, 0)
	CZ.BackgroundTransparency = 1
	CZ.Text                  = ""
	CZ.ZIndex                = 3
	CZ.Parent                = Track

	CZ.MouseButton1Down:Connect(function(x) draggingSlider = true; updateSlider(x) end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
		end
	end)

	Wrap.MouseEnter:Connect(function()
		TweenService:Create(Wrap, TweenInfo.new(0.1), {BackgroundColor3 = C.cardHover}):Play()
	end)
	Wrap.MouseLeave:Connect(function()
		TweenService:Create(Wrap, TweenInfo.new(0.1), {BackgroundColor3 = C.card}):Play()
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
	TBtn.Size             = UDim2.new(0, 96, 1, 0)
	TBtn.BackgroundColor3 = C.tabInactive
	TBtn.BorderSizePixel  = 0
	TBtn.Text             = icon.." "..name
	TBtn.TextColor3       = C.textDim
	TBtn.Font             = Enum.Font.GothamBold
	TBtn.TextSize         = 11
	TBtn.LayoutOrder      = order
	TBtn.ZIndex           = 4
	TBtn.Parent           = TabBar
	Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 7)

	local Indicator = Instance.new("Frame")
	Indicator.Size              = UDim2.new(0.6, 0, 0, 2)
	Indicator.Position          = UDim2.new(0.2, 0, 1, -3)
	Indicator.BackgroundColor3  = C.neonBright
	Indicator.BackgroundTransparency = 1
	Indicator.BorderSizePixel   = 0
	Indicator.Parent            = TBtn
	Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

	local Page = Instance.new("Frame")
	Page.Size             = UDim2.new(1, 0, 0, 0)
	Page.AutomaticSize    = Enum.AutomaticSize.Y
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel  = 0
	Page.LayoutOrder      = order
	Page.Visible          = false
	Page.Parent           = Body

	local PL = Instance.new("UIListLayout", Page)
	PL.SortOrder = Enum.SortOrder.LayoutOrder
	PL.Padding   = UDim.new(0, 8)

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

local pageESP    = createTab("ESP",    "◈", 1)
local pageAimbot = createTab("Aimbot", "◎", 2)
local pageCombat = createTab("Combat", "⚡", 3)

-- ══════════════════════════════════════════════════════════
--                   POPULANDO AS ABAS
-- ══════════════════════════════════════════════════════════

-- ── ABA ESP ──────────────────────────────────────────────
do
	local sec = makeSection(pageESP, "ESP / Highlights", 1)
	makeToggle(sec, "ESP Ativo",        "Liga/desliga todo o sistema ESP",         1, onESPToggle)
	makeToggle(sec, "RGB",              "Cores animadas em arco-íris",             2, onRGBToggle)
	makeToggle(sec, "Caixa (Box ESP)",  "Silhueta/highlight ao redor do player",   3, onBoxToggle)
	makeToggle(sec, "Esqueleto",        "Linhas do esqueleto sobre o personagem",  4, onSkeletonToggle)
	makeToggle(sec, "Nome (Name ESP)",  "Exibe o nome acima do player",            5, onNameESPToggle)
	makeToggle(sec, "Distância",        "Mostra quantos studs o inimigo está",     6, onDistanceToggle)
	makeToggle(sec, "Health Bar",       "Barra de vida na lateral do personagem",  7, onHealthBarToggle)
	makeToggle(sec, "Tracelines",       "Linha do centro da tela até o player",    8, onTracelinesToggle)
end

-- ── ABA AIMBOT ───────────────────────────────────────────
do
	local sec1 = makeSection(pageAimbot, "Aimbot", 1)
	makeToggle(sec1, "Aimbot Ativo",  "Liga/desliga o sistema de aimbot",      1, onAimbotToggle)
	makeToggle(sec1, "Silent Aim",    "Acerta sem mover a câmera",             2, onSilentAimToggle)
	makeToggle(sec1, "Prediction",    "Compensa o movimento do alvo",          3, onPredictionToggle)
	makeToggle(sec1, "FOV Circle",    "Exibe o círculo de campo de mira",      4, onFOVCircleToggle)

	local sec2 = makeSection(pageAimbot, "Configurações", 2)
	makeSlider(sec2, "FOV Size",   50, 500, 150, " px", 1, onFOVChange)
	makeSlider(sec2, "Smoothness",  1,  20,   8, "x",   2, onSmoothnessChange)
end

-- ── ABA COMBAT ───────────────────────────────────────────
do
	local sec1 = makeSection(pageCombat, "Weapon Mods", 1)
	makeToggle(sec1, "No Recoil",     "Remove o recuo da arma",               1, onNoRecoilToggle)
	makeToggle(sec1, "No Spread",     "Remove a dispersão dos tiros",         2, onNoSpreadToggle)
	makeToggle(sec1, "Rapid Fire",    "Aumenta a cadência de disparo",        3, onRapidFireToggle)
	makeToggle(sec1, "Infinite Ammo", "Munição não se esgota",                4, onInfiniteAmmoToggle)

	local sec2 = makeSection(pageCombat, "Configurações", 2)
	makeSlider(sec2, "Fire Rate", 1, 10, 1, "x", 1, onFireRateChange)
end

-- ── ATIVA ABA ESP POR PADRÃO ─────────────────────────────
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
		dragging  = true
		dragStart = input.Position
		startPos  = Main.Position
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
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
		                          startPos.Y.Scale, startPos.Y.Offset + d.Y)
		Glow.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset - 20,
		                          Main.Position.Y.Scale, Main.Position.Y.Offset - 20)
	end
end)

-- ══════════════════════════════════════════════════════════
--               FECHAR / MINIMIZAR / KEYBIND
-- ══════════════════════════════════════════════════════════

local minimized  = false
local guiVisible = true
local originalH  = 480

CloseBtn.MouseButton1Click:Connect(function()
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
--                  RGB ANIMADO NO HEADER
-- ══════════════════════════════════════════════════════════

local headerHue = 0
RunService.Heartbeat:Connect(function(dt)
	headerHue = (headerHue + dt * 0.12) % 1
	local rgb = Color3.fromHSV(headerHue, 0.8, 1)
	LogoDot.BackgroundColor3 = rgb
	HLine.BackgroundColor3   = rgb
	DotGlow.BackgroundColor3 = rgb
end)

-- ══════════════════════════════════════════════════════════
--                  ANIMAÇÃO DE ENTRADA
-- ══════════════════════════════════════════════════════════

Main.Size = UDim2.new(0, 340, 0, 0)
Main.BackgroundTransparency = 0.8
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{Size = UDim2.new(0,340,0,originalH), BackgroundTransparency = 0}):Play()
TweenService:Create(Glow, TweenInfo.new(0.4), {ImageTransparency = 0.6}):Play()

-- ╔══════════════════════════════════════════════════════╗
-- ║  PURITY v2.2 — ESP Completo                         ║
-- ║                                                      ║
-- ║  ◈ ESP Ativo    → Liga/desliga tudo                 ║
-- ║  ◈ RGB          → Cores animadas em tudo            ║
-- ║  ◈ Caixa        → Highlight/silhueta                ║
-- ║  ◈ Esqueleto    → Drawing.Line nos ossos            ║
-- ║  ◈ Nome         → BillboardGui com nome             ║
-- ║  ◈ Distância    → Studs em tempo real               ║
-- ║  ◈ Health Bar   → Barra verde→vermelho na lateral   ║
-- ║  ◈ Tracelines   → Linha até o player                ║
-- ║                                                      ║
-- ║  RightShift → mostra/esconde o menu                 ║
-- ╚══════════════════════════════════════════════════════╝