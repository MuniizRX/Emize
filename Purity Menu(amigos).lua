-- PURITY GUI v7.0 - DESIGN PROFISSIONAL
-- RightShift = abre/fecha

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

-- ============================================================
--  SISTEMA HWID - Purity v7.0
--  Verificacao automatica por HWID — usuario nao digita nada.
--  Configure o link do GitHub Gist abaixo (so uma vez).
--  Formato no Gist: HWID|YYYY-MM-DD|apelido
-- ============================================================

local GIST_URL = "https://gist.githubusercontent.com/MuniizRX/e0de8c9299806cf6ebd67c67c7133b1d/raw/6b53c72d1215191261859e9aeab270dffe74d467/purity_keys.txt"

local function loadMainGUI() end -- placeholder, definida mais abaixo

-- Pega o HWID do PC (ID unico gerado pelo Roblox por maquina)
local hwid = ""
pcall(function()
	hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
end)
if hwid == "" then
	-- Fallback: usa UserId + nome da maquina como identificador alternativo
	hwid = tostring(LocalPlayer.UserId)
end

-- ── GUI de verificacao ──
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "PurityHWIDCheck"
KeyGui.ResetOnSpawn = false
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyGui.DisplayOrder = 9999
KeyGui.IgnoreGuiInset = true
KeyGui.Parent = PlayerGui

local Overlay = Instance.new("Frame", KeyGui)
Overlay.Size = UDim2.new(1,0,1,0)
Overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
Overlay.BackgroundTransparency = 0.45
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 1

local KWin = Instance.new("Frame", KeyGui)
KWin.Size = UDim2.new(0,380,0,0)
KWin.Position = UDim2.new(0.5,-190,0.5,-100)
KWin.BackgroundColor3 = Color3.fromRGB(15,15,20)
KWin.BackgroundTransparency = 0.6
KWin.BorderSizePixel = 0
KWin.ZIndex = 2
Instance.new("UICorner", KWin).CornerRadius = UDim.new(0,12)
local KStroke = Instance.new("UIStroke", KWin)
KStroke.Color = Color3.fromRGB(110,50,230)
KStroke.Thickness = 1.4

-- Header
local KHeader = Instance.new("Frame", KWin)
KHeader.Size = UDim2.new(1,0,0,44)
KHeader.BackgroundColor3 = Color3.fromRGB(13,13,18)
KHeader.BorderSizePixel = 0
KHeader.ZIndex = 3
Instance.new("UICorner", KHeader).CornerRadius = UDim.new(0,12)
local KHFix = Instance.new("Frame", KHeader)
KHFix.Size = UDim2.new(1,0,0,12)
KHFix.Position = UDim2.new(0,0,1,-12)
KHFix.BackgroundColor3 = Color3.fromRGB(13,13,18)
KHFix.BorderSizePixel = 0
KHFix.ZIndex = 3
local KHDiv = Instance.new("Frame", KHeader)
KHDiv.Size = UDim2.new(1,0,0,1)
KHDiv.Position = UDim2.new(0,0,1,0)
KHDiv.BackgroundColor3 = Color3.fromRGB(110,50,230)
KHDiv.BorderSizePixel = 0
KHDiv.ZIndex = 4
local KDot = Instance.new("Frame", KHeader)
KDot.Size = UDim2.new(0,8,0,8)
KDot.Position = UDim2.new(0,14,0.5,-4)
KDot.BackgroundColor3 = Color3.fromRGB(145,85,255)
KDot.BorderSizePixel = 0
KDot.ZIndex = 5
Instance.new("UICorner", KDot).CornerRadius = UDim.new(1,0)
local KTitle = Instance.new("TextLabel", KHeader)
KTitle.Size = UDim2.new(1,-30,1,0)
KTitle.Position = UDim2.new(0,30,0,0)
KTitle.BackgroundTransparency = 1
KTitle.Text = "PURITY  —  Verificando Acesso..."
KTitle.TextColor3 = Color3.fromRGB(238,232,255)
KTitle.Font = Enum.Font.GothamBold
KTitle.TextSize = 13
KTitle.TextXAlignment = Enum.TextXAlignment.Left
KTitle.ZIndex = 5

-- Status central
local KStatus = Instance.new("TextLabel", KWin)
KStatus.Size = UDim2.new(1,-32,0,40)
KStatus.Position = UDim2.new(0,16,0,58)
KStatus.BackgroundTransparency = 1
KStatus.Text = "Verificando seu acesso, aguarde..."
KStatus.TextColor3 = Color3.fromRGB(148,138,180)
KStatus.Font = Enum.Font.Gotham
KStatus.TextSize = 12
KStatus.TextWrapped = true
KStatus.TextXAlignment = Enum.TextXAlignment.Left
KStatus.ZIndex = 3

-- HWID display (mostra pro usuario copiar e mandar pra voce)
local KHwidBG = Instance.new("Frame", KWin)
KHwidBG.Size = UDim2.new(1,-32,0,34)
KHwidBG.Position = UDim2.new(0,16,0,104)
KHwidBG.BackgroundColor3 = Color3.fromRGB(22,20,30)
KHwidBG.BorderSizePixel = 0
KHwidBG.ZIndex = 3
KHwidBG.Visible = false
Instance.new("UICorner", KHwidBG).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", KHwidBG).Color = Color3.fromRGB(58,48,86)

local KHwidLbl = Instance.new("TextLabel", KHwidBG)
KHwidLbl.Size = UDim2.new(1,-80,1,0)
KHwidLbl.Position = UDim2.new(0,8,0,0)
KHwidLbl.BackgroundTransparency = 1
KHwidLbl.Text = hwid
KHwidLbl.TextColor3 = Color3.fromRGB(145,85,255)
KHwidLbl.Font = Enum.Font.GothamBold
KHwidLbl.TextSize = 11
KHwidLbl.TextXAlignment = Enum.TextXAlignment.Left
KHwidLbl.TextTruncate = Enum.TextTruncate.AtEnd
KHwidLbl.ZIndex = 4

-- Botao copiar HWID
local KCopyBtn = Instance.new("TextButton", KHwidBG)
KCopyBtn.Size = UDim2.new(0,66,0,24)
KCopyBtn.Position = UDim2.new(1,-72,0.5,-12)
KCopyBtn.BackgroundColor3 = Color3.fromRGB(110,50,230)
KCopyBtn.BorderSizePixel = 0
KCopyBtn.Text = "📋 Copiar"
KCopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
KCopyBtn.Font = Enum.Font.GothamBold
KCopyBtn.TextSize = 10
KCopyBtn.ZIndex = 5
Instance.new("UICorner", KCopyBtn).CornerRadius = UDim.new(0,6)

KCopyBtn.MouseButton1Click:Connect(function()
	setclipboard(hwid)
	KCopyBtn.Text = "✓ Copiado"
	KCopyBtn.BackgroundColor3 = Color3.fromRGB(0,160,75)
	task.delay(2, function()
		KCopyBtn.Text = "📋 Copiar"
		KCopyBtn.BackgroundColor3 = Color3.fromRGB(110,50,230)
	end)
end)
KCopyBtn.MouseEnter:Connect(function()
	if KCopyBtn.Text ~= "✓ Copiado" then
		TweenService:Create(KCopyBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(145,85,255)}):Play()
	end
end)
KCopyBtn.MouseLeave:Connect(function()
	if KCopyBtn.Text ~= "✓ Copiado" then
		TweenService:Create(KCopyBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(110,50,230)}):Play()
	end
end)

-- Animacao de entrada
TweenService:Create(KWin, TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out), {
	Size = UDim2.new(0,380,0,160),
	BackgroundTransparency = 0
}):Play()

-- ── Logica HWID ──
local function parseDate(dateStr)
	local y,m,d = dateStr:match("(%d+)-(%d+)-(%d+)")
	if not y then return nil end
	return {year=tonumber(y), month=tonumber(m), day=tonumber(d)}
end

local function checkExpired(dateStr)
	local dt = parseDate(dateStr)
	if not dt then return true end
	local now = os.date("*t")
	if now.year  ~= dt.year  then return now.year  > dt.year  end
	if now.month ~= dt.month then return now.month > dt.month end
	return now.day > dt.day
end

local function dismiss(success)
	TweenService:Create(KWin, TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
		{Size=UDim2.new(0,380,0,0), BackgroundTransparency=0.6}):Play()
	TweenService:Create(Overlay, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
	task.delay(0.3, function()
		KeyGui:Destroy()
		if success then loadMainGUI() end
	end)
end

task.spawn(function()
	task.wait(0.4) -- espera animacao de entrada

	-- Busca lista do Gist
	local ok, result = pcall(function()
		return game:HttpGet(GIST_URL .. "?t=" .. tostring(math.floor(tick())), true)
	end)

	if not ok then
		KStatus.Text = "⚠  Erro de conexão. Verifique sua internet e tente novamente."
		KStatus.TextColor3 = Color3.fromRGB(240,165,0)
		return
	end

	-- Procura o HWID na lista
	-- Formato: HWID|YYYY-MM-DD|apelido  ou  HWID|YYYY-MM-DD
	local found   = false
	local expired = false

	for line in result:gmatch("[^\r\n]+") do
		line = line:match("^%s*(.-)%s*$")
		if line ~= "" and not line:match("^#") then
			local parts = {}
			for p in line:gmatch("[^|]+") do parts[#parts+1] = p:match("^%s*(.-)%s*$") end
			if parts[1] == hwid then
				found = true
				if parts[2] and checkExpired(parts[2]) then
					expired = true
				end
				break
			end
		end
	end

	if found and not expired then
		-- Acesso liberado
		KTitle.Text = "PURITY  —  Acesso Liberado ✓"
		KStatus.Text = "✓  Bem-vindo ao Purity v7.0!"
		KStatus.TextColor3 = Color3.fromRGB(0,205,95)
		KStroke.Color = Color3.fromRGB(0,160,75)
		task.wait(1)
		dismiss(true)

	elseif found and expired then
		-- HWID encontrado mas expirado
		KTitle.Text = "PURITY  —  Acesso Expirado"
		KStatus.Text = "⏱  Seu acesso expirou.\nEntre em contato para renovar."
		KStatus.TextColor3 = Color3.fromRGB(240,165,0)
		KStroke.Color = Color3.fromRGB(240,165,0)

	else
		-- HWID nao encontrado — mostra o HWID pra pessoa mandar pra voce
		KTitle.Text = "PURITY  —  Sem Acesso"
		KStatus.Text = "✗  Seu PC não está registrado.\nEnvie o ID abaixo para liberar seu acesso:"
		KStatus.TextColor3 = Color3.fromRGB(215,45,75)
		KStroke.Color = Color3.fromRGB(215,45,75)
		KHwidBG.Visible = true

		-- Botao de reverificar (aparece so quando nao tem acesso)
		local KRetryBtn = Instance.new("TextButton", KWin)
		KRetryBtn.Size = UDim2.new(1,-32,0,34)
		KRetryBtn.Position = UDim2.new(0,16,0,148)
		KRetryBtn.BackgroundColor3 = Color3.fromRGB(28,24,42)
		KRetryBtn.BorderSizePixel = 0
		KRetryBtn.Text = "🔄  Já enviei meu ID — Verificar Acesso"
		KRetryBtn.TextColor3 = Color3.fromRGB(145,85,255)
		KRetryBtn.Font = Enum.Font.GothamBold
		KRetryBtn.TextSize = 12
		KRetryBtn.ZIndex = 4
		Instance.new("UICorner", KRetryBtn).CornerRadius = UDim.new(0,8)
		local KRetryStroke = Instance.new("UIStroke", KRetryBtn)
		KRetryStroke.Color = Color3.fromRGB(80,40,160)
		KRetryStroke.Thickness = 1

		-- Expande a janela pra caber o botao
		TweenService:Create(KWin, TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
			{Size=UDim2.new(0,380,0,200)}):Play()

		KRetryBtn.MouseEnter:Connect(function()
			TweenService:Create(KRetryBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,28,70)}):Play()
		end)
		KRetryBtn.MouseLeave:Connect(function()
			TweenService:Create(KRetryBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,24,42)}):Play()
		end)

		KRetryBtn.MouseButton1Click:Connect(function()
			-- Bloqueia clique duplo
			KRetryBtn.Active = false
			KRetryBtn.Text = "⏳  Verificando..."
			KRetryBtn.TextColor3 = Color3.fromRGB(148,138,180)
			KRetryStroke.Color = Color3.fromRGB(58,48,86)
			KTitle.Text = "PURITY  —  Verificando Acesso..."
			KStatus.Text = "Verificando seu acesso, aguarde..."
			KStatus.TextColor3 = Color3.fromRGB(148,138,180)
			KStroke.Color = Color3.fromRGB(110,50,230)
			KHwidBG.Visible = false

			-- Rebusca no Gist
			local ok2, result2 = pcall(function()
				return game:HttpGet(GIST_URL .. "?t=" .. tostring(math.floor(tick())), true)
			end)

			if not ok2 then
				KTitle.Text = "PURITY  —  Sem Acesso"
				KStatus.Text = "⚠  Erro de conexão. Tente novamente."
				KStatus.TextColor3 = Color3.fromRGB(240,165,0)
				KStroke.Color = Color3.fromRGB(240,165,0)
				KHwidBG.Visible = true
				KRetryBtn.Active = true
				KRetryBtn.Text = "🔄  Já enviei meu ID — Verificar Acesso"
				KRetryBtn.TextColor3 = Color3.fromRGB(145,85,255)
				KRetryStroke.Color = Color3.fromRGB(80,40,160)
				return
			end

			local found2, expired2 = false, false
			for line in result2:gmatch("[^\r\n]+") do
				line = line:match("^%s*(.-)%s*$")
				if line ~= "" and not line:match("^#") then
					local parts = {}
					for p in line:gmatch("[^|]+") do parts[#parts+1] = p:match("^%s*(.-)%s*$") end
					if parts[1] == hwid then
						found2 = true
						if parts[2] and checkExpired(parts[2]) then expired2 = true end
						break
					end
				end
			end

			if found2 and not expired2 then
				-- Acesso liberado!
				KTitle.Text = "PURITY  —  Acesso Liberado ✓"
				KStatus.Text = "✓  Bem-vindo ao Purity v7.0!"
				KStatus.TextColor3 = Color3.fromRGB(0,205,95)
				KStroke.Color = Color3.fromRGB(0,160,75)
				KRetryBtn:Destroy()
				task.wait(1)
				dismiss(true)
			elseif found2 and expired2 then
				KTitle.Text = "PURITY  —  Acesso Expirado"
				KStatus.Text = "⏱  Seu acesso expirou.\nEntre em contato para renovar."
				KStatus.TextColor3 = Color3.fromRGB(240,165,0)
				KStroke.Color = Color3.fromRGB(240,165,0)
				KRetryBtn:Destroy()
			else
				-- Ainda nao registrado
				KTitle.Text = "PURITY  —  Sem Acesso"
				KStatus.Text = "✗  Ainda não registrado.\nEnvie o ID abaixo e aguarde:"
				KStatus.TextColor3 = Color3.fromRGB(215,45,75)
				KStroke.Color = Color3.fromRGB(215,45,75)
				KHwidBG.Visible = true
				KRetryBtn.Active = true
				KRetryBtn.Text = "🔄  Verificar Novamente"
				KRetryBtn.TextColor3 = Color3.fromRGB(145,85,255)
				KRetryStroke.Color = Color3.fromRGB(80,40,160)
			end
		end)
	end
end)

-- ============================================================
--  Tudo abaixo so executa apos a key ser validada
-- ============================================================
loadMainGUI = function()

