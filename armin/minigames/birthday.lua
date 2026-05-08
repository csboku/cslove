-- minigames/birthday.lua — Birthday cutscene animation
-- A dramatic fullscreen celebration: "HAPPY BIRTHDAY ARMIN!" fades in,
-- then a fancy golden "30" drops in with confetti and sparkles.

local Birthday = {}
Birthday.isFullscreen = true   -- tells building.lua to skip its interior chrome

local elapsed   = 0
local completed = false
local confetti  = {}
local sparkles  = {}
local hugeFont  = nil
local bigFont   = nil
local medFont   = nil
local smallFont = nil

-- Phase breakpoints (seconds)
local P_DARK        = 0       -- black screen
local P_HAPPY       = 1.5     -- "HAPPY BIRTHDAY" fades in
local P_ARMIN       = 3.5     -- "ARMIN!" drops in
local P_THIRTY_IN   = 6.0     -- big "30" scales up
local P_CONFETTI    = 7.5     -- confetti starts
local P_GLOW        = 9.0     -- golden glow pulses
local P_COMPLETE    = 12.0    -- animation done

-- ── Interface ───────────────────────────────────────────────────

function Birthday:init()
    elapsed   = 0
    completed = false
    confetti  = {}
    sparkles  = {}

    hugeFont  = love.graphics.newFont(110)
    bigFont   = love.graphics.newFont(48)
    medFont   = love.graphics.newFont(28)
    smallFont = love.graphics.newFont(14)

    -- Pre-create confetti particles
    for _ = 1, 120 do
        table.insert(confetti, {
            x          = math.random(0, 800),
            y          = math.random(-800, -50),
            size       = math.random(3, 8),
            speed      = math.random(60, 180),
            wobbleSpd  = math.random() * 4 + 1,
            wobbleAmt  = math.random(15, 40),
            rotation   = math.random() * math.pi * 2,
            rotSpd     = (math.random() - 0.5) * 4,
            color      = {
                math.random() * 0.4 + 0.6,
                math.random() * 0.4 + 0.6,
                math.random() * 0.4 + 0.6,
            },
        })
    end

    -- Sparkle particles (around the "30")
    for _ = 1, 30 do
        table.insert(sparkles, {
            angle  = math.random() * math.pi * 2,
            dist   = math.random(60, 140),
            speed  = (math.random() - 0.5) * 2,
            size   = math.random(2, 5),
            phase  = math.random() * math.pi * 2,
        })
    end
end

function Birthday:update(dt)
    elapsed = elapsed + dt

    -- Confetti physics (P_CONFETTI onward)
    if elapsed >= P_CONFETTI then
        for _, c in ipairs(confetti) do
            c.y = c.y + c.speed * dt
            c.rotation = c.rotation + c.rotSpd * dt
            if c.y > 620 then c.y = math.random(-100, -20) end
        end
    end

    if elapsed >= P_COMPLETE then
        completed = true
    end
end

function Birthday:keypressed(key) end

function Birthday:isCompleted()
    return completed
end

-- ── Drawing ─────────────────────────────────────────────────────

