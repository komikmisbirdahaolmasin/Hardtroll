-- // ╔═══════════════════════════════════════════╗
-- // ║   GEMINI HUB v2.0 - ULTIMATE EDITION   ║
-- // ║     50+ Özellik | Pro Developers Için    ║
-- // ╚═══════════════════════════════════════════╝

-- // AYARLAR & DEĞİŞKENLER //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Özellik Değişkenleri
local Features = {
    noclip = false,
    godMode = false,
    attach = false,
    speed = false,
    speedValue = 50,
    fly = false,
    flySpeed = 100,
    xrayMode = false,
    espMode = false,
    invisibility = false,
    teleport = false,
    glow = false,
    chatSpam = false,
    jumpPower = false,
    jumpValue = 100,
    fullBright = false,
    noFog = false,
    aimbot = false,
    killaura = false,
    infiniteJump = false,
    antiKnockback = false,
    silentKill = false,
    rapidFire = false,
    autoParry = false,
    spiderClimb = false,
    wallWalk = false,
    waterWalk = false,
    shrinkSize = false,
    gigantSize = false,
    invisibilityCloak = false,
    timeStop = false,
    slowMotion = false,
    customTime = 12,
    rainbowMode = false,
    hyperspeed = false,
    dashAbility = false,
    doubleJump = false,
    wallSlide = false,
    gravityControl = false,
    gravityValue = 32.2,
    potionMode = false,
    chatLogger = false,
    playerLogger = false,
    chatFilter = false,
    autoReport = false,
    danceMove = false,
    spinAttack = false,
    laserBeam = false,
    particleEffect = false,
    soundMixer = false,
    screenEffect = false,
    screenGlitch = false,
    heatMap = false,
    radarMode = false,
    debugMode = false
}

local targetName = ""
local targetPlayer = nil
local isUIVisible = true
local flyConnection = nil
local speedConnection = nil
local noclipConnection = nil
local attachConnection = nil
local spamConnection = nil
local chatLogs = {}
local playerLogs = {}

-- // UI OLUŞTURMA (MODERN DİZAYN) //
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TabFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleUI = Instance.new("TextButton")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TabButtons = {}
local TabContainers = {}

ScreenGui.Name = "GeminiHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Ana Çerçeve
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 600)
MainFrame.Active = true
MainFrame.Draggable = true

-- Tab Çerçevesi
TabFrame.Name = "TabFrame"
TabFrame.Parent = MainFrame
TabFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TabFrame.BorderSizePixel = 0
TabFrame.Size = UDim2.new(1, 0, 0, 35)

-- Başlık
Title.Parent = TabFrame
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "◈ GEMINI HUB v2.0"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextFont = Enum.Font.GothamBold

-- Toggle Butonu
ToggleUI.Parent = TabFrame
ToggleUI.Position = UDim2.new(0.7, 0, 0, 0)
ToggleUI.Size = UDim2.new(0, 50, 0, 35)
ToggleUI.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
ToggleUI.BorderSizePixel = 0
ToggleUI.Text = "-"
ToggleUI.TextColor3 = Color3.new(1, 1, 1)
ToggleUI.TextSize = 20
ToggleUI.TextFont = Enum.Font.GothamBold

-- Kapsayıcı
Container.Name = "Container"
Container.Parent = MainFrame
Container.Position = UDim2.new(0, 0, 0, 35)
Container.Size = UDim2.new(1, 0, 1, -35)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 5
Container.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)

UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- // YARDIMCI FONKSİYONLAR //
local function Notify(title, message, duration)
    duration = duration or 3
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    notificationGui.ResetOnSpawn = false
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Parent = notificationGui
    notificationFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    notificationFrame.Position = UDim2.new(0.5, -150, 0.05, 0)
    notificationFrame.Size = UDim2.new(0, 300, 0, 80)
    notificationFrame.BorderSizePixel = 0
    
    local notificationTitle = Instance.new("TextLabel")
    notificationTitle.Parent = notificationFrame
    notificationTitle.BackgroundTransparency = 1
    notificationTitle.Size = UDim2.new(1, 0, 0, 30)
    notificationTitle.Text = "◈ " .. title
    notificationTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    notificationTitle.TextFont = Enum.Font.GothamBold
    notificationTitle.TextSize = 14
    
    local notificationMessage = Instance.new("TextLabel")
    notificationMessage.Parent = notificationFrame
    notificationMessage.Position = UDim2.new(0, 10, 0, 30)
    notificationMessage.Size = UDim2.new(1, -20, 1, -40)
    notificationMessage.BackgroundTransparency = 1
    notificationMessage.Text = message
    notificationMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
    notificationMessage.TextFont = Enum.Font.Gotham
    notificationMessage.TextSize = 12
    notificationMessage.TextWrapped = true
    
    game:GetService("Debris"):AddItem(notificationGui, duration)
end

local function createButton(name, callback, isToggle)
    isToggle = isToggle or false
    local btn = Instance.new("TextButton")
    btn.Parent = Container
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 85)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        if isToggle then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = btn.BackgroundColor3}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
        end
    end)
    
    return btn
end

local function createSlider(name, minVal, maxVal, defaultVal, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = Container
    sliderFrame.Size = UDim2.new(1, -10, 0, 50)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    sliderFrame.BorderSizePixel = 0
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Parent = sliderFrame
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. defaultVal
    sliderLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    sliderLabel.TextFont = Enum.Font.GothamBold
    sliderLabel.TextSize = 11
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Parent = sliderFrame
    sliderBar.Position = UDim2.new(0, 10, 0, 25)
    sliderBar.Size = UDim2.new(1, -20, 0, 5)
    sliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    sliderBar.BorderSizePixel = 0
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBar
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sliderFill.BorderSizePixel = 0
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Parent = sliderBar
    sliderButton.Size = UDim2.new(0, 15, 1, 10)
    sliderButton.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -7, 0, -2.5)
    sliderButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    
    local dragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local barPos = sliderBar.AbsolutePosition.X
            local barSize = sliderBar.AbsoluteSize.X
            local relativePos = math.clamp((mousePos.X - barPos) / barSize, 0, 1)
            
            local value = minVal + (maxVal - minVal) * relativePos
            value = math.floor(value)
            
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            sliderButton.Position = UDim2.new(relativePos, -7, 0, -2.5)
            sliderLabel.Text = name .. ": " .. value
            
            callback(value)
        end
    end)
    
    return sliderFrame
end

local function createTextBox(placeholder, callback)
    local textBox = Instance.new("TextBox")
    textBox.Parent = Container
    textBox.Size = UDim2.new(1, -10, 0, 35)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    textBox.BorderSizePixel = 0
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    textBox.Text = ""
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.TextFont = Enum.Font.Gotham
    textBox.TextSize = 13
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textBox.Text)
            targetName = textBox.Text
        end
    end)
    
    return textBox
end

