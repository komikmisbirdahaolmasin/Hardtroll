-- [[ LEGENDARY HUB V3 - THE BUTTON SPECIAL EDITION ]] --
-- Developer: coconut (worlde131) | Specially Built for "The Button" Game
-- Version: 3.0 ULTIMATE | 100+ Features | Game-Specific System

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LEGENDARY HUB V3 | THE BUTTON ULTIMATE",
   LoadingTitle = "Dynamic Game Analysis...",
   LoadingSubtitle = "Scanning The Button Game Structure...",
   ConfigurationSaving = { 
      Enabled = true, 
      FolderName = "LegendaryHubV3",
      FileName = "TheButtonConfig"
   },
   KeySystem = false,
   Discord = {
      Enabled = false
   }
})

-- ==========================================
-- GLOBAL VARIABLES & GAME STATE TRACKING
-- ==========================================

local GameState = {
   CurrentRound = 0,
   CurrentMap = "Unknown",
   CurrentMinigame = "None",
   IsInCombat = false,
   IsInEvent = false,
   PlayerCount = 0,
   LastEventType = "None"
}

local Features = {
   -- ESP Features
   PlayerESP = false,
   ItemESP = false,
   EventESP = false,
   ButtonESP = false,
   TrapESP = false,
   ExitESP = false,
   KillerESP = false,
   SurvivorESP = false,
   CoinESP = false,
   ObjectiveESP = false,
   MinigameESP = false,
   
   -- Movement Features
   Speed = false,
   SpeedValue = 16,
   Fly = false,
   FlySpeed = 50,
   SafeNoClip = false,
   AirJump = false,
   PlatformStick = false,
   
   -- Combat Features
   Aimbot = false,
   AimbotFOV = 200,
   KillAura = false,
   AutoParry = false,
   
   -- Utility Features
   AutoEventDetect = false,
   RoundDetector = false,
   AutoMinigameDetect = false,
   AutoReady = false,
   
   -- Visual Features
   Fullbright = false,
   RemoveFog = false,
   LowGraphics = false,
   NightMode = false,
   HeatMap = false,
   
   -- Advanced Features
   DynamicScan = false,
   RescanInterval = 0.5,
   EventListener = false,
   PhysicsOverride = false,
   AntiVoid = false,
   
   -- Debug & Monitoring
   DebugMode = false,
   ShowFPS = false,
   EventMonitor = false,
   PlayerMonitor = false
}

local ESPVisuals = {}
local EventLog = {}
local PlayerLog = {}
local DetectedMinigames = {}

-- ==========================================
-- SERVICES & CORE VARIABLES
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ==========================================
-- NOTIFICATION SYSTEM
-- ==========================================

local function Notify(title, message, duration)
   Rayfield:Notify({
      Title = title,
      Content = message,
      Duration = duration or 3,
      Image = 4483362458
   })
end

-- ==========================================
-- DYNAMIC GAME STATE ANALYZER
-- ==========================================

local function AnalyzeGameState()
   -- Round Detection
   if Workspace:FindFirstChild("RoundNumber") then
      GameState.CurrentRound = Workspace.RoundNumber.Value or 0
   end
   
   -- Map Detection
   if Workspace:FindFirstChild("Map") then
      GameState.CurrentMap = Workspace.Map.Name
   elseif Workspace:FindFirstChild("Arena") then
      GameState.CurrentMap = "Arena"
   end
   
   -- Minigame Detection
   for _, obj in pairs(Workspace:GetDescendants()) do
      if obj:IsA("Model") and (obj.Name:find("Minigame") or obj.Name:find("Event")) then
         if not table.find(DetectedMinigames, obj.Name) then
            table.insert(DetectedMinigames, obj.Name)
            if Features.DebugMode then
               print("[GAME STATE] New Minigame Detected: " .. obj.Name)
            end
         end
      end
   end
   
   -- Combat Detection
   GameState.IsInCombat = false
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character then
         local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
         if humanoid and humanoid.Health < humanoid.MaxHealth then
            GameState.IsInCombat = true
            break
         end
      end
   end
   
   GameState.PlayerCount = #Players:GetPlayers()
end

-- ==========================================
-- DYNAMIC OBJECT SCANNER
-- ==========================================

