function splitText (str) -- create function to split string by each letter
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
	t.update = function(self, dt, v)
		v.timeWaited = v.timeWaited + dt -- add to wait time
		while v.timeWaited >= v.timeToWait and v.curPrint <= #v.text do
			v.timeWaited = v.timeWaited - v.timeToWait
			v.toShow = v.toShow .. v.text[v.curPrint] -- add to shown text
			v.curPrint = v.curPrint + 1 -- increase printing location 
		end
	end
	t.draw = function(self, v) love.graphics.print(v.toShow, v.x, v.y) end
	typewriters[#typewriters + 1] = t
	return t
end

function typewriter:update(dt)
	for k, v in ipairs(typewriters) do v:update(dt, v) end
end

function typewriter:draw()
	for k, v in ipairs(typewriters) do v:draw(v) end
end

return typewriter


----- MAIN.lua
--[[

local typewriter = require("typewriter")

local a = typewriter:new("hello", .5, 5, 10)
local b = typewriter:new("world", .5, 40, 10)
local c = typewriter:new("This is my text...", .25, 5, 50)

function love.update(dt)
	typewriter:update(dt)
end

function love.draw()
	typewriter:draw()
end

--]]
