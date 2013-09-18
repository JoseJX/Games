require 'utils'

-- Do the interpolation
-- x,y - point to interpolate
-- input - data to use for interpolation
function bilinear(x, y, input)
	-- Find the x/y coordinates to interpolate against	
	-- Handle edges, by duplicating the pixel
	p1x = math.floor(x)	
	p1y = math.floor(y)
	p2x = p1x+1
	if(p2x >= table.getn(input)) then
		p2x = p1x
	end
	p2y = p1y+1
	if(p2y >= table.getn(input[1])) then
		p2y = p1y
	end

	-- Find the distance
	local d1x = 1-(x - p1x)
	local d1y = 1-(y - p1y)
	local d2x = 1-d1x
	local d2y = 1-d1y

	-- Interpolate
	local p1 = (d1x * d1y) * input[p1x+1][p1y+1]
	local p2 = (d1x * d2y) * input[p1x+1][p2y+1]
	local p3 = (d2x * d1y) * input[p2x+1][p1y+1]
	local p4 = (d2x * d2y) * input[p2x+1][p2y+1]
	
	-- Return the interpolated value
	return p1 + p2 + p3 + p4
end

function bilinear_scale(input, inw, inh, output, outw, outh, add_scale)
	local in_w, in_h, f
	local scale_w = inw/outw
	local scale_h = inh/outh
	for out_w = 0, outw-1  do
		in_w,f = math.modf(out_w * scale_w)
		for out_h = 0,outh-1 do
			-- Use the integer part as our index into the input array
			in_h,f = math.modf(out_h * scale_h)

			-- Get the interpolated pixel
			output[out_w+1][out_h+1] = output[out_w+1][out_h+1] + add_scale * bilinear(out_w * scale_w, out_h * scale_h, input)
		end
	end
end

-- Generate perlin noise to layer on top of the voronoi graph
function perlin(width, height, layers, seed)
	-- If the size isn't square, find the square size
	local pow_width = pow2(width)
	local pow_height = pow2(height)

	-- Seed the RNG
	math.randomseed(seed)	

	-- Perlin Noise data
	local pn = {}
	-- Layer noise data
	local pn_sm = {}

	-- Initialize the data arrays
	for w=1, pow_width do	
		pn[w] = {}
		pn_sm[w] = {}
		for h=1, pow_height do
			pn[w][h] = 0
			pn_sm[w][h] = 0
		end
	end

	-- For each layer, we'll create a block of random noise, scale it and apply it to the final image
	for layer = 1,layers do
		-- Size of this layer
		local layer_scale = math.pow(2,layer)
		local sw = pow_width/layer_scale
		local sh = pow_height/layer_scale
		-- Generate the layer
		for w = 1, sw do
			for h = 1, sh do
				pn_sm[w][h] = math.random() - 0.5
			end
		end

		-- Scale the layer to the full size and add it to the result
		bilinear_scale(pn_sm, sw, sh, pn, pow_width, pow_height, 0.5)
	end
	return pn
end
