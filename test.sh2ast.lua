local parse = require 'sh-parser.parser'.parse
local sh = [[
FOO=bar
]]
if (...) == "-" then
	sh=io.stdin:read("*a")
end

--local t = parse(sh)
local t = parse(sh, {comments = true})

local tprint = require"tprint"
tprint.indent="    "

print("t = "..tprint(t, {inline=false}))
