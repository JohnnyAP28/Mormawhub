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
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

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
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogColor = Lighting.FogColor,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ExposureCompensation = Lighting.ExposureCompensation,
}

local effectsSnapshot = {}
local visualEffectsSnapshot = {}
local originalSkies = {}
for _, obj in ipairs(Lighting:GetChildren()) do
    if obj:IsA("PostEffect") then
        effectsSnapshot[obj] = obj.Enabled
    elseif obj:IsA("Sky") then
        table.insert(originalSkies, obj)
    end
end

local function isReducibleVisual(obj)
    return obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles")
        or obj:IsA("Highlight")
end

local function captureVisualEffects()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isReducibleVisual(obj) and visualEffectsSnapshot[obj] == nil then
            visualEffectsSnapshot[obj] = obj.Enabled
        end
    end
end
captureVisualEffects()

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
panel.Size = UDim2.fromOffset(420, 510)
panel.BackgroundColor3 = Color3.fromRGB(13, 15, 21)
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 16)
stroke(panel, Color3.fromRGB(50, 55, 69), 0.1)

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MinSize = Vector2.new(300, 300)
sizeLimit.MaxSize = Vector2.new(460, 600)
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

local homeTab = button(tabs, "Início", UDim2.new(1/6, -4, 1, 0), UDim2.fromOffset(0, 0))
local halloweenTab = button(tabs, "Halloween", UDim2.new(1/6, -4, 1, 0), UDim2.new(1/6, 1, 0, 0))
local performanceTab = button(tabs, "Gráficos", UDim2.new(1/6, -4, 1, 0), UDim2.new(2/6, 2, 0, 0))
local playerTab = button(tabs, "Player", UDim2.new(1/6, -4, 1, 0), UDim2.new(3/6, 3, 0, 0))
local testsTab = button(tabs, "Testes", UDim2.new(1/6, -4, 1, 0), UDim2.new(4/6, 4, 0, 0))
local settingsTab = button(tabs, "Ajustes", UDim2.new(1/6, -4, 1, 0), UDim2.new(5/6, 5, 0, 0))

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

local lowGraphics = makeAction("ULTRA LEVE — mínimo visual", 46)
local shadows = makeAction("BAIXO — desempenho", 84)
local effects = makeAction("MÉDIO — equilibrado", 122)
local highGraphics = makeAction("ALTO — qualidade visual", 160)
local realisticGraphics = makeAction("REALISTA — iluminação original", 198)
local blackSky = makeAction("Ativar céu totalmente escuro", 236)
local visualCleanup = makeAction("Reduzir partículas e efeitos animados", 274)
local restore = makeAction("Restaurar configurações guardadas", 312)
lowGraphics.Size = UDim2.new(1, 0, 0, 32)
shadows.Size = UDim2.new(1, 0, 0, 32)
effects.Size = UDim2.new(1, 0, 0, 32)
highGraphics.Size = UDim2.new(1, 0, 0, 32)
realisticGraphics.Size = UDim2.new(1, 0, 0, 32)
blackSky.Size = UDim2.new(1, 0, 0, 32)
visualCleanup.Size = UDim2.new(1, 0, 0, 32)
restore.Size = UDim2.new(1, 0, 0, 32)

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

local playerFrame = Instance.new("Frame")
playerFrame.Name = "PlayerPage"
playerFrame.BackgroundTransparency = 1
playerFrame.Position = UDim2.fromOffset(0, 0)
playerFrame.Size = UDim2.new(1, 0, 1, 0)
playerFrame.Visible = false
playerFrame.Parent = content

local playerInfo = label(playerFrame, "Carregando informações do personagem...", UDim2.new(1, 0, 0, 100), UDim2.fromOffset(0, 0), 12)
playerInfo.TextYAlignment = Enum.TextYAlignment.Top
local refreshPlayer = button(playerFrame, "Atualizar status do personagem", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 108))
local playerNotice = label(playerFrame,
    "Use Testes para controles experimentais. Eles são locais e podem ser corrigidos pelo servidor; valide a lógica de gameplay no código do seu próprio jogo.",
    UDim2.new(1, 0, 0, 84), UDim2.fromOffset(0, 158), 11, Color3.fromRGB(155, 161, 178))
playerNotice.TextYAlignment = Enum.TextYAlignment.Top

