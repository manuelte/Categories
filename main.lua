-- Manuel Reiner
-- Categories party game based on the tabletop game Tapple
-- Coded in Lua for the Playdate device

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics
local allLetters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","W"}
local remainingLetters = 20
local playableLetters = {}
local currentLetterIndex = 1
local lastRemovedLetter = "A"
local phase = 1
local allowRedo = false
local turnTimer = nil





local categories = {
    "Song titles",
    "Cartoons",
    "Plants and trees",
    "Animals",
    "Things at the Garden",
    "Sports Equipment",
    "Things at a party",
    "Adjectives",
    "Something yellow",
    "Countries",
    "Board games",
    "Comic book characters",
    "Breakfast foods",
    "Pet names",
    "Weapons",
    "Pizza topings",
    "TV Shows",
    "Fruits",
    "Holidays",
    "Things that are square",
    "Insects",
    "Things that grow",
    "Things that are black",
    "Something red",
    "Movie titles",
    "Fears",
    "States or provinces",
    "Tools",
    "Things in the sky",
    "School subjects",
    "Ice cream flavors",
    "Things that are cold",
    "Birds",
    "Found in water",
    "Colors",
    "Toys",
    "Cities",
    "Things in the kitchen",
    "Body parts",
    "Seen at the mall",
    "Mode of transportation",
    "Brands",
    "Things that are hot",
    "Fashion",
    "Book titles",
    "Fabric patterns"
}
local catArray, catHash = table.getsize(categories)


function selectCategory()
    catSelected = math.random(catArray)
end


function myGameSetUp()
    currentFont = gfx.font.new("Fonts/Nontendo")
    gfx.setFont(currentFont)
    gfx.clear()
    playableLetters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","W"}
    remainingLetters = 20
    currentLetterIndex = 1
    lastRemovedLetter = "A"
    phase = 1
    selectCategory()
end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()
-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()    

    currentLetterIndex = currentLetterIndex + playdate.getCrankTicks(remainingLetters)

    if (currentLetterIndex>remainingLetters)
    then
        currentLetterIndex = 1
    end

    if (currentLetterIndex<1)
    then
        currentLetterIndex = remainingLetters
    end

    if (phase == 3 and turnTimer.currentTime >=15000) then
        myGameSetUp()
    end

    gfx.clear()
    gfx.drawText(categories[catSelected], 10,10)

    if (phase == 1) then
        gfx.drawText("A to confirm, B to reshuffle", 10, 40)
    elseif (phase ==3 ) then
        gfx.drawText(playableLetters[currentLetterIndex], 200,140)
        gfx.drawText(math.ceil((15000 - turnTimer.currentTime)/1000), 300, 10)
    end

    -- catch the buttons to remove a letter and restart the timer, or undo
    if playdate.buttonJustPressed(playdate.kButtonA)
    then

        if (phase == 1) then
            turnTimer = playdate.timer.new(15000)
            turnTimer.discardOnCompletion = false
            phase = 3
        elseif (phase == 3) then
            if (remainingLetters>1)
            then
                lastRemovedLetter = playableLetters[currentLetterIndex]
                table.remove(playableLetters,currentLetterIndex)
                remainingLetters -= 1
                allowRedo = true
                turnTimer:reset()            
            else
                myGameSetUp()
            end
        end
    end

    if playdate.buttonJustPressed(playdate.kButtonB)
    then
        if (phase == 1) then
            selectCategory()
        elseif (phase == 3) then
            if (remainingLetters<20 and allowRedo)
            then
                table.insert(playableLetters,lastRemovedLetter)
                table.sort(playableLetters)
                remainingLetters += 1
                allowRedo = false
                turnTimer:reset()
            end
        end
    end
    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)
    --print(currentLetterIndex + "/" + remainingLetters)
    gfx.sprite.update()
    playdate.timer.updateTimers()

end