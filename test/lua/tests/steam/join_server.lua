local ip, port = "177.220.172.0", 27015  
 
local function wireshark_hex_dump(str)
	print((str:readablehex():gsub("(.. .. .. .. .. .. .. .. )(.. .. .. .. .. .. .. .. )", "%1\t%2\n")))
end

local SINGLE_PACKET = 0xFFFFFFFF
local MAGIC_VERSION = 0x5A4F4933
local CLIENT_CHALLENGE = 0x33494f5a --0x30303030 -- 0x7FFFFFFF

local PROTOCOL_VERSION = 0x18 --0xf
local PROTOCOL_STEAM = 0x03 -- Protocol type (Steam authentication)

local DISCONNECT_REASON_LENGTH = 1260
local GAME_VERSION = "1.0.10.1" 

local connect = {
	request = {
		{"long", SINGLE_PACKET}, -- this is for telling if the packet is split or not
		{"byte", 0x71}, -- get challenge
		
		0x33, 0x27, 0x72, 0x00,
		-- can also be:
		-- 0xc9, 0x5e, 0xa2, 0x09,
		-- 0xa2, 0x42, 0x9f, 0x06
		-- 0xa9, 0x33, 0x96, 0x01
		-- 0x22, 0x91, 0x37, 0x0d
		
		-- rest is always this
		0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x00
	},
	response = {
		{"long", "header"},
		{"byte", "type", switch = {
			[0x39] = {
				{"long", "client_challenge"},   
				{"string", "disconnect_reason", length = DISCONNECT_REASON_LENGTH},   
			},
			[0x41] = {
				{"long", "magic_version", assert = MAGIC_VERSION},
				{"string", "challenge", length = 8}, -- might also be server and client challenge
				{"byte", "protocol", assert = PROTOCOL_STEAM},
				
				{"byte", "unknown"},
				{"long", "unknown"},
				
				{"string", "gsid", length = 7}, 
				{"byte", "vac", translate = {[1] = true, [2] = false}}, -- probably the vac secure boolean, it was 01 in wireshark   
			},
		}},
	},
} 
   
local connect_response = {
	{"long", SINGLE_PACKET}, 
	{"byte", 0x6b}, 
	{"byte", PROTOCOL_VERSION}, 
	0x00, 0x00, 0x00, -- is PROTOCOL_STEAM a long?
	{"byte", PROTOCOL_STEAM}, 
	0x00, 0x00, 0x00,
	{"bytes", get = "challenge"},
	
	-- strings separated by 0
	{"string", "CapsAdmin"}, -- nick
	{"string", "train"}, -- password
	{"string", "14.04.19"}, -- date
	
	0xf2, 0x00, 0xef, 0x82, 0x1d, 0x01, 0x01, 0x00, 
	0x10, 0x01, 
	
	{"bytes", get = "gsid"},
	
	0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 
	0x17, 0xd9, 0xc7, 0x6d, 0x00, 0x00, 0x00, 0x00, 
	
	-- these can change
	0xda, 0x87, 0x02, 0x0d, 0x03, 
	 
	0x00, 0x00, 0x00, 0xb2, 
	0x00, 0x00, 0x00, 0x32, 0x00, 0x00, 0x00, 0x04, 
	0x00, 0x00, 0x00, 0xef, 0x82, 0x1d, 0x01, 0x01, 
	0x00, 0x10, 0x01, 0xa0, 0x0f, 0x00, 0x00, 0x17, 
	0xd9, 0xc7, 0x6d, 0x0a, 0x00, 0xa8, 0xc0, 0x00, 
	0x00, 0x00, 0x00, 0x62, 0xa2, 0x71, 0x53, 0xe2, 
	0x51, 0x8d, 0x53, 0x01, 0x00, 0xda, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x5c, 0xe7, 0x26, 
	0x18, 0xdb, 0x04, 0x5d, 0xec, 0x5e, 0xc7, 0x4c, 
	0x0a, 0xcf, 0x7d, 0x51, 0xfe, 0xad, 0x1d, 0x63, 
	0x6d, 0x41, 0xe6, 0xeb, 0x56, 0xcf, 0x45, 0x2c, 
	0x19, 0xaf, 0xc7, 0x26, 0xa8, 0xb7, 0x84, 0x4f, 
	0x3f, 0x56, 0x3e, 0x47, 0x8f, 0x1e, 0x2a, 0x8a, 
	0xfd, 0x79, 0x08, 0x7c, 0xa1, 0xb9, 0x6d, 0x74, 
	0xe4, 0x74, 0xbd, 0x8a, 0x6e, 0x83, 0xba, 0x74, 
	0x12, 0x80, 0xe9, 0x19, 0xf1, 0xe3, 0x5e, 0xaf, 
	0x6a, 0xa8, 0xf2, 0xc9, 0x4a, 0x4a, 0x2f, 0xba, 
	0xc9, 0x65, 0xa9, 0xa4, 0xa6, 0x4c, 0x7d, 0xcd, 
	0x7b, 0xa5, 0xa4, 0x10, 0x82, 0xe6, 0xdb, 0x46, 
	0x9e, 0x99, 0x82, 0x23, 0xb5, 0x06, 0xe4, 0x7d, 
	0x9d, 0x6d, 0x5d, 0x22, 0xa2, 0x67, 0x11, 0xd0, 
	0x4d, 0xb9, 0xd3, 0x5c, 0xe0, 0xc2, 0x43, 0x95, 
	0xc4, 0x46, 0xe8, 0x17, 0xa1, 0x54, 0x75, 0xca, 
	0xad, 0xb6, 0x93, 0xc6, 0x96
};
 
local function send_struct(socket, struct, values) 
	local buffer = Buffer()
	buffer:WriteStructure(struct, values)
	  
	wireshark_hex_dump(buffer:GetString())
	   
	socket:Send(buffer:GetString())
end

local function read_struct(str, struct)
	return Buffer(str):ReadStructure(struct)
end

do -- socket	 
	local client = luasocket.CreateClient("udp", ip, port)
	client.debug = false  

	send_struct(client, connect.request)

	function client:OnReceive(str)	
		local data = read_struct(str, connect.response)
					
		if data.type == 57 then -- rejected
			logn("connection rejected: ", data.disconnect_reason)
		elseif data.type == 65 then -- challenge
			local key = steam.GetAuthTokenFromServer(utilities.StringToLongLong(data.gsid), ip, port, data.vac)
			
			data.steam_key_size = #key
			data.steam_key = key
			
			print(#key)
									
			send_struct(self, connect_response, data) 
		elseif data.type == 66 then -- connection
			print("woho")
		end
	end  
end