local ESP = {
	Enabled=false, RGB=false, Box=false, Skeleton=false,
	Names=false, Distance=false, HealthBar=false, Tracers=false,
	Radar=false, VisionCone=false,
}
local AIMBOT = {
	Enabled=false, Silent=false, Prediction=false, FOVCircle=false,
	TeamCheck=true, VisCheck=false, AutoShoot=false, AimKey=false,
	TargetSwitch=false, AimShake=false,
	FOVRadius=150, Smoothness=8, MaxDist=500, ShakeAmt=2,
	TargetPart="Head", AimKeyCode=Enum.KeyCode.LeftAlt,
}
local COMBAT = {
	NoRecoil=false, NoSpread=false, RapidFire=false, InfiniteAmmo=false,
	BunnyHop=false, FastReload=false, AntiRagdoll=false,
	FlyHack=false, SpeedHack=false, JumpPower=false, InfiniteJump=false,
	FireRateMult=1, ReloadSpeed=1, WalkSpeed=50, JumpPowerVal=100, FlySpeed=50,
}
local combatConns = {}
local MISC = {
	CustomFOV=false, SpinBot=false, BigHead=false, Noclip=false,
	WallBang=false, AntiAFK=false, TimeOfDay=false,
	Thirdperson=false, ThirdpersonDist=8,
	BulletTracer=false, Crosshair=false, CrosshairSize=10, CrosshairGap=4,
	FOVValue=70, SpinSpeed=10, BigHeadScale=2, TimeValue=12,
}
local miscConns={}; local originalFOV=70; local originalHeads={}; local _screenGuiRef=nil

-- Keybinds customizaveis (nil = desativado)
local KEYBINDS={
	ESPKey=nil,       -- tecla para toggle ESP
	BigHeadKey=nil,   -- tecla para toggle BigHead
}
local waitingForKey=nil  -- "ESPKey" ou "BigHeadKey" quando aguardando input do usuario
local _keyBindLabels={}  -- labels dos botoes de keybind, preenchido em buildMisc

local function isEnemy(plr)
	if not LocalPlayer.Team or not plr.Team then return true end
	return plr.Team ~= LocalPlayer.Team
end
local function healthToColor(pct)
	pct=math.clamp(pct,0,1)
	if pct>0.5 then return Color3.fromRGB(math.floor(255*(1-pct)*2),255,0)
	else return Color3.fromRGB(255,math.floor(255*pct*2),0) end
end
local function screenDist(sp)
	local vp=Camera.ViewportSize
	return (Vector2.new(sp.X,sp.Y)-vp/2).Magnitude
end
local function isVisible(plr)
	local char=plr.Character; if not char then return false end
	local part=char:FindFirstChild(AIMBOT.TargetPart) or char:FindFirstChild("HumanoidRootPart")
	if not part then return false end
	local myChar=LocalPlayer.Character
	local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return false end
	local ray=RaycastParams.new()
	ray.FilterType=Enum.RaycastFilterType.Exclude
	ray.FilterDescendantsInstances={myChar,char}
	return workspace:Raycast(myHRP.Position,part.Position-myHRP.Position,ray)==nil
end

-- ESP
local drawings={}
local function clearESP(plr)
	if not drawings[plr] then return end
	for _,obj in pairs(drawings[plr]) do pcall(function() obj:Destroy() end); pcall(function() obj:Remove() end) end
	drawings[plr]=nil
end
local function createESP(plr)
	if plr==LocalPlayer then return end
	local char=plr.Character; if not char then return end
	-- Nao recria se o Highlight ainda existe e esta no char correto
	if drawings[plr] and drawings[plr].Highlight and drawings[plr].Highlight.Parent==char then return end
	clearESP(plr)
	drawings[plr]={}
	local hl=Instance.new("Highlight"); hl.FillTransparency=0.5; hl.OutlineTransparency=0
	hl.OutlineColor=Color3.fromRGB(120,60,240); hl.FillColor=Color3.fromRGB(70,0,150)
	hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled=ESP.Box; hl.Parent=char
	local head=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	local bill=Instance.new("BillboardGui"); bill.Size=UDim2.new(0,120,0,44); bill.AlwaysOnTop=true
	bill.StudsOffset=Vector3.new(0,3.2,0); bill.Enabled=ESP.Names or ESP.Distance; bill.Parent=head
	local layout=Instance.new("UIListLayout",bill); layout.SortOrder=Enum.SortOrder.LayoutOrder
	layout.FillDirection=Enum.FillDirection.Vertical; layout.HorizontalAlignment=Enum.HorizontalAlignment.Center; layout.Padding=UDim.new(0,2)
	local nameLbl=Instance.new("TextLabel",bill); nameLbl.Size=UDim2.new(1,0,0,18); nameLbl.BackgroundTransparency=1
	nameLbl.Text=plr.Name; nameLbl.TextColor3=Color3.fromRGB(180,100,255); nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=13
	nameLbl.TextStrokeTransparency=0; nameLbl.TextStrokeColor3=Color3.fromRGB(0,0,0); nameLbl.Visible=ESP.Names; nameLbl.LayoutOrder=1
	local distLbl=Instance.new("TextLabel",bill); distLbl.Size=UDim2.new(1,0,0,16); distLbl.BackgroundTransparency=1
	distLbl.Text="0 studs"; distLbl.TextColor3=Color3.fromRGB(200,200,255); distLbl.Font=Enum.Font.Gotham; distLbl.TextSize=11
	distLbl.TextStrokeTransparency=0; distLbl.TextStrokeColor3=Color3.fromRGB(0,0,0); distLbl.Visible=ESP.Distance; distLbl.LayoutOrder=2
	drawings[plr].Highlight=hl; drawings[plr].Billboard=bill; drawings[plr].NameLabel=nameLbl; drawings[plr].DistLabel=distLbl
end
local function applyBoxVisibility() for _,d in pairs(drawings) do if d.Highlight then d.Highlight.Enabled=ESP.Box end end end
local function applyNameVisibility()
	for _,d in pairs(drawings) do
		if d.NameLabel then d.NameLabel.Visible=ESP.Names end
		if d.Billboard then d.Billboard.Enabled=ESP.Names or ESP.Distance end
	end
end
local function applyDistVisibility()
	for _,d in pairs(drawings) do
		if d.DistLabel then d.DistLabel.Visible=ESP.Distance end
		if d.Billboard then d.Billboard.Enabled=ESP.Names or ESP.Distance end
	end
end
local function refreshAllESP()
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=LocalPlayer and plr.Character and isEnemy(plr) then createESP(plr) end
	end
end

-- Health Bar
local HealthBars={}
local function clearHealthBar(plr)
	if not HealthBars[plr] then return end
	pcall(function() HealthBars[plr].bg:Remove() end); pcall(function() HealthBars[plr].fg:Remove() end); pcall(function() HealthBars[plr].txt:Remove() end)
	HealthBars[plr]=nil
end
local function createHealthBar(plr)
	if HealthBars[plr] then return end
	local bg=Drawing.new("Line"); bg.Thickness=6; bg.Color=Color3.fromRGB(20,20,20); bg.Transparency=0.5; bg.Visible=false
	local fg=Drawing.new("Line"); fg.Thickness=4; fg.Color=Color3.fromRGB(0,255,80); fg.Transparency=1; fg.Visible=false
	local txt=Drawing.new("Text"); txt.Size=11; txt.Font=2; txt.Color=Color3.fromRGB(255,255,255); txt.Outline=true; txt.Visible=false
	HealthBars[plr]={bg=bg,fg=fg,txt=txt}
end
local function updateHealthBar(plr,rgb)
	local char=plr.Character; if not char then clearHealthBar(plr); return end
	local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end
	local hp=hum.Health; local maxHP=math.max(hum.MaxHealth,1); local pct=math.clamp(hp/maxHP,0,1)
	local head=char:FindFirstChild("Head") or hrp
	local vH,onH=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,1.5,0))
	local vF,onF=Camera:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
	if not(onH and onF) then if HealthBars[plr] then HealthBars[plr].bg.Visible=false; HealthBars[plr].fg.Visible=false; HealthBars[plr].txt.Visible=false end; return end
	local sH=math.max(math.abs(vF.Y-vH.Y),10); local xB=vH.X-sH*0.28-8
	local yT=vH.Y; local yB=vF.Y; local yFill=yB-(yB-yT)*pct
	if not HealthBars[plr] then createHealthBar(plr) end
	local bar=HealthBars[plr]
	bar.bg.From=Vector2.new(xB,yT); bar.bg.To=Vector2.new(xB,yB); bar.bg.Visible=true
	bar.fg.From=Vector2.new(xB,yB); bar.fg.To=Vector2.new(xB,yFill); bar.fg.Color=ESP.RGB and rgb or healthToColor(pct); bar.fg.Visible=true
	bar.txt.Text=math.floor(hp).." HP"; bar.txt.Position=Vector2.new(xB-2,yT-14); bar.txt.Color=ESP.RGB and rgb or Color3.fromRGB(230,230,230); bar.txt.Visible=true
end

-- Skeleton
local Skeletons={}
local function getBones(char)
	local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return nil end
	if hum.RigType==Enum.HumanoidRigType.R6 then
		return {{"Head","Torso"},{"Torso","Left Arm"},{"Left Arm","Left Leg"},{"Torso","Right Arm"},{"Right Arm","Right Leg"}}
	end
	return {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
end
local function clearSkeleton(plr)
	if not Skeletons[plr] then return end
	for _,l in pairs(Skeletons[plr]) do pcall(function() l:Remove() end) end; Skeletons[plr]=nil
end
local function createSkeleton(plr,count)
	if Skeletons[plr] then return end; Skeletons[plr]={}
	for i=1,count do local l=Drawing.new("Line"); l.Thickness=1.5; l.Color=Color3.fromRGB(120,60,240); l.Visible=false; Skeletons[plr][i]=l end
end

-- Tracers
local Tracers={}
local function clearTracer(plr) if Tracers[plr] then pcall(function() Tracers[plr]:Remove() end); Tracers[plr]=nil end end
local function createTracer(plr)
	if Tracers[plr] then return end
	local l=Drawing.new("Line"); l.Thickness=1; l.Color=Color3.fromRGB(120,60,240); l.Visible=false; Tracers[plr]=l
end

-- Aimbot
local fovCircle; pcall(function()
	fovCircle=Drawing.new("Circle"); fovCircle.Thickness=1.5; fovCircle.Color=Color3.fromRGB(120,60,240)
	fovCircle.Filled=false; fovCircle.Transparency=1; fovCircle.NumSides=64; fovCircle.Visible=false
end)
if not fovCircle then fovCircle={Visible=false,Position=Vector2.new(0,0),Radius=150,Color=Color3.new(1,1,1)} end

local function getBestTarget()
	local best=nil; local bestD=math.huge; local myChar=LocalPlayer.Character; if not myChar then return nil end
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr==LocalPlayer then continue end
		if AIMBOT.TeamCheck and not isEnemy(plr) then continue end
		local char=plr.Character; if not char then continue end
		local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then continue end
		local part=char:FindFirstChild(AIMBOT.TargetPart) or char:FindFirstChild("HumanoidRootPart"); if not part then continue end
		local sp,on=Camera:WorldToViewportPoint(part.Position); if not on then continue end
		local d=screenDist(sp); if d>AIMBOT.FOVRadius then continue end
		if AIMBOT.VisCheck and not isVisible(plr) then continue end
		if d<bestD then bestD=d; best=plr end
	end
	return best
end
local function getPredictedPosition(char,part)
	if not AIMBOT.Prediction then return part.Position end
	local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return part.Position end
	local myHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local dist=myHRP and (myHRP.Position-part.Position).Magnitude or 100
	return part.Position+hrp.AssemblyLinearVelocity*(dist/1000)
end

local currentTarget=nil; local aimbotConn=nil
local function startAimbotLoop()
	if aimbotConn then return end
	aimbotConn=RunService.RenderStepped:Connect(function(dt)
		if AIMBOT.FOVCircle then local vp=Camera.ViewportSize; fovCircle.Position=Vector2.new(vp.X/2,vp.Y/2); fovCircle.Radius=AIMBOT.FOVRadius; fovCircle.Visible=true else fovCircle.Visible=false end
		if not AIMBOT.Enabled then currentTarget=nil; return end
		if AIMBOT.AimKey and not UserInputService:IsKeyDown(AIMBOT.AimKeyCode) then currentTarget=nil; return end
		local prev=currentTarget; local target=getBestTarget()
		if AIMBOT.TargetSwitch and prev then local ph=prev.Character and prev.Character:FindFirstChildOfClass("Humanoid"); if not ph or ph.Health<=0 then target=getBestTarget() end end
		currentTarget=target; if not target then return end
		local char=target.Character; if not char then return end
		if AIMBOT.MaxDist>0 then
			local mh=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); local th=char:FindFirstChild("HumanoidRootPart")
			if mh and th and (mh.Position-th.Position).Magnitude>AIMBOT.MaxDist then currentTarget=nil; return end
		end
		local part=char:FindFirstChild(AIMBOT.TargetPart) or char:FindFirstChild("HumanoidRootPart"); if not part then return end
		local aimPos=getPredictedPosition(char,part)
		if not AIMBOT.Silent then
			local shake=Vector3.new(0,0,0)
			if AIMBOT.AimShake then local t=tick(); local a=AIMBOT.ShakeAmt*0.01; shake=Vector3.new(math.sin(t*7.3)*a,math.cos(t*5.9)*a,0) end
			Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,aimPos+shake),math.clamp(dt*(21-AIMBOT.Smoothness),0,1))
		end
		if AIMBOT.AutoShoot then pcall(function() mouse1press() end) end
	end)
end
local function stopAimbotLoop() if aimbotConn then aimbotConn:Disconnect(); aimbotConn=nil end; fovCircle.Visible=false; currentTarget=nil end

local silentConn=nil
local function startSilentAim()
	if silentConn then return end
	silentConn=UserInputService.InputBegan:Connect(function(input,gpe)
		if gpe then return end
		if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		if not AIMBOT.Silent or not AIMBOT.Enabled then return end
		local t=getBestTarget(); if not t then return end
		local char=t.Character; if not char then return end
		local part=char:FindFirstChild(AIMBOT.TargetPart) or char:FindFirstChild("HumanoidRootPart"); if not part then return end
		local aimPos=getPredictedPosition(char,part); local saved=Camera.CFrame
		Camera.CFrame=CFrame.new(Camera.CFrame.Position,aimPos); task.defer(function() Camera.CFrame=saved end)
	end)
end
local function stopSilentAim() if silentConn then silentConn:Disconnect(); silentConn=nil end end

