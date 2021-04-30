--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety





end




-- todo - Am adding this so that we don't do a psystem until we have coordinates etc
-- previously this was in Tile:init
function Tile:psystemInit()


    -- particle system stuff
    -- todo see note about this being slow and ensure not doing anything over and over that you can do just once
    self.psystem = love.graphics.newParticleSystem(gParticle, 64)

    -- todo check / experiment with all these values and locations of all this stuff too
    -- like here make it shorter but emit it again
    self.psystem:setParticleLifetime(.5, 2)

    -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 
    self.psystem:setLinearAcceleration(-5, -5, 10, 10)

    -- spread of particles; normal looks more natural than uniform
    -- todo try uniform and other settings
    self.psystem:setEmissionArea('uniform', 10, 10)
   
    -- todo not sure if this should be in this section or not
    -- and later need to have it only happen sometimes, not for all tiles obvi
    -- and change color as needed
    self.psystem:setColors(150, 255, 255, 0, 150, 255, 150, 100, 150, 255, 255, 0)
    
    self.psystem:setSizes(.2)



end


-- I'm putting this here so I can do it on a timer from the playstate 
-- because we want it emtting every couple seconds
function Tile:emit()

    --self.psystem:setPosition( self.x, self.y )
    self.psystem:emit(64)    

end





--[[  todo - see note - could probably do it here as well
function Tile:update(dt)

    self.psystem:update(dt)

end
]]



function Tile:render(x, y)

    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    
end



function Tile:renderParticles(x, y)
    --self.psystem:setPosition( self.x, self.y )
    love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16)
end