local Class = require "lib.class"

local client = require "scripts.client"
local server = require "scripts.server"
local util = require "scripts.util"

local tick = 0
local updateTick = 0

local Projectile = Class{
	init = function(self, type, id, x, y)
		self.type = type
		self.x = x
		self.y = y
		self.id = tostring(id)
		self.destroyed = false

		self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		self.shape = love.physics.newCircleShape(25)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.body:setFixedRotation(false)
	    self.body:setMass(0.5)
	    self.fixture:setRestitution(0.5)
	    self.fixture:setUserData(type:sub(1,1):upper()..type:sub(2))

	    self.tick = 0
	    if self.type == "grenede" then self.timer = 5 end
	end
}

function Projectile:update(dt)
	if self.type == "bomb" then
	elseif self.type == "grenede" then
		if mode == "server" then
			self.tick = self.tick + dt

		    if self.tick >= 1 and self.timer > 0 then
		    	self.tick = 0
		    	self.timer = self.timer - 1
		    end
		end

	    if self.timer == 0 then
	    	if mode == "server" then
				server.server:sendToAll("projectileData", {
					type = self.type,
					id = self.id,
					exploded = true,
					timer = 0,
					x = self.body:getX(),
					y = self.body:getY()
				})
			end
	    	self.destroyed = true
	    	self.body:destroy()
	    end
	end

	if mode == "server" and not self.destroyed then
		updateTick = updateTick + dt

		if updateTick >= 1/tickRate then
			updateTick = 0
			server.server:sendToAll("projectileData", {
				type = self.type,
				id = self.id,
				exploded = false,
				timer = self.timer,
				x = self.body:getX(),
				y = self.body:getY()
			})
		end
	end
end

function Projectile:draw()
	if self.type == "bomb" then
	elseif self.type == "grenede" then
		love.graphics.setColor(0, 0, 0)

		love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
	end
end

return Projectile
