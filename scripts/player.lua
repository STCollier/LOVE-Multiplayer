local Class = require "lib.class"

local client = require "scripts.client"
local server = require "scripts.server"

local nametagFont = love.graphics.newFont(30)

local tick = 0

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
	end
}

function Player:update(dt)
	if (love.keyboard.isDown("up")) then
		self.y = self.y - 2
	elseif (love.keyboard.isDown("down")) then
		self.y = self.y + 2
	end

	if mode == "client" then
	    tick = tick + dt
	    if tick >= 0.016 then -- 60 times per second
	    	tick = 0
	    	client.client:send("playerPosition", {
				id = self.id,
				username = self.username,
				x = self.x,
				y = self.y,
			})
	    end
	elseif mode == "server" then
		tick = tick + dt
	    if tick >= 0.016 then -- 60 times per second
	    	tick = 0
	    	server.playerData[self.id] = {
	    		id = self.id,
	    		username = self.username,
	    		x = self.x,
	    		y = self.y,
	    	}
	    end
	else
		print("Invalid mode: must be server or client")
	end
end

function Player:draw()
	love.graphics.setFont(nametagFont)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf(self.username, self.x - 250, self.y - 50*2, 500, "center")

	love.graphics.setColor(0.28, 0.63, 0.05)
  	love.graphics.circle("fill", self.x, self.y, 50)
end

return Player
