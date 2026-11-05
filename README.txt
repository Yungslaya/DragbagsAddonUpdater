Dragbags Addon Updater 1.0.0
============================

One click keeps every Yungslaya WoW: Forever addon up to date.

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
