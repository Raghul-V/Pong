Ball = class{}


function Ball:init(x, y, radius, dx, dy)
	self.x = x
	self.y = y
	self.radius = radius
	self.dx = dx
	self.dy = dy
	self.is_moving = false
end


function Ball:is_collided(paddle)
	if self.x + self.radius < paddle.x or
			self.x - self.radius > paddle.x + paddle.width or
			self.y + self.radius < paddle.y or
			self.y - self.radius > paddle.y + paddle.height then
		return false
	end
	return true
end


function Ball:move(screen_width, screen_height, speed_change, paddle)
	if not self.is_moving then
		return false
	end

	if self.y - self.radius + self.dy < 0 then
		self.y = self.radius
		self.dy = -(self.dy - math.random(0, speed_change*100)/100)
		wall_hit_sound:play()
		return true
	elseif self.y + self.radius + self.dy > screen_height then
		self.y = screen_height - self.radius
		self.dy = -(self.dy + math.random(0, speed_change*100)/100)
		wall_hit_sound:play()
		return true
	end

	self.x = self.x + self.dx
	self.y = self.y + self.dy

	if self:is_collided(paddle) then
		if paddle.x < screen_width/2 then
			if self.x >= paddle.x + paddle.width then
				self.x = paddle.x + paddle.width + self.radius
				self.dx = -(self.dx - math.random(0, speed_change*100)/100)
			end
		else
			if self.x <= paddle.x then
				self.x = paddle.x - self.radius
				self.dx = -(self.dx + math.random(0, speed_change*100)/100)
			end
		end

		if self.y >= paddle.y + paddle.height then
			self.y = paddle.y + paddle.height + self.radius
			self.dy = -(self.dy - math.random(0, speed_change*100)/100)
		elseif self.y <= paddle.y then
			self.y = paddle.y - self.radius
			self.dy = -(self.dy + math.random(0, speed_change*100)/100)
		end

		paddle_hit_sound:play()
	end
end


function Ball:draw()
	love.graphics.circle(
		"fill", self.x, self.y, self.radius
	)
end

