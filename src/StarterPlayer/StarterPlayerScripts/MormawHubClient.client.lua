-- MormawHub standalone client panel.
-- Install this as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- Safe training tools only: ESP scans Workspace.TrainingTargets, never live players.
-- No Config ModuleScript or RemoteEvent is required for the UI to appear.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("MormawHubUI")
if oldGui then oldGui:Destroy() end

local COLORS = {
    bg = Color3.fromRGB(16, 19, 28),
    panel = Color3.fromRGB(27, 32, 48),
    accent = Color3.fromRGB(139, 92, 246),
    text = Color3.fromRGB(245, 245, 250),
    muted = Color3.fromRGB(161, 161, 170),
    target = Color3.fromRGB(167, 139, 250),
    good = Color3.fromRGB(74, 222, 128),
    bad = Color3.fromRGB(248, 113, 113),
}

local settings = {
    showFOV = true,
    fovRadius = 110,
    espEnabled = true,
    boxes = true,
    names = true,
    distance = true,
    maxDistance = 500,
    walkSpeed = 20,
    jumpPower = 55,
}

local function make(className, properties, parent)
    local obj = Instance.new(className)
    for key, value in pairs(properties or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local gui = make("ScreenGui", {
    Name = "MormawHubUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 50,
}, playerGui)

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 12, 0.5, 0),
    Size = UDim2.new(0, 330, 0, 430),
    BackgroundColor3 = COLORS.bg,
    BorderSizePixel = 0,
    Active = true,
}, gui)
make("UISizeConstraint", {
    MinSize = Vector2.new(270, 250),
    MaxSize = Vector2.new(360, 500),
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 14)}, main)
make("UIStroke", {Color = COLORS.accent, Transparency = 0.25, Thickness = 1}, main)

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    Active = true,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 14)}, header)
make("Frame", {
    Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
}, header)

make("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 7),
    Size = UDim2.new(1, -100, 0, 26),
    Font = Enum.Font.GothamBold,
    Text = "MORMAWHUB",
    TextColor3 = COLORS.text,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 33),
    Size = UDim2.new(1, -30, 0, 15),
    Font = Enum.Font.Gotham,
    Text = "TRAINING MAP  •  LOCAL UI",
    TextColor3 = COLORS.accent,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local minimize = make("TextButton", {
    Name = "Minimize",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 12),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = COLORS.bg,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "—",
    TextColor3 = COLORS.text,
    TextSize = 16,
    AutoButtonColor = true,
}, header)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, minimize)

