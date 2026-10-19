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
panel.Size = UDim2.fromOffset(390, 410)
panel.BackgroundColor3 = Color3.fromRGB(13, 15, 21)
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 16)
stroke(panel, Color3.fromRGB(50, 55, 69), 0.1)

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MinSize = Vector2.new(300, 300)
sizeLimit.MaxSize = Vector2.new(460, 520)
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

local homeTab = button(tabs, "Início", UDim2.new(0.25, -5, 1, 0), UDim2.fromOffset(0, 0))
local halloweenTab = button(tabs, "Halloween", UDim2.new(0.25, -5, 1, 0), UDim2.new(0.25, 2, 0, 0))
local performanceTab = button(tabs, "Gráficos", UDim2.new(0.25, -5, 1, 0), UDim2.new(0.50, 4, 0, 0))
local settingsTab = button(tabs, "Ajustes", UDim2.new(0.25, -5, 1, 0), UDim2.new(0.75, 6, 0, 0))

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

-- Rastreador manual do evento: não lê nem altera o estado do jogo.
local trackerState = {}
local trackerItems = {
    "Echo: encontrar o colar",
    "Echo: encontrar o osso",
    "Echo: encontrar o ursinho",
    "Echo: encontrar a foto fantasma",
    "Falar com o Ghost Fisherman",
    "Conseguir a Haunted Rod",
    "Pescar e obter o ticket do Phantom Express",
    "Visitar o Phantom Express / área Spectral",
    "Coletar Candy Corn durante o evento",
}
for _, item in ipairs(trackerItems) do trackerState[item] = false end

local halloweenFrame = Instance.new("ScrollingFrame")
halloweenFrame.Name = "HalloweenTracker"
halloweenFrame.BackgroundTransparency = 1
halloweenFrame.BorderSizePixel = 0
halloweenFrame.Position = UDim2.fromOffset(0, 0)
halloweenFrame.Size = UDim2.new(1, 0, 1, 0)
halloweenFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
halloweenFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
halloweenFrame.ScrollBarThickness = 4
halloweenFrame.ScrollBarImageColor3 = Color3.fromRGB(91, 145, 105)
halloweenFrame.Visible = false
halloweenFrame.Parent = content

local trackerLayout = Instance.new("UIListLayout")
trackerLayout.Padding = UDim.new(0, 6)
trackerLayout.SortOrder = Enum.SortOrder.LayoutOrder
trackerLayout.Parent = halloweenFrame

local trackerPadding = Instance.new("UIPadding")
trackerPadding.PaddingRight = UDim.new(0, 5)
trackerPadding.PaddingBottom = UDim.new(0, 5)
trackerPadding.Parent = halloweenFrame

local trackerProgress = label(halloweenFrame, "Progresso do evento: 0/9", UDim2.new(1, -6, 0, 28), UDim2.new(), 13, Color3.fromRGB(125, 220, 157))
trackerProgress.LayoutOrder = 1

local trackerButtons = {}
local function refreshTracker()
    local done = 0
    for _, item in ipairs(trackerItems) do
        if trackerState[item] then done += 1 end
    end
    trackerProgress.Text = "Progresso do evento: " .. done .. "/" .. #trackerItems
    for item, b in pairs(trackerButtons) do
        b.Text = (trackerState[item] and "   ☑  " or "   □  ") .. item
        b.BackgroundColor3 = trackerState[item] and Color3.fromRGB(25, 57, 39) or Color3.fromRGB(29, 32, 42)
    end
end

for index, item in ipairs(trackerItems) do
    local b = button(halloweenFrame, "   □  " .. item, UDim2.new(1, -6, 0, 34), UDim2.new())
    b.LayoutOrder = index + 1
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextSize = 11
    trackerButtons[item] = b
    b.Activated:Connect(function()
        trackerState[item] = not trackerState[item]
        refreshTracker()
    end)
end

local trackerTips = label(halloweenFrame,
    "Dica: o checklist é manual e vale apenas enquanto esta interface estiver aberta. Os nomes e etapas podem mudar com atualizações.",
    UDim2.new(1, -6, 0, 46), UDim2.new(), 10, Color3.fromRGB(155, 161, 178))
trackerTips.LayoutOrder = #trackerItems + 2
trackerTips.TextYAlignment = Enum.TextYAlignment.Top

local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "SettingsPage"
settingsFrame.BackgroundTransparency = 1
settingsFrame.Position = UDim2.fromOffset(0, 0)
settingsFrame.Size = UDim2.new(1, 0, 1, 0)
settingsFrame.Visible = false
settingsFrame.Parent = content

local resetTracker = button(settingsFrame, "Zerar checklist do Halloween", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 0))
local toggleTips = button(settingsFrame, "Ocultar dicas do evento", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 48))
local tipsVisible = true
local settingsInfo = label(settingsFrame,
    "Preferências locais. O checklist não é enviado ao Roblox nem sincronizado entre sessões.",
    UDim2.new(1, 0, 0, 62), UDim2.fromOffset(0, 100), 11, Color3.fromRGB(155, 161, 178))
settingsInfo.TextYAlignment = Enum.TextYAlignment.Top

local function showPage(page)
    local isHome = page == "home"
    local isPerformance = page == "performance"
    local isHalloween = page == "halloween"
    local isSettings = page == "settings"
    status.Visible = isHome
    halloweenFrame.Visible = isHalloween
    settingsFrame.Visible = isSettings
    lowGraphics.Visible = isPerformance
    shadows.Visible = isPerformance
    effects.Visible = isPerformance
    restore.Visible = isPerformance

    if isHome then
        status.Text = "MormawHub está ativo.\nHalloween: checklist manual do evento.\nGráficos: ajustes locais de iluminação."
    elseif isPerformance then
        status.Text = "Ajustes locais de iluminação e efeitos."
    end
end

resetTracker.Activated:Connect(function()
    for _, item in ipairs(trackerItems) do trackerState[item] = false end
    refreshTracker()
    settingsInfo.Text = "Checklist zerado. Marque cada etapa conforme concluir no jogo."
end)

toggleTips.Activated:Connect(function()
    tipsVisible = not tipsVisible
    trackerTips.Visible = tipsVisible
    toggleTips.Text = tipsVisible and "Ocultar dicas do evento" or "Mostrar dicas do evento"
    settingsInfo.Text = tipsVisible and "Dicas ativadas no rastreador do Halloween." or "Dicas ocultadas no rastreador do Halloween."
end)

homeTab.Activated:Connect(function() showPage("home") end)
halloweenTab.Activated:Connect(function() showPage("halloween") end)
performanceTab.Activated:Connect(function() showPage("performance") end)
settingsTab.Activated:Connect(function() showPage("settings") end)

refreshTracker()

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
