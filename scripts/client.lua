local sock = require "lib.sock"

local client = {
	id = -1,
	peers = {},
	playerData = {}
}

function client:init(ip, port)
	self.client = sock.newClient(ip, port)
	self.client:connect()

	client:events()
end

function client:update()
	self.client:update()
end

function client:events()
	self.client:on("connect", function(data, client)
  		print("You connected")
    end)

 	self.client:on("yourID", function(id, client)
   		self.id = id
 	end)

 	self.client:on("peers", function(peers, client)
 		self.peers = peers
 	end)

    self.client:on("playerData", function(data, client)
    	self.playerData = data
    end)
end

return client