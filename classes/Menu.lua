-- Labyrinthium Maze Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_sin = math.sin

local helpText = {
    "Welcome to Labyrinthium - The Shifting Maze!",
    "",
    "Game Features:",
    "• Procedurally generated mazes - different every time!",
    "• Three unique biomes with different themes",
    "• Ancient spirits that roam the halls",
    "• Hidden secrets and lore to discover",
    "• Moving walls and shifting paths",
    "• Beautiful particle effects and visuals",
    "",
    "How to Play:",
    "• Navigate through the maze to find the exit",
    "• Discover hidden secrets for bonus points",
    "• Collect lore scrolls to learn the maze's history",
    "• Watch out for environmental hazards",
    "• Some walls may move or shift over time",
    "",
    "Biomes:",
    "• Ancient: Mystical blue theme with floating spirits",
    "• Forest: Natural green theme with earthy tones",
    "• Crystal: Magical purple theme with glowing crystals",
    "",
    "Controls:",
    "• WASD or Arrow Keys: Move through the maze",
    "• Space: Interact with nearby secrets/lore",
    "• F: Toggle auto-explore mode",
    "• R: Reset the current maze",
    "• ESC: Return to main menu",
    "",
    "Click anywhere to close"
}

local Menu = {}
Menu.__index = Menu

function Menu.new()
    local instance = setmetatable({}, Menu)

    instance.screenWidth = 1000
    instance.screenHeight = 700
    instance.difficulty = "medium"
    instance.biome = "ancient"
    instance.title = {
        text = "LABYRINTHIUM",
        subtitle = "The Shifting Maze",
        scale = 1,
        scaleDirection = 1,
        scaleSpeed = 0.2,
        minScale = 0.98,
        maxScale = 1.02,
        rotation = 0,
        rotationSpeed = 0.1,
        pulse = 0
    }
    instance.showHelp = false

    instance.smallFont = love.graphics.newFont(16)
    instance.mediumFont = love.graphics.newFont(24)
    instance.largeFont = love.graphics.newFont(52)
    instance.subtitleFont = love.graphics.newFont(28)
    instance.sectionFont = love.graphics.newFont(20)

    instance:createMenuButtons()
    instance:createOptionsButtons()

    return instance
end

function Menu:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    self:updateButtonPositions()
    self:updateOptionsButtonPositions()
end

function Menu:createMenuButtons()
    self.menuButtons = {
        {
            text = "Start Journey",
            action = "start",
            width = 240,
            height = 50,
            x = 0,
            y = 0,
            color = { 0.2, 0.7, 0.9 }
        },
        {
            text = "Options",
            action = "options",
            width = 240,
            height = 50,
            x = 0,
            y = 0,
            color = { 0.7, 0.5, 0.9 }
        },
        {
            text = "Quit",
            action = "quit",
            width = 240,
            height = 50,
            x = 0,
            y = 0,
            color = { 0.9, 0.3, 0.4 }
        }
    }

    -- Help button (question mark)
    self.helpButton = {
        text = "?",
        action = "help",
        width = 45,
        height = 45,
        x = 30,
        y = self.screenHeight - 55,
        color = { 0.3, 0.6, 0.9 }
    }

    self:updateButtonPositions()
end

