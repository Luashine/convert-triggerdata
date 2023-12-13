#!/usr/bin/env lua
package.path = package.path .. ";./../?.lua"

require"translation-manager"

loadTranslationFiles({"test-lang-1a.txt", "test-lang-1b.txt"})

--print(TRANSLATION.getTablesLang, "what")

assert(TRANSLATION:tr("WESTRING_MISSING") == "WESTRING_MISSING")

assert(TRANSLATION:tr("WESTRING_VERYICY") == "Very Icy")
assert(TRANSLATION:tr("WESTRING_VERYICY_QUOTES") == "Very Icy Quoted")
assert(TRANSLATION:tr("WESTRING_VERYICY_RECURSION") == "Recursion works")


assert(TRANSLATION:tr("WESTRING_VERYGOOD") == "Very Good")
assert(TRANSLATION:tr("WESTRING_lowercase") == "It's lower case")
assert(TRANSLATION:tr("WESTRING_LOWERCASE") == "WESTRING_LOWERCASE")

io.stderr:write("Language test OK!\n")
