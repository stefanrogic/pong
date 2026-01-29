Class = require 'class'  -- Import the class library for OOP
push = require 'push'  -- Import the push library for virtual resolution handling

require 'paddle'
require 'ball'  
require 'utilFunctions' 
require 'settings'  

-- Window dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Virtual resolution dimensions (smaller than actual window size, we use it to give a retro feel)
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

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

    -- Sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['music'] = love.audio.newSource('sounds/music.mp3', 'static')
    }

    -- Setup
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { -- Set the window size and options) 
        -- Window configuration options, could be done separate in config.lua
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    playerOneScore = 0  -- Initialize player one score
    playerTwoScore = 0  -- Initialize player two score

    servingPlayer = 1  -- Player one starts serving

    -- Initialize player paddles and ball
    playerOne = Paddle(10, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, PADDLE_WIDTH, PADDLE_HEIGHT)
    playerTwo = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - PADDLE_HEIGHT / 2, PADDLE_WIDTH, PADDLE_HEIGHT)
    ball = Ball(VIRTUAL_WIDTH / 2 - BALL_SIZE / 2, VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2, BALL_SIZE)

    -- State 
    gameState = 'start'  -- Can be 'start', 'serve', 'play', or 'done'
    fpsState = "off"
end

--[[
    Called each frame after update, used to draw things to the screen.
]]
function love.draw()
    push:apply('start') -- Begin rendering at virtual resolution

    -- Play background music
    sounds['music']:setLooping(true)
    sounds['music']:setVolume(0.05)
    sounds['music']:play()

    love.graphics.clear(40/255, 45/255, 52/255, 255)  -- Clear the screen with a specific color
    love.graphics.setFont(scoreFont)  -- Set the score font


    -- Set score color if player one has won
    if gameState == 'done' and playerOneScore >= WINNING_SCORE then
        love.graphics.setColor(1, 0, 0, 1)  -- Set color to red
    else 
        love.graphics.setColor(90/255, 95/255, 102/255, 1)  -- Set color to lighter shade
    end

    -- Draw player one score
    love.graphics.print(              -- Draw player one score
        tostring(playerOneScore),     -- Text to print (converted to string)
        VIRTUAL_WIDTH / 2 - 50,       -- X position
        10            -- Y position
    )

    -- Set score color if player two has won
    if gameState == 'done' and playerTwoScore >= WINNING_SCORE then
        love.graphics.setColor(1, 0, 0, 1)  -- Set color to red
    else 
        love.graphics.setColor(90/255, 95/255, 102/255, 1)  -- Set color to lighter shade
    end

    -- Draw player two score
    love.graphics.print(              -- Draw player two score
        tostring(playerTwoScore),     -- Text to print (converted to string)
        VIRTUAL_WIDTH / 2 + 30,       -- X position
        10            -- Y position
    )

    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white

    -- When game is over display winning message
    if gameState == 'done' then
        love.graphics.setFont(smallFont)  -- Set font to smallFont

        if playerOneScore >= WINNING_SCORE then
            love.graphics.printf("Player One Wins", 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf("Player Two Wins", 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        end

        love.graphics.printf("Press Enter to Restart", 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
    end

    playerOne:render()                -- Render player one's paddle
    playerTwo:render()                -- Render player two's paddle

    if gameState == 'start' then
        love.graphics.setFont(smallFont)  -- Set font to smallFont
        love.graphics.printf("Press Enter to Serve", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'serve' then
        love.graphics.setFont(smallFont)  -- Set font to smallFont
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s Serve! Press Enter to Serve", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'start' or gameState == 'play' or gameState == 'serve' then
        ball:render()                     -- Render the ball
    end

    if fpsState == "on" then
        displayFPS()                  -- Display FPS for debugging
    end

    push:apply('end')                 -- End rendering at virtual resolution
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

             -- Keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(PADDLE_INACCURACY, BALL_SPEED)
            else
                ball.dy = math.random(PADDLE_INACCURACY, BALL_SPEED)
            end

            sounds['paddle_hit']:play()  -- Play paddle hit sound
        end

        if ball:colides(playerTwo) then
            ball.dx = -ball.dx * BALL_ACCELERATION  -- Reverse horizontal direction and increase speed
            ball.x = playerTwo.x - ball.width       -- Reposition ball outside paddle (center-based)

            -- Keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(PADDLE_INACCURACY, BALL_SPEED)
            else
                ball.dy = math.random(PADDLE_INACCURACY, BALL_SPEED)
            end

            sounds['paddle_hit']:play()  -- Play paddle hit sound
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy  -- Reverse vertical direction
            sounds['wall_hit']:play()  -- Play wall hit sound
        end

        if ball.y >= VIRTUAL_HEIGHT - ball.height then
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.dy = -ball.dy  -- Reverse vertical direction
            sounds['wall_hit']:play()  -- Play wall hit sound
        end

        ball:update(dt) -- Update ball position based on its velocity
    end

    -- Scoring
    if ball.x > VIRTUAL_WIDTH then
        playerOneScore = playerOneScore + 1  -- Player one scores
        servingPlayer = 2

        ball:reset()
        playerOne:reset()
        playerTwo:reset()  
                       
        gameState = 'serve'                  -- Change state to start

        sounds['score']:setVolume(0.2)
        sounds['score']:play()
    end

    if ball.x < 0 then
        playerTwoScore = playerTwoScore + 1  -- Player two scores
        servingPlayer = 1

        ball:reset()
        playerOne:reset()
        playerTwo:reset()  

        gameState = 'serve'   

        sounds['score']:setVolume(0.2)
        sounds['score']:play()
    end

    -- Check for winning condition
    if (playerOneScore >= WINNING_SCORE or playerTwoScore >= WINNING_SCORE) then
        gameState = 'done'
    end

    -- Player movement
    if love.keyboard.isDown('w') then
        playerOne.dy = -PADDLE_SPEED  -- Set velocity to move up
    elseif love.keyboard.isDown('s') then
        playerOne.dy = PADDLE_SPEED   -- Set velocity to move down
    else
        playerOne.dy = 0              -- Stop moving if no key pressed
    end

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