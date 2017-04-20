
local x = require "ast2sh"

if (...) == "-" then
	local tmpenv = {}
	local luacode = "local t;"..io.stdin:read("*a")..";return t"
	local load = load or loadstring
	local t = load(luacode, luacode, "t", tmpenv)()
	--print(t)
	print("t = "..require"tprint"(t))
	print(x:render(t))
	return
end
-- A sh-parser AST sample
local t

-- sample: FOO=bar
t = {
    ["body"] = {
        [1] = {
            ["tag"] = "SimpleCommand",
            ["prefix"] = {
                [1] = {
                    ["value"] = {
                        ["tag"] = "Word",
                        ["content"] = {
                            [1] = "bar",
                        },
                    },
                    ["name"] = {
                        ["text"] = "FOO",
                        ["tag"] = "Name",
                    },
                    ["tag"] = "Assignment",
                },
            },
        },
    },
    ["tag"] = "Program",
}

assert( x:render(t.body[1].prefix[1].name)=="FOO")
--print("OK: Name")

assert( x:render(t.body[1].prefix[1].value) == "bar")
--print("OK: Word")

assert( x:render(t.body[1].prefix[1]) == "FOO=bar")
--print("OK: Assignment")

assert( x:render(t.body[1]) == "FOO=bar")
--print("OK: SimpleCommand")

assert( x:render(t) == "FOO=bar")
--print("OK: Program")

-- sample: FOO=foo BAR=bar ls -ld *;
t = {
    ["tag"] = "Program",
    ["body"] = {
        [1] = {
            ["tag"] = "SimpleCommand",
            ["suffix"] = {
                [1] = {
                    ["tag"] = "Word",
                    ["content"] = {
                        [1] = "-ld",
                    },
                },
                [2] = {
                    ["tag"] = "Word",
                    ["content"] = {
                        [1] = "*/",
                    },
                },
            },
            ["prefix"] = {
                [1] = {
                    ["name"] = {
                        ["tag"] = "Name",
                        ["text"] = "FOO",
                    },
                    ["value"] = {
                        ["tag"] = "Word",
                        ["content"] = {
                            [1] = "foo",
                        },
                    },
                    ["tag"] = "Assignment",
                },
                [2] = {
                    ["name"] = {
                        ["tag"] = "Name",
                        ["text"] = "BAR",
                    },
                    ["value"] = {
                        ["tag"] = "Word",
                        ["content"] = {
                            [1] = "bar",
                        },
                    },
                    ["tag"] = "Assignment",
                },
            },
            ["cmd"] = {
                ["tag"] = "Word",
                ["content"] = {
                    [1] = "ls",
                },
            },
        },
    },
}
--print("with sample: FOO=foo BAR=bar ls -ld */")

assert( x:render(t.body[1]) == 'FOO=foo BAR=bar ls -ld */')
--print("OK: SimpleCommand")

assert( x:render(t) == 'FOO=foo BAR=bar ls -ld */')
--print("OK: Program")
