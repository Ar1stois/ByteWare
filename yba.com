local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NanderezWithZ/ByteWare/build/f.lua"))()
local Wait = library.subs.Wait

local ByteWare = library:CreateWindow({
    Name = "ByteWare",
    Themeable = {
        Info = "Made by the ByteWare team."
    }
})

local AimTab = ByteWare:CreateTab({
    Name = "Aimlock"
})

local AntiAimTab = ByteWare:CreateTab({
    Name = "Antiaim"
})

local MovementTab = ByteWare:CreateTab({
    Name = "Movement"
})

local VisualsTab = ByteWare:CreateTab({
    Name = "Visuals"
})


local BoxSection = VisualsTab:CreateSection({
    Name = "Box ESP"
})

local TracersSection = VisualsTab:CreateSection({
    Name = "Tracers"
})

BoxSection:AddToggle({
    Name = "Box",
    Flag = "Visuals_Esp_Box_Enabled",
    Callback = function(bool)
        getgenv().espSettings.Box.Enabled = bool
    end
})

TracersSection:AddToggle({
    Name = "Tracers",
    Flag = "Visuals_Esp_Tracers_Enabled",
    Callback = function(bool)
        getgenv().espSettings.Tracers.Enabled = bool
    end
})

TracersSection:AddSlider({
    Name = "Thickness",
    Flag = "Visuals_Esp_Tracers_Thickness",
    Value = 1,
    Min = 1,
    Max = 5,
    Textbox = true,
    Callback = function(Value)
        getgenv().espSettings.Tracers.Thickness = Value
    end
})

TracersSection:AddSlider({
    Name = "Transparency",
    Flag = "Visuals_Esp_Tracers_Transparency",
    Value = 0.5,
    Min = 0,
    Max = 1,
    Textbox = true,
    Callback = function(Value)
        getgenv().espSettings.Tracers.Transparency = Value
    end
})

TracersSection:AddColorpicker({
    Name = "Color",
    Value = Color3.fromRGB(179, 0, 255), --"rainbow" or "random",
    Callback = function(NewValue, LastValue)
        getgenv().espSettings.Tracers.Color = NewValue
    end,
    Flag = "Visuals_Esp_Color"
})

BoxSection:AddColorpicker({
    Name = "Color",
    Value = Color3.fromRGB(179, 0, 255), --"rainbow" or "random",
    Callback = function(NewValue, LastValue)
        getgenv().espSettings.Box.Color = NewValue
    end,
    Flag = "Visuals_Esp_Color"
})

local AimlockSection = AimTab:CreateSection({
    Name = "Aimlock"
})

AimlockSection:AddToggle({
    Name = "Enabled",
    Flag = "Aim_Aimlock_Enabled",
    Callback = function(bool)
        getgenv().DaHoodSettings.CanToggle = bool
    end
})

AimlockSection:AddSlider({
    Name = "FOV",
    Flag = "Aim_Aimlock_FOV",
    Value = 30,
    Min = 10,
    Max = 300,
    Textbox = true,
    Callback = function(Value)
        getgenv().Aiming.FOV = Value
    end
})

AimlockSection:AddToggle({
    Name = "SilentAim",
    Flag = "Aim_Aimlock_Silent",
    Callback = function(bool)
        getgenv().DaHoodSettings.SilentAim = bool
        getgenv().DaHoodSettings.AimLock = not getgenv().DaHoodSettings.SilentAim
    end
})

AimlockSection:AddToggle({
    Name = "Resolver",
    Flag = "Aim_Aimlock_Resolver",
    Callback = function(bool)
        getgenv().DaHoodSettings.Resolver = bool
    end
})

AimlockSection:AddToggle({
    Name = "State",
    Keybind = {
        Mode = "Dynamic" -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
    },
    Callback = function(bool)
        getgenv().DaHoodSettings.Enabled = bool
    end
})

AimlockSection:AddSlider({
    Name = "Prediction",
    Flag = "Aim_Aimlock_Prediction",
    Value = 0.1,
    Min = 0.1,
    Max = 1,
    Textbox = true,
    Callback = function(Value)
        getgenv().DaHoodSettings.Prediction = Value
    end
})

local LagSection = AntiAimTab:CreateSection({
    Name = "Ping Spoof"
})

