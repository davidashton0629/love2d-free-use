--[[
	Requires LOVE2D -- https://love2d.org/
--]]
local lg = love.graphics
local typewriters = {}
local typewriter = {}

function typewriter:new(text, length, x, y)
	assert(text, "FAILURE: typewriter:new() :: missing parameter [text]")
	assert(length, "FAILURE: typewriter:new() :: missing parameter [length]")
	assert(x, "FAILURE: typewriter:new() :: missing parameter [x]")
	assert(y, "FAILURE: typewriter:new() :: missing parameter [y]")
	
	local t = {}
	if type(text) == "table" then
		if text[2] then
			assert(type(text[2]) == "table", "FAILURE: typewriter:new() :: text table color param incorrect.")
			while type(text[2][1]) == "table" do text[2] = text[2][1] end
		end
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
	t.show = true
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
	for _,t in ipairs(typewriters) do if t.show then t:update(dt) end end
end

function typewriter:split(str)
	local t={}
	for s in string.gmatch(str, ".") do
		t[#t+1] = s
	end
	return t
end

function typewriter:toggle(t)
	assert(t, "FAILURE: typewriter:toggle() :: no typewriter passed.")
	assert(type(t) == "table", "FAILURE: typewriter:toggle() :: the variable passed was not a typewriter.")
	t.show = not t.show
end

function typewriter:draw()
	for _,t in ipairs(typewriters) do if t.show then t:draw() end end
end

function typewriter:reset(t)
	assert(t, "FAILURE: typewriter:reset() :: no typewriter passed.")
	assert(type(t) == "table", "FAILURE: typewriter:reset() :: the variable passed was not a typewriter.") 
	t.timeWaited = 0
	t.curPrint = 1
	t.toShow = ""
	t.finished = false
end

function typewriter:remove(t)
	assert(t, "FAILURE: typewriter:remove() :: no typewriter passed.")
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
local c = typewriter:new({"This is my text...", {1,0,1,1}, myFont}, .05, 5, 50)

local playTime = 0

function love.update(dt)
	typewriter:update(dt)
	playTime = playTime + dt
	if playTime > 2 then playTime = 0 typewriter:toggle(c) end
end

function love.draw()
	typewriter:draw()
	if c.finished then typewriter:reset(c) end
	if c.runCount >= 20 then typewriter:remove(c) end
end
--]]
