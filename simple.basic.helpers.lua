function isInt(n)
	return (type(n) == "number") and (math.floor(n) == n)
end

function toInt(n)
	if type(n) ~= "number" then return false end 
	return math.floor(n)
end

function slugify(str)
	return str:lower():gsub("%s+","-")
end

function capFirst(str)
	return str:sub(1,1):upper()..str:sub(2)
end
