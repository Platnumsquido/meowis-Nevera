local engine = loadstring(game:HttpGet("https://raw.githubusercontent.com/Singularity5490/rbimgui-2/main/rbimgui-2.lua"))()

local window1 = engine.new({
    text = "GoldWARE - ChaffyScarab#8677",
    size = UDim2.new(300, 200),
})

window1.open()

local tab1 = window1.new({
    text = "Made by: ChaffyScarab#8677",
})

local label1 = tab1.new("label", {
    text = "Make sure to bypass before using.",
    color = Color3.new(1, 0, 0),
})

local button1 = tab1.new("button", {
    text = "Bypass Anticheat",
})
button1.event:Connect(function()
    oldNameCall = hookmetamethod(game,"__namecall",function(self,...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() and getcallingscript().Name == "LocalClean" then
        return {}
    end
    if method == "FireServer" and self.Name == "RequestPlayerKick" then
        return {}
    end
    return oldNameCall(self,...)
end)
local Player = game.Players.LocalPlayer
while wait() do
    if Player.Character and Player.Character:FindFirstChild("CharacterControl") then
        Player.Character:FindFirstChild("CharacterControl").Disabled = true
    end
end
end)

local label1 = tab1.new("label", {
    text = "Main features:",
    color = Color3.new(1, 0, 0),
})

local button1 = tab1.new("button", {
    text = "FULL AUTO WEAPONS",
})
button1.event:Connect(function()
    --[[
    Rifthook Minigun
    Some things to note:
    Due to the patching of deathstare/killall with weapons that fire bullets, this minigun script only does damage every ~5 seconds.
]]
local MinigunAuto = false
local Mouse = game.Players.LocalPlayer:GetMouse()
Mouse.Button1Down:Connect(function()
    MinigunAuto = true
end)

Mouse.Button1Up:Connect(function()
    MinigunAuto = false
end)
while wait() do
    if MinigunAuto then 
        pcall(function()
            FirearmHandler = getsenv(game:GetService("Players").LocalPlayer.Character.FirearmHandler)
            debug.setupvalue(FirearmHandler.BulletFire, 1, true)
            FirearmHandler.PlayAnimation("PresentReady", "PresentFire")
            FirearmHandler.BulletFire()
        end)
    end
end
end)

local button1 = tab1.new("button", {
    text = "Aim/Shoot while walking + Fast reload",
})
button1.event:Connect(function()
    loadstring(game:HttpGet("https://pastebin.com/raw/KJjfKDN4"))()
end)

local button1 = tab1.new("button", {
    text = "Chaffy's Aimbot",
})
button1.event:Connect(function()
    --// Preventing Multiple Processes

pcall(function()
	getgenv().Aimbot.Functions:Exit()
end)

--// Environment

getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera

--// Variables

local LocalPlayer = Players.LocalPlayer
local Title = "GoldWARE"
local FileNames = {"Aimbot", "Configuration.json", "Drawing.json"}
local Typing, Running, Animation, RequiredDistance, ServiceConnections = false, false, nil, 2000, {}

--// Support Functions

local mousemoverel = mousemoverel or (Input and Input.MouseMove)
local queueonteleport = queue_on_teleport or syn.queue_on_teleport

--// Script Settings

Environment.Settings = {
	SendNotifications = true,
	SaveSettings = true, -- Re-execute upon changing
	ReloadOnTeleport = true,
	Enabled = true,
	TeamCheck = false,
	AliveCheck = true,
	WallCheck = false, -- Laggy
	Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
	ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
	ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
	TriggerKey = "MouseButton2",
	Toggle = false,
	LockPart = "Head" -- Body part to lock on
}

Environment.FOVSettings = {
	Enabled = true,
	Visible = true,
	Amount = 90,
	Color = "255, 255, 255",
	LockedColor = "255, 70, 70",
	Transparency = 0.5,
	Sides = 60,
	Thickness = 1,
	Filled = false
}

Environment.FOVCircle = Drawing.new("Circle")
Environment.Locked = nil

--// Core Functions

local function Encode(Table)
	if Table and type(Table) == "table" then
		local EncodedTable = HttpService:JSONEncode(Table)

		return EncodedTable
	end
end

local function Decode(String)
	if String and type(String) == "string" then
		local DecodedTable = HttpService:JSONDecode(String)

		return DecodedTable
	end
end

local function GetColor(Color)
	local R = tonumber(string.match(Color, "([%d]+)[%s]*,[%s]*[%d]+[%s]*,[%s]*[%d]+"))
	local G = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*([%d]+)[%s]*,[%s]*[%d]+"))
	local B = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*[%d]+[%s]*,[%s]*([%d]+)"))

	return Color3.fromRGB(R, G, B)
end

local function SendNotification(TitleArg, DescriptionArg, DurationArg)
	if Environment.Settings.SendNotifications then
		StarterGui:SetCore("SendNotification", {
			Title = TitleArg,
			Text = DescriptionArg,
			Duration = DurationArg
		})
	end
end

--// Functions

local function SaveSettings()
	if Environment.Settings.SaveSettings then
		if isfile(Title.."/"..FileNames[1].."/"..FileNames[2]) then
			writefile(Title.."/"..FileNames[1].."/"..FileNames[2], Encode(Environment.Settings))
		end

		if isfile(Title.."/"..FileNames[1].."/"..FileNames[3]) then
			writefile(Title.."/"..FileNames[1].."/"..FileNames[3], Encode(Environment.FOVSettings))
		end
	end
end

local function GetClosestPlayer()
	if not Environment.Locked then
		if Environment.FOVSettings.Enabled then
			RequiredDistance = Environment.FOVSettings.Amount
		else
			RequiredDistance = 2000
		end

		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer then
				if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
					if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
					if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
					if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end

					local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
					local Distance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude

					if Distance < RequiredDistance and OnScreen then
						RequiredDistance = Distance
						Environment.Locked = v
					end
				end
			end
		end
	elseif (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
		Environment.Locked = nil
		Animation:Cancel()
		Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
	end
end

--// Typing Check

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Create, Save & Load Settings

if Environment.Settings.SaveSettings then
	if not isfolder(Title) then
		makefolder(Title)
	end

	if not isfolder(Title.."/"..FileNames[1]) then
		makefolder(Title.."/"..FileNames[1])
	end

	if not isfile(Title.."/"..FileNames[1].."/"..FileNames[2]) then
		writefile(Title.."/"..FileNames[1].."/"..FileNames[2], Encode(Environment.Settings))
	else
		Environment.Settings = Decode(readfile(Title.."/"..FileNames[1].."/"..FileNames[2]))
	end

	if not isfile(Title.."/"..FileNames[1].."/"..FileNames[3]) then
		writefile(Title.."/"..FileNames[1].."/"..FileNames[3], Encode(Environment.FOVSettings))
	else
		Environment.Visuals = Decode(readfile(Title.."/"..FileNames[1].."/"..FileNames[3]))
	end

	coroutine.wrap(function()
		while wait(10) and Environment.Settings.SaveSettings do
			SaveSettings()
		end
	end)()
else
	if isfolder(Title) then
		delfolder(Title)
	end
end

local function Load()
	ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
		if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
			Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
			Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
			Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
			Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
			Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
			Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
			Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
			Environment.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		else
			Environment.FOVCircle.Visible = false
		end

		if Running and Environment.Settings.Enabled then
			GetClosestPlayer()

			if Environment.Settings.ThirdPerson then
				Environment.Settings.ThirdPersonSensitivity = math.clamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)

				local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
				mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
			else
				if Environment.Settings.Sensitivity > 0 then
					Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
					Animation:Play()
				else
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
				end
			end

			Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.LockedColor)
		end
	end)

	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
					if Environment.Settings.Toggle then
						Running = not Running

						if not Running then
							Environment.Locked = nil
							Animation:Cancel()
							Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
						end
					else
						Running = true
					end
				end
			end)

			pcall(function()
				if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
					if Environment.Settings.Toggle then
						Running = not Running

						if not Running then
							Environment.Locked = nil
							Animation:Cancel()
							Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
						end
					else
						Running = true
					end
				end
			end)
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
					if not Environment.Settings.Toggle then
						Running = false
						Environment.Locked = nil
						Animation:Cancel()
						Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
					end
				end
			end)

			pcall(function()
				if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
					if not Environment.Settings.Toggle then
						Running = false
						Environment.Locked = nil
						Animation:Cancel()
						Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
					end
				end
			end)
		end
	end)
