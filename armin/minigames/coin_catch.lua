-- minigames/coin_catch.lua — Catch falling coins, avoid bombs
-- Used inside Building 1.

local CoinCatch = {}

local basket  = {}
local coins   = {}
local bombs   = {}
local score   = 0
local targetScore   = 15
local spawnTimer    = 0
local spawnInterval = 0.55
local fallSpeed     = 200
local completed     = false

-- Play area bounds (inside the building interior)
local LEFT  = 80
local RIGHT = 720
local TOP   = 140
local BOTTOM = 440

function CoinCatch:init()
    basket = { x = 350, y = BOTTOM - 25, width = 80, height = 20 }
    coins  = {}
    bombs  = {}
    score  = 0
    spawnTimer = 0
    completed  = false
end

function CoinCatch:update(dt)
    if completed then return end

    -- Move basket
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        basket.x = basket.x - 400 * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        basket.x = basket.x + 400 * dt
    end
    basket.x = math.max(LEFT, math.min(basket.x, RIGHT - basket.width))

    -- Spawn coins / bombs
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = 0
        local x = math.random(LEFT + 10, RIGHT - 10)
        if math.random() < 0.2 then
            table.insert(bombs, { x = x, y = TOP, size = 14 })
        else
            table.insert(coins, { x = x, y = TOP, size = 11 })
        end
    end

    -- Move & check coins
    for i = #coins, 1, -1 do
        coins[i].y = coins[i].y + fallSpeed * dt
        if coins[i].y + coins[i].size >= basket.y
           and coins[i].x >= basket.x
           and coins[i].x <= basket.x + basket.width then
            score = score + 1
            table.remove(coins, i)
        elseif coins[i].y > BOTTOM + 20 then
            table.remove(coins, i)
        end
    end

    -- Move & check bombs
    for i = #bombs, 1, -1 do
        bombs[i].y = bombs[i].y + fallSpeed * dt
        if bombs[i].y + bombs[i].size >= basket.y
           and bombs[i].x >= basket.x
           and bombs[i].x <= basket.x + basket.width then
            score = math.max(0, score - 3)
            table.remove(bombs, i)
        elseif bombs[i].y > BOTTOM + 20 then
            table.remove(bombs, i)
        end
    end

    if score >= targetScore then
        completed = true
    end
end

function CoinCatch:keypressed(key) end

function CoinCatch:isCompleted()
    return completed
end

function CoinCatch:draw()
    -- Instructions
    love.graphics.setColor(1, 0.85, 0)
    love.graphics.printf("HACKELN", 0, 85, 800, "center")
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(
        "Catch " .. targetScore .. " coins!  Avoid the bugs (−3 pts).",
        0, 105, 800, "center"
    )

    -- Score bar
    local barW = 200
    local progress = math.min(score / targetScore, 1)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", 300, 125, barW, 12, 4, 4)
    love.graphics.setColor(0, 1, 0.5)
    love.graphics.rectangle("fill", 300, 125, barW * progress, 12, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(score .. " / " .. targetScore, 300, 125, barW, "center")

    -- Coins
    for _, c in ipairs(coins) do
        love.graphics.setColor(1, 0.85, 0)
        love.graphics.circle("fill", c.x, c.y, c.size)
        love.graphics.setColor(1, 1, 0.5)
        love.graphics.circle("line", c.x, c.y, c.size)
    end

    -- Bombs
    for _, b in ipairs(bombs) do
        love.graphics.setColor(1, 0.1, 0.1)
        love.graphics.circle("fill", b.x, b.y, b.size)
        love.graphics.setColor(1, 0.5, 0.5)
        love.graphics.circle("line", b.x, b.y, b.size)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("X", b.x - 5, b.y - 6, 10, "center")
    end

    -- Basket
    love.graphics.setColor(0.0, 0.8, 1.0)
    love.graphics.rectangle("fill", basket.x, basket.y, basket.width, basket.height, 4, 4)
    love.graphics.setColor(0, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", basket.x, basket.y, basket.width, basket.height, 4, 4)
end

return CoinCatch
