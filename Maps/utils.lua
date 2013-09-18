-- Utility functions
function string:split(d, p)
	local t, ll
	t = {}
	ll = 0
	if(#p == 1) then return {p} end
	while true do
		-- Find the next delimiter
		l = string.find(p,d,ll,true)
		-- Found one, save it
		if l ~= nul then
			table.insert(t, string.sub(p, ll, l-1))
			ll = l + 1
		-- Save whatever's left
		else
			table.insert(t, string.sub(p, ll))
			break
		end
	end
	return t
end

-- Get a slice of a table
function slice(table, idx_start, idx_end)
	local result = {}
	if idx_end == nil then
		idx_end = #table
	end

	for i=idx_start,idx_end do
		table.insert(result, table[i])
	end
	return result
end

-- Get the next power of two
function pow2(val)
	local pow = math.log(val)/math.log(2)
	local i,f = math.modf(pow)
	-- If this is already a power of two return that
	if(f == 0) then
		i = i - 1
	end
	return math.pow(2, i+1)
end

-- Constant for distance tolerance for float unreliability
DISTANCE_TOLERANCE = 0.0001
