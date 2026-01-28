function displayFPS()
    love.graphics.setFont(smallFont)  -- Set the font to smallFont
    love.graphics.setColor(0, 1, 0, 1) -- Set color to green
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10) -- Print FPS at (10,10)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white
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
            ball.dx = math.random(2) == 1 and BALL_SPEED or -BALL_SPEED
            ball.dy = BALL_SPEED
        elseif gameState == 'play' then
            gameState = 'start'  -- Change state to start
            ball:reset()         -- Reset ball using its method
            playerOne:reset()       -- Reset paddles using their method
            playerTwo:reset()       -- Reset paddles using their method
        end
    end

    if key == '`' then
        if fpsState == "on" then
            fpsState = "off"
        else
            fpsState = "on"
        end
    end
end