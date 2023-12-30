# GUI Trigger Data Converter for WC3

This is a tool to export Warcraft 3's editor trigger data to JSON/serialized Lua formats.
Intended for ingestion into jassdoc.

## Installation

1. Copy this repository
2. `lua` must be installed. I developed on 5.4, but 5.1 seemed to be working fine.

## Usage

Run `./convert-triggerdata.lua --help`

Basic conversion of triggers:

```shell
lua ./convert-triggerdata.lua \
	'../extract-w3t-1.36.0.20144-b8db0de/war3.w3mod/_locales/enus.w3mod/ui/triggerdata.txt' -f json \
	> triggerdata.json
```

Example command with localization:

```shell
lua ./convert-triggerdata.lua '../Sinistra/TriggerData.txt' \
	-f json -t trigger \
	--lang '../Sinistra/worldeditstrings.txt' \
	--hint '../Sinistra/TriggerStrings.txt' \
	> triggerdata-ru.json
```

Multiple lang files and hints are supposed to be working, first file has highest priority.

## Localization versioning

### worldeditstrings.txt

This file on its own is of little importance, although it contains important terminology, it totally lacks the GUI triggers.

- w3t-1.31.1: has enus, zhcn, kokr. Everything else empty strings
- w3-1.30.4.11274: has ruru
- wc3-1.30.0.9900: has ruru (fully translated, even the JassHelper strings)
- 1.27-de: is German

*It was a deliberate decision by management to remove the (partial) translations for some reason. Only zh-CN remained in later versions.*

### triggerstrings.txt

Looks like it was never translated by official distributors.

There exist:

- A fixed version of the [1.26 English WorldEditor strings by PT153](https://xgm.guru/p/wc3/englify-we-1-26).
- A Russian translation of [WorldEditor up to 1.36 by Sinistra](https://xgm.guru/p/wc3/RusWorldEditor).

Versions I've checked:

- w3t-1.31.1: has enus, zhcn. Everything else contains English
- w3-1.30.4.11274: no ruru
- wc3-1.30.0.9900: no ruru
- w3-1.29.2.9231: no ruru in War3Local, War3xLocal - contains English
- 1.28.6.7933: RU-War3Local has no ui files; RU-War3xLocal is English
- 1.28.2.7395: RU-War3local & War3Patch are placeholders, War3xlocal is English
- 1.27-de: is English
- 1.27-ru, tft: is English

## TODO

### Rewrite into separate entities

Warcraft INI parsing lib + conversion of that data into object-oriented way (JSON).
Right now both trigger parsing and the *unfiltered* INI parsing is one whole piece.

Then it would make sense to release this as a Luarocks module.

### Separate cascade data storage lib

For the purpose of merging and taking data from different sources and versions, a data storage backend
is required that will allow simple priority-based lookups. For example, an outdated language file is used
and any missing data is retrieved from an up-to-date official file.

This is true for language files (easy) and trigger data (hard), because triggers have a more complicated structure
to them.

This would end up in refactoring both "hint files" and "language files" management and how the trigger
processing code accesses them. Much cleaner.

Finally this would unlock merging of custom triggerdata.txt files that we already have a couple of,
examples include JNGP and GuiGui. Some discussion here: https://github.com/speige/WC3MapDeprotector/issues/14

