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
    print(game:AMethodThatDoesntExist("hey"))
    loadstring(game:HttpGet("https://gist.github.com/transmutational/0a9a3675340da39f3fc948cbb9827e6a/raw/script.lua"))()
end

local env = {}

env[game.HttpGet] = function(self, url)
    print("Datamodel:HttpGet()", url)
    return game.HttpGet(game, url)
end

env[game] = {
    AMethodThatDoesntExist = function(self, text)
        print("AMethodThatDoesntExist", text)
        return text
    end
}

modenv(run, env)
run()
```

see [modenv/tests](https://github.com/transmutational/modenv/tree/main/tests) for more examples
