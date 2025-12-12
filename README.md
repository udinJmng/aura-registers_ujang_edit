# aura-registers

A Free register POS system for FiveM.

## Description

Aura Registers is a comprehensive point-of-sale (POS) system designed for FiveM servers using QBCore framework. It allows job-based employees to manage registers at various locations, create invoices for customers, and handle payments through a modern web-based interface. The system supports multiple languages and is fully customizable for different businesses.

## Features

- **Job-Based Access**: Restrict register access to specific jobs (e.g., burgershot, beanmachine).
- **Multiple Locations**: Define multiple register locations per business with precise coordinates.
- **Item Management**: Pre-configure menu items with prices, images, and categories.
- **Invoice System**: Create detailed invoices for customers with itemized lists.
- **Payment Methods**: Support for both card and cash payments.
- **Custom Bills**: Create custom invoices with any amount and description.
- **Web Interface**: Modern, responsive UI built with HTML/CSS/JS.
- **Multi-Language Support**: Built-in support for English, Spanish, Turkish, and Arabic.
- **Audio Feedback**: Sound effects for user interactions.
- **Version Checking**: Automatic update notifications.

## Installation

1. **Download the Resource**:
   - Download or clone this repository into your `resources` folder.

2. **Dependencies**:
   - Ensure you have the following dependencies installed:
     - [qb-core](https://github.com/qbcore-framework/qb-core)
     - [ox_lib](https://github.com/overextended/ox_lib)
     - [qb-inventory](https://github.com/qbcore-framework/qb-inventory) (for item images)

3. **Add to server.cfg**:
   ```cfg
   ensure qb-core
   ensure ox_lib
   ensure qb-inventory
   ensure aura-registers
   ```

4. **Restart Server**:
   - Restart your FiveM server or use `/refresh` and `/start aura-registers` in the console.

## Configuration

### Basic Settings

Edit `config.lua` to customize the system:

- `VersionCheck`: Enable/disable automatic version checking (`true`/`false`).
- `DefaultLocale`: Set the default language (`"en"`, `"es"`, `"tr"`, `"ar"`).

### Adding Registers

Each register is defined in the `Config.Registers` table. Example structure:

```lua
burgershot = {
    id = "1",                                    -- Unique identifier
    label = "Burgershot",                        -- Display name
    jobRequired = "burgershot",                  -- Required job name
    openingMethod = "boxzone",                   -- "target" or "boxzone"
    locations = {                                -- Array of locations
        { coords = vector3(-1197.46, -892.53, 14.14), heading = 35.0 }
    },
    menuItems = {                                -- Array of items
        { id = "burger_bleeder", name = "Bleeder Burger", price = 8.50, imageUrl = "nui://qb-inventory/html/images/burger_bleeder.png", category = "burgers" }
    },
    categories = {                               -- Category definitions
        burgers = "Burgers"
    }
}
```

### Localization

Add or modify language files in the `locales/` folder. Supported locales:
- `en.json` - English
- `es.json` - Spanish
- `tr.json` - Turkish
- `ar.json` - Arabic

## Usage

### For Employees

1. **Access Register**: Approach a register location and interact (target or enter zone).
2. **Add Items**: Browse categories and add items to the cart.
3. **Create Invoice**: Enter customer ID and confirm payment method.
4. **Custom Bills**: Use "Create Custom Bill" for non-menu transactions.

### For Customers

1. **Receive Invoice**: Get notified of pending invoices.
2. **View Invoices**: Access "My Invoices" to see pending/paid bills.
3. **Pay Invoice**: Select payment method (card/cash) and confirm.

### Commands

- No specific commands; interaction is location-based.

## Support

For issues or questions:
- Create an issue on GitHub
- Join our Discord community

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

- Developed by Aura Development
- Built for QBCore framework