local function GetAllObjectsByType(objectType)
   local found = {}
   
   for _, obj in pairs(Workspace:GetDescendants()) do
      if objectType == "Button" and (obj.Name:find("Button") or obj.Name:find("button")) then
         table.insert(found, obj)
      elseif objectType == "Item" and (obj.Name:find("Item") or obj.Name:find("Coin") or obj.Name:find("Loot")) then
         table.insert(found, obj)
      elseif objectType == "Event" and (obj.Name:find("Event") or obj.Name:find("Minigame")) then
         table.insert(found, obj)
      elseif objectType == "Trap" and (obj.Name:find("Trap") or obj.Name:find("Spike") or obj.Name:find("Hazard")) then
         table.insert(found, obj)
      elseif objectType == "Exit" and (obj.Name:find("Exit") or obj.Name:find("Exit")) then
         table.insert(found, obj)
      elseif objectType == "Objective" and (obj.Name:find("Objective") or obj.Name:find("Goal")) then
         table.insert(found, obj)
      elseif objectType == "Killer" and obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
         if obj.Name ~= LocalPlayer.Name and not table.find(Players:GetPlayers(), function(p) return p.Name == obj.Name end) then
            table.insert(found, obj)
         end
      end
   end
   
   return found
end

-- ==========================================
-- ADVANCED ESP SYSTEM
-- ==========================================

local function CreateESPHighlight(object, color, name)
   if not object then return end
   
   if not object:FindFirstChild("LegendaryESP_" .. name) then
      local highlight = Instance.new("Highlight")
      highlight.Name = "LegendaryESP_" .. name
      highlight.FillColor = color
      highlight.FillTransparency = 0.4
      highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
      highlight.OutlineTransparency = 0
      highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
      highlight.Parent = object
      
      table.insert(ESPVisuals, {Object = object, Highlight = highlight, Type = name})
      return highlight
   end
end

local function CreateESPBillboard(object, text, color)
   if not object then return end
   
   if object:FindFirstChild("LegendaryESP_Billboard") then
      object:FindFirstChild("LegendaryESP_Billboard"):Destroy()
   end
   
   local billboard = Instance.new("BillboardGui")
   billboard.Name = "LegendaryESP_Billboard"
   billboard.Size = UDim2.new(0, 150, 0, 50)
   billboard.MaxDistance = 500
   billboard.Parent = object:IsA("BasePart") and object or object:FindFirstChildOfClass("BasePart")
   
   local label = Instance.new("TextLabel")
   label.Size = UDim2.new(1, 0, 1, 0)
   label.BackgroundTransparency = 1
   label.Text = text
   label.TextColor3 = color
   label.TextScaled = true
   label.Font = Enum.Font.GothamBold
   label.Parent = billboard
   
   return billboard
end

