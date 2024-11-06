function run()
	local httpService = game:GetService("HttpService")
	
	while true do
		print("HttpEnabled: ", httpService.HttpEnabled)
		print("https://example.com/:", httpService:GetAsync("https://example.com/"):sub(0, 20) .. "...")
		
		wait(1)
	end
end

local env = {}
local hooks = {}

function hookfunction(old, new): any
	assert(old, "hookfunction: old must have a value (old is nil/falsey)")

	env[old] = new
	hooks[old] = true
	return old
end

function restorefunction(old)
	assert(old, "restorefunction: old must have a value (old is nil/falsey)")

	env[old] = nil
	hooks[old] = nil
end

function isfunctionhooked(old): boolean
	return hooks[old] ~= nil
end

local httpService = game:GetService("HttpService")





---- DO use hookfunction like this if you want to hook a method

---- benefits:
----   • any reference to the GetAsync method will be replaced with a reference to modenv wrapper
----      - this means that HttpService:GetAsync("https://example.com/") and...
----      - HttpService.GetAsync(HttpService, "https://example.com/") are both the same.
local oldGetAsync;
oldGetAsync = hookfunction(httpService.GetAsync, function(self, url, nocache, headers)
	if url == "https://example.com/" then
		return "<html><head></head><body><p>This is not the real dom, obviously.</p></body></html>"
	end
	return oldGetAsync(self, url, nocache, headers)
end)
---- equivalent code:
----env[httpService.GetAsync] = function(self, url, nocache, headers)
----	return httpService.GetAsync(self, url, nocache, headers)
----end





---- DO use modenv like this if you want to hook a property

---- benefits:
----   • any reference to httpService will be replaced with a reference to modenv
----      - this means that game.HttpService, game:service("HttpService"), etc...
----      - is supported and will always end up being a reference to modenv.

----   • any reference to a property or method will be redirected to your indexes
----      - this value is updatable at all times, but you will need to make...
----      - your own method to modify the value in this table.
env[httpService] = {
	HttpEnabled = true
}

modenv(run, env)
coroutine.wrap(run)()

coroutine.wrap(function()
	task.wait(5)
	warn("---- restorefunction(game.HttpService.GetAsync)")
	restorefunction(httpService.GetAsync)
	---- equivalent code:
	----env[httpService.GetAsync] = nil
end)()
coroutine.wrap(function()
	while wait(0.5) do
		print("---- isfunctionhooked(game.HttpService.GetAsync): " .. tostring(isfunctionhooked(httpService.GetAsync)))
	end
end)()
