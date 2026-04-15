-- player.lua — Player entity (movement, physics, drawing)

local Utils = require("utils")

local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x or 100
    self.y = y or 100
    self.width  = 30
    self.height = 30
    self.dx = 0
    self.dy = 0
    self.acceleration  = 800
    self.friction       = 600
    self.max_speed      = 250
    self.run_multiplier = 1.6
    self.gravity    = 1500
    self.jump_force = -850
    self.isGrounded  = false
    self.isDead      = false
    self.facingRight = true
    return self
end

function Player:reset(x, y)
    self.x  = x or 100
    self.y  = y or 100
    self.dx = 0
    self.dy = 0
    self.isDead      = false
    self.isGrounded  = false
    self.facingRight = true
end

--- Update movement and resolve collisions against `boxes`.
--- The `boxes` table may contain types "solid" and "bouncy".
function Player:update(dt, boxes)
    if self.isDead then return end

    -- ── Horizontal movement ──
    local moving = false
    local current_max = self.max_speed

    if love.keyboard.isDown("z") or love.keyboard.isDown("lshift") then
        current_max = current_max * self.run_multiplier
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.dx = self.dx + self.acceleration * dt
        moving = true
        self.facingRight = true
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.dx = self.dx - self.acceleration * dt
        moving = true
        self.facingRight = false
    end

    -- Friction when idle
    if not moving then
        if self.dx > 0 then
            self.dx = math.max(0, self.dx - self.friction * dt)
        elseif self.dx < 0 then
            self.dx = math.min(0, self.dx + self.friction * dt)
        end
    end

    -- Speed clamp
    if self.dx >  current_max then self.dx =  current_max end
    if self.dx < -current_max then self.dx = -current_max end

    -- Apply X movement
    self.x = self.x + self.dx * dt
    if self.x < 0 then self.x = 0; self.dx = 0 end

    -- X collision resolution
    for _, box in ipairs(boxes) do
        if (box.type == "solid" or box.type == "bouncy") and
           Utils.checkCollision(self.x, self.y, self.width, self.height,
                                box.x, box.y, box.width, box.height) then
            if self.dx > 0 then
                self.x = box.x - self.width; self.dx = 0
            elseif self.dx < 0 then
                self.x = box.x + box.width;  self.dx = 0
            end
        end
    end

    -- ── Vertical physics ──
    self.dy = self.dy + self.gravity * dt
    self.y  = self.y + self.dy * dt
    self.isGrounded = false

    for _, box in ipairs(boxes) do
        if (box.type == "solid" or box.type == "bouncy") and
           Utils.checkCollision(self.x, self.y, self.width, self.height,
                                box.x, box.y, box.width, box.height) then
            if self.dy > 0 then -- landing
                self.y = box.y - self.height
                if box.type == "bouncy" then
                    self.dy = -1100
                else
                    self.dy = 0
                    self.isGrounded = true
                end
            elseif self.dy < 0 then -- bonk head
                self.y  = box.y + box.height
                self.dy = 0
            end
        end
    end

    -- Pit death
    if self.y > 800 then
        self.isDead = true
    end
end

function Player:jump()
    if self.isGrounded and not self.isDead then
        self.dy = self.jump_force
    end
end

function Player:releaseJump()
    if self.dy < 0 then
        self.dy = self.dy * 0.45
    end
end

function Player:draw()
    -- Neon green body
    love.graphics.setColor(0.1, 1.0, 0.6)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- White directional edge
    love.graphics.setColor(1, 1, 1)
    if self.facingRight then
        love.graphics.rectangle("fill", self.x + self.width - 6, self.y, 6, self.height)
    else
        love.graphics.rectangle("fill", self.x, self.y, 6, self.height)
    end
end

return Player
