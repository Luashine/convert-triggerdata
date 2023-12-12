--- Holds functions that give values their names
local valueRenamerLib = {}
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
function valueRenamerLib.value()
	return "value"
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

do

	local function triggerArgNumberedOffset(index, indexOffset)
		-- different offsets are needed based on definition
		return {"ArgTypes", index + indexOffset }
	end

	function valueRenamerLib.triggerEventsArgNumbered(index)
		-- TriggerEvents arguments start at second index, so to make them 1-indexed substract 1
		return triggerArgNumberedOffset(index, -1)
	end

	function valueRenamerLib.triggerCallsArgNumbered(index)
		-- TriggerCalls arguments start at fourth index, so to make them 1-indexed substract 3
		return triggerArgNumberedOffset(index, -3)
	end
end

function valueRenamerLib.argNumberedDefault(index)
	return index
end
function valueRenamerLib.parametersNumbered(index)
	return index
end
function valueRenamerLib.limitsNumbered(index)
	-- odd is min limit
	-- even is max limit
	local whichLimit = index % 2 == 0 and "max" or "min"
	local flatIndex = math.ceil(index / 2) -- 1 / 2 = 0.5 --> 1
	return {whichLimit, flatIndex}
end

return valueRenamerLib
