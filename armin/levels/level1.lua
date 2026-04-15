-- levels/level1.lua — "City Outskirts" (easy, teaches basics)

return {
    name = "Arbeitsweg",

    playerStart = { x = 100, y = 400 },

    -- Building at the end of the level (enter to trigger minigame)
    building = {
        x = 2400, y = 250, width = 220, height = 250,
    },

    boxes = {
        -- Main ground
        { x = 0,    y = 500, width = 600, height = 150, type = "solid" },
        -- Higher block after a gap
        { x = 700,  y = 400, width = 200, height = 250, type = "solid" },
        -- Floating stepping stones
        { x = 1000, y = 300, width = 80,  height = 20,  type = "solid" },
        { x = 1200, y = 200, width = 80,  height = 20,  type = "solid" },
        -- Upper platform
        --{ x = 1500, y = 100, width = 500, height = 20,  type = "solid" },
        -- Ground below the upper platform
        { x = 1400, y = 550, width = 200, height = 100, type = "solid" },
        { x = 1700, y = 550, width = 300, height = 100, type = "solid" },

        -- Bouncy pad
        { x = 2000, y = 530, width = 100, height = 20,  type = "bouncy" },
        -- Final ground with building
        { x = 2200, y = 500, width = 500, height = 150, type = "solid" },
    },

    enemies = {
        { x = 450,  y = 470, dx = -90  },
        { x = 850,  y = 370, dx = -110 },
        { x = 1600, y = 520, dx = -140 },
        { x = 1700, y = 70,  dx = -100 },
    },
}
