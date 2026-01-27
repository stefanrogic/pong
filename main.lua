WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--[[
    Runs when the game first starts up, only once. 
    Used to initialize the game.
]]
function love.load()
    -- Set the window size and options (we can create a separate file for this as well) - config.lua
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { 
        -- Window configuration options
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

--[[
    Called each frame after update, used to draw things to the screen.
]]
function love.draw()
    love.graphics.printf(  -- Draws text on the screen
        "Hello, World!",   -- Text to print
        0,                 -- X position
        WINDOW_HEIGHT / 2 - 6, -- Y position (-6 is half the font height for vertical centering)
        WINDOW_WIDTH,      -- Maximum width 
        "center"           -- Alignment, it can be "left", "right", or "center"
    )
end

--[[
    Called each frame, used to update the game state.
    'dt' is the amount of time (in seconds) since the last update.
]]
function love.update(dt)

end