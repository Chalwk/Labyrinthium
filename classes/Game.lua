-- Labyrinthium Maze Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_min = math.min
local math_sin = math.sin
local math_cos = math.cos
local math_abs = math.abs
local math_max = math.max
local math_pi = math.pi
local math_floor = math.floor
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove

local Game = {}
Game.__index = Game

function Game.new()
    local instance = setmetatable({}, Game)

    instance.screenWidth = 1000
    instance.screenHeight = 700
    instance.mazeSize = 15
    instance.cellSize = 40
    instance.maze = {}
    instance.player = {x = 1, y = 1}
    instance.exit = {x = 1, y = 1}
    instance.gameOver = false
    instance.gameWon = false
    instance.holdToMove = false
    instance.difficulty = "medium"
    instance.biome = "ancient"
    instance.animations = {}
    instance.particles = {}
    instance.secrets = {}
    instance.loreItems = {}
    instance.movingWalls = {}
    instance.shiftingPaths = {}
    instance.hazards = {}
    instance.spirits = {}
    instance.autoExplore = false
    instance.startTime = 0
    instance.elapsedTime = 0
    instance.secretsFound = 0
    instance.loreCollected = 0
    instance.playerColor = {0.2, 0.8, 1}
    instance.pathColor = {0.3, 0.6, 0.9}
    instance.wallColor = {0.1, 0.2, 0.4}

    instance.loreTexts = {
        "The Labyrinthium shifts with ancient magic...",
        "Whispers speak of a forgotten civilization...",
        "Some walls are not what they seem...",
        "Time flows differently within these halls...",
        "The spirits guard secrets older than memory...",
        "Every path tells a story, every turn a legend...",
        "The maze breathes, it lives, it remembers...",
        "To find the way out, one must understand the way in..."
    }

    instance:generateMaze()
    return instance
end

function Game:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    self:calculateCellSize()
end

function Game:calculateCellSize()
    local maxSize = math_min(self.screenWidth, self.screenHeight) * 0.85
    self.cellSize = math_floor(maxSize / self.mazeSize)
    self.mazeX = (self.screenWidth - self.cellSize * self.mazeSize) / 2
    self.mazeY = (self.screenHeight - self.cellSize * self.mazeSize) / 2 + 30
end

function Game:generateMaze()
    self.maze = {}
    for i = 1, self.mazeSize do
        self.maze[i] = {}
        for j = 1, self.mazeSize do
            self.maze[i][j] = {
                walls = {top = true, right = true, bottom = true, left = true},
                visited = false,
                path = false,
                secret = math_random() < 0.1,
                hazard = math_random() < 0.05,
                shifting = math_random() < 0.08
            }
        end
    end

    -- Recursive backtracking maze generation
    self:carvePassages(1, 1)

    -- Set player start and exit
    self.player = {x = 1, y = 1}
    self.exit = {x = self.mazeSize, y = self.mazeSize}
    self.maze[self.exit.y][self.exit.x].exit = true

    -- Generate secrets and lore
    self:generateSecrets()
    self:generateSpirits()
    self:generateMovingWalls()
end

function Game:carvePassages(x, y)
    self.maze[y][x].visited = true
    self.maze[y][x].path = true

    local directions = {
        {dx = 0, dy = -1, wall = "top", opposite = "bottom"},
        {dx = 1, dy = 0, wall = "right", opposite = "left"},
        {dx = 0, dy = 1, wall = "bottom", opposite = "top"},
        {dx = -1, dy = 0, wall = "left", opposite = "right"}
    }

    -- Shuffle directions
    for i = #directions, 2, -1 do
        local j = math_random(1, i)
        directions[i], directions[j] = directions[j], directions[i]
    end

    for _, dir in ipairs(directions) do
        local nx, ny = x + dir.dx, y + dir.dy
        if nx >= 1 and nx <= self.mazeSize and ny >= 1 and ny <= self.mazeSize and not self.maze[ny][nx].visited then
            self.maze[y][x].walls[dir.wall] = false
            self.maze[ny][nx].walls[dir.opposite] = false
            self:carvePassages(nx, ny)
        end
    end
