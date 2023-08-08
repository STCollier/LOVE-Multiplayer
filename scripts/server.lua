local sock = require "lib.sock"

local server = {
	clientID = -1,
	peers = {},
	playerData = {}
}

function server:init(ip, port)
	self.server = sock.newServer(ip, port)

	local clientID = tostring(math.random(10000, 99999))
	self.clientID = clientID
    table.insert(self.peers, clientID)

	server:events()
end

function server:update()
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

        client:send("peers", self.peers)
        client:send("yourID", newID)

        --self.server:sendToAll("newPlayer", newID)
    end)

    self.server:on("playerPosition", function(data, client)
    	self.playerData[tostring(data.id)] = {
    		id = data.id,
    		username = data.username,
    		x = data.x,
    		y = data.y,
    	}

    	client:send("playerData", self.playerData)
    end)
end

return server