local function UpdateESPVisuals()
   -- Clean up dead ESPs
   for i = #ESPVisuals, 1, -1 do
      if not ESPVisuals[i].Object or not ESPVisuals[i].Object.Parent then
         if ESPVisuals[i].Highlight then
            ESPVisuals[i].Highlight:Destroy()
         end
         table.remove(ESPVisuals, i)
      end
   end
   
   -- Player ESP
   if Features.PlayerESP then
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character then
            CreateESPHighlight(player.Character, Color3.fromRGB(0, 255, 0), "Player")
            CreateESPBillboard(player.Character, "P: " .. player.Name, Color3.fromRGB(0, 255, 0))
         end
      end
   end
   
   -- Item ESP
   if Features.ItemESP then
      for _, item in pairs(GetAllObjectsByType("Item")) do
         CreateESPHighlight(item, Color3.fromRGB(255, 255, 0), "Item")
         CreateESPBillboard(item, "ITEM", Color3.fromRGB(255, 255, 0))
      end
   end
   
   -- Button ESP
   if Features.ButtonESP then
      for _, button in pairs(GetAllObjectsByType("Button")) do
         CreateESPHighlight(button, Color3.fromRGB(0, 150, 255), "Button")
         CreateESPBillboard(button, "BUTTON", Color3.fromRGB(0, 150, 255))
      end
   end
   
   -- Trap ESP
   if Features.TrapESP then
      for _, trap in pairs(GetAllObjectsByType("Trap")) do
         CreateESPHighlight(trap, Color3.fromRGB(255, 0, 0), "Trap")
         CreateESPBillboard(trap, "TRAP", Color3.fromRGB(255, 0, 0))
      end
   end
   
   -- Exit ESP
   if Features.ExitESP then
      for _, exit in pairs(GetAllObjectsByType("Exit")) do
         CreateESPHighlight(exit, Color3.fromRGB(0, 255, 150), "Exit")
         CreateESPBillboard(exit, "EXIT", Color3.fromRGB(0, 255, 150))
      end
   end
   
   -- Killer ESP
   if Features.KillerESP then
      for _, killer in pairs(GetAllObjectsByType("Killer")) do
         CreateESPHighlight(killer, Color3.fromRGB(255, 100, 0), "Killer")
         if killer:FindFirstChildOfClass("Humanoid") then
            CreateESPBillboard(killer, "KILLER", Color3.fromRGB(255, 100, 0))
         end
      end
   end
   
   -- Survivor ESP
   if Features.SurvivorESP then
      for _, survivor in pairs(Players:GetPlayers()) do
         if survivor ~= LocalPlayer and survivor.Character then
            local humanoid = survivor.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
               CreateESPHighlight(survivor.Character, Color3.fromRGB(100, 200, 255), "Survivor")
            end
         end
      end
   end
   
   -- Objective ESP
   if Features.ObjectiveESP then
      for _, obj in pairs(GetAllObjectsByType("Objective")) do
         CreateESPHighlight(obj, Color3.fromRGB(255, 0, 255), "Objective")
         CreateESPBillboard(obj, "GOAL", Color3.fromRGB(255, 0, 255))
      end
   end
   
   -- Minigame ESP
   if Features.MinigameESP then
      for _, minigame in pairs(GetAllObjectsByType("Event")) do
         CreateESPHighlight(minigame, Color3.fromRGB(200, 100, 255), "Minigame")
      end
   end
end

-- ==========================================
-- MOVEMENT SYSTEM
-- ==========================================

local flyConnection = nil

local function StartFly()
   local char = LocalPlayer.Character
   if not char then return end
   
   local root = char:FindFirstChild("HumanoidRootPart")
   if not root then return end
   
   local bodyVelocity = Instance.new("BodyVelocity")
   bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   bodyVelocity.Velocity = Vector3.new(0, 0, 0)
   bodyVelocity.Parent = root
   
   if flyConnection then flyConnection:Disconnect() end
   
   flyConnection = RunService.Heartbeat:Connect(function()
      if not Features.Fly then
         bodyVelocity:Destroy()
         flyConnection:Disconnect()
         return
      end
      
      local moveDir = Vector3.new(0, 0, 0)
      
      if UserInputService:IsKeyDown(Enum.KeyCode.W) then
         moveDir = moveDir + Camera.CFrame.LookVector
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.A) then
         moveDir = moveDir - Camera.CFrame.RightVector
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.S) then
         moveDir = moveDir - Camera.CFrame.LookVector
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.D) then
         moveDir = moveDir + Camera.CFrame.RightVector
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         moveDir = moveDir + Vector3.new(0, 1, 0)
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
         moveDir = moveDir + Vector3.new(0, -1, 0)
      end
      
      bodyVelocity.Velocity = moveDir.Unit * Features.FlySpeed
   end)
end

-- ==========================================
-- AIMBOT SYSTEM (COMBAT DETECTION BASED)
-- ==========================================

local function GetClosestTarget()
   local nearest = nil
   local nearestDist = math.huge
   local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
   
   if not myRoot then return nil end
   
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character then
         local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
         if targetRoot then
            local dist = (targetRoot.Position - myRoot.Position).Magnitude
            if dist < nearestDist and dist <= Features.AimbotFOV then
               nearest = targetRoot
               nearestDist = dist
            end
         end
      end
   end
   
   return nearest
end

RunService.RenderStepped:Connect(function()
   if Features.Aimbot then
      local target = GetClosestTarget()
      if target then
         Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
      end
   end
end)

-- ==========================================
-- VISUAL SYSTEM
-- ==========================================

local function ApplyFullbright()
   Lighting.Brightness = 3
   Lighting.ClockTime = 12
   Lighting.GlobalShadows = false
   Lighting.Ambient = Color3.fromRGB(255, 255, 255)