end

function Game:generateSecrets()
    self.secrets = {}
    self.loreItems = {}

    for i = 1, 5 do
        local x, y = math_random(2, self.mazeSize - 1), math_random(2, self.mazeSize - 1)
        if self.maze[y][x].path and not (x == 1 and y == 1) and not (x == self.mazeSize and y == self.mazeSize) then
            table_insert(self.secrets, {x = x, y = y, found = false})
        end
    end

    for i = 1, 3 do
        local x, y = math_random(2, self.mazeSize - 1), math_random(2, self.mazeSize - 1)
        if self.maze[y][x].path and not (x == 1 and y == 1) and not (x == self.mazeSize and y == self.mazeSize) then
            table_insert(self.loreItems, {
                x = x,
                y = y,
                collected = false,
                text = self.loreTexts[math_random(1, #self.loreTexts)]
            })
        end
    end
end

function Game:generateSpirits()
    self.spirits = {}
    local spiritCount = math_floor(self.mazeSize * 0.3)

    for i = 1, spiritCount do
        local x, y = math_random(2, self.mazeSize - 1), math_random(2, self.mazeSize - 1)
        if self.maze[y][x].path then
            table_insert(self.spirits, {
                x = x,
                y = y,
                speed = math_random(0.5, 2),
                angle = math_random() * math_pi * 2,
                color = {math_random(0.7, 1), math_random(0.5, 0.9), math_random(0.3, 0.7)},
                size = math_random(0.8, 1.5),
                pulse = 0
            })
        end
    end
end

function Game:generateMovingWalls()
    self.movingWalls = {}
    local wallCount = math_floor(self.mazeSize * 0.2)

    for i = 1, wallCount do
        local x, y = math_random(1, self.mazeSize), math_random(1, self.mazeSize)
        if not self.maze[y][x].path then
            table_insert(self.movingWalls, {
                x = x,
                y = y,
                direction = math_random(1, 4),
                speed = math_random(0.1, 0.3),
                progress = 0
            })
        end
    end
end

function Game:startNewGame(difficulty, biome)
    self.difficulty = difficulty or "medium"
    self.biome = biome or "ancient"

    -- Set maze size based on difficulty
    if self.difficulty == "easy" then
        self.mazeSize = 12
    elseif self.difficulty == "medium" then
        self.mazeSize = 18
    else -- hard
        self.mazeSize = 24
    end

    -- Set colors based on biome
    if self.biome == "forest" then
        self.playerColor = { 0.2, 0.8, 0.3 }
        self.pathColor = { 0.3, 0.7, 0.4 }
        self.wallColor = { 0.1, 0.4, 0.2 }
    elseif self.biome == "crystal" then
        self.playerColor = { 0.8, 0.3, 0.9 }
        self.pathColor = { 0.7, 0.4, 0.8 }
        self.wallColor = { 0.4, 0.1, 0.5 }
    else -- ancient
        self.playerColor = { 0.2, 0.8, 1 }
        self.pathColor = { 0.3, 0.6, 0.9 }
        self.wallColor = { 0.1, 0.2, 0.4 }
    end

    self:calculateCellSize()
    self:generateMaze()
    self.gameOver = false
    self.gameWon = false
    self.autoExplore = false
    self.secretsFound = 0
    self.loreCollected = 0
    self.startTime = love.timer.getTime()
    self.elapsedTime = 0
end

function Game:setHoldToMove(enabled)
    self.holdToMove = enabled
end

function Game:toggleHoldToMove()
    self.holdToMove = not self.holdToMove
end

function Game:getHoldToMove()
    return self.holdToMove
end


function Game:resetGame()
    self:startNewGame(self.difficulty, self.biome)
end

function Game:toggleAutoExplore()
    self.autoExplore = not self.autoExplore
end

function Game:movePlayer(dx, dy)
    if self.gameOver then return end

    local newX, newY = self.player.x + dx, self.player.y + dy

    if newX >= 1 and newX <= self.mazeSize and newY >= 1 and newY <= self.mazeSize then
        local cell = self.maze[self.player.y][self.player.x]
        local newCell = self.maze[newY][newX]

        -- Check if movement is allowed (no wall in the direction)
        if (dx == 1 and not cell.walls.right) or
           (dx == -1 and not cell.walls.left) or
           (dy == 1 and not cell.walls.bottom) or
           (dy == -1 and not cell.walls.top) then

            self.player.x, self.player.y = newX, newY

            -- Create movement particles
            self:createParticles(
                self.mazeX + (self.player.x - 0.5) * self.cellSize,
                self.mazeY + (self.player.y - 0.5) * self.cellSize,
                self.playerColor, 3
            )

            -- Check for secrets
            self:checkSecrets()

            -- Check for lore
            self:checkLore()

            -- Check for exit
            if self.player.x == self.exit.x and self.player.y == self.exit.y then
                self.gameOver = true
                self.gameWon = true
                self:createWinParticles()
            end
        end
    end
end

function Game:interact()
    if self.gameOver then return end

    -- Check for nearby secrets or lore
    for _, secret in ipairs(self.secrets) do
        if not secret.found and math_abs(secret.x - self.player.x) <= 1 and math_abs(secret.y - self.player.y) <= 1 then
            secret.found = true
            self.secretsFound = self.secretsFound + 1
            self:createParticles(
                self.mazeX + (secret.x - 0.5) * self.cellSize,
                self.mazeY + (secret.y - 0.5) * self.cellSize,
                {1, 0.8, 0.2}, 8
            )
        end
    end

    for _, lore in ipairs(self.loreItems) do
        if not lore.collected and math_abs(lore.x - self.player.x) <= 1 and math_abs(lore.y - self.player.y) <= 1 then
            lore.collected = true
            self.loreCollected = self.loreCollected + 1
            table_insert(self.animations, {
                type = "lore",
                text = lore.text,
                progress = 0,
                duration = 4
            })
            self:createParticles(
                self.mazeX + (lore.x - 0.5) * self.cellSize,
                self.mazeY + (lore.y - 0.5) * self.cellSize,
                {0.8, 0.2, 1}, 12
            )
        end
    end
end

function Game:checkSecrets()
    for _, secret in ipairs(self.secrets) do
        if not secret.found and secret.x == self.player.x and secret.y == self.player.y then
            secret.found = true
            self.secretsFound = self.secretsFound + 1
            self:createParticles(
                self.mazeX + (secret.x - 0.5) * self.cellSize,
                self.mazeY + (secret.y - 0.5) * self.cellSize,
                {1, 0.8, 0.2}, 8
            )
        end
    end
end

function Game:checkLore()
    for _, lore in ipairs(self.loreItems) do
        if not lore.collected and lore.x == self.player.x and lore.y == self.player.y then
            lore.collected = true
            self.loreCollected = self.loreCollected + 1
            table_insert(self.animations, {
                type = "lore",
                text = lore.text,
                progress = 0,
                duration = 4
            })
            self:createParticles(
                self.mazeX + (lore.x - 0.5) * self.cellSize,
                self.mazeY + (lore.y - 0.5) * self.cellSize,
                {0.8, 0.2, 1}, 12
            )
        end
    end
end

function Game:update(dt)
    self.elapsedTime = love.timer.getTime() - self.startTime

    -- Update animations
    for i = #self.animations, 1, -1 do
        local anim = self.animations[i]
        anim.progress = anim.progress + dt / anim.duration
        if anim.progress >= 1 then
            table_remove(self.animations, i)
        end
    end

    -- Update particles
    for i = #self.particles, 1, -1 do
        local particle = self.particles[i]
        particle.life = particle.life - dt
        particle.x = particle.x + particle.dx * dt
        particle.y = particle.y + particle.dy * dt
        particle.rotation = particle.rotation + particle.dr * dt

        if particle.life <= 0 then
            table_remove(self.particles, i)
        end
    end

    -- Update spirits
    for _, spirit in ipairs(self.spirits) do
        spirit.pulse = spirit.pulse + dt * spirit.speed
        spirit.angle = spirit.angle + dt * 0.5
    end

    -- Update moving walls
    for _, wall in ipairs(self.movingWalls) do
        wall.progress = wall.progress + dt * wall.speed
        if wall.progress >= 1 then
            wall.progress = 0
            wall.direction = math_random(1, 4)
        end
    end

    -- Auto-explore if enabled
    if self.autoExplore and not self.gameOver then
        if math_random() < 0.1 then
            local directions = {
                {0, -1}, {1, 0}, {0, 1}, {-1, 0}
            }
            local dir = directions[math_random(1, 4)]
            self:movePlayer(dir[1], dir[2])
        end
    end
end

function Game:createParticles(x, y, color, count)
    for _ = 1, count or 6 do
        table_insert(self.particles, {
            x = x,
            y = y,
            dx = (math_random() - 0.5) * 60,
            dy = (math_random() - 0.5) * 60,
            dr = (math_random() - 0.5) * 6,
            life = math_random(0.8, 1.5),
            color = color,
            size = math_random(2, 6),
            rotation = math_random() * math_pi * 2
        })
    end
end

function Game:createWinParticles()
    for i = 1, 20 do
        local x = self.mazeX + (self.exit.x - 0.5) * self.cellSize
        local y = self.mazeY + (self.exit.y - 0.5) * self.cellSize
        self:createParticles(x, y, {0.2, 1, 0.2}, 1)
    end
end

function Game:draw()
    self:drawMaze()
    self:drawSecrets()
    self:drawLore()
    self:drawSpirits()
    self:drawPlayer()
    self:drawExit()
    self:drawUI()
    self:drawParticles()
    self:drawAnimations()

    if self.gameOver then
        self:drawGameOver()
    end
end

function Game:drawMaze()
    -- Draw maze background
    love.graphics.setColor(0.05, 0.08, 0.15, 0.9)
    love.graphics.rectangle("fill", self.mazeX - 15, self.mazeY - 15,
        self.cellSize * self.mazeSize + 30,
        self.cellSize * self.mazeSize + 30, 8)

    -- Calculate pulsing brightness for walls
    local pulse = (math.sin(self.elapsedTime * 2) + 1) * 0.25 + 0.75

    for y = 1, self.mazeSize do
        for x = 1, self.mazeSize do
            local cell = self.maze[y][x]
            local cellX = self.mazeX + (x - 1) * self.cellSize
            local cellY = self.mazeY + (y - 1) * self.cellSize

            -- Draw path background
            if cell.path then
                love.graphics.setColor(self.pathColor[1], self.pathColor[2], self.pathColor[3], 0.3)
                love.graphics.rectangle("fill", cellX, cellY, self.cellSize, self.cellSize)
            end

            -------------------------------------------------------------------
            --  WALLS:  Two-layered glowing walls with animated brightness
            -------------------------------------------------------------------

            -- Outer glow (darker, thicker base)
            love.graphics.setColor(
                self.wallColor[1] * 0.3,
                self.wallColor[2] * 0.3,
                self.wallColor[3] * 0.3,
                1
            )
            love.graphics.setLineWidth(6)

            if cell.walls.top then
                love.graphics.line(cellX, cellY, cellX + self.cellSize, cellY)
            end
            if cell.walls.right then
                love.graphics.line(cellX + self.cellSize, cellY, cellX + self.cellSize, cellY + self.cellSize)
            end
            if cell.walls.bottom then
                love.graphics.line(cellX, cellY + self.cellSize, cellX + self.cellSize, cellY + self.cellSize)
            end
            if cell.walls.left then
                love.graphics.line(cellX, cellY, cellX, cellY + self.cellSize)
            end

            -- Inner pulse (brighter core line)
            love.graphics.setColor(
                self.wallColor[1] * pulse,
                self.wallColor[2] * pulse,
                self.wallColor[3] * pulse,
                1
            )
            love.graphics.setLineWidth(3)

            if cell.walls.top then
                love.graphics.line(cellX, cellY, cellX + self.cellSize, cellY)
            end
            if cell.walls.right then
                love.graphics.line(cellX + self.cellSize, cellY, cellX + self.cellSize, cellY + self.cellSize)
            end
            if cell.walls.bottom then
                love.graphics.line(cellX, cellY + self.cellSize, cellX + self.cellSize, cellY + self.cellSize)
            end
            if cell.walls.left then
                love.graphics.line(cellX, cellY, cellX, cellY + self.cellSize)
            end

            love.graphics.setLineWidth(1)
        end
    end
end


function Game:drawPlayer()
    local x = self.mazeX + (self.player.x - 0.5) * self.cellSize
    local y = self.mazeY + (self.player.y - 0.5) * self.cellSize

    -- Player glow
    local pulse = (math_sin(self.elapsedTime * 5) + 1) * 0.2
    love.graphics.setColor(self.playerColor[1], self.playerColor[2], self.playerColor[3], 0.4 + pulse)
    love.graphics.circle("fill", x, y, self.cellSize * 0.4)

    -- Player core
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("fill", x, y, self.cellSize * 0.2)

    -- Player direction indicator
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.circle("fill", x, y, self.cellSize * 0.1)
end

function Game:drawExit()
    local x = self.mazeX + (self.exit.x - 0.5) * self.cellSize
    local y = self.mazeY + (self.exit.y - 0.5) * self.cellSize

    -- Exit portal with animation
    local pulse = (math_sin(self.elapsedTime * 3) + 1) * 0.3
    love.graphics.setColor(0.2, 1, 0.2, 0.6 + pulse)
    love.graphics.circle("fill", x, y, self.cellSize * 0.3)

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("line", x, y, self.cellSize * 0.3)
    love.graphics.circle("line", x, y, self.cellSize * 0.2)
end

function Game:drawSecrets()
    for _, secret in ipairs(self.secrets) do
        if not secret.found then
            local x = self.mazeX + (secret.x - 0.5) * self.cellSize
            local y = self.mazeY + (secret.y - 0.5) * self.cellSize

            local pulse = (math_sin(self.elapsedTime * 4) + 1) * 0.2
            love.graphics.setColor(1, 0.8, 0.2, 0.7 + pulse)
            love.graphics.circle("line", x, y, self.cellSize * 0.25)

            love.graphics.setColor(1, 0.9, 0.3, 0.5)
            love.graphics.circle("fill", x, y, self.cellSize * 0.15)
        end
    end
end

function Game:drawLore()
    for _, lore in ipairs(self.loreItems) do
        if not lore.collected then
            local x = self.mazeX + (lore.x - 0.5) * self.cellSize
            local y = self.mazeY + (lore.y - 0.5) * self.cellSize

            local pulse = (math_sin(self.elapsedTime * 5) + 1) * 0.25
            love.graphics.setColor(0.8, 0.2, 1, 0.8 + pulse)

            -- Lore symbol (scroll)
            love.graphics.rectangle("fill", x - self.cellSize * 0.2, y - self.cellSize * 0.1,
                self.cellSize * 0.4, self.cellSize * 0.2, 2)
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.rectangle("line", x - self.cellSize * 0.2, y - self.cellSize * 0.1,
                self.cellSize * 0.4, self.cellSize * 0.2, 2)
        end
    end
end

function Game:drawSpirits()
    for _, spirit in ipairs(self.spirits) do
        local x = self.mazeX + (spirit.x - 0.5) * self.cellSize
        local y = self.mazeY + (spirit.y - 0.5) * self.cellSize

        local pulse = (math_sin(spirit.pulse) + 1) * 0.3
        local size = self.cellSize * 0.2 * spirit.size

        love.graphics.setColor(spirit.color[1], spirit.color[2], spirit.color[3], 0.6 + pulse)

        love.graphics.push()
        love.graphics.translate(x, y)
        love.graphics.rotate(spirit.angle)

        -- Spirit shape (ethereal triangle)
        love.graphics.polygon("fill",
            0, -size,
            size * 0.8, size,
            -size * 0.8, size
        )

        love.graphics.pop()
    end
end

function Game:drawUI()
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)

    local texts = {
        "Labyrinthium - " .. self.biome:upper() .. " Biome",
        "Difficulty: " .. self.difficulty,
        "Time: " .. math_floor(self.elapsedTime) .. "s",
        "Secrets: " .. self.secretsFound .. "/5",
        "Lore: " .. self.loreCollected .. "/3"
    }

    local maxWidth = 0
    for _, t in ipairs(texts) do
        local w = font:getWidth(t)
        if w > maxWidth then maxWidth = w end
    end
    local boxWidth = maxWidth + 40
    local boxHeight = #texts * 25 + 20

    love.graphics.setColor(0.1, 0.15, 0.25, 0.3)
    love.graphics.rectangle("fill", 20, 20, boxWidth, boxHeight, 5)

    love.graphics.setColor(1, 1, 1)
    for i, t in ipairs(texts) do
        love.graphics.print(t, 35, 35 + (i - 1) * 25)
    end
end

function Game:drawParticles()
    for _, particle in ipairs(self.particles) do
        local alpha = math_min(1, particle.life * 1.5)
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], alpha)
        love.graphics.push()
        love.graphics.translate(particle.x, particle.y)
        love.graphics.rotate(particle.rotation)
        love.graphics.circle("fill", 0, 0, particle.size)
        love.graphics.pop()
    end
