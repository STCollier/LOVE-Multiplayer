local scene = require "scripts.scene"

function love.load()
	players = {}
	mode = nil

	love.graphics.setBackgroundColor(1, 1, 1, 1)
	scene:load()
end

function love.update(dt)
	if (love.keyboard.isDown("escape")) then love.event.quit() end

	scene:update(dt)
end

function love.draw()
	scene:draw()
end

function love.textinput(t)
	scene:textInput(t)
end

function love.keypressed(key)
	scene:keyPressed(key)
end