function Birthday:draw()
    local t = love.timer.getTime()

    -- ── Black background ──
    love.graphics.setColor(0.02, 0.01, 0.05)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- ── Stars / ambient sparkle in background ──
    if elapsed >= P_DARK then
        local starAlpha = math.min(elapsed / 3, 0.5)
        for i = 1, 40 do
            local sx = (i * 137 + 50) % 800
            local sy = (i * 97 + 30) % 600
            local twinkle = 0.3 + 0.7 * math.abs(math.sin(t * (0.5 + i * 0.1) + i))
            love.graphics.setColor(1, 1, 1, starAlpha * twinkle)
            love.graphics.circle("fill", sx, sy, 1.5)
        end
    end

    -- ── "HAPPY BIRTHDAY" text (fades in at P_HAPPY) ──
    if elapsed >= P_HAPPY then
        local alpha = math.min((elapsed - P_HAPPY) / 1.5, 1)

        -- Subtle glow behind text
        love.graphics.setColor(1, 0.85, 0, alpha * 0.15)
        love.graphics.setFont(bigFont)
        love.graphics.printf("HAPPY BIRTHDAY", 2, 102, 800, "center")
        love.graphics.printf("HAPPY BIRTHDAY", -2, 98, 800, "center")

        -- Main text
        love.graphics.setColor(1, 0.9, 0.3, alpha)
        love.graphics.printf("HAPPY BIRTHDAY", 0, 100, 800, "center")
    end

    -- ── "ARMIN!" drops in (from P_ARMIN) ──
    if elapsed >= P_ARMIN then
        local progress = math.min((elapsed - P_ARMIN) / 1.5, 1)
        -- Ease-out bounce
        local bounce = 1 - (1 - progress) * (1 - progress)
        local yPos = -80 + bounce * 250  -- drops from above to y=170
        local alpha = math.min(progress * 2, 1)

        -- Rainbow shimmer per letter
        love.graphics.setFont(bigFont)
        local name = "ARMIN!"
        local totalW = bigFont:getWidth(name)
        local startX = 400 - totalW / 2

        for i = 1, #name do
            local char = name:sub(i, i)
            local charW = bigFont:getWidth(char)
            local hue = ((t * 0.5 + i * 0.15) % 1)
            local r, g, b = hslToRgb(hue, 0.8, 0.65)
            love.graphics.setColor(r, g, b, alpha)
            love.graphics.print(char, startX, yPos)
            startX = startX + charW
        end
    end

    -- ── Fancy "30" (scales up from P_THIRTY_IN) ──
    if elapsed >= P_THIRTY_IN then
        local progress = math.min((elapsed - P_THIRTY_IN) / 2.0, 1)
        -- Elastic ease-out
        local scale = 1 + math.sin(progress * math.pi * 3) * (1 - progress) * 0.3
        scale = scale * progress

        local cx, cy = 400, 370

        -- Golden glow rings
        if elapsed >= P_GLOW then
            local ga = math.min((elapsed - P_GLOW) / 2, 1)
            for ring = 1, 3 do
                local pulse = 0.3 + 0.7 * math.abs(math.sin(t * (1 + ring * 0.3) + ring))
                local radius = 80 + ring * 25 + math.sin(t * 2 + ring) * 10
                love.graphics.setColor(1, 0.85, 0, ga * pulse * 0.12)
                love.graphics.circle("fill", cx, cy, radius * scale)
            end
        end

        -- "30" with shadow
        love.graphics.setFont(hugeFont)
        local textW = hugeFont:getWidth("30")
        local textH = hugeFont:getHeight()
        local tx = cx - (textW * scale) / 2
        local ty = cy - (textH * scale) / 2

        -- Shadow
        love.graphics.setColor(0.4, 0.2, 0, progress * 0.5)
        love.graphics.print("30", tx + 3 * scale, ty + 3 * scale, 0, scale, scale)

        -- Golden text with pulse
        local pulse = 0.85 + 0.15 * math.sin(t * 3)
        love.graphics.setColor(1, pulse, 0, progress)
        love.graphics.print("30", tx, ty, 0, scale, scale)

        -- Sparkles around the "30"
        for _, s in ipairs(sparkles) do
            local a = s.angle + t * s.speed
            local d = s.dist * scale
            local sx = cx + math.cos(a) * d
            local sy = cy + math.sin(a) * d
            local twinkle = 0.5 + 0.5 * math.sin(t * 4 + s.phase)
            love.graphics.setColor(1, 0.95, 0.7, progress * twinkle)
            love.graphics.circle("fill", sx, sy, s.size * twinkle)
        end

        love.graphics.setFont(smallFont)
    end

    -- ── Confetti (P_CONFETTI onward) ──
    if elapsed >= P_CONFETTI then
        for _, c in ipairs(confetti) do
            local wx = c.x + math.sin(t * c.wobbleSpd) * c.wobbleAmt
            love.graphics.setColor(c.color[1], c.color[2], c.color[3], 0.85)
            love.graphics.push()
            love.graphics.translate(wx + c.size / 2, c.y + c.size / 2)
            love.graphics.rotate(c.rotation)
            love.graphics.rectangle("fill", -c.size / 2, -c.size / 2, c.size, c.size * 1.6)
            love.graphics.pop()
        end
    end

    -- ── "Press E" once animation is done ──
    if completed then
        local pulse = 0.5 + 0.3 * math.sin(t * 4)
        love.graphics.setFont(medFont)
        love.graphics.setColor(1, 0.85, 0, pulse)
        love.graphics.printf("Press E", 0, 520, 800, "center")
        love.graphics.setFont(smallFont)
    end
end

-- ── Helper: HSL to RGB ──────────────────────────────────────────

function hslToRgb(h, s, l)
    if s == 0 then return l, l, l end
    local function hue2rgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    return hue2rgb(p, q, h + 1/3), hue2rgb(p, q, h), hue2rgb(p, q, h - 1/3)
end

return Birthday
