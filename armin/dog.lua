-- dog.lua — Companion dog that follows the player around
-- Has its own physics, auto-jumps to follow, and a wagging tail animation.
-- Purely cosmetic — enemies pass through it.

local Utils = require("utils")

local Dog = {}
Dog.__index = Dog

function Dog.new(x, y)
    local self = setmetatable({}, Dog)
    self.x = x or 50
    self.y = y or 100
    self.width  = 20
    self.height = 14
    self.dx = 0
    self.dy = 0
    self.speed      = 600
    self.maxSpeed   = 280
    self.gravity    = 1500
    self.jumpForce  = -820
    self.isGrounded = false
    self.facingRight = true
    self.tailWag    = 0
    self.followDist = 45
    return self
end

function Dog:update(dt, player, boxes)
    self.tailWag = self.tailWag + dt * 8

    -- Target: stay behind the player
    local targetX
    if player.facingRight then
        targetX = player.x - self.followDist
    else
        targetX = player.x + player.width + self.followDist - self.width
    end

    -- Accelerate toward target
    local distX = targetX - self.x
    if math.abs(distX) > 8 then
        if distX > 0 then
            self.dx = self.dx + self.speed * dt
            self.facingRight = true
        else
            self.dx = self.dx - self.speed * dt
            self.facingRight = false
        end
    else
        -- Friction when close
        self.dx = self.dx * (1 - 8 * dt)
    end

    -- Speed cap
    if self.dx >  self.maxSpeed then self.dx =  self.maxSpeed end
    if self.dx < -self.maxSpeed then self.dx = -self.maxSpeed end

    -- Apply X movement
    self.x = self.x + self.dx * dt
    if self.x < 0 then self.x = 0; self.dx = 0 end

    -- X collision
    for _, box in ipairs(boxes) do
        if (box.type == "solid" or box.type == "bouncy") and
           Utils.checkCollision(self.x, self.y, self.width, self.height,
                                box.x, box.y, box.width, box.height) then
            if self.dx > 0 then
                self.x = box.x - self.width; self.dx = 0
            elseif self.dx < 0 then
                self.x = box.x + box.width; self.dx = 0
            end
        end
    end

    -- Gravity
    self.dy = self.dy + self.gravity * dt
    self.y  = self.y + self.dy * dt
    self.isGrounded = false

    for _, box in ipairs(boxes) do
        if (box.type == "solid" or box.type == "bouncy") and
           Utils.checkCollision(self.x, self.y, self.width, self.height,
                                box.x, box.y, box.width, box.height) then
            if self.dy > 0 then
                self.y = box.y - self.height
                if box.type == "bouncy" then
                    self.dy = -900
                else
                    self.dy = 0
                    self.isGrounded = true
                end
            elseif self.dy < 0 then
                self.y = box.y + box.height
                self.dy = 0
            end
        end
    end

    -- Auto-jump when player is above
    if self.isGrounded and player.y < self.y - 35 then
        self.dy = self.jumpForce
    end

    -- Teleport if too far away or fell into pit
    local totalDist = math.sqrt((self.x - player.x)^2 + (self.y - player.y)^2)
    if totalDist > 500 or self.y > 800 then
        self.x  = player.x - 30
        self.y  = player.y
        self.dx = 0
        self.dy = 0
    end
end

function Dog:draw()
    -- Orange-brown body
    love.graphics.setColor(0.85, 0.55, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- White directional edge
    love.graphics.setColor(1, 1, 1)
    if self.facingRight then
        love.graphics.rectangle("fill", self.x + self.width - 4, self.y, 4, self.height)
    else
        love.graphics.rectangle("fill", self.x, self.y, 4, self.height)
    end
end

return Dog
