function modenv(func, env)
	local fenv = getfenv()
	local lookup = {}

	local function addlookup(object, real)
		if real and type(real) == "userdata" then
			lookup[object] = real
		end
	end

	local function findby(key, index, _env)
		if _env == nil then _env = env end
		for i, v in pairs(_env) do
			if i == index or i == key then
				return v
			end
		end
		return nil
	end

	local function smallenv(self, dbg, env)
		return setmetatable({}, {__index = function(_self, i)
			local item = self[i]
			local modded = findby(item, i, env) or findby(item, i)

			if modded ~= nil then
				print("return modded")
				addlookup(modded, item)
				return modded
			end

			if type(item) == "userdata" or type(item) == "table" then
				print("return small")
				local small = smallenv(item, i)
				addlookup(small, item)
				return small
			end

			---- support for namecall methods (i.e. game:GetService())
			if type(item) == "function" and type(self) == "Instance" then
				print("return wrapper")
				local function wrapper(...)
					local value = item(self, select(2, unpack({...})))
					if findby(value) and type(value) == "userdata" then
						return smallenv(value, i, findby(value))
					end
					if type(value) == "userdata" or type(value) == "table" then
						local small = smallenv(value, i)
						addlookup(small, value)
						return small
					end
					return value
				end
				return wrapper
			end

			return self[i]
		end,
		__newindex = function(_self, i, v)
			self[i] = v
			return
		end,
		__tostring = function(_self)
			return tostring(self)
		end,
		__eq = function(_self, object)
			return rawequal(self, object)
		end,
		})
	end

	local function splitenv(self, mod, dbg)
		return setmetatable({}, {__index = function(_self, i)
			local exists, item = pcall(function() return self[i] end)
			local modded = mod[i] or (exists and env[item] or nil)

			if (type(item) == "userdata" or type(item) == "table") and modded then
				local split = splitenv(item, modded, dbg .. "/" .. i)
				addlookup(split, item)
				return split
			end

			if modded ~= nil then
				addlookup(modded, item)
				return modded
			end

			---- support for namecall methods (i.e. game:GetService())
			if type(item) == "function" and type(self) == "Instance" then
				local function wrapper(...)
					local value = item(self, select(2, unpack({...})))
					if findby(value) then
						return findby(value)
					end
					if type(value) == "userdata" or type(value) == "table" then
						local small = smallenv(value, i)
						addlookup(small, value)
						return small
					end
					return value
				end
				return wrapper
			end

			return self[i]
		end,
		__newindex = function(_self, i, v)
			self[i] = v
			return
		end,
		__tostring = function(_self)
			return tostring(self)
		end,
		__eq = function(_self, object)
			return rawequal(self, object)
		end,
		})
	end

	local newenv = setmetatable({}, {__index = function(self, i)
		local item = fenv[i]
		local modded = findby(item)

		if (modded ~= nil) then
			if type(modded) == "userdata" or type(modded) == "table" then
				local split = splitenv(item, modded, i)
				addlookup(split, item)
				return split
			end
			addlookup(modded, item)
			return modded
		end
		
		if type(item) == "userdata" or type(item) == "table" then
			local small = smallenv(item, i)
			addlookup(small, item)
			return small
		end

		return item
	end,
	__newindex = function(self, i, v)
		fenv[i] = v
		return
	end,
	__eq = function(self, object)
		return rawequal(self, object)
	end,})

	local oloadstring = fenv.loadstring
	local ogetmetatable = fenv.getmetatable
	local osetmetatable = fenv.setmetatable
	local otype = fenv.type
	local otypeof = fenv.typeof
	local orawequal = fenv.rawequal
	local orawget = fenv.rawget
	local orawlen = fenv.rawlen
	local orawset = fenv.rawset
	local ogetfenv = fenv.getfenv

	newenv.loadstring = function(chunk, chunkname)
		local loadfunc = oloadstring(chunk, chunkname)

		if loadfunc then
			setfenv(loadfunc, getfenv(func))
		end

		return loadfunc
	end
	newenv.getmetatable = function(object)
		return ogetmetatable(lookup[object] or object)
	end
	newenv.setmetatable = function(t, newMeta)
		return osetmetatable(lookup[t] or t, newMeta)
	end
	newenv.type = function(object)
		if lookup[object] ~= nil then
			return "userdata"
		end
		return otype(object)
	end
	if otypeof ~= nil then
		newenv.typeof = function(object)
			if lookup[object] ~= nil then
				return "Instance"
			end
			return otypeof(object)
		end
	end
	newenv.rawequal = function(v1, v2)
		return orawequal(lookup[v1] or v1, lookup[v2] or v2)
	end
	newenv.rawget = function(t, index)
		return orawget(lookup[t] or t, index)
	end
	newenv.rawlen = function(t)
		return orawlen(lookup[t] or t)
	end
	newenv.rawset = function(t, index, value)
		return orawset(lookup[t] or t, index, value)
	end
	newenv.getfenv = function()
		return newenv
	end

	setfenv(func, newenv)
end