end

--// Functions

Environment.Functions = {}

function Environment.Functions:Exit()
	SaveSettings()

	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end

	getgenv().Aimbot.Functions = nil
	getgenv().Aimbot = nil
end

function Environment.Functions:Restart()
	SaveSettings()

	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	Load()
end

function Environment.Functions:ResetSettings()
	Environment.Settings = {
		SendNotifications = true,
		SaveSettings = true, -- Re-execute upon changing
		ReloadOnTeleport = true,
		Enabled = true,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		ThirdPerson = false,
		ThirdPersonSensitivity = 3,
		TriggerKey = "MouseButton2",
		Toggle = false,
		LockPart = "Head" -- Body part to lock on
	}

	Environment.FOVSettings = {
		Enabled = true,
		Visible = true,
		Amount = 90,
		Color = "255, 255, 255",
		LockedColor = "255, 70, 70",
		Transparency = 0.5,
		Sides = 60,
		Thickness = 1,
		Filled = false
	}
end

--// Support Check

if not Drawing or not getgenv then
	SendNotification(Title, "Your exploit does not support this script", 3); return
end

--// Reload On Teleport

if Environment.Settings.ReloadOnTeleport then
	if queueonteleport then
		queueonteleport(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V2/main/Resources/Scripts/Main.lua"))
	else
		SendNotification(Title, "Your exploit does not support \"syn.queue_on_teleport()\"")
	end
end

--// Load

Load(); SendNotification(Title, "Aimbot script successfully loaded! -ChaffyScarab#8677.", 5)
end)

