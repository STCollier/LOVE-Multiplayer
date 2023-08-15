local sock = require "lib.sock"

local tick = 0

local server = {
	clientID = -1,
	peers = {},
	playerData = {},
	projectiles = {},
	spawnProjectile = false
}

function server:init(ip, port)
	self.server = sock.newServer(ip, port)

	local clientID = tostring(math.random(10000, 99999))
	self.clientID = clientID
    table.insert(self.peers, clientID)

	server:events()
end

function server:update(dt)
	self.server:update()
end


function server:events()
	self.server:on("connect", function(data, client)
		local newID = math.random(10000, 99999)

		-- Make sure each clientID is unique
        for id in pairs(self.peers) do
        	while (id == newID) do newID = math.random(10000, 99999) end
        end

        table.insert(self.peers, newID)
        print("Client ["..newID.."] connected")

        client:send("yourID", newID)

        client:send("peers", self.peers)
        self.server:sendToAll("newPlayer", newID)
    end)

    self.server:on("playerPosition", function(data, client)
    	self.playerData[tostring(data.id)] = {
    		tick = data.tick,
    		id = data.id,
    		username = data.username,
    		x = data.x,
    		y = data.y,
			prevX = data.prevX,
			prevY = data.prevY,
			velX = data.velX,
			velY = data.velY,
			movement = data.movement
    	}

    	client:send("playerData", self.playerData)
    end)
end

return server