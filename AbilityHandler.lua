-- !! NEEDS TO BE PLACED IN StarterPlayer > StarterCharacterScripts
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
--
local Remote = RS:WaitForChild("AbilitySystem"):WaitForChild("AbilityRemote")
Remote:FireServer()
--
local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local PlayerGui = Player:WaitForChild("PlayerGui")

while Char.Parent == nil do
	Char.AncestryChanged:wait()
end

local HumRP = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")
--
local DKeyDown = false
local SKeyDown = false
local AKeyDown = false
local WKeyDown = false
local ShiftLocked = false
local CanDoAnything = true
--
local AbilityName = {
	Empty = "< empty >",
	CloudSprint = "Cloud Sprint",
	Regenerate = "Regenerate",
	SpiritWalker = "Spirit Walker",
	PhaseRift = "Phase Rift",
	FastDash = "Fast Dash"
}
--
local CurrAbility = {"", "", "", ""}

-- User Interface
local Ability_1 = PlayerGui.SpellAbilities.Ability.Ability_1
local Ability_2 = PlayerGui.SpellAbilities.Ability.Ability_2
local Ability_3 = PlayerGui.SpellAbilities.Ability.Ability_3
local Ability_4 = PlayerGui.SpellAbilities.Ability.Ability_4

local Button_1 = PlayerGui.SpellAbilities.Ability.Button_1
local Button_2 = PlayerGui.SpellAbilities.Ability.Button_2
local Button_3 = PlayerGui.SpellAbilities.Ability.Button_3
local Button_4 = PlayerGui.SpellAbilities.Ability.Button_4

local AbilityDictionary = {Ability_1, Ability_2, Ability_3, Ability_4}
local ButtonDictionary = {Button_1, Button_2, Button_3, Button_4}