local fakeLagSettings = {
    ['CurrentMode'] = "ReplicationLag",
    ['Enabled'] = false,
    ['Delay'] = 0.1,
    ['Modes'] = {
        ['ReplicationLag'] = {
            ['Delay'] = 0.2
        }
    }
}

local fakeLagModes = {}

for name, Settings in pairs(fakeLagSettings.Modes) do
    table.insert(fakeLagModes, name)
end

local FakeLagEnabled

local FakeLagModeSelection = LagSection:AddDropdown({
    Name = "Ping Spoof Mode",
    Value = fakeLagModes[1] or "Nil",
    Callback = function(NewValue, LastValue)
        fakeLagSettings['Enabled'] = false
        fakeLagSettings['CurrentMode'] = NewValue
        FakeLagEnabled:Set(false)
    end,
    List = fakeLagModes,
    Flag = "AntiAim_FakeLag_Mode"
})

FakeLagEnabled = LagSection:AddToggle({
    Name = "Enabled",
    Keybind = {
        Mode = "Dynamic"
    },
    Callback = function(bool)
        fakeLagSettings['Enabled'] = bool
    end,
    Flag = "AntiAim_FakeLag_Enabled"
})

LagSection:AddSlider({
    Name = "Delay",
    Flag = "AntiAim_FakeLag_Delay",
    Value = 0.1,
    Min = 0.01,
    Max = 3,
    Textbox = true,
    Callback = function(Value)
        fakeLagSettings.Delay = Value
    end
})

local Yaw = {
    ['Mode'] = "None",
    ['Direction'] = "None"
}

local YawSection = AntiAimTab:CreateSection({
    Name = "Yaw"
})
getgenv().FakeCrouch = false


YawSection:AddDropdown({
    Name = "Yaw Mode",
    Value = "None",
    Callback = function(NewValue, LastValue)
        Yaw.Mode = NewValue
        if Yaw.Mode == "Down" then
            getgenv().FakeCrouch = true

            local Humanoid = game.Players.LocalPlayer.Character.Humanoid
            local Animation = Instance.new("Animation")
            Animation.AnimationId = "rbxassetid://12175776782"
            
            local LoadAnim = Humanoid:LoadAnimation(Animation)
            while true do
                if getgenv().FakeCrouch == false then
                   LoadAnim:Stop()
                   break
                else
                    LoadAnim:Play()
                end
               wait(0.05) 
            end
        else
            getgenv().FakeCrouch = false
        end
    end,
    List = {"Down", "None"},
    Flag = "AntiAim_Yaw_Mode"
})

YawSection:AddDropdown({
    Name = "Direction Mode",
    Value = "None",
    Callback = function(NewValue, LastValue)
        Yaw.Direction = NewValue
        if Yaw.Direction == "Spin" then
            local Spin = Instance.new("BodyAngularVelocity")
            Spin.Name = "Spinning"
            Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
            Spin.MaxTorque = Vector3.new(0, math.huge, 0)
            Spin.AngularVelocity = Vector3.new(0,20,0) 
        else
            if game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Spinning") then
                game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Spinning"):Destroy()
            end
        end
    end,
    List = {"Spin", "None"},
    Flag = "AntiAim_Yaw_Mode"
})

local JumpCooldown = true

local PlayerSection = MovementTab:CreateSection({
    Name = "Tracers"
})

PlayerSection:AddToggle({
    Name = "Jump Cooldown",
    Value = true,
    Callback = function(bool)
        JumpCooldown = bool
    end,
    Flag = "AntiAim_FakeLag_Enabled"
})

-- // Inject ByteWare ESP Into Process
loadstring(game:HttpGet('https://raw.githubusercontent.com/NanderezWithZ/ByteWare/build/drawingLibrary.lua'))()

-- // Inject Aiming Utilities
loadstring(game:HttpGet('https://raw.githubusercontent.com/NanderezWithZ/ByteWare/build/cameraLibrary.lua'))()

local IsA = game.IsA;
local newindex = nil

newindex = hookmetamethod(game, "__newindex", function(self, Index, Value)
   if not checkcaller() and IsA(self, "Humanoid") and Index == "JumpPower" and JumpCooldown == false then
       return
   end
   
   return newindex(self, Index, Value);
end)

