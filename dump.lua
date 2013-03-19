local function GetSpaces(n)
    local res = ""
    for i = 0, n do
        res = res .. " "
    end
    return res
end

local function dump(var, depth)
    if type(var) == "boolean" then
        return tostring(var)
    elseif type(var) == "nil" then
        return "nil"
    elseif type(var) == "table" then
        local res = "{\n"
        local spaces = GetSpaces(depth)
        for k, v in pairs(var) do
            res = res .. spaces .. k .. " = "
            res = res .. dump(v, depth + 4) .. ",\n"
        end
        return res .. "}"
    elseif type(var) == "string" then
        return "\"" .. var .. "\""
    else
    	return tostring(var)
    end
end

function Dump(var)
	print(dump(var, 0))
end
