push = require 'push'  -- Import the push library for virtual resolution handling

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200 -- Multiplied by dt to get pixels per second
PADDLE_HEIGHT = 20
PADDLE_WIDTH = 5

BALL_SIZE = 4

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

    -- State 
    gameState = 'start'  -- Can be 'start', 'serve', 'play', or 'done'

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

    -- Only Y because paddles only move up and down
    playerOneY = 30 -- Initial Y position for player one paddle
    playerTwoY = VIRTUAL_HEIGHT - 50 -- Initial Y position for player two paddle

    -- Ball position
    ballX = VIRTUAL_WIDTH / 2 - 2  -- Initial X position for the ball (centered)
    ballY = VIRTUAL_HEIGHT / 2 - 2  -- Initial Y position for the ball (centered)

    -- Ball velocity
    ballDX = math.random(2) == 1 and 100 or -100  -- Initial horizontal speed of the ball
    ballDY = math.random(-50, 50)  -- Initial vertical speed of the ball
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
        elseif gameState == 'play' then
            gameState = 'start'  -- Change state to start
            -- Reset ball position
            ballX = VIRTUAL_WIDTH / 2 - 2
            ballY = VIRTUAL_HEIGHT / 2 - 2
            -- Reset ball velocity
            ballDX = math.random(2) == 1 and 100 or -100
            ballDY = math.random(-50, 50)
        end
    end
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

    love.graphics.rectangle(          -- Draw a rectangle (paddle) for first player
        'fill',                       -- Mode, can be 'fill' or 'line'
        10,                           -- X position (centered)
        playerOneY,                   -- Y position
        PADDLE_WIDTH,                -- Width
        PADDLE_HEIGHT                -- Height
    )

    love.graphics.rectangle(          -- Draw a rectangle (paddle) for second player
        'fill',                       -- Mode, can be 'fill' or 'line'
        VIRTUAL_WIDTH - 10 - PADDLE_WIDTH, -- X position (centered)
        playerTwoY,                   -- Y position
        PADDLE_WIDTH,                -- Width
        PADDLE_HEIGHT                -- Height
    )

    love.graphics.rectangle(          -- Draw a ball
        'fill',                       -- Mode, can be 'fill' or 'line'
        ballX,                        -- X position (centered)
        ballY,                        -- Y position (centered)
        BALL_SIZE,                    -- Width
        BALL_SIZE                     -- Height
    )

    push:apply('end')  -- End rendering at virtual resolution
end

--[[
    Called each frame, used to update the game state.
    'dt' is the amount of time (in seconds) since the last update.
]]
function love.update(dt)
    -- Player one movement
    if love.keyboard.isDown('w') then
        -- Math.max ensures the paddle doesn't go above the screen when moving up
        playerOneY = math.max(0, playerOneY - PADDLE_SPEED * dt)  -- Move paddle up
    elseif love.keyboard.isDown('s') then
        -- Math.min ensures the paddle doesn't go below the screen when moving down
        playerOneY = math.min(VIRTUAL_HEIGHT - PADDLE_HEIGHT, playerOneY + PADDLE_SPEED * dt)  -- Move paddle down
    end

    -- Player two movement
    if love.keyboard.isDown('up') then
        playerTwoY = math.max(0, playerTwoY - PADDLE_SPEED * dt)  -- Move paddle up
    elseif love.keyboard.isDown('down') then
        playerTwoY = math.min(VIRTUAL_HEIGHT - PADDLE_HEIGHT, playerTwoY + PADDLE_SPEED * dt)  -- Move paddle down
    end

    if gameState == 'play' then
        -- Update ball position based on its velocity
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end
end