-- states/play.lua — Platforming gameplay state
-- Handles level loading, player/enemy logic, building interaction, and drawing.

local Player = require("player")
local Dog    = require("dog")
local Camera = require("camera")
local Utils  = require("utils")

local PlayState = {}

-- ── Module-level state (re-initialized each time enter() is called) ──
local player
local dog
local camera
local boxes    = {}
local enemies  = {}
local building = nil
local levelData       = nil
local currentLevel    = 1
local enterPrompt     = false
local transitionTimer = 0
local transitionActive = false
local drunkMode       = false
local deathFont       = nil
local uiFont          = nil

-- ── State lifecycle ─────────────────────────────────────────────

function PlayState:enter(level)
    currentLevel = level or 1

    -- Flush cached level module so re-require gives a fresh copy
    package.loaded["levels.level" .. currentLevel] = nil
    levelData = require("levels.level" .. currentLevel)

    player = Player.new(levelData.playerStart.x, levelData.playerStart.y)
    dog    = Dog.new(levelData.playerStart.x - 40, levelData.playerStart.y)
    camera = Camera.new()

    boxes   = {}
    enemies = {}
    enterPrompt     = false
    transitionTimer = 0
    transitionActive = false
    drunkMode       = false

    -- After the beer minigame, level 3 starts with impaired controls
    if currentLevel == 3 then
        drunkMode = true
        player.acceleration  = 400    -- sluggish to get moving
        player.friction      = 280    -- slides more
        player.max_speed     = 190    -- slower overall
        player.jump_force    = -780   -- slightly weaker jumps
    end

    -- Create fonts once
    if not deathFont then
        deathFont = love.graphics.newFont(22)
        uiFont    = love.graphics.newFont(13)
    end

    -- Copy boxes from level data
    for _, b in ipairs(levelData.boxes) do
        table.insert(boxes, {
            x = b.x, y = b.y,
            width = b.width, height = b.height,
            type = b.type or "solid",
        })
    end

    -- Copy enemies from level data
    for _, e in ipairs(levelData.enemies) do
        table.insert(enemies, {
            x = e.x, y = e.y,
            width  = e.width  or 30,
            height = e.height or 30,
            dx = e.dx or -90,
            isDead = false,
        })
    end

    -- Copy building
    if levelData.building then
        building = {
            x = levelData.building.x,
            y = levelData.building.y,
            width     = levelData.building.width  or 220,
            height    = levelData.building.height or 250,
            doorWidth  = 40,
            doorHeight = 60,
        }
    else
        building = nil
    end
end

function PlayState:exit()
    package.loaded["levels.level" .. currentLevel] = nil
end

-- ── Update ──────────────────────────────────────────────────────