end

function Game:drawAnimations()
    for _, anim in ipairs(self.animations) do
        if anim.type == "lore" then
            local alpha = math_min(1, (1 - math_abs(anim.progress - 0.5) * 2) * 2)
            love.graphics.setColor(0, 0, 0, 0.7 * alpha)
            love.graphics.rectangle("fill", 0, self.screenHeight / 2 - 40, self.screenWidth, 80)

            love.graphics.setColor(0.8, 0.2, 1, alpha)
            love.graphics.setFont(love.graphics.newFont(20))
            love.graphics.printf(anim.text, 50, self.screenHeight / 2 - 20, self.screenWidth - 100, "center")
        end
    end
end

function Game:drawGameOver()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)

    local font = love.graphics.newFont(48)
    love.graphics.setFont(font)

    if self.gameWon then
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("ESCAPED!", 0, self.screenHeight / 2 - 100, self.screenWidth, "center")

        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Time: " .. math_floor(self.elapsedTime) .. " seconds", 0, self.screenHeight / 2 - 40, self.screenWidth, "center")
        love.graphics.printf("Secrets Found: " .. self.secretsFound .. "/5", 0, self.screenHeight / 2 - 10, self.screenWidth, "center")
        love.graphics.printf("Lore Collected: " .. self.loreCollected .. "/3", 0, self.screenHeight / 2 + 20, self.screenWidth, "center")
    else
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.printf("MAZE COLLAPSED", 0, self.screenHeight / 2 - 80, self.screenWidth, "center")
    end

    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Click anywhere to continue", 0, self.screenHeight / 2 + 80, self.screenWidth, "center")
end

function Game:isGameOver()
    return self.gameOver
end

return Game