-- ESP Loop
local rgbHue=0
RunService.RenderStepped:Connect(function(dt)
	rgbHue=(rgbHue+dt*0.15)%1; local rgb=Color3.fromHSV(rgbHue,1,1)
	local myHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr==LocalPlayer then continue end
		local char=plr.Character; local isEn=isEnemy(plr)
		if not ESP.Enabled or not char or not isEn then clearESP(plr); clearSkeleton(plr); clearTracer(plr); clearHealthBar(plr); continue end
		-- Revalida: recria ESP se o Highlight foi destruido (respawn, etc)
		if not drawings[plr] or not drawings[plr].Highlight or not drawings[plr].Highlight.Parent then
			createESP(plr)
		end
		local d=drawings[plr]; if not d then continue end
		local ec=ESP.RGB and rgb or Color3.fromRGB(120,60,240)
		if d.Highlight and d.Highlight.Parent then d.Highlight.OutlineColor=ec; d.Highlight.FillColor=ESP.RGB and rgb or Color3.fromRGB(70,0,150) end
		if d.NameLabel then d.NameLabel.TextColor3=ESP.RGB and rgb or Color3.fromRGB(180,100,255) end
		if ESP.Distance and d.DistLabel then
			if myHRP and char:FindFirstChild("HumanoidRootPart") then
				d.DistLabel.Text=math.floor((myHRP.Position-char.HumanoidRootPart.Position).Magnitude).." studs"
				d.DistLabel.TextColor3=ESP.RGB and rgb or Color3.fromRGB(200,200,255); d.DistLabel.Visible=true
			end
		elseif d.DistLabel then d.DistLabel.Visible=false end
		if d.Billboard then d.Billboard.Enabled=ESP.Names or ESP.Distance end
		if ESP.HealthBar then updateHealthBar(plr,rgb) else clearHealthBar(plr) end
		local bones=getBones(char)
		if ESP.Skeleton and bones then
			if not Skeletons[plr] then createSkeleton(plr,#bones) end
			for i,b in ipairs(bones) do
				local p1=char:FindFirstChild(b[1]); local p2=char:FindFirstChild(b[2]); local line=Skeletons[plr] and Skeletons[plr][i]
				if p1 and p2 and line then
					local v1,o1=Camera:WorldToViewportPoint(p1.Position); local v2,o2=Camera:WorldToViewportPoint(p2.Position)
					if o1 and o2 then line.From=Vector2.new(v1.X,v1.Y); line.To=Vector2.new(v2.X,v2.Y); line.Color=ec; line.Visible=true else line.Visible=false end
				elseif line then line.Visible=false end
			end
		else clearSkeleton(plr) end
		local hrp=char:FindFirstChild("HumanoidRootPart")
		if ESP.Tracers and hrp then
			if not Tracers[plr] then createTracer(plr) end
			local v,on=Camera:WorldToViewportPoint(hrp.Position); local tr=Tracers[plr]
			if on and tr then local vp=Camera.ViewportSize; tr.From=Vector2.new(vp.X/2,vp.Y); tr.To=Vector2.new(v.X,v.Y); tr.Color=ec; tr.Visible=true elseif tr then tr.Visible=false end
		else clearTracer(plr) end
	end
	if ESP.Radar then updateRadar(rgb) end
	if ESP.VisionCone then updateVisionCones(rgb) end
end)

-- ============================================================
--  RADAR 2D - GUI-based (confiavel em todos os executores)
-- ============================================================
local RADAR_SIZE   = 160  -- tamanho do radar em px
local RADAR_RADIUS = 74   -- raio interno em px
local RADAR_RANGE  = 250  -- range em studs
local RADAR_POS_X  = 10   -- margem da borda esquerda
local RADAR_POS_Y  = 10   -- margem do topo

-- Container do radar no ScreenGui
local RadarGui = Instance.new("Frame")
RadarGui.Name = "PurityRadar"
RadarGui.Size = UDim2.new(0, RADAR_SIZE, 0, RADAR_SIZE)
RadarGui.Position = UDim2.new(0, RADAR_POS_X, 0, RADAR_POS_Y)
RadarGui.BackgroundColor3 = Color3.fromRGB(8, 6, 14)
RadarGui.BackgroundTransparency = 0.25
RadarGui.BorderSizePixel = 0
RadarGui.ZIndex = 990
RadarGui.Visible = false
RadarGui.Parent = ScreenGui
Instance.new("UICorner", RadarGui).CornerRadius = UDim.new(1, 0)
local RadarStroke = Instance.new("UIStroke", RadarGui)
RadarStroke.Color = Color3.fromRGB(110, 50, 230)
RadarStroke.Thickness = 1.5

-- Ponto central (voce)
local RadarSelf = Instance.new("Frame", RadarGui)
RadarSelf.Size = UDim2.new(0, 6, 0, 6)
RadarSelf.Position = UDim2.new(0.5, -3, 0.5, -3)
RadarSelf.BackgroundColor3 = Color3.fromRGB(100, 220, 255)
RadarSelf.BorderSizePixel = 0
RadarSelf.ZIndex = 993
Instance.new("UICorner", RadarSelf).CornerRadius = UDim.new(1, 0)

-- Cruz de referencia
local function makeRadarLine(isHorz)
	local l = Instance.new("Frame", RadarGui)
	if isHorz then
		l.Size = UDim2.new(1, -20, 0, 1)
		l.Position = UDim2.new(0, 10, 0.5, 0)
	else
		l.Size = UDim2.new(0, 1, 1, -20)
		l.Position = UDim2.new(0.5, 0, 0, 10)
	end
	l.BackgroundColor3 = Color3.fromRGB(60, 50, 90)
	l.BackgroundTransparency = 0.4
	l.BorderSizePixel = 0
	l.ZIndex = 991
end
makeRadarLine(true); makeRadarLine(false)

-- Label "N" no topo indicando norte
local RadarN = Instance.new("TextLabel", RadarGui)
RadarN.Size = UDim2.new(0, 14, 0, 14)
RadarN.Position = UDim2.new(0.5, -7, 0, 4)
RadarN.BackgroundTransparency = 1
RadarN.Text = "N"
RadarN.TextColor3 = Color3.fromRGB(200, 180, 255)
RadarN.Font = Enum.Font.GothamBold
RadarN.TextSize = 9
RadarN.ZIndex = 994

-- Dots dos inimigos
local radarDots = {}

local function getOrMakeRadarDot(plr)
	if radarDots[plr] and radarDots[plr].Parent then return radarDots[plr] end
	local dot = Instance.new("Frame", RadarGui)
	dot.Size = UDim2.new(0, 7, 0, 7)
	dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	dot.BorderSizePixel = 0
	dot.ZIndex = 995
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	radarDots[plr] = dot
	return dot
end

local function clearRadarDot(plr)
	if radarDots[plr] then
		pcall(function() radarDots[plr]:Destroy() end)
		radarDots[plr] = nil
	end
end

function updateRadar(rgb)
	local myChar = LocalPlayer.Character
	local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local tc = ESP.RGB and rgb or C.accent
	RadarStroke.Color = tc

	if not myHRP then return end

	local cl = Camera.CFrame.LookVector
	local cy = math.atan2(cl.X, cl.Z)
	local center = RADAR_SIZE / 2

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		local char = plr.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")

		if not hrp or not isEnemy(plr) then
			clearRadarDot(plr); continue
		end

		local dx = hrp.Position.X - myHRP.Position.X
		local dz = hrp.Position.Z - myHRP.Position.Z

		-- Rotaciona relativo a camera
		local rx =  dx * math.cos(cy) - dz * math.sin(cy)
		local ry =  dx * math.sin(cy) + dz * math.cos(cy)

		local dist = math.sqrt(rx*rx + ry*ry)
		local scale = math.min(dist / RADAR_RANGE, 1)

		local fx, fy
		if dist > 0.01 then
			fx = (rx / dist) * scale * RADAR_RADIUS
			fy = (ry / dist) * scale * RADAR_RADIUS
		else
			fx, fy = 0, 0
		end

		local dot = getOrMakeRadarDot(plr)
		dot.Position = UDim2.new(0, center + fx - 3, 0, center + fy - 3)
		dot.BackgroundColor3 = ESP.RGB and rgb or Color3.fromRGB(255, 60, 60)
		dot.Visible = true
	end
end

local function hideRadar()
	RadarGui.Visible = false
	for _, plr in ipairs(Players:GetPlayers()) do clearRadarDot(plr) end
end

-- Vision Cone
local VisionCones={}; local CONE_LEN=40; local CONE_ANGLE=30
local function clearVisionCone(plr)
	if not VisionCones[plr] then return end
	for _,l in pairs(VisionCones[plr]) do pcall(function() l:Remove() end) end; VisionCones[plr]=nil
end
local function createVisionCone(plr)
	if VisionCones[plr] then return end; VisionCones[plr]={}
	for i=1,3 do local l=Drawing.new("Line"); l.Thickness=1.2; l.Color=Color3.fromRGB(255,200,0); l.Transparency=1; l.Visible=false; VisionCones[plr][i]=l end
end
function updateVisionCones(rgb)
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr==LocalPlayer then continue end
		local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local head=char and char:FindFirstChild("Head")
		if not ESP.Enabled or not hrp or not head or not isEnemy(plr) then clearVisionCone(plr); continue end
		local vH,onH=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,0.5,0)); if not onH then clearVisionCone(plr); continue end
		local vT,_=Camera:WorldToViewportPoint(head.Position+hrp.CFrame.LookVector*4)
		local b2=Vector2.new(vH.X,vH.Y); local t2=Vector2.new(vT.X,vT.Y)
		local dir=t2-b2; if dir.Magnitude<1 then clearVisionCone(plr); continue end
		dir=dir.Unit*CONE_LEN; local tipPt=b2+dir
		local rad=math.rad(CONE_ANGLE); local ca=math.cos(rad); local sa=math.sin(rad)
		local eL=b2+Vector2.new(dir.X*ca-dir.Y*sa,dir.X*sa+dir.Y*ca)
		local eR=b2+Vector2.new(dir.X*ca+dir.Y*sa,-dir.X*sa+dir.Y*ca)
		if not VisionCones[plr] then createVisionCone(plr) end
		local vc=VisionCones[plr]; local c=ESP.RGB and rgb or Color3.fromRGB(255,200,0)
		vc[1].From=b2; vc[1].To=tipPt; vc[1].Color=c; vc[1].Visible=true
		vc[2].From=b2; vc[2].To=eL; vc[2].Color=c; vc[2].Visible=true
		vc[3].From=b2; vc[3].To=eR; vc[3].Color=c; vc[3].Visible=true
	end
end

Players.PlayerRemoving:Connect(function(plr) clearESP(plr); clearSkeleton(plr); clearTracer(plr); clearHealthBar(plr); clearRadarDot(plr); clearVisionCone(plr) end)
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		char:WaitForChild("HumanoidRootPart",5)
		task.wait(0.2)
		if ESP.Enabled and isEnemy(plr) then createESP(plr) end
	end)
end)
-- Hook para jogadores ja na partida (CharacterAdded perdido antes do script)
for _,plr in ipairs(Players:GetPlayers()) do
	if plr~=LocalPlayer then
		plr.CharacterAdded:Connect(function(char)
			char:WaitForChild("HumanoidRootPart",5)
			task.wait(0.2)
			if ESP.Enabled and isEnemy(plr) then createESP(plr) end
		end)
	end
end
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(refreshAllESP)

-- Callbacks ESP
local function onESPToggle(s) ESP.Enabled=s; if not s then for _,p in ipairs(Players:GetPlayers()) do clearESP(p); clearSkeleton(p); clearTracer(p); clearHealthBar(p) end else refreshAllESP() end end
local function onRGBToggle(s) ESP.RGB=s end
local function onBoxToggle(s) ESP.Box=s; applyBoxVisibility() end
local function onSkeletonToggle(s) ESP.Skeleton=s; if not s then for _,p in ipairs(Players:GetPlayers()) do clearSkeleton(p) end end end
local function onNameESPToggle(s) ESP.Names=s; applyNameVisibility() end
local function onDistanceToggle(s) ESP.Distance=s; applyDistVisibility() end
local function onHealthBarToggle(s) ESP.HealthBar=s; if not s then for _,p in ipairs(Players:GetPlayers()) do clearHealthBar(p) end end end
local function onTracelinesToggle(s) ESP.Tracers=s; if not s then for _,p in ipairs(Players:GetPlayers()) do clearTracer(p) end end end
local function onRadarToggle(s) ESP.Radar=s; if s then RadarGui.Visible=true else hideRadar() end end
local function onVisionConeToggle(s) ESP.VisionCone=s; if not s then for _,p in ipairs(Players:GetPlayers()) do clearVisionCone(p) end end end

-- Callbacks Aimbot
local function onAimbotToggle(s) AIMBOT.Enabled=s; if s then startAimbotLoop() end end
local function onSilentAimToggle(s) AIMBOT.Silent=s; if s then startSilentAim() else stopSilentAim() end end
local function onPredictionToggle(s) AIMBOT.Prediction=s end
local function onFOVCircleToggle(s) AIMBOT.FOVCircle=s; if s then startAimbotLoop() else fovCircle.Visible=false end end
local function onTeamCheckToggle(s) AIMBOT.TeamCheck=s end
local function onVisCheckToggle(s) AIMBOT.VisCheck=s end
local function onAutoShootToggle(s) AIMBOT.AutoShoot=s end
local function onFOVChange(v) AIMBOT.FOVRadius=v; fovCircle.Radius=v end
local function onSmoothnessChange(v) AIMBOT.Smoothness=v end
local function onTargetPartHead() AIMBOT.TargetPart="Head" end
local function onTargetPartTorso() AIMBOT.TargetPart="HumanoidRootPart" end
local function onAimKeyToggle(s) AIMBOT.AimKey=s end
local function onTargetSwitchToggle(s) AIMBOT.TargetSwitch=s end
local function onAimShakeToggle(s) AIMBOT.AimShake=s end
local function onMaxDistChange(v) AIMBOT.MaxDist=v end
local function onShakeAmtChange(v) AIMBOT.ShakeAmt=v end

-- Callbacks Combat
local lastCamCF=nil
local function onNoRecoilToggle(s)
	COMBAT.NoRecoil=s
	if s then
		combatConns.nr1=RunService.RenderStepped:Connect(function() if COMBAT.NoRecoil then lastCamCF=Camera.CFrame end end)
		combatConns.nr2=RunService.Stepped:Connect(function()
			if not COMBAT.NoRecoil or not lastCamCF then return end
			local cur=Camera.CFrame; local _,cy,_=cur:ToEulerAnglesYXZ(); local _,oy,_=lastCamCF:ToEulerAnglesYXZ()
			if math.abs(cy-oy)<0.002 then Camera.CFrame=CFrame.new(cur.Position)*CFrame.fromEulerAnglesYXZ(0,cy,0)*CFrame.fromEulerAnglesYXZ(select(1,lastCamCF:ToEulerAnglesYXZ()),0,0) end
		end)
	else
		if combatConns.nr1 then combatConns.nr1:Disconnect(); combatConns.nr1=nil end
		if combatConns.nr2 then combatConns.nr2:Disconnect(); combatConns.nr2=nil end; lastCamCF=nil
	end
end
local noSpreadSaved=nil
local function onNoSpreadToggle(s)
	COMBAT.NoSpread=s
	if s then
		combatConns.ns1=UserInputService.InputBegan:Connect(function(i,g) if not g and i.UserInputType==Enum.UserInputType.MouseButton1 then noSpreadSaved=Camera.CFrame end end)
		combatConns.ns2=UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then noSpreadSaved=nil end end)
		combatConns.ns3=RunService.RenderStepped:Connect(function() if COMBAT.NoSpread and noSpreadSaved then Camera.CFrame=noSpreadSaved end end)
	else
		for _,k in ipairs({"ns1","ns2","ns3"}) do if combatConns[k] then combatConns[k]:Disconnect(); combatConns[k]=nil end end; noSpreadSaved=nil
	end
end
local rapidConn=nil
local function applyRapidFire()
	if rapidConn then rapidConn:Disconnect(); rapidConn=nil end
	if not COMBAT.RapidFire then return end
	rapidConn=UserInputService.InputBegan:Connect(function(i,g)
		if g then return end
		if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		for _=1,math.max(COMBAT.FireRateMult-1,0) do pcall(function() mouse1click() end) end
	end)
end
local function onRapidFireToggle(s) COMBAT.RapidFire=s; applyRapidFire() end
local infiniteAmmoConn=nil; local infiniteAmmoCharConn=nil
local function hookAmmo(tool)
	if infiniteAmmoConn then infiniteAmmoConn:Disconnect(); infiniteAmmoConn=nil end
	if not tool or not COMBAT.InfiniteAmmo then return end
	for _,cfg in ipairs({tool:FindFirstChild("AmmoInClip"),tool:FindFirstChild("Ammo"),tool:FindFirstChild("CurrentAmmo")}) do
		if cfg and (cfg:IsA("NumberValue") or cfg:IsA("IntValue")) then
			local mv=cfg.Value; infiniteAmmoConn=cfg.Changed:Connect(function(v) if COMBAT.InfiniteAmmo and v<mv then cfg.Value=mv end end); break
		end
	end
end
local function onInfiniteAmmoToggle(s)
	COMBAT.InfiniteAmmo=s
	if s then
		local char=LocalPlayer.Character; if char then hookAmmo(char:FindFirstChildOfClass("Tool")) end
		infiniteAmmoCharConn=LocalPlayer.CharacterAdded:Connect(function(c) c.ChildAdded:Connect(function(ch) if ch:IsA("Tool") and COMBAT.InfiniteAmmo then hookAmmo(ch) end end) end)
		if LocalPlayer.Character then LocalPlayer.Character.ChildAdded:Connect(function(ch) if ch:IsA("Tool") and COMBAT.InfiniteAmmo then hookAmmo(ch) end end) end
	else
		if infiniteAmmoConn then infiniteAmmoConn:Disconnect(); infiniteAmmoConn=nil end
		if infiniteAmmoCharConn then infiniteAmmoCharConn:Disconnect(); infiniteAmmoCharConn=nil end
	end
