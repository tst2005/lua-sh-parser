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
function sh:CompoundList(t)
end

-- SequentialList = 'cmds',
function sh:SequentialList(t)
end

-- AndList = 'cmds',
function sh:AndList(t)
end

-- OrList = 'cmds',
function sh:OrList(t)
end

-- Not = 'cmd',
function sh:Not(t)
end

-- PipeSequence = 'cmds',
function sh:PipeSequence(t)
	return table_concatlike(self, t.cmds, "|")
end

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
	return "{\n"..self:render(t.body).."\n}"..table_concatlike(self, t.redirs, " ").."\n"
end

-- Subshell = { 'body', 'redirs' },
function sh:Subshell(t)
	return "( "..self:render(t.body).." )"..table_concatlike(self, t.redirs, " ").."\n"
end

-- If = { 'clauses', 'redirs' },
function sh:If(t)
	return "if "..self:render(t.clauses[1])..table_concatlike(self, t.redirs, " ") -- FIXME: all conditions ?
end

-- IfClause = { 'cond', 'body' },
function sh:IfClause(t)
	return self:render(t.cond)..";then".." "..self:render(t.body)..";".."fi"
end

-- ElifClause = { 'cond', 'body' },
function sh:ElifClause(t)
end

-- ElseClause = { 'body' },
function sh:ElseClause(t)
end

-- For = { 'var', 'items', 'body', 'redirs' },
function sh:For(t)
end

-- Case = { 'var', 'cases', 'redirs' },
function sh:Case(t)
	return "case "..self:render(t.var).." in\n"..table_concatlike(self, t.cases, "\n").."esac\n"
end

-- CaseItem = { 'pattern', 'body' },
function sh:CaseItem(t)
	return "("..self:render(t.pattern)..")" ..(t.body and self:render(t.body) or "")..";;\n"
end

function sh:Pattern(t)
	return table_concatlike(self, t.children, "|")
end

-- While = { 'cond', 'body', 'redirs' },
function sh:While(t)
end

-- Until = { 'cond', 'body', 'redirs' },
function sh:Until(t)
end

-- FunctionDef = { 'name', 'body', 'redirs' },
function sh:FunctionDef(t)
	return self:render(t.name).."()".. self:render(t.body) -- t.redirs
end

-- RedirectFile = { 'fd', 'op', 'file' },
function sh:RedirectFile(t)
	return (t.fd or "")..t.op..self:render(t.file)
end

-- RedirectHereDoc = { 'fd', 'op', 'delimiter', 'content' },
function sh:RedirectHereDoc(t)
end

-- HereDocContent = { 'content' },
function sh:HereDocContent(t)
end

-- Assignments = { 'modifier', 'assignments' },
function sh:Assignments(t)
end

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
function sh:ArithmeticExpansion(t)
end

-- ParameterExpansion = { 'op_pre', 'param', 'op_in', 'word' },
function sh:ParameterExpansion(t)
end

-- CommandSubstitution = 'cmds',
function sh:CommandSubstitution(t)
end

-- Comment = { 'text' },
function sh:Comment(t)
end

function sh:CommandSubBackquote(t)
	if t.children then
		assert(#t.children==1)
		return "`"..prot(t.children[1]).."`"
	end
end

return x
