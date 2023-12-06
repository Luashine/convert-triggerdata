--- Holds value processors which convert values for digestible output
local valueProcessorsLib = {}
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
function valueProcessorsLib.stripDoubleQuotes(txt)
	-- parameters are a format string containing a mix of "text" and ~variables
	-- only process text by removing enclosing double quotes
	if txt:sub(1,1) == '"' and txt:sub(-1,-1) == '"' then
		return txt:sub(2,-2)
	else
		return txt
	end
end

return valueProcessorsLib
