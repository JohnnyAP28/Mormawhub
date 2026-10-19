--[[
    MormawHub - UI + desempenho local
    Projeto inicial para publicar no GitHub.
    Observação: não contém automação de farm, roubo, teleporte ou chamadas
    a RemoteEvents de jogos de terceiros. Use mecânicas de gameplay apenas
    em experiências que você controla/autorizou.
]]

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local externalConnections = {}
local function trackConnection(connection)
    table.insert(externalConnections, connection)
    return connection
end
local restoreLocalSettings
local clearPlayerInfoConnections
local stopFlight
local stopAimAssist

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
local visualCleanupEnabled = false
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

gui.Destroying:Connect(function()
    if stopFlight then pcall(stopFlight) end
    if stopAimAssist then pcall(stopAimAssist) end
    if restoreLocalSettings then pcall(restoreLocalSettings) end
    if clearPlayerInfoConnections then pcall(clearPlayerInfoConnections) end
    for _, connection in ipairs(externalConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(externalConnections)
end)

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
sizeLimit.MinSize = Vector2.new(260, 320)
sizeLimit.MaxSize = Vector2.new(460, 600)
sizeLimit.Parent = panel

-- Ajusta o painel ao espaço disponível em telas pequenas e ao girar o dispositivo.
local function resizePanelToViewport()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    panel.Size = UDim2.fromOffset(
        math.clamp(viewport.X - 20, 260, 460),
        math.clamp(viewport.Y - 24, 320, 600)
    )
end
resizePanelToViewport()
local viewportConnection
local function bindViewport()
    if viewportConnection then viewportConnection:Disconnect() end
    local camera = Workspace.CurrentCamera
    if camera then
        viewportConnection = trackConnection(camera:GetPropertyChangedSignal("ViewportSize"):Connect(resizePanelToViewport))
    end
    resizePanelToViewport()
end
local cameraChangedConnection = trackConnection(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport))

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

local tabs = Instance.new("ScrollingFrame")
tabs.Name = "NavigationTabs"
tabs.BackgroundTransparency = 1
tabs.BorderSizePixel = 0
tabs.Position = UDim2.fromOffset(14, 78)
tabs.Size = UDim2.new(1, -28, 0, 34)
tabs.CanvasSize = UDim2.fromOffset(6 * 76, 0)
tabs.ScrollingDirection = Enum.ScrollingDirection.X
tabs.ScrollBarThickness = 3
tabs.ScrollBarImageColor3 = Color3.fromRGB(70, 78, 96)
tabs.Active = true
tabs.Parent = panel

local function makeTab(text, index)
    local tab = button(tabs, text, UDim2.fromOffset(72, 30), UDim2.fromOffset(index * 76, 0))
    tab.TextSize = 11
    return tab
end
local homeTab = makeTab("Início", 0)
local halloweenTab = makeTab("Halloween", 1)
local performanceTab = makeTab("Gráficos", 2)
local playerTab = makeTab("Player", 3)
local testsTab = makeTab("Testes", 4)
local settingsTab = makeTab("Ajustes", 5)

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
local shadows = makeAction("BAIXO — desempenho", 80)
local effects = makeAction("MÉDIO — equilibrado", 114)
local highGraphics = makeAction("ALTO — qualidade visual", 148)
local realisticGraphics = makeAction("REALISTA — iluminação original", 182)
local blackSky = makeAction("Ativar céu totalmente escuro", 216)
local visualCleanup = makeAction("Reduzir partículas e efeitos animados", 250)
local restore = makeAction("Restaurar configurações guardadas", 284)
local refreshVisuals = makeAction("Atualizar captura de efeitos visuais", 318)
lowGraphics.Size = UDim2.new(1, 0, 0, 30)
shadows.Size = UDim2.new(1, 0, 0, 30)
effects.Size = UDim2.new(1, 0, 0, 30)
highGraphics.Size = UDim2.new(1, 0, 0, 30)
realisticGraphics.Size = UDim2.new(1, 0, 0, 30)
blackSky.Size = UDim2.new(1, 0, 0, 30)
visualCleanup.Size = UDim2.new(1, 0, 0, 30)
restore.Size = UDim2.new(1, 0, 0, 30)
refreshVisuals.Size = UDim2.new(1, 0, 0, 30)

