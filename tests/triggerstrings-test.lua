#!/usr/bin/env lua
package.path = package.path .. ";./../?.lua"

require"triggerstrings-manager"

local hintSingleLang = loadHintFiles({"test-triggerstrings-1a.txt"})
local hintDualLang = loadHintFiles({"test-triggerstrings-1b.txt", "test-triggerstrings-1a.txt"})

-- print("printing triggerstrings table")
-- for k,v in pairs(hintSingleLang.EmptyStringHint) do
-- 	print(k,v)
-- end
-- print("eof print")

assert(hintSingleLang.EmptyStringHint == nil, "Expected unquoted empty hint to be nil, got: '"
	.. tostring(hintSingleLang.EmptyStringHint) .."'")

assert(hintSingleLang.EmptyStringQuotedHint == nil, "Expected quoted empty hint to be nil, got: '"
	.. tostring(hintSingleLang.EmptyStringQuotedHint) .."'")


assert(hintSingleLang.StringHint == "This is an example", "Expected example unquoted string, got: '"
	.. tostring(hintSingleLang.StringHint) .."'")

assert(hintSingleLang.StringQuotedHint == "This is a quoted example", "Expected example quoted string, got: '"
	.. tostring(hintSingleLang.StringQuotedHint) .."'")

-- language checks below

assert(hintSingleLang.ConditionsHint == "Conditionsss", "Expected string for conditions, got: '"
	.. tostring(hintSingleLang.ConditionsHint) .."'")

assert(hintSingleLang.ActionsHint == "Actionsss", "Expected string for actions, got: '"
	.. tostring(hintSingleLang.ActionsHint) .."'")

assert(hintSingleLang.CallsHint == "Callsss", "Expected string for calls, got: '"
	.. tostring(hintSingleLang.CallsHint) .."'")

assert(hintSingleLang.AIFunctionsHint == "AIFunctionsss", "Expected string for ai functions, got: '"
	.. tostring(hintSingleLang.CallsHint) .."'")



assert(hintSingleLang.MultilanguageFirstHint == "Multilanguage first language expected", "Expected single lang string, got: '"
	.. tostring(hintSingleLang.MultilanguageFirstHint) .."'")

assert(hintSingleLang.MultilanguageSecondHint == nil, "Expected second lang's unquoted string to be nil, got: '"
	.. tostring(hintSingleLang.MultilanguageSecondHint) .."'")

assert(hintSingleLang.MultilanguageSecondQuotedHint == nil, "Expected second lang's quoted string to be nil, got: '"
	.. tostring(hintSingleLang.MultilanguageSecondQuotedHint) .."'")


assert(hintDualLang.MultilanguageFirstHint == "Multilanguage first language expected", "Dual lang, Expected first lang's string, got: '"
	.. tostring(hintDualLang.MultilanguageFirstHint) .."'")

assert(hintDualLang.MultilanguageSecondHint == "Second lang expected", "Dual lang, Expected second lang's unquoted string, got: '"
	.. tostring(hintDualLang.MultilanguageSecondHint) .."'")

assert(hintDualLang.MultilanguageSecondQuotedHint == "Second lang expected quoted", "Dual lang, Expected second lang's quoted string, got: '"
	.. tostring(hintDualLang.MultilanguageSecondQuotedHint) .."'")

io.stderr:write("triggerstrings.txt tests passed!\n")