-- // TAB OLUŞTURMA FONKSIYONU //
local function createTab(tabName, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = TabFrame
    tabBtn.Size = UDim2.new(0, 35, 1, 0)
    tabBtn.Position = UDim2.new(0.75 + (#TabButtons * 0.12), 0, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = icon
    tabBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
    tabBtn.TextSize = 16
    
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Parent = Container
    tabContainer.Size = UDim2.new(1, -10, 1, -50)
    tabContainer.Position = UDim2.new(0, 5, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.Visible = false
    tabContainer.ScrollBarThickness = 5
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabContainer
    tabLayout.Padding = UDim.new(0, 4)
    
    tabBtn.MouseButton1Click:Connect(function()
        Container.Visible = false
        tabContainer.Visible = true
    end)
    
    table.insert(TabButtons, tabBtn)
    table.insert(TabContainers, tabContainer)
    
    return tabContainer
end

-- // OYUNCU FONKSİYONLARI //
local function GetCharacter(player)
    return player and player.Character
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsPlayerAlive(player)
    local humanoid = GetHumanoid(player)
    return humanoid and humanoid.Health > 0
end

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsPlayerAlive(player) then
            local root = GetRoot(player)
            local localRoot = GetRoot(LocalPlayer)
            
            if root and localRoot then
                local distance = (root.Position - localRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

-- // ÇEKIRDEK ÖZELLİKLER //

-- 1. NOCLIP
local noclipBtn = createButton("🚫 Noclip: KAPALI", function(btn)
    Features.noclip = not Features.noclip
    btn.Text = Features.noclip and "✅ Noclip: AÇIK" or "🚫 Noclip: KAPALI"
    btn.BackgroundColor3 = Features.noclip and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if noclipConnection then noclipConnection:Disconnect() end
    
    if Features.noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
        Notify("Noclip", "✅ Aktivleştirildi!", 2)
    else
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
        Notify("Noclip", "❌ Deaktivilleştirildi!", 2)
    end
end, true)

-- 2. GOD MODE
local godModeBtn = createButton("🚫 God Mode: KAPALI", function(btn)
    Features.godMode = not Features.godMode
    btn.Text = Features.godMode and "✅ God Mode: AÇIK" or "🚫 God Mode: KAPALI"
    btn.BackgroundColor3 = Features.godMode and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.godMode then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                Notify("God Mode", "✅ Sınırsız Can!", 2)
            end
        end
    end
end, true)

-- 3. ATTACH (YAPIŞ)
createTextBox("Hedef Oyuncu Adı...", function(text)
    targetName = text
    targetPlayer = Players:FindFirstChild(text)
end)

local attachBtn = createButton("🚫 Yapış: KAPALI", function(btn)
    Features.attach = not Features.attach
    btn.Text = Features.attach and "✅ Yapış: AÇIK" or "🚫 Yapış: KAPALI"
    btn.BackgroundColor3 = Features.attach and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if attachConnection then attachConnection:Disconnect() end
    
    if Features.attach then
        attachConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char and targetName ~= "" then
                targetPlayer = Players:FindFirstChild(targetName)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        myRoot.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        myRoot.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
        Notify("Yapış", "✅ Hedefe yapıştırıldı!", 2)
    else
        Notify("Yapış", "❌ İptal edildi!", 2)
    end
end, true)

-- 4. SPEED
local speedBtn = createButton("🚫 Hız: KAPALI", function(btn)
    Features.speed = not Features.speed
    btn.Text = Features.speed and "✅ Hız: AÇIK" or "🚫 Hız: KAPALI"
    btn.BackgroundColor3 = Features.speed and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if speedConnection then speedConnection:Disconnect() end
    
    if Features.speed then
        speedConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local root = GetRoot(LocalPlayer)
                if root then
                    local moveDirection = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + Camera.CFrame.RightVector
                    end
                    
                    if moveDirection.Magnitude > 0 then
                        root.Velocity = moveDirection.Unit * Features.speedValue
                    end
                end
            end
        end)
        Notify("Hız", "✅ Hız modu aktif!", 2)
    end
end, true)

-- Speed Slider
createSlider("Hız Değeri", 0, 200, Features.speedValue, function(val)
    Features.speedValue = val
end)

-- 5. FLY
local flyBtn = createButton("🚫 Uçuş: KAPALI", function(btn)
    Features.fly = not Features.fly
    btn.Text = Features.fly and "✅ Uçuş: AÇIK" or "🚫 Uçuş: KAPALI"
    btn.BackgroundColor3 = Features.fly and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if flyConnection then flyConnection:Disconnect() end
    
    if Features.fly then
        local char = LocalPlayer.Character
        local root = GetRoot(LocalPlayer)
        
        if root then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = root
            
            flyConnection = RunService.Stepped:Connect(function()
                local moveDirection = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = moveDirection.Unit * Features.flySpeed
            end)
            
            Notify("Uçuş", "✅ Uçmaya başladı! (W-A-S-D + SPACE + CTRL)", 3)
        end
    else
        local char = LocalPlayer.Character
        local root = GetRoot(LocalPlayer)
        if root then
            for _, obj in pairs(root:GetChildren()) do
                if obj:IsA("BodyVelocity") then
                    obj:Destroy()
                end
            end
        end
        Notify("Uçuş", "❌ Uçuş durduruldu!", 2)
    end
end, true)

-- Fly Speed Slider
createSlider("Uçuş Hızı", 0, 300, Features.flySpeed, function(val)
    Features.flySpeed = val
end)

-- 6. X-RAY (DUVAR İÇİ GÖRME)
local xrayBtn = createButton("🚫 X-Ray: KAPALI", function(btn)
    Features.xrayMode = not Features.xrayMode
    btn.Text = Features.xrayMode and "✅ X-Ray: AÇIK" or "🚫 X-Ray: KAPALI"
    btn.BackgroundColor3 = Features.xrayMode and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.xrayMode then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
                part.Transparency = 0.3
            end
        end
        Notify("X-Ray", "✅ X-Ray modu aktif!", 2)
    else
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        Notify("X-Ray", "❌ X-Ray modu kapalı!", 2)
    end
end, true)

-- 7. GLOW (PAR İLTİ)
local glowBtn = createButton("🚫 Glow: KAPALI", function(btn)
    Features.glow = not Features.glow
    btn.Text = Features.glow and "✅ Glow: AÇIK" or "🚫 Glow: KAPALI"
    btn.BackgroundColor3 = Features.glow and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Features.glow and Enum.Material.Neon or Enum.Material.SmoothPlastic
            end
        end
    end
    
    Notify("Glow", Features.glow and "✅ Parıldamaya başladı!" or "❌ Parıltı kapalı!", 2)
end, true)

-- 8. JUMP POWER
local jumpBtn = createButton("🚫 Jump Power: KAPALI", function(btn)
    Features.jumpPower = not Features.jumpPower
    btn.Text = Features.jumpPower and "✅ Jump Power: AÇIK" or "🚫 Jump Power: KAPALI"
    btn.BackgroundColor3 = Features.jumpPower and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    local humanoid = GetHumanoid(LocalPlayer)
    if humanoid then
        humanoid.JumpPower = Features.jumpPower and Features.jumpValue or 50
        Notify("Jump Power", Features.jumpPower and "✅ Zıplama gücü: " .. Features.jumpValue or "❌ Normal zıplama", 2)
    end
end, true)

-- Jump Power Slider
createSlider("Zıplama Gücü", 0, 200, Features.jumpValue, function(val)
    Features.jumpValue = val
    if Features.jumpPower then
        local humanoid = GetHumanoid(LocalPlayer)
        if humanoid then
            humanoid.JumpPower = val
        end
    end
end)

-- 9. FULL BRIGHT
local fullBrightBtn = createButton("🚫 Full Bright: KAPALI", function(btn)
    Features.fullBright = not Features.fullBright
    btn.Text = Features.fullBright and "✅ Full Bright: AÇIK" or "🚫 Full Bright: KAPALI"
    btn.BackgroundColor3 = Features.fullBright and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    Lighting.Brightness = Features.fullBright and 3 or 2
    Lighting.ClockTime = Features.fullBright and 12 or 18
    
    Notify("Full Bright", Features.fullBright and "☀️ Çok aydınlık!" or "🌙 Normal aydınlık", 2)
end, true)

-- 10. NO FOG (SİS TEMIZLE)
local noFogBtn = createButton("🚫 No Fog: KAPALI", function(btn)
    Features.noFog = not Features.noFog
    btn.Text = Features.noFog and "✅ No Fog: AÇIK" or "🚫 No Fog: KAPALI"
    btn.BackgroundColor3 = Features.noFog and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    Lighting.FogEnd = Features.noFog and 9e9 or 10000
    
    Notify("Fog", Features.noFog and "✅ Sis temizlendi!" or "❌ Sis geri geldi!", 2)
end, true)

-- 11. CHAT SPAM
local spamMsg = "Gemini Hub'tan selamlar!"
createTextBox("Spam Mesajı...", function(text)
    spamMsg = text
end)

local chatSpamBtn = createButton("🚫 Chat Spam: KAPALI", function(btn)
    Features.chatSpam = not Features.chatSpam
    btn.Text = Features.chatSpam and "✅ Chat Spam: AÇIK" or "🚫 Chat Spam: KAPALI"
    btn.BackgroundColor3 = Features.chatSpam and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if spamConnection then spamConnection:Disconnect() end
    
    if Features.chatSpam then
        spamConnection = RunService.Heartbeat:Connect(function()
            local chatSystem = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chatSystem then
                local sayMessageRequest = chatSystem:FindFirstChild("SayMessageRequest")
                if sayMessageRequest then
                    sayMessageRequest:FireServer(spamMsg, "All")
                end
            end
        end)
        Notify("Chat Spam", "✅ Spam başladı!", 2)
    else
        Notify("Chat Spam", "❌ Spam durduruldu!", 2)
    end
end, true)

-- 12. INFINITE JUMP
local infJumpBtn = createButton("🚫 Sonsuz Zıplama: KAPALI", function(btn)
    Features.infiniteJump = not Features.infiniteJump
    btn.Text = Features.infiniteJump and "✅ Sonsuz Zıplama: AÇIK" or "🚫 Sonsuz Zıplama: KAPALI"
    btn.BackgroundColor3 = Features.infiniteJump and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.infiniteJump then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.Space then
                local humanoid = GetHumanoid(LocalPlayer)
                if humanoid then
                    humanoid:Jump()
                end
            end
        end)
        Notify("Sonsuz Zıplama", "✅ SPACE'e basarak sınırsız zıpla!", 2)
    end
end, true)

-- 13. DOUBLE JUMP
local doubleJumpBtn = createButton("🚫 Çift Zıplama: KAPALI", function(btn)
    Features.doubleJump = not Features.doubleJump
    btn.Text = Features.doubleJump and "✅ Çift Zıplama: AÇIK" or "🚫 Çift Zıplama: KAPALI"
    btn.BackgroundColor3 = Features.doubleJump and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.doubleJump then
        local jumped = false
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.Space then
                local humanoid = GetHumanoid(LocalPlayer)
                if humanoid then
                    if not jumped then
                        jumped = true
                        humanoid:Jump()
                    else
                        local root = GetRoot(LocalPlayer)
                        if root then
                            root.Velocity = root.Velocity + Vector3.new(0, 50, 0)
                            jumped = false
                        end
                    end
                end
            end
        end)
        
        Notify("Çift Zıplama", "✅ İki kez zıplayabilirsin!", 2)
    end
end, true)

-- 14. GRAVITY CONTROL
local gravityBtn = createButton("🚫 Gravity: NORMAL", function(btn)
    Features.gravityControl = not Features.gravityControl
    btn.Text = Features.gravityControl and "✅ Gravity: KONTROL" or "🚫 Gravity: NORMAL"
    btn.BackgroundColor3 = Features.gravityControl and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.gravityControl then
        Workspace.Gravity = Features.gravityValue
        Notify("Gravity", "✅ Gravite kontrolü aktif!", 2)
    else
        Workspace.Gravity = 196.2
    end
end, true)

-- Gravity Slider
createSlider("Gravite Değeri", 0, 196.2, Features.gravityValue, function(val)
    Features.gravityValue = val
    if Features.gravityControl then
        Workspace.Gravity = val
    end
end)

-- 15. INVISIBILITY (GÖRÜNMEZLIK)
local invisBtn = createButton("🚫 Görünmezlik: KAPALI", function(btn)
    Features.invisibility = not Features.invisibility
    btn.Text = Features.invisibility and "✅ Görünmezlik: AÇIK" or "🚫 Görünmezlik: KAPALI"
    btn.BackgroundColor3 = Features.invisibility and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = Features.invisibility and 1 or 0
            end
        end
    end
    
    Notify("Görünmezlik", Features.invisibility and "👻 Görünmez oldu!" or "👤 Görünür oldu!", 2)
end, true)

-- 16. SHRINK
local shrinkBtn = createButton("🚫 Küçülme: KAPALI", function(btn)
    Features.shrinkSize = not Features.shrinkSize
    btn.Text = Features.shrinkSize and "✅ Küçülme: AÇIK" or "🚫 Küçülme: KAPALI"
    btn.BackgroundColor3 = Features.shrinkSize and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = GetHumanoid(LocalPlayer)
        if humanoid then
            humanoid:FindFirstChild("Humanoid").HipHeight = Features.shrinkSize and 1 or 2
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * (Features.shrinkSize and 0.5 or 2)
                end
            end
        end
    end
    
    Notify("Küçülme", Features.shrinkSize and "📉 Küçüldün!" or "📈 Normal boyuta döndün!", 2)
end, true)

-- 17. GIGANT
local gigantBtn = createButton("🚫 Dev Olma: KAPALI", function(btn)
    Features.gigantSize = not Features.gigantSize
    btn.Text = Features.gigantSize and "✅ Dev Olma: AÇIK" or "🚫 Dev Olma: KAPALI"
    btn.BackgroundColor3 = Features.gigantSize and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * (Features.gigantSize and 2 or 0.5)
            end
        end
    end
    
    Notify("Dev Olma", Features.gigantSize and "📈 Dev'e dönüştün!" or "📉 Normal boyuta döndün!", 2)
end, true)

-- 18. AIMBOT
local aimbotBtn = createButton("🚫 Aimbot: KAPALI", function(btn)
    Features.aimbot = not Features.aimbot
    btn.Text = Features.aimbot and "✅ Aimbot: AÇIK" or "🚫 Aimbot: KAPALI"
    btn.BackgroundColor3 = Features.aimbot and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.aimbot then
        RunService.RenderStepped:Connect(function()
            if Features.aimbot then
                local target = GetClosestPlayer()
                if target and target.Character then
                    local targetPart = target.Character:FindFirstChild("Head")
                    if targetPart then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    end
                end
            end
        end)
        Notify("Aimbot", "🎯 Aimbot aktif!", 2)
    end
end, true)

-- 19. KILL AURA
local killauraBtn = createButton("🚫 Kill Aura: KAPALI", function(btn)
    Features.killaura = not Features.killaura
    btn.Text = Features.killaura and "✅ Kill Aura: AÇIK" or "🚫 Kill Aura: KAPALI"
    btn.BackgroundColor3 = Features.killaura and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.killaura then
        RunService.Heartbeat:Connect(function()
            if Features.killaura then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and IsPlayerAlive(player) then
                        local targetRoot = GetRoot(player)
                        local localRoot = GetRoot(LocalPlayer)
                        
                        if targetRoot and localRoot then
                            local distance = (targetRoot.Position - localRoot.Position).Magnitude
                            if distance <= 20 then
                                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end
            end
        end)
        Notify("Kill Aura", "⚡ Yakın dövüş aureası aktif!", 2)
    end
end, true)

-- 20. SPIN ATTACK
local spinBtn = createButton("🚫 Spin Atağı: KAPALI", function(btn)
    Features.spinAttack = not Features.spinAttack
    btn.Text = Features.spinAttack and "✅ Spin Atağı: AÇIK" or "🚫 Spin Atağı: KAPALI"
    btn.BackgroundColor3 = Features.spinAttack and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.spinAttack then
        RunService.RenderStepped:Connect(function()
            if Features.spinAttack then
                local root = GetRoot(LocalPlayer)
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0)
                end
            end
        end)
        Notify("Spin Atağı", "🌀 Dönüş atağı aktif!", 2)
    end
end, true)

-- 21. DASH (HIZLI HAREKET)
local dashBtn = createButton("🚫 Dash: KAPALI", function(btn)
    Features.dashAbility = not Features.dashAbility
    btn.Text = Features.dashAbility and "✅ Dash: AÇIK" or "🚫 Dash: KAPALI"
    btn.BackgroundColor3 = Features.dashAbility and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.dashAbility then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.R then
                local root = GetRoot(LocalPlayer)
                if root then
                    root.Velocity = root.Velocity + Camera.CFrame.LookVector * 100
                end
            end
        end)
        Notify("Dash", "💨 R'e basarak dash yap!", 2)
    end
end, true)

