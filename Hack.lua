-- =============================================
--   [FPS] FLICK - SCRIPT OFICIAL
--   Aimbot + Hitbox Transparente + Anti-Ban Mejorado + Anti-AFK
--   Desarrollado por Ares
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ================== CONFIGURACIÓN ==================
local Settings = {
    Aimbot = true,
    AimLock = false,
    AimFOV = 180,
    HitboxSize = 12,
    HitboxTransparency = 0.4,
    TeamCheck = true,
    AntiAFK = true,
    AntiBan = true,
}

-- ================== ANTI-AFK ==================
local antiAFKConn
local function EnableAntiAFK()
    if antiAFKConn then return end
    antiAFKConn = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local function DisableAntiAFK()
    if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end
end

-- ================== ANTI-BAN MEJORADO ==================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Settings.AntiBan then
        -- Bloquea kicks del cliente
        if method == "Kick" then
            print("🚫 Anti-Ban: Kick bloqueado en FLICK")
            return
        end
        
        -- Bloquea remotes sospechosos de anti-cheat
        if method == "FireServer" then
            local remoteName = tostring(self):lower()
            if remoteName:find("anti") or remoteName:find("cheat") or remoteName:find("ban") or remoteName:find("detect") or remoteName:find("report") then
                print("🚫 Anti-Ban: Remote bloqueado - " .. tostring(self))
                return
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)

-- Protecciones adicionales
mt.__index = newcclosure(function(self, key)
    if Settings.AntiBan then
        if key == "Kick" or (tostring(self):find("AntiCheat") or tostring(self):find("Ban")) then
            return nil
        end
    end
    return oldIndex(self, key)
end)

mt.__newindex = newcclosure(function(self, key, value)
    if Settings.AntiBan and key == "Parent" and (tostring(self):find("AntiCheat") or tostring(self):find("Detector")) then
        return -- Evita que se cambie el padre de scripts de anti-cheat
    end
    return oldNewIndex(self, key, value)
end)

setreadonly(mt, true)

-- ================== MENÚ GUI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 65, 0, 65)
OpenBtn.Position = UDim2.new(0, 15, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 0)
OpenBtn.Text = "🔫"
OpenBtn.TextSize = 32
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1,0)
Corner.Parent = OpenBtn

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 520)
Frame.Position = UDim2.new(0.5, -160, 0.5, -260)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.Visible = false
Frame.Parent = ScreenGui

local FCorner = Instance.new("UICorner")
FCorner.CornerRadius = UDim.new(0, 14)
FCorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundTransparency = 1
Title.Text = "Menú FLICK - Desarrollado por Ares"
Title.TextColor3 = Color3.fromRGB(255, 140, 0)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local function AddToggle(text, default, callback)
    local togFrame = Instance.new("Frame")
    togFrame.Size = UDim2.new(1,-30,0,45)
    togFrame.BackgroundTransparency = 1
    togFrame.Parent = Frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,15,0,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = togFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,70,0,35)
    btn.Position = UDim2.new(0.78,0,0.5,-17)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,60,60)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = togFrame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,10)
    bc.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,60,60)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

AddToggle("Aimbot Silent", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddToggle("Aim Lock", Settings.AimLock, function(v) Settings.AimLock = v end)
AddToggle("Anti-AFK", Settings.AntiAFK, function(v) 
    Settings.AntiAFK = v 
    if v then EnableAntiAFK() else DisableAntiAFK() end 
end)
AddToggle("Anti-Ban Mejorado", Settings.AntiBan, function(v) Settings.AntiBan = v end)

-- Sliders simples para Hitbox y FOV
local function AddSlider(name, minv, maxv, def, cb)
    local sFrame = Instance.new("Frame")
    sFrame.Size = UDim2.new(1,-30,0,60)
    sFrame.BackgroundTransparency = 1
    sFrame.Parent = Frame

    local lbl = Instance.new("TextLabel")
    lbl.Text = name .. ": " .. def
    lbl.Size = UDim2.new(1,0,0,25)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Parent = sFrame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,12)
    bar.Position = UDim2.new(0,0,0,35)
    bar.BackgroundColor3 = Color3.fromRGB(50,50,55)
    bar.Parent = sFrame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-minv)/(maxv-minv),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    fill.Parent = bar

    local bc1 = Instance.new("UICorner") bc1.Parent = bar
    local bc2 = Instance.new("UICorner") bc2.Parent = fill

    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local rel = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(minv + (maxv - minv) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            lbl.Text = name .. ": " .. val
            cb(val)
        end
    end)
end

AddSlider("Hitbox Size", 5, 25, Settings.HitboxSize, function(v) Settings.HitboxSize = v end)
AddSlider("Aim FOV", 80, 300, Settings.AimFOV, function(v) Settings.AimFOV = v end)

-- Cerrar menú
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(1,-45,0,10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = Frame
closeBtn.MouseButton1Click:Connect(function() Frame.Visible = false end)

OpenBtn.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)

-- ================== AIMBOT + HITBOX ==================
local function GetClosestEnemy()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < Settings.AimFOV and dist < shortest then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Silent Aimbot (raycast hook)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Settings.Aimbot and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local origin = args[1] and (args[1].Origin or args[1])
            if origin then
                local direction = (target.Character.Head.Position - origin).Unit * 20000
                if method == "Raycast" then
                    args[2] = direction
                else
                    args[1] = Ray.new(origin, direction)
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- Hitbox Transparente
RunService.Heartbeat:Connect(function()
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character then
            for _, part in plr.Character:GetChildren() do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    part.Transparency = Settings.HitboxTransparency
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Aim Lock
RunService.RenderStepped:Connect(function()
    if Settings.AimLock then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

if Settings.AntiAFK then EnableAntiAFK() end

print("✅ FLICK Script cargado | Anti-Ban mejorado activado")
print("   Toca el botón 🔫 para abrir el menú")
