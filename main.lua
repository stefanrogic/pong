push = require 'push'  -- Import the push library for virtual resolution handling

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--[[
    Runs when the game first starts up, only once. 
    Used to initialize the game.
]]
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')  -- Set default filter to nearest for pixel art style

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { -- Set the window size and options (could be done separate in config.lua) 
        -- Window configuration options
        fullscreen = false,
        resizable = false,
        vsync = true
    })
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
    
    love.graphics.printf(       -- Draws text on the screen
        "Hello, World!",        -- Text to print
        0,                      -- X position
        VIRTUAL_HEIGHT / 2 - 6, -- Y position (-6 is half the font height for vertical centering)
        VIRTUAL_WIDTH,          -- Maximum width 
        "center"                -- Alignment, it can be "left", "right", or "center"
    )

    push:apply('end')  -- End rendering at virtual resolution
end

--[[
    Called each frame, used to update the game state.
    'dt' is the amount of time (in seconds) since the last update.
]]
function love.update(dt)

end