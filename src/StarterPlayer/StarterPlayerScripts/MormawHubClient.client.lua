-- MormawHub client UI + training-target ESP + FOV ring.
-- Self-contained; no external loadstring or remote code.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local hubFolder = ReplicatedStorage:WaitForChild("MormawHub")
local Config = require(hubFolder:WaitForChild("Config"))
local movementRequest = hubFolder:WaitForChild("MovementRequest")

local settings = {
    showFOV = Config.Aim.ShowFOV,
    fovRadius = Config.Aim.FOVRadius,
    espEnabled = Config.ESP.Enabled,
    boxes = Config.ESP.Boxes,
    names = Config.ESP.Names,
    distance = Config.ESP.Distance,
    maxDistance = Config.ESP.MaxDistance,
    walkSpeed = Config.Movement.WalkSpeed,
    jumpPower = Config.Movement.JumpPower,
}

local UI = {}
function UI.create(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local previous = playerGui:FindFirstChild("MormawHubUI")
if previous then previous:Destroy() end

local gui = UI.create("ScreenGui", {
    Name = "MormawHubUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = UI.create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(330, 440),
    Position = UDim2.new(0, 20, 0.5, -220),
    BackgroundColor3 = Config.UI.Background,
    BorderSizePixel = 0,
}, gui)
UI.create("UICorner", {CornerRadius = UDim.new(0, 14)}, main)
UI.create("UIStroke", {Color = Config.UI.Accent, Transparency = 0.3, Thickness = 1}, main)

local header = UI.create("Frame", {
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = Config.UI.Panel,
    BorderSizePixel = 0,
}, main)
UI.create("UICorner", {CornerRadius = UDim.new(0, 14)}, header)
UI.create("Frame", {
    Size = UDim2.new(1, 0, 0, 15),
    Position = UDim2.new(0, 0, 1, -15),
    BackgroundColor3 = Config.UI.Panel,
    BorderSizePixel = 0,
}, header)

UI.create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(16, 9),
    Size = UDim2.new(1, -30, 0, 26),
    Font = Enum.Font.GothamBold,
    Text = Config.UI.Title,
    TextColor3 = Config.UI.Text,
    TextSize = 19,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)
UI.create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(17, 35),
    Size = UDim2.new(1, -30, 0, 16),
    Font = Enum.Font.Gotham,
    Text = "TRAINING MAP  •  STUDIO BUILD",
    TextColor3 = Config.UI.Accent,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local body = UI.create("ScrollingFrame", {
    Position = UDim2.fromOffset(12, 74),
    Size = UDim2.new(1, -24, 1, -86),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Config.UI.Accent,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
UI.create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, body)
UI.create("UIPadding", {
    PaddingBottom = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 3),
}, body)

