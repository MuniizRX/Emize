local _a=math.floor;local _b=math.pi;local _c=tostring;local _d=string.char
local _e=_a(_b*68)*1+69;if not(_c(_e):len()>0)then return end
local _f=_a(_b*14)*8+16;if not(_c(_f):len()>0)then return end

local _WU=(string.char(104,116,116,112,115,58,47,47,112,117)..string.char(114,105,116,121,45,97,117,116,104,46)..string.char(119,101,110,100,101,108,49,50,114,120)..string.char(46,119,111,114,107,101,114,115,46,100)..string.char(101,118))
local _SU=(string.char(104,116,116,112,115,58,47,47,103,105)..string.char(115,116,46,103,105,116,104,117,98,117)..string.char(115,101,114,99,111,110,116,101,110,116)..string.char(46,99,111,109,47,77,117,110,105,105)..string.char(122,82,88,47,49,54,102,55,53,98)..string.char(52,50,101,97,48,51,101,100,49,99)..string.char(50,56,97,55,97,57,100,55,99,100)..string.char(98,56,52,100,50,100,47,114,97,119)..string.char(47,112,117,114,105,116,121,95,111,98)..string.char(102,117,115,99,97,116,101,100,46,108)..string.char(117,97))
local _XK=137

local _b64=string.char(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47)

