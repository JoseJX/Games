require 'utils'
-- Point in 2D Space
local Point = {}
Point.__index = Point

function Point:new(x, y)
	-- If we're passed a point make a copy
	if (type(x) == "table") then
		if(x.cname == "Point") then
			y = x.y
			x = x.x
		end
	end

	local obj = { 
		cname = "Point",
		x = x,
		y = y,
	}
	return setmetatable(obj, Point)
end

-- Check for equality between objects
-- Supports other points and lines (equal if point is on line)
function Point:__eq(obj)
	if (self.x == obj.x) and (self.y == obj.y) then
		return true
	else
		if(self:distance(obj) < DISTANCE_TOLERANCE) then
			return true
		end
	end
	return false
end

-- Move a point's position
function Point:move(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end
function Point:move_to(x, y)
	self.x = x
	self.y = y
end

-- Find the distance between a point and another object
function Point:distance(obj)
	-- To another point
	if (obj.cname == "Point") then
		return math.sqrt(math.pow(obj.x - self.x, 2) + math.pow(obj.y - self.y,2))
	elseif (obj.cname == "Segment") then
		print("FIXME: Distance: Point(self) == Segment")
	end
	
	-- Default error state	
	print ("Invalid type for comparison: " .. obj.cname)
	return nil
end

-- Find the line that bisects this point and another
function Point:bisect(x, y)
	local pt = x
	if type(pt) == "number" then
		pt = Point:new(x, y)
	end

	local midpoint = Point:new((self.x + pt.x)/2, (self.y + pt.y)/2)
	-- Find the new points
	local bsm = 1/DISTANCE_TOLERANCE
	local p1 = Point:new(midpoint.x - bsm*(pt.y - self.y), midpoint.y + bsm*(pt.x - self.x))
	local p2 = Point:new(midpoint.x + bsm*(pt.y - self.y), midpoint.y - bsm*(pt.x - self.x))
	
	-- Returns the two points
	return p1, p2
end

-- Print out the current state of the point
function Point:print()
	print("(" .. self.x .. "," .. self.y ..")")
end

-- Draw this point on the screen
function Point:draw()
	lg.point(self.x, self.y)
end

return Point
