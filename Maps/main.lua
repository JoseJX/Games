-- Include the loader
require 'load'

-- Simpler caller parameters
lg = love.graphics
lk = love.keyboard
lm = love.mouse
le = love.event

-- Engine settings
window_width = lg.getWidth()
window_height = lg.getHeight()

-- System function dispatcher variables
fd_state = {
	keypressed = nil,
	mousepressed = nil,
	mousereleased = nil,
	update = nil,
	draw = nil,
}

-- Function dispatcher
function love.keypressed(key, unicode)
	if not (fd_state.keypressed == nil) then
		fd_state.keypressed(key, unicode)
	end
end
function love.mousepressed(x, y, button)
	if not (fd_state.mousepressed == nil) then
		fd_state.mousepressed(x, y, button)
	end
end
function love.mousereleased(x, y, button)
	if not (fd_state.mousereleased == nil) then
		fd_state.mousereleased(x, y, button)
	end
end
function love.update(dt)
	if not (fd_state.update == nil) then
		fd_state.update(dt)
	end
end
function love.draw()
	if not (fd_state.draw == nil) then
		fd_state.draw()
	end
end
