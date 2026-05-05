local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("FatalityWins_Final") then CoreGui.FatalityWins_Final:Destroy() end

getgenv().FatalityWinsRunning = true
getgenv().FatalityState = {
    Rage = false,
    Aimbot = false,
    Trigger = false,
    Silent = false,
    ESP = false,
    Tracers = false,
    Ammo = false,
    Acc = false,
    FireRate = false,
    Auto = false,
    WallBang = false,
    NoAnims = false,
    AutoInspect = false,
    Lines = {}
}

local MyUI = nil
local uiVisible = true
local isShooting = false

local function SyncUI()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name == "Wizard" or v:FindFirstChild("Main")) then
            MyUI = v
            return v
        end
    end
end

local function isEnemy(p)
    if not p or p == LocalPlayer or not p.Character then return false end
    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    local specBox = workspace:FindFirstChild("SpectatorBox")
    if specBox and char:IsDescendantOf(specBox) then return false end
    local pos = hrp.Position
    if pos.Y < -50 or pos.Y > 400 or (pos - Vector3.new(0,0,0)).Magnitude > 900 then return false end
    if p.Team ~= LocalPlayer.Team then return true end
    local myTorso = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("UpperTorso")
    local theirTorso = char:FindFirstChild("UpperTorso")
    if myTorso and theirTorso then
        return myTorso.BrickColor ~= theirTorso.BrickColor
    end
    return false
end

local function shoot()
    if isShooting then return end
    isShooting = true
    task.spawn(function()
        pcall(function()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local shootFunc = tool:FindFirstChild("Shoot") or tool:FindFirstChild("Fire") or tool:FindFirstChild("shoot") or tool:FindFirstChild("fire")
                if shootFunc and shootFunc:IsA("RemoteEvent") then
                    shootFunc:FireServer(Mouse.Hit.Position)
                elseif shootFunc and shootFunc:IsA("BindableEvent") then
                    shootFunc:Fire(Mouse.Hit.Position)
                else
                    local remote = tool:FindFirstChildOfClass("RemoteEvent")
                    if remote then
                        remote:FireServer(Mouse.Hit.Position)
                    else
                        mouse1press()
                        task.wait(0.05)
                        mouse1release()
                    end
                end
            else
                mouse1press()
                task.wait(0.05)
                mouse1release()
            end
        end)
        task.wait(0.05)
        isShooting = false
    end)
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local Window = Library:NewWindow("Fatality Wins Arsenal V2")
task.wait(0.5)
SyncUI()

local function GetClosestTarget()
    local target, dist = nil, 1000
    local mLoc = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character and p.Character:FindFirstChild("Head") then
            local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if on then
                local dx = pos.X - mLoc.X
                local dy = pos.Y - mLoc.Y
                local mag = math.sqrt(dx*dx + dy*dy)
                if mag < dist then target = p; dist = mag end
            end
        end
    end
    return target
end

local function createBox(player)
    if player.Character and not player.Character:FindFirstChild("FatalityBox") then
        local box = Instance.new("BillboardGui", player.Character)
        box.Name = "FatalityBox"; box.Size = UDim2.new(4,0,5,0); box.AlwaysOnTop = true
        box.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
        local t = 0.05
        local function f(p,s)
            local fr = Instance.new("Frame", box); fr.Size = s; fr.Position = p; fr.BackgroundColor3 = Color3.new(1,0,0); fr.BorderSizePixel = 0
        end
        f(UDim2.new(0,0,0,0), UDim2.new(1,0,t,0))
        f(UDim2.new(0,0,1-t,0), UDim2.new(1,0,t,0))
        f(UDim2.new(0,0,0,0), UDim2.new(t,0,1,0))
        f(UDim2.new(1-t,0,0,0), UDim2.new(t,0,1,0))
    end
end

local Combat = Window:NewSection("Combat")
local Rage = Window:NewSection("Rage")
local Visuals = Window:NewSection("Visuals")
local Mods = Window:NewSection("Gun Mods")
local Misc = Window:NewSection("Misc")

Combat:CreateToggle("Aimbot", function(s) getgenv().FatalityState.Aimbot = s end)
Combat:CreateToggle("Triggerbot", function(s) getgenv().FatalityState.Trigger = s end)

