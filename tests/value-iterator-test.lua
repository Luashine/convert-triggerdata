#!/usr/bin/env lua
package.path = package.path .. ";./../?.lua"

triggerdataValueIterator = require"value-iterator"

function triggerdataValueIterator_test()
	local test = function(text, expectedTbl)

		local matchCount = 0
		for pos,value in triggerdataValueIterator(text) do
			matchCount = matchCount + 1

			if expectedTbl[matchCount] ~= value then
				error(string.format(
					"triggerdataValueIterator: Failed test, text='%s', expected='%s' at index='%d', got='%s'",
					text, tostring(expectedTbl[matchCount]), matchCount, value
				))
			end
		end
	end


	test([["1Hello",~val,"bye!"]], {'"1Hello"', "~val", '"bye!"'})
	test([["2mid",,~val]], {'"2mid"', "~val"})
	test([["3trail",]], {'"3trail"'})
	test([[,"4start"]], {'"4start"'})
	test([["Inside , here ",~val," outside"]], {'"Inside , here "', "~val", '" outside"'})
end


triggerdataValueIterator_test()
io.stderr:write("triggerdataValueIterator_test: OK\n")
