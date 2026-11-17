# CurseForge publication

This manually triggered workflow uploads only the checksum-pinned releases in `releases.json`. It does not edit project descriptions, summaries, galleries or project settings.

Create an author upload API token in CurseForge Authors Console > API Tokens. Store it as the `CURSEFORGE_API_TOKEN` Actions repository secret in this repository. Never commit or paste it into issues, chat, or workflow inputs.

Run **CurseForge uploads** with `publish` unchecked first. This checks the ZIP, version lookup and token access; it does not prove project write permission. Then run with publishing enabled for MarketLedger first and ProfessionPal second. File uploads include optional project relationships. Check the resulting file IDs for approval and public availability before advertising the integration on project pages.

Do not rerun an upload whose result is uncertain until checking the project's files for duplicates. Uploads can await CurseForge moderation. There are no push, tag or release event triggers: saving the token or committing code does not publish anything.

The marketing copy in this folder is prepared separately for the author console. Keep existing genuine screenshots and video. Do not fabricate a screenshot of the new price display. Preserve the TSM setup explanation; do not advertise the unused Market Ledger Companion.

These publishing tools and documents are repository-only and must never be included in addon or updater distribution ZIPs.