local testsFrame = Instance.new("ScrollingFrame")
testsFrame.Name = "TestsPage"
testsFrame.BackgroundTransparency = 1
testsFrame.BorderSizePixel = 0
testsFrame.Position = UDim2.fromOffset(0, 0)
testsFrame.Size = UDim2.new(1, 0, 1, 0)
testsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
testsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
testsFrame.ScrollBarThickness = 4
testsFrame.Visible = false
testsFrame.Parent = content

local testsLayout = Instance.new("UIListLayout")
testsLayout.Padding = UDim.new(0, 6)
testsLayout.SortOrder = Enum.SortOrder.LayoutOrder
testsLayout.Parent = testsFrame
local testsPadding = Instance.new("UIPadding")
testsPadding.PaddingRight = UDim.new(0, 5)
testsPadding.PaddingBottom = UDim.new(0, 5)
testsPadding.Parent = testsFrame

local metricsLabel = label(testsFrame, "Métricas: coletando amostras...", UDim2.new(1, -6, 0, 70), UDim2.new(), 12, Color3.fromRGB(125, 220, 157))
metricsLabel.LayoutOrder = 1
metricsLabel.TextYAlignment = Enum.TextYAlignment.Top

local testModeEnabled = false
local flyEnabled = false
local flyVelocity
local flyConnection
local testStatus = label(testsFrame, "Modo de teste desligado. Ative para habilitar os controles locais abaixo.", UDim2.new(1, -6, 0, 40), UDim2.new(), 11, Color3.fromRGB(220, 190, 110))
testStatus.LayoutOrder = 2
testStatus.TextYAlignment = Enum.TextYAlignment.Top

local testModeButton = button(testsFrame, "ATIVAR MODO DE TESTE", UDim2.new(1, -6, 0, 36), UDim2.new())
testModeButton.LayoutOrder = 3
local speed16 = button(testsFrame, "Velocidade 16 (padrão)", UDim2.new(1, -6, 0, 34), UDim2.new())
speed16.LayoutOrder = 4
local speed24 = button(testsFrame, "Velocidade 24", UDim2.new(1, -6, 0, 34), UDim2.new())
speed24.LayoutOrder = 5
local speed32 = button(testsFrame, "Velocidade 32", UDim2.new(1, -6, 0, 34), UDim2.new())
speed32.LayoutOrder = 6
local speed48 = button(testsFrame, "Velocidade 48", UDim2.new(1, -6, 0, 34), UDim2.new())
speed48.LayoutOrder = 7
local flyButton = button(testsFrame, "Ativar voo de teste", UDim2.new(1, -6, 0, 34), UDim2.new())
flyButton.LayoutOrder = 8
local spawnButton = button(testsFrame, "Teletransportar ao Spawn de teste", UDim2.new(1, -6, 0, 34), UDim2.new())
spawnButton.LayoutOrder = 9
local stopAnimations = button(testsFrame, "Parar animações atuais do meu personagem", UDim2.new(1, -6, 0, 34), UDim2.new())
stopAnimations.LayoutOrder = 10
local testsDisclaimer = label(testsFrame,
    "Teste local: velocidade/voo/teleporte podem ser sobrescritos pelo servidor. Parar animações afeta apenas as tracks do seu próprio personagem. Para testes de rede reais, implemente endpoints de teste no servidor do seu jogo.",
    UDim2.new(1, -6, 0, 72), UDim2.new(), 10, Color3.fromRGB(155, 161, 178))
testsDisclaimer.LayoutOrder = 11
testsDisclaimer.TextYAlignment = Enum.TextYAlignment.Top

local function refreshPlayerInfo()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    playerInfo.Text = "Jogador: " .. player.DisplayName .. " (@" .. player.Name .. ")\n"
        .. "Personagem: " .. (character and "carregado" or "não carregado") .. "\n"
        .. "Humanoid: " .. (humanoid and "disponível" or "indisponível") .. "\n"
        .. "Vida: " .. (humanoid and (math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)) or "—") .. "\n"
        .. "Velocidade atual: " .. (humanoid and tostring(humanoid.WalkSpeed) or "—")
end