local body = make("ScrollingFrame", {
    Name = "Body",
    Position = UDim2.fromOffset(10, 68),
    Size = UDim2.new(1, -20, 1, -78),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = COLORS.accent,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, main)
make("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, body)
make("UIPadding", {
    PaddingBottom = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 3),
}, body)

local order = 0
local function section(label)
    order += 1
    make("TextLabel", {
        LayoutOrder = order,
        Size = UDim2.new(1, -4, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(label),
        TextColor3 = COLORS.accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, body)
end

local function addButton(label, callback)
    order += 1
    local b = make("TextButton", {
        LayoutOrder = order,
        Size = UDim2.new(1, -4, 0, 36),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = COLORS.text,
        TextSize = 12,
        TextWrapped = true,
    }, body)
    make("UICorner", {CornerRadius = UDim.new(0, 8)}, b)
    b.Activated:Connect(function()
        local ok, err = pcall(callback, b)
        if not ok then
            warn("[MormawHub] Button error: " .. tostring(err))
        end
    end)
    return b
end

local function addToggle(label, key, callback)
    local function updateText(btn)
        btn.Text = label .. ": " .. (settings[key] and "ON" or "OFF")
    end
    local b = addButton("", function(btn)
        settings[key] = not settings[key]
        updateText(btn)
        if callback then callback(settings[key]) end
    end)
    updateText(b)
    return b
end

local status = make("TextLabel", {
    Name = "Status",
    LayoutOrder = 999,
    Size = UDim2.new(1, -4, 0, 30),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Painel carregado.",
    TextColor3 = COLORS.muted,
    TextSize = 10,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
}, body)

local function setStatus(text, isError)
    status.Text = text
    status.TextColor3 = isError and COLORS.bad or COLORS.muted
end

section("VISUAL / FOV")
addToggle("Anel FOV", "showFOV")
local fovButton
fovButton = addButton("Raio FOV: 110 px (toque para mudar)", function(btn)
    settings.fovRadius += 20
    if settings.fovRadius > 190 then settings.fovRadius = 70 end
    btn.Text = "Raio FOV: " .. settings.fovRadius .. " px (toque para mudar)"
end)

section("ALVOS DE TREINO")
addToggle("ESP de alvos", "espEnabled")
addToggle("Destaque dos alvos", "boxes")
addToggle("Nome do alvo", "names")
addToggle("Distância do alvo", "distance")
addButton("Distância máxima: 500 studs", function(btn)
    settings.maxDistance += 250
    if settings.maxDistance > 1500 then settings.maxDistance = 250 end
    btn.Text = "Distância máxima: " .. settings.maxDistance .. " studs"
end)

section("MOVIMENTO (SOMENTE STUDIO)")
local function movementRequest(action, value)
    if not RunService:IsStudio() then
        setStatus("Controles de movimento disponíveis somente no Roblox Studio.", true)
        return
    end
    local folder = ReplicatedStorage:FindFirstChild("MormawHub")
    local remote = folder and folder:FindFirstChild("MovementRequest")
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(action, value)
        setStatus(action .. " enviado ao servidor de teste.")
    else
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            setStatus("Personagem ainda não carregou.", true)
            return
        end
        if action == "WalkSpeed" then
            humanoid.WalkSpeed = math.clamp(value, 8, 32)
        elseif action == "JumpPower" then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = math.clamp(value, 30, 80)
        end
        setStatus("Aplicado localmente para teste. Para validação do servidor, crie MovementRequest.")
    end
end

addButton("WalkSpeed: 20 (toque para mudar)", function(btn)
    settings.walkSpeed += 4
    if settings.walkSpeed > 32 then settings.walkSpeed = 12 end
    btn.Text = "WalkSpeed: " .. settings.walkSpeed .. " (toque para mudar)"
    movementRequest("WalkSpeed", settings.walkSpeed)
end)
addButton("JumpPower: 55 (toque para mudar)", function(btn)
    settings.jumpPower += 10
    if settings.jumpPower > 80 then settings.jumpPower = 30 end
    btn.Text = "JumpPower: " .. settings.jumpPower .. " (toque para mudar)"
    movementRequest("JumpPower", settings.jumpPower)
end)
addButton("Restaurar movimento padrão", function()
    settings.walkSpeed, settings.jumpPower = 16, 50
    movementRequest("WalkSpeed", 16)
    movementRequest("JumpPower", 50)
end)
addButton("Ocultar / mostrar painel", function()
    main.Visible = not main.Visible
end)

-- Floating reopen button remains available when the panel is minimized/hidden.
local reopen = make("TextButton", {
    Name = "MormawHubReopen",
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 12, 0.5, 0),
    Size = UDim2.fromOffset(46, 46),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "M",
    TextColor3 = COLORS.accent,
    TextSize = 22,
    Visible = false,
    Active = true,
}, gui)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, reopen)
make("UIStroke", {Color = COLORS.accent, Thickness = 1.5}, reopen)

local minimized = false
local function setPanelVisible(visible)
    main.Visible = visible
    reopen.Visible = not visible
end
minimize.Activated:Connect(function()
    minimized = not minimized
    if minimized then
        setPanelVisible(false)
    else
        setPanelVisible(true)
    end
end)
reopen.Activated:Connect(function()
    minimized = false
    setPanelVisible(true)
end)

-- Drag support works with mouse and touch.
local dragging = false
local dragInput
local dragStart
local startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        dragInput = input
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
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

local fov = make("Frame", {
    Name = "FOVRing",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(settings.fovRadius * 2, settings.fovRadius * 2),
    BackgroundTransparency = 1,
    Visible = settings.showFOV,
    Active = false,
}, gui)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, fov)
make("UIStroke", {Color = COLORS.accent, Thickness = 1.5, Transparency = 0.15}, fov)

