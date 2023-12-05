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
]]

require"category-parsers"

function parseFile(fileH, dataOut)
	local PATTERN_CATEGORY = "^\[([A-Za-z0-9]+)\]"
	local categoryName = "ROOT_LEVEL"

	for line in fileH:lines() do
		line = line:gsub("\r$", "")

		if #line == 0 then
			-- blank line

		elseif line:match("^//") then
			-- comment

		elseif line:match(PATTERN_CATEGORY) then
			-- category name
			categoryName = line:match(PATTERN_CATEGORY)

		elseif line:match("^[A-Za-z_]") then
			-- conservative matching rule
			-- That's a value, process it according to category


		else
			error("Unknown line format, line: '".. line .."'")
		end

	end
end

function stderr(...)
	io.stderr:write(...)
end

function main(...)
	local filePaths = {}
	for k, v in pairs(args) do
		if not v:match("^\-\-") then
			table.insert(filePaths, v)
		end
	end

	local data = {}

	for k, path in pairs(filePaths) do
		stderr("Reading file: ".. file, "\n")

		local file = assert(path)
		parseFile(file, data)
		file:close()
	end
end

local args = args or {...}
main(args)
