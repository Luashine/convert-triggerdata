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
function valueRenamerLib.triggerEventsArgNumbered(index)
	-- TriggerEvents arguments start at second index, so to make them 1-indexed substract 1
	return string.format("arg%dType", index - 1)
end
function valueRenamerLib.triggerCallsArgNumbered(index)
	-- TriggerCalls arguments start at fourth index, so to make them 1-indexed substract 3
	return string.format("arg%dType", index - 3)
end
function valueRenamerLib.argNumberedDefault(index)
	return string.format("arg%dDefault", index)
end
function valueRenamerLib.parametersNumbered(index)
	return string.format("paramformat%d", index)
end
function valueRenamerLib.limitsNumbered(index)
	-- odd is min limit
	-- even is max limit
	local whichLimit == index % 2 == 0 and "MaxLimit" or "MinLimit"
	return string.format("arg%d%s", index, whichLimit)
end

return valueRenamerLib
