Paddle = Class{}

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

--  dt, delta-time is the amount of time that's passed since the last frame was rendered
function Paddle :update( dt )
    if self.dy < 0 then
        self.y = math.max( 0, self.y +self.dy *dt )

    elseif self.dy > 0 then
        self.y = math.min( VIRTUAL_HEIGHT -self.height,  self.y +self.dy *dt )
    end
end

function Paddle:reset()
    self.x = 5
    self.y = VIRTUAL_HEIGHT / 2 - 15
end

function Paddle :render()
    love .graphics .rectangle( 'fill',  self.x,  self.y,  self.width,  self.height )
end
