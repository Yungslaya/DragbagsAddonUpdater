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

## Addons it keeps updated

Every repo on [github.com/Yungslaya](https://github.com/Yungslaya) with a release zip, for example
[ProfessionPal](https://github.com/Yungslaya/ProfessionPal), a profession guide for all 12 professions from 1 to 300.

## How it works

A single PowerShell script (`updater.ps1`, readable in this repo) with a small Windows window. It reads the public GitHub API, downloads the latest release zip of each addon, and swaps the addon folder in place. Old versions go to `%LOCALAPPDATA%\DragbagsAddonUpdater\backup`. The login check is a normal Windows scheduled task named **Dragbags Addon Updater**, which you can switch off with the same checkbox.
