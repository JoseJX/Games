local Point = require 'point'

-- Segment in 2D Space
local Segment = {}
Segment.__index = Segment

function Segment:new(p1, p2, x2, y2)
	local obj = { 
		cname = "Segment",
		p1 = nil,
		p2 = nil,
	}
	-- Created with numbers, four values indicating two points
	if(type(p1) == "number") then
		obj.p1 = Point:new(p1,p2)
		obj.p2 = Point:new(x2,y2)
	-- If we were passed two points, then just use them directly
	elseif(p1.cname == "Point") then
		obj.p1 = p1
		obj.p2 = p2
	end

	return setmetatable(obj, Segment)
end

-- Check if this segment matches another segment/line
-- NOTE: Semgent/Line must go in the same direction to match
function Segment:__eq(obj)
	if (self.p1 == obj.p1) and (self.p2 == obj.p2) then
		return true
	end
	return false
end

-- Check if a point is one of the points for this segment
function Segment:point_eq(x,y)
	local pt = x	
	if (type(x) == "number") then
		pt = Point:new(x, y)
	end
	if (self.p1 == pt) or (self.p2 == pt) then
		return true
	end
	return false
end

-- Move the segment by dx, dy
function Segment:move(dx, dy)
	p1:move(dx, dy)
	p2:move(dx, dy)
end

-- Get the length of this segment
function Segment:length()
	return math.sqrt(math.pow(self.p2.x - self.p1.x,2) + math.pow(self.p2.y - self.p1.y,2))
end

-- Get the slope of this segment
function Segment:slope()
	-- Check for 0
	if (self.p2.x == self.p1.x) then
		return math.huge
	end
	return ((self.p2.y - self.p1.y) / (self.p2.x - self.p1.x))
end

-- Find which side of the segment x,y lies on
function Segment:side_of(x, y)
	local pt = x
	if (type(x) == "number") then
		pt = Point:new(x, y)
	end

	-- Check any of the points are the same first...
	if (self.p1 == self.p2) or (self.p1 == pt) or (self.p2 == pt) then
		return "neither"
	end

	-- See if they're all collinear
	if (self.p1.x == pt.x) and (self.p1.x == self.p2.x)  then
		return "neither"
	elseif (self.p1.y == pt.y) and (self.p1.y == self.p2.y)  then
		return "neither"
	end

	-- Find the determinent
	local area = 0.5 * ((self.p1.x * self.p2.y) + (self.p1.y * pt.x) + (self.p2.x * pt.y) - (pt.x * self.p2.y) - (pt.y * self.p1.x) - (self.p2.x * self.p1.y))

	if (area < 0) then
		return "right"
	elseif (area > 0) then
		return "left"
	else
		return "neither"
	end
end

-- Check if two lines/segments intersect, or if a point, check if the point is on the segment
function Segment:intersect(obj, inclusive)
	-- Check if the point is on the line, in the segment
	if (obj.cname == "Point") then
		local ix = (obj.x - self.p1.x) / (self.p2.x - self.p1.x)
		local iy = (obj.y - self.p1.y) / (self.p2.y - self.p1.y)

		-- FIXME account for fp error
		if not (math.abs(ix - iy) < DISTANCE_TOLERANCE) then
			return false
		end

		-- Check that we're IN the segment
		local xok = false
		local yok = false
		if (self.p1.x > self.p2.x) then
			if self.p2.x < obj.x and self.p1.x > obj.x then
				xok = true
			end
		else
			if self.p2.x < obj.x and self.p1.x > obj.x then
				xok = true
			end
		end
		if (self.p1.y > self.p2.y) then
			if self.p2.y < obj.y and self.p1.y > obj.y then
				yok = true
			end
		else
			if self.p2.y < obj.y and self.p1.y > obj.y then
				yok = true
			end
		end
		return (xok and yok)

	-- Check if the line intersects with the segment
	-- FIXME: Inclusive?
	elseif(obj.cname == "Segment") then
		local p1 = obj.p1
		local p2 = obj.p2

		-- Check to see if the line points (p1, p2) are on opposite sides of the segment
		-- Take the cross product for point p1
		cp1 = (self.p2.x - self.p1.x) * (p1.y - self.p2.y) - (self.p2.y - self.p1.y) * (p1.x - self.p2.x)
		-- Take the cross product for point p2
		cp2 = (self.p2.x - self.p1.x) * (p2.y - self.p2.y) - (self.p2.y - self.p1.y) * (p2.x - self.p2.x)
		-- Check the result, if the sign matches, they don't intersect
		if ((cp1 < 0) and (cp2 < 0)) or ((cp1 > 0) and (cp2 > 0)) then
			return false
		end

		-- Now we do the reverse and check the segment to see if it's on opposite sides
		-- Take the cross product for point self.p1
		cp1 = (p2.x - p1.x) * (self.p1.y - p2.y) - (p2.y - p1.y) * (self.p1.x - p2.x)
		-- Take the cross product for point self.p2
		cp2 = (p2.x - p1.x) * (self.p2.y - p2.y) - (p2.y - p1.y) * (self.p2.x - p2.x)
		-- Check the result, if the sign matches, they don't intersect
		if ((cp1 < 0) and (cp2 < 0)) or ((cp1 > 0) and (cp2 > 0)) then
			return false
		end
		return true
	end
	-- Default error state	
	print ("Invalid type for comparison: " .. obj.cname)
	return false
end

-- Find the intersection point between two segments
-- FIXME Comment and fix vars
function Segment:intersect_point(s)
	local cp1 = (self.p2.x - self.p1.x) * (s.p1.y - self.p1.y) - (self.p2.y - self.p1.y) * (s.p1.x - self.p1.x)	
	local cp2 = (self.p2.y - self.p1.y) * (s.p2.x - s.p1.x) - (self.p2.x - self.p1.x) * (s.p2.y - s.p1.y)
	if not (cp2 == 0) then
		local int_pt = cp1 / cp2
		local x = s.p1.x + (s.p2.x - s.p1.x) * int_pt
		local y = s.p1.y + (s.p2.y - s.p1.y) * int_pt
		return Point:new(x, y)
	end
	return nil
end

-- Find the line that bisects this segment
function Segment:bisect()
	local midpoint = Point:new((self.p1.x + self.p2.x)/2, (self.p1.y + self.p2.y)/2)
	-- Find the new points
	local p1 = Point:new(midpoint.x - (self.p2.y - self.p1.y), midpoint.y + (self.p2.x - self.p1.x))
	local p2 = Point:new(midpoint.x + (self.p2.y - self.p1.y), midpoint.y - (self.p2.x - self.p1.x))
	
	-- Return the segment
	return Segment:new(p1, p2)
end

-- Print out the segment's location
function Segment:print()
	print("(" .. self.p1.x .. "," .. self.p1.y .." -> " .. self.p2.x .. "," .. self.p2.y .. ")")
end

-- Draw this line on the screen
function Segment:draw()
	lg.line(self.p1.x, self.p1.y, self.p2.x, self.p2.y)
end

return Segment