end
local bhopConn=nil
local function onBunnyHopToggle(s)
	COMBAT.BunnyHop=s
	if s then bhopConn=RunService.Heartbeat:Connect(function()
		if not COMBAT.BunnyHop then return end
		local char=LocalPlayer.Character; if not char then return end
		local hum=char:FindFirstChildOfClass("Humanoid")
		if hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum:GetState()==Enum.HumanoidStateType.Landed then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end) else if bhopConn then bhopConn:Disconnect(); bhopConn=nil end end
end
local fastReloadConn=nil
local function applyFastReload(char)
	if fastReloadConn then fastReloadConn:Disconnect(); fastReloadConn=nil end
	if not char or not COMBAT.FastReload then return end
	local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
	local anim=hum:FindFirstChildOfClass("Animator"); if not anim then return end
	fastReloadConn=anim.AnimationPlayed:Connect(function(tr) local n=tr.Name:lower(); if n:find("reload") or n:find("recarg") then tr:AdjustSpeed(COMBAT.ReloadSpeed) end end)
end
local function onFastReloadToggle(s)
	COMBAT.FastReload=s
	if s then applyFastReload(LocalPlayer.Character); LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.5); if COMBAT.FastReload then applyFastReload(c) end end)
	else if fastReloadConn then fastReloadConn:Disconnect(); fastReloadConn=nil end end
end
local function onFireRateChange(v) COMBAT.FireRateMult=v; if COMBAT.RapidFire then applyRapidFire() end end
local function onReloadSpeedChange(v) COMBAT.ReloadSpeed=v end
local antiRagdollConn=nil
local function onAntiRagdollToggle(s)
	COMBAT.AntiRagdoll=s
	if s then antiRagdollConn=RunService.Stepped:Connect(function()
		if not COMBAT.AntiRagdoll then return end
		local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end
		if hum:GetState()==Enum.HumanoidStateType.FallingDown or hum:GetState()==Enum.HumanoidStateType.Ragdoll then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
	end) else if antiRagdollConn then antiRagdollConn:Disconnect(); antiRagdollConn=nil end end
end
local flyConn=nil; local flyBV=nil
local function onFlyHackToggle(s)
	COMBAT.FlyHack=s
	if s then
		local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end; hum.PlatformStand=true
		flyBV=Instance.new("BodyVelocity",hrp); flyBV.Velocity=Vector3.new(0,0,0); flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
		flyConn=RunService.Heartbeat:Connect(function()
			if not COMBAT.FlyHack then return end
			local cf=Camera.CFrame; local vel=Vector3.new(0,0,0); local spd=COMBAT.FlySpeed
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector*spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector*spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector*spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector*spd end
			if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel=vel+Vector3.new(0,spd,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vel=vel-Vector3.new(0,spd,0) end
			if flyBV and flyBV.Parent then flyBV.Velocity=vel end
		end)
	else
		if flyConn then flyConn:Disconnect(); flyConn=nil end
		if flyBV and flyBV.Parent then flyBV:Destroy(); flyBV=nil end
		local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
	end
end
local function onFlySpeedChange(v) COMBAT.FlySpeed=v end
local function applySpeed() local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=COMBAT.SpeedHack and COMBAT.WalkSpeed or 16 end end
local function onSpeedHackToggle(s) COMBAT.SpeedHack=s; applySpeed(); if s then LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); if COMBAT.SpeedHack then applySpeed() end end) end end
local function onWalkSpeedChange(v) COMBAT.WalkSpeed=v; if COMBAT.SpeedHack then applySpeed() end end
local function applyJump() local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower=COMBAT.JumpPower and COMBAT.JumpPowerVal or 50 end end
local function onJumpPowerToggle(s) COMBAT.JumpPower=s; applyJump() end
local function onJumpPowerChange(v) COMBAT.JumpPowerVal=v; if COMBAT.JumpPower then applyJump() end end
local infJumpConn=nil
local function onInfiniteJumpToggle(s)
	COMBAT.InfiniteJump=s
	if s then infJumpConn=UserInputService.JumpRequest:Connect(function()
		if not COMBAT.InfiniteJump then return end
		local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end) else if infJumpConn then infJumpConn:Disconnect(); infJumpConn=nil end end
end

-- Callbacks Misc
local function onCustomFOVToggle(s) MISC.CustomFOV=s; if s then originalFOV=Camera.FieldOfView; Camera.FieldOfView=MISC.FOVValue else Camera.FieldOfView=originalFOV end end
local function onFOVValueChange(v) MISC.FOVValue=v; if MISC.CustomFOV then Camera.FieldOfView=v end end
local spinConn=nil
local function onSpinBotToggle(s)
	MISC.SpinBot=s
	if s then spinConn=RunService.Heartbeat:Connect(function(dt)
		if not MISC.SpinBot then return end
		local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(360*MISC.SpinSpeed*dt),0) end
	end) else if spinConn then spinConn:Disconnect(); spinConn=nil end end
end
local function onSpinSpeedChange(v) MISC.SpinSpeed=v end

-- ============================================================
--  BIG HEAD v3 - RenderStepped client-side
--  Altera head.Size no RenderStepped (so roda no client,
--  nao replica pro servidor = sem travar inimigos).
--  Hitbox e visual crescem juntos, so voce ve/sente o efeito.
-- ============================================================

-- originalHeads: [char] = Vector3 tamanho original da head
local function restoreHeads()
	for char, origSize in pairs(originalHeads) do
		local head = char:FindFirstChild("Head")
		if head then pcall(function() head.Size = origSize end) end
	end
	originalHeads = {}
end

local bigHeadConn = nil

local function startBigHeadLoop()
	if bigHeadConn then return end
	-- RenderStepped: executa antes do render, apenas no client.
	-- Alteracoes de CFrame/Size feitas aqui NAO sao replicadas ao servidor,
	-- entao os outros jogadores nao veem e a fisica deles nao e afetada.
	bigHeadConn = RunService.RenderStepped:Connect(function()
		if not MISC.BigHead then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == LocalPlayer then continue end
			local char = plr.Character
			if not char then continue end
			local head = char:FindFirstChild("Head")
			if not head then continue end

			local isAlly = LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team
			if isAlly then
				-- Restaura aliado se tiver sido escalonado antes
				if originalHeads[char] then
					pcall(function() head.Size = originalHeads[char] end)
					originalHeads[char] = nil
				end
			else
				-- Salva tamanho original uma unica vez por char
				if not originalHeads[char] then
					originalHeads[char] = head.Size
				end
				-- Aplica escala desejada a cada frame (garante que nao reverta)
				local target = originalHeads[char] * MISC.BigHeadScale
				pcall(function() head.Size = target end)
			end
		end
	end)
end

local function stopBigHeadLoop()
	if bigHeadConn then bigHeadConn:Disconnect(); bigHeadConn = nil end
end

local function onBigHeadToggle(s)
	MISC.BigHead = s
	if s then
		startBigHeadLoop()
	else
		stopBigHeadLoop()
		restoreHeads()
	end
end

local function onBigHeadScaleChange(v)
	MISC.BigHeadScale = v
	if not MISC.BigHead then return end
	-- Aplica novo scale imediatamente nos chars ja cacheados
	for char, origSize in pairs(originalHeads) do
		local head = char:FindFirstChild("Head")
		if head then pcall(function() head.Size = origSize * v end) end
	end
end

local noclipConn=nil
local function onNoclipToggle(s)
	MISC.Noclip=s
	if s then noclipConn=RunService.Stepped:Connect(function()
		if not MISC.Noclip then return end
		local char=LocalPlayer.Character; if not char then return end
		for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
	end) else
		if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
		local char=LocalPlayer.Character; if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
	end
end
local wallBangConn=nil
local wallBangCache={}

local function onWallBangToggle(s)
	MISC.WallBang=s
	if s then
		AIMBOT.VisCheck=false
		if wallBangConn then wallBangConn:Disconnect() end
		wallBangCache={}
		wallBangConn=RunService.Heartbeat:Connect(function()
			if not MISC.WallBang then return end
			for _,obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and not wallBangCache[obj] then
					wallBangCache[obj]=true
					local isCharPart=false
					for _,plr in ipairs(Players:GetPlayers()) do
						if plr.Character and obj:IsDescendantOf(plr.Character) then
							isCharPart=true; break
						end
					end
					if not isCharPart then
						local nm=obj.Name:lower()
						local isSmall=(obj.Size.Magnitude < 4)
						local hasName=nm:find("bullet") or nm:find("proj") or nm:find("pellet")
							or nm:find("shot") or nm:find("ball") or nm:find("rocket")
							or nm:find("grenade") or nm:find("ammo") or nm:find("fire")
						if isSmall or hasName then
							pcall(function() obj.CanCollide=false end)
						end
					end
				end
			end
		end)
	else
		if wallBangConn then wallBangConn:Disconnect(); wallBangConn=nil end
		wallBangCache={}
	end
end
local afkConn=nil
local function onAntiAFKToggle(s)
	MISC.AntiAFK=s
	if s then afkConn=RunService.Heartbeat:Connect(function()
		if not MISC.AntiAFK then return end
		if math.floor(tick())%55==0 then
			local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.CFrame=hrp.CFrame*CFrame.new(0,0.001,0) end
			pcall(function() VirtualUser:CaptureController() end); pcall(function() VirtualUser:ClickButton2(Vector2.new()) end)
		end
	end) else if afkConn then afkConn:Disconnect(); afkConn=nil end end
end
local function onTimeOfDayToggle(s) MISC.TimeOfDay=s; if s then Lighting.ClockTime=MISC.TimeValue end end
local function onTimeOfDayChange(v) MISC.TimeValue=v; if MISC.TimeOfDay then Lighting.ClockTime=v end end

-- Config/Temas
local CONFIG={Notifications=true,Opacity=1.0,Theme="roxo",Watermark=true,Particles=true}

-- ── Watermark (FPS + Ping + Versao) ──
local WatermarkFrame=nil; local WatermarkStroke=nil; local WatermarkDot=nil
task.defer(function()
	WatermarkFrame=Instance.new("Frame",ScreenGui)
	WatermarkFrame.Size=UDim2.new(0,210,0,28)
	WatermarkFrame.Position=UDim2.new(1,-218,0,8)
	WatermarkFrame.BackgroundColor3=Color3.fromRGB(13,13,18)
	WatermarkFrame.BorderSizePixel=0
	WatermarkFrame.ZIndex=999
	WatermarkFrame.Visible=CONFIG.Watermark
	Instance.new("UICorner",WatermarkFrame).CornerRadius=UDim.new(0,7)
	WatermarkStroke=Instance.new("UIStroke",WatermarkFrame)
	WatermarkStroke.Color=Color3.fromRGB(110,50,230)
	WatermarkStroke.Thickness=1

	WatermarkDot=Instance.new("Frame",WatermarkFrame)
	WatermarkDot.Size=UDim2.new(0,6,0,6)
	WatermarkDot.Position=UDim2.new(0,8,0.5,-3)
	WatermarkDot.BackgroundColor3=Color3.fromRGB(145,85,255)
	WatermarkDot.BorderSizePixel=0
	Instance.new("UICorner",WatermarkDot).CornerRadius=UDim.new(1,0)

	local wLbl=Instance.new("TextLabel",WatermarkFrame)
	wLbl.Name="WatermarkLbl"
	wLbl.Size=UDim2.new(1,-18,1,0)
	wLbl.Position=UDim2.new(0,18,0,0)
	wLbl.BackgroundTransparency=1
	wLbl.Text="Purity v7.0"
	wLbl.TextColor3=Color3.fromRGB(238,232,255)
	wLbl.Font=Enum.Font.GothamBold
	wLbl.TextSize=11
	wLbl.TextXAlignment=Enum.TextXAlignment.Left

	-- Atualiza FPS e ping a cada segundo
	local lastTime=tick()
	local frameCount=0
	RunService.RenderStepped:Connect(function()
		frameCount=frameCount+1
		local now=tick()
		if now-lastTime>=1 then
			local fps=math.floor(frameCount/(now-lastTime))
			local ping=math.floor(LocalPlayer:GetNetworkPing()*1000)
			wLbl.Text=string.format("Purity v7.0  |  %d FPS  |  %dms",fps,ping)
			frameCount=0; lastTime=now
		end
	end)
end)
local THEMES={
	roxo     ={border=Color3.fromRGB(110,30,200),neon=Color3.fromRGB(155,40,240),neonBright=Color3.fromRGB(190,70,255)},
	azul     ={border=Color3.fromRGB(30,80,220), neon=Color3.fromRGB(40,120,255),neonBright=Color3.fromRGB(80,160,255)},
	vermelho ={border=Color3.fromRGB(180,20,50), neon=Color3.fromRGB(220,40,70), neonBright=Color3.fromRGB(255,70,100)},
	verde    ={border=Color3.fromRGB(20,150,60), neon=Color3.fromRGB(30,200,80), neonBright=Color3.fromRGB(60,255,120)},
	laranja  ={border=Color3.fromRGB(180,80,10), neon=Color3.fromRGB(220,110,20),neonBright=Color3.fromRGB(255,150,40)},
	ciano    ={border=Color3.fromRGB(10,140,180),neon=Color3.fromRGB(20,180,220),neonBright=Color3.fromRGB(50,220,255)},
	rosa     ={border=Color3.fromRGB(180,20,120),neon=Color3.fromRGB(220,40,160),neonBright=Color3.fromRGB(255,80,200)},
	branco   ={border=Color3.fromRGB(160,160,180),neon=Color3.fromRGB(200,200,220),neonBright=Color3.fromRGB(240,240,255)},
}

-- Paleta
local C={
	window=Color3.fromRGB(15,15,20), sidebar=Color3.fromRGB(11,11,16), content=Color3.fromRGB(20,20,26),
	card=Color3.fromRGB(26,26,34), cardHover=Color3.fromRGB(34,32,44), cardActive=Color3.fromRGB(34,20,55),
	header=Color3.fromRGB(13,13,18), accent=Color3.fromRGB(110,50,230), accentLight=Color3.fromRGB(145,85,255),
	accentGlow=Color3.fromRGB(80,30,180), green=Color3.fromRGB(0,205,95), greenDim=Color3.fromRGB(0,130,65),
	red=Color3.fromRGB(215,45,75), textPrim=Color3.fromRGB(238,232,255), textSec=Color3.fromRGB(148,138,180),
	textDim=Color3.fromRGB(85,78,110), border=Color3.fromRGB(36,32,54), borderLight=Color3.fromRGB(58,48,86),
	sliderTrack=Color3.fromRGB(34,30,52), sliderKnob=Color3.fromRGB(195,155,255),
	dropBG=Color3.fromRGB(18,14,30), dropItem=Color3.fromRGB(28,22,44), dropItemHov=Color3.fromRGB(44,34,70),
	white=Color3.fromRGB(255,255,255),
}

local TW=TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local TW_SLOW=TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

-- Screen GUI
local ScreenGui=Instance.new("ScreenGui"); ScreenGui.Name="PurityGUI"; ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ScreenGui.DisplayOrder=999; ScreenGui.IgnoreGuiInset=true
ScreenGui.Parent=PlayerGui; _screenGuiRef=ScreenGui

local WIN_W,WIN_H=620,430
local Main=Instance.new("Frame"); Main.Name="Main"; Main.Size=UDim2.new(0,WIN_W,0,WIN_H)
Main.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2); Main.BackgroundColor3=C.window; Main.BorderSizePixel=0
Main.ZIndex=2; Main.ClipsDescendants=true; Main.Parent=ScreenGui
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,12)
local MainStroke=Instance.new("UIStroke",Main); MainStroke.Color=C.border; MainStroke.Thickness=1.2

-- ============================================================
--  PARTICULAS DE FUNDO v3 - Estrelinhas
--  Contidas dentro do menu usando clipping por posicao absoluta.
-- ============================================================
local PARTICLE_COUNT = 35
local particles = {}
local particleConn = nil

local WIN_W_P = 620
local WIN_H_P = 430

