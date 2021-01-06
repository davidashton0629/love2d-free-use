function splitText (str) -- create function to split string by each letter
	local t={}
	for s in string.gmatch(str, ".") do
			t[#t+1] = s
	end
	return t
end

local t = { -- store table with text information
	text = splitText("you came back for me..."), -- split text
	curPrint = 1, -- printing location
	toShow = "" -- text currently shown
}
local timeToWait = .5 -- how long you need to wait
local timeWaited = 0 -- how long you've waited

function love.update(dt)
	-- if you havent waited long enough
	if timeWaited <= timeToWait then 
		timeWaited = timeWaited + dt -- add to wait time
	end 
	
	-- if you waited long enough
	if timeWaited >= timeToWait and t.curPrint < #t.text then
		t.toShow = t.toShow .. t.text[t.curPrint] -- add to shown text
		t.curPrint = t.curPrint + 1 -- increase printing location 
		timeWaited = 0 -- reset wait time
	end
end

function love.draw()
	love.graphics.print(t.toShow, 10, 10) -- print shown text
end
