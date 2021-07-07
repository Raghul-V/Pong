Paddle = class{}


function Paddle:init(name, x, y, width, height, upkey, downkey)
	self.name = name
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.upkey = upkey
	self.downkey = downkey
	self.dy = 0
	self.score = 0
end


function Paddle:move(screen_height, paddle_speed)
	if love.keyboard.isDown(self.upkey) then
		self.dy = -paddle_speed
	elseif love.keyboard.isDown(self.downkey) then
		self.dy = paddle_speed
	else
		self.dy = 0
	end

	if self.y + self.dy < 0 then
		self.y = 0
		self.dy = 0
	elseif self.y + self.height + self.dy > screen_height then
		self.y = screen_height - self.height
		self.dy = 0
	end

	self.y = self.y + self.dy
end


function Paddle:draw()
	love.graphics.rectangle(
		"fill", self.x, self.y, self.width, self.height
	)
end

