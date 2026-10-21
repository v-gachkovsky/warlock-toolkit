# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-10-21

First release. Supports WoW Forever (`16001`), Classic Era (`11509`), TBC Anniversary (`20506`),
Mists of Pandaria Classic (`50504`) and Retail (`120105`) from a single TOC.

### Added
- **Armor reminder**: icon when Demon Skin / Demon Armor / Fel Armor is missing; click casts the strongest armor
  (Fel Armor once learned in TBC).
- **Soul Shard counter** in `have/recommended` format, with a configurable spare count,
  optional Ritual of Summoning and a manual highlight threshold. Only on clients with Soul Shard items
  (Forever, Classic Era, TBC); Mists and Retail show shards in the game's own UI.
- **Healthstone reminder**: icon when no Healthstone is in the bags; click creates the strongest one.
  Master stones in TBC; Demonic Healthstone counts in Retail.
- **Soulstone tracker**: yellow highlight for an unused stone, red for a missing one;
  movable label with the target's name in class color and a timer. The target is tracked by GUID.
  In Mists and Retail the Soulstone is cast directly on the target.
- **Demon summon icon** with Click / Shift / Ctrl / Alt / Cmd bindings for Imp, Voidwalker,
  Succubus, Incubus, Felhunter and Felguard. Grimoire of Supremacy demons (Mists) and Sayaad (Retail)
  replace the regular ones; no reminder while Grimoire of Sacrifice is active.
- Shared widgets: secure action icons, resizing, moving, locking and snapping into rows and columns.
- Highlight styles (*Proc*, *Running lines*, *Pulsing border*) and types (*Outline*, *Fill icon*, *Outline + fill*).
- *Highlight in combat* option.
- Separate in-combat and out-of-combat opacity (in-combat opacity is limited to at least 20%).
- *Hide icons in combat* and *Click-through in combat* options.
- Combat simulation (`/wlt combat`, Shift + right click on the minimap button), including click-through.
- Minimap button: settings, preview, combat simulation; draggable, lockable and hideable.
- Options window and `/wlt` commands: `lock`, `unlock`, `preview`, `combat`, `reset`.
- *Move icons with* option: right-button drag or a modifier + left button; the move modifier never triggers the icon's action.
- Combat handling for secure buttons: icons visible at the start of combat stay clickable until it ends,
  icons hidden at the start of combat don't take clicks.
- Addon logo.
- English and Ukrainian READMEs, CurseForge description, this changelog.
- MIT license.
- Automated releases to GitHub Releases and CurseForge from a version tag.
