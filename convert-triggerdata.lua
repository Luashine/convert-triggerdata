#!/usr/bin/env lua

--[[
FILES:

triggerdata.txt: main file containing all GUI triggers.
aieditordata.txt: GUI triggers as above but for AI Editor code generation

worldeditordata.txt: mostly localization, but gives many lists and hardcoded values a pretty name.
uniteditordata.txt: gives pretty names to unit data values. Mostly for object editor use.

miscui.txt: only useful for frame native users, should not be part of jassdoc but an outside tutorial
miscdata.txt: hardcoded constants, useful to derive some terminology

campaigninfoclassic.txt: defines constants and campaign missions, needs an outside tutorial
campaigninforeforged.txt: same as above
]]

--[[
Question: Where are all the WESTRING_ located?
Answer: __LOCALE__/ui/worldeditstrings.txt
]]

require"file-parser"

function stderr(...)
	io.stderr:write(...)
end

function main(args)
	local argparse = require"lib.argparse@27967d7.argparse"
	local parser = argparse()
		:name("convert-triggerdata.lua")
		:description("A tool to convert Warcraft 3's code definitions for GUI Trigger Editor from triggerdata.txt")
		:epilog("Source code: https://github.com/Luashine/convert-triggerdata")
		:add_complete()
		:add_help_command()
		:require_command(false)

	parser:group("Input data",
		parser:argument("triggerdata", "Trigger definition file")
			:args("1+"):argname("<triggerdata.txt>"),

		parser:option("-t --translate", "WE localization file, first file has highest priority")
			:args("*"):argname("<strings.txt>"):action("concat"):hidden(true)
	)

	parser:group("Output format",
		parser:option("-f --format", "output format")
			:args(1)
			:default("none")
			:choices({"json", "lua", "none"})
	)

	local pargs = parser:parse(args)
	local filePaths = pargs.triggerdata

	local data = {}

	for k, path in pairs(filePaths) do
		stderr("Reading file: ".. path, "\n")

		local file = assert(io.open(path, "rb"))
		parseFileTriggers(file, data)
		file:close()
	end

	if pargs.format == "json" then
		local JSON = require"lib.JSON"
		io.stdout:write(JSON:encode_pretty(data), "\n")

	elseif pargs.format == "lua" then
		local serpent = require("lib.serpent@139fc18.src.serpent")
		io.stdout:write(serpent.block(data, {comment = false}), "\n")
	end
end

local args = args or {...}
main(args)