local function _dec(data)
	local r={}
	data=data:gsub("[^"..(_b64).."=]","")
	for i=1,#data,4 do
		local a=_b64:find(data:sub(i,i))-1
		local b=_b64:find(data:sub(i+1,i+1))-1
		local cv=data:sub(i+2,i+2)~="=" and (_b64:find(data:sub(i+2,i+2))-1) or 0
		local dv=data:sub(i+3,i+3)~="=" and (_b64:find(data:sub(i+3,i+3))-1) or 0
		local n=a*262144+b*4096+cv*64+dv
		r[#r+1]=string.char(bit32.rshift(n,16)%256)
		if data:sub(i+2,i+2)~="=" then r[#r+1]=string.char(bit32.rshift(n,8)%256) end
		if data:sub(i+3,i+3)~="=" then r[#r+1]=string.char(n%256) end
	end
	return table.concat(r)
end

local function _xd(cb64)
	local raw=_dec(cb64);local o={}
	for i=1,#raw do o[i]=string.char(bit32.bxor(raw:byte(i),_XK)) end
	return table.concat(o)
end

local _P=game:GetService(string.char(80,108,97,121,101,114,115))
local _T=game:GetService(string.char(84,119,101,101,110,83,101,114,118,105,99,101))
local _LP=_P.LocalPlayer
local _PG=_LP:WaitForChild(string.char(80,108,97,121,101,114,71,117,105))
local _HS=game:GetService(string.char(72,116,116,112,83,101,114,118,105,99,101))

local function _gh()
	local h=""
	pcall(function() h=tostring(game:GetService(string.char(82,98,120,65,110,97,108,121,116,105,99,115,83,101,114,118,105,99,101)):GetClientId()) end)
	if h=="" then h=tostring(_LP.UserId) end
	return h
end

local function _bl()
	local sg=Instance.new(string.char(83,99,114,101,101,110,71,117,105))
	sg.Name=string.char(80,117,114,105,116,121,76,100,114);sg.ResetOnSpawn=false
	sg.DisplayOrder=9999;sg.IgnoreGuiInset=true;sg.Parent=_PG

	-- Card maior para comportar o botão de copiar
	local card=Instance.new(string.char(70,114,97,109,101),sg)
	card.Size=UDim2.new(0,310,0,165)
	card.Position=UDim2.new(0.5,-155,1,20)
	card.BackgroundColor3=Color3.fromRGB(10,10,15);card.BorderSizePixel=0
	Instance.new(string.char(85,73,67,111,114,110,101,114),card).CornerRadius=UDim.new(0,12)
	local sk=Instance.new(string.char(85,73,83,116,114,111,107,101),card)
	sk.Color=Color3.fromRGB(80,36,180);sk.Thickness=1

	local bar=Instance.new(string.char(70,114,97,109,101),card)
	bar.Size=UDim2.new(1,0,0,3);bar.BackgroundColor3=Color3.fromRGB(110,50,230);bar.BorderSizePixel=0
	Instance.new(string.char(85,73,67,111,114,110,101,114),bar).CornerRadius=UDim.new(0,10)

	local tl=Instance.new(string.char(84,101,120,116,76,97,98,101,108),card)
	tl.Size=UDim2.new(1,0,0,28);tl.Position=UDim2.new(0,0,0,10)
	tl.BackgroundTransparency=1;tl.Text=string.char(80,85,82,73,84,89)
	tl.TextColor3=Color3.fromRGB(195,155,255);tl.Font=Enum.Font.GothamBold;tl.TextSize=16

	local sl=Instance.new(string.char(84,101,120,116,76,97,98,101,108),card)
	sl.Size=UDim2.new(1,-24,0,16);sl.Position=UDim2.new(0,12,0,44)
	sl.BackgroundTransparency=1;sl.Text=string.char(73,110,105,99,105,97,110,100,111,46,46,46)
	sl.TextColor3=Color3.fromRGB(130,115,170);sl.Font=Enum.Font.Gotham;sl.TextSize=11
	sl.TextXAlignment=Enum.TextXAlignment.Left

	local tr=Instance.new(string.char(70,114,97,109,101),card)
	tr.Size=UDim2.new(1,-24,0,4);tr.Position=UDim2.new(0,12,0,68)
	tr.BackgroundColor3=Color3.fromRGB(28,22,46);tr.BorderSizePixel=0
	Instance.new(string.char(85,73,67,111,114,110,101,114),tr).CornerRadius=UDim.new(1,0)

	local fi=Instance.new(string.char(70,114,97,109,101),tr)
	fi.Size=UDim2.new(0,0,1,0);fi.BackgroundColor3=Color3.fromRGB(110,50,230);fi.BorderSizePixel=0
	Instance.new(string.char(85,73,67,111,114,110,101,114),fi).CornerRadius=UDim.new(1,0)

	local sb=Instance.new(string.char(84,101,120,116,76,97,98,101,108),card)
	sb.Size=UDim2.new(1,-24,0,14);sb.Position=UDim2.new(0,12,0,82)
	sb.BackgroundTransparency=1;sb.Text=""
	sb.TextColor3=Color3.fromRGB(75,65,105);sb.Font=Enum.Font.Gotham;sb.TextSize=9
	sb.TextXAlignment=Enum.TextXAlignment.Left

	-- Botão copiar HWID (invisível por padrão, só aparece quando HWID não autorizado)
	local cb=Instance.new(string.char(84,101,120,116,66,117,116,116,111,110),card)
	cb.Size=UDim2.new(1,-24,0,30);cb.Position=UDim2.new(0,12,0,104)
	cb.BackgroundColor3=Color3.fromRGB(28,22,44);cb.BorderSizePixel=0
	cb.Text=utf8.char(128203).." Copiar meu HWID"
	cb.TextColor3=Color3.fromRGB(145,85,255);cb.Font=Enum.Font.GothamBold;cb.TextSize=11
	cb.Visible=false;cb.ZIndex=5
	Instance.new(string.char(85,73,67,111,114,110,101,114),cb).CornerRadius=UDim.new(0,7)
	local cbs=Instance.new(string.char(85,73,83,116,114,111,107,101),cb)
	cbs.Color=Color3.fromRGB(80,40,160);cbs.Thickness=1

	-- Hover do botão copiar
	cb.MouseEnter:Connect(function()
		_T:Create(cb,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(44,32,70)}):Play()
	end)
	cb.MouseLeave:Connect(function()
		if cb.Text~=utf8.char(10003).." Copiado!" then
			_T:Create(cb,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,22,44)}):Play()
		end
	end)

	_T:Create(card,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
		{Position=UDim2.new(0.5,-155,1,-180)}):Play()

	local function ss(msg,pct,col)
		sl.Text=msg;if col then sl.TextColor3=col end
		_T:Create(fi,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Size=UDim2.new(pct,0,1,0)}):Play()
	end
	local function sb2(msg,col) sb.Text=msg;sb.TextColor3=col or Color3.fromRGB(75,65,105) end
	local function se()
		_T:Create(fi,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(180,40,70)}):Play()
		_T:Create(bar,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(180,40,70)}):Play()
		sk.Color=Color3.fromRGB(140,30,60)
	end
	local function sv()
		_T:Create(fi,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(40,180,90)}):Play()
		_T:Create(bar,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(40,180,90)}):Play()
		sk.Color=Color3.fromRGB(30,140,70)
	end
	local function cl(d)
		task.delay(d or 1.2,function()
			_T:Create(card,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
				{Position=UDim2.new(0.5,-155,1,20)}):Play()
			task.delay(0.35,function() pcall(function() sg:Destroy() end) end)
		end)
	end
	-- Retorna também o botão copiar (cb) e o stroke (cbs)
	return ss,sb2,se,sv,cl,cb,cbs
end