local function createParticle()
	-- Tamanho de estrela: 1 a 3px
	local size = math.random(1, 3)
	local p = Instance.new("Frame", ScreenGui)
	p.Size = UDim2.new(0, size, 0, size)
	p.BackgroundTransparency = math.random(10, 45) / 100
	p.BackgroundColor3 = C.accentLight
	p.BorderSizePixel = 0
	p.ZIndex = 998
	p.Visible = true
	Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

	local data = {
		frame = p,
		x     = math.random(2, WIN_W_P - 4),
		y     = math.random(2, WIN_H_P - 4),
		vx    = (math.random() - 0.5) * 22,
		vy    = (math.random() - 0.5) * 22,
		size  = size,
	}
	return data
end

local function startParticles()
	if particleConn then return end
	particleConn = RunService.RenderStepped:Connect(function(dt)
		if not CONFIG.Particles then return end
		local winX = Main.AbsolutePosition.X
		local winY = Main.AbsolutePosition.Y
		local col  = C.accentLight
		for _, d in ipairs(particles) do
			d.x = d.x + d.vx * dt
			d.y = d.y + d.vy * dt

			-- Rebate nas bordas INTERNAS do menu
			if d.x < 2 then
				d.x = 2; d.vx = math.abs(d.vx)
			elseif d.x > WIN_W_P - d.size - 2 then
				d.x = WIN_W_P - d.size - 2; d.vx = -math.abs(d.vx)
			end
			if d.y < 2 then
				d.y = 2; d.vy = math.abs(d.vy)
			elseif d.y > WIN_H_P - d.size - 2 then
				d.y = WIN_H_P - d.size - 2; d.vy = -math.abs(d.vy)
			end

			pcall(function()
				d.frame.Position = UDim2.new(0, winX + d.x, 0, winY + d.y)
				d.frame.BackgroundColor3 = col
			end)
		end
	end)
end

local function stopParticles()
	if particleConn then particleConn:Disconnect(); particleConn = nil end
	for _, d in ipairs(particles) do pcall(function() d.frame.Visible = false end) end
end

local function setParticlesVisible(v)
	for _, d in ipairs(particles) do pcall(function() d.frame.Visible = v end) end
end

task.defer(function()
	for i = 1, PARTICLE_COUNT do
		particles[i] = createParticle()
	end
	-- Posiciona todas antes de iniciar o loop
	local winX = Main.AbsolutePosition.X
	local winY = Main.AbsolutePosition.Y
	for _, d in ipairs(particles) do
		d.frame.Position = UDim2.new(0, winX + d.x, 0, winY + d.y)
	end
	startParticles()
end)


-- Header
local Header=Instance.new("Frame"); Header.Size=UDim2.new(1,0,0,46); Header.BackgroundColor3=C.header
Header.BorderSizePixel=0; Header.ZIndex=3; Header.Parent=Main
Instance.new("UICorner",Header).CornerRadius=UDim.new(0,12)
local HFix=Instance.new("Frame",Header); HFix.Size=UDim2.new(1,0,0,12); HFix.Position=UDim2.new(0,0,1,-12); HFix.BackgroundColor3=C.header; HFix.BorderSizePixel=0; HFix.ZIndex=3
local HDivider=Instance.new("Frame",Header); HDivider.Size=UDim2.new(1,0,0,1); HDivider.Position=UDim2.new(0,0,1,0); HDivider.BackgroundColor3=C.border; HDivider.BorderSizePixel=0; HDivider.ZIndex=4
local LogoDot=Instance.new("Frame",Header); LogoDot.Size=UDim2.new(0,9,0,9); LogoDot.Position=UDim2.new(0,15,0.5,-4.5); LogoDot.BackgroundColor3=C.accentLight; LogoDot.BorderSizePixel=0; LogoDot.ZIndex=5; Instance.new("UICorner",LogoDot).CornerRadius=UDim.new(1,0)
local TitleLbl=Instance.new("TextLabel",Header); TitleLbl.Size=UDim2.new(0,90,0,22); TitleLbl.Position=UDim2.new(0,32,0.5,-11); TitleLbl.BackgroundTransparency=1; TitleLbl.Text="PURITY"; TitleLbl.TextColor3=C.textPrim; TitleLbl.Font=Enum.Font.GothamBold; TitleLbl.TextSize=17; TitleLbl.TextXAlignment=Enum.TextXAlignment.Left; TitleLbl.ZIndex=5
local VerBadge=Instance.new("TextLabel",Header); VerBadge.Size=UDim2.new(0,36,0,16); VerBadge.Position=UDim2.new(0,126,0.5,-8); VerBadge.BackgroundColor3=C.accentGlow; VerBadge.Text="v7.0"; VerBadge.TextColor3=C.accentLight; VerBadge.Font=Enum.Font.GothamBold; VerBadge.TextSize=10; VerBadge.ZIndex=5; VerBadge.Parent=Header; Instance.new("UICorner",VerBadge).CornerRadius=UDim.new(0,4)
local CloseBtn=Instance.new("TextButton",Header); CloseBtn.Size=UDim2.new(0,26,0,26); CloseBtn.Position=UDim2.new(1,-36,0.5,-13); CloseBtn.BackgroundColor3=Color3.fromRGB(48,26,30); CloseBtn.BorderSizePixel=0; CloseBtn.Text=""; CloseBtn.ZIndex=6; Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(1,0)
local CloseStroke=Instance.new("UIStroke",CloseBtn); CloseStroke.Color=Color3.fromRGB(76,26,38); CloseStroke.Thickness=1
local CloseX=Instance.new("TextLabel",CloseBtn); CloseX.Size=UDim2.new(1,0,1,0); CloseX.BackgroundTransparency=1; CloseX.Text="X"; CloseX.TextColor3=Color3.fromRGB(195,75,95); CloseX.Font=Enum.Font.GothamBold; CloseX.TextSize=11; CloseX.ZIndex=7
local MinBtn=Instance.new("TextButton",Header); MinBtn.Size=UDim2.new(0,26,0,26); MinBtn.Position=UDim2.new(1,-68,0.5,-13); MinBtn.BackgroundColor3=Color3.fromRGB(28,28,46); MinBtn.BorderSizePixel=0; MinBtn.Text=""; MinBtn.ZIndex=6; Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(1,0); Instance.new("UIStroke",MinBtn).Color=C.borderLight
local MinX=Instance.new("TextLabel",MinBtn); MinX.Size=UDim2.new(1,0,1,0); MinX.BackgroundTransparency=1; MinX.Text="-"; MinX.TextColor3=C.textSec; MinX.Font=Enum.Font.GothamBold; MinX.TextSize=14; MinX.ZIndex=7

-- Sidebar
local SIDEBAR_W=155
local Sidebar=Instance.new("Frame",Main)
Sidebar.Name="Sidebar"
Sidebar.Size=UDim2.new(0,SIDEBAR_W,1,-46)
Sidebar.Position=UDim2.new(0,0,0,46)
Sidebar.BackgroundColor3=C.sidebar
Sidebar.BorderSizePixel=0
Sidebar.ZIndex=3
Sidebar.ClipsDescendants=false

local SideDiv=Instance.new("Frame",Main)
SideDiv.Size=UDim2.new(0,1,1,-46)
SideDiv.Position=UDim2.new(0,SIDEBAR_W,0,46)
SideDiv.BackgroundColor3=C.border
SideDiv.BorderSizePixel=0
SideDiv.ZIndex=4

local SideInner=Instance.new("Frame",Sidebar)
SideInner.Name="SideInner"
SideInner.Size=UDim2.new(1,0,1,0)
SideInner.Position=UDim2.new(0,0,0,0)
SideInner.BackgroundTransparency=1
SideInner.BorderSizePixel=0
SideInner.ZIndex=3

local SideLayout=Instance.new("UIListLayout",SideInner)
SideLayout.SortOrder=Enum.SortOrder.LayoutOrder
SideLayout.Padding=UDim.new(0,2)
local SidePad=Instance.new("UIPadding",SideInner)
SidePad.PaddingTop=UDim.new(0,8)
SidePad.PaddingLeft=UDim.new(0,7)
SidePad.PaddingRight=UDim.new(0,7)

-- Content panel
local Content=Instance.new("ScrollingFrame",Main)
Content.Size=UDim2.new(1,-SIDEBAR_W,1,-46); Content.Position=UDim2.new(0,SIDEBAR_W,0,46)
Content.BackgroundColor3=C.content; Content.BorderSizePixel=0
Content.ScrollBarThickness=3; Content.ScrollBarImageColor3=C.accent
Content.CanvasSize=UDim2.new(0,0,0,0); Content.AutomaticCanvasSize=Enum.AutomaticSize.Y; Content.ZIndex=3
local CLayout=Instance.new("UIListLayout",Content); CLayout.SortOrder=Enum.SortOrder.LayoutOrder; CLayout.Padding=UDim.new(0,0)
local CPad=Instance.new("UIPadding",Content); CPad.PaddingTop=UDim.new(0,14); CPad.PaddingBottom=UDim.new(0,14); CPad.PaddingLeft=UDim.new(0,16); CPad.PaddingRight=UDim.new(0,16)

-- Toast
local function showToast(msg,isOn)
	if not CONFIG.Notifications then return end
	local t=Instance.new("Frame",_screenGuiRef); t.Size=UDim2.new(0,224,0,40); t.Position=UDim2.new(1,-234,1,-54); t.BackgroundColor3=C.card; t.BorderSizePixel=0; t.ZIndex=60; t.BackgroundTransparency=1
	Instance.new("UICorner",t).CornerRadius=UDim.new(0,7)
	local stroke=Instance.new("UIStroke",t); stroke.Color=isOn and C.green or C.red; stroke.Thickness=1; stroke.Transparency=0.35
	local bar=Instance.new("Frame",t); bar.Size=UDim2.new(0,3,0.65,0); bar.Position=UDim2.new(0,0,0.175,0); bar.BackgroundColor3=isOn and C.green or C.red; bar.BorderSizePixel=0; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
	local lbl=Instance.new("TextLabel",t); lbl.Size=UDim2.new(1,-12,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=msg; lbl.TextColor3=C.textPrim; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextYAlignment=Enum.TextYAlignment.Center; lbl.ZIndex=61
	TweenService:Create(t,TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
	task.delay(2.3,function()
		TweenService:Create(t,TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1,Position=UDim2.new(1,-8,1,-54)}):Play()
		task.delay(0.22,function() pcall(function() t:Destroy() end) end)
	end)
end

-- ============================================================
--  COMPONENTES
-- ============================================================

local function makeGroupHeader(parent,title,order)
	local wrap=Instance.new("Frame",parent); wrap.Size=UDim2.new(1,0,0,24); wrap.BackgroundTransparency=1; wrap.LayoutOrder=order
	local lbl=Instance.new("TextLabel",wrap); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=string.upper(title); lbl.TextColor3=C.accent; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left
	local line=Instance.new("Frame",wrap); line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1); line.BackgroundColor3=C.border; line.BorderSizePixel=0
end

local function makeSpacer(parent,h,order)
	local s=Instance.new("Frame",parent); s.Size=UDim2.new(1,0,0,h); s.BackgroundTransparency=1; s.LayoutOrder=order
end