-- Template: AbilityDictionary[#].Text = "[#] " .. "< empty >"
AbilityDictionary[1].Text = "[1] " .. "< empty >"
AbilityDictionary[2].Text = "[2] " .. "< empty >"
AbilityDictionary[3].Text = "[3] " .. "< empty >"
AbilityDictionary[4].Text = "[4] " .. "< empty >"

--
local function UpdateAbility(Ability_Number, Ability_Name) -- Changes Ability Name in PlayerGUI
	CurrAbility[Ability_Number] = Ability_Name
	AbilityDictionary[Ability_Number].Text = "[" .. tostring(Ability_Number) .."] ".. Ability_Name
end
---
local function AbilityActive(Ability_Number) -- Makes background green
	Ability_Number.BackgroundColor3 = Color3.fromRGB(26, 255, 98)
	Ability_Number.BackgroundTransparency = 0.5
end

local function AbilityInactive(Ability_Number) -- Makes background red
	Ability_Number.BackgroundColor3 = Color3.fromRGB(255, 76, 100)
	Ability_Number.BackgroundTransparency = 0.5
end

local function AbilityReady(Ability_Number)	-- Makes background transparent
	Ability_Number.BackgroundTransparency = 1
end
---
local function AfterimageEffect(Player_Input)
	for i,v in pairs(Player_Input.Character:GetChildren()) do
		if (v:IsA('BasePart')) then

			local Shadow = v:Clone()
			Shadow:ClearAllChildren()

			if (v.Name == 'Head') then
				local HeadShape = Instance.new('SpecialMesh')
				HeadShape.MeshType = Enum.MeshType.Head
				HeadShape.Scale = Vector3.new(1.25, 1.25, 1.25)
				HeadShape.Parent = Shadow
			end
			Shadow.CFrame = Player_Input.Character:FindFirstChild(Shadow.Name).CFrame
			Shadow.Color = Color3.fromRGB(154, 113, 235)
			Shadow.Material = "Neon"
			Shadow.CanCollide = false
			Shadow.Anchored = true
			Shadow.Parent = workspace.Wastebin.VFX
			TweenService:Create(Shadow, TweenInfo.new(0.1), {Transparency = 1}):Play()

			game.Debris:AddItem(Shadow, 0.4)
		end
	end
end
local function SpiritWalkerEffect(Player_Input)
	for i,v in pairs(Player_Input.Character:GetChildren()) do
		if (v:IsA('BasePart')) then
			
			local Shadow = v:Clone()
			Shadow:ClearAllChildren()

			if (v.Name == 'Head') then
				local HeadShape = Instance.new('SpecialMesh')
				HeadShape.MeshType = Enum.MeshType.Head
				HeadShape.Scale = Vector3.new(1.25, 1.25, 1.25)
				HeadShape.Parent = Shadow
			end
			Shadow.CFrame = Player_Input.Character:FindFirstChild(Shadow.Name).CFrame
			Shadow.Color = Color3.fromRGB(231, 225, 245)
			Shadow.Material = "Neon"
			Shadow.CanCollide = false
			Shadow.Anchored = true
			Shadow.Parent = workspace.Wastebin.VFX
			TweenService:Create(Shadow, TweenInfo.new(0.1), {Transparency = 1}):Play()

			game.Debris:AddItem(Shadow, 0.3)
		end
	end
end
local function FastDashMovement(Buff, Duration)
	local i = Instance.new("BodyPosition")
	i.MaxForce = Vector3.new(1000000,0,1000000) -- y-component is 0 because we don't want them to fly
	i.P = 100000
	i.D = 2000
	Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	if not ShiftLocked then
		i.Position = (HumRP.CFrame*CFrame.new(0,0,-Buff)).Position -- Dashes forward based on buff amount
	else
		if WKeyDown then
			i.Position = (HumRP.CFrame*CFrame.new(0,0,-Buff)).Position -- Dashes forward based on buff amount
		elseif SKeyDown then
			i.Position = (HumRP.CFrame*CFrame.new(0,0,Buff)).Position -- Dashes backward based on buff amount
		elseif AKeyDown then
			i.Position = (HumRP.CFrame*CFrame.new(-Buff,0,0)).Position -- Dashes leftside based on buff amount
		elseif DKeyDown then
			i.Position = (HumRP.CFrame*CFrame.new(Buff,0,0)).Position -- Dashes rightside based on buff amount
		else
			i.Position = (HumRP.CFrame*CFrame.new(0,0,-Buff)).Position -- Dashes forward based on buff amount
		end
	end

	i.Parent = HumRP
	delay(Duration, function()
		i:Destroy()
		Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
	end)
end
local function ChangeTransparency(Player_Input, Percentage)
	for i,v in pairs(Player_Input.Character:GetChildren()) do
		if (v:IsA('BasePart')) then
			if (Percentage == 0 and v.Name == "HumanoidRootPart") then
				v.Transparency = 100
				continue
			end
			v.Transparency = Percentage
		end
	end
end
--


-----------------------------------------------------------------------------------------------------------
------------------------------------------------ main() ------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-- Template: UpdateAbility(#, AbilityName["Empty"])
UpdateAbility(1, AbilityName["CloudSprint"])
UpdateAbility(2, AbilityName["SpiritWalker"])
UpdateAbility(3, AbilityName["Regenerate"])
UpdateAbility(4, AbilityName["FastDash"])

-- Keyboard Input
UIS.InputBegan:Connect(function(Input,IsTyping)
	if IsTyping then return end

	if CanDoAnything == true then

		if Input.KeyCode == Enum.KeyCode.One then
			-- warn("Pressed One Key")
			Remote:FireServer(CurrAbility[1], 1)

		elseif Input.KeyCode == Enum.KeyCode.Two then
			-- warn("Pressed Two Key")
			Remote:FireServer(CurrAbility[2], 2)
		elseif Input.KeyCode == Enum.KeyCode.Three then
			-- warn("Pressed Three Key")
			Remote:FireServer(CurrAbility[3], 3)
		elseif Input.KeyCode == Enum.KeyCode.Four then
			-- warn("Pressed Four Key")
			Remote:FireServer(CurrAbility[4], 4)
		end

	end	
end)

-- Mobile Tap / Computer Cursor Input
Button_1.MouseButton1Click:Connect(function()
	Remote:FireServer(CurrAbility[1], 1)
end)
Button_2.MouseButton1Click:Connect(function()
	Remote:FireServer(CurrAbility[2], 2)
end)
Button_3.MouseButton1Click:Connect(function()
	Remote:FireServer(CurrAbility[3], 3)
end)
Button_4.MouseButton1Click:Connect(function()
	Remote:FireServer(CurrAbility[4], 4)
end)

-- Firing to Client
Remote.OnClientEvent:Connect(function(Action, Number, Player_Input, Option1, Option2)
	if Action == "Active"  then
		AbilityActive(AbilityDictionary[Number])
	elseif Action == "Inactive" then
		AbilityInactive(AbilityDictionary[Number])
	elseif Action == "Ready" then
		AbilityReady(AbilityDictionary[Number])
	elseif Action == "Afterimage" then
		local AfterimageActive = true
		
		delay(Number, function()
			AfterimageActive = false
		end)
		local connect
		connect = RunService.Heartbeat:Connect(function()
			AfterimageEffect(Player_Input)
			if AfterimageActive == false then
				connect:Disconnect()
			end
		end)
	elseif Action == "FastDash" then
		FastDashMovement(Number, Option1)
	elseif Action == "SpiritWalker" then
		local AfterimageActive = true

		delay(Number, function()
			AfterimageActive = false
			ChangeTransparency(Player_Input, 0)
		end)
		ChangeTransparency(Player_Input, 0.3)
		local connect
		connect = RunService.Heartbeat:Connect(function()
			SpiritWalkerEffect(Player_Input)
			if AfterimageActive == false then
				connect:Disconnect()
			end
		end)
	end
end)

Hum.Died:Connect(function()
	Remote:FireServer("Death")
end)


local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()

	local Player = game.Players.LocalPlayer
	local Char = Player.Character or Player.CharacterAdded:Wait()
	local Hum = Char:FindFirstChild("Humanoid")

	if UIS:IsKeyDown(Enum.KeyCode.W)  then
		WKeyDown = true
	else
		WKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.A)  then
		AKeyDown = true
	else
		AKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.S) then
		SKeyDown = true
	else 
		SKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.D) then
		DKeyDown = true
	else 
		DKeyDown = false
	end
	if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
		ShiftLocked = true
	else
		ShiftLocked = false
	end
end)