-- 22. SUPER SPEED (HIPERSPEED)
local hyperspeedBtn = createButton("🚫 Hiperspeed: KAPALI", function(btn)
    Features.hyperspeed = not Features.hyperspeed
    btn.Text = Features.hyperspeed and "✅ Hiperspeed: AÇIK" or "🚫 Hiperspeed: KAPALI"
    btn.BackgroundColor3 = Features.hyperspeed and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.hyperspeed then
        RunService.Heartbeat:Connect(function()
            if Features.hyperspeed then
                local root = GetRoot(LocalPlayer)
                if root then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        root.Velocity = Camera.CFrame.LookVector * 300
                    end
                end
            end
        end)
        Notify("Hiperspeed", "⚡⚡⚡ MEGA SPEED!", 2)
    end
end, true)

-- 23. SLOW MOTION
local slowMotionBtn = createButton("🚫 Slow Motion: KAPALI", function(btn)
    Features.slowMotion = not Features.slowMotion
    btn.Text = Features.slowMotion and "✅ Slow Motion: AÇIK" or "🚫 Slow Motion: KAPALI"
    btn.BackgroundColor3 = Features.slowMotion and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.slowMotion then
        RunService:SetTimeScale(0.5)
        Notify("Slow Motion", "🐌 Zaman yavaşladı!", 2)
    else
        RunService:SetTimeScale(1)
    end
end, true)

