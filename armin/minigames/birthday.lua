-- minigames/birthday.lua — Birthday cutscene animation
-- Armin comes home, meets his girlfriend, and a big "30" celebration plays.
-- This is a fullscreen cutscene, not a traditional minigame.

local Birthday = {}
Birthday.isFullscreen = true   -- tells building.lua to skip its interior chrome

local elapsed   = 0
local completed = false
local confetti  = {}
local bigFont   = nil
local medFont   = nil
local smallFont = nil

-- Character positions (animated)
local arminX = 60
local gfX    = 550

-- Phase breakpoints (seconds)
local P_DOOR     = 0      -- dark room, door light appears
local P_ENTER    = 1.5    -- Armin walks in
local P_LIGHTS   = 4.0    -- lights on, girlfriend visible
local P_TOGETHER = 5.5    -- they walk toward each other
local P_HEART    = 7.5    -- heart appears
local P_THIRTY   = 9.0    -- big "30" + confetti + birthday text
local P_COMPLETE = 12.0   -- animation done

-- ── Interface ───────────────────────────────────────────────────

function Birthday:init()
    elapsed   = 0
    completed = false
    arminX    = 60
    gfX       = 550
    confetti  = {}

    bigFont   = love.graphics.newFont(72)
    medFont   = love.graphics.newFont(22)
    smallFont = love.graphics.newFont(14)

    -- Pre-create confetti particles
    for _ = 1, 80 do
        table.insert(confetti, {
            x          = math.random(60, 740),
            y          = math.random(-500, -50),
            size       = math.random(3, 7),
            speed      = math.random(40, 120),
            wobbleSpd  = math.random() * 3 + 1,
            wobbleAmt  = math.random(10, 30),
            color      = {
                math.random() * 0.5 + 0.5,
                math.random() * 0.5 + 0.5,
                math.random() * 0.5 + 0.5,
            },
        })
    end
end

