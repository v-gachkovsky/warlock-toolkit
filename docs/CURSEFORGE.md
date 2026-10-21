# Warlock Toolkit

**Never forget your armor, stones, shards or demon again.**

Warlock Toolkit is a lightweight helper for Warlocks in **World of Warcraft: Forever**. It shows an icon only when
something is missing, and a single click fixes it: cast your armor, create a Healthstone, apply a Soulstone or
summon your demon.

On any other class the addon does nothing and stays fully disabled.

**Works on every client:** WoW Forever, Classic Era, TBC Anniversary, Mists of Pandaria Classic and Retail.
The addon adapts to each one: Fel Armor and Master stones in TBC, no extra shard counter (the game shows them) and direct-cast
Soulstone in Mists and Retail, Sayaad and Grimoire of Sacrifice in Retail.

---

## Features

| Icon | Shown when | Click |
|------|------------|-------|
| **Armor** | Demon Skin / Demon Armor is missing | Casts your strongest armor |
| **Soul Shards** | Always (counter) | — |
| **Healthstone** | No Healthstone in your bags | Creates your strongest Healthstone |
| **Soulstone** | Stone unused or missing | Applies or creates the stone |
| **Demon** | No pet out | Summons the demon you assigned |

### Armor

Reminds you when neither Demon Skin nor Demon Armor is up. Click to cast Demon Armor, or Demon Skin if you
haven't learned Demon Armor yet.

### Soul Shard counter

Shows your shards as **have / recommended** and lights up when you're running low. The recommended amount is
calculated from what you actually know:

- 1 shard for summoning a demon (once Voidwalker, Succubus or Felhunter is learned)
- 1 shard for each learned stone: Healthstone, Soulstone, Firestone, Spellstone
- spare shards (1 by default, configurable)
- optionally, Ritual of Summoning

You can also set the warning threshold manually.

### Healthstone

Appears when there's no Healthstone in your bags. Click to create the strongest one you know.

### Soulstone

- **Yellow highlight**: the stone is in your bags but not applied. Click to use it on your friendly target (or yourself).
- **Red highlight**: no stone in your bags. Click to create one.

When your Soulstone is on another player, a movable label shows **their name in class color and the remaining
time**. When it's on yourself, only the timer is shown (optional). Font, size, outline, icon and background
opacity are all configurable.

### Demon

Appears when you have no pet. Bind a different demon to **Click, Shift, Ctrl, Alt and Cmd (Mac)**: Imp,
Voidwalker, Succubus, Incubus, Felhunter or Felguard.

---

## Make it yours

- **Every feature** can be turned on or off individually.
- **Every icon** can be resized, moved, locked, and given its own highlight color and alert sound.
- **Highlight styles**: *Proc* (the Cooldown Manager animation, default), *Running lines* or *Pulsing border*.
- **Highlight types**: *Outline*, *Fill icon* or both. Highlighting in combat can be turned off.
- **Snapping**: drop an element next to another one and it lines up neatly, so building rows and columns is easy.
  Snap distance and spacing are adjustable.
- **Background opacity** for the shard counter and the Soulstone label.
- **Sounds**: 14 game sounds, LibSharedMedia sounds, or **your own .ogg / .mp3 files** for every alert.

## Built for combat

- Separate **in-combat and out-of-combat opacity**.
- **Hide icons in combat** if you only want reminders between fights.
- **Click-through in combat**: in combat the icons ignore the mouse, so you can click targets and turn the
  camera right through them.
- **Combat simulation**: preview out of combat how everything will look and behave once a fight starts.
- Icons visible when combat starts stay clickable for the whole fight. Icons that weren't needed never block
  your clicks.

---

## Commands

| Command | Action |
|---------|--------|
| `/wlt` | Open settings (also in *Options → AddOns*) |
| `/wlt lock` / `/wlt unlock` | Lock or unlock all elements |
| `/wlt preview` | Show all icons to position them |
| `/wlt combat` | Toggle combat simulation |
| `/wlt reset` | Reset settings |

## Minimap button

- **Left click**: open settings
- **Right click**: toggle preview
- **Shift + right click**: toggle combat simulation

The button can be dragged around the minimap, locked or hidden.

## Moving icons

By default, drag icons with the **right mouse button**. You can switch to Shift / Ctrl / Alt / Cmd + left
button in the settings. The shard counter and the Soulstone label are dragged with the left button.

---

## Good to know

- WoW doesn't allow secure buttons to be shown, hidden or moved in combat. If an icon becomes needed
  mid-fight, it appears as a reminder and becomes clickable once combat ends. Settings changed in combat
  apply after combat.
- WoW Forever may hide auras in combat. The addon then keeps the last known state and updates it from your own
  casts (Demon Armor, Soulstone).
- Spell and item IDs come from Classic Era. If anything differs in Forever, the addon looks the spell up by name.

## Feedback

Found a bug or have an idea? Open an issue on [GitHub](https://github.com/v-gachkovsky/warlock-toolkit/issues).

---

With ❤️ from 🇺🇦
