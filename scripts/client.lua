local sock = require "lib.sock"

local client = {
	id = -1,
	peers = {},
	playerData = {},
	spawnProjectile = false,
	projectiles = {}
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

    self.client:on("playerData", function(data, client)
    	self.playerData = data
    end)

 	self.client:on("peers", function(peers, client)
 		self.peers = peers
 	end)

    self.client:on("newPlayer", function(id, client)
    	if (id ~= self.id) then table.insert(self.peers, id) end
    end)

    self.client:on("spawnProjectile", function(p, client)
    	self.spawnProjectile = true

    	self.projectiles[p.id] = {
			type = p.type,
			id = p.id,
			exploded = p.exploded,
			timer = p.timer,
			x = p.x,
			y = p.y
    	}
    end)

    self.client:on("projectileData", function(data, client)
    	self.projectiles[data.id] = {
			type = data.type,
			id = data.id,
			exploded = data.exploded,
			timer = data.timer,
			x = data.x,
			y = data.y
    	}
    end)
end

return client