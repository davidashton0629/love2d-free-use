--[[
	Requires LOVE2D -- https://love2d.org/
--]]
local lg, lt = love.graphics, love.timer
local min, max = math.min, math.max
local text = {}

local prefixes = {
	color = "c",
	delay = "d",
	font = "f",
	time = "t"
}

text.items = {}
text.guis = {}

function text:new(n, p)
	local t = {}
	if p and p.id and not self.guis[p.id] then self.guis[p.id] = p end
	
	t.name = n
	t.id = #self.items + 1
	if p and p.id then t.parent = p.id else t.parent = nil end
	t.text = ""
	t.w = 0
	t.h = 0
	t.pos = {
		x = 0,
		y = 0,
		z = 0
	}
	t.timerEvent = nil
	t.color = {1,1,1,1}
	t.font = love.graphics.getFont()
	t.fonts = {}
	t.hovered = false
	t.clicked = false
	t.clickable = true
	t.faded = false
	t.fancy = false
	t.typewriter = false
	t.typewriterPrint = ""
	t.typewriterText = self:split(t.text)
	t.typewriterPos = 1
	t.typewriterSpeed = 0
	t.typewriterWaited = 0
	t.typewriterFinished = false
	t.typewriterPaused = false
	t.typewriterStopped = false
	t.typewriterRunCount = 0
	t.inAnimation = false
	t.animateColor = false
	t.colorToAnimateTo = {1,1,1,1}
	t.colorAnimateSpeed = 0
	t.colorAnimateTime = lt.getTime()
	t.animatePosition = false
	t.positionAnimateSpeed = 0
	t.positionToAnimateTo = {x = 0, y = 0}
	t.positionToAnimateFrom = {x = 0, y = 0}
	t.positionAnimateTime = lt.getTime()
	t.animateOpacity = false
	t.opacityAnimateSpeed = 0
	t.opacityToAnimateTo = 0
	t.opacityAnimateTime = lt.getTime()
	
	function t:animateToColor(c, s)
		assert(c, "FAILURE: text:animateToColor() :: Missing param[color]")
		assert(type(c) == "table", "FAILURE: text:animateToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c == 4, "FAILURE: text:animateToColor() :: Incorrect param[color] - table length 4 expected and got " .. #c)
		s = s or 2
		assert(s, "FAILURE: text:animateToColor() :: Missing param[speed]")
		assert(type(s) == "number", "FAILURE: text:animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.colorToAnimateTo = c
		self.colorAnimateSpeed = s
		self.colorAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animateColor = true
	end
	
	function t:animateToPosition(x, y, s)
		assert(x, "FAILURE: text:animateToPosition() :: Missing param[x]")
		assert(type(x) == "number", "FAILURE: text:animateToPosition() :: Incorrect param[x] - expecting number and got " .. type(x))
		assert(y, "FAILURE: text:animateToPosition() :: Missing param[y]")
		assert(type(y) == "number", "FAILURE: text:animateToPosition() :: Incorrect param[y] - expecting number and got " .. type(y))
		s = s or 2
		assert(type(s) == "number", "FAILURE: text:animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
		for k,v in pairs(self.pos) do self.positionToAnimateFrom[k] = v end
		self.positionToAnimateTo = {x = x, y = y}
		self.positionAnimateDrag = s
		self.positionAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animatePosition = true
	end
	
	function t:animateToOpacity(o, s)
		assert(o, "FAILURE: text:animateToOpacity() :: Missing param[o]")
		assert(type(o) == "number", "FAILURE: text:animateToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
		s = s or 1
		assert(s, "FAILURE: text:animateToOpacity() :: Missing param[speed]")
		assert(type(s) == "number", "FAILURE: text:animateToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.opacityToAnimateTo = o
		self.opacityAnimateTime = lt.getTime()
		self.opacityAnimateSpeed = s
		self.inAnimation = true
		self.animateOpacity = true
	end
	
	function t:isAnimating()
		return self.inAnimation
	end
	
	function t:setClickable(c)
		assert(c ~= nil, "FAILURE: text:setClickable() :: Missing param[clickable]")
		assert(type(c) == "boolean", "FAILURE: text:setClickable() :: Incorrect param[clickable] - expecting boolean and got " .. type(c))
		self.clickable = c
	end
	
	function t:isClickable()
		return self.clickable
	end
	
	function t:setColor(c)
		assert(c, "FAILURE: text:setColor() :: Missing param[color]")
		assert(type(c) == "table", "FAILURE: text:setColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c == 4, "FAILURE: text:setColor() :: Incorrect param[color] - table length 4 expected and got " .. #c)
		self.color = c
	end
	
	function t:setData(d)
		assert(d, "FAILURE: text:setData() :: Missing param[data]")
		assert(type(d) == "table", "FAILURE: text:setData() :: Incorrect param[data] - expecting table and got " .. type(d))
		assert(d.t or d.text, "FAILURE: text:setData() :: Missing param[data['text']")
		assert(type(d.text) == "string", "FAILURE: text:setData() :: Incorrect param[text] - expecting string and got " .. type(d.text))
		assert(d.x, "FAILURE: text:setData() :: Missing param[data['x']")
		assert(type(d.x) == "number", "FAILURE: text:setData() :: Incorrect param[x] - expecting number and got " .. type(d.x))
		assert(d.y, "FAILURE: text:setData() :: Missing param[data['y']")
		assert(type(d.y) == "number", "FAILURE: text:setData() :: Incorrect param[y] - expecting number and got " .. type(d.y))
		self.w = d.w or d.width or self.w
		self.h = d.h or d.height or self.h
		self.text = d.t or d.text or self.text
		self.typewriterText, self.fancy = text:split(self.text)
		self.typewriter = d.tw and d.tw or d.typewriter and d.typewriter or self.typewriter
		self.pos.x = d.x or self.pos.x
		self.pos.y = d.y or self.pos.y
		self.pos.z = d.z or self.pos.z
		self.color = d.color or self.color
		self.font = d.font or self.font
		self.clickable = d.clickable and d.clickable or self.clickable
	end
	
	function t:disable()
		self.hidden = true
	end
	
	function t:draw()
		lg.push()
		lg.setColor(self.color)
		lg.setFont(self.font)
		
		if self.typewriter then
			if self.fancy then
				for k,v in ipairs(self.typewriterText) do
					if v.text then
						lg.push()
						
						if v.color ~= "white" then
							lg.setColor(text.guis[self.parent].color(v.color))
						end
						if v.font ~= "default" then
							lg.setColor(v.font)
						end
						
						if not v.y then
							v.y = self.pos.y
						end
						
						if not v.x then
							if k == 1 then
								v.x = self.pos.x
							else
								v.x = self.typewriterText[k - 1].x + lg.getFont():getWidth(v.fullText)
								
								if self.width > 0 and v.x > self.pos.x + (self.width - lg.getFont():getWidth(v.fullText)) then
									v.x = self.pos.x
									v.y = self.typewriterText[k - 1].y + lg.getFont():getHeight(v.fullText) 
								end
							end
						end
						
						lg.print(v.toShow, v.x, v.y)
						lg.setColor(1,1,1,1)
						lg.pop()
						if not v.finished then break end
					end
				end
			else
				lg.print(self.typewriterPrint, self.pos.x, self.pos.y)
			end
		else
			lg.print(self.text, self.pos.x, self.pos.y)
		end
		
		lg.setColor(1,1,1,1)
		lg.pop()
	end
	
	function t:enable()
		self.hidden = false
	end
	
	function t:fadeIn()
		self:animateToOpacity(1)
		self.hidden = false
		self.faded = false
		if self.onFadeIn then self:onFadeIn() end
	end
	
	function t:fadeOut(p)
		if p then self.faded = true end
		self:animateToOpacity(0)
		if self.onFadeOut then self:onFadeOut() end
	end
	
	function t:addFont(f, n)
		assert(f, "FAILURE: text:addFont() :: Missing param[font]")
		assert(type(f) == "userdata", "FAILURE: text:addFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		assert(n, "FAILURE: text:addFont() :: Missing param[name]")
		assert(type(n) == "string", "FAILURE: text:addFont() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.fonts[n] = f
	end
	
	function t:setFont(n)
		assert(n, "FAILURE: text:setFont() :: Missing param[name]")
		assert(type(n) == "string", "FAILURE: text:setFont() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.font = self.fonts[n]
	end
	
	function t:isHovered()
		return self.hovered
	end
	
	function t:startAnimation()
		self.inAnimation = true
	end
	
	function t:stopAnimation()
		self.inAnimation = false
	end
	
	function t:update(dt)
		local x,y = love.mouse.getPosition()
		if (x >= self.pos.x and x <= self.pos.x + self.w) and (y >= self.pos.y and y <= self.pos.y + self.h) then
			if not self.hovered then
				if self.onHoverEnter then self:onHoverEnter() end
				self.hovered = true 
			end
		else
			if self.hovered then 
				if self.onHoverExit then self:onHoverExit() end
				self.hovered = false 
			end
		end
		
		if self.typewriter then
			self.typewriterWaited = self.typewriterWaited + dt
			if self.fancy then
				for k,v in ipairs(self.typewriterText) do
					if v.text then
						if v.delay > 0 and not delayWaited >= v.delay then
							delayWaited = delayWaited + dt
						end
						if not v.needToWait then
							if not v.started then
								v.started = true
							end
							while v.timeWaited >= v.time and v.textPos <= #v.text do
								v.timeWaited = v.timeWaited - v.time
								v.toShow = v.toShow .. v.text[v.textPos]
								v.textPos = v.textPos = 1
							end
							if v.textPos >= #v.text then
								v.finished = true
							end
						end
					end
					if not v.finished then break end
				end
			else
				while self.typewriterWaited >= self.typewriterSpeed and self.typewriterPrint <= #self.typewriterText do
					self.typewriterWaited = self.typewriterWaited - self.typewriterSpeed
					self.typewriterPrint = self.typewriterPrint .. self.typewriterText[self.typewriterPos]
					self.typewriterPos = self.typewriterPos + 1
				end
				if self.typewriterPos >= #self.typewriterText and not self.typewriterFinished then
					if not self.typewriterRepeat then self.typewriterFinished = true else self:typewriterCycle() end
					self.typewriterRunCount = self.typewriterRunCount + 1
				end
			end
		end
		
		if self.inAnimation then
			local allColorsMatch = true
			local allBorderColorsMatch = true
			local inProperPosition = true
			local atProperOpacity = true
			
			if self.animateColor then
				for k,v in ipairs(self.colorToAnimateTo) do
					if self.color[k] ~= v then
						if v > self.color[k] then
							self.color[k] = min(v, self.color[k] + (self.colorAnimateSpeed * dt))
						else
							self.color[k] = max(v, self.color[k] - (self.colorAnimateSpeed * dt))
						end
						allColorsMatch = false
					end
				end
			end
			
			if self.animatePosition then
				local t = math.min((lt.getTime() - self.positionAnimateTime) * (self.positionAnimateSpeed / 2), 1.0)
				if self.pos.x ~= self.positionToAnimateTo.x or self.pos.y ~= self.positionToAnimateTo.y then
					self.pos.x = self.lerp(self.positionToAnimateFrom.x, self.positionToAnimateTo.x, t)
					self.pos.y = self.lerp(self.positionToAnimateFrom.y, self.positionToAnimateTo.y, t)
					inProperPosition = false
				end
			end
			
			if self.animateOpacity then
				if self.color[4] ~= self.opacityToAnimateTo then
					if self.color[4] < self.opacityToAnimateTo then
						self.color[4] = min(self.opacityToAnimateTo, self.color[4] + (self.opacityAnimateSpeed * dt))
					else
						self.color[4] = max(self.opacityToAnimateTo, self.color[4] - (self.opacityAnimateSpeed * dt))
					end
					atProperOpacity = false
				end
			end
			
			if self.animateBorderColor then
				for k,v in ipairs(self.borderColorToAnimateTo) do
					if self.borderColor[k] ~= v then
						if v > self.borderColor[k] then
							self.borderColor[k] = min(v, self.borderColor[k] + (self.borderColorAnimateSpeed * dt))
						else
							self.borderColor[k] = max(v, self.borderColor[k] - (self.borderColorAnimateSpeed * dt))
						end
						allBorderColorsMatch = false
					end
				end
			end
			
			if allColorsMatch and inProperPosition and atProperOpacity and allBorderColorsMatch then
				self.inAnimation = false
				self.animateColor = false
				self.animatePosition = false
				if self.animateOpacity and self.faded then self.hidden = true end
				self.animateOpacity = false
			end
		end
	end
	
	function t:setOpacity(o)
		assert(o, "FAILURE: text:setUseBorder() :: Missing param[opacity]")
		assert(type(o) == "number", "FAILURE: text:setUseBorder() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		self.color[4] = o
	end
	
	function t:getOpacity()
		return self.color[4]
	end
	
	function t:typewriterCycle()
		self.typewriterWaited = 0
		self.typewriterPos = 1
		self.typewriterPrint = ""
		self.typewriterFinished = false
		self.typewriterStopped = false
		self.typewriterPaused = false
	end
	
	function t:setText(txt)
		assert(txt ~= nil, "FAILURE: text:setText() :: Missing param[text]")
		assert(type(txt) == "string", "FAILURE: text:setText() :: Incorrect param[text] - expecting boolean and got " .. type(txt))
		self.text = text
		self.typewriterText, self.fancy = text:split(txt)
	end
	
	function t:getText()
		return self.text
	end
	
	function t:setAsTypewriter(aT)
		assert(aT ~= nil, "FAILURE: text:setAsTypewriter() :: Missing param[useBorder]")
		assert(type(aT) == "boolean", "FAILURE: text:setAsTypewriter() :: Incorrect param[useBorder] - expecting boolean and got " .. type(aT))
		self.typewriter = aT
	end
	
	function t:isTypewriter()
		return self.typewriter
	end
	
	function t:setX(x)
		assert(x, "FAILURE: text:setX() :: Missing param[x]")
		assert(type(x) == "number", "FAILURE: text:setX() :: Incorrect param[x] - expecting number and got " .. type(x))
		self.pos.x = x
	end
	
	function t:getX()
		return self.pos.x
	end
	
	function t:setY(y)
		assert(y, "FAILURE: text:setY() :: Missing param[y]")
		assert(type(y) == "number", "FAILURE: text:setY() :: Incorrect param[y] - expecting number and got " .. type(y))
		self.pos.y = y
	end
	
	function t:getY()
		return self.pos.y
	end
	
	function t:setZ(z)
		assert(z, "FAILURE: text:setZ() :: Missing param[z]")
		assert(type(z) == "number", "FAILURE: text:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
		self.pos.z = z
	end
	
	function t:getZ()
		return self.pos.z
	end
	
	function t.lerp(e,s,c)
		return (1 - c) * e + c * s
	end
	
	return t
end

function text:split(s)
	local t={}
	local f = false
	if string.match(s, "{") then
		f = true
		for b in string.gmatch(str, ".-{") do
			local id = #t + 1
			t[id] = {}
			t[id].text = {}
			t[id].color = "white"
			t[id].delay = 0
			t[id].delayWaited = 0
			t[id].needToWait = false
			t[id].font = "default"
			t[id].time = 0.5
			t[id].started = false
			t[id].finished = false
			t[id].textPos = 0
			t[id].timeWaited = 0
			t[id].toShow = ""
			if string.match(b, "}") then
				for o in string.gmatch(b, ".-}") do
					local d = o:gsub("}","")
					for m in string.gmatch(d, "([^,]+)") do
						if string.sub(m,1,1) == prefixes.color then
							t[id].color = m:gsub("^" .. prefixes.color .. "=", "")
						end
						if string.sub(m,1,1) == prefixes.delay then
							t[id].delay = m:gsub("^" .. prefixes.delay .. "=", "")
							t[id].needToWait = true
						end
						if string.sub(m,1,1) == prefixes.font then
							t[id].font = m:gsub("^" .. prefixes.font .. "=", "")
						end
						if string.sub(m,1,1) == prefixes.time then
							t[id].time = m:gsub("^" .. prefixes.time .. "=", "")
						end
					end
				end
				t[id].fullText = b:gsub("^.-}",""):gsub("{",""):gsub("^%s*(.-)%s*$","%1")
			else
				t[id].fullText = b:gsub("{", "")
			end
			for i in t[id].fullText:gmatch(".") do
				t[id].text[#t[id].text + 1] = i
			end
		end
	else
		for i in string.gmatch(s, ".") do
			t[#t+1] = i
		end
	end
	return t, f
end

return text

---- main.lua
--[[

local typewriter = require("typewriter")
local myFont = love.graphics.newFont("pixelated.ttf")

local colors = { red = {1,0,0,1}, green = {0,1,0,1}, blue = {0,0,1,1} }

local a = typewriter:new("hello")
local b = typewriter:new("dance")
local c = typewriter:new("pet")

local playTime = 0

function love.load()
	a:setData({t = "Hello World!", x = 10, y = 100, color = colors.green, font = myFont, typewriter = true, speed = 2})
	b:setData({t = "Let's go to the dance." x = 50, y = 250, typewriter = true, color = colors.blue, speed = 4})
	c:setData({t = "No pets are allowed at the dance.", x = 50, y = 265, typewriter = true, color = colors.blue, speed = 0.5})
end

function love.update(dt)
	typewriter:update(dt)
	playTime = playTime + dt
	
	if playTime > 2 then 
		playTime = 0
		if b:getColor() ~= colors.red then b:setColor(colors.red) end
	end
end

function love.draw()
	typewriter:draw()
end

--]]
