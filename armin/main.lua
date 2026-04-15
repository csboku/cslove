local player = {
    x = 100, y = 100, width = 30, height = 30,
    dx = 0, dy = 0,
    acceleration = 800, friction = 600, 
    max_speed = 250, run_multiplier = 1.6,
    gravity = 1500, jump_force = -850,
    isGrounded = false, isDead = false,
    facingRight = true
}

local camX = 0
local boxes = {}
local enemies = {}

function love.load()
    love.window.setTitle("Neon Jumper")
    love.window.setMode(800, 600)
    
    ResetLevel()
end

function ResetLevel()
    player.x = 100
    player.y = 100
    player.dx = 0
    player.dy = 0
    player.isDead = false
    player.facingRight = true

    camX = 0
    boxes = {}
    enemies = {}

    -- --- Level Design ---
    -- Main ground segments
    table.insert(boxes, {x = 0, y = 500, width = 600, height = 150, type = "solid"})
    
    -- A higher block after a gap
    table.insert(boxes, {x = 700, y = 400, width = 200, height = 250, type = "solid"})
    
    -- Floating stepping stones
    table.insert(boxes, {x = 1000, y = 300, width = 80, height = 20, type = "solid"})
    table.insert(boxes, {x = 1200, y = 200, width = 80, height = 20, type = "solid"})
    
    -- Upper platform
    table.insert(boxes, {x = 1500, y = 100, width = 500, height = 20, type = "solid"})
    
    -- Ground below the upper platform
    table.insert(boxes, {x = 1400, y = 550, width = 800, height = 100, type = "solid"})

    -- Bouncy pad to launch up
    table.insert(boxes, {x = 2000, y = 530, width = 100, height = 20, type = "bouncy"})
    



    -- Huge Wall at the end
    --table.insert(boxes, {x = 2100, y = -200, width = 100, height = 800, type = "solid"})

    -- --- Enemies ---
    table.insert(enemies, {x = 450, y = 470, width = 30, height = 30, dx = -90, isDead = false})
    table.insert(enemies, {x = 850, y = 370, width = 30, height = 30, dx = -110, isDead = false})
    table.insert(enemies, {x = 1600, y = 520, width = 30, height = 30, dx = -140, isDead = false})
    table.insert(enemies, {x = 1700, y = 70, width = 30, height = 30, dx = -100, isDead = false})
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end


function love.update(dt)
    if player.isDead then return end

    -- --- 1. Player Horizontal Physics ---
    local moving = false
    local current_max = player.max_speed
    
    -- Sprinting
    if love.keyboard.isDown("z") or love.keyboard.isDown("lshift") then
        current_max = current_max * player.run_multiplier
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        player.dx = player.dx + player.acceleration * dt
        moving = true
        player.facingRight = true
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        player.dx = player.dx - player.acceleration * dt
        moving = true
        player.facingRight = false
    end

    -- Apply Friction if no keys are pressed
    if not moving then
        if player.dx > 0 then
            player.dx = math.max(0, player.dx - player.friction * dt)
        elseif player.dx < 0 then
            player.dx = math.min(0, player.dx + player.friction * dt)
        end
    end

    -- Clamp velocity to max speed
    if player.dx > current_max then player.dx = current_max end
    if player.dx < -current_max then player.dx = -current_max end

    -- Apply X movement
    player.x = player.x + player.dx * dt
    if player.x < 0 then 
        player.x = 0 
        player.dx = 0
    end

    -- Resolve X Collisions
    for _, box in ipairs(boxes) do
        if CheckCollision(player.x, player.y, player.width, player.height, box.x, box.y, box.width, box.height) then
            if player.dx > 0 then
                player.x = box.x - player.width
                player.dx = 0
            elseif player.dx < 0 then
                player.x = box.x + box.width
                player.dx = 0
            end
        end
    end

    -- --- 2. Player Vertical Physics ---
    player.dy = player.dy + player.gravity * dt
    player.y = player.y + player.dy * dt

    player.isGrounded = false

    -- Resolve Y Collisions
    for _, box in ipairs(boxes) do
        if CheckCollision(player.x, player.y, player.width, player.height, box.x, box.y, box.width, box.height) then
            if player.dy > 0 then -- Landing on top
                player.y = box.y - player.height
                if box.type == "bouncy" then
                    -- Bounce pad gives huge vertical momentum
                    player.dy = -1100
                    player.isGrounded = false
                else
                    player.dy = 0
                    player.isGrounded = true
                end
            elseif player.dy < 0 then -- Bonking head from below
                player.y = box.y + box.height
                player.dy = 0
            end
        end
    end

    -- --- 3. Enemies Logic ---
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        
        if not enemy.isDead then
            -- Enemy X Movement
            enemy.x = enemy.x + enemy.dx * dt
            
            -- Enemy wall collision
            local hitWall = false
            for _, box in ipairs(boxes) do
                if CheckCollision(enemy.x, enemy.y, enemy.width, enemy.height, box.x, box.y, box.width, box.height) then
                    if enemy.dx > 0 then enemy.x = box.x - enemy.width
                    else enemy.x = box.x + box.width end
                    hitWall = true
                end
            end
            if hitWall then enemy.dx = -enemy.dx end -- turnaround

            -- Enemy Y / Gravity
            enemy.y = enemy.y + 500 * dt
            for _, box in ipairs(boxes) do
                if CheckCollision(enemy.x, enemy.y, enemy.width, enemy.height, box.x, box.y, box.width, box.height) then
                    enemy.y = box.y - enemy.height
                end
            end

            -- Stomp & Player Hit Logic
            if CheckCollision(player.x, player.y, player.width, player.height, enemy.x, enemy.y, enemy.width, enemy.height) then
                -- Player stomps enemy (player moving down, slightly above the enemy)
                if player.dy > 0 and player.y + player.height - player.dy * dt <= enemy.y + 15 then
                    enemy.isDead = true
                    -- Stomp bounce
                    if love.keyboard.isDown("space") or love.keyboard.isDown("up") or love.keyboard.isDown("w") then
                        player.dy = player.jump_force * 1.1 -- Slightly bigger bounce if holding jump
                    else
                        player.dy = player.jump_force * 0.7 -- Normal bounce
                    end
                else
                    -- Player takes damage
                    player.isDead = true
                end
            end
        end
    end

    -- Remove dead enemies
    for i = #enemies, 1, -1 do
        if enemies[i].isDead then
            table.remove(enemies, i)
        end
    end

    -- --- 4. Game Over Logic (Fell in Pit) ---
    if player.y > 800 then
        player.isDead = true
    end

    -- --- 5. Camera update ---
    local targetCamX = player.x - 400 + player.width / 2
    if targetCamX < 0 then targetCamX = 0 end
    camX = camX + (targetCamX - camX) * 10 * dt
