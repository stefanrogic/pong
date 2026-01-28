Class = require 'class'  -- Import the class library for OOP
push = require 'push'  -- Import the push library for virtual resolution handling
require 'paddle'  -- Import the Paddle class
require 'ball'    -- Import the Ball class

-- Window dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Virtual resolution dimensions (smaller than actual window size, we use it to give a retro feel)
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Paddle constants
PADDLE_SPEED = 400 -- Multiplied by dt to get pixels per second
PADDLE_HEIGHT = 50
PADDLE_WIDTH = 5

-- Ball constants
BALL_SIZE = 4 -- Width and height of the ball
BALL_START_SPEED = 200 -- Initial speed of the ball
BALL_ACCELERATION = 1.03 -- Ball speed increase factor on paddle hit

--[[
    Runs when the game first starts up, only once. 
    Used to initialize the game.
]]
function love.load()
    love.window.setTitle('Pong')  -- Set the window title
    love.graphics.setDefaultFilter('nearest', 'nearest')  -- Set default filter to nearest for pixel art style

    -- Seed the RNG so that calls to random are always random
    -- It uses current time, since that will vary on each execution
    math.randomseed(os.time())

    -- Fonts
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    scoreFont = love.graphics.newFont('fonts/font.ttf', 32)

    -- Setup
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { -- Set the window size and options) 
        -- Window configuration options, could be done separate in config.lua
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    playerOneScore = 0  -- Initialize player one score
    playerTwoScore = 0  -- Initialize player two score

    -- Initialize player paddles and ball
    playerOne = Paddle(10, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, PADDLE_WIDTH, PADDLE_HEIGHT)
    playerTwo = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, PADDLE_WIDTH, PADDLE_HEIGHT)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, BALL_SIZE)

    -- State 
    gameState = 'start'  -- Can be 'start', 'serve', 'play', or 'done'
end

--[[
    Function is called whenever a key is pressed.
    In this case we're using it to quit the game.
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()    -- Terminate the game
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'  -- Change state to play
            -- Give ball initial velocity when starting
            ball.dx = math.random(2) == 1 and BALL_START_SPEED or -BALL_START_SPEED
            ball.dy = BALL_START_SPEED
        elseif gameState == 'play' then
            gameState = 'start'  -- Change state to start
            ball:reset()         -- Reset ball using its method
            playerOne:reset()       -- Reset paddles using their method
            playerTwo:reset()       -- Reset paddles using their method
        end
    end
end

function displayFPS()
    love.graphics.setFont(smallFont)  -- Set the font to smallFont
    love.graphics.setColor(0, 1, 0, 1) -- Set color to green
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10) -- Print FPS at (10,10)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white
end

--[[
    Called each frame after update, used to draw things to the screen.
]]
function love.draw()
    push:apply('start')  -- Begin rendering at virtual resolution

    love.graphics.clear(40/255, 45/255, 52/255, 255)  -- Clear the screen with a specific color

    love.graphics.setFont(smallFont)  -- Set the loaded font as the current font
    love.graphics.printf(             -- Draws text on the screen
        "Hello, Pong!",               -- Text to print
        0,                            -- X position
        10,                           -- Y position
        VIRTUAL_WIDTH,                -- Maximum width 
        "center"                      -- Alignment, it can be "left", "right", or "center"
    )

    love.graphics.setFont(scoreFont)  -- Set the score font
    love.graphics.print(              -- Draw player one score
        tostring(playerOneScore),     -- Text to print (converted to string)
        VIRTUAL_WIDTH / 2 - 50,       -- X position
        VIRTUAL_HEIGHT / 3            -- Y position
    )
    love.graphics.print(              -- Draw player two score
        tostring(playerTwoScore),     -- Text to print (converted to string)
        VIRTUAL_WIDTH / 2 + 30,       -- X position
        VIRTUAL_HEIGHT / 3            -- Y position
    )

    playerOne:render()  -- Render player one's paddle
    playerTwo:render()  -- Render player two's paddle
    ball:render()       -- Render the ball

    displayFPS()        -- Display FPS for debugging

    push:apply('end')   -- End rendering at virtual resolution
end

--[[
    Called each frame, used to update the game state.
    'dt' is the amount of time (in seconds) since the last update.
]]
function love.update(dt)
    -- Ball movement and collision
    if gameState == 'play' then
        if ball:colides(playerOne) then
            ball.dx = -ball.dx * BALL_ACCELERATION  -- Reverse horizontal direction and increase speed
            ball.x = playerOne.x + playerOne.width  -- Reposition ball outside paddle (center-based)

            -- Randomize ball's vertical velocity
            if ball.dy < 0 then
                ball.dy = -ball.dx
            else
                ball.dy = ball.dx
            end
        end

        if ball:colides(playerTwo) then
            ball.dx = -ball.dx * BALL_ACCELERATION  -- Reverse horizontal direction and increase speed
            ball.x = playerTwo.x - ball.width       -- Reposition ball outside paddle (center-based)

            -- Randomize ball's vertical velocity
            if ball.dy < 0 then
                ball.dy = ball.dx
            else
                ball.dy = -ball.dx
            end
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy  -- Reverse vertical direction
        end

        if ball.y >= VIRTUAL_HEIGHT - ball.height then
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.dy = -ball.dy  -- Reverse vertical direction
        end

        ball:update(dt) -- Update ball position based on its velocity
    end

    -- Player one movement
    if love.keyboard.isDown('w') then
        playerOne.dy = -PADDLE_SPEED  -- Set velocity to move up
    elseif love.keyboard.isDown('s') then
        playerOne.dy = PADDLE_SPEED   -- Set velocity to move down
    else
        playerOne.dy = 0              -- Stop moving if no key pressed
    end

    -- Player two movement
    if love.keyboard.isDown('up') then
        playerTwo.dy = -PADDLE_SPEED  -- Set velocity to move up
    elseif love.keyboard.isDown('down') then
        playerTwo.dy = PADDLE_SPEED   -- Set velocity to move down
    else
        playerTwo.dy = 0              -- Stop moving if no key pressed
    end

    -- Always update paddles (they check their own dy to move)
    playerOne:update(dt)
    playerTwo:update(dt)
end