refreshPlayer.Activated:Connect(refreshPlayerInfo)
player.CharacterAdded:Connect(function()
    task.defer(refreshPlayerInfo)
end)

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
    local isPlayer = page == "player"
    local isTests = page == "tests"
    status.Visible = isHome or isPerformance
    halloweenFrame.Visible = isHalloween
    settingsFrame.Visible = isSettings
    playerFrame.Visible = isPlayer
    testsFrame.Visible = isTests
    lowGraphics.Visible = isPerformance
    shadows.Visible = isPerformance
    effects.Visible = isPerformance
    highGraphics.Visible = isPerformance
    realisticGraphics.Visible = isPerformance
    blackSky.Visible = isPerformance
    visualCleanup.Visible = isPerformance
    restore.Visible = isPerformance

    if isHome then
        status.Text = "MormawHub está ativo.\nHalloween: checklist manual.\nGráficos: perfis locais para priorizar FPS."
    elseif isPerformance then
        status.Text = "Perfis locais de imagem. A qualidade final também depende das configurações do Roblox."
    elseif isPlayer then
        refreshPlayerInfo()
    elseif isTests then
        testStatus.Text = testModeEnabled and "Modo de teste ATIVO." or "Modo de teste desligado. Ative para habilitar os controles locais abaixo."
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
playerTab.Activated:Connect(function() showPage("player") end)
testsTab.Activated:Connect(function() showPage("tests") end)
settingsTab.Activated:Connect(function() showPage("settings") end)

refreshTracker()

local visualCleanupEnabled = false
local blackSkyEnabled = false

local function setPostEffectsEnabled(enabled)
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") then obj.Enabled = enabled end
    end
end

local function applyLightProfile()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.FogEnd = 100000
    Lighting.Ambient = Color3.fromRGB(170, 170, 170)
    Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
    setPostEffectsEnabled(false)
end

local function applyLowProfile()
    applyLightProfile()
    Lighting.Brightness = 0.8
    Lighting.Ambient = Color3.fromRGB(100, 100, 100)
    Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
end

local function applyUltraLightProfile()
    applyLightProfile()
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.fromRGB(80, 80, 80)
    Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80)
    captureVisualEffects()
    for obj in pairs(visualEffectsSnapshot) do
        if obj and obj.Parent and isReducibleVisual(obj) then
            pcall(function() obj.Enabled = false end)
        end
    end
end

lowGraphics.Activated:Connect(function()
    applyUltraLightProfile()
    status.Text = "ULTRA LEVE aplicado: sombras, pós-efeitos e efeitos visuais reduzidos localmente."
    status.Visible = true
end)

shadows.Activated:Connect(function()
    applyLowProfile()
    status.Text = "Perfil BAIXO aplicado: prioriza simplicidade visual."
    status.Visible = true
end)

effects.Activated:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = original.Brightness
    Lighting.Ambient = original.Ambient
    Lighting.OutdoorAmbient = original.OutdoorAmbient
    setPostEffectsEnabled(true)
    status.Text = "Perfil MÉDIO aplicado: mantém iluminação original e ativa pós-efeitos."
    status.Visible = true
end)

highGraphics.Activated:Connect(function()
    Lighting.GlobalShadows = original.GlobalShadows
    Lighting.Brightness = original.Brightness
    Lighting.FogEnd = original.FogEnd
    Lighting.Ambient = original.Ambient
    Lighting.OutdoorAmbient = original.OutdoorAmbient
    setPostEffectsEnabled(true)
    status.Text = "Perfil ALTO aplicado com os valores de iluminação capturados ao iniciar. O Roblox controla a qualidade final."
    status.Visible = true
end)

realisticGraphics.Activated:Connect(function()
    Lighting.GlobalShadows = original.GlobalShadows
    Lighting.Brightness = original.Brightness
    Lighting.FogEnd = original.FogEnd
    Lighting.ClockTime = original.ClockTime
    Lighting.Ambient = original.Ambient
    Lighting.OutdoorAmbient = original.OutdoorAmbient
    Lighting.FogColor = original.FogColor
    Lighting.ColorShift_Top = original.ColorShift_Top
    Lighting.ColorShift_Bottom = original.ColorShift_Bottom
    Lighting.ExposureCompensation = original.ExposureCompensation
    for obj, enabled in pairs(effectsSnapshot) do
        if obj and obj.Parent then pcall(function() obj.Enabled = enabled end) end
    end
    status.Text = "Perfil REALISTA: restaura iluminação e pós-efeitos capturados. Não altera o nível gráfico global do Roblox."
    status.Visible = true
end)

