# See Through Rails

## Overview
This Factorio mod allows players to toggle the transparency of elevated rails, rail ramps, and rail supports with the press of a button. When enabled, all these structures on the map are replaced with transparent variants, making it easier to see what's underneath them while maintaining their functionality.

Perfect for managing complex elevated rail networks without losing sight of your factory below!

## Features
- **One-click toggle**: Use the shortcut button in the toolbar to instantly toggle transparency for all elevated structures across the entire map
- **Separate transparency settings**: 
  - **Rail Transparency** (0-100%, default 50%): Controls elevated rails
  - **Support Transparency** (0-100%, default 25%): Controls rail ramps and rail supports
- **Smart selectability**: At 100% transparency, entities become non-selectable for easy click-through
- **Pipette tool support**: Using Q on transparent entities gives you the normal version
- **Global effect**: When you click the button, ALL elevated rails, ramps, and supports on the map change transparency instantly
- **Automatic handling**: Newly built structures automatically adopt the current transparency state
- **Train-aware**: Won't replace rails with trains on them - will retry automatically when safe

## Usage
1. Install the mod and configure transparency levels in Settings > Mod Settings > Startup (requires game restart after changes)
2. Look for the rail icon shortcut button in your toolbar
3. Click the button to toggle all elevated structures between transparent and normal states
4. All elevated rails, ramps, and supports on the map will change transparency immediately

## Settings
- **Rail Transparency**: Controls how transparent elevated rails become when transparency is enabled (0-100%, default: 50%)
  - 0% = Completely invisible (and non-selectable)
  - 50% = Half transparent (default)
  - 100% = Completely opaque (same as normal rails)
  
- **Support Transparency**: Controls how transparent rail supports and rail ramps become when transparency is enabled (0-100%, default: 25%)
  - 0% = Completely invisible (and non-selectable)
  - 25% = Mostly transparent (default)
  - 100% = Completely opaque (same as normal)
  
- **Note**: Both are startup settings - you must restart the game for changes to take effect

## Compatibility
- **Factorio 2.0+** required
- Compatible with most other mods
- Works with modded elevated rail variants

## Installation
### From Mod Portal (Recommended)
1. Search for "See Through Rails" in the in-game mod browser
2. Click Install

### Manual Installation
1. Download the mod files
2. Extract the contents into your Factorio mods directory:
   - Windows: `%APPDATA%\Factorio\mods`
   - macOS: `~/Library/Application Support/factorio/mods`
   - Linux: `~/.factorio/mods`
3. Launch Factorio and enable the mod in the mod settings menu

## How It Works
The mod creates transparent versions of all elevated rail types, rail ramps, and rail supports at startup based on your transparency settings. When you toggle the button, it replaces all entities on the map with their transparent or normal variants. The replacement is instant and preserves all properties like train positions, quality, and deconstruction orders.

## Known Limitations
- Transparency settings require a game restart to change (they are baked into the entity sprites)
- Rails with trains on them will be replaced after the train leaves

## FAQ

**Q: Can I change transparency while playing?**  
A: No, transparency percentages are startup settings that require a game restart. However, you can toggle between transparent and normal at any time with the button.

**Q: What happens if I set transparency to 100%?**  
A: At 100% transparency, entities become completely invisible AND non-selectable, allowing you to click through them to interact with things below.

**Q: Does this work with other rail mods?**  
A: It should work with most mods. The mod creates transparent variants based on the base game's elevated rails.

## Support
- Report issues on [GitHub](https://github.com/ishaipicus/Factorio-See-Through-Rails/issues)
- Join the discussion on the mod portal

## Acknowledgments
Inspired by the transparent-elevated-rails mod. Thanks to the Factorio community for their support and feedback!

## License
CC BY-NC 4.0 - Free for non-commercial use

---

Enjoy your enhanced factory experience!