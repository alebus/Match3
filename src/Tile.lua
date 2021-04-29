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



  -- particle system stuff
  -- todo see note about this being slow and ensure not doing anything over and over that you can do just once
  self.psystem = love.graphics.newParticleSystem(gParticle, 64)

  -- todo 
  self.psystem:setParticleLifetime(0.5, 5)

  -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
  -- gives generally downward 
  self.psystem:setLinearAcceleration(-15, 0, 15, 80)

  -- spread of particles; normal looks more natural than uniform
  self.psystem:setEmissionArea('normal', 10, 10)


   
    -- todo not sure if this should be in this section or not
    -- and later need to have it only happen sometimes
    -- and change color as needed
    self.psystem:setColors(.5,.5,.5,.5,.2,.2,.2,.5)
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



function Tile:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end