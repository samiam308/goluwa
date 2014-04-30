chat = {}

local function getnick(ply)
	return ply:IsValid() and ply:GetNick() or "server"
end

local enabled = console.CreateVariable("chat_timestamps", true)

function chat.AddTimeStamp(tbl)
	if not enabled:Get() then return end
	
	tbl = tbl or {}
	
	local time = os.date("*t")
	
	table.insert(tbl, 1, " - ")
	table.insert(tbl, 1, Color(255, 255, 255))
	table.insert(tbl, 1, ("%.2d:%.2d"):format(time.hour, time.min))
	table.insert(tbl, 1, Color(118, 170, 217))

	return tbl
end

function chat.GetTimeStamp()
	local time = os.date("*t")

	return ("%.2d:%.2d - "):format(time.hour, time.min)
end

function chat.Append(var, str)

	if not str then
		str = var
		var = NULL
	end

	local ply = NULL
	
	if typex(var) == "player" then
		ply = var
		var = getnick(var)
	elseif not network.IsConnected() then
		var = "disconnected"
	elseif typex(var) == "null" then
		var = "server"
	else
		var = tostring(var)
	end	

	if CLIENT then
		local tbl = chat.AddTimeStamp()
		
		if ply:IsValid() then
			table.insert(tbl, ply:GetUniqueColor())
		end
		
		table.insert(tbl, var)
		table.insert(tbl, Color(255, 255, 255, 255))
		table.insert(tbl, ": ")
		table.insert(tbl, str)
		chathud.AddText(unpack(tbl))
	end
	
	logf("%s%s: %s", chat.GetTimeStamp(), var, str)
end

if CLIENT then	
	message.AddListener("say", function(ply, str)
		if event.Call("OnPlayerChat", ply, str) ~= false then
			chat.Append(ply, str)
		end
	end)
	
	function chat.Say(str)
		str = tostring(str)		
		message.Send("say", str)
		if event.Call("OnPlayerChat", players.GetLocalPlayer(), str) ~= false then
			chat.Append(players.GetLocalPlayer(), str)
		end
	end	
	
	chat.panel = NULL
	
	function chat.IsVisible()
		return chat.panel:IsValid()
	end
		
	function chat.SetInputText(str)
		if not chat.IsVisible() then return end
		chat.panel:SetText(str)
	end
	
	function chat.GetInputText()
		if not chat.IsVisible() then return "" end
		return chat.panel:GetText()
	end	
	
	function chat.GetInputPos()
		if not chat.IsVisible() then return 0, 0 end
		return chat.panel:GetPos()
	end
		
	--[[event.AddListener("ConsoleLineEntered", "chat", function(line)
		if not network.IsStarted() then return end
	
		if not console.RunString(line, true) then
			chat.Say(line)
		end
		
		return false
	end)]]
	
	if aahh then

		local i = 1
		local history = {}
		local visible
		
		console.AddCommand("showchat", function()
		
			local panel =  chat.panel
			
			if not visible then				
				panel = aahh.Create("text_input")
					panel:SetPos(Vec2(50, Vec2(render.GetScreenSize()).h - 100))
					panel:SetSize(Vec2(512, 16))
					panel:MakeActivePanel()
					panel:SetMultiline(true)
					
					panel.OnUnhandledKey = function(self, key)									
						local str = self:GetText():trim()
						
						local ctrl = input.IsKeyDown("left_control") or input.IsKeyDown("right_control")
						
						if ctrl or str == "" then
							local browse = false
							
							if key == "up" then
								i = math.clamp(i + 1, 1, #history)
								browse = true
							elseif key == "down" then
								i = math.clamp(i - 1, 1, #history)
								browse = true
							end
							
							if browse and history[i] then
								panel:SetText(history[i])
								panel:SetCaretPos(Vec2(#history[i], 0))
							end
						end

						if key == "escape" then
							panel:OnEnter("")
						end
						
						if key == "tab" then
							local str = event.Call("OnChatTab", str)
								
							if str then 
								panel:SetText(str)
							end
						end
						
						if key == "enter" and not ctrl then
							i = 0
							if #str > 0 then
								chat.Say(str)
								if history[1] ~= str then
									table.insert(history, 1, str)
								end
							end
							
							window.ShowCursor(false)
							visible = false
							
							panel:Remove()
							
							event.Call("OnChatTextChanged", "")
						end	
					end
					
					local suppress = true -- stupid
					timer.Delay(0.1, function() suppress = false end) -- stupid
					
					panel.OnTextChanged = function(self, str)
						if suppress then -- stupid
							suppress = false -- stupid
							self:SetText("") -- stupid
							suppress = true -- stupid
						end
						event.Call("OnChatTextChanged", str)
						
						self:SetPos(Vec2(50, Vec2(render.GetScreenSize()).h - 100))
						self:SizeToContents()
					end
					
				window.ShowCursor(true)
				visible = true
			end
			
			chat.panel = panel
		end)
		
		input.Bind("y", "showchat")
	end
end

function chat.PlayerSay(ply, str, filter, skip_log)
	if event.Call("OnPlayerChat", ply, str) ~= false then
		if skip_log then chat.Append(ply, str) end
		if SERVER then message.Send("say", filter, ply, str) end
	end
end

if SERVER then

	message.AddListener("say", function(ply, str)
		chat.PlayerSay(ply, str, message.PlayerFilter():AddAllExcept(ply))
	end)

	function chat.Say(str)
		str = tostring(str)		
		message.Broadcast("say", NULL, str)
		chat.Append(NULL, str)
	end
end