local render = require "ast-renderer"

--local typeget = function(t) return t.tag or t.type end
local x = render("tag")

local function prot(s)
	return s:gsub("[\"\\$`]", function(cap) return "\\"..cap end)

end
local function quotestring(s)
	return '"'..s:gsub("[\"\\]", function(cap) return "\\"..cap end)..'"'
end
local function squotestring(s)
	return "'"..s:gsub("['\\]", function(cap)
		if cap == "'" then
			return [['"'"']] --  ' -> '"'"'
		else
			return "\\"..cap
		end
	end).."'"
end
local function table_concatlike(self, t, sep)
	local r = {}
	for i,v in ipairs(t) do
		if type(v) == "table" then
			r[#r+1] = self:render(v)
		else
			r[#r+1] = v
		end
	end
	return table.concat(r, sep or "")
end

x:configure("Name", function(self, t)
	assert(type(t.text)=="string")
	return t.text
end)

x:configure("Word", function(self, t)
	local sep = " "
	assert(t.content and t.content[1])
	local content = t.content

	local words = t.content[1]
	if type(words) ~= "string" then
		return self:render(words)
	end
	if not words:find("[\"\\$ ]") then
		return words
	end
	return squotestring( words )
end)

x:configure("Assignment", function(self, t)
	assert(t.name and t.value)
	return self:render(t.name) .. "=" .. self:render(t.value)
end)

x:configure("SimpleCommand", function(self, t)
	local r = {}
	if t.prefix then
		for i,v in ipairs(t.prefix) do
			r[#r+1] = self:render(v)
		end
	end
	if t.cmd and t.cmd.content then
		r[#r+1] = self:render(t.cmd)
	end
	if t.suffix then
		for i,v in ipairs(t.suffix) do
			r[#r+1] = self:render(v)
		end
	end
	return table.concat(r, " ")
end)

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

x:configure("CommandSubBackquote", function(self, t)
	if t.children then
		assert(#t.children==1)
		return "`"..prot(t.children[1]).."`"
	end
end)

return x
