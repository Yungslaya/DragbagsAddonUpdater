# Dragbags Addon Updater

Keep your WoW: Forever addons together. Check versions, read what's new, and install updates in one window.

### [Download the updater](https://github.com/Yungslaya/DragbagsAddonUpdater/releases/latest/download/DragbagsAddonUpdater.zip)

Windows 10 / 11. No GitHub account needed.

## What's new

**1.2.0:** **Market Ledger** is now its own addon and shows up in the list. The Market Ledger Companion app now comes with it.

**1.1.0:** Installs and updates the **Market Ledger Companion**. Your Market Ledger plan is kept when the addon updates.

**1.0.1:** Change notes inside the window, a release-page button, and clear labels for newer local copies. Older downloads cannot replace newer local versions.

[Full change notes](https://github.com/Yungslaya/DragbagsAddonUpdater/releases/latest)

## The addons

| Addon | What it does | Download | Changes |
| --- | --- | --- | --- |
| [ProfessionPal](https://github.com/Yungslaya/ProfessionPal) | Guides all 12 professions from skill 1 to 300. Next steps, material counts, trainer pins, and gear shopping lists. Open with `/prof`. | [ZIP](https://github.com/Yungslaya/ProfessionPal/releases/latest/download/ProfessionPal.zip) | [Latest release](https://github.com/Yungslaya/ProfessionPal/releases/latest) |
| [Market Ledger](https://github.com/Yungslaya/MarketLedger) | Scan your bags at the Auction House and see what to auction, vendor, craft, keep or farm. Open with `/ledger`. | [ZIP](https://github.com/Yungslaya/MarketLedger/releases/latest/download/MarketLedger.zip) | [Latest release](https://github.com/Yungslaya/MarketLedger/releases/latest) |
| [DBagsAlerts](https://github.com/Yungslaya/DBagsAlerts) | Class alerts, health and power bars, cooldowns, and reminders. Previously called **ProtAlerts**. Open settings with `/pa` or `/dba`. | [ZIP](https://github.com/Yungslaya/DBagsAlerts/releases/latest/download/DBagsAlerts.zip) | [Latest release](https://github.com/Yungslaya/DBagsAlerts/releases/latest) |
| [DragsHedgeFund](https://github.com/Yungslaya/DragsHedgeFund) | Set gold goals, track your savings cuts, and see how much you can spend. Open with `/gg` or `/hedge`. | [ZIP](https://github.com/Yungslaya/DragsHedgeFund/releases/latest/download/DragsHedgeFund.zip) | [Latest release](https://github.com/Yungslaya/DragsHedgeFund/releases/latest) |

## Market Ledger Companion (app)

Market Ledger can ask an AI what to sell. You can do that with copy and paste inside the game, with no extra app. The Companion is an optional desktop app that does the same hand-off with files, for people who use an API key or an AI tool on their PC.

1. Tick **Market Ledger Companion (app)** and click **Update / Install**. It is saved in `Documents\MarketLedgerCompanion`, with a shortcut on your Desktop.
2. Install [Python 3](https://www.python.org/downloads/) if you do not have it. It is free, and the app needs it to run.
3. In WoW, at the Auction House: open Market Ledger (`/ppauction`), click **Scan Bags**, then **AI Help**, then **Save and reload**.
4. Open the Companion. Click **Copy for AI chat**, paste into ChatGPT, Claude or any AI chat, copy the whole reply, then click **Paste AI reply**.
5. Type `/reload` in WoW and open the **Plan** tab.

The app is updated together with Market Ledger and shows the same version number. It only reads and writes files on your PC; you still click every sale yourself.

The updater finds published release ZIPs on [Yungslaya's GitHub](https://github.com/Yungslaya). New addons appear when a release is published. It reads **published releases**, not unfinished changes on a repository's main page.

## Start here

1. **Download** the updater ZIP and **extract all**.
2. Open the extracted folder and double-click **Dragbags Addon Updater.bat**.
3. Check the AddOns folder at the top. Use **Change folder** if needed.
4. Select an addon row to read **What changed**. Tick its box to install it, then click **Update / Install**.

Optional: tick **Update automatically when I log in to Windows**. It checks about a minute after login and only updates installed addons.

For changed Lua files, type `/reload` in WoW. Installing a new addon or new files needs a full WoW restart.

## Updating the updater itself

Download and extract the new updater ZIP, close the old window, and open the new `.bat` file. The window title shows **1.2.0**. The old updater updates addons, not its own window.

If login updates are already enabled, untick and retick that option in the new copy to refresh the saved login script.

## What the version labels mean

- **Update ready:** GitHub has a newer release. Ticked for you.
- **Up to date:** installed and published versions match.
- **Local copy is newer:** this PC has a later version than GitHub. It is kept; the notes shown are for GitHub's release.
- **Check version:** the versions could not be compared. No automatic replacement.
- **Not installed:** tick it to install.

## Backups and settings

Old addon folders and old copies of the Companion are saved in `%LOCALAPPDATA%\DragbagsAddonUpdater\backup` (two per addon). Settings and `updater.log` are in `%LOCALAPPDATA%\DragbagsAddonUpdater`.

Login updates use a Windows scheduled task named **Dragbags Addon Updater**. Untick the option to turn it off.

The updater runs outside WoW. It downloads addon files; it does not play your character.