local function makeToggle(parent,label,desc,order,callback)
	local state=false
	local Row=Instance.new("Frame",parent); Row.Size=UDim2.new(1,0,0,desc~="" and 48 or 38); Row.BackgroundColor3=C.card; Row.BorderSizePixel=0; Row.LayoutOrder=order
	Instance.new("UICorner",Row).CornerRadius=UDim.new(0,7)
	local Ind=Instance.new("Frame",Row); Ind.Size=UDim2.new(0,3,0,desc~="" and 26 or 18); Ind.Position=UDim2.new(0,0,0.5,desc~="" and -13 or -9); Ind.BackgroundColor3=C.textDim; Ind.BorderSizePixel=0; Instance.new("UICorner",Ind).CornerRadius=UDim.new(1,0)
	local Lbl=Instance.new("TextLabel",Row); Lbl.Size=UDim2.new(1,-68,0,17); Lbl.Position=UDim2.new(0,13,desc~="" and 0.22 or 0.5,desc~="" and 0 or -8.5); Lbl.BackgroundTransparency=1; Lbl.Text=label; Lbl.TextColor3=C.textSec; Lbl.Font=Enum.Font.Gotham; Lbl.TextSize=13; Lbl.TextXAlignment=Enum.TextXAlignment.Left
	if desc~="" then
		local Desc=Instance.new("TextLabel",Row); Desc.Size=UDim2.new(1,-68,0,13); Desc.Position=UDim2.new(0,13,0,24); Desc.BackgroundTransparency=1; Desc.Text=desc; Desc.TextColor3=C.textDim; Desc.Font=Enum.Font.Gotham; Desc.TextSize=10; Desc.TextXAlignment=Enum.TextXAlignment.Left
	end
	local Switch=Instance.new("Frame",Row); Switch.Size=UDim2.new(0,42,0,22); Switch.Position=UDim2.new(1,-52,0.5,-11); Switch.BackgroundColor3=Color3.fromRGB(36,30,52); Switch.BorderSizePixel=0; Instance.new("UICorner",Switch).CornerRadius=UDim.new(1,0)
	local SwStroke=Instance.new("UIStroke",Switch); SwStroke.Color=C.border; SwStroke.Thickness=1
	local Knob=Instance.new("Frame",Switch); Knob.Size=UDim2.new(0,16,0,16); Knob.Position=UDim2.new(0,3,0.5,-8); Knob.BackgroundColor3=C.textDim; Knob.BorderSizePixel=0; Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
	local Btn=Instance.new("TextButton",Row); Btn.Size=UDim2.new(1,0,1,0); Btn.BackgroundTransparency=1; Btn.Text=""; Btn.ZIndex=5
	local function refresh()
		if state then
			TweenService:Create(Row,TW,{BackgroundColor3=C.cardActive}):Play()
			TweenService:Create(Lbl,TW,{TextColor3=C.textPrim}):Play()
			TweenService:Create(Ind,TW,{BackgroundColor3=C.green}):Play()
			TweenService:Create(Switch,TW,{BackgroundColor3=C.greenDim}):Play()
			TweenService:Create(Knob,TW,{Position=UDim2.new(1,-19,0.5,-8),BackgroundColor3=C.green}):Play()
			SwStroke.Color=C.greenDim
		else
			TweenService:Create(Row,TW,{BackgroundColor3=C.card}):Play()
			TweenService:Create(Lbl,TW,{TextColor3=C.textSec}):Play()
			TweenService:Create(Ind,TW,{BackgroundColor3=C.textDim}):Play()
			TweenService:Create(Switch,TW,{BackgroundColor3=Color3.fromRGB(36,30,52)}):Play()
			TweenService:Create(Knob,TW,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=C.textDim}):Play()
			SwStroke.Color=C.border
		end
	end
	Btn.MouseButton1Click:Connect(function() state=not state; refresh(); callback(state); showToast((state and "[ON]  " or "[OFF] ")..label,state) end)
	Btn.MouseEnter:Connect(function() if not state then TweenService:Create(Row,TweenInfo.new(0.1),{BackgroundColor3=C.cardHover}):Play() end end)
	Btn.MouseLeave:Connect(function() if not state then TweenService:Create(Row,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end end)
	return function(s)
		if s ~= state then
			state = s
			refresh()
		end
	end
end

local function makeSlider(parent,label,minV,maxV,def,suf,order,callback)
	local val=def
	local Wrap=Instance.new("Frame",parent); Wrap.Size=UDim2.new(1,0,0,52); Wrap.BackgroundColor3=C.card; Wrap.BorderSizePixel=0; Wrap.LayoutOrder=order
	Instance.new("UICorner",Wrap).CornerRadius=UDim.new(0,7)
	local Ind=Instance.new("Frame",Wrap); Ind.Size=UDim2.new(0,3,0,14); Ind.Position=UDim2.new(0,0,0.5,-7); Ind.BackgroundColor3=C.accent; Ind.BorderSizePixel=0; Instance.new("UICorner",Ind).CornerRadius=UDim.new(1,0)
	local Lb=Instance.new("TextLabel",Wrap); Lb.Size=UDim2.new(1,-78,0,15); Lb.Position=UDim2.new(0,13,0,7); Lb.BackgroundTransparency=1; Lb.Text=label; Lb.TextColor3=C.textSec; Lb.Font=Enum.Font.Gotham; Lb.TextSize=12; Lb.TextXAlignment=Enum.TextXAlignment.Left
	local VL=Instance.new("TextLabel",Wrap); VL.Size=UDim2.new(0,65,0,15); VL.Position=UDim2.new(1,-72,0,7); VL.BackgroundTransparency=1; VL.Text=tostring(def)..suf; VL.TextColor3=C.accentLight; VL.Font=Enum.Font.GothamBold; VL.TextSize=12; VL.TextXAlignment=Enum.TextXAlignment.Right
	local Track=Instance.new("Frame",Wrap); Track.Size=UDim2.new(1,-26,0,4); Track.Position=UDim2.new(0,13,0,34); Track.BackgroundColor3=C.sliderTrack; Track.BorderSizePixel=0; Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
	local Fill=Instance.new("Frame",Track); Fill.Size=UDim2.new((def-minV)/(maxV-minV),0,1,0); Fill.BackgroundColor3=C.accent; Fill.BorderSizePixel=0; Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
	local SK=Instance.new("Frame",Track); SK.Size=UDim2.new(0,14,0,14); SK.Position=UDim2.new((def-minV)/(maxV-minV),-7,0.5,-7); SK.BackgroundColor3=C.sliderKnob; SK.BorderSizePixel=0; SK.ZIndex=2; Instance.new("UICorner",SK).CornerRadius=UDim.new(1,0)
	local dragging=false
	local function upd(x) local r=math.clamp((x-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1); val=math.floor(minV+r*(maxV-minV)); Fill.Size=UDim2.new(r,0,1,0); SK.Position=UDim2.new(r,-7,0.5,-7); VL.Text=tostring(val)..suf; callback(val) end
	local CZ=Instance.new("TextButton",Track); CZ.Size=UDim2.new(1,0,0,20); CZ.Position=UDim2.new(0,0,0.5,-10); CZ.BackgroundTransparency=1; CZ.Text=""; CZ.ZIndex=3
	CZ.MouseButton1Down:Connect(function(x) dragging=true; upd(x) end)
	UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
	Wrap.MouseEnter:Connect(function() TweenService:Create(Wrap,TweenInfo.new(0.1),{BackgroundColor3=C.cardHover}):Play() end)
	Wrap.MouseLeave:Connect(function() TweenService:Create(Wrap,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end)
end

local _openDropList = nil

local function makeDropdown(parent, label, options, default, order, callback)
	local selected = default or 1
	local LIST_ITEM_H = 30
	local LIST_H = #options * LIST_ITEM_H + 8

	local Wrap = Instance.new("Frame", parent)
	Wrap.Name = "Dropdown_"..label
	Wrap.Size = UDim2.new(1, 0, 0, 46)
	Wrap.BackgroundColor3 = C.card
	Wrap.BorderSizePixel = 0
	Wrap.LayoutOrder = order
	Wrap.ZIndex = 5
	Wrap.ClipsDescendants = false
	Instance.new("UICorner", Wrap).CornerRadius = UDim.new(0, 7)
	local WStroke = Instance.new("UIStroke", Wrap)
	WStroke.Color = C.border; WStroke.Thickness = 1

	local Ind = Instance.new("Frame", Wrap)
	Ind.Size = UDim2.new(0, 3, 0, 18); Ind.Position = UDim2.new(0, 0, 0.5, -9)
	Ind.BackgroundColor3 = C.accent; Ind.BorderSizePixel = 0
	Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

	local FieldLbl = Instance.new("TextLabel", Wrap)
	FieldLbl.Size = UDim2.new(1, -16, 0, 12)
	FieldLbl.Position = UDim2.new(0, 13, 0, 5)
	FieldLbl.BackgroundTransparency = 1
	FieldLbl.Text = string.upper(label)
	FieldLbl.TextColor3 = C.textDim
	FieldLbl.Font = Enum.Font.GothamBold
	FieldLbl.TextSize = 9
	FieldLbl.TextXAlignment = Enum.TextXAlignment.Left
	FieldLbl.ZIndex = 6

	local ValLbl = Instance.new("TextLabel", Wrap)
	ValLbl.Size = UDim2.new(1, -40, 0, 18)
	ValLbl.Position = UDim2.new(0, 13, 0, 20)
	ValLbl.BackgroundTransparency = 1
	ValLbl.Text = options[selected]
	ValLbl.TextColor3 = C.textPrim
	ValLbl.Font = Enum.Font.GothamBold
	ValLbl.TextSize = 13
	ValLbl.TextXAlignment = Enum.TextXAlignment.Left
	ValLbl.ZIndex = 6

	local Arrow = Instance.new("TextLabel", Wrap)
	Arrow.Size = UDim2.new(0, 20, 0, 20)
	Arrow.Position = UDim2.new(1, -28, 0.5, -10)
	Arrow.BackgroundTransparency = 1
	Arrow.Text = "v"
	Arrow.TextColor3 = C.accentLight
	Arrow.Font = Enum.Font.GothamBold
	Arrow.TextSize = 12
	Arrow.ZIndex = 6

	local OpenBtn = Instance.new("TextButton", Wrap)
	OpenBtn.Size = UDim2.new(1, 0, 1, 0)
	OpenBtn.BackgroundTransparency = 1
	OpenBtn.Text = ""
	OpenBtn.ZIndex = 7

	local DropList = Instance.new("Frame", Wrap)
	DropList.Size = UDim2.new(1, 0, 0, 0)
	DropList.Position = UDim2.new(0, 0, 1, 6)
	DropList.BackgroundColor3 = C.dropBG
	DropList.BorderSizePixel = 0
	DropList.ZIndex = 80
	DropList.Visible = false
	DropList.ClipsDescendants = true
	Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 8)
	local DStroke = Instance.new("UIStroke", DropList)
	DStroke.Color = C.accentLight; DStroke.Thickness = 1; DStroke.Transparency = 0.6

	local DPad = Instance.new("UIPadding", DropList)
	DPad.PaddingTop = UDim.new(0, 4); DPad.PaddingBottom = UDim.new(0, 4)
	DPad.PaddingLeft = UDim.new(0, 5); DPad.PaddingRight = UDim.new(0, 5)
	local DLayout = Instance.new("UIListLayout", DropList)
	DLayout.SortOrder = Enum.SortOrder.LayoutOrder; DLayout.Padding = UDim.new(0, 2)

	local itemRefs = {}
	for i, opt in ipairs(options) do
		local Item = Instance.new("TextButton", DropList)
		Item.Size = UDim2.new(1, 0, 0, LIST_ITEM_H)
		Item.BackgroundColor3 = C.dropItemHov
		Item.BackgroundTransparency = (i == selected) and 0.55 or 1
		Item.BorderSizePixel = 0
		Item.Text = ""
		Item.LayoutOrder = i
		Item.ZIndex = 82
		Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 6)

		local Dot = Instance.new("Frame", Item)
		Dot.Size = UDim2.new(0, 5, 0, 5)
		Dot.Position = UDim2.new(0, 9, 0.5, -2.5)
		Dot.BackgroundColor3 = C.accentLight
		Dot.BorderSizePixel = 0
		Dot.ZIndex = 83
		Dot.Visible = (i == selected)
		Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

		local OptLbl = Instance.new("TextLabel", Item)
		OptLbl.Size = UDim2.new(1, -24, 1, 0)
		OptLbl.Position = UDim2.new(0, 20, 0, 0)
		OptLbl.BackgroundTransparency = 1
		OptLbl.Text = opt
		OptLbl.TextColor3 = (i == selected) and C.accentLight or C.textSec
		OptLbl.Font = (i == selected) and Enum.Font.GothamBold or Enum.Font.Gotham
		OptLbl.TextSize = 12
		OptLbl.TextXAlignment = Enum.TextXAlignment.Left
		OptLbl.ZIndex = 83

		Item.MouseEnter:Connect(function()
			if i ~= selected then TweenService:Create(Item,TweenInfo.new(0.08),{BackgroundTransparency=0.7}):Play() end
		end)
		Item.MouseLeave:Connect(function()
			if i ~= selected then TweenService:Create(Item,TweenInfo.new(0.08),{BackgroundTransparency=1}):Play() end
		end)

		Item.MouseButton1Click:Connect(function()
			for _, ref in ipairs(itemRefs) do
				ref.dot.Visible = false
				ref.lbl.TextColor3 = C.textSec
				ref.lbl.Font = Enum.Font.Gotham
				TweenService:Create(ref.btn,TweenInfo.new(0.08),{BackgroundTransparency=1}):Play()
			end
			Dot.Visible = true
			OptLbl.TextColor3 = C.accentLight
			OptLbl.Font = Enum.Font.GothamBold
			TweenService:Create(Item,TweenInfo.new(0.08),{BackgroundTransparency=0.55}):Play()
			selected = i
			ValLbl.Text = opt
			TweenService:Create(DropList,TweenInfo.new(0.14,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,0)}):Play()
			task.delay(0.15,function() DropList.Visible=false end)
			TweenService:Create(Arrow,TweenInfo.new(0.12),{Rotation=0}):Play()
			TweenService:Create(WStroke,TweenInfo.new(0.12),{Color=C.border}):Play()
			_openDropList = nil
			callback(opt)
		end)

		table.insert(itemRefs, {btn=Item, dot=Dot, lbl=OptLbl})
	end

	local isOpen = false
	OpenBtn.MouseButton1Click:Connect(function()
		if _openDropList and _openDropList ~= DropList then
			_openDropList.Visible = false
			_openDropList.Size = UDim2.new(1,0,0,0)
		end
		isOpen = not isOpen
		if isOpen then
			_openDropList = DropList
			DropList.Size = UDim2.new(1,0,0,0)
			DropList.Visible = true
			TweenService:Create(DropList,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,LIST_H)}):Play()
			TweenService:Create(Arrow,TweenInfo.new(0.15),{Rotation=180}):Play()
			TweenService:Create(WStroke,TweenInfo.new(0.15),{Color=C.accentLight}):Play()
		else
			_openDropList = nil
			TweenService:Create(DropList,TweenInfo.new(0.14,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,0)}):Play()
			task.delay(0.15,function() DropList.Visible=false end)
			TweenService:Create(Arrow,TweenInfo.new(0.12),{Rotation=0}):Play()
			TweenService:Create(WStroke,TweenInfo.new(0.12),{Color=C.border}):Play()
		end
	end)

	Wrap.MouseEnter:Connect(function() TweenService:Create(Wrap,TweenInfo.new(0.1),{BackgroundColor3=C.cardHover}):Play() end)
	Wrap.MouseLeave:Connect(function() TweenService:Create(Wrap,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end)
end

-- ============================================================
--  SIDEBAR / ABAS
-- ============================================================

local sideItems={}; local contentPages={}; local activePage=nil
local toggleSetters={}

local TAB_DEFS={
	{name="Aimbot",  sub="Mira automatica", order=1},
	{name="Visuals", sub="ESP e elementos", order=2},
	{name="Combat",  sub="Modificacoes",    order=3},
	{name="Misc",    sub="Utilidades",      order=4},
	{name="Config",  sub="Configuracoes",   order=5},
}

local function switchPage(name)
	for n,page in pairs(contentPages) do page.Visible=(n==name) end
	for n,item in pairs(sideItems) do
		local isActive=(n==name)
		item.bg.BackgroundTransparency=isActive and 0 or 1
		TweenService:Create(item.name,TW,{TextColor3=isActive and C.accentLight or C.textDim}):Play()
		TweenService:Create(item.sub,TW,{TextColor3=isActive and C.textSec or Color3.fromRGB(56,50,76)}):Play()
		item.bar.BackgroundTransparency=isActive and 0 or 1
	end
	activePage=name
end

for _,def in ipairs(TAB_DEFS) do
	local itemBG=Instance.new("Frame",SideInner); itemBG.Size=UDim2.new(1,0,0,50); itemBG.BackgroundColor3=Color3.fromRGB(32,22,54); itemBG.BackgroundTransparency=1; itemBG.BorderSizePixel=0; itemBG.LayoutOrder=def.order
	Instance.new("UICorner",itemBG).CornerRadius=UDim.new(0,8)
	local bar=Instance.new("Frame",itemBG); bar.Size=UDim2.new(0,3,0.55,0); bar.Position=UDim2.new(0,-7,0.225,0); bar.BackgroundColor3=C.accent; bar.BorderSizePixel=0; bar.BackgroundTransparency=1; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
	local nameLbl=Instance.new("TextLabel",itemBG); nameLbl.Size=UDim2.new(1,-8,0,17); nameLbl.Position=UDim2.new(0,10,0,10); nameLbl.BackgroundTransparency=1; nameLbl.Text=def.name; nameLbl.TextColor3=C.textDim; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=13; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
	local subLbl=Instance.new("TextLabel",itemBG); subLbl.Size=UDim2.new(1,-8,0,12); subLbl.Position=UDim2.new(0,10,0,28); subLbl.BackgroundTransparency=1; subLbl.Text=def.sub; subLbl.TextColor3=Color3.fromRGB(56,50,76); subLbl.Font=Enum.Font.Gotham; subLbl.TextSize=9; subLbl.TextXAlignment=Enum.TextXAlignment.Left
	local btn=Instance.new("TextButton",itemBG); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=5
	btn.MouseButton1Click:Connect(function() switchPage(def.name) end)
	btn.MouseEnter:Connect(function() if activePage~=def.name then TweenService:Create(itemBG,TweenInfo.new(0.1),{BackgroundTransparency=0.72}):Play() end end)
	btn.MouseLeave:Connect(function() if activePage~=def.name then TweenService:Create(itemBG,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play() end end)
	sideItems[def.name]={bg=itemBG,name=nameLbl,sub=subLbl,bar=bar}
	local page=Instance.new("Frame",Content); page.Size=UDim2.new(1,0,0,0); page.AutomaticSize=Enum.AutomaticSize.Y; page.BackgroundTransparency=1; page.BorderSizePixel=0; page.LayoutOrder=def.order; page.Visible=false
	local pl=Instance.new("UIListLayout",page); pl.SortOrder=Enum.SortOrder.LayoutOrder; pl.Padding=UDim.new(0,5)
	contentPages[def.name]=page
end
local SideVer=Instance.new("TextLabel",SideInner); SideVer.Size=UDim2.new(1,0,0,20); SideVer.BackgroundTransparency=1; SideVer.Text="Purity v7.0"; SideVer.TextColor3=C.textDim; SideVer.Font=Enum.Font.Gotham; SideVer.TextSize=9; SideVer.LayoutOrder=99

-- ============================================================
--  POPULANDO PAGINAS
-- ============================================================

local function buildAimbot()
	local p=contentPages["Aimbot"]
	makeGroupHeader(p,"Principal",1); makeSpacer(p,3,2)
	toggleSetters["AIMBOT.Enabled"]  = makeToggle(p,"Aimbot Ativo",   "Mira automatica no alvo no FOV",           3,onAimbotToggle)
	toggleSetters["AIMBOT.Silent"]   = makeToggle(p,"Silent Aim",     "Redireciona o projetil sem mover a camera",4,onSilentAimToggle)
	toggleSetters["AIMBOT.Prediction"]= makeToggle(p,"Prediction",    "Compensa a velocidade do alvo",            5,onPredictionToggle)
	toggleSetters["AIMBOT.FOVCircle"]= makeToggle(p,"FOV Circle",     "Circulo de campo de visao na tela",        6,onFOVCircleToggle)
	toggleSetters["AIMBOT.AutoShoot"]= makeToggle(p,"Auto Shoot",     "Atira ao travar no alvo",                  7,onAutoShootToggle)
	makeSpacer(p,8,8); makeGroupHeader(p,"Filtros",9); makeSpacer(p,3,10)
	toggleSetters["AIMBOT.TeamCheck"]   = makeToggle(p,"Team Check",     "Ignora mesmo time",                        11,onTeamCheckToggle)
	toggleSetters["AIMBOT.VisCheck"]    = makeToggle(p,"Vis. Check",     "So mira em alvos visiveis",                12,onVisCheckToggle)
	toggleSetters["AIMBOT.AimKey"]      = makeToggle(p,"Aim Key (LAlt)", "Ativa mira com Left Alt",                  13,onAimKeyToggle)
	toggleSetters["AIMBOT.TargetSwitch"]= makeToggle(p,"Target Switch",  "Troca de alvo ao eliminar",                14,onTargetSwitchToggle)
	toggleSetters["AIMBOT.AimShake"]    = makeToggle(p,"Aim Shake",      "Oscilacao humana na mira",                 15,onAimShakeToggle)
	makeSpacer(p,8,16); makeGroupHeader(p,"Parte Alvo",17); makeSpacer(p,3,18)
	makeDropdown(p,"Parte Alvo",{"Cabeca","Torso"},1,19,function(opt)
		if opt=="Cabeca" then onTargetPartHead() else onTargetPartTorso() end
	end)
	makeSpacer(p,8,20); makeGroupHeader(p,"Ajustes",21); makeSpacer(p,3,22)
	makeSlider(p,"FOV",         20,500,150," px",23,onFOVChange)
	makeSlider(p,"Smoothness",   1, 20,  8,"x",  24,onSmoothnessChange)
	makeSlider(p,"Max Distance",50,1000,500," st",25,onMaxDistChange)
	makeSlider(p,"Shake Amount", 1, 10,  2,"x",  26,onShakeAmtChange)
end

buildAimbot()
local function buildVisuals()
	local p=contentPages["Visuals"]
	makeGroupHeader(p,"ESP",1); makeSpacer(p,3,2)
	toggleSetters["ESP.Enabled"]   = makeToggle(p,"ESP Ativo",     "Liga todo o sistema de visuais",       3,onESPToggle)
	toggleSetters["ESP.RGB"]       = makeToggle(p,"RGB",           "Cores animadas em arco-iris",          4,onRGBToggle)
	toggleSetters["ESP.Box"]       = makeToggle(p,"Box ESP",       "Silhueta ao redor do personagem",      5,onBoxToggle)
	toggleSetters["ESP.Skeleton"]  = makeToggle(p,"Esqueleto",     "Linhas do esqueleto 3D",               6,onSkeletonToggle)
	toggleSetters["ESP.Names"]     = makeToggle(p,"Nome",          "Nome do jogador acima",                7,onNameESPToggle)
	toggleSetters["ESP.Distance"]  = makeToggle(p,"Distancia",     "Distancia em studs",                   8,onDistanceToggle)
	toggleSetters["ESP.HealthBar"] = makeToggle(p,"Health Bar",    "Barra de vida lateral",                9,onHealthBarToggle)
	toggleSetters["ESP.Tracers"]   = makeToggle(p,"Tracelines",    "Linha do centro da tela ao alvo",      10,onTracelinesToggle)
	makeSpacer(p,8,11); makeGroupHeader(p,"Extras",12); makeSpacer(p,3,13)
	toggleSetters["ESP.VisionCone"]= makeToggle(p,"Cone de Visao", "Triangulo da direcao do inimigo",      15,onVisionConeToggle)
end
buildVisuals()

local function buildCombat()
	local p=contentPages["Combat"]
	makeGroupHeader(p,"Arma",1); makeSpacer(p,3,2)
	toggleSetters["COMBAT.NoRecoil"]    = makeToggle(p,"No Recoil",     "Trava o recuo da camera",              3,onNoRecoilToggle)
	toggleSetters["COMBAT.NoSpread"]    = makeToggle(p,"No Spread",     "Elimina dispersao no disparo",         4,onNoSpreadToggle)
	toggleSetters["COMBAT.RapidFire"]   = makeToggle(p,"Rapid Fire",    "Disparo rapido automatico",            5,onRapidFireToggle)
	toggleSetters["COMBAT.InfiniteAmmo"]= makeToggle(p,"Infinite Ammo", "Municao infinita",                     6,onInfiniteAmmoToggle)
	toggleSetters["COMBAT.FastReload"]  = makeToggle(p,"Fast Reload",   "Acelera animacao de recarga",          7,onFastReloadToggle)
	makeSpacer(p,8,8); makeGroupHeader(p,"Mobilidade",9); makeSpacer(p,3,10)
	toggleSetters["COMBAT.BunnyHop"]    = makeToggle(p,"Bunny Hop",     "Pulo automatico ao manter Espaco",     11,onBunnyHopToggle)
	toggleSetters["COMBAT.InfiniteJump"]= makeToggle(p,"Infinite Jump", "Pulo infinito no ar",                  12,onInfiniteJumpToggle)
	toggleSetters["COMBAT.FlyHack"]     = makeToggle(p,"Fly Hack",      "Voa com WASD e E/Q",                  13,onFlyHackToggle)
	toggleSetters["COMBAT.SpeedHack"]   = makeToggle(p,"Speed Hack",    "Aumenta velocidade de corrida",        14,onSpeedHackToggle)
	toggleSetters["COMBAT.JumpPower"]   = makeToggle(p,"Jump Power",    "Aumenta poder de pulo",                15,onJumpPowerToggle)
	toggleSetters["COMBAT.AntiRagdoll"] = makeToggle(p,"Anti Ragdoll",  "Impede estado de ragdoll",             16,onAntiRagdollToggle)
	makeSpacer(p,8,17); makeGroupHeader(p,"Ajustes",18); makeSpacer(p,3,19)
	makeSlider(p,"Fire Rate",   1, 10, 1,"x",  20,onFireRateChange)
	makeSlider(p,"Reload Speed",1,  5, 1,"x",  21,onReloadSpeedChange)
	makeSlider(p,"Walk Speed", 16,200,50," ws",22,onWalkSpeedChange)
	makeSlider(p,"Jump Power", 50,500,100," jp",23,onJumpPowerChange)
	makeSlider(p,"Fly Speed",   5,200,50," ws",24,onFlySpeedChange)
end
buildCombat()

local function buildMisc()
	local p=contentPages["Misc"]

	-- Camera
	makeGroupHeader(p,"Camera",1); makeSpacer(p,3,2)
	toggleSetters["MISC.CustomFOV"] = makeToggle(p,"Custom FOV","Controla o campo de visao",3,onCustomFOVToggle)
	makeSlider(p,"FOV",50,120,70,"graus",4,onFOVValueChange)

	-- Thirdperson
	makeSpacer(p,8,5); makeGroupHeader(p,"Visao",6); makeSpacer(p,3,7)
	local tpConn=nil
	toggleSetters["MISC.Thirdperson"] = makeToggle(p,"Thirdperson","Visao em terceira pessoa",8,function(s)
		MISC.Thirdperson=s
		if s then
			tpConn=RunService.RenderStepped:Connect(function()
				if not MISC.Thirdperson then return end
				local char=LocalPlayer.Character
				local hrp=char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					Camera.CFrame=CFrame.new(hrp.Position + Vector3.new(0,4,0) + Camera.CFrame.LookVector*-MISC.ThirdpersonDist, hrp.Position + Vector3.new(0,2,0))
					Camera.CameraType=Enum.CameraType.Scriptable
				end
			end)
		else
			if tpConn then tpConn:Disconnect(); tpConn=nil end
			Camera.CameraType=Enum.CameraType.Custom
		end
	end)
	makeSlider(p,"Distancia TP",3,20,8,"m",9,function(v) MISC.ThirdpersonDist=v end)

	-- Personagem
	makeSpacer(p,8,10); makeGroupHeader(p,"Personagem",11); makeSpacer(p,3,12)
	toggleSetters["MISC.Noclip"]   = makeToggle(p,"Noclip",   "Atravessa paredes",  13,onNoclipToggle)
	toggleSetters["MISC.SpinBot"]  = makeToggle(p,"Spin Bot", "Gira o personagem",  14,onSpinBotToggle)
	makeSlider(p,"Spin Speed",1,20,10," rot/s",15,onSpinSpeedChange)

	-- Inimigos
	makeSpacer(p,8,16); makeGroupHeader(p,"Inimigos",17); makeSpacer(p,3,18)
	toggleSetters["MISC.BigHead"]  = makeToggle(p,"Big Head","Aumenta a cabeca dos inimigos",19,onBigHeadToggle)
	makeSlider(p,"Head Scale",1,4,2,"x",20,onBigHeadScaleChange)

	-- Tracer de bala
	makeSpacer(p,8,21); makeGroupHeader(p,"Visual Extra",22); makeSpacer(p,3,23)
	local bulletConns={}
	toggleSetters["MISC.BulletTracer"] = makeToggle(p,"Bullet Tracer","Mostra o rastro das suas balas",24,function(s)
		MISC.BulletTracer=s
		for _,c in pairs(bulletConns) do pcall(function() c:Disconnect() end) end
		bulletConns={}
		if not s then return end
		local char=LocalPlayer.Character
		local function hookTool(tool)
			if not tool then return end
			local fireConn=tool.ChildAdded:Connect(function(obj)
				if obj.Name~="Bullet" and obj.Name~="Shell" and not obj:IsA("BasePart") then return end
				pcall(function()
					local line=Drawing.new("Line")
					line.Thickness=1.5; line.Color=C.accentLight; line.Transparency=1
					local startPos=obj.Position
					local moved=obj:GetPropertyChangedSignal("Position"):Connect(function()
						local v1,_=Camera:WorldToViewportPoint(startPos)
						local v2,_=Camera:WorldToViewportPoint(obj.Position)
						line.From=Vector2.new(v1.X,v1.Y); line.To=Vector2.new(v2.X,v2.Y); line.Visible=true
					end)
					task.delay(0.5,function() line:Remove(); moved:Disconnect() end)
				end)
			end)
			table.insert(bulletConns,fireConn)
		end
		if char then hookTool(char:FindFirstChildOfClass("Tool")) end
		table.insert(bulletConns, LocalPlayer.CharacterAdded:Connect(function(c)
			c.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then hookTool(ch) end end)
		end))
	end)

	-- Crosshair customizavel
	local crosshairLines={}
	local crosshairVisible=false
	local function updateCrosshair()
		if not MISC.Crosshair then
			for _,l in pairs(crosshairLines) do pcall(function() l:Remove() end) end
			crosshairLines={}; return
		end
		local vp=Camera.ViewportSize
		local cx,cy=vp.X/2,vp.Y/2
		local sz=MISC.CrosshairSize or 10
		local gap=MISC.CrosshairGap or 4
		local col=C.accentLight
		if #crosshairLines==0 then
			for i=1,4 do local l=Drawing.new("Line"); l.Thickness=1.5; l.Color=col; l.Transparency=1; l.Visible=true; crosshairLines[i]=l end
		end
		-- left, right, up, down
		crosshairLines[1].From=Vector2.new(cx-gap-sz,cy); crosshairLines[1].To=Vector2.new(cx-gap,cy)
		crosshairLines[2].From=Vector2.new(cx+gap,cy);    crosshairLines[2].To=Vector2.new(cx+gap+sz,cy)
		crosshairLines[3].From=Vector2.new(cx,cy-gap-sz); crosshairLines[3].To=Vector2.new(cx,cy-gap)
		crosshairLines[4].From=Vector2.new(cx,cy+gap);    crosshairLines[4].To=Vector2.new(cx,cy+gap+sz)
		for _,l in pairs(crosshairLines) do l.Color=col end
	end
	toggleSetters["MISC.Crosshair"] = makeToggle(p,"Crosshair Custom","Mira personalizada no centro",25,function(s)
		MISC.Crosshair=s
		if not s then for _,l in pairs(crosshairLines) do pcall(function() l:Remove() end) end; crosshairLines={} end
	end)
	makeSlider(p,"Tamanho Mira",4,30,10,"px",26,function(v) MISC.CrosshairSize=v end)
	makeSlider(p,"Gap Mira",   1,20,4, "px",27,function(v) MISC.CrosshairGap=v end)
	RunService.RenderStepped:Connect(function() if MISC.Crosshair then updateCrosshair() end end)

	-- Utilidade
	makeSpacer(p,8,28); makeGroupHeader(p,"Utilidade",29); makeSpacer(p,3,30)
	toggleSetters["MISC.WallBang"]  = makeToggle(p,"Wall Bang",  "Bala atravessa paredes",           31,onWallBangToggle)
	toggleSetters["MISC.AntiAFK"]   = makeToggle(p,"Anti AFK",   "Evita kick por inatividade",       32,onAntiAFKToggle)
	toggleSetters["MISC.TimeOfDay"] = makeToggle(p,"Time of Day","Controla a hora do dia",           33,onTimeOfDayToggle)
	makeSlider(p,"Hora do Dia",0,24,12,"h",34,onTimeOfDayChange)

	-- Radar
	makeSpacer(p,8,35); makeGroupHeader(p,"Radar",36); makeSpacer(p,3,37)
	toggleSetters["ESP.Radar"] = makeToggle(p,"Radar 2D","Minimapa com posicao dos inimigos",38,onRadarToggle)
	makeSlider(p,"Range Radar",50,600,250,"m",39,function(v) RADAR_RANGE=v end)
	makeSlider(p,"Tamanho Radar",100,240,160,"px",40,function(v)
		RADAR_SIZE=v; RADAR_RADIUS=v/2-6
		RadarGui.Size=UDim2.new(0,v,0,v)
	end)
end
buildMisc()

local function buildConfig()
	local p=contentPages["Config"]

	-- ── Interface ──
	makeGroupHeader(p,"Interface",1); makeSpacer(p,3,2)
	toggleSetters["CONFIG.Notifications"] = makeToggle(p,"Notificacoes","Toast ao ativar/desativar funcoes",3,function(s) CONFIG.Notifications=s end)
	toggleSetters["CONFIG.Particles"] = makeToggle(p,"Particulas","Estrelinhas animadas no fundo",4,function(s)
		CONFIG.Particles=s
		if s then setParticlesVisible(true); startParticles()
		else stopParticles() end
	end)
	toggleSetters["CONFIG.Watermark"] = makeToggle(p,"Watermark","FPS, ping e versao no canto da tela",5,function(s)
		CONFIG.Watermark=s
		if WatermarkFrame then WatermarkFrame.Visible=s end
	end)
	makeSpacer(p,6,6)
	makeSlider(p,"Opacidade",20,100,100,"%",7,function(v)
		CONFIG.Opacity=v/100; Main.BackgroundTransparency=1-(v/100)
	end)
	makeSpacer(p,10,8); makeGroupHeader(p,"Tema de Cores",9); makeSpacer(p,3,10)

	local function applyTheme(name)
		CONFIG.Theme=name
		local t=THEMES[name]; if not t then return end

		local oldAccent      = C.accent
		local oldAccentLight = C.accentLight
		local oldAccentGlow  = C.accentGlow

		local h,s,v = Color3.toHSV(t.neon)
		local newGlow = Color3.fromHSV(h, s, math.max(0, v - 0.25))

		C.accent      = t.border
		C.accentLight = t.neonBright
		C.accentGlow  = newGlow

		for _, obj in ipairs(ScreenGui:GetDescendants()) do
			pcall(function()
				if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("ImageLabel") then
					if obj.BackgroundColor3 == oldAccent      then obj.BackgroundColor3 = C.accent      end
					if obj.BackgroundColor3 == oldAccentLight then obj.BackgroundColor3 = C.accentLight end
					if obj.BackgroundColor3 == oldAccentGlow  then obj.BackgroundColor3 = C.accentGlow  end
				end
				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					if obj.TextColor3 == oldAccent      then obj.TextColor3 = C.accent      end
					if obj.TextColor3 == oldAccentLight then obj.TextColor3 = C.accentLight end
				end
				if obj:IsA("UIStroke") then
					if obj.Color == oldAccent      then obj.Color = C.accent      end
					if obj.Color == oldAccentLight then obj.Color = C.accentLight end
				end
				if obj:IsA("ScrollingFrame") then
					if obj.ScrollBarImageColor3 == oldAccent then obj.ScrollBarImageColor3 = C.accent end
				end
			end)
		end

		MainStroke.Color          = C.accent
		HDivider.BackgroundColor3 = C.accent
		LogoDot.BackgroundColor3  = C.accentLight
		VerBadge.BackgroundColor3 = C.accentGlow
		VerBadge.TextColor3       = C.accentLight
		fovCircle.Color           = C.accentLight
		for _, d in ipairs(particles) do
			pcall(function() d.frame.BackgroundColor3 = C.accentLight end)
		end
		if WatermarkFrame then
			WatermarkStroke.Color = C.accent
			WatermarkDot.BackgroundColor3 = C.accentLight
		end
	end

	makeDropdown(p,"Tema Ativo",{"Roxo","Azul","Vermelho","Verde","Laranja","Ciano","Rosa","Branco"},1,11,function(opt)
		applyTheme(string.lower(opt))
	end)

	-- ── Perfis de Config ──
	makeSpacer(p,10,12); makeGroupHeader(p,"Perfis de Configuracao",13); makeSpacer(p,3,14)

	local PROFILES = {"Rage","Legit","Visual Only"}
	local profileData = {}  -- salva config por perfil

	local function captureConfig()
		return {
			ESP=table.clone and table.clone(ESP) or {
				Enabled=ESP.Enabled,RGB=ESP.RGB,Box=ESP.Box,Skeleton=ESP.Skeleton,
				Names=ESP.Names,Distance=ESP.Distance,HealthBar=ESP.HealthBar,
				Tracers=ESP.Tracers,Radar=ESP.Radar,VisionCone=ESP.VisionCone,
			},
			AIMBOT={
				Enabled=AIMBOT.Enabled,Silent=AIMBOT.Silent,Prediction=AIMBOT.Prediction,
				FOVCircle=AIMBOT.FOVCircle,TeamCheck=AIMBOT.TeamCheck,VisCheck=AIMBOT.VisCheck,
				AutoShoot=AIMBOT.AutoShoot,FOVRadius=AIMBOT.FOVRadius,Smoothness=AIMBOT.Smoothness,
				MaxDist=AIMBOT.MaxDist,TargetPart=AIMBOT.TargetPart,
			},
			MISC={
				BigHead=MISC.BigHead,BigHeadScale=MISC.BigHeadScale,
				SpinBot=MISC.SpinBot,Noclip=MISC.Noclip,
			},
		}
	end

	local profileWrap=Instance.new("Frame",p); profileWrap.Size=UDim2.new(1,0,0,80); profileWrap.BackgroundColor3=C.card; profileWrap.BorderSizePixel=0; profileWrap.LayoutOrder=15; Instance.new("UICorner",profileWrap).CornerRadius=UDim.new(0,7)
	local profPad=Instance.new("UIPadding",profileWrap); profPad.PaddingLeft=UDim.new(0,10); profPad.PaddingRight=UDim.new(0,10); profPad.PaddingTop=UDim.new(0,8); profPad.PaddingBottom=UDim.new(0,8)
	local profLayout=Instance.new("UIListLayout",profileWrap); profLayout.FillDirection=Enum.FillDirection.Horizontal; profLayout.Padding=UDim.new(0,8); profLayout.SortOrder=Enum.SortOrder.LayoutOrder

	for i,name in ipairs(PROFILES) do
		local col=Instance.new("Frame",profileWrap); col.Size=UDim2.new(0,90,1,0); col.BackgroundTransparency=1; col.LayoutOrder=i
		local colLayout=Instance.new("UIListLayout",col); colLayout.Padding=UDim.new(0,5); colLayout.SortOrder=Enum.SortOrder.LayoutOrder

		local nameLbl=Instance.new("TextLabel",col); nameLbl.Size=UDim2.new(1,0,0,16); nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=C.textSec; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=10; nameLbl.LayoutOrder=1

		local saveBtn=Instance.new("TextButton",col); saveBtn.Size=UDim2.new(1,0,0,22); saveBtn.BackgroundColor3=C.cardHover; saveBtn.BorderSizePixel=0; saveBtn.Text="Salvar"; saveBtn.TextColor3=C.accentLight; saveBtn.Font=Enum.Font.GothamBold; saveBtn.TextSize=10; saveBtn.LayoutOrder=2; Instance.new("UICorner",saveBtn).CornerRadius=UDim.new(0,5)

		local loadBtn=Instance.new("TextButton",col); loadBtn.Size=UDim2.new(1,0,0,22); loadBtn.BackgroundColor3=C.accent; loadBtn.BorderSizePixel=0; loadBtn.Text="Carregar"; loadBtn.TextColor3=C.white; loadBtn.Font=Enum.Font.GothamBold; loadBtn.TextSize=10; loadBtn.LayoutOrder=3; Instance.new("UICorner",loadBtn).CornerRadius=UDim.new(0,5)

		saveBtn.MouseButton1Click:Connect(function()
			profileData[name]=captureConfig()
			saveBtn.Text="Salvo ✓"; saveBtn.BackgroundColor3=C.green
			task.delay(1.5,function() saveBtn.Text="Salvar"; saveBtn.BackgroundColor3=C.cardHover end)
			showToast("Perfil '"..name.."' salvo!",true)
		end)
		loadBtn.MouseButton1Click:Connect(function()
			if not profileData[name] then showToast("Perfil '"..name.."' vazio!",false); return end
			local d=profileData[name]
			if d.ESP then for k,v in pairs(d.ESP) do ESP[k]=v end end
			if d.AIMBOT then for k,v in pairs(d.AIMBOT) do AIMBOT[k]=v end end
			if d.MISC then
				if d.MISC.BigHead~=nil then onBigHeadToggle(d.MISC.BigHead) end
			end
			showToast("Perfil '"..name.."' carregado!",true)
		end)
	end
	makeSpacer(p,6,16)

	-- ── Hotkeys ──
	makeGroupHeader(p,"Hotkeys",17); makeSpacer(p,3,18)

	local hotkeys={
		{label="Toggle ESP",         key="ESPKey"},
		{label="Toggle BigHead",     key="BigHeadKey"},
		{label="Toggle Aimbot",      key="AimbotKey"},
		{label="Toggle Silent Aim",  key="SilentKey"},
		{label="Toggle Noclip",      key="NoclipKey"},
	}
	-- Garante que KEYBINDS tem todas as entradas
	KEYBINDS.AimbotKey=KEYBINDS.AimbotKey or nil
	KEYBINDS.SilentKey=KEYBINDS.SilentKey or nil
	KEYBINDS.NoclipKey=KEYBINDS.NoclipKey or nil

	for i,hk in ipairs(hotkeys) do
		local row=Instance.new("Frame",p); row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=C.card; row.BorderSizePixel=0; row.LayoutOrder=18+i; Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
		local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.55,0,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=hk.label; lbl.TextColor3=C.textPrim; lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
		local keyBtn=Instance.new("TextButton",row); keyBtn.Size=UDim2.new(0,130,0,22); keyBtn.Position=UDim2.new(1,-138,0.5,-11); keyBtn.BackgroundColor3=C.cardHover; keyBtn.BorderSizePixel=0; keyBtn.Font=Enum.Font.GothamBold; keyBtn.TextSize=10; keyBtn.TextColor3=C.accentLight; Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,5)
		keyBtn.Text=KEYBINDS[hk.key] and tostring(KEYBINDS[hk.key]):gsub("Enum.KeyCode.","") or "-- clique para definir --"
		_keyBindLabels[hk.key]=keyBtn
		keyBtn.MouseButton1Click:Connect(function()
			waitingForKey=hk.key; keyBtn.Text=">> pressione uma tecla <<"; keyBtn.TextColor3=C.textSec
		end)
	end
	makeSpacer(p,10,30)

	-- ── Changelog ──
	makeGroupHeader(p,"Changelog",31); makeSpacer(p,3,32)
	local changes={
		{"v7.0","Sistema HWID, particulas, temas, perfis, hotkeys, watermark"},
		{"v6.x","Aimbot silencioso, FOV circle, radar 2D, vision cone"},
		{"v5.x","ESP completo, skeleton, tracers, health bar"},
		{"v4.x","Combat: bhop, noclip, spinbot, bighead"},
	}
	for i,ch in ipairs(changes) do
		local row=Instance.new("Frame",p); row.Size=UDim2.new(1,0,0,40); row.BackgroundColor3=C.card; row.BorderSizePixel=0; row.LayoutOrder=32+i; Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
		local dot=Instance.new("Frame",row); dot.Size=UDim2.new(0,3,0.6,0); dot.Position=UDim2.new(0,0,0.2,0); dot.BackgroundColor3=C.accent; dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
		local ver=Instance.new("TextLabel",row); ver.Size=UDim2.new(0,38,0,18); ver.Position=UDim2.new(0,10,0.5,-9); ver.BackgroundColor3=C.accentGlow; ver.Text=ch[1]; ver.TextColor3=C.accentLight; ver.Font=Enum.Font.GothamBold; ver.TextSize=9; Instance.new("UICorner",ver).CornerRadius=UDim.new(0,4)
		local desc=Instance.new("TextLabel",row); desc.Size=UDim2.new(1,-58,1,0); desc.Position=UDim2.new(0,52,0,0); desc.BackgroundTransparency=1; desc.Text=ch[2]; desc.TextColor3=C.textSec; desc.Font=Enum.Font.Gotham; desc.TextSize=10; desc.TextXAlignment=Enum.TextXAlignment.Left; desc.TextWrapped=true
	end
	makeSpacer(p,10,40)

	-- ── Info ──
	makeGroupHeader(p,"Info",41); makeSpacer(p,3,42)
	local infoWrap=Instance.new("Frame",p); infoWrap.Size=UDim2.new(1,0,0,32); infoWrap.BackgroundColor3=C.card; infoWrap.BorderSizePixel=0; infoWrap.LayoutOrder=43; Instance.new("UICorner",infoWrap).CornerRadius=UDim.new(0,7)
	local iLbl=Instance.new("TextLabel",infoWrap); iLbl.Size=UDim2.new(1,-16,1,0); iLbl.Position=UDim2.new(0,8,0,0); iLbl.BackgroundTransparency=1; iLbl.Text="Purity v7.0  |  ID: "..tostring(LocalPlayer.UserId); iLbl.TextColor3=C.textDim; iLbl.Font=Enum.Font.Gotham; iLbl.TextSize=11; iLbl.TextXAlignment=Enum.TextXAlignment.Left