function PlayState:update(dt, game)
    -- Fade-to-black transition when entering building
    if transitionActive then
        transitionTimer = transitionTimer + dt
        if transitionTimer >= 1.0 then
            game.switchState("building", currentLevel)
        end
        return
    end

    if player.isDead then return end

    -- Player physics (handles boxes internally)
    player:update(dt, boxes)
    dog:update(dt, player, boxes)
    camera:update(dt, player.x + player.width / 2)

    -- ── Enemy logic ──
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]

        if not enemy.isDead then
            -- Horizontal patrol
            enemy.x = enemy.x + enemy.dx * dt

            -- Wall collision → reverse direction
            local hitWall = false
            for _, box in ipairs(boxes) do
                if Utils.checkCollision(
                    enemy.x, enemy.y, enemy.width, enemy.height,
                    box.x, box.y, box.width, box.height
                ) then
                    if enemy.dx > 0 then
                        enemy.x = box.x - enemy.width
                    else
                        enemy.x = box.x + box.width
                    end
                    hitWall = true
                end
            end
            if hitWall then enemy.dx = -enemy.dx end

            -- Gravity
            enemy.y = enemy.y + 500 * dt
            for _, box in ipairs(boxes) do
                if Utils.checkCollision(
                    enemy.x, enemy.y, enemy.width, enemy.height,
                    box.x, box.y, box.width, box.height
                ) then
                    enemy.y = box.y - enemy.height
                end
            end

            -- Player vs enemy
            if Utils.checkCollision(
                player.x, player.y, player.width, player.height,
                enemy.x, enemy.y, enemy.width, enemy.height
            ) then
                if player.dy > 0 and
                   player.y + player.height - player.dy * dt <= enemy.y + 15 then
                    -- Stomp!
                    enemy.isDead = true
                    if love.keyboard.isDown("space") or
                       love.keyboard.isDown("up") or
                       love.keyboard.isDown("w") then
                        player.dy = player.jump_force * 1.1
                    else
                        player.dy = player.jump_force * 0.7
                    end
                else
                    player.isDead = true
                end
            end
        end
    end

    -- Remove dead enemies
    for i = #enemies, 1, -1 do
        if enemies[i].isDead then table.remove(enemies, i) end
    end

    -- ── Building proximity check ──
    enterPrompt = false
    if building then
        local doorX = building.x + building.width / 2 - building.doorWidth / 2
        local doorY = building.y + building.height - building.doorHeight
        local dist  = math.abs(
            (player.x + player.width / 2) - (doorX + building.doorWidth / 2)
        )
        if dist < 50
           and player.y + player.height >= doorY
           and player.y <= doorY + building.doorHeight then
            enterPrompt = true
        end
    end
end

-- ── Input ───────────────────────────────────────────────────────

function PlayState:keypressed(key, game)
    if player.isDead then
        if key == "r" then self:enter(currentLevel) end
        return
    end

    if key == "up" or key == "w" or key == "space" then
        player:jump()
    end

    if key == "e" and enterPrompt then
        transitionActive = true
        transitionTimer  = 0
    end
end

function PlayState:keyreleased(key, game)
    if key == "up" or key == "w" or key == "space" then
        player:releaseJump()
    end
end

-- ── Drawing ─────────────────────────────────────────────────────

