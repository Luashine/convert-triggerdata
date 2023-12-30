# File formats description

Reforged: Warcraft 3 defaults to UTF-8. Some files have BOM, other don't.

`war3.w3mod/ui/` or `war3.w3mod/_locales/ruru.w3mod/ui/` or (legacy) `ui/`

**Question:** Where are all the WESTRING_ located?
**Answer:** `__LOCALE__/ui/worldeditstrings.txt`

## Useful Files

- triggerdata.txt: main file containing all GUI triggers.
- aieditordata.txt: GUI triggers as above but for AI Editor code generation
- triggerstrings.txt: only used to store GUI trigger hints
   - it's a simple INI structure (albeit multiple categories) where each `FunctionName` is called `FunctionNameHint` followed by a textual explanation.

- worldeditordata.txt: mostly localization, but gives many lists and hardcoded values a pretty name.
- uniteditordata.txt: gives pretty names to unit data values. Mostly for object editor use, **useful** for some native parameters

- miscui.txt: only useful for frame native users, some parts are **useful** for jassdoc, otherwise a separate tutorial
- miscdata.txt: hardcoded constants, **useful** to derive some terminology and default values

- campaigninfoclassic.txt: defines constants and campaign missions, needs an outside tutorial. Answers: "which campaign map is this?"
- campaigninforeforged.txt: same as above

- ui/worldeditdata.txt: mostly editor configuration, useful constants too like "Ally priority distances"
- ui/worldeditlayout.txt: dynamic and easy UI configuration (years before Windows Forms!)

## triggerdata.txt and aieditordata.txt

See "triggerdata-comments.txt"

### Trigger data fields

For general description and per section info see `triggerdata-comments.txt`

Each category is to be parsed differently.

"Entries" are keys that don't begin with `_`, they're the main object so to say

"Properties" are keys that begin with `_`, they expand the main object's definition. The property name is a `..._Suffix` to the full entry name.

Possible entry properties:

- case-insensitive: `_CATEGORY` same as `_Category`
- `_Category`: single value, category ID
- `_Defaults`: csv of default values in code or `_`

- `_Parameters`: multi-value, comma-separated. See INI format
   - example: `_GetPlayerTechCountSimple_Parameters="Current research level of ",~Tech," for ",~Player`
   - example: `_GetPlayerUnitCount_Parameters="Count non-structure units controlled by ",~Player," (",~Include/Exclude," incomplete units)"`
      - here, `/Exclude` is a suffix to be concatenated to construct the type with its pre-defined default boolean value

- `_DisplayName`: single value, in double-quotes (but localization files do not have them sometimes)

- `_Limits`: multi-value csv, used for integer/real limits. Two entries per argument: `min,max`
   - numbers are both inclusive, non-integer or "no limit" is denoted by an underscore `_`
   - may have a trailing comma (followed by nothing)
   - may have one or both limits (e.g. only minimal limit)

- `_ScriptName`: I suppose this is the alias to be used in generated code
   - example: `_SetHeroLevel_ScriptName=SetHeroLevelBJ`

- `_UseWithAI`: always used with a 1, so it must default to 0 if unspecified

- `_AIDefaults`: apparently only applied in AI editor, while regular map triggers use `_Defaults`


## triggerstrings.txt

**1.31, 1.32.0.13369, 1.32.10.18820 and older:** contains three lines per entry:

1. Duplicated `FuncName_DisplayName`, same as in `triggerdata.txt`, but under key `FuncName`
2. Duplicated `FuncName_Parameters`, same as in `triggerdata.txt`, but under key `FuncName`
3. Unique `FuncNameHint` that contains the translated hint text.


**Since 1.33.0.18857, 1.34.0.19572, 1.36.0.20144:** only contains `...Hint` entries.

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

