local ffi = require("ffi")
local gl = require("opengl") -- OpenGL
local render = (...) or _G.render

local severities = {
	[0x9146] = "important", -- high
	[0x9147] = "warning", -- medium
	[0x9148] = "notice", -- low
}

local sources = {
	[0x8246] = "api",
	[0x8247] = "window system",
	[0x8248] = "shader compiler",
	[0x8249] = "third party",
	[0x824A] = "application",
	[0x824B] = "other",
}

local types = {
	[0x824C] = "error",
	[0x824D] = "deprecated behavior",
	[0x824E] = "undefined behavior",
	[0x824F] = "portability",
	[0x8250] = "performance",
	[0x8251] = "other",
}

function render.StartDebug()
	if EXTERNAL_DEBUGGER then return end
	if render.verbose_debug then return end

	if system.IsOpenGLExtensionSupported("GL_KHR_debug") then
		gl.Enable("GL_DEBUG_OUTPUT")
		gl.DebugMessageControl("GL_DONT_CARE", "GL_DONT_CARE", "GL_DONT_CARE", ffi.new("GLuint"), nil, true)
		gl.Enable("GL_DEBUG_OUTPUT_SYNCHRONOUS")
	else
		-- todo
	end
end

function render.StopDebug()
	if EXTERNAL_DEBUGGER then return end
	if render.verbose_debug then return end

	if system.IsOpenGLExtensionSupported("GL_KHR_debug") then
		local buffer = ffi.new("GLchar[1024]")
		local length = ffi.sizeof(buffer)

		local int = ffi.new("GLint[1]")
		gl.GetIntegerv("GL_DEBUG_LOGGED_MESSAGES", int)

		local message

		if int[0] ~= 0 then
			message = {}

			for _ = 0, int[0] do
				local types = ffi.new("GLenum[1]")
				if gl.GetDebugMessageLog(1, length, nil, types, nil, nil, nil, buffer) ~= 0 and types[0] == gl.e.GL_DEBUG_TYPE_ERROR then
					local str = ffi.string(buffer)
					table.insert(message, str)
				end
			end

			message = table.concat(message, "\n")

			if message == "" then message = nil end
		end

		gl.Disable("GL_DEBUG_OUTPUT")

		return message
	else
		-- todo
	end
end

local flags = {
	"error",
	"deprecated_behavior",
	"undefined_behavior",
	"portability",
	"performance"
}

for i,v in ipairs(flags) do flags[i] = gl.e["GL_DEBUG_TYPE_" .. v:upper()] end
flags = bit.bor(unpack(flags))

function render.EnableVerboseDebug(b)
	if system.IsOpenGLExtensionSupported("GL_KHR_debug") then
		if b then
			gl.Enable("GL_DEBUG_OUTPUT")
			gl.DebugMessageControl("GL_DONT_CARE", flags, "GL_DONT_CARE", ffi.new("GLuint"), nil, true)
			gl.Enable("GL_DEBUG_OUTPUT_SYNCHRONOUS")

			local buffer = ffi.new("GLchar[1024]")
			local length = ffi.sizeof(buffer)

			debug.sethook(function()
				local info = debug.getinfo(2)
				if info.source:find("opengl", nil, true) then

					local logged_count = ffi.new("GLint[1]")
					gl.GetIntegerv("GL_DEBUG_LOGGED_MESSAGES", logged_count)

					if logged_count[0] ~= 0 then
						local info = debug.getinfo(3)
						local source = info.source:match(".+render/(.+)")

						local message

						for _ = 0, logged_count[0] do
							local type = ffi.new("GLenum[1]")
							if gl.GetDebugMessageLog(1, length, nil, type, nil, nil, nil, buffer) ~= 0 then
								type = types[type[0]]
								if type ~= "other" then
									message = (message or "") .. "\t" .. type .. ": " .. ffi.string(buffer) .. "\n"
								end
							end
						end

						if message then
							llog("%s:%i gl.%s:", source, info.currentline, info.name)
							logn(message)
						end
					end
				end
			end, "return")
			render.verbose_debug = true
		else
			gl.Disable("GL_DEBUG_OUTPUT")
			debug.sethook()
			render.verbose_debug = false
		end
	else
		llog("glDebugMessageControl is not availible")
	end
end