
local function dump_var(var, depth)
    if type(var) == "boolean" then
        return tostring(var)
    elseif type(var) == "nil" then
        return "nil"
    elseif type(var) == "table" then
        local res = "{\n"
        local spaces = string.rep(" ", depth)
        for k, v in pairs(var) do
            res = res .. spaces .. k .. " = "
            res = res .. dump_var(v, depth + 4) .. ",\n"
        end
        return res .. "}"
    elseif type(var) == "string" then
        return "\"" .. var .. "\""
    else
    	return tostring(var)
    end
end

function dump(var)
	print(dump_var(var, 0))
end

function split(str, delim)
    local words = {}
	local pattern
	if delim then
		if delim == "%" then delim = "%" .. delim end
		pattern = "[^" .. delim .. "]+"
	else
		pattern = "[^%s]+"
	end
	for w in string.gmatch(str, pattern) do
		words[#words + 1] = w
	end
    return words
end

function round(num, bit)
    local plus = 0.5
    local divide = 1
    if bit and bit > 0 then
        for i = 1, bit do
            plus = plus / 10
            divide = divide / 10
        end
    end
    num = num + plus
    return num - num%divide
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do a[#a + 1] = n end
    table.sort(a, f)
    local i = 0
    return function ()
        i = i + 1
        return a[i], t[a[i]]
    end
end

function getTableCount(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function setDefault(t, d)
    local mt = {__index = function() return d end,}
    setmetatable(t, mt) 
end

function GetPlayerName()
    return Inspect.Unit.Detail("player").name
end

function GetItemDetail(var)
    return Inspect.Item.Detail(var)
end
