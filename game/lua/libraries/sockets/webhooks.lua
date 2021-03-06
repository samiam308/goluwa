sockets.webook_servers = sockets.webook_servers or {}

function sockets.StartWebhookServer(port, secret, callback)
	local hmac

	if secret then
		hmac = require("openssl.hmac")
	end

	local function verify_signature(hub_sign, body)
		local a = hub_sign:sub(#"sha1=" + 1):gsub("..", function(c) return string.char(tonumber("0x"..c)) end)
		local b = hmac.new(secret, "sha1"):final(body)

		local equal = #a == #b
		if equal then
			for i = 1, #a do
				if a:sub(i, i) ~= b:sub(i, i) then
					return
				end
			end
			return true
		end
	end

	local server = sockets.webook_servers[port]

	if not server then
		server = sockets.TCPServer()
		server:Host("*", port)

		sockets.webook_servers[port] = server
	end

	function server:OnClientConnected(client)
		sockets.ConnectedTCP2HTTP(client)

		function client:OnReceiveBody()
			if secret then
				if not verify_signature(self.Header["x-hub-signature"], self.Body) then
					logn("webhook client ", client, " removed because signature does not match: ", data.header["x-hub-signature"])
					client:Remove()
					return
				end
			end

			local content = self.Body

			if self.Header["content-type"]:find("form-urlencoded", nil, true) then
				content = content:match("^payload=(.+)")
				content = content:gsub("%%(..)", function(hex)
					return string.char(tonumber("0x"..hex))
				end)
			end

			client:Send("HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")

			local tbl = serializer.Decode("json", content)
			if callback then callback(tbl, self) end
			event.Call("Webhook", tbl, self)
		end

		return true
	end
end

function sockets.StopWebhookServer(port)
	if sockets.webook_servers[port] then
		sockets.webook_servers[port]:Remove()
		sockets.webook_servers[port] = nil
	end
end