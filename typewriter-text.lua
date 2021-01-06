local lg = love.graphics
local typewriters = {}
local typewriter = {}

function typewriter:new(text, length, x, y)
	assert(text and length and x and y, "FAILURE: typewriter:new() :: missing parameter")
	
	local t = {}
	if type(text) == "table" then
		text, t.color, t.font = unpack(text)
	end
	t.text = self:split(text)
	t.timeWaited = 0
	t.timeToWait = length
	t.curPrint = 1
	t.toShow = ""
	t.x = x
	t.y = y
	t.id = #typewriters + 1
	t.finished = false
	t.runCount = 0
	t.update = function(v, dt)
		v.timeWaited = v.timeWaited + dt
		while v.timeWaited >= v.timeToWait and v.curPrint <= #v.text do
			v.timeWaited = v.timeWaited - v.timeToWait
			v.toShow = v.toShow .. v.text[v.curPrint]
			v.curPrint = v.curPrint + 1
		end
		if v.curPrint >= #v.text and not v.finished then v.finished = true v.runCount = v.runCount + 1 end
	end
	t.draw = function(v) 
		if v.color and v.font then
			lg.print({v.color, v.toShow}, v.font, v.x, v.y)
		elseif v.color and not v.font then
			lg.print({v.color, v.toShow}, v.x, v.y)
		elseif not v.color and v.font then
			lg.print(v.toShow, v.font, v.x, v.y)
		else
			lg.print(v.toShow, v.x, v.y) 
		end
	end
	typewriters[t.id] = t
	return t
end

function typewriter:update(dt)
	for k, v in ipairs(typewriters) do v:update(dt) end
end

function typewriter:split(str)
	local t={}
	for s in string.gmatch(str, ".") do
			t[#t+1] = s
	end
	return t
end

function typewriter:draw()
	for k, v in ipairs(typewriters) do v:draw() end
end

function typewriter:reset(t)
	t.timeWaited = 0
	t.curPrint = 1
	t.toShow = ""
	t.finished = false
end

function typewriter:remove(t)
	if t == "all" then typewriters = {} else 
		assert(type(t) == "table", "FAILURE: typewriter:remove() :: the variable passed was not a typewriter.") 
		table.remove(typewriters, t.id) 
	end
end

return typewriter


---- main.lua
--[[
local typewriter = require("typewriter")

local myFont = love.graphics.newFont("pixelated.ttf")

local a = typewriter:new("hello", .5, 5, 10)
local b = typewriter:new({"world", {0,1,1,1}}, .5, 40, 10)
local c = typewriter:new({"This is my text...", {1,0,1,1}, myFont}, .1, 5, 50)

function love.update(dt)
	typewriter:update(dt)
end

function love.draw()
	typewriter:draw()
	if c.finished then typewriter:reset(c) end
	if c.runCount >= 3 then typewriter:remove(c) end
end
--]]