-- Rastreador manual do evento: não lê nem altera o estado do jogo.
local trackerState = {}
local trackerItems = {
    "Verificar o aviso de início da florada de borboletas",
    "Equipar a rede de captura",
    "Ir à Floresta Encantada",
    "Capturar borboletas durante a florada",
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

local trackerProgress = label(halloweenFrame, "Checklist da florada: 0/4", UDim2.new(1, -6, 0, 28), UDim2.new(), 13, Color3.fromRGB(125, 220, 157))
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
    "Checklist baseado no aviso visível no vídeo. Ele não ativa o evento nem captura itens automaticamente; para isso, é necessário integrar a lógica real da sua experiência.",
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

local playerInfo = label(playerFrame, "Carregando informações do personagem...", UDim2.new(1, 0, 0, 116), UDim2.fromOffset(0, 0), 12)
playerInfo.TextYAlignment = Enum.TextYAlignment.Top
local refreshPlayer = button(playerFrame, "Atualizar status do personagem", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 122))
local playerNotice = label(playerFrame,
    "Status ao vivo: vida e velocidade são atualizadas enquanto o personagem muda. Use Testes para controles experimentais do seu próprio jogo.",
    UDim2.new(1, 0, 0, 84), UDim2.fromOffset(0, 172), 11, Color3.fromRGB(155, 161, 178))
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
local selectedSpeed = 16
local setTestSpeed
local flyEnabled = false
local flyVelocity
local flyConnection
local flyVerticalDirection = 0
local aimAssistEnabled = false
local aimAssistConnection
local testRemote = ReplicatedStorage:FindFirstChild("MormawHubTestRemote")
local selectedSpawnIndex = 1
local spawnTargets = {}
local testStatus = label(testsFrame, "MODO DE TESTE DESLIGADO. Instale o script de servidor do repositório para validar velocidade e teleporte.", UDim2.new(1, -6, 0, 48), UDim2.new(), 11, Color3.fromRGB(220, 190, 110))
testStatus.LayoutOrder = 2
testStatus.TextYAlignment = Enum.TextYAlignment.Top

local testModeButton = button(testsFrame, "ATIVAR MODO DE TESTE", UDim2.new(1, -6, 0, 36), UDim2.new())
testModeButton.LayoutOrder = 3