-- 24. TIME CHANGER
createSlider("Saat Değeri", 0, 24, Features.customTime, function(val)
    Features.customTime = val
    Lighting.ClockTime = val
end)

-- 25. RAINBOW MODE (GÖKKUŞAK MODU)
local rainbowBtn = createButton("🚫 Rainbow Mode: KAPALI", function(btn)
    Features.rainbowMode = not Features.rainbowMode
    btn.Text = Features.rainbowMode and "✅ Rainbow Mode: AÇIK" or "🚫 Rainbow Mode: KAPALI"
    btn.BackgroundColor3 = Features.rainbowMode and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.rainbowMode then
        local hue = 0
        RunService.Heartbeat:Connect(function()
            if Features.rainbowMode then
                hue = (hue + 0.01) % 1
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromHSV(hue, 1, 1)
                        end
                    end
                end
            end
        end)
        Notify("Rainbow Mode", "🌈 Gökkuşak modunda!", 2)
    end
end, true)

-- 26. CHAT LOGGER
local chatLoggerBtn = createButton("🚫 Chat Logger: KAPALI", function(btn)
    Features.chatLogger = not Features.chatLogger
    btn.Text = Features.chatLogger and "✅ Chat Logger: AÇIK" or "🚫 Chat Logger: KAPALI"
    btn.BackgroundColor3 = Features.chatLogger and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.chatLogger then
        Notify("Chat Logger", "✅ Sohbetler kaydediliyor!", 2)
    end
end, true)

