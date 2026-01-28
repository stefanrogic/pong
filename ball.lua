Ball = Class{}

function Ball:init(x, y, size)
    self.x = x  -- X position of the ball
    self.y = y  -- Y position of the ball

    self.height = size -- Height of the ball
    self.width = size -- Same as height for a 'square' ball

    self.dx = 0  -- Horizontal velocity of the ball
    self.dy = 0  -- Vertical velocity of the ball
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt  -- Update X position based on velocity and delta time
    self.y = self.y + self.dy * dt  -- Update Y position based on velocity and delta time
end

function Ball:render()
    love.graphics.rectangle(
        'fill', 
        self.x - self.width / 2, 
        self.y - self.height / 2, 
        self.width, 
        self.height
    )
end

function Ball:colides(paddle)
    -- First, check to see if the left edge of either is farther to the right than the right edge of the other
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- Then check to see if the bottom edge of either is higher than the top edge of the other
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
    self.dx = 0
    self.dy = 0
end