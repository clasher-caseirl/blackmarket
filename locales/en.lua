--- @module locales.en
--- @description English language; you can replace these or add a new language file.

return {

    init = {
        mod_missing = "Module not found: %s",
        mod_compile = "Module compile error in %s: %s",
        mod_runtime = "Module runtime error in %s: %s",
        mod_return = "Module %s did not return a table (got %s)",
        ns_blocked = "Attempted to modify locked namespace: core.%s",
        ns_ready = "%s namespace locked and ready",
    },

    db = {
        table_ready = "Database table ready",
        table_failed = "Failed to create or verify database table"
    },

    burner = {
        brand_name = "CELLTOWA",
        messages = {
            contact = "Yo you around?",
            sending = "Sending message...",
            sent = "Message sent...",
            received = "Message received...",
            received_menu = "Menu received...",
            response_busy = "Nah am busy..",
            response_cops = "Nah too hot rn",
            response_success = "Yh 22s menu inc",
            response_no_stock = "Out of stock rn",
            order_confirmed = "Say less loc inc",
            delivery_incoming = "Drops active chief",
            on_cooldown = "Hold up chief",
            no_active_order = "No order rn",
            item_not_found = "Item gone",
            rep_too_low = "Rep too low g",
            cannot_afford = "Not enough cash",
            no_space = "Bag full fam",
            payment_failed = "Payment failed",
            add_item_failed = "Item failed",
            no_method = "No delivery method",
            no_locations = "No locations available"
        }
    },

    deliveries = {
        no_locations_config = "No locations found for method: %s",
        no_handler = "No handler found for method: %s",
        started = "Delivery started: player %d, item %s, location %s",
        completed = "Delivery completed: %s received %dx %s",
        order_confirmed = "Order confirmed: %s ordered %dx %s for $%d delivery starting",
    },

    find_object = {
        invalid_source = "Invalid player source",
        player_not_found = "Player not found: %s",
        invalid_drop_id = "Invalid drop ID provided",
        drop_not_found = "Drop not found: %s",
        delivery_not_found = "Delivery not found: %s",
        invalid_ped = "Invalid player ped: %s",
        invalid_delivery_id = "Invalid delivery ID",
        invalid_location = "Invalid location data",
        invalid_spawn = "Invalid spawn coordinates",
        invalid_model = "Invalid model provided",
        wrong_owner = "Player %d attempted to complete delivery %s owned by player %d",
        start_failed_player = "Failed to start delivery %s: invalid player",
        complete_failed_player = "Failed to complete delivery %s: invalid player",
        complete_failed_ownership = "Failed to complete delivery %s for player %d: ownership validation failed",
        no_inventory_space = "Player %s has no space for %s",
        add_item_failed = "Failed to add item for player %s: %s",
        too_far = "Player %d too far from drop (%.2fm/%.2fm)",
        drop_created = "Drop created: %s for player %d",
        drops_synced_to = "Drops synced to player %d",
        pickup_validated = "Pickup validated: player %d, drop %s",
        pickup_completed = "Pickup completed: player %d, drop %s",
        drop_cleaned = "Drop cleaned up: %s (player %d disconnected)",
        request_failed_player = "Failed drops request from player %d: invalid player",
        validate_failed_player = "Failed pickup validation for player %d, drop %s: invalid player",
        validate_failed_drop = "Failed pickup validation for player %d, drop %s: drop not found",
        validate_failed_ownership = "Failed pickup validation for player %d, drop %s: ownership check failed",
        validate_failed_proximity = "Failed pickup validation for player %d, drop %s: too far",
        pickup_complete_failed_player = "Failed pickup complete for player %d, drop %s: invalid player",
        pickup_complete_failed_ownership = "Failed pickup complete for player %d, drop %s: ownership check failed",
        pickup_complete_failed_drop = "Failed pickup complete for player %d, drop %s: drop not found",
        store_failed_player = "Failed store for player %d, drop %s: invalid player",
        store_failed_invalid_id = "Failed store for player %d: invalid drop ID",
        store_failed_ownership = "Failed store for player %d, drop %s: ownership check failed",
        location_set = "Delivery location set: %s - Method: %s",
        drops_synced = "Drops synced to client",
        drop_added = "Drop added: %s",
        pickup_package = "Press ~INPUT_CONTEXT~ to pick up package",
        open_package = "Press ~INPUT_CONTEXT~ to open package",
        notifications = {
            header = "BLACKMARKET",
            not_your_drop = "This isn't your package",
            too_far_away = "You're too far from the package",
            items_received = "Received %dx %s",
            pickup_package = "Press ~INPUT_CONTEXT~ to pick up package",
            open_package = "Press ~INPUT_CONTEXT~ to open package"
        }
    },

    search_vehicle = {
        invalid_source = "Invalid player source",
        player_not_found = "Player not found: %s",
        invalid_vehicle_id = "Invalid vehicle ID provided",
        vehicle_not_found = "Vehicle not found: %s",
        delivery_not_found = "Delivery not found: %s",
        invalid_delivery_id = "Invalid delivery ID",
        invalid_location = "Invalid location data",
        invalid_spawn = "Invalid spawn coordinates",
        invalid_model = "Invalid model provided",
        wrong_owner = "Player %d attempted to complete delivery %s owned by player %d",
        start_failed_player = "Failed to start delivery %s: invalid player",
        spawn_failed = "Failed to spawn vehicle for delivery %s: model %s",
        complete_failed_player = "Failed to complete delivery %s: invalid player",
        complete_failed_ownership = "Failed to complete delivery %s for player %d: ownership validation failed",
        no_inventory_space = "Player %s has no space for %s",
        add_item_failed = "Failed to add item for player %s: %s",
        vehicle_created = "Vehicle created: %s for player %d",
        vehicle_cleaned = "Vehicle cleaned up: %s (player %d disconnected)",
        vehicle_unlocked = "Vehicle unlocked: player %d, vehicle %s",
        vehicle_unlocked_client = "Vehicle unlocked on client: %s",
        vehicle_deleted_delay = "Vehicle deleted after delay: %s",
        lockpick_failed_player = "Lockpick failed for player %d, vehicle %s: invalid player",
        lockpick_failed_vehicle = "Lockpick failed for player %d, vehicle %s: vehicle not found",
        lockpick_failed_ownership = "Lockpick failed for player %d, vehicle %s: ownership check failed",
        lockpick_started = "Lockpick started: player %d, vehicle %s",
        no_lockpick = "Player %d has no lockpick",
        search_locked = "Player %d attempted to search locked vehicle %s",
        location_set = "Delivery location set: %s - Method: %s",
        vehicle_added = "Vehicle added: %s",
        lockpick_vehicle = "Press ~INPUT_CONTEXT~ to lockpick vehicle",
        search_vehicle = "Press ~INPUT_CONTEXT~ to search vehicle",
        notifications = {
            header = "BLACKMARKET",
            items_received = "Received %dx %s",
            unlocked = "Vehicle unlocked",
            not_your_vehicle = "This isn't your vehicle",
            need_lockpick = "You need a lockpick",
            someone_stole = "Someone stole your delivery!"
        }
    }

}