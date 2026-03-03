local CustomReplicationClient = {}

local localPlayer = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Observer = require(ReplicatedStorage.Packages.Observer)

local Snapshots = require(script.Parent.Snapshots)

type CustomReplicationClient = typeof(CustomReplicationClient)

local UPDATE_INTERVAL = 0.025
local ALPHA_LERP = 0.8

function CustomReplicationClient.init(self :CustomReplicationClient)
	
	self.networker = Networker.client.new('CustomReplication',self)
	
	self.lastUpdate = os.clock()
	self.lastCFrame = CFrame.new()
	
	-- init local char
	Observer.observeLocalCharacter(function(character)
		
		local humanoid :Humanoid = character:WaitForChild('Humanoid')
		
		local updateLoop = RunService.Heartbeat:Connect(function()
			
			local HRP :BasePart = character:FindFirstChild('HumanoidRootPart')

			if not HRP then return end

			if os.clock() - self.lastUpdate >= UPDATE_INTERVAL then

				local posDist = (HRP.Position - self.lastCFrame.Position).Magnitude
				local angleDif = self.lastCFrame.LookVector:Dot(HRP.CFrame.LookVector)
				
				if angleDif ~= 1 or posDist > 0.1 then
					self.lastCFrame = HRP.CFrame
					self.lastUpdate = os.clock()
					self.networker:fireUnreliable('updateCharPos',HRP.CFrame)
				end 

			end
			
		end)
		
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		
		return function()
			updateLoop:Disconnect()
		end
		
	end)
	
	-- init other chars
	Observer.observeCharacter(function(player,character)
		
		if player == localPlayer then return end
		
		local HRP :BasePart = character:WaitForChild('HumanoidRootPart')
		local humanoid :Humanoid = character:WaitForChild('Humanoid')
		
		Snapshots[character] = character:GetPivot()
		
		return function()
			Snapshots[character] = nil
		end
		
	end)
	
	RunService.Heartbeat:Connect(function(dt)
		for character, currentPos in Snapshots do

			local alpha = 1 - math.exp(-25 * dt)
			
			local lastPivot = character:GetPivot()
			
			if character:HasTag('Ragdoll') then
				character.HumanoidRootPart.Anchored = false
			else
				character.HumanoidRootPart.Anchored = true
			end
			
			character:PivotTo(lastPivot:Lerp(currentPos, alpha))

		end
	end)
	
end

function CustomReplicationClient.replicateCharPos(self :CustomReplicationClient,targetPlayer :Player,CF :CFrame)
	Snapshots[targetPlayer.Character] = CF
end

return CustomReplicationClient

