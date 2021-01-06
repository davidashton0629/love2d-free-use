function splitText (str)
	local t={}
	for s in string.gmatch(str, ".") do
			t[#t+1] = s
	end
	return t
end


local typewriter = {}
local typewriters = {}
function typewriter:new(text, length, x, y)
	local t = {}
	t.text = splitText(text)
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
	t.draw = function(self) love.graphics.print(self.toShow, self.x, self.y) end
	typewriters[t.id] = t
	return t
end

function typewriter:update(dt)
	for k, v in ipairs(typewriters) do v:update(dt) end
end

function typewriter:draw()
	for k, v in ipairs(typewriters) do v:draw(v) end
end

function typewriter:reset(t)
	t.timeWaited = 0
	t.curPrint = 1
	t.toShow = ""
	t.finished = false
end

function typewriter:remove(t)
	table.remove(typewriters, t.id)
end

return typewriter

---- main.lua
--[[
local typewriter = require("typewriter")

local a = typewriter:new("hello", .5, 5, 10)
local b = typewriter:new("world", .5, 40, 10)
local c = typewriter:new("This is my text...", .1, 5, 50)

function love.update(dt)
	typewriter:update(dt)
end

function love.draw()
	typewriter:draw()
	if c.finished then typewriter:reset(c) end
	if c.runCount >= 3 then typewriter:remove(c) end
end
--]]
