# Elevated Rail Transparency

## Overview
This Factorio mod allows players to toggle the transparency of elevated rails, rail ramps, and rail supports with the press of a button. When enabled, all these structures on the map are replaced with transparent variants, making it easier to see what's underneath them while maintaining their functionality.

## Features
- **One-click toggle**: Use the shortcut button in the toolbar to instantly toggle transparency for all elevated structures across the entire map
- **Separate transparency settings**: 
  - **Rail Transparency** (0-100%, default 50%): Controls elevated rails
  - **Support Transparency** (0-100%, default 75%): Controls rail ramps and rail supports
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
  - 0% = Completely invisible
  - 50% = Half transparent (default)
  - 100% = Completely opaque (same as normal rails)
  
- **Support Transparency**: Controls how transparent rail supports and rail ramps become when transparency is enabled (0-100%, default: 75%)
  - 0% = Completely invisible
  - 75% = Moderately transparent (default)
  - 100% = Completely opaque (same as normal)
  
- **Note**: Both are startup settings - you must restart the game for changes to take effect

## Requirements
- Factorio 2.0+

## Installation
1. Download the mod files
2. Extract the contents into your Factorio mods directory, typically located at:
   - Windows: `%APPDATA%\Factorio\mods`
   - macOS: `~/Library/Application Support/factorio/mods`
   - Linux: `~/.factorio/mods`
3. Launch Factorio and enable the mod in the mod settings menu

## How It Works
The mod creates transparent versions of all elevated rail types, rail ramps, and rail supports and replaces them when you toggle the button. The transparency levels are baked into the sprites at startup based on your settings.

## Compatibility
This mod is designed to work with Factorio 2.0+. It should be compatible with most other mods that don't heavily modify elevated rail entities.

## Acknowledgments
Inspired by the transparent-elevated-rails mod. Thanks to the Factorio community for their support and feedback!

Enjoy your enhanced factory experience!