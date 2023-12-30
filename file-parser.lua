require"category-parsers"

local PATTERN_CATEGORY = "^%[([A-Za-z0-9]+)%]"
local PATTERN_ENTRY = "^[A-Za-z][A-Za-z0-9_]*"
local PATTERN_ENTRYPROPERTY = "^_[A-Za-z0-9_]+"

local function isBlank(line)
	if line:find("%S") then
		return false
	else
		return true
	end
end

function parseW3Ini(fileH, dataOut)
	local categoryName = "ROOT_LEVEL"

	local lineCount = 0

	for line in fileH:lines() do
		lineCount = lineCount + 1
		if lineCount == 1 then
			-- remove UTF-8 BOM
			if line:sub(1, 3) == "\xEF\xBB\xBF" then
				line = line:sub(4)
			end
		end
		line = line:gsub("\r+$", "")


		if #line == 0 then
			-- blank line

		elseif line:match("^//") then
			-- comment

		elseif line:match(PATTERN_CATEGORY) then
			-- category name

			categoryName = line:match(PATTERN_CATEGORY)

		elseif line:match(PATTERN_ENTRY) then
			local entryName = line:match(PATTERN_ENTRY)

			local parserTbl = assert(category[categoryName], string.format(
				"Parser not found for category: '%s' on line: '%s'", tostring(categoryName), line))

			if not dataOut[categoryName] then dataOut[categoryName] = {} end

			local definition = parserTbl.parseLine(line)
			definition.name = nil -- stored as key

			if definition.singleValue then
				definition = definition.singleValue
			end

			dataOut[categoryName][entryName] = definition

		elseif isBlank(line) then
			-- skip
		else
			error(string.format("Unknown line format, line #%d: '%s', length: '%d' (invisible chars, BOM?)",
				lineCount, line, #line
			))
		end

	end
end

local IGNORE_DOUBLE_DEFAULTS = {
	["TriggerRegisterUnitInRangeSimple"] = true,
	["SetTimeOfDayScalePercentBJ"] = true,
	["SetUnitLifeBJ"] = true,
	["BlzSetAbilityIntegerLevelFieldBJ"] = true,
	["CreateFogModifierRadiusLocBJ"] = true,
	["BlzSetAbilityIntegerLevelField"] = true,
}
function parseFileTriggers(fileH, dataOut)
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
		line = line:gsub("\r+$", "")


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

			-- See docs/README.md for format description
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
				"Parser not found for category: '%s' on line: '%s'", tostring(categoryName), line))

			lastEntry = parserTbl.parseLine(line)

			local hintText = TRIGGERHINTS[ entryName .. "Hint" ]
			if hintText then
				lastEntry.hint = hintText
			end

		elseif isBlank(line) then
			-- skip
		else
			error(string.format("Unknown line format, line #%d: '%s', length: '%d' (invisible chars, BOM?)",
				lineCount, line, #line
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
