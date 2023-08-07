local utf8 = require("utf8")
local Class = require "lib.class"
local font = love.graphics.newFont(50)
local rgb = love.math.colorFromBytes

function hovered(px, py, rx, ry, rw, rh)
	return (px >= rx and px <= rx + rw and py >= ry and py <= ry + rh)
end

local Ui = {
	TextInput = {},
	Button = {}
}

Ui.TextInput = Class{
    init = function(self, placeholder, x, y, w, h)
    	love.keyboard.setKeyRepeat(true)

    	self.placeholder = placeholder
	    self.x = x
	    self.y = y
	    self.w = w
	    self.h = h
		self.text = ""
		self.hovered = false
		self.clicked = false
		self.focused = false
    end,
}

function Ui.TextInput:draw()
	love.graphics.setFont(font)
	love.graphics.setColor(rgb(240, 240, 240))
	love.graphics.rectangle("fill", self.x-self.w/2, self.y-self.h/2, self.w, self.h, 10, 10)
	love.graphics.setColor(0, 0, 0, 1)


	love.graphics.setColor(rgb(0, 0, 0))
	love.graphics.printf(self.text, self.x-self.w/2, self.y-font:getHeight()/2, self.w, "center")

	if string.len(self.text) <= 0 then
		love.graphics.setColor(rgb(180, 180, 180))
		love.graphics.printf(self.placeholder, self.x-self.w/2, self.y-font:getHeight()/2, self.w, "center")
	end


	if self.focused then
		love.graphics.setColor(rgb(150, 150, 150))
		love.graphics.setLineWidth(3)
	else
		love.graphics.setColor(rgb(200, 200, 200))
		love.graphics.setLineWidth(2)
	end

	love.graphics.rectangle("line", self.x-self.w/2, self.y-self.h/2, self.w, self.h, 10, 10)
end

function Ui.TextInput:update()
	local mouseX, mouseY = love.mouse.getPosition()

	self.clicked = love.mouse.isDown(1)
	self.hovered = hovered(mouseX, mouseY, self.x-self.w/2, self.y-self.h/2, self.w, self.h)

	if (self.clicked and self.hovered) then
		self.focused = true
	elseif (not self.hovered and self.clicked) then
		self.focused = false
	end
end

function Ui.TextInput:handleInput(t)
	local text = love.graphics.newText(font, self.text)

    if text:getWidth() < self.w-50 and self.focused then 
    	self.text = self.text .. t
    end
end

function Ui.TextInput:handleBackspace(key)
    if key == "backspace" and self.focused then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(self.text, -1)

        if byteoffset then
            self.text = string.sub(self.text, 1, byteoffset - 1)
        end
    end
end

Ui.Button = Class{
    init = function(self, text, x, y, w, h)
    	self.text = text
		self.x = x
		self.y = y
		self.w = w
		self.h = h

		self.color = 225
		self.padding = 0
		self.hovered = false
		self.submitted = false
		self.clicked = false
		self.clickable = true
    end,
}

function Ui.Button:draw()
	love.graphics.setFont(font)
	love.graphics.setColor(rgb(self.color, self.color, self.color))
	love.graphics.rectangle("fill", self.x-self.w/2, self.y-self.h/2, self.w, self.h, 10, 10)
	love.graphics.setColor(0, 0, 0, 1)


	love.graphics.setColor(rgb(0, 0, 0))
	love.graphics.printf(self.text, self.x-self.w/2, self.y-font:getHeight()/2, self.w, "center")


	if self.hovered then
		love.graphics.setLineWidth(3)
		love.graphics.setColor(rgb(150, 150, 150))
		self.color = 200
	else
		love.graphics.setLineWidth(2)
		love.graphics.setColor(rgb(200, 200, 200))
		self.color = 225
	end

	love.graphics.rectangle("line", self.x-self.w/2, self.y-self.h/2, self.w, self.h, 10, 10)
end

function Ui.Button:update()
	local mouseX, mouseY = love.mouse.getPosition()

	self.clicked = love.mouse.isDown(1)
	self.hovered = hovered(mouseX, mouseY, self.x-self.w/2, self.y-self.h/2, self.w, self.h)
	self.submitted = ((self.clicked and self.hovered) or love.keyboard.isDown("return")) and self.clickable
end

function Ui.Button:onSubmit(callback)
	if (self.submitted) then callback() end
end

return Ui