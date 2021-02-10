# brickBreaker
-- INTRODUCTION

For my final project I made the classic 'Brick Breaker' in which you have to destroy all the
bricks to complete the level the program restarts when you complete the level and a new level
is generated and the score is resetted. In this game you have 3 lives when the ball goes beyond the
paddle your lives decrease and the ball and paddle are resetted, and when you have 0 lives your game
gets over and final score is displayed on the screen. For each brick destroyed you get 1 point and the
score gets incremented. The program randomly generates 3 columns of the brick towards the opposite end
of the screen. Sounds are also generated when bricks are destroyed or if there is a collision between
the ball and the paddles and when the game is won or the game is over. And the program also plays a
background music for the play state and pauses the music when the state is other than play state

-- LANGUAGE

The program is coded using lua and is run with LOVE2d which was already taught in the cs50 games
track

-- CODE
Defined some global variables in the start
```


For randomly generating bricks, writing a function in love.load(), in which table is created to store the co-ordinates
of the block
```
    local function generate_column( col )
        for  row = 0,  rows -1  do
            if love .math .random() *100 <= chance_of_block then
                local xpos  = col *block_width -( block_width /2 )
                local ypos  = row *block_height +1

                local red  = row /rows
                local green  = math.random()
                local blue  = 1 -col /columns

                block_pos[ #block_pos +1 ] = { x = xpos,  y = ypos,  r = red,  g = green,  b = blue }
            end  --  rand
        end  --  #rows
    end  --  generate_column()
```
Changing the chance_of_block for various columns and passing different arguements for generating
bricks at different columns

For restarting the game used a function love.keypressed and mapped that to 'r' so that if r is pressed the the program restarts
For changing the gameState from 'play' to 'pause' or vice versa the user can press 'enter' or 'space'
or 'return' or 'p' which also utilizes the love.keypressed function
```
function love .keypressed( key )
    if key == 'escape' then  --  takes priority over other keys
        love .event .quit()

    -- to restart the whole game for testing purpose
    -- takes in consideration the changes done and load according to that
    elseif key == 'r' then
        timer = 0
        love .event .quit("restart")

    elseif key == 'enter' or key == 'return' or key == 'space' or key == 'p' then
        if gameState == 'start' then
            gameState = 'play'

        elseif gameState == 'play' then
            gameState = 'pause'

        elseif gameState == 'pause' then
            gameState = 'play'
        end  --  gameState
    end  --  enter
end  --  keypressed
```

In love.update implemented a timer for the start of the program ('timer') and for the end ('timerEnd')
in which the 'timer' increments itself when the state is changed from 'start' to 'play',
and the 'timerEnd' which increments itself when the state is either 'end' or 'victory'
```
    timer = timer +dt

    if gameState == 'end' or gameState == 'victory' then
        timerEnd = timerEnd + dt
    end
```

Also a defined some algorithms which utilizes the AABB collision and check for the various types of collsion
when the gameState = 'play'
such as when the ball goes above the edge of the screen it reverses dy and sets ball.y  to 0,
or when the ball hits the bottom wall, dy is reversed and ball.y = VIRTUAL_HEIGHT -ball.size,
or when the ball hits the right wall, dx is reversed or
for when the ball collides with the paddle a function is written in ball.lua which checks for the collision
using AABB collision and it's called in love.update()
```
if ball :collides( paddle ) then
            ball .dx = -ball .dx  --  horizontal deflection
            sounds['Collision']:play()
        end

        if ball .y <= 0 then  --  top wall
            ball .dy = -ball .dy  --  vertical deflection
            ball .y = 0
        end

        if ball .y >= VIRTUAL_HEIGHT -ball .size then  --  bottom wall
            ball .dy = -ball .dy  --  vertical deflection
            ball .y = VIRTUAL_HEIGHT -ball .size
        end

        if ball .x +ball .width >= VIRTUAL_WIDTH then  --  right wall
            ball .dx = -ball .dx  --  horizontal deflection
        end
```

Also the program reduces the lives when the ball goes beyond the left edge of the screen
and then the ball and the paddle both are resetted to their original position and if
lives = 0 then the game ends
```
if ball.x < 0 then
            lives = lives - 1
            ball:reset()
            paddle:reset()
            gameState = 'pause'
            if lives == 0 then
                gameState = 'end'
            end
        end
```

The programs check if all bricks are destroyed, if so the gameState is changed to 'victory'
```
	if #block_pos == 0 then
            gameState = 'victory'
        end
```

To update the paddle according to the button pressed love.keyboard.isDown is used if when a particular
key is pressed, updates the dy of the paddle accordingly
```
        if love .keyboard .isDown( 'w', 'up' ) then
            paddle .dy = -paddle.speed  --  negative velocity to move paddle up

        elseif love .keyboard .isDown( 's', 'down' ) then
            paddle .dy = paddle .speed  --  positive velocity to move paddle down
        else
            paddle .dy = 0
        end
```

Checking for collision between ball and the brick used a for loop which iterates over every row
and check if ball:collides('brick table'), if thats the case the block value at that position is
set to nil and the brick is erased from the screen the score is incremented by 1, the checking of
collision is only done in right half of the screen to make the program more optimized as there wont be
any bricks in the left half of the screen
```
if ball.x > VIRTUAL_WIDTH *0.5 then  --  only test for block-collision on right half of screen so that it becomes fast and optimized
            for index = 1, #block_pos do
                local block = block_pos[index]
                if ball :collides(  { x = block .x,  y = block .y,  width = block_width,  height = block_height }  ) then

                    for i = index,  #block_pos -1 do
                        block_pos[i] = block_pos[i +1]
                    end  --  shuffle every entry in list down one

                    block_pos [#block_pos] = nil  --  erase last entry
                    collectgarbage()  --  make sure that last position is empty
                        --  this should be automatic, but just to be certain there aren't any errors

                    score = score +1
                    ball .dx = -ball .dx  --  horizontal deflection
                    sounds['Explosion']:play()
                    break  --  don't try to access last entry in block_pos, because it no longer exists
                end  --  test for collision
            end  --  loop through all block_pos
        end  --  right side of screen
```

In love.draw first used the love.graphics.clear to set background color to dark grey
```
    love .graphics .clear(34/255, 34/255, 34/255)
```

and rendering the ball and the paddle using render function which is defined in ball.lua and paddle.lua
respectively
```
    ball :render()  --  print ball
    paddle :render()  --  print paddle
```

Display welcome message when the program is ran and if the game is started(the state is changed from
'start' to 'play') display a message for 3s and play the background soundtrack
```
if gameState == 'start' then
        love .graphics .printf(
            'Welcome to Brick Breaker!',  -- text to render
            0,                       -- starting X (0 since we're going to center it based on width)
            VIRTUAL_HEIGHT /12 -4,    -- starting Y (halfway down screen)  subtract half of font for proper alignment
            VIRTUAL_WIDTH,           -- number of pixels to center within (the entire screen here)
            'center' )               -- alignment mode, can be 'center', 'left', or 'right'

    elseif gameState == 'play' then
        sounds['BG']:play()
        if timer < 5 then
            love .graphics .printf( 'Goodluck!',  0,  VIRTUAL_HEIGHT /12 -4,  VIRTUAL_WIDTH,  'center' )
        end  --  three second timer
    end
```

and if the gameState == 'end' print a message along with final score and restart the game after short
amount of timer
```
if gameState == 'end' then
        love.graphics.printf('Game Over!', 0, VIRTUAL_HEIGHT /12 -8, VIRTUAL_WIDTH, 'center')
        love .graphics .printf( 'Final Score : '..score..'', 0,  VIRTUAL_HEIGHT /12 +10 ,  VIRTUAL_WIDTH,  'center' )
        sounds['Game_Over']:play()
        sounds['BG']:stop()
        if timerEnd > 3 then
            love.event.quit("restart")
        end
    end
```

and if the gameState == 'victory' then printing message and then restarting the game again
```
    if gameState == 'victory' then
        love.graphics.printf('You Won!', 0, VIRTUAL_HEIGHT /12 -8, VIRTUAL_WIDTH, 'center')
        sounds['BG']:stop()
        sounds['Victory']:play()
        if timerEnd > 1 then
            love.event.quit("restart")
        end
    end
```

If the game is in 'pause' state display a message which shows how to move the paddle and the keys for
restarting the game and pausing the game
```
    love.graphics.setFont(smallFont)
    if gameState == 'pause' then
        sounds['BG']:pause()
        love .graphics .printf( 'Press w and s, or arrows, to move the paddle', 0,  VIRTUAL_HEIGHT /12 +10 ,  VIRTUAL_WIDTH,  'center' )
        love.graphics.printf('Press P or Enter to pause & R to restart',0,  VIRTUAL_HEIGHT /12 +24 ,  VIRTUAL_WIDTH,  'center' )
    end
```

Printing score and lives when the game is in 'play' or 'pause' state
```
    if gameState == 'play' or gameState == 'pause' then
        love .graphics .printf( 'Score : ' ..score ..'', 20, 1, 170, 'left' )
        love.graphics.printf('Lives : '..lives..'', 120,1,170, 'left')
    end
```

Printing out the randomly generated blocks
```
    for b = 1, #block_pos do  --  draw blocks
        local block  = block_pos[b]

        love .graphics .setColor( block .r,  block. g,  block .b )
        love .graphics .rectangle( 'fill',  block.x,  block.y,  block_width -3,  block_height -3 )
    end  --  #block_pos
```

main.lua also requires ball.lua and paddle.lua which are imported as class using the class.lua
provided in the tracks


initializing various parameters of ball in ball.lua(co-ordinates, height, width and velocity)
```
function Ball :init( x, y, width, height )
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.size = 6
    self.dx = math.random(2) == 1 and -150 or 150  --  ternary operation of 'x:true?false'
    self.dy = math.random(-50, 50)
end
```
the x-velocity is is only picked from 2 equal values so that the game is fair
the y-velocity is randomly picked from range so as to make the ball move in any direction when
combined with dx(x-velocity)

AABB collision checking function
```
function Ball :collides( box )
    if self.x > box.x +box.width or self.x +self.width < box.x then
        return false
    end

    if self.y > box.y +box.height or self.y +self.height < box.y then
        return false
    end

    return true
end
```
The first condition in which the first part checks if ball is to the right of any block
and the second part checks if ball is to the right of the box(ball.width is added since lua draws
from top left corner), if thats the case
the function return false since the ball doesn't collide with any box
The second condition in which the first part checks if the ball is below any box
and the second part is for when the ball is above any box(ball.height is added since lua draws from
top left corner), if thats the case the ball returns false since the ball doesn't collides with
anything
These two conditions are checked simultaneously since collision in both direction can occur together


```
function Ball :reset()
    self.x = VIRTUAL_WIDTH /2 -3
    self.y = VIRTUAL_HEIGHT /2 -3

    self.dx = math.random(2) == 1 and -175 or 175    -- ternary operation of 'x:true?false'
    self.dy = math.random( -50, 50 )
end
```
to reset the ball as and when required

```
function Ball :update( dt )
    self.x = self.x +self.dx *dt
    self.y = self.y +self.dy *dt
end
```
to update the ball with dt(dt is mutilplied so that the pace of the game remains the same across
different frame rates)

```
function Ball :render()  --  before setting the color coz we want ball to be white
    love .graphics .rectangle( 'fill',  self.x,  self.y,  self.size,  self.size )
end
```
rendering the ball onto the screen


defining various parameters of the paddle in paddle:init(defining its co-ordinates, width, height,
speed and y velocity, since the paddle movement is restricted to y direction only
```
function Paddle :init( x, y, width, height )
    self.x = x
    self.y = y

    self.width = width
    self.height = height

    self.minimum = height *0.75
    self.maximum = height *3

    self.speed  = 250
    self.dy = 0
end
```

updating the ball with passing arguement as dt so as to keep the pace constant
```
function Paddle :update( dt )
    if self.dy < 0 then
        self.y = math.max( 0, self.y +self.dy *dt )

    elseif self.dy > 0 then
        self.y = math.min( VIRTUAL_HEIGHT -self.height,  self.y +self.dy *dt )
    end
end
```

reset function to reset when required
the paddle is resetted to the middle of VIRTUAL_HEIGHT so to render it in the middle of the screen
```
function Paddle:reset()
    self.x = 5
    self.y = VIRTUAL_HEIGHT / 2 - 15
end
```

rendering the ball
```
function Paddle :render()
    love .graphics .rectangle( 'fill',  self.x,  self.y,  self.width,  self.height )
end
```
