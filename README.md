# Mayday: The Survival Island — 32:9 Ultrawide Fix

An unofficial Windows mod for **Mayday: The Survival Island** (Construct 3 / NW.js).

Created and tested at **5120 × 1440 (32:9)**. The patch changes the internal viewport from 1280 × 720 to 2560 × 720, extends the world horizontally, and adjusts the main menu, hotbar, and two separate in-game HUD groups. The clock's pointer follows the clock face's named attachment point.

## Install (Windows)

1. **Close the game.** Download the latest ZIP from [Releases](../../releases), or use the [downloadable ZIP supplied in the original mod announcement](https://github.com/braindancelive/mayday-survival-island-ultrawide).
2. Extract the ZIP **completely**.
3. Double-click **`Install.cmd`**. If Steam's common folders are not found, select the Mayday game directory containing `package.nw`.
4. Launch the game at 5120 × 1440.

**No manual PowerShell commands required.** The batch launcher runs the included, inspectable PowerShell script. Windows may warn you about downloaded scripts; read the source before choosing to run it.

**Uninstall:** close the game and run **`Uninstall.cmd`**. **Check:** run **`Check.cmd`**.

### Already using experimental pre-release scripts?

Those previous builds installed patches in multiple stages. **Verify the game files through Steam** to obtain a clean `package.nw` first. Then run the standalone installer. Back up your game saves before making changes.

## Features

- True wider viewport at 32:9 rather than merely stretching 16:9.
- Recentered start menu and hotbar.
- Independent survival (health and energy/hunger) and clock/day HUD positions.
- Clock pointer attached to `PONTEIRO` image point on the clock sprite.
- Live HUD placement controls and a toggle.
- Update-safe preinstall backup and SHA-256 verified rollback.
- No redistribution of game archives, textures, or executable code.

### HUD shortcuts

| Shortcut | Action |
|---|---|
| Ctrl + Alt + 1 | Select survival HUD |
| Ctrl + Alt + 2 | Select clock/day HUD |
| Ctrl + Alt + arrow key | Move selected HUD 10 internal pixels |
| Add Shift | Move only 1 pixel |
| Ctrl + Alt + 0 | Reset selected HUD to default |
| F10 | Toggle HUD correction |

The HUD's custom anchor settings are stored in the game's browser localStorage and survive reinstalls.

## Steam updates and backups

The installer checks the expected Construct 3 project signatures and known object coordinates. On an incompatible updated build it refuses to patch rather than applying arbitrary offsets.

Backups are stored in the game folder with a timestamp, with a corresponding `Mayday-32x9-Rebase-state.json`. **Do not restore a pre-update backup over a game updated by Steam.** If the uninstaller detects a changed archive checksum, it refuses to overwrite it. Verify game files and then apply the latest compatible mod build.

## Technical details

The installer locally edits a legally installed copy of `package.nw` (ZIP-compatible format):

- `data.json`: viewport width and selected known layout positions.
- `scripts/c3main.js`: imports the mod at startup.
- `scripts/mayday-ultrawide-ui.js`: the mod's runtime HUD positioning and clock pointer logic.

The project does not download scripts or game assets from the internet. The code is contained in `src/Mayday-Ultrawide.ps1`, with Windows launchers in the repository root.

**Compatibility:** tested on the author's game build on November 3, 2026. May not work on other versions, unusual aspect ratios, or all menus. The combined one-click installation path is newly packaged and should be treated as a release candidate until independently tested.

This is an unofficial community mod, not affiliated with or endorsed by the developers. Use at your own risk.

## License

The original mod code and documentation are MIT licensed. *Mayday: The Survival Island* and its proprietary assets belong to their respective owners.
