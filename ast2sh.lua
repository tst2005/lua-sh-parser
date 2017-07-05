local renderer = require "ast-renderer"

--local typeget = function(t) return t.tag or t.type end
local x = renderer("tag")

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
--[[
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
]]--

local sh = x:defs()

-- Program = 'body',
function sh:Program(t)
	local r = {}
	-- if t.shebang then end ?
	if t.body then
		for i,v in ipairs(t.body) do
			r[#r+1] = self:render(v)
		end
	end
	return table.concat(r, "\n")
end

-- CompoundList = 'cmds',
-- SequentialList = 'cmds',
-- AndList = 'cmds',
-- OrList = 'cmds',
-- Not = 'cmd',
-- PipeSequence = 'cmds',
-- SimpleCommand = { 'prefix', 'cmd', 'suffix' },
function sh:SimpleCommand(t)
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
end

-- BraceGroup = { 'body', 'redirs' },
function sh:BraceGroup(t)
	return "{\n"..self:render(t.body).."\n}\n" -- redirs
end

-- Subshell = { 'body', 'redirs' },
-- If = { 'clauses', 'redirs' },
-- IfClause = { 'cond', 'body' },
-- ElifClause = { 'cond', 'body' },
-- ElseClause = { 'body' },
-- For = { 'var', 'items', 'body', 'redirs' },
-- Case = { 'var', 'cases', 'redirs' },
-- CaseItem = { 'pattern', 'body' },
-- While = { 'cond', 'body', 'redirs' },
-- Until = { 'cond', 'body', 'redirs' },
-- FunctionDef = { 'name', 'body', 'redirs' },
function sh:FunctionDef(t)
	return self:render(t.name).."()".. self:render(t.body) -- t.redirs
end

-- RedirectFile = { 'fd', 'op', 'file' },
-- RedirectHereDoc = { 'fd', 'op', 'delimiter', 'content' },
-- HereDocContent = { 'content' },
-- Assignments = { 'modifier', 'assignments' },

-- Assignment = { 'name', 'value' },
function sh:Assignment(t)
	assert(t.name and t.value)
	return self:render(t.name) .. "=" .. self:render(t.value)
end

-- Name = { 'text' },
function sh:Name(t)
	assert(type(t.text)=="string")
	return t.text
end

-- Word = 'content',
function sh:Word(t)
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
end

-- ArithmeticExpansion = { 'text' },
-- ParameterExpansion = { 'op_pre', 'param', 'op_in', 'word' },
-- CommandSubstitution = 'cmds',
-- Comment = { 'text' },

function sh:CommandSubBackquote(t)
	if t.children then
		assert(#t.children==1)
		return "`"..prot(t.children[1]).."`"
	end
end

return x
