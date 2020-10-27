push = require 'push'
Class = require 'class'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    -- seeds os time to the function which generates random number
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    love.window.setTitle('Brick Breaker')

    --VIRTUAL_WIDTH, VIRTUAL_HEIGHT  = love .graphics .getDimensions()

    block_pos  = {}  --  table to store block positions
    rows, columns  = 30, 20  --  you decide how many

    chance_of_block  = 75  --  % chance of placing a block

    block_width  = math .floor( VIRTUAL_WIDTH /columns )
    block_height  = math .floor( VIRTUAL_HEIGHT /rows )

    col  = columns -1  --  don't loop through columns, just use final column

    for  row = 0,  rows -1  do

        if love .math .random() *100 <= chance_of_block then
            local xpos  = col *block_width
            local ypos  = row *block_height

            block_pos[ #block_pos +1 ] = { x = xpos,  y = ypos }
        end  --  rand

    end  --  #columns

    r, g, b  = 0.5, 0.5, 0.0
    love .graphics .setColor( r, g, b )

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 16)

    -- defining score
    score = 0

    -- defining paddle
    paddle = Paddle(5, 20, 5, 20)

    -- defining ball position
    ball = Ball(VIRTUAL_WIDTH / 2 - 3, VIRTUAL_HEIGHT / 2 - 3, 6, 6)

    gameState = 'start'

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- to restart the whole game for testing purpose
    -- takes in consideration the changes done and load according to that
    if key == 'r' then
        love.event.quit("restart")
    end
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'play' then
            gameState = 'start'
            ball:reset()
        end
    end    
end    

function love.update(dt)

    if ball:collides(paddle) then
        -- deflecting to opposite side
        ball.dx = -ball.dx
    end
    -- for top edge
    if ball.y <= 0 then
        -- deflecting to opposite side
        ball.dy = -ball.dy
        ball.y = 0
    end
    -- for bottom edge
    if ball.y >= VIRTUAL_HEIGHT - 6 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 6
    end
    -- for right
    if ball.x + ball.width >= VIRTUAL_WIDTH then
        ball.dx = -ball.dx
    end

    paddle:update(dt)
    -- adding negative velocity to move paddle up
    if love.keyboard.isDown('w') then
        paddle.dy = -PADDLE_SPEED
    -- adding positive velocity to move paddle down
    elseif love.keyboard.isDown('s') then
        paddle.dy = PADDLE_SPEED
    else
        paddle.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(109/255,76/255,65/255,255/255)
    -- printing ball
    ball:render()
    -- printing paddle
    paddle:render()

    -- sets active font to smallFont
    love.graphics.setFont(smallFont)
    
    if gameState == 'start' then
        love.graphics.printf(
            'Welcome to Brick Breaker!',          -- text to render
            0,                      -- starting X (0 since we're going to center it based on width)
            VIRTUAL_HEIGHT / 6 - 4,  -- starting Y (halfway down the screen)  minus-ing half the size of the font for proper alignment
            VIRTUAL_WIDTH,           -- number of pixels to center within (the entire screen here)
            'center')               -- alignment mode, can be 'center', 'left', or 'right'
        love.graphics.printf('Press w and s to move the paddle', 0, VIRTUAL_HEIGHT / 6 + 10 , VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.printf('Goodluck!', 0, VIRTUAL_HEIGHT / 6 - 4, VIRTUAL_WIDTH, 'center') 
    end

    -- printing 
    love.graphics.setFont(scoreFont)
    love.graphics.printf('Score : ' .. score .. '', 20, 1, 170, 'left')
    -- setting color for bricks
    love.graphics.setColor(255/255,255/255, 0/255, 255/255)

    -- printing out bricks
    for y = 0, VIRTUAL_HEIGHT, 10 do                
        love.graphics.rectangle('line', VIRTUAL_WIDTH - 5, y, 5, 10)
    end
    -- printing out 2nd linebricks
    for y = 0, VIRTUAL_HEIGHT, 10 do                
        love.graphics.rectangle('line', VIRTUAL_WIDTH - 15, y, 5, 10)
    end
    -- random 1st line of blocks
    for b = 1, #block_pos do
        local block  = block_pos[b]
        love .graphics .rectangle( 'line',  block.x + 5,  block.y,  5,  10 )
    end  --  #block_pos
    -- random 2nd line of blocks
    for b = 1, #block_pos do
        local block  = block_pos[b]
        love .graphics .rectangle( 'line',  block.x - 5,  block.y,  5,  10 )
    end  --  #block_pos

    push:apply('end')    
end
