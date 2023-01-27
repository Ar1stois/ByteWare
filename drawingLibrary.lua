getgenv().espSettings = {
    ['Box'] = {
        ['Enabled'] = false,
        ['Color'] = Color3.fromRGB(179, 0, 255)
    },
    ['Tracers'] = {
        ['Enabled'] = false,
        ['Color'] = Color3.fromRGB(179, 0, 255),
        ['Thickness'] = 1,
        ['Transparency'] = 0.5
    }
}

local function API_Check()
    if Drawing == nil then
        return "No"
    else
        return "Yes"
    end
end

local Find_Required = API_Check()

if Find_Required == "No" then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Unsupported";
        Text = "Your exploit does not support drawings.";
        Duration = math.huge;
        Button1 = "OK"
    })

    return
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TestService = game:GetService("TestService")

local function CreateTracers()
    for _, v in next, Players:GetPlayers() do
        if v.Name ~= game.Players.LocalPlayer.Name then
            local TracerLine = Drawing.new("Line")
    
            RunService.RenderStepped:Connect(function()
                if workspace:FindFirstChild(v.Name) ~= nil and workspace[v.Name]:FindFirstChild("HumanoidRootPart") ~= nil then
                    local HumanoidRootPart_Position, HumanoidRootPart_Size = workspace[v.Name].HumanoidRootPart.CFrame, workspace[v.Name].HumanoidRootPart.Size * 1
                    local Vector, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart_Position * CFrame.new(0, -HumanoidRootPart_Size.Y, 0).p)
                    
                    TracerLine.Thickness = getgenv().espSettings.Tracers.Thickness
                    TracerLine.Transparency = getgenv().espSettings.Tracers.Transparency
                    TracerLine.Color = getgenv().espSettings.Tracers.Color
                    TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

                    if OnScreen == true  then
                        TracerLine.To = Vector2.new(Vector.X, Vector.Y)
                        TracerLine.Visible = getgenv().espSettings.Tracers.Enabled
                    else
                        TracerLine.Visible = false
                    end
                else
                    TracerLine.Visible = false
                end
            end)

            Players.PlayerRemoving:Connect(function()
                TracerLine.Visible = false
            end)
        end
    end

    Players.PlayerAdded:Connect(function(Player)
        Player.CharacterAdded:Connect(function(v)
            if v.Name ~= game.Players.LocalPlayer.Name then
                local TracerLine = Drawing.new("Line")
        
                RunService.RenderStepped:Connect(function()
                    if workspace:FindFirstChild(v.Name) ~= nil and workspace[v.Name]:FindFirstChild("HumanoidRootPart") ~= nil then
                        local HumanoidRootPart_Position, HumanoidRootPart_Size = workspace[v.Name].HumanoidRootPart.CFrame, workspace[v.Name].HumanoidRootPart.Size * 1
                    	local Vector, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart_Position * CFrame.new(0, -HumanoidRootPart_Size.Y, 0).p)
                        
                        TracerLine.Thickness = getgenv().espSettings.Tracers.Thickness
                        TracerLine.Transparency = getgenv().espSettings.Tracers.Transprency
                        TracerLine.Color = getgenv().espSettings.Tracers.Color
                        TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

                        if OnScreen == true  then
                            TracerLine.To = Vector2.new(Vector.X, Vector.Y)
                            TracerLine.Visible = getgenv().espSettings.Tracers.Enabled
                        else
                            TracerLine.Visible = false
                        end
                    else
                        TracerLine.Visible = false
                    end
                end)

                Players.PlayerRemoving:Connect(function()
                    TracerLine.Visible = false
                end)
            end
        end)
    end)
end

local runService = game:GetService("RunService");
local players = game:GetService("Players");

local localPlayer = players.LocalPlayer;
local camera = workspace.CurrentCamera;

local newVector2, newColor3, newDrawing = Vector2.new, Color3.new, Drawing.new;
local tan, rad = math.tan, math.rad;
local round = function(...) local a = {}; for i,v in next, table.pack(...) do a[i] = math.round(v); end return unpack(a); end;
local wtvp = function(...) local a, b = camera.WorldToViewportPoint(camera, ...) return newVector2(a.X, a.Y), b, a.Z end;

local espCache = {};

local function loadESP(player)
    local drawings = {};
   
    drawings.box = newDrawing("Square");
    drawings.box.Thickness = 1;
    drawings.box.Filled = false;
    drawings.box.Color = getgenv().espSettings.Box.Color;
    drawings.box.Visible = false;
    drawings.box.ZIndex = 2;
 
    drawings.boxoutline = newDrawing("Square");
    drawings.boxoutline.Thickness = 3;
    drawings.boxoutline.Filled = false;
    drawings.boxoutline.Color = newColor3();
    drawings.boxoutline.Visible = false;
    drawings.boxoutline.ZIndex = 1;
 
    espCache[player] = drawings;
end

local function updateEsp(player, esp)
    local character = player and player.Character;
    if character then
        local cframe = character:GetModelCFrame();
        local position, visible, depth = wtvp(cframe.Position);
        if getgenv().espSettings.Box.Enabled == true then
            esp.box.Visible = visible;
            esp.boxoutline.Visible = visible;
        else
            esp.box.Visible = false;
            esp.boxoutline.Visible = false;
        end
 
        if cframe and visible then
            local scaleFactor = 1 / (depth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000;
            local width, height = round(4 * scaleFactor, 5 * scaleFactor);
            local x, y = round(position.X, position.Y);
 
            esp.box.Size = newVector2(width, height);
            esp.box.Position = newVector2(round(x - width / 2, y - height / 2));
            esp.box.Color = getgenv().espSettings.Box.Color;
 
            esp.boxoutline.Size = esp.box.Size;
            esp.boxoutline.Position = esp.box.Position;
        end
    else
        esp.box.Visible = false;
        esp.boxoutline.Visible = false;
    end
 end

for _, player in pairs(game:GetService("Players"):GetChildren()) do
    loadESP(player)
end
local Success, Errored = pcall(function()
    CreateTracers()
end)

game.Players.PlayerAdded:Connect(function(player)
    loadESP(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if rawget(espCache, player) then
        for _, drawing in next, espCache[player] do
            drawing:Remove();
        end
        espCache[player] = nil;
    end
end)

runService:BindToRenderStep("esp", Enum.RenderPriority.Camera.Value, function()
    for player, drawings in next, espCache do
        if drawings and player ~= localPlayer then
            updateEsp(player, drawings);
        end
    end
 end)
