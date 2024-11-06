function run()
	local t = {1, 2, 3}

	-- redirected/hooked method :3
	print(table.insert(t, 4))
end

local env = {
	[table.insert] = function(t, v)
		print("table.insert hook :3", t, v)
		return table.insert(t, v)
	end
}

modenv(run, env)
run()