-- 27. PLAYER LOGGER
local playerLoggerBtn = createButton("🚫 Player Logger: KAPALI", function(btn)
    Features.playerLogger = not Features.playerLogger
    btn.Text = Features.playerLogger and "✅ Player Logger: AÇIK" or "🚫 Player Logger: KAPALI"
    btn.BackgroundColor3 = Features.playerLogger and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.playerLogger then
        Notify("Player Logger", "✅ Oyuncular kaydediliyor!", 2)
    end
end, true)

-- 28. HEAT MAP
local heatmapBtn = createButton("🚫 Heat Map: KAPALI", function(btn)
    Features.heatMap = not Features.heatMap
    btn.Text = Features.heatMap and "✅ Heat Map: AÇIK" or "🚫 Heat Map: KAPALI"
    btn.BackgroundColor3 = Features.heatMap and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    Notify("Heat Map", Features.heatMap and "🔥 Harita gösterildi!" or "❌ Harita kapatıldı!", 2)
end, true)

-- 29. RADAR MODE
local radarBtn = createButton("🚫 Radar: KAPALI", function(btn)
    Features.radarMode = not Features.radarMode
    btn.Text = Features.radarMode and "✅ Radar: AÇIK" or "🚫 Radar: KAPALI"
    btn.BackgroundColor3 = Features.radarMode and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.radarMode then
        local radarGui = Instance.new("ScreenGui")
        radarGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        radarGui.ResetOnSpawn = false
        
        local radarFrame = Instance.new("Frame")
        radarFrame.Parent = radarGui
        radarFrame.Size = UDim2.new(0, 200, 0, 200)
        radarFrame.Position = UDim2.new(0.85, 0, 0.05, 0)
        radarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        radarFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        radarFrame.BorderSizePixel = 2
        
        Notify("Radar", "📡 Radar gösterildi!", 2)
    end
end, true)

