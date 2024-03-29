-- Convert HSLA to RGBA
-- From: http://www.love2d.org/wiki/HSL_color
function HSL(h, s, l, a)
	-- If there's no saturaton, we can't convert
	if s<=0 then
		return l,l,la
	end

	-- Conversion to RGB Space
	h, s, l = h/256*6, s/255, l/255
	local c = (1-math.abs(2*l-1)) * s
	local x = (1-math.abs(h%2-1)) * c
	local m,r,g,b = (l-0.5*c), 0, 0, 0
	if h < 1 then
		r,g,b = c,x,0
	elseif h < 2 then
		r,g,b = x,c,0
	elseif h < 3 then
		r,g,b = 0,c,x
	elseif h < 4 then
		r,g,b = 0,x,c
	elseif h < 5 then
		r,g,b = x,0,c
	else
		r,g,b = c,0,x
	end
	return (r+m)*255, (g+m)*255, (b+m)*255, a
end