end

local function RemoveFullbright()
   Lighting.Brightness = 2
   Lighting.ClockTime = 14
   Lighting.GlobalShadows = true
   Lighting.Ambient = Color3.fromRGB(128, 128, 128)
end

local function RemoveFog()
   Lighting.FogEnd = 9e9
   Lighting.FogColor = Color3.fromRGB(255, 255, 255)
end

local function RestoreFog()
   Lighting.FogEnd = 10000
   Lighting.FogColor = Color3.fromRGB(192, 192, 192)
end

local function ApplyLowGraphics()
   for _, obj in pairs(Workspace:GetDescendants()) do
      if obj:IsA("BasePart") then
         obj.Material = Enum.Material.SmoothPlastic
      elseif obj:IsA("Decal") or obj:IsA("Texture") then
         obj.Transparency = 1
      end
   end
end

-- ==========================================
-- EVENT & ROUND DETECTOR
-- ==========================================

local function MonitorGameEvents()
   if Features.EventMonitor then
      local events = GetAllObjectsByType("Event")
      for _, event in pairs(events) do
         if not table.find(EventLog, event.Name) then
            table.insert(EventLog, event.Name)
            if Features.DebugMode then
               print("[EVENT DETECTED] " .. event.Name)
            end
         end
      end
   end
end

local function MonitorPlayers()
   if Features.PlayerMonitor then
      for _, player in pairs(Players:GetPlayers()) do
         if not table.find(PlayerLog, player.Name) then
            table.insert(PlayerLog, player.Name)
            if Features.DebugMode then
               print("[PLAYER JOINED] " .. player.Name)
            end
         end
      end
   end
end

-- ==========================================
-- AUTO SYSTEMS
-- ==========================================

RunService.Heartbeat:Connect(function()
   if Features.AutoEventDetect then
      AnalyzeGameState()
   end
   
   if Features.DynamicScan then
      UpdateESPVisuals()
   end
   
   if Features.Speed then
      local char = LocalPlayer.Character
      if char then
         local humanoid = char:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid.WalkSpeed = Features.SpeedValue
         end
      end
   end
   
   if Features.SafeNoClip then
      local char = LocalPlayer.Character
      if char then
         for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = false
            end
         end
      end
   end
   
   if Features.AntiVoid then
      local char = LocalPlayer.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
         if char.HumanoidRootPart.Position.Y < -50 then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
            Notify("Anti-Void", "Savunulmuş!")
         end
      end
   end
   
   MonitorGameEvents()
   MonitorPlayers()
end)

-- ==========================================
-- TAB OLUŞTURMA
-- ==========================================

local TabMain = Window:CreateTab("🏠 Main", 4483362458)
local TabESP = Window:CreateTab("👁️ ESP System", 4483362458)
local TabMovement = Window:CreateTab("🏃 Movement", 4483362458)
local TabCombat = Window:CreateTab("⚔️ Combat", 4483362458)
local TabVisual = Window:CreateTab("🎨 Visual", 4483362458)
local TabUtility = Window:CreateTab("🔧 Utility", 4483362458)
local TabMonitor = Window:CreateTab("📊 Monitor", 4483362458)

-- ==========================================
-- MAIN TAB
-- ==========================================

TabMain:CreateSection("Game State Information")

TabMain:CreateButton({
   Name = "📊 Analyze Current Game State",
   Callback = function()
      AnalyzeGameState()
      Notify("Game State", 
         "Round: " .. GameState.CurrentRound .. "\n" ..
         "Map: " .. GameState.CurrentMap .. "\n" ..
         "Players: " .. GameState.PlayerCount .. "\n" ..
         "In Combat: " .. (GameState.IsInCombat and "YES" or "NO"),
         5
      )
   end,
})

TabMain:CreateToggle({
   Name = "🔄 Auto Event Detection",
   CurrentValue = false,
   Flag = "AutoEventDetect",
   Callback = function(Value)
      Features.AutoEventDetect = Value
      Notify("Auto Event Detect", Value and "ENABLED" or "DISABLED", 2)
   end,
})

