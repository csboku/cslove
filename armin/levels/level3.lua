-- levels/level3.lua — Lotte -> Nach Hause

return {
    name = "Heimweg",

    playerStart = { x = 100, y = 200 },

    building = {
        x = 3800, y = 250, width = 220, height = 250,
    },

    boxes = {
        -- Starting rooftop
        { x = 0,    y = 300, width = 300, height = 350, type = "solid" },
        -- Floating platforms (big gaps!)
        { x = 400,  y = 280, width = 60,  height = 20,  type = "solid" },
        { x = 560,  y = 220, width = 60,  height = 20,  type = "solid" },
        { x = 720,  y = 160, width = 60,  height = 20,  type = "solid" },
        -- Bouncy launcher
        { x = 900,  y = 400, width = 80,  height = 20,  type = "bouncy" },
        -- High platforms
        { x = 1050, y = 100, width = 200, height = 20,  type = "solid" },
        { x = 1350, y = 150, width = 200, height = 20,  type = "solid" },
        -- Drop to mid-level
        { x = 1600, y = 350, width = 300, height = 20,  type = "solid" },
        -- Precision section
        { x = 2000, y = 280, width = 60,  height = 20,  type = "solid" },
        { x = 2150, y = 200, width = 60,  height = 20,  type = "solid" },
        { x = 2300, y = 280, width = 60,  height = 20,  type = "solid" },
        { x = 2450, y = 200, width = 60,  height = 20,  type = "solid" },
        -- Long platform
        { x = 2600, y = 350, width = 400, height = 20,  type = "solid" },
        -- Final bouncy to building
        { x = 3100, y = 500, width = 100, height = 20,  type = "bouncy" },
        -- Stepping stones to building
        { x = 3300, y = 300, width = 80,  height = 20,  type = "solid" },
        { x = 3500, y = 350, width = 80,  height = 20,  type = "solid" },
        -- Building platform
        { x = 3700, y = 400, width = 400, height = 250, type = "solid" },
    },

    enemies = {
        { x = 1100, y = 70,  dx = -130 },
        { x = 1650, y = 320, dx = -100 },
        { x = 1800, y = 320, dx =  110 },
        { x = 2650, y = 320, dx = -140 },
        { x = 2800, y = 320, dx =  120 },
        { x = 3750, y = 370, dx =  -90 },
    },
}
