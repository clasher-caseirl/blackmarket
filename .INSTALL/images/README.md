# Item Lists

Add the following items to your inventory system.

## QBCore
```lua
blackmarket_phone = { name = "blackmarket_phone", label = "burner", weight = 250, type = "item", image = "blackmarket_phone.png", unique = true, useable = true, shouldClose = true, combinable = nil, description = "A burner phone.. looks like it only has one contact..." },
```

## OX Inventory
```lua
["blackmarket_phone"] = {
    label = "Burner",
    weight = 250,
    stack = false,
    close = true,
    description = "A burner phone.. looks like it only has one contact...",
    client = {
        export = 'blackmarket.blackmarket_phone'
    }
}
```