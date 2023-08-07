local Player = require "scripts.player"

local game = {}

function game:init()
	you = Player("Player", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
end

function game:update(dt)
	you:update(dt)
end

function game:draw()
	you:draw()
end

return game