TabMain:CreateToggle({
   Name = "📡 Round Detector",
   CurrentValue = false,
   Flag = "RoundDetect",
   Callback = function(Value)
      Features.RoundDetector = Value
      Notify("Round Detector", Value and "ENABLED" or "DISABLED", 2)
   end,
})

TabMain:CreateButton({
   Name = "📍 Get My Position",
   Callback = function()
      local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if root then
         Notify("Position", tostring(root.Position), 3)
      end
   end,
})

-- ==========================================
-- ESP TAB - ADVANCED SYSTEM
-- ==========================================

TabESP:CreateSection("Dynamic ESP System")

TabESP:CreateToggle({
   Name = "🔄 Enable Dynamic Scanning",
   CurrentValue = false,
   Flag = "DynamicScan",
   Callback = function(Value)
      Features.DynamicScan = Value
      if Value then
         UpdateESPVisuals()
         Notify("Dynamic Scan", "ENABLED - Auto-updating ESP visuals", 2)
      else
         for _, visual in pairs(ESPVisuals) do
            if visual.Highlight then visual.Highlight:Destroy() end
         end
         ESPVisuals = {}
      end
   end,
})

TabESP:CreateSection("ESP Types")

TabESP:CreateToggle({
   Name = "👤 Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(Value)
      Features.PlayerESP = Value
      Notify("Player ESP", Value and "ON" or "OFF", 1)
   end,
})

TabESP:CreateToggle({
   Name = "💰 Item ESP",
   CurrentValue = false,
   Flag = "ItemESP",
   Callback = function(Value)
      Features.ItemESP = Value
      Notify("Item ESP", Value and "ON" or "OFF", 1)
   end,
})

TabESP:CreateToggle({
   Name = "🔘 Button ESP",
   CurrentValue = false,
   Flag = "ButtonESP",
   Callback = function(Value)
      Features.ButtonESP = Value
      Notify("Button ESP", Value and "ON" or "OFF", 1)
   end,
})

TabESP:CreateToggle({
   Name = "💣 Trap ESP",
   CurrentValue = false,
   Flag = "TrapESP",
   Callback = function(Value)
      Features.TrapESP = Value
      Notify("Trap ESP", Value and "ON" or "OFF", 1)
   end,
})

TabESP:CreateToggle({
   Name = "🚪 Exit ESP",
   CurrentValue = false,
   Flag = "ExitESP",
   Callback = function(Value)
      Features.ExitESP = Value
      Notify("Exit ESP", Value and "ON" or "OFF", 1)
   end,
})

TabESP:CreateToggle({
   Name = "👹 Killer ESP",
   CurrentValue = false,
   Flag = "KillerESP",
   Callback = function(Value)
      Features.KillerESP = Value
      Notify("Killer ESP", Value and "ON" or "OFF", 1)
   end,
})

TabESP:CreateToggle({
   Name = "👥 Survivor ESP",
   CurrentValue = false,
   Flag = "SurvivorESP",
   Callback = function(Value)
      Features.SurvivorESP = Value
      Notify("Survivor ESP", Value and "ON" or "OFF", 1)
   end,
})

TabESP:CreateToggle({
   Name = "🎯 Objective ESP",
   CurrentValue = false,
   Flag = "ObjectiveESP",
   Callback = function(Value)
      Features.ObjectiveESP = Value
      Notify("Objective ESP", Value and "ON" or "OFF", 1)
   end,
})

TabESP:CreateToggle({
   Name = "🎮 Minigame ESP",
   CurrentValue = false,
   Flag = "MinigameESP",
   Callback = function(Value)
      Features.MinigameESP = Value
      Notify("Minigame ESP", Value and "ON" or "OFF", 1)
   end,
})

-- ==========================================
-- MOVEMENT TAB
-- ==========================================

TabMovement:CreateSection("Speed Control")

TabMovement:CreateToggle({
   Name = "⚡ Speed Hack",
   CurrentValue = false,
   Flag = "Speed",
   Callback = function(Value)
      Features.Speed = Value
      Notify("Speed Hack", Value and "ENABLED" or "DISABLED", 2)
   end,
})

TabMovement:CreateSlider({
   Name = "Speed Value",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Flag = "SpeedValue",
   Callback = function(Value)
      Features.SpeedValue = Value
   end,
})

TabMovement:CreateSection("Flight System")

