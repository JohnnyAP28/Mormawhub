--[[
    MormawHub - UI + desempenho local
    Projeto inicial para publicar no GitHub.
    Observação: não contém automação de farm, roubo, teleporte ou chamadas
    a RemoteEvents de jogos de terceiros. Use mecânicas de gameplay apenas
    em experiências que você controla/autorizou.
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Evita duplicar a interface ao executar novamente.
local previous = playerGui:FindFirstChild("MormawHubGui")
if previous then
    previous:Destroy()
end

local original = {
    GlobalShadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    Technology = Lighting.Technology,
}

local effectsSnapshot = {}
for _, obj in ipairs(Lighting:GetChildren()) do
    if obj:IsA("PostEffect") then
        effectsSnapshot[obj] = obj.Enabled
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "MormawHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 999
gui.Parent = playerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(57, 62, 76)
    s.Thickness = 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function label(parent, text, size, position, fontSize, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.Size = size
    l.Position = position
    l.Font = Enum.Font.Gotham
    l.TextSize = fontSize or 13
    l.TextColor3 = color or Color3.fromRGB(230, 232, 240)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = parent
    return l
end

local function button(parent, text, size, position)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(29, 32, 42)
    b.TextColor3 = Color3.fromRGB(238, 240, 246)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 9)
    return b
end

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(390, 360)
panel.BackgroundColor3 = Color3.fromRGB(13, 15, 21)
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 16)
stroke(panel, Color3.fromRGB(50, 55, 69), 0.1)

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MinSize = Vector2.new(300, 300)
sizeLimit.MaxSize = Vector2.new(460, 460)
sizeLimit.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 66)
header.BackgroundColor3 = Color3.fromRGB(19, 22, 30)
header.BorderSizePixel = 0
header.Parent = panel
corner(header, 16)

local flag = label(header, "🇧🇷", UDim2.fromOffset(42, 42), UDim2.fromOffset(14, 12), 25)
flag.TextXAlignment = Enum.TextXAlignment.Center
flag.BackgroundColor3 = Color3.fromRGB(31, 35, 47)
flag.BackgroundTransparency = 0
corner(flag, 12)

label(header, "MORMAWHUB", UDim2.new(1, -150, 0, 24), UDim2.fromOffset(65, 12), 15)
label(header, "BRASIL  •  LOCAL UI", UDim2.new(1, -150, 0, 17), UDim2.fromOffset(65, 35), 9, Color3.fromRGB(143, 149, 165))

local minimize = button(header, "—", UDim2.fromOffset(34, 34), UDim2.new(1, -82, 0, 16))
local close = button(header, "×", UDim2.fromOffset(34, 34), UDim2.new(1, -42, 0, 16))

local tabs = Instance.new("Frame")
tabs.BackgroundTransparency = 1
tabs.Position = UDim2.fromOffset(14, 78)
tabs.Size = UDim2.new(1, -28, 0, 34)
tabs.Parent = panel

local homeTab = button(tabs, "Início", UDim2.new(0.33, -5, 1, 0), UDim2.fromOffset(0, 0))
local performanceTab = button(tabs, "Desempenho", UDim2.new(0.34, -5, 1, 0), UDim2.new(0.33, 3, 0, 0))
local aboutTab = button(tabs, "Sobre", UDim2.new(0.33, -5, 1, 0), UDim2.new(0.67, 5, 0, 0))

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Position = UDim2.fromOffset(16, 124)
content.Size = UDim2.new(1, -32, 1, -140)
content.Parent = panel

local status = label(content, "Interface carregada. Escolha uma seção.", UDim2.new(1, 0, 0, 42), UDim2.fromOffset(0, 0), 13)
status.TextYAlignment = Enum.TextYAlignment.Top

local function makeAction(text, y)
    local b = button(content, text, UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, y))
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "   " .. text
    return b
end

local lowGraphics = makeAction("Ativar gráficos baixos", 50)
local shadows = makeAction("Desativar sombras globais", 96)
local effects = makeAction("Desativar efeitos pós-processamento", 142)
local restore = makeAction("Restaurar configurações guardadas", 188)

local function showPage(page)
    status.Visible = page == "home" or page == "about"
    lowGraphics.Visible = page == "performance"
    shadows.Visible = page == "performance"
    effects.Visible = page == "performance"
    restore.Visible = page == "performance"

    if page == "home" then
        status.Text = "MormawHub está ativo.\nUse Desempenho para reduzir efeitos locais."
    elseif page == "about" then
        status.Text = "MormawHub • Projeto brasileiro 🇧🇷\nInterface local de demonstração. Não executa farm, roubo ou teleporte."
    else
        status.Text = "Ajustes locais de iluminação e efeitos."
    end
end

homeTab.Activated:Connect(function() showPage("home") end)
performanceTab.Activated:Connect(function() showPage("performance") end)
aboutTab.Activated:Connect(function() showPage("about") end)

local function setEffectsEnabled(enabled)
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") then
            obj.Enabled = enabled
        end
    end
end

lowGraphics.Activated:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.FogEnd = 100000
    setEffectsEnabled(false)
    status.Text = "Perfil baixo aplicado: sombras e efeitos locais desativados."
    status.Visible = true
end)

shadows.Activated:Connect(function()
    Lighting.GlobalShadows = not Lighting.GlobalShadows
    shadows.Text = Lighting.GlobalShadows and "   Desativar sombras globais" or "   Ativar sombras globais"
    status.Text = "Sombras globais: " .. (Lighting.GlobalShadows and "ativadas" or "desativadas")
    status.Visible = true
end)

effects.Activated:Connect(function()
    local anyEnabled = false
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") and obj.Enabled then
            anyEnabled = true
            break
        end
    end
    setEffectsEnabled(anyEnabled)
    effects.Text = anyEnabled and "   Desativar efeitos pós-processamento" or "   Ativar efeitos pós-processamento"
    status.Text = anyEnabled and "Efeitos pós-processamento desativados." or "Efeitos pós-processamento ativados."
    status.Visible = true
end)

restore.Activated:Connect(function()
    Lighting.GlobalShadows = original.GlobalShadows
    Lighting.Brightness = original.Brightness
    Lighting.FogEnd = original.FogEnd
    for obj, enabled in pairs(effectsSnapshot) do
        if obj and obj.Parent then
            obj.Enabled = enabled
        end
    end
    shadows.Text = Lighting.GlobalShadows and "   Desativar sombras globais" or "   Ativar sombras globais"
    status.Text = "Configurações de iluminação restauradas quando possível."
    status.Visible = true
end)

-- Ícone flutuante: ao minimizar, a janela desaparece por completo.
local reopen = button(gui, "🇧🇷", UDim2.fromOffset(54, 54), UDim2.new(0, 18, 0.5, -27))
reopen.Name = "MormawFloatingIcon"
reopen.TextSize = 24
reopen.Visible = false
reopen.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
stroke(reopen, Color3.fromRGB(55, 135, 85), 0)
corner(reopen, 18)

minimize.Activated:Connect(function()
    panel.Visible = false
    reopen.Visible = true
end)

reopen.Activated:Connect(function()
    panel.Visible = true
    reopen.Visible = false
end)

close.Activated:Connect(function()
    gui:Destroy()
end)

-- Arrastar painel pelo cabeçalho (mouse ou toque).
local dragging = false
local dragStart, startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

showPage("home")
