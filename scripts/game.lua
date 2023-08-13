local Player = require "scripts.player"
local server = require "scripts.server"
local client = require "scripts.client"
local util = require "scripts.util"
local flux = require "lib.flux"

local game = {
	numPeers = 0,
	peers = {},

	players = {}
}

function game:init(username)
	love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)
    world:setCallbacks(beginContact)

	if (string.len(username) > 0) then
		you = Player(username, love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	else
		you = Player("Player", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	end

	if mode == "server" then
		self.peers = server.peers
	elseif mode == "client" then
		self.peers = client.peers

		for k, id in pairs(self.peers) do
			if (id ~= client.id) then
				self.players[tostring(id)] = Player(id, love.graphics.getWidth()/2, love.graphics.getHeight()/2)
			end
		end
	end

	self.numPeers = util.tableLength(self.peers)


	floor = {} 
	floor.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()-50)
	floor.shape = love.physics.newRectangleShape(love.graphics.getWidth(), 100)
	floor.fixture = love.physics.newFixture(floor.body, floor.shape)
	floor.fixture:setUserData("Solids")
end

function game:update(dt)

	world:update(dt)
	you:update(dt)
	flux.update(dt)

	if mode == "server" then
		self.peers = server.peers
		for k, v in pairs(server.playerData) do
			if (v.id ~= server.clientID) then
				self.players[tostring(v.id)].body:setPosition(p.x, p.y)
			end

			if (self.numPeers < util.tableLength(self.peers)) then
				print("A new player joined!")

				for k, id in pairs(self.peers) do
					if (id ~= server.clientID) then self.players[tostring(id)] = Player("Player", love.graphics.getWidth()/2, love.graphics.getHeight()/2) end
				end
				self.numPeers = self.numPeers + 1
			end
		end
	elseif mode == "client" then
		self.peers = client.peers
		for k, v in pairs(client.playerData) do
			if (v.id ~= client.id) then
				self.players[tostring(v.id)].body:setPosition(p.x, p.y)

			end
		end

		if (self.numPeers < util.tableLength(self.peers)) then
			print("A new player joined!")

			for k, id in pairs(self.peers) do
				if (id ~= client.id) then self.players[tostring(id)] = Player("Player", love.graphics.getWidth()/2, love.graphics.getHeight()/2) end
			end
			self.numPeers = self.numPeers + 1
		end
	end
end

function game:draw()

	if mode == "server" then
		for k, v in pairs(server.playerData) do
			if (v.id == server.clientID) then
				you:draw()
			else
				if (v.id ~= server.clientID) then
					self.players[tostring(v.id)]:draw(v.username)
				end
			end
		end
	elseif mode == "client" then
		for k, v in pairs(client.playerData) do
			if (v.id == client.id) then
				you:draw()
			else
				if (v.id ~= client.id) then
					self.players[tostring(v.id)]:draw(v.username)
				end
			end
		end
	end

	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.polygon("fill", floor.body:getWorldPoints(floor.shape:getPoints()))
end

function game:handleCollisions(a, b)
	you:handleCollisions(a, b)
end

return game