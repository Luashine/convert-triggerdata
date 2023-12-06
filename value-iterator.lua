local function triggerdataValueIterator_next(text, offset)
	offset = offset + 1

	local from, to, match;
	if text:sub(offset, offset) == '"' then
		from, to, match = text:find('(%b"")', offset)
	else
		from, to, match = text:find('([^,]+)', offset)
	end

	return to, match
end

local function triggerdataValueIterator(text)
	return triggerdataValueIterator_next, text, 0
end

return triggerdataValueIterator
