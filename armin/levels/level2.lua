-- levels/level2.lua BERGFEX zu Lotte

return {
    name = "Feierabend",

    playerStart = { x = 100, y = 400 },

    building = {
        x = 3200, y = 350, width = 220, height = 250,
    },

    boxes = {
        -- Starting platform
        { x = 0,    y = 500, width = 400, height = 150, type = "solid" },
        -- Staircase up
        { x = 500,  y = 440, width = 100, height = 20,  type = "solid" },
        { x = 650,  y = 370, width = 100, height = 20,  type = "solid" },
        { x = 800,  y = 300, width = 100, height = 20,  type = "solid" },
        -- High platform
        { x = 950,  y = 250, width = 300, height = 20,  type = "solid" },
        -- Drop to bouncy pad
        { x = 1300, y = 550, width = 100, height = 20,  type = "bouncy" },
        -- Mid platforms after bounce
        { x = 1450, y = 200, width = 150, height = 20,  type = "solid" },
        { x = 1700, y = 250, width = 150, height = 20,  type = "solid" },
        -- Long ground section
        { x = 1900, y = 500, width = 600, height = 150, type = "solid" },
        -- Another set of jumps
        { x = 2600, y = 400, width = 80,  height = 20,  type = "solid" },
        { x = 2750, y = 300, width = 80,  height = 20,  type = "solid" },
        { x = 2900, y = 400, width = 80,  height = 20,  type = "solid" },
        -- Final platform with building
        { x = 3050, y = 500, width = 400, height = 150, type = "solid" },
    },

    enemies = {
        { x = 250,  y = 470, dx = -100 },
        { x = 1000, y = 220, dx = -120 },
        { x = 2000, y = 470, dx = -150 },
        { x = 2200, y = 470, dx =  130 },
        { x = 2400, y = 470, dx = -110 },
    },
}
