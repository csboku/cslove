-- states/building.lua — Interior / minigame state
-- Wraps the per-level minigame in a "building interior" shell.
-- When the minigame is completed, the player can press E to exit and
-- advance to the next level (or the victory screen after level 3).

local BuildingState = {}

local currentMinigame = nil
local currentLevel    = 1
local completed       = false
local exitTimer       = 0
local exitTransition  = false
local titleFont       = nil
local bodyFont        = nil

local minigameNames = {
    "Coin Catch",
    "Beer Drinking",
    "Zuhause",
}

local minigameModules = {
    "minigames.coin_catch",
    "minigames.beer_drink",
    "minigames.birthday",
}

-- ── Lifecycle ───────────────────────────────────────────────────

function BuildingState:enter(level)
    currentLevel   = level
    completed      = false
    exitTimer      = 0
    exitTransition = false

    if not titleFont then
        titleFont = love.graphics.newFont(20)
        bodyFont  = love.graphics.newFont(14)
    end

    -- Fresh-load the minigame module
    package.loaded[minigameModules[currentLevel]] = nil
    currentMinigame = require(minigameModules[currentLevel])
    if currentMinigame and currentMinigame.init then
        currentMinigame:init()
    end
end

function BuildingState:exit()
    if currentMinigame then
        package.loaded[minigameModules[currentLevel]] = nil
        currentMinigame = nil
    end
end

-- ── Update ──────────────────────────────────────────────────────

function BuildingState:update(dt, game)
    if exitTransition then
        exitTimer = exitTimer + dt
        if exitTimer >= 1.0 then
            local nextLevel = currentLevel + 1
            if nextLevel > game.maxLevels then
                game.switchState("victory")
            else
                game.currentLevel = nextLevel
                game.switchState("play", nextLevel)
            end
        end
        return
    end

    if currentMinigame and currentMinigame.update then
        currentMinigame:update(dt)
    end

    if currentMinigame and currentMinigame.isCompleted
       and currentMinigame:isCompleted() then
        completed = true
    end
end

-- ── Input ───────────────────────────────────────────────────────

function BuildingState:keypressed(key, game)
    if completed and key == "e" then
        exitTransition = true
        exitTimer      = 0
        return
    end

    if currentMinigame and currentMinigame.keypressed then
        currentMinigame:keypressed(key)
    end
end

function BuildingState:mousepressed(x, y, button, game)
    if currentMinigame and currentMinigame.mousepressed then
        currentMinigame:mousepressed(x, y, button)
    end
end

-- ── Draw ────────────────────────────────────────────────────────

function BuildingState:draw(game)
    love.graphics.setBackgroundColor(0.08, 0.06, 0.12)

    -- Fullscreen minigames (e.g. birthday cutscene) draw their own scene
    local isFS = currentMinigame and currentMinigame.isFullscreen

    if not isFS then
        -- Interior walls
        love.graphics.setColor(0.12, 0.1, 0.18)
        love.graphics.rectangle("fill", 50, 50, 700, 500)

        love.graphics.setColor(0.4, 0.3, 0.6)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", 50, 50, 700, 500)

        -- Floor
        love.graphics.setColor(0.08, 0.06, 0.1)
        love.graphics.rectangle("fill", 50, 450, 700, 100)
        love.graphics.setColor(0.3, 0.2, 0.4)
        love.graphics.line(50, 450, 750, 450)

        -- Title
        love.graphics.setFont(titleFont)
        love.graphics.setColor(0.6, 0.4, 1.0)
        love.graphics.printf(
            "Building " .. currentLevel .. "  –  " .. (minigameNames[currentLevel] or "Minigame"),
            0, 55, 800, "center"
        )
    end

    -- Minigame content
    love.graphics.setFont(bodyFont)
    if currentMinigame and currentMinigame.draw then
        currentMinigame:draw()
    end

    -- Completion prompt (skipped for fullscreen — they draw their own)
    if completed and not isFS then
        local pulse = 0.5 + 0.3 * math.sin(love.timer.getTime() * 4)
        love.graphics.setColor(0, 1, 0.5, pulse)
        love.graphics.setFont(titleFont)
        love.graphics.printf("Minigame Complete!  Press E to exit", 0, 525, 800, "center")
        love.graphics.setFont(bodyFont)
    end

    -- Exit transition overlay
    if exitTransition then
        local alpha = math.min(exitTimer / 1.0, 1.0)
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 0, 0, 800, 600)

        love.graphics.setFont(titleFont)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.printf("Leaving building…", 0, 280, 800, "center")
        love.graphics.setFont(bodyFont)
    end
end

return BuildingState
