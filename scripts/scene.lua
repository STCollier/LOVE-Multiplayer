local Ui = require "scripts.ui"
local socket = require "socket"

local game = require "scripts.game"
local server = require "scripts.server"
local client = require "scripts.client"

local scene = {
	scene = "menu",
}

function scene:load()
	-- MENU
	joinButton = Ui.Button("Join", love.graphics.getWidth()/2, love.graphics.getHeight()/2-100, 400, 75)
	hostButton = Ui.Button("Host", love.graphics.getWidth()/2, love.graphics.getHeight()/2, 400, 75)
	quitButton = Ui.Button("Quit", love.graphics.getWidth()/2, love.graphics.getHeight()/2+100, 400, 75)

	-- JOIN
	ipInput = Ui.TextInput("IP", love.graphics.getWidth()/2-225 - 5, love.graphics.getHeight()/2, 600, 75)
	ipInput.text = socket.dns.toip(socket.dns.gethostname()) or "0.0.0.0"

	portInput = Ui.TextInput("Port", love.graphics.getWidth()/2+225 + 5, love.graphics.getHeight()/2, 300, 75)
	portInput.text = 7777

	joinGameButton = Ui.Button("Join", love.graphics.getWidth()/2+465, love.graphics.getHeight()/2, 150, 75)

	backButton = Ui.Button("Back", love.graphics.getWidth()/2, love.graphics.getHeight()-150, 300, 75)

	-- HOST
	hostGameButton = Ui.Button("Host", love.graphics.getWidth()/2+465, love.graphics.getHeight()/2, 150, 75)

	loadingFont = love.graphics.newFont(64)
end

function scene:update(dt)
	if self.scene == "menu" then
		joinButton:update()
		hostButton:update()
		quitButton:update()

		if joinButton.submitted then self.scene = "join" end
		if hostButton.submitted then self.scene = "host" end
		if quitButton.submitted then love.event.quit() end
	elseif self.scene == "join" then
		ipInput:update()
		portInput:update()
		joinGameButton:update()
		backButton:update()

		if (joinGameButton.submitted) then 
			client:init(ipInput.text, tonumber(portInput.text))
			mode = "client"
			game:init()
			self.scene = "loading"
		end

		if backButton.submitted then self.scene = "menu" end
	elseif self.scene == "host" then
		ipInput:update()
		portInput:update()
		hostGameButton:update()
		backButton:update()

		if (hostGameButton.submitted) then 
			server:init(ipInput.text, tonumber(portInput.text))
			mode = "server"
			game:init()
			self.scene = "loading"
		end

		if backButton.submitted then self.scene = "menu" end
	elseif self.scene == "game" then
		if mode == "server" then
			server:update()
		elseif mode == "client" then
			client:update()
		else
			print("Invalid mode: must be server or client")
			love.event.quit()
		end

		game:update(dt)
	elseif self.scene == "loading" then
		if mode == "server" then
			server:update()
			if not (server.clientID == -1) then self.scene = "game" end
		elseif mode == "client" then
			client:update()
			if not (client.id == -1) then self.scene = "game" end
		else
			print("Invalid mode: must be server or client")
			love.event.quit()
		end

	end

end

function scene:draw()
	if self.scene == "menu" then
		joinButton:draw()
		hostButton:draw()
		quitButton:draw()
	elseif self.scene == "join" then
		ipInput:draw()
		portInput:draw()
		joinGameButton:draw()
		backButton:draw()
	elseif self.scene == "host" then
		ipInput:draw()
		portInput:draw()
		hostGameButton:draw()
		backButton:draw()
	elseif self.scene == "loading" then
		local text = love.graphics.newText(loadingFont, "Loading...")

		love.graphics.setColor(0, 0, 0)
		love.graphics.setFont(loadingFont)
		love.graphics.printf("Loading...", love.graphics.getWidth() / 2 - text:getWidth() / 2, love.graphics.getHeight() / 2 - text:getHeight() / 2, text:getWidth(), "center")

	elseif self.scene == "game" then
		game:draw()
	end
end

function scene:textInput(t)
	if self.scene == "menu" then
	elseif self.scene == "join" or self.scene == "host" then
		ipInput:handleInput(t)
		portInput:handleInput(t)
	end
end

function scene:keyPressed(key)
	if self.scene == "menu" then
	elseif self.scene == "join" or self.scene == "host" then
		ipInput:handleBackspace(key)
		portInput:handleBackspace(key)
	end
end

return scene