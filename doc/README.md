# File formats description

Reforged: Warcraft 3 defaults to UTF-8. Some files have BOM, other don't.

`war3.w3mod/ui/` or `war3.w3mod/_locales/ruru.w3mod/ui/` or (legacy) `ui/`

## triggerdata.txt and aieditordata.txt

See "triggerdata-comments.txt"

## chathelp-war3-<langcode>.txt

Same as: helpstrings.txt,

Strings are indexed by line number or indexed by blank lines as separator.

## newaccount-<langcode>.txt

Same as: termsofservice-<langcode>.txt

I think this entire file is used as one text.

## tipstrings.txt

Wacraft's custom INI format, each tip is uniquely numbered. Total number is defined in `TipCount=60`.

## worldeditgamestrings.txt, worldeditstrings.txt

Warcraft's custom INI format, all localized keys are in `WorldEditStrings` section. Values not containing `,` commas may have double-quotes omitted.

Special line flag `//#LINENOBETA` followed by affected line. Purpose unknown.

## worldeditlicense.txt

Old license text, no longer used in new/Reforged editor that simply links to website. Used as a whole.

## Warcraft 3 Custom INI Format

- Supports sections (I haven't seen keys outside of a section)
- CRLF, UTF-8 with/without BOM
- `key` starts at the beginning of a line, followed by `=`, followed by value. No whitespaces witnessed
- Empty values are OK
- Duplicate key names were witnessed, but are obviously an error.
Do not seem to cause issues or overwrite previously encountered values.
- Values may have double-quotes around them. Without double-quotes, space characters are probably ignored
   - Example: `IDMenu_Size=160,20          // Relative to row`
   - `LoadTriggerRegionHandleBJ="Load Region Handle"`
- No multi-line values. The game uses `|n` instead which are interpreted deeper down by the engine
- Multi-values (list) are possible. `,` comma is the separator
- If the value is a multi-value, then all literal values will be surrounded by double-quotes to avoid interpretation of commas.
   - Example: `key="one","two"` but `key=one` or `key="one"`
- `//` makes a comment until the end of line
- Special flags start at beginning of a line with `//#` which affect the next line
   - Example: `//#LINENOBETA`
- decimal separator is `.` for float numbers
- Chars are interpreted as bytes (see Rawcode, FourCC): `'F'`
   - `FormationToggle='F'     // Alt-F`
   - `ObserverFogOfWar=100                // Numpad 4`
   - See: https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