end
buildConfig()


switchPage("Aimbot")

-- Drag
local dragging=false; local dragStart=nil; local startPos=nil
Header.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=i.Position; startPos=Main.Position end
end)
Header.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
UserInputService.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-dragStart; Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
	end
end)

-- Fechar / Minimizar / Keybind
local minimized=false; local guiVisible=true
CloseBtn.MouseButton1Click:Connect(function()
	stopAimbotLoop(); stopSilentAim(); fovCircle.Visible=false
	for _,conn in pairs(combatConns) do pcall(function() conn:Disconnect() end) end
	if bhopConn then bhopConn:Disconnect() end
	if fastReloadConn then fastReloadConn:Disconnect() end
	if infiniteAmmoConn then infiniteAmmoConn:Disconnect() end
	for _,conn in pairs(miscConns) do pcall(function() conn:Disconnect() end) end
	if spinConn then spinConn:Disconnect() end
	if noclipConn then noclipConn:Disconnect() end
	if bigHeadConn then bigHeadConn:Disconnect() end
	if flyConn then flyConn:Disconnect() end
	if flyBV and flyBV.Parent then flyBV:Destroy() end
	if afkConn then afkConn:Disconnect() end
	restoreHeads()
	if MISC.CustomFOV then Camera.FieldOfView=originalFOV end
	if MISC.Noclip then local char=LocalPlayer.Character; if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
	local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed=16; hum.JumpPower=50; hum.PlatformStand=false end
	for _,plr in ipairs(Players:GetPlayers()) do clearESP(plr); clearSkeleton(plr); clearTracer(plr); clearHealthBar(plr) end
	hideRadar(); RadarGui.Visible=false
	TweenService:Create(Main,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1}):Play()
	task.delay(0.25,function() ScreenGui:Destroy() end)