blackSky.Activated:Connect(function()
    blackSkyEnabled = not blackSkyEnabled
    if blackSkyEnabled then
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") then obj.Parent = nil end
        end
        Lighting.ClockTime = 0
        Lighting.Brightness = 0
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        Lighting.FogColor = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
        Lighting.ExposureCompensation = -2
        blackSky.Text = "   Desativar céu totalmente escuro"
        status.Text = "Modo escuro ativado localmente. Pode ocultar detalhes e dificultar a visão."
    else
        for _, sky in ipairs(originalSkies) do
            if sky then sky.Parent = Lighting end
        end
        Lighting.ClockTime = original.ClockTime
        Lighting.Brightness = original.Brightness
        Lighting.Ambient = original.Ambient
        Lighting.OutdoorAmbient = original.OutdoorAmbient
        Lighting.FogColor = original.FogColor
        Lighting.ColorShift_Top = original.ColorShift_Top
        Lighting.ColorShift_Bottom = original.ColorShift_Bottom
        Lighting.ExposureCompensation = original.ExposureCompensation
        blackSky.Text = "   Ativar céu totalmente escuro"
        status.Text = "Modo escuro desativado; iluminação original restaurada."
    end
    status.Visible = true
end)

visualCleanup.Activated:Connect(function()
    visualCleanupEnabled = not visualCleanupEnabled
    captureVisualEffects()
    for obj, enabled in pairs(visualEffectsSnapshot) do
        if obj and obj.Parent and isReducibleVisual(obj) then
            pcall(function()
                if visualCleanupEnabled then
                    obj.Enabled = false
                else
                    obj.Enabled = enabled
                end
            end)
        end
    end
    visualCleanup.Text = visualCleanupEnabled and "   Restaurar partículas e efeitos visuais" or "   Reduzir partículas e efeitos animados"
    status.Text = visualCleanupEnabled
        and "Partículas, trilhas, beams, fogo, fumaça, brilhos e highlights foram ocultados localmente quando suportado."
        or "Estados dos efeitos visuais capturados foram restaurados quando possível."
    status.Visible = true
end)

restore.Activated:Connect(function()
    blackSkyEnabled = false
    visualCleanupEnabled = false
    for _, sky in ipairs(originalSkies) do
        if sky then sky.Parent = Lighting end
    end
    Lighting.GlobalShadows = original.GlobalShadows
    Lighting.Brightness = original.Brightness
    Lighting.FogEnd = original.FogEnd
    Lighting.ClockTime = original.ClockTime
    Lighting.Ambient = original.Ambient
    Lighting.OutdoorAmbient = original.OutdoorAmbient
    Lighting.FogColor = original.FogColor
    Lighting.ColorShift_Top = original.ColorShift_Top
    Lighting.ColorShift_Bottom = original.ColorShift_Bottom
    Lighting.ExposureCompensation = original.ExposureCompensation
    for obj, enabled in pairs(effectsSnapshot) do
        if obj and obj.Parent then pcall(function() obj.Enabled = enabled end) end
    end
    for obj, enabled in pairs(visualEffectsSnapshot) do
        if obj and obj.Parent and isReducibleVisual(obj) then
            pcall(function() obj.Enabled = enabled end)
        end
    end
    blackSky.Text = "   Ativar céu totalmente escuro"
    visualCleanup.Text = "   Reduzir partículas e efeitos animados"
    status.Text = "Configurações de iluminação e efeitos restauradas quando possível."
    status.Visible = true
end)


-- Métricas aproximadas do cliente: FPS por amostras de RenderStepped, memória total
-- e ping quando a API de Stats disponibiliza esses valores.
local fpsFrames, fpsElapsed, measuredFps = 0, 0, 0
local metricsConnection = RunService.RenderStepped:Connect(function(dt)
    fpsFrames += 1
    fpsElapsed += dt
    if fpsElapsed >= 1 then
        measuredFps = math.floor(fpsFrames / math.max(fpsElapsed, 0.001) + 0.5)
        fpsFrames, fpsElapsed = 0, 0
        local memoryText = "indisponível"
        local pingText = "indisponível"
        pcall(function()
            memoryText = string.format("%.1f MB", Stats:GetTotalMemoryUsageMb())
        end)
        pcall(function()
            local network = Stats:FindFirstChild("Network")
            local serverStats = network and network:FindFirstChild("ServerStatsItem")
            local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
            if dataPing then pingText = dataPing:GetValueString() end
        end)
        metricsLabel.Text = "MÉTRICAS DO CLIENTE (aproximadas)\nFPS: " .. measuredFps
            .. "\nMemória Roblox: " .. memoryText .. "\nPing: " .. pingText
    end
end)

