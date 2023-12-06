--- Holds rules that verify values to be generally correct
local verificationRulesLib = {}
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

function verificationRulesLib.rejectAnyWhitespace(txt)
	if txt:match("%s") then
		return false, "found whitespace character in: '".. txt .."'"
	else
		return true
	end
end

return verificationRulesLib
