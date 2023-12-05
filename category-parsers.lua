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
function valueRenamerLib.minGameVersion()
	return "minGameVersion"
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
function valueRenamerLib.triggerEventsArgNumbered(index)
	-- TriggerEvents arguments start at second index, so to make them 1-indexed substract 1
	return string.format("%s%d", txt, index - 1)
end
function valueRenamerLib.triggerCallsArgNumbered(index)
	-- TriggerCalls arguments start at fourth index, so to make them 1-indexed substract 3
	return string.format("%s%d", txt, index - 3)
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
		local valueName = valueRenamer[matchCount](index) -- supply index to support parametrized functions

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
		[1] = valueRenamerLib.minGameVersion,
		[2] = valueRenamerLib.canBeGlobalVar,
		[3] = valueRenamerLib.allowComparisonOperators,
		[4] = valueRenamerLib.prettyStringId,
		[5] = valueRenamerLib.baseType,
		[6] = valueRenamerLib.importType,
		[7] = valueRenamerLib.treatAsBaseType,
	}

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end

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
		[1] = valueRenamerLib.minGameVersion
		[2] = valueRenamerLib.variableType
		[3] = valueRenamerLib.codeText
		[4] = valueRenamerLib.prettyStringId
	}

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end

--- Returns a new __index function to remap a numeric range of indexes to one index
---@param minIndex starting from this index (inclusive)
---@param maxIndex ending with this index (inclusive)
---@param remapToIndex point to this index
function metatblFactory_IndexRemapper(minIndex, maxIndex, remapToIndex)
	return function (t, key)
		if type(key) == "number" and key >= minIndex and key <= maxIndex then
			return t[remapToIndex]
		else
			return t[key]
		end
	end
end

category.TriggerEvents = {}
function category.TriggerEvents.parseLine(line)
	-- 32 is the max allowed Jass arguments
	local mt_indexRemapper3_32_to_2 = {__index = metatblFactory_IndexRemapper(3, 32, 2)}

	local verificationRules = {
		[1] = verificationRulesLib.requireGameVersion,
		[2] = verificationRulesLib.acceptAny,
	}
	setmetatable(verificationRules, mt_indexRemapper3_32_to_2)

	local valueProcessors = {
		[1] = valueProcessorsLib.intToGameVer,
		[2] = valueProcessorsLib.nop
	}
	setmetatable(valueProcessors, mt_indexRemapper3_32_to_2)

	local valueRenamer = {
		[1] = valueRenamerLib.minGameVersion,
		[2] = valueRenamerLib.triggerEventsArgNumbered
	}
	setmetatable(valueRenamer, mt_indexRemapper3_32_to_2)

	error("TODO: Secondary line extension")

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end


category.TriggerConditions = {}
-- identical parent value definitions
category.TriggerConditions.parseLine = category.TriggerEvents.parseLine


category.TriggerActions = {}
-- identical parent value definitions
category.TriggerActions.parseLine = category.TriggerEvents.parseLine


category.TriggerCalls = {}
function category.TriggerCalls.parseLine(line)
	-- 32 is the max allowed Jass arguments
	local mt_indexRemapper5_32_to_4 = {__index = metatblFactory_IndexRemapper(5, 32, 4)}

	local verificationRules = {
		[1] = verificationRulesLib.requireGameVersion,
		[2] = verificationRulesLib.requireString01,
		[3] = verificationRulesLib.acceptAny,
		[4] = verificationRulesLib.acceptAny,
	}
	setmetatable(verificationRules, mt_indexRemapper5_32_to_4)

	local valueProcessors = {
		[1] = valueProcessorsLib.intToGameVer,
		[2] = valueProcessorsLib.binToBoolean,
		[3] = valueProcessorsLib.acceptAny,
		[4] = valueProcessorsLib.acceptAny
	}
	setmetatable(valueProcessors, mt_indexRemapper5_32_to_4)

	local valueRenamer = {
		[1] = valueRenamerLib.minGameVersion,
		[2] = valueRenamerLib.usableInEvents,
		[3] = valueRenamerLib.returnType,
		[4] = valueRenamerLib.triggerCallsArgNumbered
	}
	setmetatable(valueRenamer, mt_indexRemapper5_32_to_4)

	error("TODO: Secondary line extension")

	return parseDefinition(line, verificationRules, valueProcessors, valueRenamer)
end
