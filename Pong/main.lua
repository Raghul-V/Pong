push = require "push"
class = require "class"

require "Paddle"
require "Ball"

SCREEN_WIDTH, SCREEN_HEIGHT = 950, 505
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 480, 255

PADDLE_WIDTH, PADDLE_HEIGHT = 10, 45
MAX_SPEED = 5
RADIUS = 8

left_paddle = Paddle(
	"Player 1", 
	20, (VIRTUAL_HEIGHT-PADDLE_HEIGHT) / 2,
	PADDLE_WIDTH, PADDLE_HEIGHT, "w", "s"
)

right_paddle = Paddle(
	"Player 2", 
	VIRTUAL_WIDTH-PADDLE_WIDTH-20, (VIRTUAL_HEIGHT-PADDLE_HEIGHT) / 2,
	PADDLE_WIDTH, PADDLE_HEIGHT, "up", "down"
)

ball = Ball(
	VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, RADIUS, 
	math.random(2) == 1 and -2.25 or 2.25, 
	(math.random(25, 225)/100) * (math.random(2) == 1 and -1 or 1)
)

game_state = "start"
winner = 0


function love.load()
	smallFont = love.graphics.newFont("font.ttf", 18)
	largeFont = love.graphics.newFont("font.ttf", 32)
	love.graphics.setFont(smallFont)

	paddle_hit_sound = love.audio.newSource(
		"sounds/paddle_hit_sound.wav", "static")
	wall_hit_sound = love.audio.newSource(
		"sounds/wall_hit_sound.wav", "static")
	score_sound = love.audio.newSource(
		"sounds/score_sound.wav", "static")

	love.graphics.setDefaultFilter("nearest", "nearest")

	love.window.setTitle("Pong")
	math.randomseed(os.time())

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT,
		SCREEN_WIDTH, SCREEN_HEIGHT, {
			fullscreen = false,
			resizable = false,
			vsync = true
	})
end


function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "return" or key == "kpenter" then
		if game_state == "start" then
			game_state = "play"
			ball.is_moving = true
		elseif game_state == "gameover" then
			game_state = "start"
			
			left_paddle.x = 20
			left_paddle.y = (VIRTUAL_HEIGHT-PADDLE_HEIGHT) / 2
			left_paddle.dy = 0
			left_paddle.score = 0
			
			right_paddle.x = VIRTUAL_WIDTH-PADDLE_WIDTH-20
			right_paddle.y = (VIRTUAL_HEIGHT-PADDLE_HEIGHT) / 2
			right_paddle.dy = 0
			right_paddle.score = 0
			
			ball.x = VIRTUAL_WIDTH / 2
			ball.y = VIRTUAL_HEIGHT / 2
			ball.dx = 2.25 * (math.random(2) == 1 and -1 or 1)
			ball.dy = (math.random(25, 225)/100) * (math.random(2) == 1 and -1 or 1)
			ball.is_moving = false
		end
	end
end


function love.draw()
	push:apply("start")

	love.graphics.clear(0.5, 0.5, 0)

	left_paddle:draw()
	right_paddle:draw()
	ball:draw()

	love.graphics.setFont(smallFont)
	love.graphics.printf(
		left_paddle.name..": "..(left_paddle.score), 
		0, 32, VIRTUAL_WIDTH/2, "center"
	)
	love.graphics.printf(
		right_paddle.name..": "..(right_paddle.score), 
		VIRTUAL_WIDTH/2, 32, VIRTUAL_WIDTH/2, "center"
	)

	if game_state == "start" then
		love.graphics.printf(
			"Press ENTER to play!", 
			0, 150, VIRTUAL_WIDTH, "center"
		)
	elseif game_state == "gameover" then
		love.graphics.setFont(largeFont)
		love.graphics.printf(
			winner.name.." won the game!",
			0, VIRTUAL_HEIGHT/2 - 30, VIRTUAL_WIDTH, "center"
		)
		love.graphics.setFont(smallFont)
		love.graphics.printf(
			"Press ENTER to restart!",
			0, VIRTUAL_HEIGHT/2 + 10, VIRTUAL_WIDTH, "center"
		)
	end

	push:apply("end")
end


function love.update()
	-- """Human as PLAYER 1"""
	left_paddle:move(VIRTUAL_HEIGHT, MAX_SPEED)
	
	-- """A.I. as PLAYER 1"""
	-- if ball.y < left_paddle.y + left_paddle.height/3 then
	-- 	left_paddle.y = left_paddle.y - MAX_SPEED
	-- elseif ball.y > left_paddle.y + left_paddle.height*2/3 then
	-- 	left_paddle.y = left_paddle.y + MAX_SPEED
	-- end
	-- left_paddle.y =  math.max(left_paddle.y, 0)
	-- left_paddle.y = math.min(left_paddle.y, VIRTUAL_HEIGHT-left_paddle.height)
	
	right_paddle:move(VIRTUAL_HEIGHT, MAX_SPEED)

	if game_state == "play" then
		if ball.x + RADIUS < 0 then
			right_paddle.score = right_paddle.score + 1
			score_sound:play()
			winner = right_paddle
			game_state = "nextgame"
		elseif ball.x - RADIUS > VIRTUAL_WIDTH then
			left_paddle.score = left_paddle.score + 1
			score_sound:play()
			winner = left_paddle
			game_state = "nextgame"
		end
		if left_paddle.score == 10 or
			right_paddle.score == 10 then
			game_state = "gameover"
		end

		ball.dx = (ball.dx/math.abs(ball.dx)) *
			math.min(math.abs(ball.dx), MAX_SPEED-1.5)
		ball.dy = (ball.dy/math.abs(ball.dy)) *
			math.min(math.abs(ball.dy), MAX_SPEED-1.5)
		
		if ball.x < VIRTUAL_WIDTH/2 then
			ball:move(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, 0.2, left_paddle)
		else
			ball:move(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, 0.2, right_paddle)
		end
	elseif game_state == "nextgame" then
		ball.x = VIRTUAL_WIDTH / 2
		ball.y = VIRTUAL_HEIGHT / 2
		ball.dx = 1.75 * (math.random(2) == 1 and -1 or 1)
		ball.dy = (math.random(25, 175)/100) * (math.random(2) == 1 and -1 or 1)
		ball.is_moving = false
		game_state = "start"
	end
end

