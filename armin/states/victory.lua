-- states/victory.lua — Birthday-themed victory screen

local VictoryState = {}

local timer     = 0
local particles = {}
local hearts    = {}
local bigFont   = nil
local medFont   = nil
local smallFont = nil
local numFont   = nil

function VictoryState:enter()
    timer     = 0
    particles = {}
    hearts    = {}

    if not bigFont then
        bigFont   = love.graphics.newFont(36)
        medFont   = love.graphics.newFont(20)
        smallFont = love.graphics.newFont(13)
        numFont   = love.graphics.newFont(90)
    end

    -- Confetti
    for _ = 1, 80 do
        table.insert(particles, {
            x     = math.random(0, 800),
            y     = math.random(-600, 0),
            size  = math.random(3, 8),
            speed = math.random(50, 150),
            wobbleSpd = math.random() * 3 + 1,
            wobbleAmt = math.random(5, 20),
            color = {
                math.random() * 0.5 + 0.5,
                math.random() * 0.5 + 0.5,
                math.random() * 0.5 + 0.5,
            },
        })
    end

    -- Floating hearts
    for _ = 1, 12 do
        table.insert(hearts, {
            x     = math.random(50, 750),
            y     = math.random(600, 900),
            size  = math.random(6, 14),
            speed = math.random(30, 80),
            drift = math.random() * 2 - 1,
        })
    end
end

function VictoryState:update(dt, game)
    timer = timer + dt

    for _, p in ipairs(particles) do
        p.y = p.y + p.speed * dt
        if p.y > 650 then
            p.y = -20
            p.x = math.random(0, 800)
        end
    end

    for _, h in ipairs(hearts) do
        h.y = h.y - h.speed * dt
        h.x = h.x + h.drift * 15 * dt
        if h.y < -30 then
            h.y = 620
            h.x = math.random(50, 750)
        end
    end
end

function VictoryState:keypressed(key, game)
    if key == "r" then
        game.currentLevel = 1
        game.switchState("play", 1)
    end
end

--- Draw a simple heart shape at (cx, cy) with the given half-size.
local function drawHeart(cx, cy, s)
    love.graphics.circle("fill", cx - s * 0.5, cy - s * 0.25, s * 0.55)
    love.graphics.circle("fill", cx + s * 0.5, cy - s * 0.25, s * 0.55)
    love.graphics.polygon("fill",
        cx - s, cy + s * 0.05,
        cx + s, cy + s * 0.05,
        cx, cy + s * 1.3
    )
end

function VictoryState:draw(game)
    love.graphics.setBackgroundColor(0.03, 0.02, 0.06)
    local t = love.timer.getTime()

    -- Confetti
    for _, p in ipairs(particles) do
        local wx = p.x + math.sin(t * p.wobbleSpd) * p.wobbleAmt
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], 0.7)
        love.graphics.rectangle("fill", wx, p.y, p.size, p.size * 1.5)
    end

    -- Floating hearts
    for _, h in ipairs(hearts) do
        love.graphics.setColor(1, 0.3, 0.4, 0.4)
        drawHeart(h.x, h.y, h.size)
    end

    -- Golden glow behind "30"
    local glowPulse = 0.2 + 0.1 * math.sin(t * 1.5)
    love.graphics.setColor(1, 0.85, 0, glowPulse)
    love.graphics.circle("fill", 400, 175, 100)

    -- Big "30"
    local numPulse = 0.85 + 0.15 * math.sin(t * 2)
    love.graphics.setFont(numFont)
    love.graphics.setColor(1, 0.85, 0, numPulse)
    love.graphics.printf("30", 0, 110, 800, "center")

    -- Birthday message
    love.graphics.setFont(bigFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Alles Gute zum Geburtstag!", 0, 250, 800, "center")

    -- Heart divider
    love.graphics.setColor(1, 0.3, 0.4, 0.8)
    drawHeart(400, 310, 10)

    -- Name / subtitle
    love.graphics.setFont(medFont)
    love.graphics.setColor(0.8, 0.7, 1.0)
    love.graphics.printf("Auf die nächsten 30!", 0, 345, 800, "center")

    -- Decorative beer + cake emojis (text-based)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.printf("~ Arbeitsweg  ·  Feierabend  ·  Heimweg  ·  Zuhause ~", 0, 400, 800, "center")

    -- Restart hint (subtle)
    love.graphics.setColor(0.4, 0.4, 0.5, 0.5 + 0.3 * math.sin(t * 3))
    love.graphics.printf("Press R to play again", 0, 560, 800, "center")
end

return VictoryState
