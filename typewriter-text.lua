--[[
	Requires LOVE2D -- https://love2d.org/
--]]
local lg = love.graphics
local typewriter = {}
typewriter.typewriters = {}

-- text, time between each letter, x, y, repeat
function typewriter:new(text, l, x, y, r)
	assert(text, "FAILURE: typewriter:new() :: missing parameter [text]")
	assert(l, "FAILURE: typewriter:new() :: missing parameter [l]")
	assert(type(l) == "string" or type(l) == "number", "FAILURE: typewriter:new() :: incorrect param[l]")
	assert(x, "FAILURE: typewriter:new() :: missing parameter [x]")
	assert(type(x) == "string" or type(x) == "number", "FAILURE: typewriter:new() :: incorrect param[x]")
	assert(y, "FAILURE: typewriter:new() :: missing parameter [y]")
	assert(type(y) == "string" or type(y) == "number", "FAILURE: typewriter:new() :: incorrect param[y]")
	
	
	local t = {}
	if type(text) == "table" then
		if text[2] then
			assert(text[2] and type(text[2]) == "table", "FAILURE: typewriter:new() :: text table color param incorrect.")
			while type(text[2][1]) == "table" do text[2] = text[2][1] end
		end
		text, t.color, t.font = unpack(text)
	end
	t.text = self:split(text)
	t.timeWaited = 0
	t.timeToWait = tonumber(l)
	t.curPrint = 1
	t.toShow = ""
	t.x = tonumber(x)
	t.y = tonumber(y)
	t.id = #self.typewriters + 1
	t.finished = false
	t.runCount = 0
	t.show = true
	t.rep = r or false
	
	function t:update(dt)
		self.timeWaited = self.timeWaited + dt
		while self.timeWaited >= self.timeToWait and self.curPrint <= #self.text do
			self.timeWaited = self.timeWaited - self.timeToWait
			self.toShow = self.toShow .. self.text[self.curPrint]
			self.curPrint = self.curPrint + 1
		end
		if self.curPrint >= #self.text and not self.finished then
			if not self.rep then self.finished = true else self:reset() end
			self.runCount = self.runCount + 1
		end
	end
	
	function t:draw()
		if self.color and self.font then
			lg.print({self.color, self.toShow}, self.font, self.x, self.y)
		elseif self.color and not self.font then
			lg.print({self.color, self.toShow}, self.x, self.y)
		elseif not self.color and self.font then
			lg.print(self.toShow, self.font, self.x, self.y)
		else
			lg.print(self.toShow, self.x, self.y) 
		end
	end
	
	function t:setSpeed(s)
		assert(s and (type(s) == "string" or type(s) == "number"), "FAILURE: typewriter:setSpeed() :: speed param incorrect.")
		self.timeToWait = tonumber(s)
	end
	
	function t:getSpeed()
		return self.timeToWait
	end
	
	function t:setColor(c)
		assert(c and type(c) == "table", "FAILURE: typewriter:setColor() :: color param incorrect.")
		self.color = c
	end
	
	function t:getColor()
		return self.color
	end
	
	function t:setFont(f)
		assert(f and type(f) == "userdata", "FAILURE: typewriter:setFont() :: font param incorrect.")
		self.font = f
	end
	
	function t:getFont()
		return self.font
	end
	
	function t:toggle(r)
		self.show = not self.show
		if r then self:reset() end
	end
	
	function t:remove()
		typewriter.typewriters[self.id] = {}
	end
	
	function t:reset()
		self.timeWaited = 0
		self.curPrint = 1
		self.toShow = ""
		self.finished = false
	end
	
	self.typewriters[t.id] = self:create(t)
	return self.typewriters[t.id]
end

function typewriter:create(item)
	local copies = {}
    local copy
    if type(item) == 'table' then
        if copies[item] then
            copy = copies[item]
        else
            copy = {}
            copies[item] = copy
            for orig_key, orig_value in next, item, nil do
                copy[self:create(orig_key, copies)] = self:create(orig_value, copies)
            end
            setmetatable(copy, self:create(getmetatable(item), copies))
        end
    else
        copy = item
    end
    return copy
end

function typewriter:split(str)
	local t={}
	for s in string.gmatch(str, ".") do
		t[#t+1] = s
	end
	return t
end

function typewriter:update(dt)
	for _,t in ipairs(self.typewriters) do if t.show then t:update(dt) end end
end

function typewriter:draw()
	for _,t in ipairs(self.typewriters) do if t.show then t:draw() end end
end

return typewriter


---- main.lua
--[[

local typewriter = require("typewriter")

local myFont = love.graphics.newFont("pixelated.ttf")
local colors = { red = {1,0,0,1}, blue = {0,1,0,1}, green = {0,0,1,1}, white = {1,1,1,1}, black = {0,0,0,0} }

local a = typewriter:new("hello", .5, 5, 10)
local b = typewriter:new({"world", {0,1,1,1}}, .5, 40, 10)
local c = typewriter:new({"This is my text...", {1,0,1,1}, myFont}, .05, 5, 50, true)
local d = typewriter:new({"Let's get it started", nil, myFont}, .01, 100, 100)

local playTime = 0

function love.update(dt)
	typewriter:update(dt)
	playTime = playTime + dt
	
	if playTime > 2 then 
		playTime = 0
		if b.color ~= colors.red then b:setColor(colors.red) end
		if b.font ~= myFont then b:setFont(myFont) end
		if c.timeToWait ~= 0.2 then c:setSpeed(1) end
		c:toggle(true)
	end
end

function love.draw()
	typewriter:draw()
	
	if c.runCount >= 3 then c:remove() end
end

--]]
