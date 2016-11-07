local ffi = require("ffi")
local gl = require("opengl") -- OpenGL
local render = (...) or _G.render

local severity_translate = {
	[0x9146] = "important", -- high
	[0x9147] = "warning", -- medium
	[0x9148] = "notice", -- low
}

local source_translate = {
	[0x8246] = "api",
	[0x8247] = "window system",
	[0x8248] = "shader compiler",
	[0x8249] = "third party",
	[0x824A] = "application",
	[0x824B] = "other",
}

local type_translate = {
	[0x824C] = "error",
	[0x824D] = "deprecated behavior",
	[0x824E] = "undefined behavior",
	[0x824F] = "portability",
	[0x8250] = "performance",
	[0x8251] = "other",
}

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
			--jit.off()
			--jit.flush()
			gl.Enable("GL_DEBUG_OUTPUT")
			gl.Enable("GL_DEBUG_OUTPUT_SYNCHRONOUS")
			gl.DebugMessageControl("GL_DONT_CARE", "GL_DONT_CARE", "GL_DONT_CARE", ffi.new("GLuint"), nil, true)

			local callback = ffi.new("void (*)(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar* message, const void* userParam)", function(source, type, id, severity, length, message, userParam)
				source = source_translate[source] or "unknown source " .. source
				type = type_translate[type] or "unknown type " .. type
				severity = severity_translate[severity] or "unknown severity level " .. severity
				message = ffi.string(message, length)

				local info = debug.getinfo(3)

				logf("OPENGL %s %s: %s\n", type:upper(), severity, info.source)
				logn("\t", message)
			end)

			gl.DebugMessageCallback(callback, nil)
		else
			gl.Disable("GL_DEBUG_OUTPUT")
			render.verbose_debug = false
		end
	else
		llog("glDebugMessageControl is not availible")
	end
end

function render.StartDebug()
	if EXTERNAL_DEBUGGER then return end
	if render.verbose_debug then return end

	render.EnableVerboseDebug(true)
end

function render.StopDebug()
	if EXTERNAL_DEBUGGER then return end
	if render.verbose_debug then return end

	render.EnableVerboseDebug(false)
end