end

function love.keypressed(key)
    if player.isDead then
        if key == "r" then ResetLevel() end
        return
    end

    -- Jump
    if (key == "up" or key == "w" or key == "space") and player.isGrounded then
        player.dy = player.jump_force
    end
end

function love.keyreleased(key)
    -- Variable jump height
    if (key == "up" or key == "w" or key == "space") and player.dy < 0 then
        player.dy = player.dy * 0.45 
    end
end

function love.draw()
    -- Deep dark geometric background
    love.graphics.setBackgroundColor(0.05, 0.05, 0.08)

    love.graphics.push()
    love.graphics.translate(-math.floor(camX), 0)

    -- Draw Environment Objects
    for _, box in ipairs(boxes) do
        if box.type == "solid" then
            -- Dark inner platform
            love.graphics.setColor(0.1, 0.1, 0.15)
            love.graphics.rectangle("fill", box.x, box.y, box.width, box.height)
            -- Cyan glowing outline
            love.graphics.setColor(0.0, 0.8, 1.0)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", box.x, box.y, box.width, box.height)
        elseif box.type == "bouncy" then
            -- Orange jump pad
            love.graphics.setColor(1, 0.4, 0.0)
            love.graphics.rectangle("fill", box.x, box.y, box.width, box.height)
            love.graphics.setColor(1, 1, 0)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", box.x, box.y, box.width, box.height)
            -- Details
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("^^^", box.x + box.width/2 - 12, box.y + 2)
        end
    end

    -- Draw Enemies (Magenta patrol blocks)
    for _, enemy in ipairs(enemies) do
        love.graphics.setColor(1, 0.1, 0.4) -- Neon magenta
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
        -- Glowing core
        love.graphics.setColor(1, 0.7, 0.8)
        love.graphics.rectangle("fill", enemy.x + 10, enemy.y + 10, 10, 10)
    end

    -- Draw Player (Neon Green hollow block)
    love.graphics.setColor(0.1, 1.0, 0.6)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Directional Light edge
    love.graphics.setColor(1, 1, 1)
    if player.facingRight then
        love.graphics.rectangle("fill", player.x + player.width - 6, player.y, 6, player.height)
    else
        love.graphics.rectangle("fill", player.x, player.y, 6, player.height)
    end
    
    love.graphics.pop() -- End Camera

    -- Draw UI
    love.graphics.setColor(1, 1, 1)
    if player.isDead then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.print("SYSTEM CRITICAL FAILURE", 300, 250, 0, 1.5, 1.5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Press 'R' to Reboot", 330, 300, 0, 1.2, 1.2)
    else
        love.graphics.print("Move: A/D | Sprint: Shift | Jump: Space", 10, 10)
    end
end