local function getTestHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid"), character
end

local function stopFlight()
    flyEnabled = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    flyButton.Text = "Ativar voo de teste"
end

testModeButton.Activated:Connect(function()
    testModeEnabled = not testModeEnabled
    testModeButton.Text = testModeEnabled and "DESATIVAR MODO DE TESTE" or "ATIVAR MODO DE TESTE"
    testStatus.Text = testModeEnabled and "Modo de teste ATIVO: os controles locais estão liberados." or "Modo de teste desligado."
    if not testModeEnabled then
        stopFlight()
        local humanoid = getTestHumanoid()
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end)

local function setTestSpeed(value)
    if not testModeEnabled then
        testStatus.Text = "Ative o MODO DE TESTE antes de alterar a velocidade."
        return
    end
    local humanoid = getTestHumanoid()
    if not humanoid then
        testStatus.Text = "Não encontrei o Humanoid. Aguarde o personagem carregar."
        return
    end
    humanoid.WalkSpeed = value
    testStatus.Text = "WalkSpeed local definido para " .. value .. ". O servidor pode sobrescrever esse valor."
end
speed16.Activated:Connect(function() setTestSpeed(16) end)
speed24.Activated:Connect(function() setTestSpeed(24) end)
speed32.Activated:Connect(function() setTestSpeed(32) end)
speed48.Activated:Connect(function() setTestSpeed(48) end)

flyButton.Activated:Connect(function()
    if not testModeEnabled then
        testStatus.Text = "Ative o MODO DE TESTE antes de iniciar o voo."
        return
    end
    if flyEnabled then
        stopFlight()
        testStatus.Text = "Voo de teste desativado."
        return
    end
    local humanoid, character = getTestHumanoid()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then
        testStatus.Text = "Personagem ainda não está pronto para voo."
        return
    end
    flyEnabled = true
    flyButton.Text = "Desativar voo de teste"
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "MormawTestFlightVelocity"
    flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyVelocity.P = 1e4
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not root.Parent then stopFlight(); return end
        local direction = humanoid.MoveDirection
        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = 35
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -35 end
        flyVelocity.Velocity = direction * 42 + Vector3.new(0, vertical, 0)
    end)
    testStatus.Text = "Voo de teste ativo: use WASD para mover, Espaço para subir e Ctrl para descer (teclado)."
end)

spawnButton.Activated:Connect(function()
    if not testModeEnabled then
        testStatus.Text = "Ative o MODO DE TESTE antes de usar o teleporte."
        return
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        testStatus.Text = "Personagem ainda não está pronto."
        return
    end
    local spawnPart
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then spawnPart = obj; break end
    end
    if not spawnPart then
        testStatus.Text = "Nenhum SpawnLocation encontrado no mapa."
        return
    end
    root.CFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
    testStatus.Text = "Teleport local para o SpawnLocation de teste solicitado. O servidor pode corrigir a posição."
end)

stopAnimations.Activated:Connect(function()
    if not testModeEnabled then
        testStatus.Text = "Ative o MODO DE TESTE antes de testar animações."
        return
    end
    local humanoid, character = getTestHumanoid()
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        testStatus.Text = "Animator não encontrado no personagem."
        return
    end
    local tracks = animator:GetPlayingAnimationTracks()
    for _, track in ipairs(tracks) do
        pcall(function() track:Stop(0.1) end)
    end
    testStatus.Text = "Paradas " .. #tracks .. " tracks de animação atuais do seu personagem. Animações replicadas ou reiniciadas pelo servidor podem voltar."
end)

player.CharacterAdded:Connect(function()
    stopFlight()
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
    stopFlight()
    if metricsConnection then metricsConnection:Disconnect() end
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
