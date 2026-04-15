-- minigames/dodge.lua — Dodge falling hazards for a set duration
-- Used inside Building 3.

local Dodge = {}

local playerX     = 400
local playerW     = 30
local playerH     = 30
local playerY     = 410       -- fixed Y
local hazards     = {}
local spawnTimer  = 0
local baseInterval = 0.4
local surviveTime = 20        -- seconds to survive
local elapsed     = 0
local completed   = false
local hit         = false
local hitTimer    = 0

-- Play area bounds
local LEFT   = 80
local RIGHT  = 720
local TOP    = 140
local BOTTOM = 440

function Dodge:init()
    playerX    = 400
    hazards    = {}
    spawnTimer = 0
    elapsed    = 0
    completed  = false
    hit        = false
    hitTimer   = 0
end

function Dodge:update(dt)
    if completed then return end

    -- Stun after being hit
    if hit then
        hitTimer = hitTimer + dt
        if hitTimer >= 1.0 then
            hit      = false
            hitTimer = 0
            elapsed  = math.max(0, elapsed - 3)   -- penalty
        end
        return
    end

    elapsed = elapsed + dt
    if elapsed >= surviveTime then
        completed = true
        return
    end

    -- Move player
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        playerX = playerX - 350 * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        playerX = playerX + 350 * dt
    end
    playerX = math.max(LEFT, math.min(playerX, RIGHT - playerW))

    -- Spawn hazards (rate increases over time)
    local interval = baseInterval * math.max(0.25, 1 - elapsed / surviveTime * 0.75)
    spawnTimer = spawnTimer + dt
    if spawnTimer >= interval then
        spawnTimer = 0
        local w = math.random(20, 60)
        table.insert(hazards, {
            x = math.random(LEFT, RIGHT - w),
            y = TOP,
            width  = w,
            height = 14,
            speed  = math.random(150, 300),
        })
    end

    -- Move hazards & check collision
    for i = #hazards, 1, -1 do
        local h = hazards[i]
        h.y = h.y + h.speed * dt

        if h.y + h.height >= playerY
           and h.y <= playerY + playerH
           and h.x + h.width >= playerX
           and h.x <= playerX + playerW then
            hit      = true
            hitTimer = 0
            hazards  = {}
            return
        end

        if h.y > BOTTOM + 20 then
            table.remove(hazards, i)
        end
    end
end

function Dodge:keypressed(key) end

function Dodge:isCompleted()
    return completed
end

function Dodge:draw()
    -- Header
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.printf("DODGE!", 0, 85, 800, "center")
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(
        "Survive for " .. surviveTime .. " seconds!  Getting hit costs 3 s.",
        0, 105, 800, "center"
    )

    -- Timer bar
    local barW = 300
    local barH = 14
    local barX = 250
    local barY = 125
    local progress = math.min(elapsed / surviveTime, 1)

    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", barX, barY, barW, barH, 4, 4)

    local r = 1 - progress
    local g = progress
    love.graphics.setColor(r, g, 0.2)
    love.graphics.rectangle("fill", barX, barY, barW * progress, barH, 4, 4)

    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.rectangle("line", barX, barY, barW, barH, 4, 4)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        string.format("%.1f / %d", elapsed, surviveTime),
        barX, barY, barW, "center"
    )

    -- Hazards
    for _, h in ipairs(hazards) do
        love.graphics.setColor(1, 0.2, 0.1)
        love.graphics.rectangle("fill", h.x, h.y, h.width, h.height)
        love.graphics.setColor(1, 0.5, 0.3)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", h.x, h.y, h.width, h.height)
    end

    -- Player
    if hit then
        love.graphics.setColor(1, 0, 0, 0.5 + 0.5 * math.sin(love.timer.getTime() * 15))
    else
        love.graphics.setColor(0.1, 1.0, 0.6)
    end
    love.graphics.rectangle("fill", playerX, playerY, playerW, playerH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", playerX + playerW / 2 - 3, playerY, 6, playerH)

    if hit then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf("HIT!  −3 seconds!", 0, playerY - 25, 800, "center")
    end
end

return Dodge