while true do

    if (fakeLagSettings.Enabled == true) then
        local ReplicationLag = settings():GetService("NetworkSettings").IncomingReplicationLag
        settings():GetService("NetworkSettings").IncomingReplicationLag = math.huge
        wait(fakeLagSettings.Delay)
        settings():GetService("NetworkSettings").IncomingReplicationLag = 0
    end

    wait()
end

--[[local GeneralTab = ByteWare:CreateTab({
Name = "General"
})
local FarmingSection = GeneralTab:CreateSection({
Name = "Farming"
})
FarmingSection:AddToggle({
Name = "EXP Grinder",
Flag = "FarmingSection_EXPGrinder"
})
FarmingSection:AddToggle({
Name = "Trick Spammer",
Flag = "FarmingSection_TrickSpammer",
Keybind = 1,
Callback = print
})
FarmingSection:AddSlider({
Name = "Trick Rate",
Flag = "FarmingSection_TrickRate",
Value = 0.15,
Precise = 2,
Min = 0,
Max = 1
})
FarmingSection:AddToggle({
Name = "TP To Coins",
Flag = "FarmingSection_TPCoins"
})
FarmingSection:AddToggle({
Name = "Collect Coins",
Flag = "FarmingSection_CollectCoins",
Callback = print
})
FarmingSection:AddSlider({
Name = "Coin Distance",
Flag = "FarmingSection_CoinDistance",
Value = 175,
Min = 0,
Max = 200,
Format = function(Value)
if Value == 0 then
return "Collection Distance: Infinite"
else
return "Collection Distance: " .. tostring(Value)
end
end
})

local BoardControlSection = GeneralTab:CreateSection({
Name = "Board Control"
})
BoardControlSection:AddToggle({
Name = "Anti Trip/Ragdoll",
Flag = "BoardControlSection_AntiTripRagdoll",
Callback = print
})
BoardControlSection:AddToggle({
Name = "No Wear & Tear",
Flag = "BoardControlSection_NoWearTear"
})
BoardControlSection:AddToggle({
Name = "No Trick Cooldown",
Flag = "BoardControlSection_NoTrickCooldown",
Callback = print
})
BoardControlSection:AddToggle({
Name = "Extend Combo Timout",
Flag = "BoardControlSection_ExtendComboTimeout"
})
BoardControlSection:AddSlider({
Name = "Timeout Extension",
Flag = "BoardControlSection_CoinDistance",
Value = 3,
Min = 0,
Max = 20,
Format = function(Value)
if Value == 0 then
return "Combo Timeout: Never"
else
return "Combo Timeout: " .. tostring(Value) .. "s"
end
end
})

local MiscSection = GeneralTab:CreateSection({
Name = "Misc",
Side = "Right"
})
MiscSection:AddToggle({
Name = "Unlock Gamepasses",
Flag = "MiscSection_UnlockGamepasses",
Callback = print
})
MiscSection:AddToggle({
Name = "Auto Compete",
Flag = "MiscSection_AutoCompete",
Callback = print
})
MiscSection:AddButton({
Name = "Repair Board",
Callback = function()
print("Fixed")
end
})
MiscSection:AddKeybind({
Name = "Test Key",
Callback = print
})
MiscSection:AddToggle({
Name = "Test Toggle/Key",
Keybind = {
Mode = "Dynamic" -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
},
Callback = print
})

local FunSection = GeneralTab:CreateSection({
Name = "Fun Cosmetics"
})
FunSection:AddToggle({
Name = "Ragdoll Assumes Flight",
Flag = "FunSection_AssumesFlight"
})
FunSection:AddToggle({
Name = "Ragdoll On Player Collision",
Flag = "FunSection_RagdollOnPlayerCollision"
})
FunSection:AddToggle({
Name = "Un-Ragdoll When Motionless",
Flag = "FunSection_UnRagdollWhenMotionless"
})
FunSection:AddToggle({
Name = "Extend Ragdoll Duration",
Flag = "FunSection_ExtendRagdollDuration"
})
FunSection:AddSlider({
Name = "Coin Distance",
Flag = "FarmingSection_Coin Distance",
Value = 4,
Min = 0,
Max = 60,
Textbox = true,
Format = function(Value)
if Value == 0 then
return "Ragdoll Extension: Indefinite"
else
return "Ragdoll Extension: " .. tostring(Value) .. "s"
end
end
})]]