task.spawn(function()
	local ss,sb,se,sv,cl,cb,cbs=_bl()
	ss(string.char(67,111,108,101,116,97,110,100,111,32,73,68,46,46,46),0.1)
	task.wait(0.3)
	local hw=_gh()
	sb("ID: "..hw)
	ss(string.char(86,101,114,105,102,105,99,97,110,100,111,46,46,46),0.3)
	task.wait(0.3)

	local cu=_WU..string.char(47,99,104,101,99,107,63,104,119,105,100,61)..hw..string.char(38,116,61)..tostring(tick())
	local ok,rp=pcall(function() return game:HttpGet(cu) end)
	if not ok or not rp then
		se()
		ss(string.char(69,114,114,111,32,100,101,32,99,111,110,101,120,227,111,46),0.3,Color3.fromRGB(200,80,100))
		cl(4);return
	end

	local dt
	pcall(function() dt=game:GetService(string.char(72,116,116,112,83,101,114,118,105,99,101)):JSONDecode(rp) end)
	if not dt then se();ss(string.char(82,101,115,112,111,115,116,97,32,105,110,118,225,108,105,100,97,46),0.3,Color3.fromRGB(200,80,100));cl(3);return end

	if not dt.ok then
		se()
		if dt.reason==string.char(101,120,112,105,114,101,100) then
			ss(string.char(65,99,101,115,115,111,32,101,120,112,105,114,97,100,111,46),0.4,Color3.fromRGB(200,80,100))
			sb(string.char(67,111,110,116,97,116,101,32,111,32,118,101,110,100,101,100,111,114,46),Color3.fromRGB(180,70,90))
		else
			ss(string.char(72,87,73,68,32,110,227,111,32,97,117,116,111,114,105,122,97,100,111,46),0.4,Color3.fromRGB(200,80,100))
			sb("HWID: "..hw,Color3.fromRGB(220,160,80))
			-- Exibe o botão de copiar HWID
			cb.Visible=true
			cb.MouseButton1Click:Connect(function()
				pcall(function() setclipboard(hw) end)
				cb.Text=utf8.char(10003).." Copiado!"
				cb.TextColor3=Color3.fromRGB(0,205,95)
				cbs.Color=Color3.fromRGB(0,130,65)
				game:GetService(string.char(84,119,101,101,110,83,101,114,118,105,99,101)):Create(cb,TweenInfo.new(0.1),
					{BackgroundColor3=Color3.fromRGB(0,40,20)}):Play()
				task.delay(2,function()
					cb.Text=utf8.char(128203).." Copiar meu HWID"
					cb.TextColor3=Color3.fromRGB(145,85,255)
					cbs.Color=Color3.fromRGB(80,40,160)
					game:GetService(string.char(84,119,101,101,110,83,101,114,118,105,99,101)):Create(cb,TweenInfo.new(0.1),
						{BackgroundColor3=Color3.fromRGB(28,22,44)}):Play()
				end)
			end)
		end
		cl(6);return
	end

	local dias=type(dt.days)=="number" and dt.days or 0
	sv()
	ss(string.char(65,99,101,115,115,111,32,108,105,98,101,114,97,100,111,33,32,67,97,114,114,101,103,97,110,100,111,46,46,46),0.7,Color3.fromRGB(100,220,140))
	sb(tostring(dias)..string.char(100,32,100,105,97,40,115,41,32,114,101,115,116,97,110,116,101,115),Color3.fromRGB(80,200,120))
	task.wait(0.4)

	ss(string.char(66,97,105,120,97,110,100,111,46,46,46),0.85)
	local sok,sraw=pcall(function()
		return game:HttpGet(_SU..string.char(63,116,61)..tostring(tick()))
	end)
	if not sok or not sraw or #sraw<10 then
		se();ss(string.char(69,114,114,111,32,97,111,32,98,97,105,120,97,114,32,115,99,114,105,112,116,46),0.85,Color3.fromRGB(200,80,100));cl(3);return
	end

	ss(string.char(73,110,105,99,105,97,110,100,111,32,80,117,114,105,116,121,46,46,46),0.95)
	task.wait(0.2)

	local src
	local dok,dres=pcall(_xd,sraw:match("^%s*(.-)%s*$"))
	if dok and #dres>100 then src=dres else src=sraw end

	local fn,ce=loadstring(src)
	if not fn then
		se();ss(string.char(83,99,114,105,112,116,32,105,110,118,225,108,105,100,111,58,32)..tostring(ce):sub(1,40),0.95,Color3.fromRGB(200,80,100));cl(5);return
	end
	local eo,ee=pcall(fn)
	if not eo then
		se();ss(string.char(69,114,114,111,58,32)..tostring(ee):sub(1,50),0.95,Color3.fromRGB(200,80,100));cl(4);return
	end

	ss(string.char(80,117,114,105,116,121,32,99,97,114,114,101,103,97,100,111,33,32)..tostring(dias)..string.char(100,32,114,101,115,116,97,110,116,101,115),1.0,Color3.fromRGB(100,220,140))
	cl(1.5)
end)
