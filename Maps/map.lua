require 'utils'
require 'perlin'
local Voronoi = require 'voronoi'
local Polygon = require 'polygon'
local Point = require 'point'

-- Map in 2D Space
local Map = {}
Map.__index = Map

function Map:new(width, height, map_type)
	-- Make the object
	local obj = { 
		cname = "Map",
		width = width,
		height = height,
		map_border = nil,
		map_type = map_type,
		voronoi = nil,
	}

	-- Create the border poly
	obj.map_border = Polygon:new({0,0, width,0, width,height, 0,height})

	-- If we're passed a map make a copy
	if (type(width) == "table") then
		if(width.cname == "Map") then

		end
	end

	return setmetatable(obj, Map)
end

-- Create a new map
function Map:generate(seed) 
	-- Pangea is one large continent
	if self.map_type == "Pangea" then
		print ('Creating Pangea map.')
		-- Generate perlin noise for hight
		-- Also seeds the RNG
		print ('Generating perlin noise.')
		pn = perlin(256,256,7, seed)

		-- Create map points
		print ('Finding map points.')
		local points = {}
		for i=1,self.width*self.height*0.0005 do
			table.insert(points, Point:new(math.random(0, self.width), math.random(0, self.height)))
		end

		print ('Creating cells.')
		-- Create a new voronoi diagram
		self.voronoi = Voronoi:new(self.map_border, points)
	
		-- Relax the diagram
		print ('Lloyd relaxation.')
		m.voronoi:normalize(2)
		
		-- Color the cells based on the cell height from perlin noise
		for i=1,#self.voronoi.cells do
			local c = self.voronoi.cells[i]
			-- Find the scale factor
			local sw = table.getn(pn) / self.width
			local sh = table.getn(pn[1]) / self.height

			-- Get the coordinates for the center	
			local cx = c.point.x * sw
			local cy = c.point.y * sh

			-- Get the height of this point
			c.height = bilinear(cx, cy, pn)

			-- Set the color
			self:color_cell(c)
		end
	elseif self.map_type == "Continents" then
		print ('Creating continents')
	elseif self.map_type == "Islands" then
		print ('Creating islnds')

	end
end

-- Get the color for a map cell
function Map:color_cell(cell)
	local color = cell.height * 255
	if(color > 0) then
		color = color + 64
	end
	if(color > 255) then
		color = 255
	end
	if(color < -192) then
		color = -192
	end
	
	-- Set the fill color
	if(color > 0) then
		cell.fill_color = { 0, color, 0, 255 }
	else
		cell.fill_color = { 0, 0, 255+color, 255 }
	end
end

-- Draw this map on the screen
function Map:draw()
	self.voronoi:draw()
end

return Map
