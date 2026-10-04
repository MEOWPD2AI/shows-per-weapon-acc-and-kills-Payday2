# Missed Shots Tracker (per-weapon fork)

A PAYDAY 2 [SuperBLT](https://superblt.znix.xyz/) mod that shows how many shots you've missed during a heist.

## Fonts

In *Options -> Mod Options -> Shots Missed Tracker*:

1. **FONT**: Default (game font) or one of the bundled font packs.
2. **FONT STYLE**: the small, medium or large variant of that font.
3. **SIZE**: text size.
4. **TEXT COLOR**: white (default), a solid color, or **Rainbow**, which cycles through all colors with a different hue on each column.

The font packs live in `assets/fonts/` and are added to the game by `main.xml` with [BeardLib](https://modworkshop.net/mod/14924) (needed for the packs). They use their own file names (`mst_*`), so nothing in `mod_overrides` is needed and the game's own fonts are not replaced. Without BeardLib, or if a font fails to load, the default font is used.

| Font | Notes |
|---|---|
| Andy | |
| Hemi Head | |
| Minecraftia | |
| Determination Mono | Undertale style |
| VL Gothic | RPG Maker style |

The packs were made by other people; credit and licences belong to their authors.

## What's new in 3.9.0

- **DAMAGE MODE** switch for the damage column:
  - *Total per weapon*: everything you dealt with that weapon this heist (title `Damage`).
  - *Last hit*: the damage of your most recent hit with that weapon (title `Hit`). Each shotgun pellet counts as a hit.
  - *Current enemy*: damage dealt to the enemy you are hitting, starting over when you hit a different enemy (title `Enemy`). It is the same number on every row.
- **SHOW DAMAGE** toggle to hide the damage column completely.

## What's new in 3.8.0

- Weapon type words (Rifle, Shotgun, Sniper, SMG, LMG, Pistol, ...) are removed from names by default, e.g. `Mark 10` instead of `Mark 10 Submachine Gun`. Turn on **SHOW WEAPON TYPE** to get the full name back. Works for English weapon names.

## What's new in 3.7.0

- **SHOW WEAPON NAME** toggle: hide the Name column and show only the stats.

## What's new in 3.6.0

- New **Damage** column: total damage you have dealt with each weapon this heist (melee, throwables and teammates' damage are not counted). The number is scaled to match the damage values shown in the game's weapon stats.

## What's new in 3.5.0

- **Column spacing** and **Background padding** sliders.

## What's new in 3.4.0

- The equipped weapon is now detected by a periodic check instead of an equip hook, so it appears in the table right away and updates when you switch weapons.
- The table shows only the weapon you are holding (toggle **ONLY EQUIPPED WEAPON** to see all weapons used). Stats for other weapons are kept.

## What's new in 3.3.0

- The **Shots missed** counter line is now hidden by default (toggle it back on in the menu).
- Your equipped weapon is added to the table as soon as you equip it, before the first shot.

## What's new in 3.2.0

- The table has its own **Table X / Table Y** sliders, separate from the counter's **Counter X / Counter Y**.
- Optional **background** behind the counter and the table, with an opacity slider.

## What's new in 3.1.0

- **Per-weapon table** under the "Shots missed" counter, one row per weapon you fire during the heist:

  ```
  Shots missed: 12
  Name    Kills   Damage     Hits/Shots   Acc%
  M249    236     412,300    1020/2040    50.00%
  ```

- Can be switched on/off in *Options → Mod Options → Shots Missed Tracker*. The table follows the existing size, X and Y settings.
- Fixed the **RESET** button, which did not actually reset the saved settings.
- Counters are cleared at the start of each heist.

Based on [vojin154/pd2_missed_shots_tracker](https://github.com/vojin154/pd2_missed_shots_tracker) (MIT).

## Install

1. Install SuperBLT.
2. Download this repo as a ZIP and extract the folder into `PAYDAY 2/mods/`.

## Notes

- Kills count the local player's own weapon kills (melee and throwables are not counted).
- Per-weapon shots/hits are derived from the game's own session totals, so they match how the game counts them (e.g. shotgun pellets).