local order = 0
local function section(text)
    order += 1
    UI.create("TextLabel", {
        LayoutOrder = order,
        Size = UDim2.new(1, -4, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(text),
        TextColor3 = Config.UI.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, body)
end

local function button(text, callback)
    order += 1
    local b = UI.create("TextButton", {
        LayoutOrder = order,
        Size = UDim2.new(1, -4, 0, 34),
        BackgroundColor3 = Config.UI.Panel,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = Config.UI.Text,
        TextSize = 12,
    }, body)
    UI.create("UICorner", {CornerRadius = UDim.new(0, 8)}, b)
    b.Activated:Connect(function() callback(b) end)
    return b
end

local function toggle(labelText, key, onChanged)
    local function caption()
        return labelText .. ": " .. (settings[key] and "ON" or "OFF")
    end
    return button(caption(), function(btn)
        settings[key] = not settings[key]
        btn.Text = caption()
        onChanged(settings[key])
    end)
end

section("Aim trainer")
toggle("FOV ring", "showFOV", function() end)
button("FOV radius: 110 px (tap to cycle)", function(btn)
    settings.fovRadius += 20
    if settings.fovRadius > 190 then settings.fovRadius = 70 end
    btn.Text = "FOV radius: " .. settings.fovRadius .. " px (tap to cycle)"
end)

section("Training target ESP")
toggle("ESP overlay", "espEnabled", function() end)
toggle("Target boxes / highlights", "boxes", function() end)
toggle("Target names", "names", function() end)
toggle("Distance labels", "distance", function() end)
button("Max distance: 500 studs (tap to cycle)", function(btn)
    settings.maxDistance += 250
    if settings.maxDistance > 1500 then settings.maxDistance = 250 end
    btn.Text = "Max distance: " .. settings.maxDistance .. " studs (tap to cycle)"
end)

section("Movement lab (Studio only)")
button("WalkSpeed: 20 (tap to cycle)", function(btn)
    settings.walkSpeed += 4
    if settings.walkSpeed > 32 then settings.walkSpeed = 12 end
    movementRequest:FireServer("WalkSpeed", settings.walkSpeed)
    btn.Text = "WalkSpeed: " .. settings.walkSpeed .. " (tap to cycle)"
end)
button("JumpPower: 55 (tap to cycle)", function(btn)
    settings.jumpPower += 10
    if settings.jumpPower > 80 then settings.jumpPower = 30 end
    movementRequest:FireServer("JumpPower", settings.jumpPower)
    btn.Text = "JumpPower: " .. settings.jumpPower .. " (tap to cycle)"
end)
button("Reset movement", function()
    settings.walkSpeed, settings.jumpPower = 16, 50
    movementRequest:FireServer("WalkSpeed", 16)
    movementRequest:FireServer("JumpPower", 50)
end)
button("Hide / show menu (RightShift)", function()
    main.Visible = not main.Visible
end)

local fov = UI.create("Frame", {
    Name = "FOVRing",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(settings.fovRadius * 2, settings.fovRadius * 2),
    BackgroundTransparency = 1,
    Visible = settings.showFOV,
}, gui)
UI.create("UICorner", {CornerRadius = UDim.new(1, 0)}, fov)
UI.create("UIStroke", {Color = Config.UI.Accent, Thickness = 1.5, Transparency = 0.15}, fov)

-- ESP is limited to models intentionally placed in Workspace.TrainingTargets.
local overlays = {}
local function clearOverlay(model)
    local item = overlays[model]
    if item then
        item.highlight:Destroy()
        item.billboard:Destroy()
        overlays[model] = nil
    end
end

local function ensureOverlay(model)
    if not model:IsA("Model") or overlays[model] then return end
    local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    if not part or not part:IsA("BasePart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MormawTrainingHighlight"
    highlight.Adornee = model
    highlight.FillColor = Config.ESP.TargetColor
    highlight.OutlineColor = Color3.fromRGB(235, 225, 255)
    highlight.FillTransparency = 0.82
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = gui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MormawTrainingLabel"
    billboard.Adornee = part
    billboard.Size = UDim2.fromOffset(170, 42)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = false
    billboard.Enabled = false
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Config.UI.Text
    label.TextStrokeTransparency = 0.25
    label.TextSize = 12
    label.Parent = billboard

    overlays[model] = {highlight = highlight, billboard = billboard, label = label}
end

local function refreshTargets()
    local folder = Workspace:FindFirstChild("TrainingTargets")
    if not folder then
        for model in pairs(overlays) do clearOverlay(model) end
        return
    end
    for _, child in ipairs(folder:GetChildren()) do ensureOverlay(child) end
    for model in pairs(overlays) do
        if not model.Parent or model.Parent ~= folder then clearOverlay(model) end
    end
end

refreshTargets()
local targetFolder = Workspace:FindFirstChild("TrainingTargets")
if targetFolder then
    targetFolder.ChildAdded:Connect(function() task.defer(refreshTargets) end)
    targetFolder.ChildRemoved:Connect(function() task.defer(refreshTargets) end)
end
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "TrainingTargets" then
        child.ChildAdded:Connect(function() task.defer(refreshTargets) end)
        child.ChildRemoved:Connect(function() task.defer(refreshTargets) end)
        task.defer(refreshTargets)
    end
end)

RunService.RenderStepped:Connect(function()
    fov.Visible = settings.showFOV
    fov.Size = UDim2.fromOffset(settings.fovRadius * 2, settings.fovRadius * 2)

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    for model, item in pairs(overlays) do
        local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
        local distance = (root and part) and (root.Position - part.Position).Magnitude or math.huge
        local enabled = settings.espEnabled and distance <= settings.maxDistance and part ~= nil
        item.highlight.Enabled = enabled and settings.boxes
        item.billboard.Enabled = enabled and (settings.names or settings.distance)
        local pieces = {}
        if settings.names then table.insert(pieces, model.Name) end
        if settings.distance and distance < math.huge then
            table.insert(pieces, string.format("%d studs", distance))
        end
        item.label.Text = table.concat(pieces, "  •  ")
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)
