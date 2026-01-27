push = require 'push'  -- Import the push library for virtual resolution handling

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Multiplied by dt to get pixels per second
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once. 
    Used to initialize the game.
]]
function love.load()
    love.window.setTitle('Pong')  -- Set the window title
    love.graphics.setDefaultFilter('nearest', 'nearest')  -- Set default filter to nearest for pixel art style

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
end

--[[
    Function is called whenever a key is pressed.
    In this case we're using it to quit the game.
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()    -- Terminate the game
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
        5,                            -- Width
        20                            -- Height
    )

    love.graphics.rectangle(          -- Draw a rectangle (paddle) for second player
        'fill',                       -- Mode, can be 'fill' or 'line'
        VIRTUAL_WIDTH - 10 - 5,       -- X position (centered)
        playerTwoY,                   -- Y position
        5,                            -- Width
        20                            -- Height
    )

    love.graphics.rectangle(          -- Draw a ball
        'fill',                       -- Mode, can be 'fill' or 'line'
        VIRTUAL_WIDTH / 2 - 2,        -- X position (centered)
        VIRTUAL_HEIGHT / 2 - 2,       -- Y position (centered)
        4,                            -- Width
        4                             -- Height
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
        playerOneY = playerOneY - PADDLE_SPEED * dt  -- Move paddle up
    elseif love.keyboard.isDown('s') then
        playerOneY = playerOneY + PADDLE_SPEED * dt  -- Move paddle down
    end

    -- Player two movement
    if love.keyboard.isDown('up') then
        playerTwoY = playerTwoY - PADDLE_SPEED * dt  -- Move paddle up
    elseif love.keyboard.isDown('down') then
        playerTwoY = playerTwoY + PADDLE_SPEED * dt  -- Move paddle down
    end
end