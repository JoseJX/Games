require 'hsl'
local Map = require 'map'
local last_cell = nil

-- Set up the dispatcher
function test_map_setup_dispatcher(fd_state)
	fd_state.keypressed = test_map_keypressed
	fd_state.mousepressed = test_map_mousepressed
	fd_state.mousereleased = test_map_mousereleased
	fd_state.update = test_map_update
	fd_state.draw = test_map_draw
end

function test_map_load()
	local t = os.time()

	-- Setup the function dispatcher
	test_map_setup_dispatcher(fd_state)

	-- Make a new map
	m = Map:new(800,600, 'Pangea')
	m:generate(t)

	-- Time since last update
	dx = 0
end

function test_map_keypressed(key)
	local t = os.time()
	-- Quit the game
	if key == "escape" then
		le.push('quit')
	else
		m:generate(t)
	end
end

function test_map_mousepressed(x, y, button)
end

function test_map_mousereleased(x, y, button)
end

function test_map_update(dt)
	dx = dx + dt
	if(dx > 1) then
		dx = 0
	end
end

function test_map_draw()
	local cell = m.voronoi:contains(lm.getX(), lm.getY())
	if type(cell) == "table" then
		-- Restore the previous color
		if type(last_cell) == "table" then
			m:color_cell(last_cell)
		end

		-- Color in the new cell
		cell.fill_color = { 255, 0, 0, 255 }

		-- Save this for next time!
		last_cell = cell;
	end

	-- Draw the diagram parts
	m:draw()
end
