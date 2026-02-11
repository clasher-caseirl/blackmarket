# Framework Integration (Hooks)

All QBCore integration happens in `custom/hooks.lua`. 
It was a competition requirement for things to be qb first, so instead of bloating the script with internal bridges or external dependencies, you have a single `hooks` file.

**One source of truth.** Change the hooks, it works anywhere.

Each hook is a wrapper around QBCore calls. If you switch frameworks:

1. Open `custom/hooks.lua`
2. Replace the QBCore calls with your framework's equivalents
3. Everything else works as-is

**QBCore Example:**
```lua
function hooks.can_afford(source, payment_method, payment_type, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return false end

    if payment_type == "balance" then
        return player.PlayerData.money[payment_method] >= amount
    end

    return false
end
```

**ESX Example:**
```lua
function hooks.can_afford(source, payment_method, payment_type, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if payment_type == "balance" then
        local account = xPlayer.getAccount(payment_method)
        return account and account.money >= amount or false
    end

    return false
end
```

**ND_Core Example:**
```lua
function hooks.can_afford(source, payment_method, payment_type, amount)
    local player = exports.ND_Core:getPlayer(source)
    if not player then return false end

    if payment_type == "balance" then
        if payment_method == "bank" then
            return player.bank >= amount
        elseif payment_method == "cash" then
            return player.cash >= amount
        end
    end

    return false
end
```

The logic stays the same across frameworks, get player, check their money. Just the function calls change.

For full examples of framework conversions, check [GRAFT - Framework Bridge](https://github.com/boiidevelopment/graft/blob/main/graft/fivem/bridges/framework.lua).