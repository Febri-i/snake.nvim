---@class SnakeBody
---@field xdir number
---@field ydir number
---@field length number

---@class Snake
---@field x number
---@field y number
---@field body SnakeBody[]

---@class Game
---@field snake Snake
---@field width number: world width
---@field level number
---@field height number: world height
---@field paused boolean
---@field snake_can_turn boolean
---@field foods Food[]
local Game = {}

---Create a snake body
---@param _xdir number
---@param _ydir number
---@param _length number
---@return SnakeBody
local function create_snake_body(_xdir, _ydir, _length)
	return { xdir = _xdir, ydir = _ydir, length = _length }
end

---Create a snake
---@param _x number
---@param _y number
---@param len number
---@return Snake
local function create_snake(_x, _y, len)
	return { x = _x, y = _y, body = { create_snake_body(0, 1, len) } }
end

---Check if val is in between min,max
---@param val number
---@param min number
---@param max number
---@return boolean
local function inbetween(val, min, max)
	return (val >= min and val <= max) or (val <= min and val >= max)
end

---@class Food
---@field x number
---@field y number
---@field level number

---Create a food
---@param width number
---@param height number
---@return Food
local function create_food(width, height)
	local x = math.random(2, width - 2)
	local y = math.random(2, height - 2)
	return {
		level = math.random(3),
		y = y,
		x = x,
	}
end

---@class GameParam
---@field width number
---@field height number
---@field initial_length number
---@field totalFood number

---Create a new snake game
---@param opts GameParam
---@return Game
function Game:new(opts)
	local newSelf = setmetatable({}, Game)
	---@type Food[]
	local foods = {}
	for _ = 1, opts.totalFood do
		local food = create_food(opts.width, opts.height)
		foods[food.x .. "." .. food.y] = food
	end

	-- vim.api.nvim_err_writeln(vim.inspect(foods))

	self.snake = create_snake(
		math.random(math.floor(opts.width / 4), math.floor(opts.width * 3 / 4)),
		math.random(math.floor(opts.height / 4), math.floor(opts.height * 3 / 4)),
		opts.initial_length
	)
	self.foods = foods
	self.width = opts.width
	self.height = opts.height
	self.snake_can_turn = true
	self.level = opts.initial_length
	self.paused = false
	self.snake_can_turn = true
	self.__index = self
	return newSelf
end

function Game:is_snake_out_of_bound()
	if self.snake.x >= self.width - 1 or self.snake.y >= self.height - 1 or self.snake.x < 1 or self.snake.y < 1 then
		return true
	end
	return false
end

function Game:is_snake_invalid()
	return not self.snake.body and not #self.snake.body < 1
end

function Game:check_snake()
	if self:is_snake_invalid() then
		return false
	end
	if self:is_snake_out_of_bound() then
		return false
	end
	return true
end

function Game:isAlive()
	local xhead = self.snake.x
	local yhead = self.snake.y

	local xstart = self.snake.x
	local ystart = self.snake.y

	for i, _body in ipairs(self.snake.body) do
		local yend = ystart - _body.ydir * _body.length
		local xend = xstart - _body.xdir * _body.length
		if i ~= 1 then
			if yend == yhead and inbetween(xhead, xstart, xend) then
				return false
			end
			if xend == xhead and inbetween(yhead, ystart, yend) then
				return false
			end
		end
		xstart = xend
		ystart = yend
	end

	return true
end

function Game:get_food()
	return self.foods[self.snake.x .. "." .. self.snake.y]
end

function Game:eat_food(food)
	self.level = self.level + food.level
	self.snake.body[#self.snake.body].length = self.snake.body[#self.snake.body].length + food.level
	self.foods[food.x .. "." .. food.y] = nil
	local new_food = create_food(self.width, self.height)
	self.foods[new_food.x .. "." .. new_food.y] = new_food
end

function Game:update_snake()
	if not self:check_snake() then
		return false
	end
	local tailidx = #self.snake.body
	self.snake.x = self.snake.x + self.snake.body[1].xdir
	self.snake.y = self.snake.y + self.snake.body[1].ydir

	self.snake.body[1].length = self.snake.body[1].length + 1
	self.snake.body[tailidx].length = self.snake.body[tailidx].length - 1
	local taillen = self.snake.body[tailidx].length
	if taillen < 1 then
		table.remove(self.snake.body, tailidx)
		self.snake.body[#self.snake.body].length = self.snake.body[#self.snake.body].length + taillen
	end
	self.snake_can_turn = true

	local food = self:get_food()
	if food ~= nil then
		self:eat_food(food)
	end

	return self:isAlive()
end

function Game:turn_snake(xdir, ydir)
	if not self.snake_can_turn then
		return
	end
	if xdir ~= 0 and ydir ~= 0 then
		ydir = 0
	end
	if (xdir ~= 0 and self.snake.body[1].xdir ~= 0) or (ydir ~= 0 and self.snake.body[1].ydir ~= 0) then
		return
	end

	local new_body = create_snake_body(xdir, ydir, 0)
	table.insert(self.snake.body, 1, new_body)

	self.snake_can_turn = false
end

function Game:quit() end

return Game
