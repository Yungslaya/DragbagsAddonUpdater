# Full bags? Know your next move, then post it in two clicks.

Market Ledger scans your bags at the Auction House and tells you what to **auction, vendor, craft, keep or farm**. When you sell, it checks the live lowest price, undercuts it, and fills in WoW's sell form for you. You always click the final Create Auction yourself.

## What makes it different

- **Two-click selling at the live price.** Click **Prepare** and Market Ledger checks what other players are asking right now, skips your own listings, and fills the sell form. Click again to post.
- **Undercut your way.** Choose smallest (1 copper for trade goods, 1 silver for other items), 1%, 2%, 5%, or match the lowest.
- **Troll listings ignored.** A lone silly price far above the usual one is never used, and a live price under half your scan is flagged for you to check first.
- **Whole stacks of trade goods.** Ore, stone, cloth and the like post your full amount across your bags, not 20 at a time. If some are in your reagent bag or quiver, it tells you to move them first.
- **Sell, vendor or craft?** Compares the auction price with the vendor price and with what you could craft or smelt, so you don't vendor something worth silver.
- **Plays well with others.** Uses TradeSkillMaster price data when it's installed, and shares prices with ProfessionPal's Farm Planner.

## How to use it

1. Open the Auction House, type **/ledger**, and click **Scan Bags**.
2. Review the **Auction**, **Vendor**, **Craft**, **Keep** and **Farm** tabs. Scans cover eligible bag items and relevant available crafting/farming picks, not every auction in the house.
3. On the Auction tab, click **Prepare** on an item, check the sell form, then click again to post. Pick your undercut with the button next to Scale.

Choose how much spare stock to offer. Blacklist supplies you want to keep, and use price history to put your latest scan in context. With ProfessionPal, guide material reserves are protected and crafting/farming guidance is available.

## Sell the materials—or craft with them?

Compare scanned material values with available crafting or smelting options. These are estimates based on asking prices, not proof that an item will sell or that crafting will make a profit. Review quantities, auction costs and demand before committing.

## Prices inside ProfessionPal

Using [ProfessionPal](https://www.curseforge.com/wow/addons/professionpal)? Your scanned material estimates also appear in its Farm Planner. Check the estimate and scan age while choosing a farm, then use Market Ledger's Farm tab to open supported ProfessionPal map destinations.

Requires Market Ledger 1.3.7 or newer and ProfessionPal 1.3.8.4 or newer (the latest of both is recommended). Both addons work independently; ProfessionPal supplies the integrated crafting/farming guidance. Run **Scan Bags** after upgrading to populate observation times for older saved prices.

## Add TradeSkillMaster for price context

1. Install the WoW: Forever-compatible [TradeSkillMaster addons](https://www.tradeskillmaster.com/) and set up their desktop app for your realm using TSM's instructions.
2. Let its data update, then start WoW with TSM enabled.
3. Run a Market Ledger scan. Hover an item or use **Copy for AI** to see available TSM data. No separate linking step is needed.

Your scan shows **asking prices**, not completed sales. The usual-price trend comes from earlier scans. TSM adds regional sale-price/rate/volume context when available; some price fields can fall back to market averages. These references do not promise your next sale.

Vendor comparisons can include TSM's cached realm minimum buyout for the item's full link. Its age is unknown here. It never silently replaces an unknown scan price. Comparisons assume a 5% auction cut and exclude deposits: review the actual selling window, especially for tiny gains.

**AH busy?** Stop another active auction scan, or click **WoW UI** in TSM, then return to Market Ledger. A paused scan resumes with **Scan Bags**. TSM can stay loaded, preserving its price context. Market Ledger does not disable TSM or automatically cancel its work.

## Optional advice import

Use **AI Help** to copy a report into your chosen chat service, then paste a supported reply into Market Ledger's Plan tab. No API key is required for copy and paste. Review the plan before acting; you choose which service receives the report.

## Useful commands

- **/ledger** opens Market Ledger.
- **/ledgerdebug** opens scan diagnostics when something gets stuck.

Auction House figures are observed asking prices, not guaranteed sales. Unknown prices remain unknown. Rescan before relying on an old estimate.

[Source](https://github.com/Yungslaya/MarketLedger) · [Report a bug](https://github.com/Yungslaya/MarketLedger/issues) · [More addons by Dragbag](https://www.curseforge.com/members/dragbag/projects)
