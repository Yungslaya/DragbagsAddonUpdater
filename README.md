# Dragbags Addon Updater

**One click keeps every Yungslaya WoW: Forever addon up to date.** Set it once and it updates your addons by itself every time you log in to Windows.

### [⬇ Download Dragbags Addon Updater (zip)](https://github.com/Yungslaya/DragbagsAddonUpdater/releases/latest/download/DragbagsAddonUpdater.zip)

No account needed · Windows 10 / 11 · nothing to install

---

## What it does

- **Finds your WoW: Forever AddOns folder** on its own (or you point it there once).
- **Checks GitHub** for every addon Yungslaya publishes and shows *You have* vs *Newest*.
- **Updates with one click.** Updates are ticked for you. Tick any addon you don't have yet to install it.
- **Auto-update at login.** Tick one box and it checks a minute after you log in to Windows, then pops up a small note if anything changed.
- **Safe by design.** It only touches the addon folders inside Yungslaya's releases, saves the old version first, and logs everything.

## Use it

1. **[Download the zip](https://github.com/Yungslaya/DragbagsAddonUpdater/releases/latest/download/DragbagsAddonUpdater.zip)** and unzip it anywhere.
2. Double-click **`Dragbags Addon Updater.bat`**.
   First time only: if Windows says *"Windows protected your PC"*, click **More info → Run anyway**.
3. Click **Update / Install**. Tick **Update automatically when I log in to Windows** to never think about it again.

If WoW is open during an update, type `/reload` in game.

## The addons

The updater installs and updates all of these. You can also grab any one on its own.

### [ProfessionPal](https://github.com/Yungslaya/ProfessionPal) · beta

**Every profession from 1 to 300, inside the game.** Type `/prof`.

- Tells you the one thing to do next, like *"Make 25 × Bronze Warhammer"*.
- Counts your bags and bank for every material you need.
- Pins your next trainer on the map and keeps a shopping list.
- Ranks the gear your profession can make for your class and role.
- All 12 professions, gathering and crafting.

[Get it](https://github.com/Yungslaya/ProfessionPal) · [Download zip](https://github.com/Yungslaya/ProfessionPal/releases/latest/download/ProfessionPal.zip)

### [ProtAlerts](https://github.com/Yungslaya/ProtAlerts) · work in progress

**Big, clear tank alerts for Protection Warrior and Paladin.** Type `/pa`.

- Big icons for danger: low health, loose mobs, taunt and kick.
- Health, rage/mana, threat and swing timer bars.
- Range dot on your target: green = in melee, red = too far.
- Makes your tank macros for you.
- Display only. It never presses buttons for you.

[Get it](https://github.com/Yungslaya/ProtAlerts) · [Download zip](https://github.com/Yungslaya/ProtAlerts/releases/latest/download/ProtAlerts.zip)

New addons show up in the updater by themselves once they're on [github.com/Yungslaya](https://github.com/Yungslaya) with a release zip.

## How it works

A single PowerShell script (`updater.ps1`, readable in this repo) with a small Windows window. It reads the public GitHub API, downloads the latest release zip of each addon, and swaps the addon folder in place. Old versions go to `%LOCALAPPDATA%\DragbagsAddonUpdater\backup`. The login check is a normal Windows scheduled task named **Dragbags Addon Updater**, which you can switch off with the same checkbox.
