-- aka Hint manager to load the explanation strings

require"file-parser"

--[[
Although the triggerstrings.txt follows this structure:

[AIFunctionStrings]
TownThreatenedHint="Some Hint"

which corresponds to aieditordata.txt/triggerdata.txt:

[AIFunctions]
TownThreatened=1,0,boolean
//...etc

I decided to turn these all into a flat list for now such that there are no assumed categories
and all hints are easily accessible by function name key:

local thisHint = hintTable[ funcName .. "Hint" ]

]]

function loadHintFiles(fileList)
	local data = {}

	-- load in reverse, so the first specified file overrides the last file thus first has a higher priority
	for i = #fileList, 1, -1 do
		local path = fileList[i]

		local file = assert(io.open(path, "rb"))


		parseW3Ini(file, data)

		file:close()
	end

	local flatHints = {}
	for catKey, catTbl in pairs(data) do
		for funcKey, hintDef in pairs(catTbl) do

			if type(hintDef) == "string" then
				if #hintDef ~= 0 then
					flatHints[funcKey] = hintDef
				end
				-- else leave empty, do not overwrite

			else
				local hasData = false
				for _,_ in pairs(hintDef) do
					hasData = true
					break
				end

				if hasData then
					flatHints[funcKey] = hintDef
				end
				-- else leave empty, do not overwrite

			end
		end
	end

	return flatHints
end
