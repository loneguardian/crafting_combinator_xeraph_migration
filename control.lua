local save_queue = {}
local store_state = function()
    if global.data_ready then return end
    -- attempt to get remote from crafting_combinator
    if remote.interfaces["crafting_combinator"] then
        global.migrated_state = remote.call("crafting_combinator", "get_migration_data")
        -- log(serpent.block(global.migrated_state, {keyignore = {__metatable = true, __self = true, chest = true, module_chest = true}}))
        -- set migrate_status to ready
        global.data_ready = true
        save_queue[1] = 1
    end
end

script.on_init(
    function()
        global.status = 1 -- [1] - init, [2] - saved step 1, [3] - saved step 2
        global.data_ready = false
        store_state()
    end
)

script.on_event(defines.events.on_tick,
    function()
        if save_queue[1] then
            if save_queue[1] == 1 then
                game.auto_save("Crafting Combinator Migration Step 1")
                game.print("--------------------------------------------------------------------")
                game.print("Crafting Combinator migration Step 1 completed, please use the generated auto-save to complete Step 2")
                game.print("Saved as: _autosave-Crafting Combinator Migration Step 1.zip")
                game.print("Next steps: disable the original crafting combinator mod -> enable Xeraph's fork -> load Step 1.zip")
                global.status = 2
            else
                game.auto_save("Crafting Combinator Migration Step 2")
                game.print("--------------------------------------------------------------------")
                game.print("Crafting Combinator migration Step 2 completed, please use the generated auto-save to complete Step 3")
                game.print("Saved as: _autosave-Crafting Combinator Migration Step 2.zip")
                game.print("Next steps: disable migration mod -> load Step 2.zip -> save as new file -> Migration complete")
                global.status = 3
            end
            table.remove(save_queue, 1)
        end
    end
)

-- create interface
remote.add_interface(
    "crafting_combinator_xeraph_migration",
    {
        get_migrated_state = function()
            if global.data_ready and global.status == 2 then
                return global.migrated_state
            end
        end,
        complete_migration = function()
            save_queue[1] = 2
        end
    }
)