local button1 = tab1.new("button", {
    text = "Chaffy's ESP/Chams",
})
button1.event:Connect(function()
    local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local colorIndex = 1
local colors = {
    Color3.new(1, 0, 0),
    Color3.new(1, 1, 0),
    Color3.new(0, 1, 0),
    Color3.new(0, 1, 1),
    Color3.new(0, 0, 1),
    Color3.new(1, 0, 1)
}

function TweenColor(obj, prop, toColor, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(obj, tweenInfo, {[prop] = toColor})
    tween:Play()
end

function ApplyColors()
    local nextColorIndex = colorIndex + 1
    if nextColorIndex > #colors then
        nextColorIndex = 1
    end

    local nextColor = colors[nextColorIndex]

    for i, v in pairs(Players:GetPlayers()) do
        local esp = v.Character:FindFirstChildOfClass("Highlight")
        if not esp then
            esp = Instance.new("Highlight")
            esp.Name = v.Name
            esp.FillTransparency = 0
            esp.OutlineColor = Color3.new(1, 0.333333, 1)
            esp.OutlineTransparency = 0
            esp.Parent = v.Character
        end

        local currentColor = esp.FillColor

        local tweenDuration = 0.5
        TweenColor(esp, "FillColor", nextColor, tweenDuration)
    end

    colorIndex = nextColorIndex
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- wait for character to load
        ApplyColors()
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    local esp = player.Character:FindFirstChildOfClass("Highlight")
    if esp then
        esp:Destroy()
    end
end)

while true do
    ApplyColors()
    wait(0.5)
end

end)

local button1 = tab1.new("button", {
    text = "Head Hitbox Expander (OP)",
})
button1.event:Connect(function()
    --Made by mis#0123 / rewaved @ v3rmillion.net

local toggle = false
local UIS = game:GetService("UserInputService")
local Size = Vector3.new(5,5,5) --Change 2,2,2 to desired head size. Numbers represent (x,y,z).
local Key = "C" --Change C to the desired key.
local function Notify(...)
    game.StarterGui:SetCore('SendNotification',...)
end


UIS.InputBegan:Connect(function(k)
if k.KeyCode == Enum.KeyCode[Key] then
    toggle = not toggle
    for k,v in next, game:GetService('Players'):GetPlayers() do
    if v.Character:FindFirstChild('Head') then
        local Head = v.Character:FindFirstChild('Head')
        Head.Size = Vector3.new(2,1,1)
        Head.Size = Size
        game.Players.LocalPlayer.Character.Head.Size = Vector3.new(2,1,1)
    if toggle then
        Head.Size = Vector3.new(2,1,1)
end
    end        
    end
end    
end)

Notify({Title="GoldWARE's Hitbox Expander Loaded";Text="Welcome "..game.Players.LocalPlayer.Name})
end)


