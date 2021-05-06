--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}

    self.level = level 

    print("level in board-init:", self.level)

    
    self:initializeTiles()

    print("checking the board to ensure there is at least one poss match")
    
    if self:checkBoard() then
        print("there is at least one match possible")
    else
        -- here we need to redo the board
        print("no matches possible on this board!")
        print("self:initializeTiles()")
        self:initializeTiles()
    end


end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            
            -- create a new tile at X,Y 
            -- the max for color is math.random(18) and the max for pattern is math.random(6)
            
            if self.level == 1 then
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(6), 1))
            elseif self.level == 2 or self.level == 3 then
                -- 12 or 18 colors
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(self.level * 6), 1))
                -- all colors and all patterns
            elseif self.level >= 4 then
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(18), math.random(6)))
            end 
               
        
        end
    end

    while self:calculateMatches("nosound") do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches(ns)
    local matches = {}

    nosound = false

    if ns == "nosound" then
        nosound = true
    end

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1

        shinyTile = false
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1

                
            else
               
                -- [Airn] ok so it doesn't run all this until the matching is complete for that color

                 
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
               

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}


                    
                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                        
                        if self.tiles[y][x2].shiny then 
                            shinyTile = true
                        end

                        -- ok so we will do this but may overwrite it later
                        table.insert(match, self.tiles[y][x2])                     
                    end

                    if shinyTile then 
                        -- if any were shiny in the match then add the whole row instead

                        for x2 = 8, 1, -1 do
                            table.insert(match, self.tiles[y][x2])
                        end

                        -- prevent sound from playing when there is a new board at start
                        if nosound == false then 
                            print("playing next-level sound")
                            gSounds['next-level']:play()
                        end
                    end 

                    -- add this match to our total matches table
                    table.insert(matches, match)
                    
                    shinyTile = false
                end

                matchNum = 1
           
                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do

                if self.tiles[y][x].shiny then 
                    shinyTile = true
                end

                table.insert(match, self.tiles[y][x])
            end

            if shinyTile then
               
                for x2 = 8, 1, -1 do
                    table.insert(match, self.tiles[y][x2])
                    if nosound == false then 
                        print("playing next-level sound")
                        gSounds['next-level']:play()
                    end
                end
           
            end


            table.insert(matches, match)
            shinyTile = false
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

-- todo also look at how the looping works here
--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end




--[[
    Ensure the board has at least one match by trying to move blocks around and seeing if there is a match.
    Returns true if there was at least one match.  
]]
function Board:checkBoard()

    -- start moving every tile in all directions to see if there is a match
    -- every time we move one, check for a match, then if we get one we can return
    -- rem gridX is board location vs x y which are the actual coords 
  
    for y = 1, 8 do
        
        for x = 1, 8 do
            
            
            for a = 1, 4 do
            
                dontTest = false
                print("a:", a)
               
                -- checking all 4 directions unless they would go off the board
                if a == 1 and y > 1 then 
                    w = y-1
                    z = x
                elseif a == 2 and x < 8 then
                    w = y
                    z = x+1
                elseif a == 3 and y < 8 then
                    w = y+1
                    z = x
                elseif a == 4 and x > 1 then 
                    w = y
                    z = x-1
                else 
                    dontTest = true
                end
               
               if dontTest then 
                    print("skipping test")
               else
                            
                
                    print("swappping tiles to test...before swap:")
                    print("firstTile - y, x: ", y, x)
                    print("testTile - w, z:", w, z)

                    local firstTile = self.tiles[y][x]

                    local tempX = firstTile.gridX
                    local tempY = firstTile.gridY

                  
                    local testTile = self.tiles[w][z]
                               

                    firstTile.gridX = testTile.gridX
                    firstTile.gridY = testTile.gridY
                
                    testTile.gridX = tempX
                    testTile.gridY = tempY

                    -- swap the tiles in the table
                    self.tiles[firstTile.gridY][firstTile.gridX] = firstTile
                    self.tiles[testTile.gridY][testTile.gridX] = testTile
                
                    print("swappping tiles to test...after swap:")
                    --print("firstTile.color: ", firstTile.color)
                    print("firstTile.gridY, gridX: ", firstTile.gridY, firstTile.gridX)
                    --print("testTile.color: ", testTile.color)
                    print("testTile.gridY, gridX: ", testTile.gridY, testTile.gridX)


                    local didMatch = self:calculateMatches("nosound")

                    -- return i.e. end function early if there is a match 
                    -- but always swap the tiles back to how they were first
                    
                    -- swap the tiles back
                    print("swappping tiles back")
                    
                    
                    local tempX = firstTile.gridX
                    local tempY = firstTile.gridY
                    
                    firstTile.gridX = testTile.gridX
                    firstTile.gridY = testTile.gridY
                
                    testTile.gridX = tempX
                    testTile.gridY = tempY
              

                    self.tiles[firstTile.gridY][firstTile.gridX] = firstTile
                    self.tiles[testTile.gridY][testTile.gridX] = testTile
                
                    --print("firstTile.color: ", firstTile.color)
                    print("firstTile.gridY, gridX: ", firstTile.gridY, firstTile.gridX)
                    --print("testTile.color: ", testTile.color)
                    print("testTile.gridY, gridX: ", testTile.gridY, testTile.gridX)



                    print("didMatch", didMatch)

                    if didMatch then
                        print("didMatch is true, returning true from Board:checkBoard")
                        return true
                    end

                end -- end of loop 1-4
            end 
        
    end
    
    end 

    print("didMatch was never true, returning false from Board:checkBoard")
    return false

end







--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    
    -- create replacement tiles at the top of the screen
    print("creating replacement tiles")
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                if self.level == 1 then
                    tile = Tile(x, y, math.random(6), 1)
                elseif self.level == 2 or self.level == 3 then
                    -- 12 or 18 colors
                    tile = Tile(x, y, math.random(self.level * 6), 1)
                    -- all colors and all patterns
                elseif self.level >= 4 then
                    tile = Tile(x, y, math.random(18), math.random(6))
                end 

                tile.y = -32
                self.tiles[y][x] = tile

                if self.tiles[y][x].shiny then 
                    self.tiles[y][x]:psystemInit()
                end

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end




-- init for particle system
function Board:pInit()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do

            if self.tiles[y][x].shiny then 
                self.tiles[y][x]:psystemInit()
            end
        end
    end
end


-- emit particles
function Board:emitP()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            
            if self.tiles[y][x].shiny then 
                self.tiles[y][x]:emit()
            end
        end
    end
end




-- todo - why are the loops done in this way vs pairs()
-- this was added to update the particle system
function Board:update(dt)
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            
            if self.tiles[y][x].shiny then 
                self.tiles[y][x].psystem:update(dt)
            end
        end
    end
end



function Board:render(particlesTF)
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
            

            -- don't render particles until we are in the playstate - this is because it's implemented to render after we have proper xy values for the tiles
            -- also don't render unless it is a shiny tile
            if particlesTF and self.tiles[y][x].shiny then 
                self.tiles[y][x]:renderParticles(self.x, self.y)
            end
        end
    end
end