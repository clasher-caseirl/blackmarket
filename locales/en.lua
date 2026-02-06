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
        table_ready = "brewing_batches database table ready",
        table_failed = "Failed to create or verify brewing_batches database table"
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
            delivery_incoming = "Drops active chief"
        }
    }

}