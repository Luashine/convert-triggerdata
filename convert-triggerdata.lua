#!/usr/bin/env lua

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
		parser:argument("datafiles", "Trigger definition or War3 INI file (depending on mode)")
			:args("1+"):argname("<inifile.txt>"),

		parser:option("-l --lang", "WE localization file for trigger string lookup, first file has highest priority")
			:args("*"):argname("<strings.txt>"):action("concat"),

		parser:option("-t --type", "Choose the input data type")
			:args(1):default("trigger")
			:choices({"trigger", "ini"})
	)

	parser:group("Output format",
		parser:option("-f --format", "output format")
			:args(1)
			:default("none")
			:choices({"json", "lua", "none"})
	)

	local pargs = parser:parse(args)
	local dataFiles = pargs.datafiles
	local langFiles = pargs.lang

	if #langFiles > 0 then
		require"translation-manager"
		loadTranslationFiles(langFiles) -- global TRANSLATION
	end

	local data = {}

	for k, path in pairs(dataFiles) do
		stderr("Reading file: ".. path, "\n")

		local file = assert(io.open(path, "rb"))

		if pargs.type == "trigger" then
			parseFileTriggers(file, data)

		elseif pargs.type == "ini" then
			parseW3Ini(file, data)

		else
			error("Unknown command-line command")
		end

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
