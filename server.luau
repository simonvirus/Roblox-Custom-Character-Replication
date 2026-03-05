local CustomReplicationServer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local Observer = require(ReplicatedStorage.Packages.Observer)

type CustomReplicationServer = typeof(CustomReplicationServer)

function CustomReplicationServer.init(self :CustomReplicationServer)
	self.networker = Networker.server.new('CustomReplication',self,{
		self.updateCharPos
	})
	
	Observer.observeCharacter(function(player,character)
		character.PrimaryPart = character.HumanoidRootPart
	end)
	
end

function CustomReplicationServer.updateCharPos(self :CustomReplicationServer,Player :Player,CF :CFrame)
	self.networker:fireAllExcept(Player,'replicateCharPos',Player,CF)
end

return CustomReplicationServer
