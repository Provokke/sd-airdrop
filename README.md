# SD-Airdrop - Advanced Airdrop System

An advanced airdrop system for QBCore with LB-Phone integration and government emergency alerts.

## Features

- **Multiple Phone Types**: Golden, Red, and Green satellite phones with different loot tables
- **LB-Phone Integration**: Government emergency alerts sent to all players when airdrop is called
- **Dynamic Drop Zones**: Multiple predefined locations with polyzone integration
- **Police Requirement**: Configurable minimum police count required
- **Cooldown System**: Prevents spam with configurable cooldown timer
- **Realistic Animations**: Plane flyover with parachute drop animation
- **QB-Target Integration**: Interactive crate opening with progress bars
- **Comprehensive Loot System**: Different loot tables for each phone type

## Dependencies

- qb-core
- qb-target
- qb-polyzone
- lb-phone

## Installation

1. Place the `sd-airdrop` folder in your `resources/[qb]/[crime]/` directory
2. Add `ensure sd-airdrop` to your server.cfg
3. Add the phone items to your `qb-core/shared/items.lua`:

```lua
['goldenphone'] = {['name'] = 'goldenphone', ['label'] = 'Golden Satellite Phone', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'goldenphone.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A golden satellite phone for calling high-value airdrops'},
['redphone'] = {['name'] = 'redphone', ['label'] = 'Red Satellite Phone', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'redphone.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A red satellite phone for calling weapon airdrops'},
['greenphone'] = {['name'] = 'greenphone', ['label'] = 'Green Satellite Phone', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'greenphone.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A green satellite phone for calling drug airdrops'},
```

4. Add the phone images to your `qb-inventory/html/images/` directory
5. Restart your server

## Configuration

Edit `config.lua` to customize:

- **Core Settings**: QB-Core resource name, debug mode
- **Police Settings**: Minimum cops required, police job names
- **Cooldown**: Time between airdrops
- **Drop Zones**: Radius and locations
- **Aircraft**: Plane model, speed, height
- **Loot Tables**: Items and chances for each phone type

## Phone Types & Loot

### Golden Phone
- High-value items (gold bars, diamonds, luxury items)
- Basic weapons
- Premium rewards

### Red Phone
- Military-grade weapons
- Assault rifles and ammunition
- Body armor

### Green Phone
- Drug-related items
- Various narcotics
- Street-level contraband

## LB-Phone Integration

When an airdrop is called, all players with equipped phones receive a government emergency alert:

*"GOVERNMENT ALERT: Unidentified package drop detected in your vicinity. Citizens are advised to maintain safe distance and report any suspicious activity to authorities immediately. Proceed with extreme caution."*

## Usage

1. Obtain a satellite phone (Golden, Red, or Green)
2. Use the phone item from your inventory
3. Wait for the plane to arrive and drop the crate
4. Navigate to the drop zone (marked on map)
5. Open the crate to receive loot

## Commands

No commands required - everything is item-based.

## Events

### Client Events
- `sd-airdrop:client:CreateDrop` - Initiates airdrop sequence
- `sd-airdrop:crate:openCrate` - Opens supply crate
- `sd-airdrop:crate:clearcrate` - Cleans up crate and zones

### Server Events
- `sd-airdrop:server:ItemHandler` - Handles item addition/removal
- `sd-airdrop:server:startCooldown` - Starts airdrop cooldown
- `sd-airdrop:crate:spawnCrate` - Spawns supply crate
- `sd-airdrop:crate:deleteCrate` - Removes crate from world

## Troubleshooting

### Common Issues

1. **"Not enough police online"**
   - Increase police count or lower `Config.MinCops`
   - Check police job names in config

2. **"Airdrop is on cooldown"**
   - Wait for cooldown to expire
   - Adjust `Config.Cooldown` in config

3. **Phone not working**
   - Ensure item is added to items.lua
   - Check server console for errors
   - Verify dependencies are running

4. **LB-Phone alerts not working**
   - Ensure lb-phone is running
   - Check player has phone equipped
   - Verify phone number exists

### Debug Mode

Enable `Config.Debug = true` to visualize drop zones and see additional console output.

## Support

For support and updates, visit our GitHub repository or Discord server.

## Changelog

### v2.1.0
- Added LB-Phone integration with government alerts
- Improved error handling and validation
- Enhanced crate spawning system
- Better network synchronization
- Updated documentation

### v2.0.0
- Complete rewrite for better performance
- Added multiple phone types
- Implemented polyzone drop zones
- Added realistic plane and parachute animations
- Improved loot system

### v1.0.0
- Initial release
- Basic airdrop functionality
- Single phone type
- Simple loot system