function Menu:createOptionsButtons()
    self.optionsButtons = {
        -- Difficulty Section
        {
            text = "Easy",
            action = "difficulty easy",
            width = 140,
            height = 40,
            x = 0,
            y = 0,
            section = "difficulty",
            color = { 0.3, 0.8, 0.4 }
        },
        {
            text = "Medium",
            action = "difficulty medium",
            width = 140,
            height = 40,
            x = 0,
            y = 0,
            section = "difficulty",
            color = { 0.8, 0.7, 0.2 }
        },
        {
            text = "Hard",
            action = "difficulty hard",
            width = 140,
            height = 40,
            x = 0,
            y = 0,
            section = "difficulty",
            color = { 0.8, 0.3, 0.3 }
        },

        -- Biome Section
        {
            text = "Ancient",
            action = "biome ancient",
            width = 160,
            height = 40,
            x = 0,
            y = 0,
            section = "biome",
            color = { 0.2, 0.6, 1 }
        },
        {
            text = "Forest",
            action = "biome forest",
            width = 160,
            height = 40,
            x = 0,
            y = 0,
            section = "biome",
            color = { 0.3, 0.8, 0.4 }
        },
        {
            text = "Crystal",
            action = "biome crystal",
            width = 160,
            height = 40,
            x = 0,
            y = 0,
            section = "biome",
            color = { 0.8, 0.3, 0.9 }
        },

        -- Navigation
        {
            text = "Hold-to-Move: OFF",
            action = "toggle hold",
            width = 200,
            height = 45,
            x = 0,
            y = 0,
            section = "navigation",
            color = { 0.4, 0.7, 0.9 }
        },
        {
            text = "Back to Menu",
            action = "back",
            width = 180,
            height = 45,
            x = 0,
            y = 0,
            section = "navigation",
            color = { 0.6, 0.5, 0.8 }
        }
    }
    self:updateOptionsButtonPositions()
end

function Menu:updateButtonPositions()
    local startY = self.screenHeight / 2 + 20
    for i, button in ipairs(self.menuButtons) do
        button.x = (self.screenWidth - button.width) / 2
        button.y = startY + (i - 1) * 70
    end

    -- Update help button position
    self.helpButton.y = self.screenHeight - 55
end

function Menu:updateHoldToMoveButton(state)
    for _, button in ipairs(self.optionsButtons) do
        if button.action == "toggle hold" then
            button.text = "Hold-to-Move: " .. (state and "ON" or "OFF")
        end
    end
end

function Menu:updateOptionsButtonPositions()
    local centerX = self.screenWidth / 2
    local totalSectionsHeight = 320
    local startY = (self.screenHeight - totalSectionsHeight) / 2 + 40

    -- Difficulty buttons
    local diffButtonW, diffButtonH, diffSpacing = 140, 40, 15
    local diffTotalW = 3 * diffButtonW + 2 * diffSpacing
    local diffStartX = centerX - diffTotalW / 2
    local diffY = startY + 50

    -- Biome buttons
    local biomeButtonW, biomeButtonH, biomeSpacing = 160, 40, 12
    local biomeTotalW = 3 * biomeButtonW + 2 * biomeSpacing
    local biomeStartX = centerX - biomeTotalW / 2
    local biomeY = startY + 130

    -- Navigation buttons (Hold-to-Move + Back)
    local navY = startY + 210
    local navSpacing = 55
    local navIndex = 0

    local diffIndex, biomeIndex = 0, 0
    for _, button in ipairs(self.optionsButtons) do
        if button.section == "difficulty" then
            button.x = diffStartX + diffIndex * (diffButtonW + diffSpacing)
            button.y = diffY
            diffIndex = diffIndex + 1
        elseif button.section == "biome" then
            button.x = biomeStartX + biomeIndex * (biomeButtonW + biomeSpacing)
            button.y = biomeY
            biomeIndex = biomeIndex + 1
        elseif button.section == "navigation" then
            button.x = centerX - button.width / 2
            button.y = navY + navIndex * navSpacing
            navIndex = navIndex + 1
        end
    end
end

function Menu:update(dt, screenWidth, screenHeight)
    if screenWidth ~= self.screenWidth or screenHeight ~= self.screenHeight then
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self:updateButtonPositions()
        self:updateOptionsButtonPositions()
    end

    -- Update title animation
    self.title.scale = self.title.scale + self.title.scaleDirection * self.title.scaleSpeed * dt
    self.title.pulse = self.title.pulse + dt * 2

    if self.title.scale > self.title.maxScale then
        self.title.scale = self.title.maxScale
        self.title.scaleDirection = -1
    elseif self.title.scale < self.title.minScale then
        self.title.scale = self.title.minScale
        self.title.scaleDirection = 1
    end

    self.title.rotation = self.title.rotation + self.title.rotationSpeed * dt
