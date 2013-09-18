local Segment = require 'segment'
local Polygon = require 'polygon'
local Point = require 'point'
local Cell = require 'cell'
require 'hsl'
require 'utils'

-- Voronoi diagram class
local Voronoi = {}
Voronoi.__index = Voronoi

-- Initialized with the initial points and boundary of the Voronoi diagram area
function Voronoi:new(boundary, points)
	local obj = { 
		cname = "Voronoi",
		boundary = nil,
		cells = {},

		-- Debug
		bisectors = nil,
	}
	local self = setmetatable(obj, Voronoi)
	

	-- Make sure the boundary is a convex hull
	self.boundary = boundary:convex_hull()
	
	-- Add the points
	if type(points) == "table" then
		for p=1,#points do
			self:add_cell(points[p])
		end
	end

	return self
end

-- Reset removes all cells in the Voronoi diagram
function Voronoi:reset(boundary)
	self.cells = {}
	self.boundary = boundary:convex_hull()
end

-- Add a new cell to the Voronoi diagram, centered at the point given
function Voronoi:add_cell(p)
	-- Check if this point is too close to existing points...
	for i=1,#self.cells do
		if p:distance(self.cells[i].point) < DISTANCE_TOLERANCE then
			return
		end
	end

	-- If this is the first cell, we only set up the boundary
	if #self.cells == 0 then
		-- Create a new cell
		local c = Cell:new(p, self.boundary)

		-- Add to the cell list
		table.insert(self.cells, c)
		return
	end

	-- This represents the new polygons from the cell division process
	local new_polys = {}
	-- Keep track of the bisectors
	bisectors = {}
	-- Loop over all of the new cells
	for i=1,#self.cells do
		-- Find the bisector between this cell and the new point
		bisectors[i] = Segment:new(self.cells[i].point:bisect(p))
		-- See if the bisector intersects with any of the cell's boundaries
		for j=1,#self.cells[i].subcells do
			-- It does, split it!
			if self.cells[i].subcells[j]:does_split(bisectors[i]) == true then
				new_polys[i] = self.cells[i].subcells[j]:split(bisectors[i])
			end
		end

	end

	-- Associate the new cells with the appropriate cell
	local added_cell_polys = {}
	local center, centroid, bside, pside
	for i,ps in pairs(new_polys) do
		-- Find which side of the bisector the cell center is on
		center = self.cells[i].point
		bside = bisectors[i]:side_of(center)
		-- Now, check each subcell against the bisector
		for j=1,#ps do
			centroid = ps[j]:centroid()	
			pside = bisectors[i]:side_of(centroid)
			-- If the centroid is on the same side, the part belongs to cell[i]
			if (pside == bside) then
				self.cells[i] = Cell:new(self.cells[i].point, ps[j])
			-- Otherwise, it's part of the new cell
			else
				table.insert(added_cell_polys, ps[j])
			end
		end
	end

	-- Create the new cell
	local c = Cell:new(p, added_cell_polys[1])
	
	-- Add all of the polygons to the new cell
	for i=2,#added_cell_polys do
		c:add_subcell(added_cell_polys[i])
	end

	-- Simplify the new cell to a single poly
	c:consolidate()

	-- Add the new cell
	table.insert(self.cells, c)
	return
end

-- Normalize the size of the voronoi cells (Lloyd relaxation)
function Voronoi:normalize(iterations)
	-- Iterations is optional!
	if iterations == nil then
		interations = 1
	end

	-- Array to hold the new points
	local points = {}	

	-- Find the centroid of each cell
	for i=1,#self.cells do
		table.insert(points, self.cells[i]:centroid())
	end

	-- Reset the voronoi diagram and insert the new points
	self:reset(self.boundary)
	for i=1,#points do
		self:add_cell(points[i])
	end


end

-- Remove a cell from the voronoi diagram
function Voronoi:remove(c)
	print ("FIXME: Remove cell")
end

-- Get the cell that contains a point
function Voronoi:contains(x, y)
	local pt = x
	if (type(x) == "number") then
		pt = Point:new(x, y)
	end

	for i=1,#self.cells do
		if not (self.cells[i].boundary == nil) then
			if self.cells[i].boundary:inside(pt) then
				return self.cells[i]	
			end
		end
	end
	return nil
end

-- Draw the shapes in the voronoi map
function Voronoi:draw()
	-- Draw the polys
	for i=1,#self.cells do
		self.cells[i]:draw()
	
		-- Draw the points for debugging
--		lg.setColor(0,0,0,255)
--		lg.circle('fill', self.cells[i].point.x, self.cells[i].point.y, 3)
--		lg.setColor(255,255,255,255)
--		lg.circle('fill', self.cells[i].point.x, self.cells[i].point.y, 2)
	end
end

return Voronoi
