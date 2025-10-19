-- Labyrinthium Maze Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Game = require("classes/Game")
local Menu = require("classes/Menu")
local BackgroundManager = require("classes/BackgroundManager")

local moveDelay = 0.15
local moveTimer = 0

local game, menu, backgroundManager
local screenWidth, screenHeight
local gameState = "menu"

local function updateScreenSize()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.load()
    love.window.setTitle("Labyrinthium - The Shifting Maze")
    love.graphics.setLineStyle("smooth")
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))

    game = Game.new()
    menu = Menu.new()
    backgroundManager = BackgroundManager.new()

    updateScreenSize()
    menu:setScreenSize(screenWidth, screenHeight)
    game:setScreenSize(screenWidth, screenHeight)
end

function love.update(dt)
    updateScreenSize()
    moveTimer = moveTimer - dt

    if gameState == "playing" then
        if game:getHoldToMove() and moveTimer <= 0 then
            if love.keyboard.isDown("w", "up") then
                game:movePlayer(0, -1)
                moveTimer = moveDelay
            elseif love.keyboard.isDown("s", "down") then
                game:movePlayer(0, 1)
                moveTimer = moveDelay
            elseif love.keyboard.isDown("a", "left") then
                game:movePlayer(-1, 0)
                moveTimer = moveDelay
            elseif love.keyboard.isDown("d", "right") then
                game:movePlayer(1, 0)
                moveTimer = moveDelay
            end
        end

        game:update(dt)
    elseif gameState == "menu" or gameState == "options" then
        menu:update(dt, screenWidth, screenHeight)
    end

    backgroundManager:update(dt)
end

function love.draw()
    if gameState == "menu" or gameState == "options" then
        backgroundManager:drawMenuBackground(screenWidth, screenHeight)
    elseif gameState == "playing" then
        backgroundManager:drawGameBackground(screenWidth, screenHeight)
    end

    if gameState == "menu" or gameState == "options" then
        menu:draw(screenWidth, screenHeight, gameState)
    elseif gameState == "playing" then
        game:draw()
    end
end

-- Robust helper: parse action into prefix and value (accepts ":", spaces, etc.)
local function parseAction(action)
    if not action then return nil, nil end
    -- capture prefix (non-space), optional separator ":", optional spaces, then the rest
    local prefix, value = action:match("^(%S+)%s*%:?%s*(.*)$")
    if not prefix then return nil, nil end
    prefix = prefix:lower()
    -- trim value (both ends)
    if value then
        value = value:match("^%s*(.-)%s*$")
        if value == "" then value = nil end
    end
    return prefix, value
end

function love.mousepressed(x, y, button, istouch)
    if gameState == "menu" then
        local action = menu:handleClick(x, y, "menu")
        if action == "start" then
            gameState = "playing"
            game:startNewGame(menu:getDifficulty(), menu:getBiome())
        elseif action == "options" then
            gameState = "options"
        elseif action == "quit" then
            love.event.quit()
        end
    elseif gameState == "options" then
        local action = menu:handleClick(x, y, "options")
        if not action then return end

        local prefix, value = parseAction(action)

        if prefix == "back" then
            gameState = "menu"
        elseif prefix == "difficulty" then
            if value then
                -- If you want normalized values (lowercase), call value:lower() here
                menu:setDifficulty(value)
            else
                print("Warning: difficulty action without value:", action)
            end
        elseif prefix == "biome" then
            if value then
                menu:setBiome(value)
            else
                print("Warning: biome action without value:", action)
            end
        elseif prefix == "toggle" and value == "hold" then
            game:toggleHoldToMove()
            menu:updateHoldToMoveButton(game:getHoldToMove())
        else
            -- fallback: support the exact "toggle hold" text if parseAction behaved unexpectedly
            if action:lower() == "toggle hold" then
                game:toggleHoldToMove()
                menu:updateHoldToMoveButton(game:getHoldToMove())
            else
                print("Unhandled options action:", action)
            end
        end
    elseif gameState == "playing" then
        -- Example behaviour: if player clicks while game over, return to menu
        if game:isGameOver() then
            gameState = "menu"
        end
        -- (Add other in-game click handling here if needed)
    end
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "playing" or gameState == "options" then
            gameState = "menu"
        else
            love.event.quit()
        end
    elseif key == "r" and gameState == "playing" then
        game:resetGame()
    elseif key == "f" and gameState == "playing" then
        game:toggleAutoExplore()
    elseif (key == "w" or key == "up") and gameState == "playing" then
        game:movePlayer(0, -1)
    elseif (key == "s" or key == "down") and gameState == "playing" then
        game:movePlayer(0, 1)
    elseif (key == "a" or key == "left") and gameState == "playing" then
        game:movePlayer(-1, 0)
    elseif (key == "d" or key == "right") and gameState == "playing" then
        game:movePlayer(1, 0)
    elseif key == " " and gameState == "playing" then
        game:interact()
    end
end

function love.resize(w, h)
    updateScreenSize()
    menu:setScreenSize(screenWidth, screenHeight)
    game:setScreenSize(screenWidth, screenHeight)
end
