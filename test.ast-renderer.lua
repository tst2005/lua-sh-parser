local render = require "ast-renderer"
local x = render("type")

local t

t = {
    ["body"] = {
        [1] = {
            ["type"] = "SimpleCommand",
            ["prefix"] = {
                [1] = {
                    ["value"] = {
                        ["type"] = "Word",
                        ["content"] = {
                            [1] = "bar",
                        },
                    },
                    ["name"] = {
                        ["text"] = "FOO",
                        ["type"] = "Name",
                    },
                    ["type"] = "Assignment",
                },
            },
        },
    },
    ["type"] = "Program",
}
--[[
t = {
	["type"] = "foo",
	body = { "a", "b", "c" },
}
x:configure("foo", function(t)
	return table.concat(t.body, "+")
end)
]]--


x:configure("Name", function(self, t)
	assert(type(t.text)=="string")
	return t.text
end)
assert( x:render(t.body[1].prefix[1].name)=="FOO")
print("OK: Name")

x:configure("Word", function(self, t)
	local sep = " "
	assert(t.content and t.content[1])
	local content = t.content
	if #content == 1 then
		return t.content[1]
	end
	return '"' .. table.concat(t.content, sep) .. '"' -- FIXME
end)
assert( x:render(t.body[1].prefix[1].value) == "bar")
print("OK: Word")

x:configure("Assignment", function(self, t)
	assert(t.name and t.value)
	return self:render(t.name) .. "=" .. self:render(t.value)
end)
assert( x:render(t.body[1].prefix[1]) == "FOO=bar")
print("OK: Assignment")

x:configure("SimpleCommand", function(self, t)
	local r = {}
	if t.prefix then
		for i,v in ipairs(t.prefix) do
			r[#r+1] = self:render(v)
		end
	end
	if t.command then -- something like that ?
	end
	return table.concat(r, " ")
end)
assert( x:render(t.body[1]) == "FOO=bar")
print("OK: SimpleCommand")

x:configure("Program", function(self, t)
	local r = {}
	-- if t.shebang then end ?
	if t.body then
		for i,v in ipairs(t.body) do
			r[#r+1] = self:render(v)
		end
	end
	return table.concat(r, "\n")
end)
assert( x:render(t) == "FOO=bar")
print("OK: Program")

print(x:render(t))