end)
MinBtn.MouseButton1Click:Connect(function()
	minimized=not minimized
	if minimized then TweenService:Create(Main,TW_SLOW,{Size=UDim2.new(0,WIN_W,0,46)}):Play(); MinX.Text="+"
	else TweenService:Create(Main,TW_SLOW,{Size=UDim2.new(0,WIN_W,0,WIN_H)}):Play(); MinX.Text="-" end
end)
CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(68,22,32)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(48,26,30)}):Play() end)
MinBtn.MouseEnter:Connect(function() TweenService:Create(MinBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(38,34,62)}):Play() end)
MinBtn.MouseLeave:Connect(function() TweenService:Create(MinBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,28,46)}):Play() end)
UserInputService.InputBegan:Connect(function(input,gpe)
	if waitingForKey and input.UserInputType==Enum.UserInputType.Keyboard then
		local key=input.KeyCode
		if key~=Enum.KeyCode.Escape then
			KEYBINDS[waitingForKey]=key
			showToast("Tecla definida: "..tostring(key).." para "..waitingForKey,true)
		else
			KEYBINDS[waitingForKey]=nil
			showToast("Keybind removido.",false)
		end
		if _keyBindLabels and _keyBindLabels[waitingForKey] then
			_keyBindLabels[waitingForKey].Text=KEYBINDS[waitingForKey] and tostring(KEYBINDS[waitingForKey]):gsub("Enum.KeyCode.","") or "-- NENHUMA --"
		end
		waitingForKey=nil
		return
	end
	if gpe then return end
	if input.KeyCode==Enum.KeyCode.RightShift then guiVisible=not guiVisible; Main.Visible=guiVisible end
	if KEYBINDS.ESPKey and input.KeyCode==KEYBINDS.ESPKey then
		ESP.Enabled=not ESP.Enabled
		if toggleSetters["ESP.Enabled"] then toggleSetters["ESP.Enabled"](ESP.Enabled) end
		onESPToggle(ESP.Enabled)
		showToast((ESP.Enabled and "[ON]  " or "[OFF] ").."ESP",ESP.Enabled)
	end
	if KEYBINDS.BigHeadKey and input.KeyCode==KEYBINDS.BigHeadKey then
		MISC.BigHead=not MISC.BigHead
		if toggleSetters["MISC.BigHead"] then toggleSetters["MISC.BigHead"](MISC.BigHead) end
		onBigHeadToggle(MISC.BigHead)
		showToast((MISC.BigHead and "[ON]  " or "[OFF] ").."Big Head",MISC.BigHead)
	end
	if KEYBINDS.AimbotKey and input.KeyCode==KEYBINDS.AimbotKey then
		AIMBOT.Enabled=not AIMBOT.Enabled
		if toggleSetters["AIMBOT.Enabled"] then toggleSetters["AIMBOT.Enabled"](AIMBOT.Enabled) end
		if AIMBOT.Enabled then startAimbotLoop() else stopAimbotLoop() end
		showToast((AIMBOT.Enabled and "[ON]  " or "[OFF] ").."Aimbot",AIMBOT.Enabled)
	end
	if KEYBINDS.SilentKey and input.KeyCode==KEYBINDS.SilentKey then
		AIMBOT.Silent=not AIMBOT.Silent
		if toggleSetters["AIMBOT.Silent"] then toggleSetters["AIMBOT.Silent"](AIMBOT.Silent) end
		if AIMBOT.Silent then startSilentAim() else stopSilentAim() end
		showToast((AIMBOT.Silent and "[ON]  " or "[OFF] ").."Silent Aim",AIMBOT.Silent)
	end
	if KEYBINDS.NoclipKey and input.KeyCode==KEYBINDS.NoclipKey then
		MISC.Noclip=not MISC.Noclip
		if toggleSetters["MISC.Noclip"] then toggleSetters["MISC.Noclip"](MISC.Noclip) end
		onNoclipToggle(MISC.Noclip)
		showToast((MISC.Noclip and "[ON]  " or "[OFF] ").."Noclip",MISC.Noclip)
	end
end)

-- RGB Header
local dotHue=0
RunService.Heartbeat:Connect(function(dt)
	dotHue=(dotHue+dt*0.09)%1
	local rgb=Color3.fromHSV(dotHue,0.75,1)
	LogoDot.BackgroundColor3=rgb
	HDivider.BackgroundColor3=Color3.fromHSV(dotHue,0.6,0.5)
	if ESP.RGB and AIMBOT.FOVCircle then fovCircle.Color=rgb else fovCircle.Color=C.accent end
end)

-- Animacao de entrada
startAimbotLoop()
Main.Size=UDim2.new(0,WIN_W,0,0); Main.BackgroundTransparency=0.7
TweenService:Create(Main,TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,WIN_W,0,WIN_H),BackgroundTransparency=0}):Play()

end -- fim de loadMainGUI (so executa apos key valida)

