-- !! NEEDS TO BE PLACED IN ServerScriptService > AbilitySystem (create this folder)

local RS = game:GetService("ReplicatedStorage")
local Remote = RS:WaitForChild("AbilitySystem"):WaitForChild("AbilityRemote")
local Players = game:GetService("Players")
---
local DefaultWalkSpeed = 16
---
local AbilityDetails = {
	["Cloud Sprint"] = {
		Duration = 5;
		Cooldown = 1; -- 5
		Buff = 16; -- WalkSpeed
	};
	["Spirit Walker"] = {
		Duration = 0.8;
		Cooldown = 1; -- 5
		Buff = 160; -- WalkSpeed
	};
	["Regenerate"] = {
		Duration = 3; -- Number of Increments * 2
		Cooldown = 1; -- 5
		Buff = 5; -- Heal Increment
	};
	["Fast Dash"] = {
		Duration = 0.2; -- Expected Dash Duration
		Cooldown = 0.75; -- 3
		Buff = 20; -- Amount applied to LookVector
	};
	["< empty >"] = {
		Duration = 0; -- Number of Increments * 2
		Cooldown = 0.2; -- 5
		Buff = 0;
	};
}
---
local Template = {
	PlayerName1 = {"Ability1", "Ability2", "Ability3", "Ability4"}
}
---
local PlayersCooldown = {} 	-- True if on cooldown, False if not
local PlayersActive = {} 		-- True if ability currently in use, False if not
---
Players.PlayerAdded:Connect(function(player)
	if not PlayersCooldown[player.Name] then
		PlayersCooldown[player.Name] = {false, false, false, false}
	end
	if not PlayersActive[player.Name] then
		PlayersActive[player.Name] = {false, false, false, false}
	end
end)
Players.PlayerRemoving:Connect(function(player)
	if not PlayersCooldown[player.Name] then
		PlayersCooldown[player.Name] = nil
	end
	if not PlayersActive[player.Name] then
		PlayersActive[player.Name] = nil
	end
end)

--- ****************************************************************************** Ability Functions Start  ******************************************************************************

local function CloudSprint(Player, Action, Ability_Number)
	
	local Char = Player.Character
	local Hum = Char:WaitForChild("Humanoid")
	
	if PlayersCooldown[Player.Name][Ability_Number] == false and PlayersActive[Player.Name][Ability_Number] == false then

		if Hum then
			PlayersActive[Player.Name][Ability_Number] = true
			Remote:FireClient(Player, "Active", Ability_Number)
			Remote:FireAllClients("Afterimage", AbilityDetails[Action]["Duration"], Player)

			delay(AbilityDetails[Action]["Duration"], function()
				Remote:FireClient(Player, "Inactive", Ability_Number)
				Hum.WalkSpeed = DefaultWalkSpeed
				PlayersActive[Player.Name][Ability_Number] = false
				PlayersCooldown[Player.Name][Ability_Number] = true

				delay(AbilityDetails[Action]["Cooldown"], function()
					Remote:FireClient(Player, "Ready", Ability_Number)
					PlayersCooldown[Player.Name][Ability_Number] = false
				end)
			end)
			
			-- Guarantees WalkSpeed is maintained throughout ability. Limits slow/stun implementations.
			while PlayersActive[Player.Name][Ability_Number] do
				Hum.WalkSpeed = DefaultWalkSpeed + AbilityDetails[Action]["Buff"]
				task.wait(1)
			end
		end
	end
end
local function SpiritWalker(Player, Action, Ability_Number)

	local Char = Player.Character
	local Hum = Char:WaitForChild("Humanoid")

	if PlayersCooldown[Player.Name][Ability_Number] == false and PlayersActive[Player.Name][Ability_Number] == false then

		if Hum then
			PlayersActive[Player.Name][Ability_Number] = true
			Remote:FireClient(Player, "Active", Ability_Number)
			Remote:FireAllClients("SpiritWalker", AbilityDetails[Action]["Duration"], Player)

			delay(AbilityDetails[Action]["Duration"], function()
				Remote:FireClient(Player, "Inactive", Ability_Number)
				Hum.WalkSpeed = DefaultWalkSpeed
				PlayersActive[Player.Name][Ability_Number] = false
				PlayersCooldown[Player.Name][Ability_Number] = true

				delay(AbilityDetails[Action]["Cooldown"], function()
					Remote:FireClient(Player, "Ready", Ability_Number)
					PlayersCooldown[Player.Name][Ability_Number] = false
				end)
			end)
			
			-- Guarantees WalkSpeed is maintained throughout ability. Limits slow/stun implementations.
			while PlayersActive[Player.Name][Ability_Number] do
				Hum.WalkSpeed = DefaultWalkSpeed + AbilityDetails[Action]["Buff"]
				task.wait(0.1)
			end
		end
	end