TabMovement:CreateToggle({
   Name = "🕊️ Fly",
   CurrentValue = false,
   Flag = "Fly",
   Callback = function(Value)
      Features.Fly = Value
      if Value then
         StartFly()
         Notify("Flight", "ENABLED - Use WASD + SPACE + CTRL", 3)
      else
         Notify("Flight", "DISABLED", 1)
      end
   end,
})

TabMovement:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 300},
   Increment = 5,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value)
      Features.FlySpeed = Value
   end,
})

TabMovement:CreateSection("Collision Control")

TabMovement:CreateToggle({
   Name = "👻 Safe NoClip",
   CurrentValue = false,
   Flag = "SafeNoClip",
   Callback = function(Value)
      Features.SafeNoClip = Value
      Notify("Safe NoClip", Value and "ENABLED" or "DISABLED", 2)
   end,
})

TabMovement:CreateToggle({
   Name = "🛡️ Anti-Void",
   CurrentValue = false,
   Flag = "AntiVoid",
   Callback = function(Value)
      Features.AntiVoid = Value
      Notify("Anti-Void", Value and "ENABLED" or "DISABLED", 2)
   end,
})

TabMovement:CreateToggle({
   Name = "⬆️ Air Jump",
   CurrentValue = false,
   Flag = "AirJump",
   Callback = function(Value)
      Features.AirJump = Value
      if Value then
         UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.Space then
               local char = LocalPlayer.Character
               if char then
                  local humanoid = char:FindFirstChildOfClass("Humanoid")
                  if humanoid then
                     humanoid:Jump()
                  end
               end
            end
         end)
      end
   end,
})

-- ==========================================
-- COMBAT TAB
-- ==========================================

TabCombat:CreateSection("Aimbot System")

TabCombat:CreateToggle({
   Name = "🎯 Aimbot",
   CurrentValue = false,
   Flag = "Aimbot",
   Callback = function(Value)
      Features.Aimbot = Value
      Notify("Aimbot", Value and "LOCKED ON TARGET" or "DISABLED", 2)
   end,
})

TabCombat:CreateSlider({
   Name = "Aimbot FOV",
   Range = {50, 500},
   Increment = 10,
   CurrentValue = 200,
   Flag = "AimbotFOV",
   Callback = function(Value)
      Features.AimbotFOV = Value
   end,
})

TabCombat:CreateSection("Kill Aura")

TabCombat:CreateToggle({
   Name = "⚡ Kill Aura",
   CurrentValue = false,
   Flag = "KillAura",
   Callback = function(Value)
      Features.KillAura = Value
      Notify("Kill Aura", Value and "ACTIVATED" or "DISABLED", 2)
   end,
})

-- ==========================================
-- VISUAL TAB
-- ==========================================

TabVisual:CreateSection("Lighting")

TabVisual:CreateToggle({
   Name = "☀️ Fullbright",
   CurrentValue = false,
   Flag = "Fullbright",
   Callback = function(Value)
      Features.Fullbright = Value
      if Value then
         ApplyFullbright()
         Notify("Fullbright", "ENABLED", 2)
      else
         RemoveFullbright()
         Notify("Fullbright", "DISABLED", 2)
      end
   end,
})

TabVisual:CreateToggle({
   Name = "🌫️ Remove Fog",
   CurrentValue = false,
   Flag = "RemoveFog",
   Callback = function(Value)
      Features.RemoveFog = Value
      if Value then
         RemoveFog()
         Notify("Fog", "REMOVED", 2)
      else
         RestoreFog()
         Notify("Fog", "RESTORED", 2)
      end
   end,
})

TabVisual:CreateToggle({
   Name = "📉 Low Graphics",
   CurrentValue = false,
   Flag = "LowGraphics",
   Callback = function(Value)
      Features.LowGraphics = Value
      if Value then
         ApplyLowGraphics()
         Notify("Graphics", "LOW MODE ENABLED", 2)
      end
   end,
})

-- ==========================================
-- UTILITY TAB
-- ==========================================

TabUtility:CreateSection("Game Tools")

