local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ArchondAimbotSettings = {
    AimbotEnabled = false,
    TeamCheck = true,
    WallCheck = true,
    DeathCheck = true,
    FOVEnabled = true,
    FOV = 50,
    TargetPart = "Head",
    FOVColor = Color3.fromRGB(255,255,255)
}

getgenv().ArchondAimbotSettings = ArchondAimbotSettings

local Circle = Drawing.new("Circle")
Circle.Thickness = 1
Circle.Radius = ArchondAimbotSettings.FOV
Circle.NumSides = 64
Circle.Color = Color3.fromRGB(255, 255, 255)
Circle.Filled = false
Circle.Visible = ArchondAimbotSettings.FOVEnabled

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

RunService.RenderStepped:Connect(function()
    Circle.Position = UserInputService:GetMouseLocation()
    Circle.Radius = ArchondAimbotSettings.FOV
    Circle.Visible = ArchondAimbotSettings.FOVEnabled

    if ArchondAimbotSettings.UIColorFOV then
        local t = (tick() % 3) / 3  

        local UIColorSequence = {
        Color3.fromRGB(250, 30, 78),
        Color3.fromRGB(216, 27, 62),
        Color3.fromRGB(175, 21, 54),
        Color3.fromRGB(150, 18, 45),
        
        Color3.fromRGB(216, 27, 62),
        Color3.fromRGB(250, 30, 78),
        Color3.fromRGB(175, 21, 54),
        Color3.fromRGB(150, 18, 45),
        
        Color3.fromRGB(250, 30, 78),
        Color3.fromRGB(216, 27, 62),
        Color3.fromRGB(175, 21, 54),
        Color3.fromRGB(150, 18, 45),
        
        Color3.fromRGB(216, 27, 62),
        Color3.fromRGB(250, 30, 78),
        Color3.fromRGB(175, 21, 54),
        Color3.fromRGB(150, 18, 45),
        Color3.fromRGB(0, 0, 0),
        
        Color3.fromRGB(250, 30, 78),
        Color3.fromRGB(216, 27, 62),
        Color3.fromRGB(175, 21, 54),
        Color3.fromRGB(150, 18, 45),
        
        Color3.fromRGB(216, 27, 62),
        Color3.fromRGB(250, 30, 78),
        Color3.fromRGB(175, 21, 54),
        Color3.fromRGB(150, 18, 45),
        
        Color3.fromRGB(250, 30, 78),
        Color3.fromRGB(216, 27, 62),
        Color3.fromRGB(175, 21, 54),
        Color3.fromRGB(150, 18, 45),
        
        Color3.fromRGB(216, 27, 62),
        Color3.fromRGB(250, 30, 78),
        Color3.fromRGB(175, 21, 54),
        Color3.fromRGB(150, 18, 45),
    }

        local total = #UIColorSequence
        local index = math.floor(t * (total - 1)) + 1
        local nextIndex = index + 1
        if nextIndex > total then
            nextIndex = 1
        end

        local ratio = (t * (total - 1)) % 1
        local c1 = UIColorSequence[index]
        local c2 = UIColorSequence[nextIndex]

        Circle.Color = Color3.new(
            c1.R + (c2.R - c1.R) * ratio,
            c1.G + (c2.G - c1.G) * ratio,
            c1.B + (c2.B - c1.B) * ratio
        )
    else
       
        Circle.Color = ArchondAimbotSettings.FOVColor
    end
end)

local function WallCheck(targetPart)
    if not ArchondAimbotSettings.WallCheck then
        return true
    end

    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}

    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 9999

    local result = Workspace:Raycast(origin, direction, rayParams)
    if not result then return true end

    return result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetClosestPlayer()
    local closest = nil
    local shortest = ArchondAimbotSettings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            local part = p.Character:FindFirstChild(ArchondAimbotSettings.TargetPart)

            if part and hum then
                if not ArchondAimbotSettings.DeathCheck or hum.Health > 0 then
                    if not ArchondAimbotSettings.TeamCheck or (LocalPlayer.Team == nil or p.Team ~= LocalPlayer.Team) then
                        local screenPos, visible = Camera:WorldToViewportPoint(part.Position)

                        if visible then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < shortest and WallCheck(part) then
                                shortest = dist
                                closest = part
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    if not ArchondAimbotSettings.AimbotEnabled then
        return
    end

    local target = GetClosestPlayer()
    if not target then return end

    local pos, visible = Camera:WorldToViewportPoint(target.Position)
    if not visible then return end

    local mousePos = UserInputService:GetMouseLocation()

    local dx = pos.X - mousePos.X
    local dy = pos.Y - mousePos.Y

    mousemoverel(dx, dy)
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

EspSettings = {
    Enabled = false,
    CheckHealth = false,
    EspColor = Color3.fromRGB(255, 255, 255),
    ShowName = false,
    ShowDistance = false,
}

getgenv().EspSettings = EspSettings

local ESP = {}

local function createSquare()
    local sq = Drawing.new("Square")
    sq.Visible = EspSettings.Enabled
    sq.Color = EspSettings.EspColor
    sq.Thickness = 1
    sq.Filled = false
    sq.Transparency = 1
    return sq
