# Notchlet Settings and Payments

## Settings popup
The settings popup should be reachable from the island and contain:
- Installed extensions
- Available extensions
- API keys
- Payments
- Feature requests
- About / version info

## API keys
- Claude API key entry.
- Store sensitive keys in Keychain, not plain preferences.

## Payments
- Music module remains free.
- Support a tip jar with $5, $10, and $20 options.
- Support $1 extension purchases for premium modules.
- **Mandatory**: Add "Restore Purchases" button for StoreKit 2 synchronization.

## Extension install flow
- Show free and premium extensions.
- Allow install, enable, disable, and purchase.
- Locked extensions should show price and unlock state.
- Purchased extensions must hide the price and show an Enable/Disable toggle.

## Feedback flow
- Feature request button.
- Bug report button.
- Support link.

## About / version info
- Version number and build string.
- **Legal**: Clickable links to Privacy Policy and Terms of Service.
- Check for updates button.