local label1 = tab1.new("label", {
    text = "Movement Features:",
    color = Color3.new(1, 0, 0),
})

local button1 = tab1.new("button", {
    text = "Fly (after press use E to toggle)",
})
button1.event:Connect(function()
    repeat wait() 
	until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:findFirstChild("Humanoid") 
local mouse = game.Players.LocalPlayer:GetMouse() 
repeat wait() until mouse
local plr = game.Players.LocalPlayer 
local torso = plr.Character.HumanoidRootPart 
local flying = true
local deb = true 
local ctrl = {f = 0, b = 0, l = 0, r = 0} 
local lastctrl = {f = 0, b = 0, l = 0, r = 0} 
local maxspeed = 50 
local speed = 0 

function Fly() 
local bg = Instance.new("BodyGyro", torso) 
bg.P = 9e4 
bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
bg.cframe = torso.CFrame 
local bv = Instance.new("BodyVelocity", torso) 
bv.velocity = Vector3.new(0,0.1,0) 
bv.maxForce = Vector3.new(9e9, 9e9, 9e9) 
repeat wait() 
plr.Character.Humanoid.PlatformStand = true 
if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then 
speed = speed+.5+(speed/maxspeed) 
if speed > maxspeed then 
speed = maxspeed 
end 
elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then 
speed = speed-1 
if speed < 0 then 
speed = 0 
end 
end 
if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then 
bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed 
lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r} 
elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then 
bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed 
else 
bv.velocity = Vector3.new(0,0.1,0) 
end 
bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0) 
until not flying 
ctrl = {f = 0, b = 0, l = 0, r = 0} 
lastctrl = {f = 0, b = 0, l = 0, r = 0} 
speed = 0 
bg:Destroy() 
bv:Destroy() 
plr.Character.Humanoid.PlatformStand = false 
end 
mouse.KeyDown:connect(function(key) 
if key:lower() == "e" then 
if flying then flying = false 
else 
flying = true 
Fly() 
end 
elseif key:lower() == "w" then 
ctrl.f = 1 
elseif key:lower() == "s" then 
ctrl.b = -1 
elseif key:lower() == "a" then 
ctrl.l = -1 
elseif key:lower() == "d" then 
ctrl.r = 1 
end 
end) 
mouse.KeyUp:connect(function(key) 
if key:lower() == "w" then 
ctrl.f = 0 
elseif key:lower() == "s" then 
ctrl.b = 0 
elseif key:lower() == "a" then 
ctrl.l = 0 
elseif key:lower() == "d" then 
ctrl.r = 0 
end 
end)
Fly()
end)

local button1 = tab1.new("button", {
    text = "Fast Walk (speed)",
})
button1.event:Connect(function()
    -- This walkspeed script is the same as others , but does not change to default speed when you reset. ENJOY !    
_G.HackedWalkSpeed = 35

local Plrs = game:GetService("Players")

local MyPlr = Plrs.LocalPlayer
local MyChar = MyPlr.Character

if MyChar then
local Hum = MyChar.Humanoid
Hum.Changed:connect(function()
Hum.WalkSpeed = _G.HackedWalkSpeed
end)
Hum.WalkSpeed = _G.HackedWalkSpeed
end


MyPlr.CharacterAdded:connect(function(Char)
MyChar = Char
repeat wait() until Char:FindFirstChild("Humanoid")
local Hum = Char.Humanoid
Hum.Changed:connect(function()
Hum.WalkSpeed = _G.HackedWalkSpeed
end)
Hum.WalkSpeed = _G.HackedWalkSpeed
end)

-- end of script :)
end)

local button1 = tab1.new("button", {
    text = "Spinbot & Bhop",
})
button1.event:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Platnumsquido/spino/main/spin.lua"))()
end)

local button1 = tab1.new("button", {
    text = "Inf. Jump",
})
button1.event:Connect(function()
    local infjmp = true
game:GetService("UserInputService").jumpRequest:Connect(function()
    if infjmp then
        game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass"Humanoid":ChangeState("Jumping")
    end
end)

end)


folder1.open()