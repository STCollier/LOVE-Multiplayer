local sock = require "lib.sock"

local client = {
	id = -1
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
  
    end)

 	self.client:on("yourID", function(id, client)
   		self.id = id
 	end)

    self.client:on("playerData", function(data, client)
    	for k, v in pairs(data) do
    		print(v.id, v.x, v.y)
    	end
    end)
end

return client