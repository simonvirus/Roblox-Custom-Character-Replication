local CharacterServiceServer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Observer = require(ReplicatedStorage.Packages.Observer)

type CharacterServiceServer = typeof(CharacterServiceServer)

function CharacterServiceServer.init(self :CharacterServiceServer)
	Observer.observeCharacter(function(player,character)
		for _,part in character:GetDescendants() do
			if part:IsA('BasePart') then
				part.CollisionGroup = 'Characters'
			end
		end
	end)
end

CollectionService:GetInstanceAddedSignal('Ragdoll'):Connect(function(character)
	local humanoid = character:FindFirstChildWhichIsA('Humanoid')
	humanoid.PlatformStand = true
end)

CollectionService:GetInstanceRemovedSignal('Ragdoll'):Connect(function(character)
	local humanoid = character:FindFirstChildWhichIsA('Humanoid')
	humanoid.PlatformStand = false
end)

return CharacterServiceServer
