--- @module src.server.modules.database
--- @description Handles all database functions for blackmarket reputation system

local db = {}

--- Initializes the blackmarket_reputation database table
function db.init()
    local query = [[
        CREATE TABLE IF NOT EXISTS `blackmarket_reputation` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(255) NOT NULL,
            `reputation` INT NOT NULL DEFAULT 0,
            `items_bought` INT NOT NULL DEFAULT 0,
            `total_paid` INT NOT NULL DEFAULT 0,
            `last_update` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier_unique` (`identifier`),
            KEY `identifier_idx` (`identifier`),
            KEY `reputation_idx` (`reputation`)
        ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]]

    MySQL.Async.execute(query, {}, function(result)
        if result then
            log("success", translate("db.table_ready"))
        else
            log("error", translate("db.table_failed"))
        end
    end)
end

--- Get player reputation data
--- @param identifier string: Players unique char id `citizenid` `stateId` `identifier` etc
--- @return table: Player reputation record
function db.get_reputation(identifier)
    local query = "SELECT * FROM blackmarket_reputation WHERE identifier = ?"
    return MySQL.query.await(query, {identifier})
end

--- Update player reputation
--- @param identifier string: Players unique char id `citizenid` `stateId` `identifier` etc
--- @return boolean: Success status
function db.update_reputation(identifier, reputation, items_bought, total_paid)
    local query = "UPDATE blackmarket_reputation SET reputation = ?, items_bought = ?, total_paid = ? WHERE identifier = ?"
    return MySQL.update.await(query, {reputation, items_bought, total_paid, identifier})
end

--- Create new reputation record
--- @param identifier string: Players unique char id `citizenid` `stateId` `identifier` etc
--- @return boolean: Success status
function db.create_reputation(identifier)
    local query = "INSERT INTO blackmarket_reputation (identifier) VALUES (?)"
    return MySQL.insert.await(query, {identifier})
end

return db