local scene = require "scripts.scene"
local game = require "scripts.game"
local socket = require "socket"
local flux = require "lib.flux"

function love.load()
	tickRate = 60
	mode = nil

    love.graphics.setDefaultFilter("nearest", "nearest")

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

function beginContact(a, b)
	if scene.scene == "game" then
		game:handleCollisions(a, b)
	end
end