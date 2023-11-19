local scr_w = 50
local scr_h = 30

local startlevel = 4

local function render_level(window, level)
	local pointext = window:create_text("Points: " .. level .. " ", 1, 1, 10)
	window:render_text(pointext)
end

---Render a pause text
---@param window any
local function render_pause(window)
	local pausedstr = " Paused! "
	local pausedtext =
		window:create_text(pausedstr, math.floor(scr_w) - math.floor(#pausedstr), math.floor(scr_h / 2), 10)
	window:render_text(pausedtext)
end

---Setup keymap for the game
---@param window any
---@param game Game
---@param quitcb fun():nil
local function setup_keymapping(window, game, quitcb)
	window:set_keymap("h", function()
		game:turn_snake(-1, 0)
	end)

	window:set_keymap("l", function()
		game:turn_snake(1, 0)
	end)

	window:set_keymap("k", function()
		game:turn_snake(0, -1)
	end)

	window:set_keymap("j", function()
		game:turn_snake(0, 1)
	end)

	window:set_keymap("<Esc>", function()
		quitcb()
	end)

	window:set_keymap("p", function()
		game.paused = not game.paused
	end)
end

---Render foods
---@param window any
---@param foods Food[]
local function draw_food(window, foods)
	for _, food in pairs(foods) do
		window:rect(1, 1, food.x, food.y, food.level + 2)
	end
end

---Draw da snake
---@param window any
---@param game Game
local function draw_snake(window, game)
	local xstart = game.snake.x
	local ystart = game.snake.y

	for _, _body in ipairs(game.snake.body) do
		local yend = ystart - _body.ydir * _body.length
		local xend = xstart - _body.xdir * _body.length
		window:line(xstart, ystart, xend, yend, 69)
		xstart = xend
		ystart = yend
	end

	window:line(game.snake.x, game.snake.y, game.snake.x, game.snake.y, 420)
end

local function draw_game_over(window)
	local gameovertext = " Game over! "
	local joever =
		window:create_text(gameovertext, math.floor(scr_w) - math.floor(#gameovertext), math.floor(scr_h / 2), 10)
	if joever ~= nil then
		window:render_text(joever)
	end
end

---Create a game loop
---@param timer uv_timer_t
---@param callback fun():boolean
---@param duration number
local function gm_loop(timer, callback, duration)
	if callback() then
		return timer:start(
			duration,
			0,
			vim.schedule_wrap(function()
				gm_loop(timer, callback, duration)
			end)
		)
	end
end

---@class GameHighlights
---@field text? string
---@field food1? string
---@field food2? string
---@field food3? string
---@field body? string
---@field head? string
---@field background? string

---@type GameHighlights
local highlights = {
	text = "guibg=#FFFFFF guifg=#000000",
	background = " guibg=#000000",
	food1 = " guibg=#0000FF",
	food2 = " guibg=#FFFF00",
	food3 = " guibg=#ff00FF",
	body = " guibg=#77FF00",
	head = " guibg=#e3bb22",
}

---Setup highlighting
---@param window any
local function setup_higlight(window)
	vim.cmd("hi " .. window:get_hl_name(10) .. " " .. highlights.text)
	vim.cmd("hi " .. window:get_hl_name(0) .. " " .. highlights.background)
	vim.cmd("hi " .. window:get_hl_name(3) .. " " .. highlights.food1)
	vim.cmd("hi " .. window:get_hl_name(4) .. " " .. highlights.food2)
	vim.cmd("hi " .. window:get_hl_name(5) .. " " .. highlights.food3)
	vim.cmd("hi " .. window:get_hl_name(69) .. " " .. highlights.body)
	vim.cmd("hi " .. window:get_hl_name(420) .. " " .. highlights.head)
end

local function startTheGame()
	local window = require("fscreen.window"):new({
		width = scr_w,
		height = scr_h,
	})

	local exit = false

	local timer = vim.loop.new_timer()
	window:subscribe("on_open", function()
		vim.notify("runnin?")
		local game = require("snake.game"):new({
			height = scr_h,
			width = scr_w,
			totalFood = 20,
			initial_length = 4,
		})

		setup_keymapping(window, game, function()
			exit = true
		end)

		setup_higlight(window)
		gm_loop(timer, function()
			if exit then
				return false
			end

			if game.paused then
				render_pause(window)
				window:render()
				return true
			end

			local alive = game:update_snake()
			window:clear()
			draw_food(window, game.foods)
			draw_snake(window, game)
			render_level(window, game.level)

			if not alive then
				draw_game_over(window)
			end
			window:render()

			return alive
		end, 120)
	end)

	window:subscribe("on_close", function()
		exit = true
		window:exit()
		timer:stop()
	end)

	window:open()
end

local M = {}
---@class SetupParam
---@field custom_higlight? GameHighlights

---Setup the game
---@param opts SetupParam
M.setup = function(opts)
	highlights = vim.tbl_extend("force", highlights, opts.custom_higlight or {})
	vim.api.nvim_create_user_command("SnakeStart", function()
		startTheGame()
	end, { bang = true })
end

return M
