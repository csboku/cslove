-- minigames/simon.lua — "Simon Says" arrow-key memory game
-- Used inside Building 2.

local Simon = {}

local sequence       = {}
local playerSequence = {}
local round          = 1
local maxRounds      = 3
local baseLength     = 3     -- sequence grows each round
local showingSequence = true
local showIndex      = 0
local showTimer      = 0
local showDuration   = 0.55
local pauseDuration  = 0.25
local completed      = false
local failed         = false
local failTimer      = 0
local activeDir      = nil
local activeTimer    = 0

local directions = { "up", "down", "left", "right" }

local dirColors = {
    up    = { 0.2, 0.8, 1.0 },
    down  = { 1.0, 0.4, 0.2 },
    left  = { 0.2, 1.0, 0.4 },
    right = { 1.0, 0.8, 0.2 },
}

local dirLabels = { up = "W / ↑", down = "S / ↓", left = "A / ←", right = "D / →" }

-- ── Helpers ─────────────────────────────────────────────────────

local function generateSequence()
    sequence = {}
    local len = baseLength + round - 1
    for _ = 1, len do
        table.insert(sequence, directions[math.random(1, 4)])
    end
    playerSequence  = {}
    showingSequence = true
    showIndex       = 0
    showTimer       = -0.5   -- brief pause before showing
end

-- ── Interface ───────────────────────────────────────────────────

function Simon:init()
    round     = 1
    completed = false
    failed    = false
    failTimer = 0
    activeDir   = nil
    activeTimer = 0
    generateSequence()
end

function Simon:update(dt)
    if completed then return end

    -- Wrong-answer cooldown
    if failed then
        failTimer = failTimer + dt
        if failTimer >= 1.5 then
            failed    = false
            failTimer = 0
            generateSequence()
        end
        return
    end

    -- Active-direction visual feedback timer
    if activeTimer > 0 then
        activeTimer = activeTimer - dt
        if activeTimer <= 0 then activeDir = nil end
    end

    -- Advance the "show sequence" animation
    if showingSequence then
        showTimer = showTimer + dt
        if showTimer >= showDuration + pauseDuration then
            showTimer = 0
            showIndex = showIndex + 1
            if showIndex > #sequence then
                showingSequence = false
            end
        end
    end
end

function Simon:keypressed(key)
    if completed or showingSequence or failed then return end

    -- Map WASD + arrows → direction name
    local map = {
        up = "up",  w = "up",
        down = "down", s = "down",
        left = "left", a = "left",
        right = "right", d = "right",
    }
    local dir = map[key]
    if not dir then return end

    activeDir   = dir
    activeTimer = 0.2

    table.insert(playerSequence, dir)
    local idx = #playerSequence

    if playerSequence[idx] ~= sequence[idx] then
        failed    = true
        failTimer = 0
        return
    end

    if #playerSequence == #sequence then
        round = round + 1
        if round > maxRounds then
            completed = true
        else
            generateSequence()
        end
    end
end

function Simon:isCompleted()
    return completed
end

function Simon:draw()
    -- Header
    love.graphics.setColor(0.8, 0.6, 1.0)
    love.graphics.printf("SIMON SAYS", 0, 85, 800, "center")
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(
        "Repeat the sequence!   Round "
        .. math.min(round, maxRounds) .. " / " .. maxRounds,
        0, 105, 800, "center"
    )

    -- Four direction pads (cross layout)
    local cx, cy = 400, 275
    local sz     = 60
    local gap    = 8

    local positions = {
        up    = { cx - sz / 2, cy - sz - gap },
        down  = { cx - sz / 2, cy + gap },
        left  = { cx - sz - gap, cy - sz / 2 },
        right = { cx + gap, cy - sz / 2 },
    }

    for dir, pos in pairs(positions) do
        local isActive = false

        -- Highlight during sequence playback
        if showingSequence
           and showIndex >= 1 and showIndex <= #sequence
           and sequence[showIndex] == dir
           and showTimer < showDuration then
            isActive = true
        end

        -- Highlight on player input
        if activeDir == dir and activeTimer > 0 then
            isActive = true
        end

        local c = dirColors[dir]
        if isActive then
            love.graphics.setColor(c[1], c[2], c[3])
        else
            love.graphics.setColor(c[1] * 0.3, c[2] * 0.3, c[3] * 0.3)
        end
        love.graphics.rectangle("fill", pos[1], pos[2], sz, sz, 8, 8)

        love.graphics.setColor(1, 1, 1, isActive and 1 or 0.4)
        love.graphics.printf(dirLabels[dir], pos[1], pos[2] + sz / 2 - 7, sz, "center")
    end

    -- Status text
    local statusY = 370
    if showingSequence then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("Watch the sequence…", 0, statusY, 800, "center")
    elseif failed then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("Wrong! Try again…", 0, statusY, 800, "center")
    else
        love.graphics.setColor(0, 1, 0.5)
        love.graphics.printf(
            "Your turn!  ( " .. #playerSequence .. " / " .. #sequence .. " )",
            0, statusY, 800, "center"
        )
    end
end

return Simon
