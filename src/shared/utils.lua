--- Chains SetTimeouts for simulating text chains on phone
--- @param actions table: Table of delays and functions to chain through SetTimeout
function core.timeout_chain(actions)
    local index = 1
    local function next_action()
        if index > #actions then return end
        local action = actions[index]
        index = index + 1
        SetTimeout(action.delay, function()
            action.fn()
            next_action()
        end)
    end
    next_action()
end