end
local function Regenerate(Player, Action, Ability_Number)
	
	local Char = Player.Character
	local Hum = Char:WaitForChild("Humanoid")
	
	local FX = script:WaitForChild("FX")
	
	local Healing = true
	
	if PlayersCooldown[Player.Name][Ability_Number] == false and PlayersActive[Player.Name][Ability_Number] == false then

		if Hum then
			PlayersActive[Player.Name][Ability_Number] = true
			Remote:FireClient(Player, "Active", Ability_Number)

			delay(AbilityDetails[Action]["Duration"], function()
				Remote:FireClient(Player, "Inactive", Ability_Number)
				Hum.WalkSpeed = DefaultWalkSpeed
				PlayersActive[Player.Name][Ability_Number] = false
				PlayersCooldown[Player.Name][Ability_Number] = true

				delay(AbilityDetails[Action]["Cooldown"], function()
					Remote:FireClient(Player, "Ready", Ability_Number)
					PlayersCooldown[Player.Name][Ability_Number] = false
				end)
			end)
			
			local HealParticles = FX.RisingLines:Clone()
			local Torso = Char:WaitForChild("Torso")
			local Weld = Instance.new("Weld")
			HealParticles.Parent = Torso
			Weld.Parent = HealParticles
			Weld.Part0 = HealParticles
			Weld.Part1 = Torso
			game.Debris:AddItem(HealParticles,AbilityDetails[Action]["Duration"])
			
			-- Guarantees WalkSpeed is maintained throughout ability. Limits slow/stun implementations.
			while PlayersActive[Player.Name][Ability_Number] do
				if Hum.Health < Hum.MaxHealth then
					Hum:TakeDamage(0 - AbilityDetails[Action]["Buff"])
				end
				-- Reduces overflow if Health value is greater than MaxHealth value
				if Hum.Health > Hum.MaxHealth then
					Hum.Health = Hum.MaxHealth
				end
				warn("Regenerate - Healed")
				wait(0.25)
			end
		end
	end
end
local function FastDash(Player, Action, Ability_Number)
	
	local Char = Player.Character
	local Hum = Char:WaitForChild("Humanoid")
	local HumRP = Char:WaitForChild("HumanoidRootPart")
	
	if PlayersCooldown[Player.Name][Ability_Number] == false and PlayersActive[Player.Name][Ability_Number] == false then

		if Hum then
			PlayersActive[Player.Name][Ability_Number] = true
			Remote:FireClient(Player, "Active", Ability_Number)
			Remote:FireClient(Player, "FastDash", AbilityDetails[Action]["Buff"], Player, AbilityDetails[Action]["Duration"])
			
			delay(AbilityDetails[Action]["Duration"], function()
				Remote:FireClient(Player, "Inactive", Ability_Number)
				PlayersActive[Player.Name][Ability_Number] = false
				PlayersCooldown[Player.Name][Ability_Number] = true

				delay(AbilityDetails[Action]["Cooldown"], function()
					Remote:FireClient(Player, "Ready", Ability_Number)
					PlayersCooldown[Player.Name][Ability_Number] = false
				end)
			end)
		end
	end
end
local function Empty(Player, Action, Ability_Number)

	local Char = Player.Character
	local Hum = Char:WaitForChild("Humanoid")

	if PlayersCooldown[Player.Name][Ability_Number] == false and PlayersActive[Player.Name][Ability_Number] == false then

		if Hum then
			PlayersActive[Player.Name][Ability_Number] = true
			Remote:FireClient(Player, "Active", Ability_Number)

			delay(AbilityDetails[Action]["Duration"], function()
				Remote:FireClient(Player, "Inactive", Ability_Number)
				Hum.WalkSpeed = DefaultWalkSpeed
				PlayersActive[Player.Name][Ability_Number] = false
				PlayersCooldown[Player.Name][Ability_Number] = true

				delay(AbilityDetails[Action]["Cooldown"], function()
					Remote:FireClient(Player, "Ready", Ability_Number)
					PlayersCooldown[Player.Name][Ability_Number] = false
				end)
			end)
		end
	end
end
--- ****************************************************************************** Ability Functions End ******************************************************************************

Remote.OnServerEvent:Connect(function(Player, Action, Ability_Number)
	local Char = Player.Character
	local Hum = Char:WaitForChild("Humanoid")
	
	if Action == "Cloud Sprint" then
		CloudSprint(Player, Action, Ability_Number)
	elseif Action == "Spirit Walker" then
		SpiritWalker(Player, Action, Ability_Number)
	elseif Action == "Regenerate" then
		Regenerate(Player, Action, Ability_Number)
	elseif Action == "Fast Dash" then
		FastDash(Player, Action, Ability_Number)
	elseif Action == "< empty >" then
		warn("Ability Slot is empty.")
		Empty(Player, Action, Ability_Number)
	elseif Action == "Death" then
		-- Reset Cooldowns
		warn("Server Event - Player Death")
	end

end)
