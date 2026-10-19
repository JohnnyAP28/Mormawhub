-- Studio-only movement controls for testing your own training map.
-- Never trust client-supplied movement values in a published experience.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local hub = ReplicatedStorage:WaitForChild("MormawHub")
local request = hub:WaitForChild("MovementRequest")

local MIN_SPEED, MAX_SPEED = 8, 32
local MIN_JUMP, MAX_JUMP = 30, 80

request.OnServerEvent:Connect(function(player, action, value)
    if not RunService:IsStudio() then
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if action == "WalkSpeed" and typeof(value) == "number" then
        humanoid.WalkSpeed = math.clamp(value, MIN_SPEED, MAX_SPEED)
    elseif action == "JumpPower" and typeof(value) == "number" then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = math.clamp(value, MIN_JUMP, MAX_JUMP)
    end
end)
