-- minigames/beer_drink.lua — Beer drinking timing game
-- Hit SPACE when the bouncing cursor lands in the green zone to take a gulp.
-- Each successful gulp makes the cursor faster. Finish the beer to win!

local BeerDrink = {}

local cursor       = 0      -- 0..1 position on the timing bar
local cursorSpeed  = 1.5
local cursorDir    = 1
local hitZoneCenter = 0.5
local hitZoneWidth  = 0.15  -- half-width of the green zone
local gulps        = 0
local maxGulps     = 5
local completed    = false
local feedback     = ""
local feedbackTimer = 0
local feedbackColor = { 1, 1, 1 }
local beerLevel    = 1.0    -- 1.0 = full, 0.0 = empty

function BeerDrink:init()
    cursor       = 0
    cursorSpeed  = 1.5
    cursorDir    = 1
    gulps        = 0
    completed    = false
    feedback     = ""
    feedbackTimer = 0
    beerLevel    = 1.0
    hitZoneCenter = 0.5
end

function BeerDrink:update(dt)
    if completed then return end

    -- Bounce cursor back and forth across the bar
    cursor = cursor + cursorDir * cursorSpeed * dt
    if cursor >= 1 then
        cursor   = 1
        cursorDir = -1
    elseif cursor <= 0 then
        cursor   = 0
        cursorDir = 1
    end

    -- Fade out feedback text
    if feedbackTimer > 0 then
        feedbackTimer = feedbackTimer - dt
    end
end

function BeerDrink:keypressed(key)
    if completed then return end
    if key ~= "space" then return end

    local dist = math.abs(cursor - hitZoneCenter)

    if dist <= hitZoneWidth * 0.4 then
        -- Perfect hit
        gulps = gulps + 1
        feedback      = "PERFECT!"
        feedbackColor = { 0, 1, 0.5 }
        feedbackTimer = 0.8
        cursorSpeed   = cursorSpeed + 0.35
    elseif dist <= hitZoneWidth then
        -- Good hit
        gulps = gulps + 1
        feedback      = "GOOD!"
        feedbackColor = { 1, 1, 0 }
        feedbackTimer = 0.8
        cursorSpeed   = cursorSpeed + 0.25
    else
        -- Miss
        feedback      = "MISS!"
        feedbackColor = { 1, 0.2, 0.2 }
        feedbackTimer = 0.8
        cursorSpeed   = cursorSpeed + 0.15   -- still gets a bit harder
    end

    beerLevel = 1.0 - (gulps / maxGulps)

    -- Shuffle the hit zone slightly each attempt
    hitZoneCenter = 0.3 + math.random() * 0.4

    if gulps >= maxGulps then
        completed     = true
        feedback      = "PROST!"
        feedbackColor = { 1, 0.85, 0 }
        feedbackTimer = 999
    end
end

function BeerDrink:isCompleted()
    return completed
end

function BeerDrink:draw()
    -- ── Header ──
    love.graphics.setColor(1, 0.85, 0)
    love.graphics.printf("BEER DRINKING", 0, 85, 800, "center")
    love.graphics.setColor(0.7, 0.7, 0.7)
    -- love.graphics.printf(
    --     "Press SPACE when the marker is in the green zone!",
    --     0, 105, 800, "center"
    -- )

    -- Progress
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        "Schlucke: " .. gulps .. " / " .. maxGulps,
        0, 125, 800, "center"
    )

    -- ── Beer Mug ──
    local mugX = 340
    local mugY = 160
    local mugW = 120
    local mugH = 160

    -- Mug body
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", mugX, mugY, mugW, mugH, 6, 6)

    -- Handle
    love.graphics.arc(
        "line", "open",
        mugX + mugW, mugY + mugH * 0.3,
        20, -math.pi / 2, math.pi / 2
    )

    -- Beer liquid (drains from bottom)
    local beerH = mugH * math.max(beerLevel, 0)
    local beerY = mugY + mugH - beerH

    love.graphics.setColor(1, 0.75, 0.1, 0.8)
    love.graphics.rectangle("fill", mugX + 3, beerY, mugW - 6, beerH - 3, 4, 4)

    -- Foam on top
    if beerLevel > 0.05 then
        love.graphics.setColor(1, 1, 0.9, 0.9)
        love.graphics.rectangle("fill", mugX + 3, beerY - 8, mugW - 6, 12, 6, 6)
    end

    -- ── Timing Bar ──
    local barX = 150
    local barY = 370
    local barW = 500
    local barH = 30

    -- Background
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", barX, barY, barW, barH, 6, 6)

    -- Hit zone (outer green)
    local zoneX = barX + (hitZoneCenter - hitZoneWidth) * barW
    local zoneW = hitZoneWidth * 2 * barW
    love.graphics.setColor(0.1, 0.6, 0.2, 0.5)
    love.graphics.rectangle("fill", zoneX, barY, zoneW, barH, 4, 4)

    -- Perfect zone (brighter inner)
    local perfX = barX + (hitZoneCenter - hitZoneWidth * 0.4) * barW
    local perfW = hitZoneWidth * 0.8 * barW
    love.graphics.setColor(0.1, 1.0, 0.3, 0.4)
    love.graphics.rectangle("fill", perfX, barY, perfW, barH, 4, 4)

    -- Bar outline
    love.graphics.setColor(0.5, 0.4, 0.3)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", barX, barY, barW, barH, 6, 6)

    -- Cursor line
    local cursorX = barX + cursor * barW
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.line(cursorX, barY - 5, cursorX, barY + barH + 5)

    -- Cursor triangle above
    love.graphics.setColor(1, 0.85, 0)
    love.graphics.polygon("fill",
        cursorX, barY - 8,
        cursorX - 6, barY - 16,
        cursorX + 6, barY - 16
    )

    -- ── Feedback ──
    if feedbackTimer > 0 then
        local a = math.min(feedbackTimer * 3, 1)
        love.graphics.setColor(
            feedbackColor[1], feedbackColor[2], feedbackColor[3], a
        )
        love.graphics.printf(feedback, 0, 340, 800, "center")
    end

    -- Speed indicator
    love.graphics.setColor(0.5, 0.5, 0.6)
    -- love.graphics.printf(
    --     "Speed: " .. string.format("%.1f", cursorSpeed) .. "x",
    --     0, 410, 800, "center"
    -- )
end

return BeerDrink
