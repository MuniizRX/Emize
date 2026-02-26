local _OoiLl0o0=math.floor(math.pi*68)
local _oI0I0i0L=_OoiLl0o0*1+69
local _LoOIO0IO=tostring(_oI0I0i0L):len()
local _lliiol0i=_LoOIO0IO>0 and true or false
if not _lliiol0i then return end
local _iiLooIOo=math.floor(math.pi*14)
local _00looOIi=_iiLooIOo*8+16
local _li0oIOOL=tostring(_00looOIi):len()
local _lIIIOolI=_li0oIOOL>0 and true or false
if not _lIIIOolI then return end



local KEYS_GIST   = (string.char(104,116,116,112,115,58)..string.char(47,47,103,105,115,116,46,103,105,116,104,117,98,117)..string.char(115,101,114,99,111,110,116,101,110,116)..string.char(46,99,111,109,47,77,117,110,105,105,122)..string.char(82,88,47,56,98,55,97)..string.char(56,49,100,50,55,98,56,48,48)..string.char(51,53,98,99,101,50,57,56,53,49,101,97)..string.char(57,50,98,51,98,97,56,47,114,97,119,47,112,117)..string.char(114,105,116,121,95,107)..string.char(101,121,115,46,116,120,116))
local SCRIPT_GIST = (string.char(104,116,116,112,115,58,47)..string.char(47,103,105,115,116,46,103,105,116,104,117,98,117,115)..string.char(101,114,99,111,110,116,101,110,116,46,99,111,109,47)..string.char(77,117,110,105,105,122,82)..string.char(88,47,49,54,102,55,53)..string.char(98,52,50,101,97,48,51,101,100,49,99)..string.char(50,56,97,55,97,57,100,55,99,100,98,56,52,100)..string.char(50,100,47,114,97,119,47,112,117,114,105,116,121)..string.char(95,111,98,102,117,115,99,97,116,101)..string.char(100,46,108,117,97))

local function _OioOIOiL()
    local hwid = ""

    
    pcall(function()
        hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    end)

    
    if hwid == "" then
        hwid = tostring(game:GetService("Players").LocalPlayer.UserId)
    end

    return hwid
end

local function _IoiiO00l(hwid, gistContent)
    
    for line in gistContent:gmatch("[^\n]+") do
        
        if line:sub(1, 1) ~= "#" and line:gsub("%s", "") ~= "" then
            
            local lineHWID = line:match("^([^|]+)|")
            local expStr   = line:match("^[^|]+|([^|]+)")

            if lineHWID and expStr then
                lineHWID = lineHWID:gsub("%s", "")
                expStr   = expStr:gsub("%s", "")

                
                if lineHWID == hwid then
                    
                    local expY, expM, expD = expStr:match("(%d+)-(%d+)-(%d+)")
                    if expY and expM and expD then
                        
                        
                        local nowY = tonumber(os.date("%Y"))
                        local nowM = tonumber(os.date("%m"))
                        local nowD = tonumber(os.date("%d"))
                        expY = tonumber(expY)
                        expM = tonumber(expM)
                        expD = tonumber(expD)

                        
                        local nowStamp = nowY * 10000 + nowM * 100 + nowD
                        local expStamp = expY * 10000 + expM * 100 + expD

                        if nowStamp <= expStamp then
                            
                            local daysLeft = (expStamp - nowStamp)
                            
                            return true, daysLeft
                        else
                            return false, string.char(101,120,112,105,114,97,100,111)
                        end
                    end
                end
            end
        end
    end
    return false, string.char(110,97,111,95,101,110,99,111,110,116,114,97,100,111)
end

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