function Birthday:update(dt)
    elapsed = elapsed + dt

    -- Armin walks in (P_ENTER → P_LIGHTS)
    if elapsed >= P_ENTER and elapsed < P_LIGHTS then
        arminX = math.min(arminX + 80 * dt, 300)
    end

    -- They walk toward each other (P_TOGETHER → P_HEART)
    if elapsed >= P_TOGETHER and elapsed < P_HEART then
        if arminX < 350 then arminX = arminX + 40 * dt end
        if gfX > 410    then gfX    = gfX    - 40 * dt end
    end

    -- Confetti physics (P_THIRTY onward)
    if elapsed >= P_THIRTY then
        for _, c in ipairs(confetti) do
            c.y = c.y + c.speed * dt
            if c.y > 450 then c.y = -20 end
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
    love.graphics.setFont(smallFont)

    -- ── Room background ──
    local bright = 0.05
    if elapsed >= P_LIGHTS then
        bright = math.min(0.05 + (elapsed - P_LIGHTS) * 0.1, 0.15)
    end
    love.graphics.setColor(bright, bright * 0.7, bright * 1.2)
    love.graphics.rectangle("fill", 50, 50, 700, 500)

    -- Border
    love.graphics.setColor(0.35, 0.25, 0.5)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", 50, 50, 700, 500)

    -- Floor
    love.graphics.setColor(0.18, 0.12, 0.1)
    love.graphics.rectangle("fill", 55, 400, 690, 145)
    love.graphics.setColor(0.3, 0.2, 0.15)
    love.graphics.line(55, 400, 745, 400)

    -- ── Door light (early phase) ──
    if elapsed < P_ENTER then
        local alpha = math.min(elapsed / 1.0, 0.4)
        love.graphics.setColor(1, 0.9, 0.7, alpha)
        love.graphics.polygon("fill", 65, 400, 65, 220, 180, 270, 180, 400)
    end

    -- ── Furniture (visible after lights on) ──
    if elapsed >= P_LIGHTS then
        local fa = math.min((elapsed - P_LIGHTS) / 1.0, 1)

        -- Couch
        love.graphics.setColor(0.3, 0.15, 0.1, fa)
        love.graphics.rectangle("fill", 530, 345, 120, 55, 6, 6)
        love.graphics.setColor(0.4, 0.2, 0.12, fa)
        love.graphics.rectangle("fill", 530, 335, 120, 15, 6, 6)
        love.graphics.setColor(0.35, 0.17, 0.1, fa)
        love.graphics.rectangle("fill", 530, 315, 15, 35, 4, 4)
        love.graphics.rectangle("fill", 635, 315, 15, 35, 4, 4)

        -- Table
        love.graphics.setColor(0.25, 0.15, 0.08, fa)
        love.graphics.rectangle("fill", 300, 368, 80, 5)
        love.graphics.rectangle("fill", 310, 373, 5, 27)
        love.graphics.rectangle("fill", 365, 373, 5, 27)

        -- Ceiling lamp
        love.graphics.setColor(0.4, 0.35, 0.2, fa)
        love.graphics.rectangle("fill", 390, 52, 4, 40)
        love.graphics.setColor(1, 0.95, 0.7, fa * 0.3)
        love.graphics.circle("fill", 392, 97, 35)
        love.graphics.setColor(1, 0.9, 0.6, fa)
        love.graphics.polygon("fill", 380, 92, 404, 92, 412, 108, 372, 108)

        -- Picture frame on wall
        love.graphics.setColor(0.5, 0.35, 0.2, fa)
        love.graphics.rectangle("line", 160, 180, 60, 50)
        love.graphics.setColor(0.3, 0.5, 0.7, fa * 0.5)
        love.graphics.rectangle("fill", 163, 183, 54, 44)
    end

    -- ── Girlfriend (visible after lights on) ──
    if elapsed >= P_LIGHTS then
        local ga = math.min((elapsed - P_LIGHTS) / 1.0, 1)

        -- Dress
        love.graphics.setColor(0.9, 0.3, 0.4, ga)
        love.graphics.rectangle("fill", gfX, 370, 28, 30)
        -- Legs
        love.graphics.setColor(1, 0.85, 0.7, ga)
        love.graphics.rectangle("fill", gfX + 5, 400, 5, 10)
        love.graphics.rectangle("fill", gfX + 18, 400, 5, 10)
        -- Head
        love.graphics.setColor(1, 0.85, 0.7, ga)
        love.graphics.circle("fill", gfX + 14, 362, 10)
        -- Hair
        -- love.graphics.setColor(0.3, 0.15, 0.05, ga)
        -- love.graphics.arc("fill", gfX + 14, 360, 12, -math.pi, 0)
        -- love.graphics.rectangle("fill", gfX + 2, 355, 3, 25)
        -- love.graphics.rectangle("fill", gfX + 23, 355, 3, 25)
        -- -- Eyes (looking left toward door)
        -- love.graphics.setColor(0.2, 0.2, 0.3, ga)
        -- love.graphics.circle("fill", gfX + 10, 361, 2)
        -- love.graphics.circle("fill", gfX + 17, 361, 2)
        -- -- Smile
        -- love.graphics.setColor(0.8, 0.3, 0.3, ga)
        -- love.graphics.arc("line", "open", gfX + 14, 365, 4, 0.2, math.pi - 0.2)
    end

    -- ── Armin (walks in after P_ENTER) ──
    if elapsed >= P_ENTER then
        -- Body (same neon green as in the platformer)
        love.graphics.setColor(0.1, 1.0, 0.6)
        love.graphics.rectangle("fill", arminX, 370, 30, 30)
        -- Direction edge
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", arminX + 24, 370, 6, 30)
        -- Legs
        love.graphics.setColor(0.1, 0.7, 0.4)
        love.graphics.rectangle("fill", arminX + 5, 400, 5, 10)
        love.graphics.rectangle("fill", arminX + 18, 400, 5, 10)
    end

    -- ── Heart between them (P_HEART onward) ──
    if elapsed >= P_HEART then
        local ha = math.min((elapsed - P_HEART) / 1.0, 1)
        local hx = (arminX + gfX) / 2 + 14
        local hy = 335 + math.sin(t * 2) * 5
        local hs = 10 * ha

        love.graphics.setColor(1, 0.2, 0.3, ha)
        love.graphics.circle("fill", hx - hs * 0.5, hy - hs * 0.25, hs * 0.55)
        love.graphics.circle("fill", hx + hs * 0.5, hy - hs * 0.25, hs * 0.55)
        love.graphics.polygon("fill",
            hx - hs, hy + hs * 0.05,
            hx + hs, hy + hs * 0.05,
            hx, hy + hs * 1.3
        )
    end

    -- ── Big "30" + Birthday message (P_THIRTY onward) ──
    if elapsed >= P_THIRTY then
        local ta = math.min((elapsed - P_THIRTY) / 2.0, 1)

        -- Golden glow
        love.graphics.setColor(1, 0.85, 0, ta * 0.25)
        love.graphics.circle("fill", 400, 185, 75)

        -- "30"
        love.graphics.setFont(bigFont)
        love.graphics.setColor(1, 0.85, 0, ta)
        love.graphics.printf("30", 0, 130, 800, "center")

        -- Birthday text
        love.graphics.setFont(medFont)
        love.graphics.setColor(1, 1, 1, ta * 0.9)
        love.graphics.printf("Alles Gute zum Geburtstag!", 0, 225, 800, "center")

        -- Reset font
        love.graphics.setFont(smallFont)
    end

    -- ── Confetti (P_THIRTY onward) ──
    if elapsed >= P_THIRTY then
        for _, c in ipairs(confetti) do
            local wx = c.x + math.sin(t * c.wobbleSpd) * c.wobbleAmt
            love.graphics.setColor(c.color[1], c.color[2], c.color[3], 0.8)
            love.graphics.rectangle("fill", wx, c.y, c.size, c.size * 1.5)
        end
    end

    -- ── Narration text ──
    love.graphics.setFont(smallFont)
    if elapsed < P_ENTER then
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.printf("*Die Tür geht auf…*", 0, 280, 800, "center")
    elseif elapsed < P_LIGHTS then
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.printf("*Armin kommt nach Hause…*", 0, 280, 800, "center")
    elseif elapsed < P_TOGETHER then
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.printf("*Das Licht geht an…*", 0, 280, 800, "center")
    end

    -- ── "Press E" once animation is done ──
    if completed then
        local pulse = 0.5 + 0.3 * math.sin(t * 4)
        love.graphics.setFont(medFont)
        love.graphics.setColor(1, 0.85, 0, pulse)
        love.graphics.printf("Press E", 0, 460, 800, "center")
        love.graphics.setFont(smallFont)
    end
end

return Birthday
