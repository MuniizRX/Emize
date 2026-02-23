--[[
    Advanced ESP | Highlight + Tracers RGB
    By ChatGPT
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP = {
    Enabled = true,
    ShowTeammates = false,
    RGBSpeed = 2,
    Thickness = 2
}

local Highlights = {}
local Tracers = {}

-- ============================
-- RGB animado
-- ============================
local function RGB()
    local t = tick() * ESP.RGBSpeed
    return Color3.fromHSV((t % 5) / 5, 1, 1)
end

-- ============================
-- Checar inimigo
-- ============================
local function IsEnemy(player)
    if not LocalPlayer.Team or not player.Team then
        return true
    end
    return player.Team ~= LocalPlayer.Team
end

-- ============================
-- Criar Highlight
-- ============================
local function CreateHighlight(player)
    if Highlights[player] then return end

    local h = Instance.new("Highlight")
    h.FillTransparency = 0.4
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = workspace

    Highlights[player] = h
end

-- ============================
-- Criar Tracer
-- ============================
local function CreateTracer(player)
    if Tracers[player] then return end

    local line = Drawing.new("Line")
    line.Thickness = ESP.Thickness
    line.Transparency = 1

    Tracers[player] = line
end

-- ============================
-- Atualizar ESP
-- ============================
local function Update()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Highlights[player] then CreateHighlight(player) end
            if not Tracers[player] then CreateTracer(player) end

            local highlight = Highlights[player]
            local tracer = Tracers[player]

            local enemy = IsEnemy(player)

            if ESP.ShowTeammates or enemy then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart

                    highlight.Adornee = player.Character
                    highlight.Enabled = true

                    local color = RGB()
                    highlight.FillColor = color
                    highlight.OutlineColor = color

                    local pos, visible = Camera:WorldToViewportPoint(hrp.Position)

                    if visible then
                        tracer.Visible = true
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Color = color
                    else
                        tracer.Visible = false
                    end
                else
                    highlight.Enabled = false
                    tracer.Visible = false
                end
            else
                highlight.Enabled = false
                tracer.Visible = false
            end
        end
    end
end

-- ============================
-- Limpeza
-- ============================
local function Cleanup(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end

    if Tracers[player] then
        Tracers[player]:Remove()
        Tracers[player] = nil
    end
end

Players.PlayerRemoving:Connect(Cleanup)
Players.PlayerAdded:Connect(function(p)
    task.wait(1)
    CreateHighlight(p)
    CreateTracer(p)
end)

RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        Update()
    end
end)

-- ============================
-- Atalhos teclado
-- ============================
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.RightBracket then
        ESP.Enabled = not ESP.Enabled
    end

    if input.KeyCode == Enum.KeyCode.LeftBracket then
        ESP.ShowTeammates = not ESP.ShowTeammates
    end
end)

print("ESP Highlight + Tracers RGB carregado com sucesso!")
print("[ ] = Liga/Desliga | [ [ ] ] = Mostrar times")