local speedValueLabel = label(testsFrame, "Velocidade de teste: 16 / 100", UDim2.new(1, -6, 0, 24), UDim2.new(), 12, Color3.fromRGB(230, 232, 240))
speedValueLabel.LayoutOrder = 4
local speedTrack = Instance.new("TextButton")
speedTrack.Name = "SpeedSliderTrack"
speedTrack.Size = UDim2.new(1, -14, 0, 14)
speedTrack.Position = UDim2.new(0, 4, 0, 0)
speedTrack.BackgroundColor3 = Color3.fromRGB(48, 52, 66)
speedTrack.BorderSizePixel = 0
speedTrack.Text = ""
speedTrack.AutoButtonColor = false
speedTrack.LayoutOrder = 5
speedTrack.Parent = testsFrame
corner(speedTrack, 7)
local speedFill = Instance.new("Frame")
speedFill.Name = "Fill"
speedFill.Size = UDim2.new(0.16, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(55, 180, 105)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedTrack
corner(speedFill, 7)
local speedKnob = Instance.new("Frame")
speedKnob.Name = "Knob"
speedKnob.AnchorPoint = Vector2.new(0.5, 0.5)
speedKnob.Position = UDim2.new(0.16, 0, 0.5, 0)
speedKnob.Size = UDim2.fromOffset(18, 18)
speedKnob.BackgroundColor3 = Color3.fromRGB(240, 244, 248)
speedKnob.BorderSizePixel = 0
speedKnob.ZIndex = 3
speedKnob.Active = true
speedKnob.Parent = speedTrack
corner(speedKnob, 9)
local speedHint = label(testsFrame, "Arraste a barra para escolher qualquer valor entre 0 e 100.", UDim2.new(1, -6, 0, 24), UDim2.new(), 10, Color3.fromRGB(155, 161, 178))
speedHint.LayoutOrder = 6

local flyButton = button(testsFrame, "Ativar voo de teste", UDim2.new(1, -6, 0, 34), UDim2.new())
flyButton.LayoutOrder = 7
local flyUpButton = button(testsFrame, "Segure para subir ▲", UDim2.new(1, -6, 0, 32), UDim2.new())
flyUpButton.LayoutOrder = 8
flyUpButton.Visible = false
local flyDownButton = button(testsFrame, "Segure para descer ▼", UDim2.new(1, -6, 0, 32), UDim2.new())
flyDownButton.LayoutOrder = 9
flyDownButton.Visible = false
local aimAssistButton = button(testsFrame, "Aim de teste: desligado", UDim2.new(1, -6, 0, 34), UDim2.new())
aimAssistButton.LayoutOrder = 10
local spawnTargetButton = button(testsFrame, "Destino: procurando SpawnLocation...", UDim2.new(1, -6, 0, 34), UDim2.new())
spawnTargetButton.LayoutOrder = 11
local spawnButton = button(testsFrame, "Teleportar para destino selecionado", UDim2.new(1, -6, 0, 34), UDim2.new())
spawnButton.LayoutOrder = 12
local stopAnimations = button(testsFrame, "Parar animações atuais do meu personagem", UDim2.new(1, -6, 0, 34), UDim2.new())
stopAnimations.LayoutOrder = 13
local testsDisclaimer = label(testsFrame,
    "Speed e teleporte usam o servidor autorizado. Voo funciona com teclado ou botões de toque. Aim só mira NPCs com a tag MormawAimTarget na sua experiência de teste. Parar animações afeta tracks do seu personagem.",
    UDim2.new(1, -6, 0, 60), UDim2.new(), 10, Color3.fromRGB(155, 161, 178))
testsDisclaimer.LayoutOrder = 14
testsDisclaimer.TextYAlignment = Enum.TextYAlignment.Top

local playerInfoConnections = {}
clearPlayerInfoConnections = function()
    for _, connection in ipairs(playerInfoConnections) do connection:Disconnect() end
    table.clear(playerInfoConnections)
end

local function refreshPlayerInfo()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local healthText = humanoid and (math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)) or "—"
    playerInfo.Text = "Jogador: " .. player.DisplayName .. " (@" .. player.Name .. ")\n"
        .. "Personagem: " .. (character and "carregado" or "não carregado") .. "\n"
        .. "Humanoid: " .. (humanoid and "disponível" or "indisponível") .. "\n"
        .. "Vida: " .. healthText .. "\n"
        .. "Velocidade atual: " .. (humanoid and tostring(humanoid.WalkSpeed) or "—") .. "\n"
        .. "Raiz do personagem: " .. (root and "disponível" or "indisponível")
end

local function bindPlayerInfo(character)
    clearPlayerInfoConnections()
    task.spawn(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
        refreshPlayerInfo()
        if not humanoid or character ~= player.Character then return end
        table.insert(playerInfoConnections, humanoid.HealthChanged:Connect(refreshPlayerInfo))
        table.insert(playerInfoConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(refreshPlayerInfo))
        table.insert(playerInfoConnections, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(refreshPlayerInfo))
    end)
end

refreshPlayerInfo()
refreshPlayer.Activated:Connect(refreshPlayerInfo)
trackConnection(player.CharacterAdded:Connect(bindPlayerInfo))
trackConnection(player.CharacterRemoving:Connect(function()
    clearPlayerInfoConnections()
    refreshPlayerInfo()
end))
if player.Character then bindPlayerInfo(player.Character) end

local resetTracker = button(settingsFrame, "Zerar checklist da florada", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 0))
local toggleTips = button(settingsFrame, "Ocultar dicas do evento", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 48))
local tipsVisible = true
local toggleKeyCode = Enum.KeyCode.RightShift
local waitingForKey = false
local keybindButton = button(settingsFrame, "Tecla para minimizar: RightShift", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 96))
local recenterButton = button(settingsFrame, "Recentralizar painel", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 144))
local settingsInfo = label(settingsFrame,
    "Toque no botão da tecla e pressione qualquer tecla do teclado. O checklist e a tecla escolhida ficam apenas nesta execução.",
    UDim2.new(1, 0, 0, 62), UDim2.fromOffset(0, 192), 11, Color3.fromRGB(155, 161, 178))