-- ESP only processes Models intentionally placed in Workspace.TrainingTargets.
local overlays = {}
local targetConnections = {}
local targetFolder

local function clearOverlay(model)
    local item = overlays[model]
    if item then
        if item.highlight then item.highlight:Destroy() end
        if item.billboard then item.billboard:Destroy() end
        overlays[model] = nil
    end
end

local function ensureOverlay(model)
    if not model:IsA("Model") or overlays[model] then return end
    local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    if not part or not part:IsA("BasePart") then return end

    local highlight = make("Highlight", {
        Name = "MormawTrainingHighlight",
        Adornee = model,
        FillColor = COLORS.target,
        OutlineColor = Color3.fromRGB(235, 225, 255),
        FillTransparency = 0.82,
        OutlineTransparency = 0.1,
        DepthMode = Enum.HighlightDepthMode.Occluded,
        Enabled = false,
}, gui)

    local billboard = make("BillboardGui", {
        Name = "MormawTrainingLabel",
        Adornee = part,
        Size = UDim2.fromOffset(170, 38),
        StudsOffset = Vector3.new(0, 2.5, 0),
        AlwaysOnTop = false,
        Enabled = false,
}, gui)

    local label = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.GothamBold,
        TextColor3 = COLORS.text,
        TextStrokeTransparency = 0.25,
        TextSize = 12,
        TextWrapped = true,
}, billboard)

    overlays[model] = {highlight = highlight, billboard = billboard, label = label}
end

local function refreshTargets()
    local folder = Workspace:FindFirstChild("TrainingTargets")
    if folder ~= targetFolder then
        for model in pairs(overlays) do clearOverlay(model) end
        for _, connection in ipairs(targetConnections) do connection:Disconnect() end
        table.clear(targetConnections)
        targetFolder = folder
        if targetFolder then
            table.insert(targetConnections, targetFolder.ChildAdded:Connect(function()
                task.defer(refreshTargets)
            end))
            table.insert(targetConnections, targetFolder.ChildRemoved:Connect(function()
                task.defer(refreshTargets)
            end))
        end
    end

    if not targetFolder then return end
    for _, child in ipairs(targetFolder:GetChildren()) do
        ensureOverlay(child)
    end
    for model in pairs(overlays) do
        if model.Parent ~= targetFolder then
            clearOverlay(model)
        end
    end
end

refreshTargets()
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "TrainingTargets" then
        task.defer(refreshTargets)
    end
end)
Workspace.ChildRemoved:Connect(function(child)
    if child == targetFolder then
        task.defer(refreshTargets)
    end
end)

local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if not gui.Parent then
        if renderConnection then renderConnection:Disconnect() end
        return
    end

    fov.Visible = settings.showFOV
    fov.Size = UDim2.fromOffset(settings.fovRadius * 2, settings.fovRadius * 2)

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    for model, item in pairs(overlays) do
        local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
        if part and part:IsA("BasePart") then
            item.billboard.Adornee = part
        end
        local distance = (root and part and part:IsA("BasePart")) and (root.Position - part.Position).Magnitude or math.huge
        local enabled = settings.espEnabled and distance <= settings.maxDistance and part ~= nil
        item.highlight.Enabled = enabled and settings.boxes
        item.billboard.Enabled = enabled and (settings.names or settings.distance)
        local pieces = {}
        if settings.names then table.insert(pieces, model.Name) end
        if settings.distance and distance < math.huge then
            table.insert(pieces, string.format("%d studs", math.floor(distance + 0.5)))
        end
        item.label.Text = table.concat(pieces, "  •  ")
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        setPanelVisible(not main.Visible)
    end
end)

player.CharacterAdded:Connect(function()
    task.defer(function()
        if gui.Parent then refreshTargets() end
    end)
end)

print("[MormawHub] Panel loaded successfully.")
