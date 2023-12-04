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

--[[
TRIGGERDATA.TXT


[TriggerCategories]
// Defines categories for organizing trigger functions
// Key: Arbitrary category identifier
// Value 0: Display text
// Value 1: Icon image file
// Value 2: Optional flag (defaults to 0) indicating to disable display of category name
//


[TriggerTypes]
// Defines all trigger variable types to be used by the Script Editor
// Key: type name
// Value 0: first game version in which this type is valid
// Value 1: flag (0 or 1) indicating if this type can be a global variable
// Value 2: flag (0 or 1) indicating if this type can be used with comparison operators
// Value 3: string to display in the editor
// Value 4: base type, used only for custom types
// Value 5: import type, for strings which represent files (optional)
// Value 6: flag (0 or 1) indicating to treat this type as the base type in the editor


[TriggerTypeDefaults]
// Defines an optional default value for a trigger type used as a global variable
// Key: variable type
// Value 0: script text
// Value 1: display text (if not present, script text will be used)
//
// If a type does not have an entry here, it will be set to null if it is a handle
//


[TriggerParams]
// Defines possible values for variable types
// Key: arbitrary text
// Value 0: first game version in which this parameter is valid
// Value 1: variable type
// Value 2: code text (used in script)
// Value 3: display text
//
// Note: If the code text is a literal string, surround it with backward single quotes (`),
//       and they will be converted to double quotes in the script.
//


[TriggerEvents]
// Defines events available in the editor
// Key: script event function
// Value 0: first game version in which this function is valid
// Value 1+: argument types
// Note that the first argument is always a `trigger`, and is excluded here


[TriggerConditions]
// Defines boolean condition functions
// Key: condition function name
// Value 0: first game version in which this function is valid
// Value 1+: argument types


[TriggerActions]
// Defines action functions
// Key: action function name
// Value 0: first game version in which this function is valid
// Value 1+: argument types


[TriggerCalls]
// Defines function calls which may be used as parameter values
// Key: Function name
// Value 0: first game version in which this function is valid
// Value 1: flag (0 or 1) indicating if the call can be used in events
// Value 2: return type
// Value 3+: argument types
//
// Note: Operators are specially handled by the editor


[DefaultTriggerCategories]
// Defines categories to be automatically added to new maps
NumCategories=1

Category01=WESTRING_INITIALIZATION


[DefaultTriggers]
// Defines triggers to be automatically added to new maps
NumTriggers=1



]]

verificationRulesLib = {}
function verificationRulesLib.acceptAny()
	return true
end
function verificationRulesLib.requireString01(txt)
	if txt == "0" or txt == "1" then
		return true
	else
		return false, "value is neither 0 or 1, got: ".. tostring(txt)
	end
end
verificationRulesLib.requireGameVersion = verificationRulesLib.requireString01

function verificationRulesLib.optionalString01(txt)
	if txt == "0" or txt == "1" or txt == nil then
		return true
	else
		return false, "value is neither 0 or 1, got: ".. tostring(txt)
	end
end

valueProcessorsLib = {}
function valueProcessorsLib.binToBoolean(txt)
	if txt == "0" then
		return false
	elseif txt == "1" then
		return true
	else
		error()
	end
end
function valueProcessorsLib.binToBooleanDefault0(txt)
	if txt == "0" or txt == nil then
		return false
	elseif txt == "1" then
		return true
	else
		error()
	end
end
function valueProcessorsLib.intToGameVer(txt)
	if txt == "0" then
		return "roc"
	elseif txt == "1" then
		return "txt"
	else
		error()
	end
end
function valueProcessorsLib.nop(txt)
	return txt
end
function valueProcessorsLib.translate(txt)
	-- NEI!
	if TRANSLATION then
		return TRANSLATION.translate(txt)
	else
		return txt
	end
end

valueRenamerLib = {}
function valueRenamerLib.displayText()
	return "displayText"
end
function valueRenamerLib.iconPath()
	return "iconPath"
end
function valueRenamerLib.isDisplayDisabled()
	return "isDisplayDisabled"
end
function valueRenamerLib.canBeGlobalVar()
	return "canBeGlobalVar"
end
function valueRenamerLib.allowComparisonOperators()
	return "allowComparisonOperators"
end
function valueRenamerLib.prettyStringId()
	return "prettyStringId"
end
function valueRenamerLib.baseType()
	return "baseType"
end
function valueRenamerLib.importType()
	return "importType"
end
function valueRenamerLib.treatAsBaseType()
	return "treatAsBaseType"
end
function valueRenamerLib.firstGameVersion()
	return "firstGameVersion"
end
function valueRenamerLib.variableType()
	return "variableType"
end
function valueRenamerLib.codeText()
	return "codeText" -- same as "script text"
end
function valueRenamerLib.argumentType()
	return "argumentType"
end
function valueRenamerLib.usableInEvents()
	return "usableInEvents"
end
function valueRenamerLib.returnType()
	return "returnType"
end


-- A heavily parametrized function to avoid duplicating code for each parser
-- Consider this a declarative parser at this point
function parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
	local name, valueText = line:match("([^=]+)=(.+)")

	assert(name)

	local definition = {}
	definition.name = name

	for match in valueText:gmatch("[^,]+") do
		matchCount = matchCount + 1

		assert(verificationRules[matchCount], string.format(
			"Verificator function missing for value #%d of '%s'", matchCount, name))

		assert(valueProcessors[matchCount], string.format(
			"Value processor function missing for value #%d of '%s'", matchCount, name))

		assert(valueRenamer[matchCount], string.format(
			"Value renamer function missing for value #%d of '%s'", matchCount, name))

		local ok, err = verificationRules[matchCount](match)
		if not ok then
			error(string.format("Verification failed for #%d of '%s': %s", matchCount, name. err))
		end

		local valueProcessed = verificationRules[matchCount](match)
		local valueName = valueRenamer[matchCount]()
		definition[valueName] = valueProcessed
	end

	if verificationRules.atLeastValues then
		assert(matchCount >= verificationRules.atLeastValues,
			string.format("Too few matches in category definition: '%s', expected: >=%d, got: %d",
				tostring(name), verificationRules.atLeastValues, matchCount
			)
		)
	end
	if verificationRules.atMostValues then
		assert(matchCount <= verificationRules.atMostValues,
			string.format("Too few matches in category definition: '%s', expected: <=%d, got: %d",
				tostring(name), verificationRules.atMostValues, matchCount
			)
		)
	end

	return definition
