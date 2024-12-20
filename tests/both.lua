function run()
	local t1 = {1, 2, 3}
	print(#t1, table.getn(t1))
	print(table.AMethodThatDoesntExist(t1))
end

local env = {}

env[table.getn] = function(t)
	print("Returning fake length :3", t)
	return -1
end

env[table] = {
	AMethodThatDoesntExist = function()
		return "hewwo from a custom method~!"
	end
}

modenv(run, env)
run()
