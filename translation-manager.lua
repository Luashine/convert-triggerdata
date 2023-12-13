require"file-parser"

function loadTranslationFiles(fileList)
	local tlib = require"translation-interface"
	TRANSLATION = tlib:new() -- global, used this way in value-processor

	for _, path in ipairs(fileList) do
		local file = assert(io.open(path, "rb"))

		local data = {}
		parseW3Ini(file, data)
		TRANSLATION:addTranslationData(data)

		file:close()
	end
end