settingsInfo.TextYAlignment = Enum.TextYAlignment.Top

keybindButton.Activated:Connect(function()
    waitingForKey = true
    keybindButton.Text = "Pressione a tecla desejada..."
    settingsInfo.Text = "Aguardando tecla. Pressione uma tecla do teclado para minimizar/reabrir o painel."
end)

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
    refreshVisuals.Visible = isPerformance

    if isHome then
        status.Text = "MormawHub está ativo.\nHalloween: checklist manual da florada de borboletas.\nGráficos: perfis locais para priorizar FPS."
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

recenterButton.Activated:Connect(function()
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Visible = true
    reopen.Visible = false
    settingsInfo.Text = "Painel recentralizado na tela."
end)

homeTab.Activated:Connect(function() showPage("home") end)
halloweenTab.Activated:Connect(function() showPage("halloween") end)
performanceTab.Activated:Connect(function() showPage("performance") end)
playerTab.Activated:Connect(function() showPage("player") end)
testsTab.Activated:Connect(function() showPage("tests") end)
settingsTab.Activated:Connect(function() showPage("settings") end)

refreshTracker()

local blackSkyEnabled = false

local visualDescendantConnection = trackConnection(Workspace.DescendantAdded:Connect(function(obj)
    if isReducibleVisual(obj) and visualEffectsSnapshot[obj] == nil then
        visualEffectsSnapshot[obj] = obj.Enabled
        if visualCleanupEnabled then pcall(function() obj.Enabled = false end) end
    end
end))

local function setPostEffectsEnabled(enabled)
    -- Preserva o estado original de cada efeito em vez de ativar todos indiscriminadamente.
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") and effectsSnapshot[obj] == nil then
            effectsSnapshot[obj] = obj.Enabled
        end
    end
    for obj, originalEnabled in pairs(effectsSnapshot) do
        if obj and obj.Parent then
            pcall(function() obj.Enabled = enabled and originalEnabled or false end)
        end
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
    pcall(function() Lighting.Technology = original.Technology end)
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

restoreLocalSettings = function()
    blackSkyEnabled = false
    visualCleanupEnabled = false
    for _, sky in ipairs(originalSkies) do
        if sky and sky.Parent ~= Lighting then pcall(function() sky.Parent = Lighting end) end
    end
    Lighting.GlobalShadows = original.GlobalShadows
    Lighting.Brightness = original.Brightness
    Lighting.FogEnd = original.FogEnd
    pcall(function() Lighting.Technology = original.Technology end)
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
        if obj and obj.Parent and isReducibleVisual(obj) then pcall(function() obj.Enabled = enabled end) end
    end
    blackSky.Text = "   Ativar céu totalmente escuro"
    visualCleanup.Text = "   Reduzir partículas e efeitos animados"
end

restore.Activated:Connect(function()
    restoreLocalSettings()
    status.Text = "Configurações de iluminação e efeitos restauradas quando possível."
    status.Visible = true
end)

refreshVisuals.Activated:Connect(function()
    captureVisualEffects()
    if visualCleanupEnabled then
        for obj in pairs(visualEffectsSnapshot) do
            if obj and obj.Parent and isReducibleVisual(obj) then pcall(function() obj.Enabled = false end) end
        end
    end
    status.Text = visualCleanupEnabled
        and "Efeitos recém-criados também foram incluídos na redução visual."
        or "Captura atualizada. Restaurar configurações usará estes estados como referência."
    status.Visible = true
end)


-- Métricas aproximadas do cliente: FPS por amostras de RenderStepped, memória total
-- e ping quando a API de Stats disponibiliza esses valores.
local fpsFrames, fpsElapsed, measuredFps = 0, 0, 0
local metricsConnection = trackConnection(RunService.RenderStepped:Connect(function(dt)
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
end))

local function getTestHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid"), character
end

stopFlight = function()
    flyEnabled = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    flyVerticalDirection = 0
    if flyButton and flyButton.Parent then flyButton.Text = "Ativar voo de teste" end
    if flyUpButton and flyUpButton.Parent then flyUpButton.Visible = false end
    if flyDownButton and flyDownButton.Parent then flyDownButton.Visible = false end