end

local function createHealthBar()
    local bar = Drawing.new("Square")
    bar.Visible = EspSettings.CheckHealth
    bar.Thickness = 0
    bar.Filled = true
    bar.Transparency = 1
    return bar
end

local function createText()
    local text = Drawing.new("Text")
    text.Visible = EspSettings.ShowName
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Color = Color3.fromRGB(255, 255, 255)
    return text
end

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(char)
    return char:FindFirstChildOfClass("Humanoid")
end

local function updateSquare(player, square, bar, nameText, distText)

    local char = player.Character
    if not char then 
        square.Visible = false 
        bar.Visible = false
        nameText.Visible = false
        distText.Visible = false
        return 
    end

    local root = getRoot(char)
    if not root then 
        square.Visible = false 
        bar.Visible = false
        nameText.Visible = false
        distText.Visible = false
        return 
    end

    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then 
        square.Visible = false 
        bar.Visible = false
        nameText.Visible = false
        distText.Visible = false
        return 
    end

    local distance = (Camera.CFrame.Position - root.Position).Magnitude
    local size = math.clamp(2000 / distance, 20, 300)

    square.Size = Vector2.new(size * 0.6, size)
    square.Position = Vector2.new(pos.X - square.Size.X/2, pos.Y - square.Size.Y/2)
    square.Visible = EspSettings.Enabled
    square.Color = EspSettings.EspColor

    -- HEALTH BAR -------------------------
    if EspSettings.CheckHealth then
        local hum = getHumanoid(char)
        if hum then
            local hp = hum.Health
            local maxhp = hum.MaxHealth
            local percent = math.clamp(hp / maxhp, 0, 1)

            local color
            if percent > 0.50 then
                color = Color3.fromRGB(0, 255, 0)
            elseif percent > 0.20 then
                color = Color3.fromRGB(255, 255, 0)
            else
                color = Color3.fromRGB(255, 0, 0)
            end

            bar.Color = color
            bar.Size = Vector2.new(4, square.Size.Y * percent)
            bar.Position = Vector2.new(square.Position.X - 6, (square.Position.Y + square.Size.Y) - bar.Size.Y)
            bar.Visible = true
        else
            bar.Visible = false
        end
    else
        bar.Visible = false
    end

    -- NAME ESP -----------------------------------
    if EspSettings.ShowName then
        nameText.Text = player.Name
        nameText.Position = Vector2.new(square.Position.X + square.Size.X/2, square.Position.Y - 16)
        nameText.Visible = true
    else
        nameText.Visible = false
    end

    -- DISTANCE ESP -------------------------------
    if EspSettings.ShowDistance then
        distText.Text = math.floor(distance) .. "m"
        distText.Position = Vector2.new(square.Position.X + square.Size.X/2, square.Position.Y + square.Size.Y + 2)
        distText.Visible = true
    else
        distText.Visible = false
    end
end

-- Criar ESP para players existentes
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        ESP[player] = {
            Box = createSquare(),
            Bar = createHealthBar(),
            Name = createText(),
            Dist = createText(),
        }
    end
end

-- Player joined
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        ESP[player] = {
            Box = createSquare(),
            Bar = createHealthBar(),
            Name = createText(),
            Dist = createText(),
        }
    end
end)

