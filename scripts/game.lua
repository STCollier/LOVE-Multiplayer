local Player = require "scripts.player"
local Projectile = require "scripts.projectile"
local server = require "scripts.server"
local client = require "scripts.client"
local util = require "scripts.util"

local t = 0

local game = {
	numPeers = 0,
	peers = {},
	players = {},
	projectiles = {}
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

	if mode == "server" then
		self.peers = server.peers
		for k, v in pairs(server.playerData) do
			if (v.id ~= server.clientID) then
				self.players[tostring(v.id)].body:setPosition(v.x, v.y)
			end

			if (self.numPeers < util.tableLength(self.peers)) then
				print("A new player joined!")

				for k, id in pairs(self.peers) do
					if (id ~= server.clientID) then self.players[tostring(id)] = Player("Player", love.graphics.getWidth()/2, love.graphics.getHeight()/2) end
				end
				self.numPeers = self.numPeers + 1
			end
		end

		t = t + dt
		if t >= 1 then
			t = 0
			local p = Projectile("grenede", util.timeNow(), love.math.random(0, love.graphics.getWidth()), -100)
			server.server:sendToAll("spawnProjectile", { -- Send "spawnProjectile" trigger to client
				type = p.type,
				id = p.id,
				exploded = p.exploded,
				timer = p.timer,
				x = p.x,
				y = p.y
			})
			server.projectiles[p.id] = { -- Update server projectile table
				type = p.type,
				id = p.id,
				exploded = p.exploded,
				timer = p.timer,
				x = p.x,
				y = p.y
			}

			self.projectiles[p.id] = p
		end

		for k, v in pairs(self.projectiles) do
			if not v.destroyed then
				self.projectiles[k]:update(dt)
			else
				util.removeByKey(self.projectiles, k)
				util.removeByKey(server.projectiles, k)
			end
		end
		--print(util.tableLength(self.projectiles), util.tableLength(server.projectiles))
	elseif mode == "client" then
		self.peers = client.peers
		for k, v in pairs(client.playerData) do
			if (v.id ~= client.id) then
				self.players[tostring(v.id)].body:setPosition(v.x, v.y)
			end
		end

		if (self.numPeers < util.tableLength(self.peers)) then
			print("[CLIENT] recieved player joined")

			for k, id in pairs(self.peers) do
				if (id ~= client.id) then self.players[tostring(id)] = Player("Player", love.graphics.getWidth()/2, love.graphics.getHeight()/2) end
			end
			self.numPeers = self.numPeers + 1
		end

		if client.spawnProjectile then
			--print("[CLIENT] recieved spawn projectile")
			for k, v in pairs(client.projectiles) do
				self.projectiles[k] = Projectile(v.type, v.id, v.x, v.y)
			end
			client.spawnProjectile = false
		end

		for k, v in pairs(self.projectiles) do
			--print(util.tableLength(self.projectiles))
			self.projectiles[k].type = client.projectiles[k].type
			self.projectiles[k].id = client.projectiles[k].id
			self.projectiles[k].exploded = client.projectiles[k].exploded
			self.projectiles[k].timer = client.projectiles[k].timer
			self.projectiles[k].x = client.projectiles[k].x
			self.projectiles[k].y = client.projectiles[k].y

			if not v.exploded then
				self.projectiles[k].body:setPosition(v.x, v.y)
				self.projectiles[k]:update(dt)
			else
				print(self.projectiles[k].body)
				--util.removeByKey(self.projectiles, k)
				--util.removeByKey(client.projectiles, k)
				print("[CLIENT] destroyed projectile")
			end
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

		for k, v in pairs(self.projectiles) do
			if not v.destroyed then
				self.projectiles[k]:draw()
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

		for k, v in pairs(self.projectiles) do
			--if not v.exploded then
				self.projectiles[k]:draw()
			--end
		end
	end

	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.polygon("fill", floor.body:getWorldPoints(floor.shape:getPoints()))
end

function game:handleCollisions(a, b)
	you:handleCollisions(a, b)
end

return game