end

testModeButton.Activated:Connect(function()
    if not testRemote then
        testStatus.Text = "Remote de teste ausente. Instale MormawHubTestServer.server.lua em ServerScriptService e use uma conta autorizada."
        return
    end
    testModeButton.Text = "SOLICITANDO AUTORIZAÇÃO..."
    testRemote:FireServer("SetTestMode", not testModeEnabled)
end)

local function bindTestRemote(remote)
    testRemote = remote
    remote.OnClientEvent:Connect(function(kind, value)
        if kind == "Status" then
            testStatus.Text = tostring(value)
        elseif kind == "TestMode" then
            testModeEnabled = value == true
            testModeButton.Text = testModeEnabled and "DESATIVAR MODO DE TESTE" or "ATIVAR MODO DE TESTE"
            if testModeEnabled and setTestSpeed then setTestSpeed(selectedSpeed, true) end
            if not testModeEnabled then
                stopFlight()
                if stopAimAssist then stopAimAssist() end
            end
        end
    end)
end
if testRemote then bindTestRemote(testRemote) end
trackConnection(ReplicatedStorage.ChildAdded:Connect(function(child)
    if child.Name == "MormawHubTestRemote" and child:IsA("RemoteEvent") and not testRemote then
        bindTestRemote(child)
    end
end))

setTestSpeed = function(value, applyToServer)
    selectedSpeed = math.clamp(math.floor(tonumber(value) or 16), 0, 100)
    speedValueLabel.Text = "Velocidade de teste: " .. selectedSpeed .. " / 100"
    speedFill.Size = UDim2.new(selectedSpeed / 100, 0, 1, 0)
    speedKnob.Position = UDim2.new(selectedSpeed / 100, 0, 0.5, 0)
    if not applyToServer then return end
    if not testModeEnabled then
        testStatus.Text = "Ative o MODO DE TESTE antes de aplicar a velocidade."
        return
    end
    if not testRemote then
        testStatus.Text = "Remote de teste ausente. Instale MormawHubTestServer.server.lua em ServerScriptService."
        return
    end
    testRemote:FireServer("SetSpeed", selectedSpeed)
end

local function setSliderFromX(x)
    local width = math.max(speedTrack.AbsoluteSize.X, 1)
    local alpha = math.clamp((x - speedTrack.AbsolutePosition.X) / width, 0, 1)
    setTestSpeed(math.floor(alpha * 100 + 0.5), false)
end
local sliderDragging = false
speedTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        setSliderFromX(input.Position.X)
    end
end)
speedKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        setSliderFromX(input.Position.X)
    end
end)
trackConnection(UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setSliderFromX(input.Position.X)
    end
end))
trackConnection(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if sliderDragging then
            sliderDragging = false
            setTestSpeed(selectedSpeed, true)
        end
    end
end))
setTestSpeed(16, false)

local function refreshSpawnTargets()
    spawnTargets = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") or (obj:IsA("BasePart") and (obj.Name == "MormawTestSpawn" or obj.Name == "TestSpawn")) then
            table.insert(spawnTargets, obj)
        end
    end
    table.sort(spawnTargets, function(a, b) return a:GetFullName() < b:GetFullName() end)
    if #spawnTargets == 0 then
        selectedSpawnIndex = 1
        spawnTargetButton.Text = "Destino: nenhum SpawnLocation de teste"
    else
        selectedSpawnIndex = math.clamp(selectedSpawnIndex, 1, #spawnTargets)
        local obj = spawnTargets[selectedSpawnIndex]
        spawnTargetButton.Text = "Destino: " .. obj:GetFullName()
    end
end
refreshSpawnTargets()
spawnTargetButton.Activated:Connect(function()
    refreshSpawnTargets()
    if #spawnTargets == 0 then
        testStatus.Text = "Adicione um SpawnLocation ou uma peça chamada TestSpawn/MormawTestSpawn ao mapa."
        return
    end
    selectedSpawnIndex = selectedSpawnIndex % #spawnTargets + 1
    spawnTargetButton.Text = "Destino: " .. spawnTargets[selectedSpawnIndex]:GetFullName()
end)

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
    flyVerticalDirection = 0
    flyButton.Text = "Desativar voo de teste"
    flyUpButton.Visible = true
    flyDownButton.Visible = true
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
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -35
        else vertical = flyVerticalDirection * 35 end
        flyVelocity.Velocity = direction * 42 + Vector3.new(0, vertical, 0)
    end)
    testStatus.Text = "Voo ativo: use o analógico para mover; segure ▲/▼ para subir/descer. Teclado: Espaço/Ctrl."
