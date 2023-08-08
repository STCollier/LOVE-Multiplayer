local Player = require "scripts.player"
local server = require "scripts.server"
local client = require "scripts.client"

local game = {
	players = {}
}

function table.length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function game:init(username)
	if (string.len(username) > 0) then
		you = Player(username, love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	else
		you = Player("Player", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	end
end

function game:update(dt)
	you:update(dt)
end

function game:draw()
	if mode == "server" then
		for k, v in pairs(server.playerData) do
			if (v.id ~= server.clientID) then
				love.graphics.setColor(0.28, 0.63, 0.05)
			  	love.graphics.circle("fill", v.x, v.y, 50)
			else
				you:draw()
			end
		end
	elseif mode == "client" then
		for k, v in pairs(client.playerData) do
			if (v.id ~= client.id) then
				love.graphics.setColor(0.28, 0.63, 0.05)
			  	love.graphics.circle("fill", v.x, v.y, 50)
			else
				you:draw()
			end
		end
	end
end

return game