end

function Menu:draw(screenWidth, screenHeight, state)
    -- Draw animated title
    local pulse = (math_sin(self.title.pulse) + 1) * 0.1
    love.graphics.setColor(0.4 + pulse, 0.7 + pulse, 1, 1)
    love.graphics.setFont(self.largeFont)

    love.graphics.push()
    love.graphics.translate(screenWidth / 2, screenHeight / 4)
    love.graphics.rotate(math_sin(self.title.rotation) * 0.03)
    love.graphics.scale(self.title.scale, self.title.scale)
    love.graphics.printf(self.title.text, -screenWidth / 2, -self.largeFont:getHeight() / 2, screenWidth, "center")
    love.graphics.pop()

    -- Draw subtitle
    love.graphics.setColor(0.8, 0.9, 1, 0.8)
    love.graphics.setFont(self.subtitleFont)
    love.graphics.printf(self.title.subtitle, 0, screenHeight / 4 + 20, screenWidth, "center")

    if state == "menu" then
        if self.showHelp then
            self:drawHelpOverlay(screenWidth, screenHeight)
        else
            self:drawMenuButtons()

            -- Draw feature highlights
            love.graphics.setColor(0.9, 0.9, 1)
            love.graphics.setFont(self.smallFont)
            love.graphics.printf("Procedural Mazes • Themed Biomes • Ancient Secrets • Moving Walls",
                0, screenHeight / 2 - 40, screenWidth, "center")

            -- Draw help button
            self:drawHelpButton()
        end
    elseif state == "options" then
        self:drawOptionsInterface()
    end

    -- Draw copyright
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.setFont(self.smallFont)
    love.graphics.printf("© 2025 Jericho Crosby – Labyrinthium", 10, screenHeight - 25, screenWidth - 20, "right")
end

function Menu:drawHelpButton()
    local button = self.helpButton
    local pulse = (math_sin(self.title.pulse * 2) + 1) * 0.2

    -- Button background with pulse
    love.graphics.setColor(button.color[1], button.color[2], button.color[3], 0.8 + pulse)
    love.graphics.circle("fill", button.x + button.width / 2, button.y + button.height / 2, button.width / 2)

    -- Button border
    love.graphics.setColor(0.9, 0.9, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", button.x + button.width / 2, button.y + button.height / 2, button.width / 2)

    -- Question mark
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.mediumFont)
    local textWidth = self.mediumFont:getWidth(button.text)
    local textHeight = self.mediumFont:getHeight()
    love.graphics.print(button.text,
        button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)

    love.graphics.setLineWidth(1)
end

function Menu:drawHelpOverlay(screenWidth, screenHeight)
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Help box dimensions
    local boxWidth = 700
    local boxHeight = 550
    local boxX = (screenWidth - boxWidth) / 2
    local boxY = (screenHeight - boxHeight) / 2

    -- Box background
    love.graphics.setColor(0.1, 0.15, 0.25, 0.95)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 12)

    -- Box border with glow
    love.graphics.setColor(0.3, 0.6, 1)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 12)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.largeFont)
    love.graphics.printf("Labyrinthium Guide", boxX, boxY + 25, boxWidth, "center")

    -- Help text setup
    love.graphics.setColor(0.9, 0.9, 1)
    love.graphics.setFont(self.smallFont)
    local lineHeight = 20

    -- 🔒 Constrain drawing area (so text doesn’t go outside the box)
    local textTop = boxY + 90
    local textHeight = boxHeight - 120
    love.graphics.setScissor(boxX, textTop, boxWidth, textHeight)

    for i, line in ipairs(helpText) do
        local y = textTop + (i - 1) * lineHeight
        if y + lineHeight < boxY + boxHeight - 20 then
            if line == "" then
                love.graphics.setColor(0.5, 0.6, 0.8, 0.5)
                love.graphics.line(boxX + 40, y + 5, boxX + boxWidth - 40, y + 5)
                love.graphics.setColor(0.9, 0.9, 1)
            else
                love.graphics.printf(line, boxX + 40, y, boxWidth - 80, "left")
            end
        end
    end

    love.graphics.setScissor()