local function _I00oloOo()
    local sg = Instance.new("ScreenGui")
    sg.Name = string.char(80,117,114,105,116,121,76,111,97,100,101,114); sg.ResetOnSpawn = false
    sg.DisplayOrder = 9999; sg.IgnoreGuiInset = true
    sg.Parent = PlayerGui

    
    local card = Instance.new("Frame", sg)
    card.Size = UDim2.new(0, 300, 0, 155)
    card.Position = UDim2.new(0.5, -150, 1, 20)
    card.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(80, 36, 180); cardStroke.Thickness = 1

    
    local topBar = Instance.new("Frame", card)
    topBar.Size = UDim2.new(1, 0, 0, 3)
    topBar.BackgroundColor3 = Color3.fromRGB(110, 50, 230)
    topBar.BorderSizePixel = 0
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

    
    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, 0, 0, 26)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = string.char(80,85,82,73,84,89)
    title.TextColor3 = Color3.fromRGB(195, 155, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 17

    
    local statusLbl = Instance.new("TextLabel", card)
    statusLbl.Size = UDim2.new(1, -24, 0, 14)
    statusLbl.Position = UDim2.new(0, 12, 0, 42)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = string.char(73,110,105,99,105,97,110,100,111,46,46,46)
    statusLbl.TextColor3 = Color3.fromRGB(130, 115, 170)
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 11
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

    
    local track = Instance.new("Frame", card)
    track.Size = UDim2.new(1, -24, 0, 4)
    track.Position = UDim2.new(0, 12, 0, 64)
    track.BackgroundColor3 = Color3.fromRGB(30, 26, 46)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(110, 50, 230)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    
    local hwidLbl = Instance.new("TextLabel", card)
    hwidLbl.Size = UDim2.new(1, -24, 0, 13)
    hwidLbl.Position = UDim2.new(0, 12, 0, 80)
    hwidLbl.BackgroundTransparency = 1
    hwidLbl.Text = ""
    hwidLbl.TextColor3 = Color3.fromRGB(75, 65, 105)
    hwidLbl.Font = Enum.Font.Gotham
    hwidLbl.TextSize = 9
    hwidLbl.TextXAlignment = Enum.TextXAlignment.Left

    
    local copyBtn = Instance.new("TextButton", card)
    copyBtn.Size = UDim2.new(1, -24, 0, 28)
    copyBtn.Position = UDim2.new(0, 12, 0, 100)
    copyBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 44)
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = utf8.char(128203,32,32,67,111,112,105,97,114,32,109,101,117,32,72,87,73,68)
    copyBtn.TextColor3 = Color3.fromRGB(145, 85, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 11
    copyBtn.Visible = false
    copyBtn.ZIndex = 5
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 7)
    local copyStroke = Instance.new("UIStroke", copyBtn)
    copyStroke.Color = Color3.fromRGB(80, 40, 160)
    copyStroke.Thickness = 1

    copyBtn.MouseEnter:Connect(function()
        TweenService:Create(copyBtn, TweenInfo.new(0.1),
            {BackgroundColor3 = Color3.fromRGB(44, 32, 70)}):Play()
    end)
    copyBtn.MouseLeave:Connect(function()
        if copyBtn.Text ~= utf8.char(10003,32,32,67,111,112,105,97,100,111,33) then
            TweenService:Create(copyBtn, TweenInfo.new(0.1),
                {BackgroundColor3 = Color3.fromRGB(28, 22, 44)}):Play()
        end
    end)

    
    TweenService:Create(card,
        TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -150, 1, -170)}
    ):Play()

    local function setStatus(msg, pct, color)
        statusLbl.Text = msg
        if color then statusLbl.TextColor3 = color end
        TweenService:Create(fill,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Size = UDim2.new(pct, 0, 1, 0)}
        ):Play()
    end

    local function setHWIDLabel(msg, color)
        hwidLbl.Text = msg
        hwidLbl.TextColor3 = color or Color3.fromRGB(75, 65, 105)
    end

    local function close(delay)
        task.delay(delay or 1.2, function()
            TweenService:Create(card,
                TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                {Position = UDim2.new(0.5, -150, 1, 20)}
            ):Play()
            task.delay(0.35, function()
                pcall(function() sg:Destroy() end)
            end)
        end)
    end

    return setStatus, setHWIDLabel, close, fill, topBar, copyBtn, copyStroke
end

local setStatus,setHWIDLabel,closeLoader,fillBar,topBar,copyBtn,copyStroke=_I00oloOo()

