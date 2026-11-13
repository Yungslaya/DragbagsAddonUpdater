Dragbags Addon Updater 1.1.0
============================

One click keeps every Yungslaya WoW: Forever addon up to date.

NEW IN 1.1.0
------------
Installs and updates the Market Ledger Companion, the desktop app for
ProfessionPal's AI Help. Tick "Market Ledger Companion (app)".
Your Market Ledger plan is now kept when ProfessionPal updates.

MARKET LEDGER COMPANION (AI HELP)
---------------------------------
Market Ledger can ask an AI what to sell. Addons cannot reach the
internet, so this small app carries your scan to the AI and back.
1. Tick "Market Ledger Companion (app)", click "Update / Install".
   It goes in Documents\MarketLedgerCompanion with a Desktop shortcut.
2. Install Python 3 (free) from https://www.python.org/downloads/
3. In WoW at the Auction House: /ppauction, "Scan Bags", "AI Help",
   then "Save and reload".
4. Open the Companion. "Copy for AI chat", paste into ChatGPT, Claude
   or any AI chat, copy the whole reply, then "Paste AI reply".
5. Type /reload in WoW and open the Plan tab.

To update the updater itself, download and unzip this new copy and open
its .bat file. If login updates are enabled, untick then retick the box
in this new copy to refresh the login task.

HOW TO USE
----------
1. Unzip this anywhere (your Desktop is fine).
2. Double-click "Dragbags Addon Updater.bat".
   The first time, Windows may show a blue box "Windows protected your PC".
   Click "More info", then "Run anyway". It's a script from the internet,
   so Windows asks once.
3. The window finds your WoW: Forever AddOns folder by itself.
   (If it can't, click "Change folder" and pick your World of Warcraft folder.)
4. Updates are ticked for you. Click "Update / Install".
   Want an addon you don't have yet? Tick it and click "Update / Install".
5. Tick "Update automatically when I log in to Windows" and you never have
   to open it again. It checks a minute after you log in and pops up a
   small note when something was updated.

If WoW is open while it updates, type /reload in game.

WHAT IT TOUCHES
---------------
Only the addon folders inside Yungslaya's GitHub releases. Other addons
are never touched. The old version is saved first in:
  %LOCALAPPDATA%\DragbagsAddonUpdater\backup
A log is in the same folder (updater.log).

TURN IT OFF
-----------
Untick the auto-update box, or delete the task "Dragbags Addon Updater"
in Windows Task Scheduler.

Source: https://github.com/Yungslaya/DragbagsAddonUpdater

THE ADDONS
----------
ProfessionPal - profession guides, materials and gear lists. /prof
DBagsAlerts - class alerts and bars. Formerly ProtAlerts. /pa
DragsHedgeFund - gold goals and savings. /gg

See each addon's download and change notes:
https://github.com/Yungslaya/DragbagsAddonUpdater#the-addons