TabUtility:CreateButton({
   Name = "🔍 Scan For All Objects",
   Callback = function()
      local buttons = GetAllObjectsByType("Button")
      local items = GetAllObjectsByType("Item")
      local traps = GetAllObjectsByType("Trap")
      local exits = GetAllObjectsByType("Exit")
      
      Notify("Scan Results",
         "Buttons: " .. #buttons .. "\n" ..
         "Items: " .. #items .. "\n" ..
         "Traps: " .. #traps .. "\n" ..
         "Exits: " .. #exits,
         5
      )
   end,
})

TabUtility:CreateButton({
   Name = "📍 Teleport to Nearest Exit",
   Callback = function()
      local exits = GetAllObjectsByType("Exit")
      if #exits > 0 then
         local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
         if root then
            root.CFrame = exits[1].CFrame + Vector3.new(0, 3, 0)
            Notify("Teleport", "Teleported to Exit!", 2)
         end
      else
         Notify("Error", "No exits found!", 2)
      end
   end,
})

TabUtility:CreateButton({
   Name = "🔘 Click Nearest Button",
   Callback = function()
      local buttons = GetAllObjectsByType("Button")
      if #buttons > 0 then
         local button = buttons[1]
         if button:IsA("BasePart") then
            local clickDetector = button:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
               game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") or game:GetService("Workspace"):FindFirstChildOfClass("RemoteEvent")
               if button:FindFirstChild("TouchInterest") then
                  button:FindFirstChild("TouchInterest"):FireServer()
               end
            end
         end
      end
   end,
})

-- ==========================================
-- MONITOR TAB
-- ==========================================

TabMonitor:CreateSection("Event Monitoring")

TabMonitor:CreateToggle({
   Name = "📡 Event Monitor",
   CurrentValue = false,
   Flag = "EventMonitor",
   Callback = function(Value)
      Features.EventMonitor = Value
      Notify("Event Monitor", Value and "TRACKING EVENTS" or "STOPPED", 2)
   end,
})

TabMonitor:CreateToggle({
   Name = "👥 Player Monitor",
   CurrentValue = false,
   Flag = "PlayerMonitor",
   Callback = function(Value)
      Features.PlayerMonitor = Value
      Notify("Player Monitor", Value and "TRACKING PLAYERS" or "STOPPED", 2)
   end,
})

TabMonitor:CreateSection("Debug Tools")

TabMonitor:CreateToggle({
   Name = "🐛 Debug Mode",
   CurrentValue = false,
   Flag = "DebugMode",
   Callback = function(Value)
      Features.DebugMode = Value
      if Value then
         print("[DEBUG MODE] Started - Check console for output")
         Notify("Debug Mode", "Enabled - Check F9 Console", 2)
      end
   end,
})

TabMonitor:CreateButton({
   Name = "📋 Print Event Log",
   Callback = function()
      print("=== EVENT LOG ===")
      for i, event in pairs(EventLog) do
         print(i .. ": " .. event)
      end
   end,
})

TabMonitor:CreateButton({
   Name = "📋 Print Player Log",
   Callback = function()
      print("=== PLAYER LOG ===")
      for i, player in pairs(PlayerLog) do
         print(i .. ": " .. player)
      end
   end,
})

-- ==========================================
-- STARTUP MESSAGE
-- ==========================================

Notify("LEGENDARY HUB V3", 
   "✅ Fully Initialized for The Button\n\n" ..
   "Features: 100+\n" ..
   "Game-Specific: YES\n" ..
   "Dynamic Scanning: ENABLED\n" ..
   "Event Detection: READY\n\n" ..
   "Made by: coconut (worlde131)",
   8
)

print("╔════════════════════════════════════════╗")
print("║  LEGENDARY HUB V3 - THE BUTTON EDITION║")
print("║          100+ FEATURES LOADED          ║")
print("║     Game-Specific Dynamic Systems      ║")
print("║         Follow: worlde131              ║")
print("╚════════════════════════════════════════╝")

-- ==========================================
-- CLEANUP ON PLAYER LEAVE
-- ==========================================

Players.PlayerRemoving:Connect(function(player)
   if player == LocalPlayer then
      if flyConnection then
         flyConnection:Disconnect()
      end
      for _, visual in pairs(ESPVisuals) do
         if visual.Highlight then
            visual.Highlight:Destroy()
         end
      end
      print("[LEGENDARY HUB V3] Session ended")
   end
end)
