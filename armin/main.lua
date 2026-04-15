-- main.lua — Entry point & game state manager
-- All game logic is delegated to state modules (play, building, victory).

local PlayState     = require("states.play")
local BuildingState = require("states.building")
local VictoryState  = require("states.victory")

local stateMap = {
    play     = PlayState,
    building = BuildingState,
    victory  = VictoryState,
}

-- Global game context shared with all states
local Game = {
    currentState = nil,
    currentLevel = 1,
    maxLevels    = 3,
}

function Game.switchState(stateName, ...)
    if Game.currentState and Game.currentState.exit then
        Game.currentState:exit()
    end
    Game.currentState = stateMap[stateName]
    if Game.currentState and Game.currentState.enter then
        Game.currentState:enter(...)
    end
end

-- ── LÖVE Callbacks ──────────────────────────────────────────────

function love.load()
    love.window.setTitle("Neon Runner")
    love.window.setMode(800, 600)
    math.randomseed(os.time())
    Game.switchState("play", 1)
end

function love.update(dt)
    if Game.currentState and Game.currentState.update then
        Game.currentState:update(dt, Game)
    end
end

function love.keypressed(key)
    if Game.currentState and Game.currentState.keypressed then
        Game.currentState:keypressed(key, Game)
    end
end

function love.keyreleased(key)
    if Game.currentState and Game.currentState.keyreleased then
        Game.currentState:keyreleased(key, Game)
    end
end

function love.mousepressed(x, y, button)
    if Game.currentState and Game.currentState.mousepressed then
        Game.currentState:mousepressed(x, y, button, Game)
    end
end

function love.draw()
    if Game.currentState and Game.currentState.draw then
        Game.currentState:draw(Game)
    end
end
