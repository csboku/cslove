-- assets.lua — Central asset loader (images, sounds, fonts)
-- Call Assets.load() once in love.load(), then reference Assets.<name> anywhere.

local Assets = {}

function Assets.load()
    -- ── Backgrounds ──
    Assets.bg    = love.graphics.newImage("assets/backgrounds/armin_BG.png")
    Assets.canvas = love.graphics.newImage("assets/backgrounds/armin_canvas.png")

    -- Make the canvas tileable (repeating horizontally)
    Assets.canvas:setWrap("repeat", "clampzero")

    -- ── Player sprites ──
    Assets.playerIdleRight = love.graphics.newImage("assets/sprites/player_1/idle_right.png")
    Assets.playerWalkRight = love.graphics.newImage("assets/sprites/player_1/walk_right.png")

    -- ── Dog sprite ──
    Assets.dog = love.graphics.newImage("assets/sprites/dog/dog.png")

    -- ── Building logos (one per level) ──
    Assets.logos = {
        love.graphics.newImage("assets/logos/bergfex-logo.png"),
        love.graphics.newImage("assets/logos/lotte-logo.png"),
        love.graphics.newImage("assets/logos/kork-logo.png"),
    }
end

return Assets
