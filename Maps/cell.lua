local Point = require 'point'
local Polygon = require 'polygon'

-- A cell is composed of multiple subcells
local Cell = {}
Cell.__index = Cell

function Cell:new(x, y, boundary)
	local obj = { 
		cname = "Cell",
		-- Subcells that make up this cell (must be polys)
		subcells = {},
		-- Boundary of this cell
		boundary = nil,
		-- Whether this cell's subcells have been consolidated into one subcell
		-- Boundary is only valid if this is true
		consolidated = true,
		-- Location of the center of this cell
		point = nil,

		-- Color to render the cell with
		fill_color = { 0,0,0,255 },
		-- Color of the border of the cell
		border_color = { 255,255,255,255 },


	}
	-- Assume we were given a point
	obj.point = x
	obj.boundary = y
	-- Check if we were actually given a number
	if type(x) == "number" then
		obj.point = Point:new(x,y)
		obj.boundary = boundary
	-- If we were given another cell, do a direct copy
	elseif type(x) == "table" then
		if x.cname == "Cell" then
			obj.point = Point:new(x.point)
			-- Force a simplification
			x:consolidate()
			obj.boundary = Polygon:new(x.boundary)
		end
	
	end

	-- There is, by default, a single subcell
	table.insert(obj.subcells, obj.boundary)

	return setmetatable(obj, Cell)
end

-- Print information about a cell
function Cell:print()
	print("Cell center:")
	self.point:print()
	print("Cell boundary:")
	self.boundary:pprint()
	if self.consolidated == true then
		print("Cell consolidated: True")
	else
		print ("Cell consolidated: False")
	end
	print("Number of subcells: "..#self.subcells)
	for i=1,#self.subcells do
		print ("Subcell #",i)
		self.subcells[i]:pprint()
	end
end

-- Find the centroid for the cell
function Cell:centroid()
	if self.consolidated == true then
		return self.boundary:centroid()
	else
		local csum_x = 0
		local csum_y = 0
		for i=1,#self.subcells do
			local c = self.subcells[i]:centroid()
			csum_x = csum_x + c.x
			csum_y = csum_y + c.y
		end
		return Point:new(csum_x / #self.subcells, csum_y / #self.subcells)
	end
end

-- Move the cell
function Cell:move(dx, dy)
	self.point:move(dx, dy)	
	self.boundary:move(dx, dy)
	for i=1,#self.subcells do
		self.subcells[i]:move(dx, dy)
	end
end

-- Add a subcell
function Cell:add_subcell(p)
	table.insert(self.subcells, p)
	self.consolidated = false
end

-- Remove a subcell
function Cell:remove_subcell(p)
	local poly_id = p
	if not(type(p) == "number") then
		for i=1,#self.subcells do
			if p == self.subcells[i] then
				poly_id = i
				break
			end
		end
	end
	self.consolidated = false
	table.remove(self.subcells, poly_id)
end

-- Consolidate the subcells
function Cell:consolidate()
	-- Make sure there's something to do...
	if self.consolidated == true or #self.subcells <= 1 then
		self.consolidated = true
		return
	end

	-- Collect all of the subcell boundaries 
	local point_list = {}
	for i=1,#self.subcells do
		for j=1,#self.subcells[i].points do
			table.insert(point_list, self.subcells[i].points[j])
		end
	end

	-- Make a new polygon with ALL of these points
	local temp_poly = Polygon:new(point_list)

	-- Find the convex hull that surrounds these points
	self.boundary = temp_poly:convex_hull()
	self.subcells = { self.boundary }
	consolidated = true
end

-- Draw this cell on the screen
function Cell:draw()
	for i=1,#self.subcells do
		self.subcells[i]:draw(self.border_color, self.fill_color)
	end
end

return Cell