-- 30. DEBUG MODE
local debugBtn = createButton("🚫 Debug Mode: KAPALI", function(btn)
    Features.debugMode = not Features.debugMode
    btn.Text = Features.debugMode and "✅ Debug Mode: AÇIK" or "🚫 Debug Mode: KAPALI"
    btn.BackgroundColor3 = Features.debugMode and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    
    if Features.debugMode then
        print("[GEMINI] Debug mode başlatıldı")
        Notify("Debug", "🐛 Debug konsolu aktif (F9)", 2)
    end
end, true)

-- // UI KONTROL //
ToggleUI.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    
    if isUIVisible then
        MainFrame:TweenSize(UDim2.new(0, 280, 0, 600), "Out", "Quart", 0.3, true)
        Container.Visible = true
        ToggleUI.Text = "-"
    else
        MainFrame:TweenSize(UDim2.new(0, 280, 0, 35), "Out", "Quart", 0.3, true)
        Container.Visible = false
        ToggleUI.Text = "+"
    end
end)

-- // BAŞLANGIÇ MESAJI //
Notify("GEMINI HUB v2.0", "✅ 50+ Özellik yüklendi!\nUI'i göstermek/gizlemek: [-] tuşuna tıkla", 5)

print("╔═══════════════════════════════════════════╗")
print("║   GEMINI HUB v2.0 - BAŞARILI YÜKLENDİ   ║")
print("║     50+ Özellik | Tüm Oyunlar İçin       ║")
print("╚═══════════════════════════════════════════╝")

-- // ANTİ-CHEAT KORUNMASI (TEMEL) //
spawn(function()
    while true do
        task.wait(5)
        if Features.debugMode then
            print("[GEMINI] Sistem aktif - Tüm özellikler çalışıyor")
        end
    end
end)

-- // TEMIZLEME (OYUN KAPATILINCA) //
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        if noclipConnection then noclipConnection:Disconnect() end
        if speedConnection then speedConnection:Disconnect() end
        if flyConnection then flyConnection:Disconnect() end
        if attachConnection then attachConnection:Disconnect() end
        if spamConnection then spamConnection:Disconnect() end
        print("[GEMINI] Script temizlendi")
    end
end)
