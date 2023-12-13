require"category-parsers"

IGNORE_DOUBLE_DEFAULTS = {
	["TriggerRegisterUnitInRangeSimple"] = true,
	["SetTimeOfDayScalePercentBJ"] = true,
	["SetUnitLifeBJ"] = true,
	["BlzSetAbilityIntegerLevelFieldBJ"] = true,
	["CreateFogModifierRadiusLocBJ"] = true,
	["BlzSetAbilityIntegerLevelField"] = true,
}
function parseFile(fileH, dataOut)
	local PATTERN_CATEGORY = "^%[([A-Za-z0-9]+)%]"
	local PATTERN_ENTRY = "^[A-Za-z][A-Za-z0-9_]*"
	local PATTERN_ENTRYPROPERTY = "^_[A-Za-z0-9_]+"

	local categoryName = "ROOT_LEVEL"
	local lastEntry = nil

	local lineCount = 0

	for line in fileH:lines() do
		lineCount = lineCount + 1
		if lineCount == 1 then
			-- remove UTF-8 BOM
			if line:sub(1, 3) == "\xEF\xBB\xBF" then
				line = line:sub(4)
			end
		end
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
				lastEntry = nil
			end

			categoryName = line:match(PATTERN_CATEGORY)
			dataOut[categoryName] = {}

		elseif line:match(PATTERN_ENTRYPROPERTY) then
			-- This must match before ENTRY, because this is a stricter check that must begin with underscore

			-- secondary line, expands the previous definition that wasn't prefixed with underscore _

			assert(lastEntry, "Unexpected entry property, last entry is nil. Line: '".. line .."'")

			if line == "_BlzGetUnitCollisionSize=TC_UNIT" then
				warnExpected("Broken property declaration, supposed to be _Category: '".. line .."'")
				line = "_BlzGetUnitCollisionSize_Category=TC_UNIT"
			end

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
			elseif propertyName == "Limites" then
				warnExpected("Mistyped 'Limits' in line: '".. line .."'")
				propertyName = "Limits"
			end



			local parserTbl = property[propertyName]

			if not parserTbl or (not parserTbl.parseLine) then
				error("parser for property '".. tostring(propertyName) .."' not found, line: '".. line .."'")
			end

			local parsedProperty = parserTbl.parseLine(line)
			if lastEntry[propertyName] ~= nil then
				local errMsg = string.format(
					"Property's name key '%s' already exists in previous base entry on line '%s'!",
					propertyName, line
				)
				if propertyName == "Defaults" and IGNORE_DOUBLE_DEFAULTS[lastEntry.name] then
					-- the first value is applied by editor (maybe because the value count matches)
					warnExpected(errMsg)
				else
					error(errMsg)
				end
			end

			if parsedProperty.singleValue then
				-- flatten, just store as base type
				lastEntry[propertyName] = parsedProperty.singleValue
			else
				-- store as table
				lastEntry[propertyName] = parsedProperty
				parsedProperty.name = nil -- avoid duplication
			end

		elseif line:match(PATTERN_ENTRY) then
			-- This must match after _ENTRYPROPERTY, because ENTRY names may contain underscores
			-- conservative matching rule
			-- That's a value, process it according to category

			-- commit lastEntry first
			if lastEntry then
				table.insert(dataOut[categoryName], lastEntry)
				lastEntry = nil
			end

			local entryName = line:match(PATTERN_ENTRY)

			local parserTbl = assert(category[categoryName], string.format(
				"Parser not found for category: '%s' on line: '%s'", tostring(entryName), line))

			lastEntry = parserTbl.parseLine(line)
		else
			error(string.format("Unknown line format, line: '%s', length: '%d' (invisible chars, BOM?)",
				line, #line
			))
		end

	end

	-- commit the final entry
	if lastEntry then
		table.insert(dataOut[categoryName], lastEntry)
		lastEntry = nil
	end
end

function warnExpected(...)
	stderr("Expected warning: ", ...)
	stderr("\n")
end
