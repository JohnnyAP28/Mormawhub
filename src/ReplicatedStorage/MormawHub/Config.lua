local Config = {
    UI = {
        Title = "MORMAWHUB",
        Accent = Color3.fromRGB(139, 92, 246),
        Background = Color3.fromRGB(16, 19, 28),
        Panel = Color3.fromRGB(27, 32, 48),
        Text = Color3.fromRGB(245, 245, 250),
        Muted = Color3.fromRGB(161, 161, 170),
    },
    Aim = {
        ShowFOV = true,
        FOVRadius = 110,
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Distance = true,
        MaxDistance = 500,
        TargetColor = Color3.fromRGB(167, 139, 250),
    },
    Movement = {
        WalkSpeed = 20,
        JumpPower = 55,
    },
}
return Config
