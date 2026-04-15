-- camera.lua — Smooth horizontal-tracking camera

local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)
    self.x = 0
    self.smoothing = 10
    return self
end

--- Smoothly follow a target X position (e.g. player center).
function Camera:update(dt, targetX)
    local tx = targetX - 400  -- center on screen (800 / 2)
    if tx < 0 then tx = 0 end
    self.x = self.x + (tx - self.x) * self.smoothing * dt
end

--- Call inside love.graphics.push() to offset the world.
function Camera:apply()
    love.graphics.translate(-math.floor(self.x), 0)
end

function Camera:reset()
    self.x = 0
end

return Camera
