require 'utils'
local Point = require 'point'
local Segment = require 'segment'

-- Polygon class
local Polygon = {}
Polygon.__index = Polygon

function Polygon:new(pts_obj)
	local obj = { 
		cname = "Polygon",
		-- A polygon is made of points, which are joined by segments
		points = {},
		segments = {},
	}
	local self = setmetatable(obj, Polygon)

	-- See if we're initialized with anything
	if(type(pts_obj) == "table") then
		-- Generate the polygon if we're initialized by a flat list of x,y values
		if (not (pts_obj[1] == nil)) and (type(pts_obj[1]) == "number") then
			if not (#pts_obj % 2 == 0) then
				print("Must be initialized by an even number of values")
				return nil
			end
			-- Generate points and add them
			for i=1,#pts_obj,2 do
				self:add_point(pts_obj[i], pts_obj[i+1])	
			end
		-- Generate the polygon if we're initialized by a list of points
		elseif (not (pts_obj[1] == nil)) and (pts_obj[1].cname == "Point") then
			for i=1,#pts_obj do
				self:add_point(pts_obj[i])
			end
		-- We can also be initialized by another polygon, make a direct copy
		elseif (pts_obj.cname == "Polygon") then
			for i=1,#pts_obj.points do
				self:add_point(Point:new(pts_obj.points[i]))
			end
		else
			print("Unknown initializer type!")
			return nil
		end
	end
	return self
end

-- Check if polygon is equal to another polygon
function Polygon:__eq(p)
	-- First, make sure we have the same number of points
	if not (#self.points == #p.points) then
		return false
	end

	-- Now compare them all
	for i=1,#self.points do
		if not (self.points[i] == p.points[i]) then
			return false
		end
	end

	return true
end

-- Print all points in a polygon
function Polygon:pprint()
	for p=1,#self.points do
		self.points[p]:print()
	end
end
function Polygon:sprint()
	for s=1,#self.segments do
		self.segments[s]:print()
	end
end
function Polygon:print()
	self:pprint()
	self:sprint()
end

-- Translate the polygon by dx,dy
function Polygon:move(dx, dy)
	for p=1,#self.points do
		self.points[p]:move(dx, dy)
	end
end

-- Add a point
function Polygon:add_point(x, y, pos)
	local p
	-- Check type to see how to add the point
	if (type(x) == "number") then
		p = Point:new(x, y)

		-- Check to make sure this point doesn't already exist
		for i=1,#self.points do
			if p == self.points[i] then
				-- No need to insert the point
				return
			end
		end

		-- Add the point
		if pos == nil then
			table.insert(self.points, p)
		else
			table.insert(self.points, pos, p)
		end
	elseif (type(x) == "table") then
		if x.cname == "Point" then
			p = x
			-- Check to make sure this point doesn't already exist
			for i=1,#self.points do
				if p == self.points[i] then
					-- No need to insert the point
					return
				end
			end

			-- Add the point
			if pos == nil then
				table.insert(self.points, p)
			else
				table.insert(self.points, pos, p)
			end
		else
			print ("Invalid input type: " .. x.cname)
			return
		end
	else
		print ("Invalid input type: " .. type(x))
		return
	end

	-- The point has been added, add the segment corresponding to this point
	-- We need to remove the previous segment first
	if #self.points > 3 then
		-- Replace the previous closing segment
		self.segments[#self.segments] = Segment:new(self.points[#self.points-1], p)
	-- Otherwise, we can just add this segment
	elseif (#self.points > 1) then
		table.insert(self.segments, Segment:new(self.points[#self.points-1], p))
	end
	-- See if we need to close the polygon
	if #self.points >= 3 then
		table.insert(self.segments, Segment:new(p, self.points[1]))	
	end
	return
end

-- Get a point id for an X,Y pair or from another point
function Polygon:get_point_id(x, y)
	local pt = x
	if (type(pt) == "number") then
		pt = Point:new(x,y)
	end
		
	for p=1,#self.points do
		if self.points[p] == pt then
			return p
		end
	end
	return nil
end

-- Delete a point, ignored if the point doesn't exist
function Polygon:del_point(x, y)
	local p = self:get_point_id(x,y)
	-- Check that it's there!
	if p == nil then
		return
	end
	-- Get a reference to the point
	local pt = self.points[p]
	
	-- Remove the point from the global point list
	table.remove(self.points, p)

	-- If there's only one segment, just reset the segment list
	if(#self.segments <= 1) then
		self.segments = {}
		return
	end

	-- Find the segments that contain this point
	local start_seg = nil
	local end_seg = nil
	for s=1,#self.segments do
		if (self.segments[s]:point_eq(pt)) then
			if start_seg == nil then
				start_seg = s
			else
				end_seg = s
				break
			end
		end
	end

	-- Okay we've got the segments, remove the second and replace p2 in the first
	self.segments[start_seg].p2 = self.segments[end_seg].p2
	table.remove(self.segments, end_seg)
	return
end

-- Generate a polygon with the bounding box for this polygon
function Polygon:get_box()
	local x = {}
	local y = {}
	-- Find the min/max X,Y
	for p=1,#self.points do
		table.insert(x, self.points[p].x)
		table.insert(y, self.points[p].y)
	end

	local minx = math.min(x)
	local miny = math.min(y)
	local maxx = math.max(x)
	local maxy = math.max(y)

	local box = Polygon:new(Point:new(minx, miny), Point:new(minx, maxy), Point:new(maxx, miny), Point:new(maxx, maxy))
	return box	
end

-- Find the centroid of the polygon
function Polygon:centroid()
	local x = 0
	local y = 0
	
	-- Make sure we have a center!
	if #self.points < 1 then
		return nil
	end

	-- Find the centroid
	for p=1,#self.points do
		x = x + self.points[p].x
		y = y + self.points[p].y
	end

	x = x/#self.points
	y = y/#self.points
	return Point:new(x,y)
end

-- Find if a coordinate set is inside the polygon
-- Implementation of PNPOLY
function Polygon:inside(x, y)
	local pt = x
	if type(x) == "number" then
		pt = Point:new(x, y)
	end
	local inside = false

	local j = #self.points
	for i=1,#self.points do
		if not ((self.points[i].y > pt.y) == (self.points[j].y > pt.y)) then
			if((pt.x < (self.points[j].x - self.points[i].x) * (pt.y - self.points[i].y) / (self.points[j].y - self.points[i].y) + self.points[i].x)) then
				inside = not(inside)	
			end
		end
		j = i
	end
	return inside
end

-- Find if a polygon is splittable by segment s
function Polygon:does_split(p1, p2)
	local s = p1
	-- If the input is a point, then make a segment, otherwise we assume it's a segment
	if s.cname == "Point" then
		s = Segment:new(p1, p2)
	end

	local intersections = 0	
	-- Check all of the segments
	for i=1,#self.segments do
		if ((s.p1 == self.points[i]) or (s.p2 == self.points[i])) then
			intersections = intersections + 1
		elseif (s:intersect(self.segments[i], true) == true) then
			intersections = intersections + 1	
		end
	end
	-- Check the last point
	if(s.p1 == self.points[#self.points]) or (s.p2 == self.points[#self.points]) then
		intersections = intersections + 1
	end
	
	if (intersections >= 2) then
		return true
	end
	return false
end

function Polygon:split(s)
	local p1_pts = {}
	local p2_pts = {}
	local intersected_points = 0

	-- Loop over all of the points to find the segments that intersect
	for i=1,#self.points do
		-- See if this segment intersects with the polygon segment
		if (s:intersect(self.segments[i], true) == true) then
			-- Add the first point to the appropriate polygon
			if (intersected_points%2 == 0) then
				table.insert(p1_pts, self.segments[i].p1)
			else
				table.insert(p2_pts, self.segments[i].p1)
			end

			-- Get the intersection point
			local int_pt = s:intersect_point(self.segments[i])
			-- This point now goes into both polygons
			table.insert(p1_pts, int_pt)
			table.insert(p2_pts, int_pt)
			intersected_points = intersected_points + 1
		-- Otherwise, add to the current polygon
		else
			-- We have an odd # of intersections, we're in the split poly
			if (intersected_points%2 == 1) then
				table.insert(p2_pts, self.points[i])
			else
				table.insert(p1_pts, self.points[i])
			end
		end

	end
	
	-- Create a deep copy of the points
	local poly1 = {}
	for i=1,#p1_pts do
		table.insert(poly1, Point:new(p1_pts[i]))
	end
	local poly2 = {}
	for i=1,#p2_pts do
		table.insert(poly2, Point:new(p2_pts[i]))
	end

	-- Make two new polygons from the points
	local polygon_set = { Polygon:new(poly1), Polygon:new(poly2) }
	return polygon_set
end

-- Draw the polygon, relative to the x,y coordinates
-- We assume the points are in the right order...
function Polygon:draw(border_color, fill_color)
	local points = {}

	-- Prepare the points
	for p=1,#self.points do
		table.insert(points, self.points[p].x)
		table.insert(points, self.points[p].y)
	end

	-- Draw a polygon
	if #self.points >= 3 then
		if type(fill_color) == "table" then
			lg.setColor(unpack(fill_color))
			lg.polygon('fill', points)
		end
		lg.setColor(unpack(border_color))
		lg.polygon('line', points)
	-- Draw a line
	elseif #self.points == 2 then
		lg.setColor(unpack(border_color))
		lg.line(points)	
	-- Draw a point
	elseif #self.points == 1 then
		lg.setColor(unpack(border_color))
		lg.point(points[1], points[2])
	end
end

-- Get the convex hull of the polygon
-- Using a gift wrapping algorithm -- optimize?
function Polygon:convex_hull()
	local hull_pts = {}
	-- For cases where the polygon has < 3 points, we don't need to generate a hull
	if (#self.points < 4) then
		-- Make a new polygon with all of the existing points
		for i=1,#self.points do
			table.insert(hull_pts, Point:new(self.points[i]))
		end
		return Polygon:new(hull_pts)
	end

	-- Find the lower rightmost point out of all of the points in the polygon
	-- We know this must be on the hull
	local point_on_hull = self.points[1]	
	for i=2,#self.points do
		if (self.points[i].y > point_on_hull.y) then
			point_on_hull = self.points[i]
		elseif (self.points[i].y == point_on_hull.y) then
			if (self.points[i].x > point_on_hull.x) then
				point_on_hull = self.points[i]
			end
		end
	end

	-- Now we find the rest of the points on the hull
	-- Similar to wrapping a string around it
	local i=1
	local endpoint, tseg
	repeat
		local collinear = {}
		table.insert(hull_pts, Point:new(point_on_hull))
		-- Initial endpoint for a candidate edge on the hull
		endpoint = self.points[1]

		-- Generate the segment to test against
		tseg = Segment:new(point_on_hull, endpoint)
		for j=1,#self.points do
			if not (self.points[j] == endpoint) then
				local side = tseg:side_of(self.points[j])
				-- If the point is to the right of the line, it's further out
				if (endpoint == point_on_hull) or (side == "right") then
					-- Found a point that's further out
					endpoint = self.points[j]
					tseg = Segment:new(point_on_hull, endpoint)
				elseif (side == "neither") then
					collinear[j] = self.points[j]
				end
			end
		end

		-- Okay, now check the collinear ones
		local d1 = 0
		local d2
		for j,v in pairs(collinear) do
			if tseg:side_of(v) == "neither" then
				d2 = point_on_hull:distance(v)
				if(d2 > d1) then
					d1 = d2
					endpoint = v
					tseg = Segment:new(point_on_hull, v)
				end
			end
		end

		i = i + 1
		point_on_hull = endpoint
	-- Loop until we've wrapped around to the first hull point
	until (endpoint == hull_pts[1]) or (i > #self.points)

	-- Create a new polygon with the hull's points
	local p = Polygon:new(hull_pts)	
	return p
end

return Polygon
