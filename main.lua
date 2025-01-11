--NOTE: adapted from https://www.love2d.org/wiki/Tutorial:Animation

---@class Animation
---@field spriteSheet love.Image
---@field startIdx integer
---@field width number
---@field height number
---@field duration number
---@field currentTime number
---@field quads love.Quad[]
local Animation = {}
Animation.__index = Animation

---@param spriteSheet love.Image
---@param width number
---@param height number
---@param duration number?
---@param startIdx integer?
---@return Animation
function Animation:new(spriteSheet, width, height, duration, startIdx)
    local newAnimation = {
        spriteSheet = spriteSheet,
        width = width,
        height = height,
        duration = duration or 1.0,
        startIdx = startIdx or 1,
        currentTime = 0.0,
        quads = {},
    }
    local sw, sh = spriteSheet:getDimensions()

    for y = 0, sh - height, height do
        for x = 0, sw - width, width do
            table.insert(newAnimation.quads, love.graphics.newQuad(x, y, width, height, sw, sh))
        end
    end
    return setmetatable(newAnimation, self)
end

---@param dt number
function Animation:progress(dt)
    self.currentTime = (self.currentTime + dt) % self.duration
end

function Animation:curSprintIdx()
    return math.floor(self.currentTime / self.duration * #self.quads) + self.startIdx
end

function Animation:reset()
    self.currentTime = 0.0
end

---@param x number
---@param y number
---@param r number
---@param scaleX number
---@param scaleY number
function Animation:draw(x, y, r, scaleX, scaleY)
    love.graphics.draw(
        self.spriteSheet,
        self.quads[self:curSprintIdx()],
        x,
        y,
        r,
        scaleX,
        scaleY,
        self.width / 2,
        self.height / 2
    )
end

---@alias Direction "left"|"right"

---@class Player
---@field animation Animation
---@field posX number
---@field posY number
---@field dx number
---@field dy number
---@field dir Direction
local Player = {}
Player.__index = Player

---@param posX number
---@param posY number
---@param animation Animation
---@param dir Direction?
---@return Player
function Player:new(posX, posY, animation, dir)
    local newPlayer = {
        posX = posX,
        posY = posY,
        animation = animation,
        dx = 0.0,
        dy = 0.0,
        dir = dir or "left",
    }

    return setmetatable(newPlayer, self)
end

---@param dt number
---@param dx number
---@param dy number
function Player:update(dt, dx, dy)
    local moving = dx ~= 0.0 or dy ~= 0.0

    if moving then
        self.animation:progress(dt)
        if dx > 0 then
            self.dir = "left"
        elseif dx < 0 then
            self.dir = "right"
        end
        self.posX = self.posX + dx * dt
        self.posY = self.posY + dy * dt
    else
        self.animation:reset()
    end
end

function Player:draw()
    local scaleX, scaleY = 4, 4

    if self.dir == "right" then
        scaleX = -scaleX
    end

    self.animation:draw(self.posX, self.posY, 0, scaleX, scaleY)
end

Game = {}

function love.load()
    local W, H = love.window.getMode()
    local animation = Animation:new(love.graphics.newImage("assets/oldHero.png"), 16, 18, 0.65)
    Game.player = Player:new(W / 2 - animation.width / 2, H / 2 - animation.height / 2, animation)
end

function love.update(dt)
    local dx, dy = 0.0, 0.0
    local speed = 200

    if love.keyboard.isDown("up") then
        dy = -speed
    end

    if love.keyboard.isDown("down") then
        dy = speed
    end

    if love.keyboard.isDown("left") then
        dx = -speed
    end

    if love.keyboard.isDown("right") then
        dx = speed
    end

    Game.player:update(dt, dx, dy)
end

function love.draw()
    Game.player:draw()
end
