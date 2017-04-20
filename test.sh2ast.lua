local parse = require 'sh-parser.parser'.parse
local t = [[
FOO=bar
]]
if (...) == "-" then
	t=io.stdin:read("*a")
end

t = parse(t)

local tprint = require"tprint"
tprint.indent="    "

print("t = "..tprint(t))