end

function Menu:drawOptionsInterface()
    local totalSectionsHeight = 280
    local startY = (self.screenHeight - totalSectionsHeight) / 2 + 20

    -- Draw section headers
    love.graphics.setFont(self.sectionFont)
    love.graphics.setColor(0.8, 0.9, 1)
    love.graphics.printf("Select Difficulty", 0, startY + 15, self.screenWidth, "center")
    love.graphics.printf("Choose Biome", 0, startY + 105, self.screenWidth, "center")

    self:updateOptionsButtonPositions()
    self:drawOptionSection("difficulty")
    self:drawOptionSection("biome")
    self:drawOptionSection("navigation")
end

function Menu:drawOptionSection(section)
    for _, button in ipairs(self.optionsButtons) do
        if button.section == section then
            -- Draw selection highlight
            local isSelected = false
            if button.action:sub(1, 10) == "difficulty" then
                local difficulty = button.action:sub(12)
                isSelected = difficulty == self.difficulty
            elseif button.action:sub(1, 5) == "biome" then
                local biome = button.action:sub(7)
                isSelected = biome == self.biome
            end

            if isSelected then
                love.graphics.setColor(1, 1, 1, 0.3)
                love.graphics.rectangle("fill", button.x - 6, button.y - 6, button.width + 12, button.height + 12, 8)
                love.graphics.setColor(1, 1, 1, 0.8)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", button.x - 6, button.y - 6, button.width + 12, button.height + 12, 8)
                love.graphics.setLineWidth(1)
            end

            -- Draw the button
            self:drawButton(button)
        end
    end
end

function Menu:drawMenuButtons()
    for _, button in ipairs(self.menuButtons) do
        self:drawButton(button)
    end
end

function Menu:drawButton(button)
    local pulse = (math_sin(self.title.pulse * 3) + 1) * 0.05

    -- Button background
    love.graphics.setColor(button.color[1] * 0.3, button.color[2] * 0.3, button.color[3] * 0.3, 0.9)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 10, 10)

    -- Button main color with pulse
    love.graphics.setColor(button.color[1] + pulse, button.color[2] + pulse, button.color[3] + pulse, 0.8)
    love.graphics.rectangle("fill", button.x + 2, button.y + 2, button.width - 4, button.height - 4, 8, 8)

    -- Button border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 10, 10)

    -- Button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.mediumFont)
    local textWidth = self.mediumFont:getWidth(button.text)
    local textHeight = self.mediumFont:getHeight()
    love.graphics.print(button.text, button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)

    love.graphics.setLineWidth(1)
end

function Menu:handleClick(x, y, state)
    local buttons = state == "menu" and self.menuButtons or self.optionsButtons

    for _, button in ipairs(buttons) do
        if x >= button.x and x <= button.x + button.width and
            y >= button.y and y <= button.y + button.height then
            return button.action
        end
    end

    -- Check help button in menu state
    if state == "menu" then
        if self.helpButton and x >= self.helpButton.x and x <= self.helpButton.x + self.helpButton.width and
            y >= self.helpButton.y and y <= self.helpButton.y + self.helpButton.height then
            self.showHelp = true
            return "help"
        end

        -- If help is showing, any click closes it
        if self.showHelp then
            self.showHelp = false
            return "help_close"
        end
    end

    return nil
end

function Menu:setDifficulty(difficulty)
    self.difficulty = difficulty
end

function Menu:getDifficulty()
    return self.difficulty
end

function Menu:setBiome(biome)
    self.biome = biome
end

function Menu:getBiome()
    return self.biome
end

return Menu