Combat:CreateToggle("Silent Aim", function(state)
    getgenv().FatalityState.Silent = state
    task.spawn(function()
        while getgenv().FatalityState.Silent and getgenv().FatalityWinsRunning do
            for _, v in pairs(Players:GetPlayers()) do
                if isEnemy(v) and v.Character then
                    pcall(function()
                        local parts = {"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}
                        for _, n in ipairs(parts) do
                            local p = v.Character:FindFirstChild(n)
                            if p then p.CanCollide = false; p.Transparency = 10; p.Size = Vector3.new(13,13,13) end
                        end
                    end)
                end
            end
            task.wait(1)
        end
    end)
end)

Rage:CreateToggle("Enable Ragebot", function(s) getgenv().FatalityState.Rage = s end)
Visuals:CreateToggle("Enemy Boxes", function(s) getgenv().FatalityState.ESP = s end)
Visuals:CreateToggle("Enemy Tracers", function(s) getgenv().FatalityState.Tracers = s end)

Mods:CreateToggle("Infinite Ammo (300)", function(s) getgenv().FatalityState.Ammo = s end)
Mods:CreateToggle("100% Accuracy", function(s) getgenv().FatalityState.Acc = s end)
Mods:CreateToggle("Rapid Fire", function(s) getgenv().FatalityState.FireRate = s end)
Mods:CreateToggle("All Automatic", function(s) getgenv().FatalityState.Auto = s end)

Misc:CreateToggle("WallBang", function(s) getgenv().FatalityState.WallBang = s end)
Misc:CreateToggle("No Animations", function(s) getgenv().FatalityState.NoAnims = s end)
Misc:CreateToggle("Auto Inspect", function(s) getgenv().FatalityState.AutoInspect = s end)
Misc:CreateButton("Unload Script", function()
    getgenv().FatalityWinsRunning = false
    for _, l in pairs(getgenv().FatalityState.Lines) do l:Remove() end
    if MyUI then MyUI:Destroy() end
end)

local frameSkip = 0
local modSkip = 0

RunService.RenderStepped:Connect(function()
    if not getgenv().FatalityWinsRunning then return end
    frameSkip = frameSkip + 1

    if getgenv().FatalityState.NoAnims and LocalPlayer.Character then
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end
            end
            if LocalPlayer.Character:FindFirstChild("Animate") then LocalPlayer.Character.Animate.Enabled = false end
        end)
    end

    if getgenv().FatalityState.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and not getgenv().FatalityState.Rage then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    if getgenv().FatalityState.Trigger then
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorWhichIsA("Model")
            if model then
                local plr = Players:GetPlayerFromCharacter(model)
                if plr and isEnemy(plr) then
                    mouse1press()
                    task.wait(0.025)
                    mouse1release()
                end
            end
        end
    end

    if frameSkip % 2 ~= 0 then return end

    local lIdx = 1
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if getgenv().FatalityState.ESP then createBox(p)
            else if p.Character:FindFirstChild("FatalityBox") then p.Character.FatalityBox:Destroy() end end

            if getgenv().FatalityState.Tracers then
                local pos, on = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if on then
                    local l = getgenv().FatalityState.Lines[lIdx] or Drawing.new("Line")
                    l.Visible = true; l.Thickness = 2; l.Color = Color3.new(1,0,0)
                    l.From = center; l.To = Vector2.new(pos.X, pos.Y)
                    getgenv().FatalityState.Lines[lIdx] = l; lIdx = lIdx + 1
                end
            end
        else
            if p.Character and p.Character:FindFirstChild("FatalityBox") then p.Character.FatalityBox:Destroy() end
        end
    end
    for i = lIdx, #getgenv().FatalityState.Lines do getgenv().FatalityState.Lines[i].Visible = false end
end)

RunService.Heartbeat:Connect(function()
    if not getgenv().FatalityWinsRunning then return end
    modSkip = modSkip + 1
    if modSkip % 10 ~= 0 then return end
    pcall(function()
        for _, v in next, ReplicatedStorage.Weapons:GetChildren() do
            for _, c in next, v:GetChildren() do
                if getgenv().FatalityState.Ammo and (c.Name == "Ammo" or c.Name == "StoredAmmo") then c.Value = 300 end
                if getgenv().FatalityState.Acc and (c.Name == "Spread" or c.Name == "RecoilControl") then c.Value = 0 end
                if getgenv().FatalityState.FireRate and c.Name == "FireRate" then c.Value = 0.05 end
                if getgenv().FatalityState.WallBang and (c.Name == "Wallbang" or c.Name == "Penetration") then c.Value = 100 end
            end
            if getgenv().FatalityState.Auto then
                local m = v:FindFirstChildOfClass("ModuleScript")
                if m then pcall(function() require(m).Auto = true end) end
            end
        end
    end)
end)

task.spawn(function()
    while task.wait(0.3) do
        if not getgenv().FatalityWinsRunning then break end
        if getgenv().FatalityState.AutoInspect and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait()
            VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if not getgenv().FatalityWinsRunning then break end
        if getgenv().FatalityState.Rage then
            pcall(function()
                local target = nil
                local dist = 1000
                for _, p in pairs(Players:GetPlayers()) do
                    if isEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                        if d < dist then target = p; dist = d end
                    end
                end
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local tHRP = target.Character.HumanoidRootPart
                        hrp.CFrame = CFrame.new(tHRP.Position + Vector3.new(0,9,0), tHRP.Position) * CFrame.Angles(0, tick() * 30, 0)
                        hrp.Velocity = Vector3.new(0,0,0)
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tHRP.Position)
                        Mouse.Hit = CFrame.new(tHRP.Position)
                        shoot()
                    end
                end
            end)
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if not MyUI then SyncUI() end
        if MyUI then
            uiVisible = not uiVisible
            MyUI.Enabled = uiVisible
        end
    end
end)