end)

local function bindVerticalHold(control, direction)
    control.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if flyEnabled then flyVerticalDirection = direction end
        end
    end)
    control.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if flyVerticalDirection == direction then flyVerticalDirection = 0 end
        end
    end)
end
bindVerticalHold(flyUpButton, 1)
bindVerticalHold(flyDownButton, -1)

-- Aim de teste limitado a NPCs explicitamente marcados pelo desenvolvedor.
stopAimAssist = function()
    aimAssistEnabled = false
    if aimAssistConnection then aimAssistConnection:Disconnect(); aimAssistConnection = nil end
    if aimAssistButton and aimAssistButton.Parent then aimAssistButton.Text = "Aim de teste: desligado" end
end

aimAssistButton.Activated:Connect(function()
    if not testModeEnabled then
        testStatus.Text = "Ative o modo de teste autorizado antes de usar o aim de teste."
        return
    end
    if aimAssistEnabled then
        stopAimAssist()
        testStatus.Text = "Aim de teste desativado."
        return
    end
    aimAssistEnabled = true
    aimAssistButton.Text = "Aim de teste: ligado"
    aimAssistConnection = RunService.RenderStepped:Connect(function()
        if not testModeEnabled then stopAimAssist(); return end
        local camera = Workspace.CurrentCamera
        if not camera then return end
        local bestPart, bestDistance
        local cameraPosition = camera.CFrame.Position
        for _, instance in ipairs(CollectionService:GetTagged("MormawAimTarget")) do
            local model = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model")
            if model and model ~= player.Character and model:IsDescendantOf(Workspace) then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local targetPart = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and targetPart and targetPart:IsA("BasePart") then
                    local distance = (targetPart.Position - cameraPosition).Magnitude
                    if distance <= 250 and (not bestDistance or distance < bestDistance) then
                        bestPart, bestDistance = targetPart, distance
                    end
                end
            end
        end
        if bestPart then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, bestPart.Position) end
    end)
    testStatus.Text = "Aim de teste ativo para NPCs com a tag MormawAimTarget (até 250 studs)."
end)

spawnButton.Activated:Connect(function()
    if not testModeEnabled then
        testStatus.Text = "Ative o MODO DE TESTE antes de usar o teleporte."
        return
    end
    if not testRemote then
        testStatus.Text = "Remote de teste ausente. Instale MormawHubTestServer.server.lua no servidor."
        return
    end
    refreshSpawnTargets()
    local target = spawnTargets[selectedSpawnIndex]
    if not target then
        testStatus.Text = "Nenhum destino válido. Adicione SpawnLocation ou peça TestSpawn/MormawTestSpawn."
        return
    end
    testRemote:FireServer("TeleportToSpawn", target:GetFullName())
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

trackConnection(player.CharacterAdded:Connect(function()
    stopFlight()
    if stopAimAssist then stopAimAssist() end
end))

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
    restoreLocalSettings()
    clearPlayerInfoConnections()
    if testRemote and testModeEnabled then testRemote:FireServer("SetTestMode", false) end
    gui:Destroy()
end)

trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if waitingForKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            toggleKeyCode = input.KeyCode
            waitingForKey = false
            keybindButton.Text = "Tecla para minimizar: " .. toggleKeyCode.Name
            settingsInfo.Text = "Tecla definida. Pressione " .. toggleKeyCode.Name .. " para minimizar/reabrir o painel."
        end
        return
    end
    if not gameProcessed and input.KeyCode == toggleKeyCode then
        panel.Visible = not panel.Visible
        reopen.Visible = not panel.Visible
    end
end))

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

trackConnection(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end))

showPage("home")