-- Player removing
Players.PlayerRemoving:Connect(function(player)
    if ESP[player] then
        ESP[player].Box:Remove()
        ESP[player].Bar:Remove()
        ESP[player].Name:Remove()
        ESP[player].Dist:Remove()
        ESP[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    for player, data in pairs(ESP) do
        updateSquare(player, data.Box, data.Bar, data.Name, data.Dist)
    end
end)

-- Ui LIB
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()  
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
Starlight:SetTheme("OperaGX")
getgenv().SecureMode = true

local Window = Starlight:CreateWindow({
    Name = "Archond",
    Subtitle = "By General Hook & Noisy",
    Icon = 135184037692682,
    DefaultSize = UDim2.new(0,520,0,460),
    LoadingEnabled = true,
    InterfaceAdvertisingPrompts = false,
    BuildWarnings = false,
    NotifyOnCallbackError = true,
    LoadingSettings = {
        Title = "Archond",
        Subtitle = "Enjoy using Archond!",
        Logo = 135184037692682,
    },

    FileSettings = {
        ConfigFolder = "Archond",
        ThemesInRoot = false
    },
})

local Notification = Starlight:Notification({
    Title = "Archond",
    Icon = 135184037692682,
    Content = "Enjoy Using Archond!",
}, "Notify")

local Archond = Window:CreateTabSection("Archond Functions")

local InfoTab = Archond:CreateTab({
    Name = "Info",
    Icon = NebulaIcons:GetIcon('info', "Lucide"),
    Columns = 1,
}, "Info")

local InfoBox = InfoTab:CreateGroupbox({
    Name = "Archond Informations",
    Icon = 135184037692682,
    Column = 1,
}, "Info")

local Paragraph = InfoBox:CreateParagraph({
    Name = "        About Archond",
    Icon = NebulaIcons:GetIcon("message-circle-question-mark", "Lucide"),
    Content = [[
       Archond is a cutting-edge Aimbot designed to enhance your gameplay with precision and reliability. Built with advanced targeting features, it offers smooth aiming, customizable settings, and a user-friendly interface. Currently optimized for PC, Archond ensures competitive performance while maintaining ease of use for both casual and professional players. 
     ]],
}, "About")

local Divider = InfoBox:CreateDivider()

local Paragraph = InfoBox:CreateParagraph({
    Name = "        Archond Device Support",
    Icon = NebulaIcons:GetIcon("monitor-smartphone", "Lucide"),
    Content = [[
        Currently, Archond does not support mobile users. Full functionality is available only on PC, ensuring optimal performance and precision (for now).
    ]],
}, "ADS")

local GeneralTab = Archond:CreateTab({
    Name = "General",
    Icon = NebulaIcons:GetIcon('crosshair', "Lucide"),
    Columns = 1,
}, "Aimbot")

local AimingBox = GeneralTab:CreateGroupbox({
    Name = "Aiming",
    Icon = 135184037692682,
    Column = 1,
}, "General")

local Toggle = AimingBox:CreateToggle({
    Name = "Enabled",
    CurrentValue = ArchondAimbotSettings.AimbotEnabled,
    Style = 1,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Callback = function(Value)
        ArchondAimbotSettings.AimbotEnabled = Value
    end,
}, "EnabledAimbot")

local Toggle = AimingBox:CreateToggle({
    Name = "Team Check",
    CurrentValue = ArchondAimbotSettings.TeamCheck,
    Style = 1,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Callback = function(Value)
        ArchondAimbotSettings.TeamCheck = Value
    end,
}, "TeamCheck")

local Toggle = AimingBox:CreateToggle({
    Name = "Wall Check",
    CurrentValue = ArchondAimbotSettings.WallCheck,
    Style = 1,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Callback = function(Value)
        ArchondAimbotSettings.WallCheck = Value
    end,
}, "WallCheck")

local Divider = AimingBox:CreateDivider()

local ShowFOVToggle = AimingBox:CreateToggle({
    Name = "Show FOV",
    CurrentValue = ArchondAimbotSettings.FOVEnabled,
    Style = 1,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Callback = function(Value)
        ArchondAimbotSettings.FOVEnabled = Value
        Circle.Visible = Value
    end,
}, "ShowFOV")

local ColorPicker = ShowFOVToggle:AddColorPicker({
    CurrentValue = ArchondAimbotSettings.FOVColor,
    Callback = function(Color)
        ArchondAimbotSettings.FOVColor = Color
    end,
}, "FovColorPick")

ArchondAimbotSettings.UIColorFOV = false

local UIColorFOVToggle = AimingBox:CreateToggle({
    Name = "Sequential UI FOV",
    CurrentValue = ArchondAimbotSettings.UIColorFOV,
    Style = 1,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Callback = function(Value)
        ArchondAimbotSettings.UIColorFOV = Value
        if not Value then
            Circle.Color = Color3.fromRGB(255, 255, 255)
        end
    end,
}, "UIColorFOV")


local Slider = AimingBox:CreateSlider({
    Name = "FOV Radius",
    Range = {50,250},
    CurrentValue = ArchondAimbotSettings.FOV,
    Increment = 1,
    Callback = function(Value)
        ArchondAimbotSettings.FOV = Value
        Circle.Radius = Value
    end,
}, "FOVRadius")

local EspTab = Archond:CreateTab({
    Name = "ESP",
    Icon = NebulaIcons:GetIcon('square', "Lucide"),
    Columns = 1,
}, "Esp")

local EspBox = EspTab:CreateGroupbox({
    Name = "Archond ESP",
    Icon = 135184037692682,
    Column = 1,
}, "EspBox")

local EspToggle = EspBox:CreateToggle({
    Name = "Enabled",
    CurrentValue = EspSettings.Enabled,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Style = 1,
    Callback = function(Value)
        EspSettings.Enabled = Value
    end,
}, "EspEnabled")

local ColorPicker = EspToggle:AddColorPicker({
    CurrentValue = EspSettings.EspColor,
    Callback = function(Color)
        EspSettings.EspColor = Color
    end,
}, "EspColorPick")


local Toggle = EspBox:CreateToggle({
    Name = "Show Health",
    CurrentValue = EspSettings.Enabled,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Style = 1,
    Callback = function(Value)
        EspSettings.CheckHealth = Value
    end,
}, "Health")

local Toggle = EspBox:CreateToggle({
    Name = "Show Name",
    CurrentValue = EspSettings.ShowName,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Style = 1,
    Callback = function(Value)
        EspSettings.ShowName = Value
    end,
}, "Name")


local Toggle = EspBox:CreateToggle({
    Name = "Show Distance",
    CurrentValue = EspSettings.ShowDistance,
    CheckboxIcon = NebulaIcons:GetIcon("check", "Material"),
    Style = 1,
    Callback = function(Value)
        EspSettings.ShowDistance = Value
    end,
}, "Distance")

