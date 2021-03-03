function split(r, str)
	local t = {}
	local s = 1
	local s1, s2 = string.find(str, r, s)
	while s1 do
		table.insert(t, string.sub(str, s, s1 - 1))
		s = s2 + 1
		s1, s2 = string.find(str, r, s)
	end
	table.insert(t, string.sub(str, s, -1))
	return t
end

-- [[ Not My Code, but useful! ]]
function table.show(t, name, indent)
	local cart
	local autoref

	local function isemptytable(t) return next(t) == nil end

	local function basicSerialize (o)
		local so = tostring(o)
		if type(o) == "function" then
			local info = debug.getinfo(o, "S")
			if info.what == "C" then
				return string.format("%q", so .. ", C function")
			else 
				return string.format("%q", so .. ", defined in (" .. info.linedefined .. "-" .. info.lastlinedefined .. ")" .. info.source)
			end
		elseif type(o) == "number" or type(o) == "boolean" then
			return so
		else
			return string.format("%q", so)
		end
	end

	local function addtocart (value, name, indent, saved, field)
		indent = indent or ""
		saved = saved or {}
		field = field or name

		cart = cart .. indent .. field

		if type(value) ~= "table" then
			cart = cart .. " = " .. basicSerialize(value) .. ";\n"
		else
			if saved[value] then
				cart = cart .. " = {}; -- " .. saved[value] .. " (self reference)\n"
				autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
				else
				saved[value] = name
				if isemptytable(value) then
					cart = cart .. " = {};\n"
				else
					cart = cart .. " = {\n"
					for k, v in pairs(value) do
						k = basicSerialize(k)
						local fname = string.format("%s[%s]", name, k)
						field = string.format("[%s]", k)
						addtocart(v, fname, indent .. "   ", saved, field)
					end
					cart = cart .. indent .. "};\n"
				end
			end
		end
	end

	name = name or "__unnamed__"
	if type(t) ~= "table" then
		return name .. " = " .. basicSerialize(t)
	end
	cart, autoref = "", ""
	addtocart(t, name, indent)
	return cart .. autoref
end


function table.load( sfile )
	local ftables,err = loadfile( sfile )
	if err then return _,err end
	local tables = ftables()
	for idx = 1,#tables do
		local tolinki = {}
		for i,v in pairs( tables[idx] ) do
			if type( v ) == "table" then
				tables[idx][i] = tables[v[1]]
			end
			if type( i ) == "table" and tables[i[1]] then
				table.insert( tolinki,{ i,tables[i[1]] } )
			end
		end
	-- link indices
		for _,v in ipairs( tolinki ) do
			tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
		end
	end
	return tables[1]
end
-- [[ End Not My Code ]]

function table.find(t, v) 
	if not t or not v then return false end
	for k,i in pairs(t) do
		if type(i) == "table" then
			return table.find(i, v)
		else
			if i == v then return k end
		end
	end
	return false
end

function table.get(t, g, single, parent)
	if not t or not g then return false end
	parent = parent or t
	local results = false
	if not single then results = {} end
	local topKeys = table.keys(t)
	for k, v in pairs(t) do
		if type(v) == "table" then
			if parent ~= t then parent = parent[t] end
			if single then
				results = table.get(v, g, true, parent)
				if(results) then
					return results
				end
			else
				local secondResult = table.get(v, g, false, parent)
				if secondResult then
					table.insert(results, secondResult[1])
					table.insert(results, secondResult[2])
				end
			end
		else 
			if single then
				if k == g or v == g then
					if parent ~= t then 
						if parent[t] then
							return parent[t]
						elseif parent[k] then
							return parent[k]
						elseif t[k] then
							return t
						else
							return parent
						end
					else
						if t[k] then
							return t[k]
						else
							return t
						end
					end
				end
			else
				if (table.has(topKeys, g) and k == g) or v == g then
					if parent ~= t then
						table.insert(results, parent[t])
					else
						table.insert(results, t)
					end
				end
			end
		end
	end
	return results
end

function table.keys(t)
	local keyset = false
	for k,v in pairs(t) do
		if type(keyset) ~= "table" then keyset = {} end
		keyset[k] = k
	end
	return keyset
end

function table.has(t, v) 
	if not t or not v then return false end
	for _,i in pairs(t) do
		if type(i) == "table" then
			return table.has(i, v)
		else
			if i == v then return true end
		end
	end
	return false
end

function table.count(t, g)
	local count = 0
	for k,v in pairs(t) do
		if type(v) == "table" then
			for _,i in pairs(v) do
				if i == g then count = count + table.count(t, g) end
			end
		else
			if v == g then count = count + 1 end
		end
	end
	return count
end

function table.execute(t, f, ...)
	for k, v in pairs(t) do
		if v[f] then v[f](arg) end
	end
end

-- [[ Not My Code, but useful! ]]
-- Save copied tables in `copies`, indexed by original table.
function deepcopy(orig, copies)
	--print(40)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0 
	local iter = function ()
		i = i + 1
		
		if a[i] == nil then 
			return nil
		else 
			return a[i], t[a[i]]
		end
	end
	return iter
end

function string.split(s, p, t)
    local temp = {}
    local index = 0
    local last_index = string.len(s)
	t = t or nil
	
    while true do
        local i, e = string.find(s, p, index)

        if i and e then
            local next_index = e + 1
            local word_bound = i - 1
            if t and t:lower() == "string" then
				table.insert(temp, tostring(string.sub(s, index, word_bound)))
			elseif t and t:lower() == "number" then
				table.insert(temp, tonumber(string.sub(s, index, word_bound)))
			else
				table.insert(temp, string.sub(s, index, word_bound))
            end
			index = next_index
        else            
            if index > 0 and index <= last_index then
                if t and t:lower() == "string" then
					table.insert(temp, tostring(string.sub(s, index, last_index)))
				elseif t and t:lower() == "number" then
					table.insert(temp, tonumber(string.sub(s, index, last_index)))
				else
					table.insert(temp, string.sub(s, index, last_index))
				end
            elseif index == 0 then
                temp = nil
            end
            break
        end
    end

    return temp
end
-- [[ End Not My Code ]]

--[[
   function newItem(id)
      if isInt(id) then
      
      else
      
      end
   end
--]]
function isInt(n)
	return (type(n) == "number") and (math.floor(n) == n)
end

--[[
   Turn "25" to 25
   local x = "25"
   local result, success = toInt(x)
   if success then print(result) end
--]]
function toInt(n)
	return (type(n) == "number") and math.floor(n) or (type(n) == "string") and math.floor(tonumber(n))
end

--[[
   Turn "Hello Friends, My Name Is Bob." into "hello-friends-my-name-is-bob"
--]]
function slugify(str)
	return str:lower():gsub("%s+","-"):gsub("%p","")
end

--[[
   Turn "hello world" into "Hello world"
--]]
function capFirst(str)
	return str:sub(1,1):upper()..str:sub(2)
end
