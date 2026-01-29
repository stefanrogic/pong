--[[
    Function is called whenever the window is resized.
    In this case we're using it to resize our virtual resolution.
]]
function love.resize(w, h)
    push:resize(w, h)
end

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
        if gameState ~= 'pause' then
            gameState = 'pause'
            sounds['wall_hit']:play()
        else 
            if ball.dx == 0 and ball.dy == 0 then
                if playerOneScore > 0 or playerTwoScore > 0 then
                    gameState = 'serve'
                    sounds['wall_hit']:play()
                else
                    gameState = 'start'
                    sounds['wall_hit']:play()
                end
            else
                gameState = 'play'
                sounds['wall_hit']:play()
            end
        end
    end

    if key == 'q' then
        if gameState == 'pause' then
            love.event.quit()
        end
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'serve' then
            gameState = 'play'
            ball.dy = math.random(-BALL_SPEED / 2, BALL_SPEED / 2)
            
            if servingPlayer == 1 then
                ball.dx = BALL_SPEED
            else
                ball.dx = -BALL_SPEED
            end
        elseif gameState == 'start' then
            gameState = 'play'  -- Change state to play
            -- Give ball initial velocity when starting
            ball.dx = math.random(2) == 1 and -BALL_SPEED or BALL_SPEED
            ball.dy = math.random(-BALL_SPEED / 2, BALL_SPEED / 2)
        elseif gameState == 'done' then
            playerOneScore = 0
            playerTwoScore = 0
            gameState = 'start'  -- Change state to start
            ball:reset()         -- Reset ball using its method
            playerOne:reset()       -- Reset paddles using their method
            playerTwo:reset()       -- Reset paddles using their method
        end
    end

    if key == 'r' then
        -- Reset scores and game state
        playerOneScore = 0
        playerTwoScore = 0
        gameState = 'start'
        ball:reset()
        playerOne:reset()
        playerTwo:reset()
    end

    if key == '`' then
        if fpsState == "on" then
            fpsState = "off"
        else
            fpsState = "on"
        end
    end
end