function PlayState:draw(game)
    -- Per-level background colour
    local bgColors = {
        { 0.05, 0.05, 0.08 },   -- L1: deep blue-black
        { 0.08, 0.04, 0.04 },   -- L2: dark crimson
        { 0.04, 0.07, 0.05 },   -- L3: dark green
    }
    local bg = bgColors[currentLevel] or bgColors[1]
    love.graphics.setBackgroundColor(bg[1], bg[2], bg[3])

    -- ── Transition overlay ──
    if transitionActive then
        love.graphics.push()
        camera:apply()
        self:drawWorld()
        love.graphics.pop()

        local alpha = math.min(transitionTimer / 1.0, 1.0)
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 0, 0, 800, 600)

        love.graphics.setFont(deathFont)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.printf("Entering building…", 0, 280, 800, "center")
        love.graphics.setFont(uiFont)
        return
    end

    -- ── Normal scene ──
    love.graphics.push()
    camera:apply()

    -- Drunk screen sway
    if drunkMode then
        local sway = math.sin(love.timer.getTime() * 1.3) * 4
        love.graphics.translate(sway, math.sin(love.timer.getTime() * 0.9) * 2)
    end

    self:drawWorld()
    love.graphics.pop()

    -- ── HUD ──
    love.graphics.setFont(uiFont)
    if player.isDead then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, 800, 600)

        love.graphics.setFont(deathFont)
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("TOT", 0, 250, 800, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press 'R' to Reboot", 0, 290, 800, "center")
        love.graphics.setFont(uiFont)
    else
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print("Move: A/D | Sprint: Shift | Jump: Space | Enter: E", 10, 10)

        -- Drunk indicator
        if drunkMode then
            local wobble = 0.6 + 0.4 * math.sin(love.timer.getTime() * 3)
            love.graphics.setColor(1, 0.85, 0, wobble)
            love.graphics.print("[Tipsy]  Controls impaired!", 10, 28)
        end

        love.graphics.setColor(0, 0.8, 1)
        love.graphics.printf("Level " .. currentLevel .. "  –  " .. (levelData.name or ""), 0, 10, 790, "right")

        if enterPrompt then
            local pulse = 0.7 + 0.3 * math.sin(love.timer.getTime() * 4)
            love.graphics.setColor(0, 1, 0.5, pulse)
            love.graphics.printf("[ Press E to Enter ]", 0, 565, 800, "center")
        end
    end
end

--- Draw all world geometry (called inside camera transform).
function PlayState:drawWorld()
    -- ── Platforms ──
    for _, box in ipairs(boxes) do
        if box.type == "solid" then
            love.graphics.setColor(0.1, 0.1, 0.15)
            love.graphics.rectangle("fill", box.x, box.y, box.width, box.height)
            love.graphics.setColor(0.0, 0.8, 1.0)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", box.x, box.y, box.width, box.height)
        elseif box.type == "bouncy" then
            love.graphics.setColor(1, 0.4, 0.0)
            love.graphics.rectangle("fill", box.x, box.y, box.width, box.height)
            love.graphics.setColor(1, 1, 0)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", box.x, box.y, box.width, box.height)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("^^^", box.x + box.width / 2 - 12, box.y + 2)
        end
    end

    -- ── Building ──
    if building then
        local b = building

        -- Body
        love.graphics.setColor(0.15, 0.12, 0.2)
        love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
        love.graphics.setColor(0.6, 0.4, 1.0)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", b.x, b.y, b.width, b.height)

        -- Windows (2 rows × 3 cols)
        local ws, wp = 18, 14
        for row = 0, 1 do
            for col = 0, 2 do
                local wx = b.x + wp + col * (ws + wp)
                local wy = b.y + wp + row * (ws + wp)
                love.graphics.setColor(0.2, 0.6, 1.0, 0.3)
                love.graphics.rectangle("fill", wx - 2, wy - 2, ws + 4, ws + 4)
                love.graphics.setColor(0.3, 0.7, 1.0)
                love.graphics.rectangle("fill", wx, wy, ws, ws)
            end
        end

        -- Door
        local dx = b.x + b.width / 2 - b.doorWidth / 2
        local dy = b.y + b.height - b.doorHeight
        love.graphics.setColor(0.3, 0.15, 0.05)
        love.graphics.rectangle("fill", dx, dy, b.doorWidth, b.doorHeight)

        if enterPrompt then
            love.graphics.setColor(0, 1, 0.5, 0.5 + 0.3 * math.sin(love.timer.getTime() * 4))
        else
            love.graphics.setColor(0.6, 0.4, 1.0)
        end
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", dx, dy, b.doorWidth, b.doorHeight)

        -- Knob
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.circle("fill", dx + b.doorWidth - 8, dy + b.doorHeight / 2, 3)

        -- Roof
        love.graphics.setColor(0.4, 0.2, 0.6)
        love.graphics.polygon("fill",
            b.x - 10, b.y,
            b.x + b.width / 2, b.y - 30,
            b.x + b.width + 10, b.y
        )
        love.graphics.setColor(0.6, 0.4, 1.0)
        love.graphics.setLineWidth(2)
        love.graphics.polygon("line",
            b.x - 10, b.y,
            b.x + b.width / 2, b.y - 30,
            b.x + b.width + 10, b.y
        )
    end

    -- ── Enemies ──
    for _, enemy in ipairs(enemies) do
        if not enemy.isDead then
            love.graphics.setColor(1, 0.1, 0.4)
            love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
            love.graphics.setColor(1, 0.7, 0.8)
            love.graphics.rectangle("fill", enemy.x + 10, enemy.y + 10, 10, 10)
        end
    end

    -- ── Dog (drawn behind player) ──
    dog:draw()

    -- ── Player ──
    player:draw()
end

return PlayState
