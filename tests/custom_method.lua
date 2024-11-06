function run()
	local t = {1, 2, 3}

  -- custom method
	assert(table.newinsert(t, {4, 5, 6}) == 3, "table.newinsert")

	print(table.concat(t, ", "))
end

local env = {
	[table] = {
		newinsert = function(t1, t2)
			local c = 0
			for _, v in t2 do
				table.insert(t1, v)
				c += 1
			end
			return c
		end,
	}
}

modenv(run, env)
run()
