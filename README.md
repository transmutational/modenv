# modenv
very detectable instrumentation but a method that works like hookfunction nevertheless<br>

 ✔ **Supports Property Hooking (Creating New Properties)**<br>
 ✔ **Supports Method Hooking (Creating New Methods)**<br>
 ✔ **Supports Roblox/Luau (Scripts And Executor)**<br>
 ✔ **Supports Loadstring (Maintains Modded Environment)**<br>
 ✔ **Supports Lua**

## usage
```lua
-- paste modenv source above

function run()
	warn("game.Workspace:", game.Workspace)
	warn("game:FindFirstChild(\"Workspace\"):", game:FindFirstChild("Workspace"))
	print("game:AMethodThatDoesntExist()", game:AMethodThatDoesntExist())
	print("game:GetService(\"Players\"):", game:GetService("Players"))
	
	-- works in executors
	--print(loadstring(game:HttpGet("https://gist.github.com/transmutational/0a9a3675340da39f3fc948cbb9827e6a/raw/script.lua"))())
end

local env = {}

-- works in executors
--env[game.HttpGet] = function(self, ...)
--	print("DataModel:HttpGet()", ...)
--	return game.HttpGet(self, ...)
--end

env[game.GetService] = function(self, srv)
	warn("Returning fake service :3", srv)
	return workspace
end

env[game] = {
	AMethodThatDoesntExist = function(self)
		return "hewwo from a custom method~!"
	end
}

modenv(run, env)
run()
```

see [modenv/tests](https://github.com/transmutational/modenv/tree/main/tests) for more examples
