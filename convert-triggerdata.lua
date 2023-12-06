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

require"category-parsers"

function parseFile(fileH, dataOut)
	local PATTERN_CATEGORY = "^\[([A-Za-z0-9]+)\]"
	local PATTERN_ENTRY = "^[A-Za-z][A-Za-z0-9_]*"
	local PATTERN_ENTRYPROPERTY = "^_[A-Za-z0-9_]+"

	local categoryName = "ROOT_LEVEL"
	local lastEntry = nil

	for line in fileH:lines() do
		line = line:gsub("\r$", "")

		if #line == 0 then
			-- blank line

		elseif line:match("^//") then
			-- comment

		elseif line:match(PATTERN_CATEGORY) then
			-- category name

			-- commit lastEntry first, then create category
			if lastEntry then
				-- table may not exist only for ROOT_LEVEL
				if not dataOut[categoryName] then dataOut[categoryName] = {} end
				table.insert(dataOut[categoryName], lastEntry)
			end

			categoryName = line:match(PATTERN_CATEGORY)
			dataOut[categoryName] = {}

		elseif line:match(PATTERN_ENTRYPROPERTY) then
			-- This must match before ENTRY, because this is a stricter check that must begin with underscore

			-- secondary line, expands the previous definition that wasn't prefixed with underscore _

			assert(lastEntry, "Unexpected entry property, last entry is nil. Line: '".. line .."'")

			-- POSSIBLE PROPERTIES:

			-- case-insensitive: _CATEGORY
			-- _Category: single value, category ID

			-- _Defaults: csv of default values in code or "_"

			-- _Parameters: format-like text WITH function arguments, csv
			-- example: _GetPlayerTechCountSimple_Parameters="Current research level of ",~Tech," for ",~Player
			-- example: _GetPlayerUnitCount_Parameters="Count non-structure units controlled by ",~Player," (",~Include/Exclude," incomplete units)"
			-- here, "Include/Exclude" are suffixes to be concatenated to construct the type with its pre-defined default boolean value

			-- _DisplayName: single value, in double-quotes (but localization files do not have them sometimes)

			-- _Limits: csv, used for integer/real limits. Two entries per argument
			-- numbers are both inclusive, non-integer or "no limit" is denoted by an underscore _
			-- may have a trailing comma (followed by nothing)
			-- may have one or both limits (e.g. only minimal limit)

			-- _ScriptName: I suppose this is the alias to be used in generated code
			-- example: "_SetHeroLevel_ScriptName=SetHeroLevelBJ"

			-- _UseWithAI: always used with a 1, so it must default to 0 if unspecified

			-- _AIDefaults: apparently only applied in AI editor, while regular map triggers use _Defaults
			local PATTERN_MATCH_LAST_UNDERSCORE_SUFFIX = "[^=]+_([^=]+)" -- todo: this should be simpler and based on previous full match name
			local propertyName = line:match(PATTERN_MATCH_LAST_UNDERSCORE_SUFFIX)
			if propertyName == "CATEGORY" then
				propertyName = "Category"
			end

			local parserTbl = category["Property_" .. propertyName]

			if not parserTbl then
				error("parser for property '".. tostring(propertyName) .."' not found, line: '".. line .."'")
			end

			local parsedProperty = parserTbl.parseLine(line)
			assert(lastEntry[propertyName] == nil, string.format("Unexpectedly found property's name key '%s' in previous base entry on line '%s'!",
				propertyName, line))

			lastEntry[propertyName] = parsedProperty
			parsedProperty.name = nil -- avoid duplication

		elseif line:match(PATTERN_ENTRY) then
			-- This must match after _ENTRYPROPERTY, because ENTRY names may contain underscores
			-- conservative matching rule
			-- That's a value, process it according to category

			-- commit lastEntry first
			if lastEntry then
				table.insert(dataOut[categoryName], lastEntry)
			end

			local entryName = line:match(PATTERN_ENTRY)

			local parserTbl = assert(category[entryName])
			lastEntry = parserTbl.parseLine(line)
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