end

category = {}

category.TriggerCategories = {}
function category.TriggerCategories.parseLine(line)
	-- TC_ARITHMETIC=WESTRING_TRIGCAT_ARITHMETIC,ReplaceableTextures\WorldEditUI\Actions-AI,1
	-- TC_GAME=WESTRING_TRIGCAT_GAME,ReplaceableTextures\WorldEditUI\Actions-Game

	local verificationRules = {
		[1] = verificationRulesLib.acceptAny,
		[2] = verificationRulesLib.acceptAny,
		[3] = verificationRulesLib.optionalString01,
	}
	local valueProcessors = {
		[1] = valueProcessorsLib.translate,
		[2] = valueProcessorsLib.nop, -- path value can be "none"
		[3] = valueProcessorsLib.binToBooleanDefault0,
	}
	local valueRenamer = {
		[1] = valueRenamerLib.prettyStringId,
		[2] = valueRenamerLib.iconPath,
		[3] = valueRenamerLib.isDisplayDisabled,
	}

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end

category.TriggerTypes = {}
function category.TriggerTypes(line)
	-- abilcode=0,1,1,WESTRING_TRIGTYPE_abilcode,integer
	-- lightning=1,1,1,WESTRING_TRIGTYPE_lightning
	-- aiscript=0,0,0,WESTRING_TRIGTYPE_aiscript,string,AIScript,1

	local verificationRules = {
		[1] = verificationRulesLib.requireGameVersion,
		[2] = verificationRulesLib.requireString01,
		[3] = verificationRulesLib.requireString01,
		[4] = verificationRulesLib.acceptAny,
		[5] = verificationRulesLib.acceptAny, -- optional string
		[6] = verificationRulesLib.acceptAny, -- optional string
		[7] = verificationRulesLib.optionalString01
	}
	local valueProcessors = {
		[1] = valueProcessorsLib.intToGameVer,
		[2] = valueProcessorsLib.binToBoolean,
		[3] = valueProcessorsLib.binToBoolean,
		[4] = valueProcessorsLib.translate,
		[5] = valueProcessorsLib.nop,
		[6] = valueProcessorsLib.nop,
		[7] = valueProcessorsLib.binToBooleanDefault0,
	}
	local valueRenamer = {
		[1] = valueRenamerLib.firstGameVersion,
		[2] = valueRenamerLib.canBeGlobalVar,
		[3] = valueRenamerLib.allowComparisonOperators,
		[4] = valueRenamerLib.prettyStringId,
		[5] = valueRenamerLib.baseType,
		[6] = valueRenamerLib.importType,
		[7] = valueRenamerLib.treatAsBaseType,
	}

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end

--[[
category.__NAME__ = {}
function category.__NAME__.parseLine(line)
	local verificationRules = {
		[1] = verificationRulesLib.
		[2] = verificationRulesLib.
		[3] = verificationRulesLib.
		[4] = verificationRulesLib.
		[5] = verificationRulesLib.
		[6] = verificationRulesLib.
		[7] = verificationRulesLib.
	}
	local valueProcessors = {
		[1] = valueProcessorsLib.
		[2] = valueProcessorsLib.
		[3] = valueProcessorsLib.
		[4] = valueProcessorsLib.
		[5] = valueProcessorsLib.
		[6] = valueProcessorsLib.
		[7] = valueProcessorsLib.
	}
	local valueRenamer = {
		[1] = valueRenamerLib.
		[2] = valueRenamerLib.
		[3] = valueRenamerLib.
		[4] = valueRenamerLib.
		[5] = valueRenamerLib.
		[6] = valueRenamerLib.
		[7] = valueRenamerLib.
	}

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end
]]

category.TriggerTypeDefaults = {}
function category.TriggerTypeDefaults.parseLine(line)
	local verificationRules = {
		[1] = verificationRulesLib.acceptAny,
		[2] = verificationRulesLib.acceptAny,
	}
	local valueProcessors = {
		[1] = valueProcessorsLib.nop,
		[2] = valueProcessorsLib.translate,
	}
	local valueRenamer = {
		[1] = valueRenamerLib.codeText
		[2] = valueRenamerLib.prettyStringId
	}

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end

category.TriggerParams = {}
function category.TriggerParams.parseLine(line)
	local verificationRules = {
		[1] = verificationRulesLib.requireGameVersion,
		[2] = verificationRulesLib.acceptAny,
		[3] = verificationRulesLib.acceptAny,
		[4] = verificationRulesLib.acceptAny,
	}
	local valueProcessors = {
		[1] = valueProcessorsLib.intToGameVer,
		[2] = valueProcessorsLib.nop,
		[3] = valueProcessorsLib.nop,
		[4] = valueProcessorsLib.translate,
	}
	local valueRenamer = {
		[1] = valueRenamerLib.firstGameVersion
		[2] = valueRenamerLib.variableType
		[3] = valueRenamerLib.codeText
		[4] = valueRenamerLib.prettyStringId
	}

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end

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