task.spawn(function()
local _IO0OLoiO=math.floor(math.pi*2)
local _i0olI00l=_IO0OLoiO*3+24
local _000L0I0i=tostring(_i0olI00l):len()
local _ILLo0iOO=_000L0I0i>0 and true or false
if not _ILLo0iOO then return end


    
    setStatus(string.char(67,111,108,101,116,97,110,100,111,32,105,100,101,110,116,105,102,105,99,97,100,111,114,46,46,46), 0.1)
    task.wait(0.4)
    local hwid = _OioOIOiL()
    setHWIDLabel("ID: " .. hwid)
    setStatus(string.char(86,101,114,105,102,105,99,97,110,100,111,32,97,99,101,115,115,111,46,46,46), 0.3)
    task.wait(0.3)

    
    local keysOk, keysContent = pcall(function()
        return game:HttpGet(KEYS_GIST .. string.char(63,110,111,99,97,99,104,101,61) .. tostring(tick()))
    end)

    if not keysOk or not keysContent then
        setStatus(string.char(69,114,114,111,32,97,111,32,99,111,110,101,99,116,97,114,46,32,84,101,110,116,101,32,110,111,118,97,109,101,110,116,101,46), 0.3,
            Color3.fromRGB(200, 80, 100))
        setHWIDLabel(string.char(83,101,109,32,99,111,110,101,120,97,111,32,99,111,109,32,111,32,115,101,114,118,105,100,111,114,32,100,101,32,108,105,99,101,110,99,97,115,46),
            Color3.fromRGB(180, 70, 90))
        closeLoader(3)
        return
    end

    
    local allowed, info = _IoiiO00l(hwid, keysContent)

    if not allowed then
        
        TweenService:Create(fillBar,
            TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 40, 70)}):Play()
        TweenService:Create(topBar,
            TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 40, 70)}):Play()

        if info == string.char(101,120,112,105,114,97,100,111) then
            setStatus(string.char(65,99,101,115,115,111,32,101,120,112,105,114,97,100,111,46), 0.4, Color3.fromRGB(200, 80, 100))
            setHWIDLabel(string.char(83,101,117,32,97,99,101,115,115,111,32,118,101,110,99,101,117,46,32,67,111,110,116,97,116,101,32,111,32,118,101,110,100,101,100,111,114,46),
                Color3.fromRGB(180, 70, 90))
        else
            setStatus(string.char(72,87,73,68,32,110,97,111,32,97,117,116,111,114,105,122,97,100,111,46), 0.4, Color3.fromRGB(200, 80, 100))
            setHWIDLabel("Seu HWID: " .. hwid, Color3.fromRGB(220, 160, 80))
            
            copyBtn.Visible = true
            copyBtn.MouseButton1Click:Connect(function()
                pcall(function() setclipboard(hwid) end)
                copyBtn.Text = utf8.char(10003,32,32,67,111,112,105,97,100,111,33)
                copyBtn.TextColor3 = Color3.fromRGB(0, 205, 95)
                copyStroke.Color = Color3.fromRGB(0, 130, 65)
                TweenService:Create(copyBtn, TweenInfo.new(0.1),
                    {BackgroundColor3 = Color3.fromRGB(0, 40, 20)}):Play()
                task.delay(2, function()
                    copyBtn.Text = utf8.char(128203,32,32,67,111,112,105,97,114,32,109,101,117,32,72,87,73,68)
                    copyBtn.TextColor3 = Color3.fromRGB(145, 85, 255)
                    copyStroke.Color = Color3.fromRGB(80, 40, 160)
                    TweenService:Create(copyBtn, TweenInfo.new(0.1),
                        {BackgroundColor3 = Color3.fromRGB(28, 22, 44)}):Play()
                end)
            end)
        end

        closeLoader(5)
        return
    end

    
    setStatus(string.char(65,99,101,115,115,111,32,108,105,98,101,114,97,100,111,33,32,67,97,114,114,101,103,97,110,100,111,46,46,46), 0.65,
        Color3.fromRGB(100, 220, 140))
    TweenService:Create(fillBar,
        TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 180, 90)}):Play()
    TweenService:Create(topBar,
        TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 180, 90)}):Play()
    task.wait(0.4)

    local scriptOk, scriptContent = pcall(function()
        return game:HttpGet(SCRIPT_GIST .. string.char(63,110,111,99,97,99,104,101,61) .. tostring(tick()))
    end)

    if not scriptOk or not scriptContent or #scriptContent < 10 then
        setStatus(string.char(69,114,114,111,32,97,111,32,98,97,105,120,97,114,32,111,32,115,99,114,105,112,116,46), 0.65,
            Color3.fromRGB(200, 80, 100))
        closeLoader(3)
        return
    end

    
    setStatus(string.char(73,110,105,99,105,97,110,100,111,32,80,117,114,105,116,121,46,46,46), 0.88)
    task.wait(0.3)

    local fn = loadstring(scriptContent)
    if not fn then
        setStatus(string.char(83,99,114,105,112,116,32,105,110,118,97,108,105,100,111,33), 0.88, Color3.fromRGB(200, 80, 100))
        setHWIDLabel("Primeiros chars: " .. scriptContent:sub(1, 60))
        closeLoader(8)
        return
    end
    
    local execOk, execErr = pcall(fn)
    if not execOk then
        setStatus("Erro: " .. tostring(execErr):sub(1, 40), 0.88, Color3.fromRGB(200, 80, 100))
        closeLoader(4)
        return
    end

    
    local diasMsg = type(info) == "number"
        and ("  |  " .. tostring(info) .. "d restantes")
        or ""
    setStatus(string.char(80,117,114,105,116,121,32,99,97,114,114,101,103,97,100,111,33) .. diasMsg, 1.0,
        Color3.fromRGB(100, 220, 140))
    closeLoader(1.5)
end)