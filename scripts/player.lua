local Class = require "lib.class"

local client = require "scripts.client"
local server = require "scripts.server"

local nametagFont = love.graphics.newFont(30)

local tick = 0
local currentTick = 0
local previousX = 0
local previousY = 0

local Player = Class{
	init = function(self, username, x, y)
		if mode == "client" then 
			self.id = client.id
		elseif mode == "server" then
			self.id = server.clientID
		else
			print("Invalid mode: must server or client")
		end

		self.username = username
		self.x = x
		self.y = y
		self.r = 50
		self.jumps = 0
		self.movement = {
			right = false,
			left = false,
			up = false,
		}

		self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		self.shape = love.physics.newCircleShape(self.r)
		self.fixture = love.physics.newFixture(self.body, self.shape)
		self.body:setFixedRotation(true)
	    self.body:setMass(1.2)
	    self.fixture:setUserData("Player")

	    self.lateralForce = 500
	    self.jumpForce = 600
	end
}

function Player:update(dt)
	self.velX, self.velY = self.body:getLinearVelocity()

    if love.keyboard.isDown("right") and self.velX < 400 then
        self.body:applyForce(self.lateralForce, 0)
        self.movement.right = true
    elseif love.keyboard.isDown("left") and self.velX > -400 then
        self.body:applyForce(-self.lateralForce, 0)
        self.movement.left = true
    end

    if love.keyboard.isDown("up") and self.jumps > 0 then
    	self.body:applyLinearImpulse(0, -self.jumpForce)
    	self.up = true
        self.jumps = self.jumps - 1
    end

	if mode == "client" then
	    tick = tick + dt

	    if tick >= 1/tickRate then
	    	tick = 0
	    	currentTick = currentTick + 1

	    	client.client:send("playerPosition", {
	    		tick = currentTick,
				id = self.id,
				username = self.username,
				x = self.body:getX(),
				y = self.body:getY(),
				prevX = previousX,
				prevY = previousY,
				velX = self.velX,
				velY = self.velY,
				movement = self.movement
			})

	    	previousX = self.body:getX()
	    	previousY = self.body:getY()
	    end
	elseif mode == "server" then
		tick = tick + dt

	    if tick >= 1/tickRate then
	    	tick = 0
	    	currentTick = currentTick + 1

	    	server.playerData[self.id] = {
	    		tick = currentTick,
				id = self.id,
				username = self.username,
				x = self.body:getX(),
				y = self.body:getY(),
				prevX = previousX,
				prevY = previousY,
				velX = self.velX,
				velY = self.velY,
				movement = self.movement
	    	}

	    	previousX = self.body:getX()
	    	previousY = self.body:getY()
	    end
	else
		print("Invalid mode: must be server or client")
	end
end

function Player:draw(username)
	love.graphics.setFont(nametagFont)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf(username or self.username, self.body:getX() - 250, self.body:getY() - 50*2, 500, "center")

	love.graphics.setColor(0.28, 0.63, 0.05)
  	love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
end

function Player:handleCollisions(a, b)
    if a:getUserData() == "Player" and b:getUserData() == "Solids" or a:getUserData() == "Solids" and b:getUserData() == "Player" then
        self.jumps = 1
    end
end

return Player
