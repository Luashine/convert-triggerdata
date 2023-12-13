
-- Note: single-instance for now

local TRANSLATION = {}
local TFUNC = {}

local indexThrowBecauseNil = function (tbl, key)
	error("Key '".. key .."' not found in language table '".. tostring(tbl) .."'")
end
local mt_indexThrowOnNil = {
	__index = indexThrowBecauseNil
}

function TRANSLATION:new(lang)
	lang = lang or "default"


	local newStorage = {
		defaultLang = lang
	}

	setmetatable(newStorage, {
		__index = function(t, key)
			local value = self[key] or TFUNC[key]
			if value then
				return value
			else
				indexThrowBecauseNil(t, key)
			end
		end

	})

	local languages = {}
	newStorage.languages = languages
	setmetatable(languages, mt_indexThrowOnNil)

	newStorage:initLang(lang)

	return newStorage
end

--- Creates lang storage if it doesn't exist
function TFUNC:initLang(lang)
	lang = lang or self:getDefaultLangCode()

	if not self.languages[lang] then
		local t = {
			dataTables = {}
		}
		setmetatable(t, mt_indexThrowOnNil)
		self.languages[lang] = t
	end
end

--- Returns default language code
function TFUNC:getDefaultLangCode()
	return self.defaultLang
end

--- Returns list containing data tables for language
function TFUNC:getTablesLang(lang)
	lang = lang or self:getDefaultLang()
	return self.languages[lang].dataTables
end

--- Translate a given stringId or returns it if not found
function TFUNC:translate(stringId, lang)
	local dataTables = self:getTablesLang(lang)
	local goodMatch

	-- recursive string lookups possible
	for i = 1, #dataTables do

		local dt = dataTables[i]

		local match = dt["WorldEditStrings"][stringId]
		if match and match ~= "" then
			goodMatch = match
			-- translate recursively until nil is hit
			return self:translate(goodMatch, lang)
		end

	end

	return goodMatch or stringId
end


--- Adds another table to language lookup, first table added has highest lookup priority (FIFO)
function TFUNC:addTranslationData(tbl, lang)
	self:initLang(tbl, lang)
	table.insert(self.dataTables, tbl)
end

return TRANSLATION
