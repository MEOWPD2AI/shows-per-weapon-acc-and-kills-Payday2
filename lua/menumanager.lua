local settings = MissedShotsTracker.settings

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusMissedShotsTracker", function(menu_manager, nodes)
    MissedShotsTracker:Load()

    local main_menu_id = "missed_shots_tracker_MAIN"

    MenuHelper:NewMenu(main_menu_id)

    local function refresh(restyle)
        -- the HUD functions only exist once the HUD script has loaded (in a heist),
        -- so in the main menu there is nothing to refresh, only to save
        if restyle then
            if MissedShotsTracker.apply_style then
                MissedShotsTracker:apply_style()
            end
        elseif MissedShotsTracker.update_table then
            MissedShotsTracker:update_table()
        end
        MissedShotsTracker:Save()
    end

    -- "Shots missed" line
    function MenuCallbackHandler:callback_missed_shots_tracker_y(item)
        settings.y = item:value()
        refresh(true)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_x(item)
        settings.x = item:value()
        refresh(true)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_show_damage(item)
        settings.show_damage = item:value() == "on"
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_damage_mode(item)
        settings.damage_mode = item:value()
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_show_type(item)
        settings.show_type = item:value() == "on"
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_show_name(item)
        settings.show_name = item:value() == "on"
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_show_counter(item)
        settings.show_counter = item:value() == "on"
        refresh(false)
    end

    -- per-weapon table
    function MenuCallbackHandler:callback_missed_shots_tracker_table_x(item)
        settings.table_x = item:value()
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_table_y(item)
        settings.table_y = item:value()
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_show_table(item)
        settings.show_table = item:value() == "on"
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_only_equipped(item)
        settings.only_equipped = item:value() == "on"
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_col_gap(item)
        settings.col_gap = item:value()
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_bg_padding(item)
        settings.bg_padding = item:value()
        refresh(false)
    end

    -- background
    function MenuCallbackHandler:callback_missed_shots_tracker_bg(item)
        settings.bg = item:value() == "on"
        refresh(false)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_bg_opacity(item)
        settings.bg_opacity = item:value()
        refresh(false)
    end

    -- font
    function MenuCallbackHandler:callback_missed_shots_tracker_font_size(item)
        settings.font_size = item:value()
        refresh(true)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_fonts(item)
        settings.font_pack = item:value()
        refresh(true)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_font_variant(item)
        settings.font_variant = item:value()
        refresh(true)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_text_color(item)
        settings.text_color = item:value()
        refresh(true)
    end

    function MenuCallbackHandler:callback_missed_shots_tracker_reset(item)
        -- write into the shared table; rebinding the local would not reset anything
        for k, v in pairs(MissedShotsTracker.default) do
            settings[k] = v
        end

        local items_table = {
            ["missed_shots_tracker_fonts"] = settings.font_pack,
            ["missed_shots_tracker_font_variant"] = settings.font_variant,
            ["missed_shots_tracker_font_size"] = settings.font_size,
            ["missed_shots_tracker_text_color"] = settings.text_color,
            ["missed_shots_tracker_x"] = settings.x,
            ["missed_shots_tracker_y"] = settings.y,
            ["missed_shots_tracker_show_table"] = settings.show_table and "on" or "off",
            ["missed_shots_tracker_only_equipped"] = settings.only_equipped and "on" or "off",
            ["missed_shots_tracker_show_damage"] = settings.show_damage and "on" or "off",
            ["missed_shots_tracker_damage_mode"] = settings.damage_mode,
            ["missed_shots_tracker_show_type"] = settings.show_type and "on" or "off",
            ["missed_shots_tracker_show_name"] = settings.show_name and "on" or "off",
            ["missed_shots_tracker_show_counter"] = settings.show_counter and "on" or "off",
            ["missed_shots_tracker_table_x"] = settings.table_x,
            ["missed_shots_tracker_table_y"] = settings.table_y,
            ["missed_shots_tracker_bg"] = settings.bg and "on" or "off",
            ["missed_shots_tracker_bg_opacity"] = settings.bg_opacity,
            ["missed_shots_tracker_col_gap"] = settings.col_gap,
            ["missed_shots_tracker_bg_padding"] = settings.bg_padding
        }

        for _, v in pairs(item._parameters.gui_node.row_items) do
            local _item = v.item
            local value = items_table[_item._parameters.name]
            if value ~= nil and _item.set_value then
                _item:set_value(value)
            end
        end

        refresh(true)
    end

    MenuHelper:AddMultipleChoice({
        id = "missed_shots_tracker_fonts",
        title = "missed_shots_tracker_fonts_title",
        desc = "missed_shots_tracker_fonts_desc",
        callback = "callback_missed_shots_tracker_fonts",
        items = MissedShotsTracker.font_pack_items,
        value = settings.font_pack,
        menu_id = main_menu_id,
        priority = 21
    })

    MenuHelper:AddMultipleChoice({
        id = "missed_shots_tracker_font_variant",
        title = "missed_shots_tracker_font_variant_title",
        desc = "missed_shots_tracker_font_variant_desc",
        callback = "callback_missed_shots_tracker_font_variant",
        items = MissedShotsTracker.font_variants,
        value = settings.font_variant,
        menu_id = main_menu_id,
        priority = 20
    })

    MenuHelper:AddDivider({
        id = "missed_shots_tracker_fonts_divider",
        size = 16,
        menu_id = main_menu_id,
        priority = 19
    })

    MenuHelper:AddSlider({
        id = "missed_shots_tracker_font_size",
        title = "missed_shots_tracker_size_title",
        description = "missed_shots_tracker_size_desc",
        callback = "callback_missed_shots_tracker_font_size",
        value = settings.font_size,
        min = 0,
        max = 100,
        step = 0.1,
        show_value = true,
        menu_id = main_menu_id,
        priority = 18
    })

    MenuHelper:AddMultipleChoice({
        id = "missed_shots_tracker_text_color",
        title = "missed_shots_tracker_text_color_title",
        desc = "missed_shots_tracker_text_color_desc",
        callback = "callback_missed_shots_tracker_text_color",
        items = MissedShotsTracker.text_color_items,
        value = settings.text_color,
        menu_id = main_menu_id,
        priority = 17.5
    })

    MenuHelper:AddDivider({
        id = "missed_shots_tracker_fonts_size_divider",
        size = 16,
        menu_id = main_menu_id,
        priority = 17
    })

    MenuHelper:AddToggle({
        id = "missed_shots_tracker_show_counter",
        title = "missed_shots_tracker_counter_title",
        desc = "missed_shots_tracker_counter_desc",
        callback = "callback_missed_shots_tracker_show_counter",
        value = settings.show_counter == true,
        menu_id = main_menu_id,
        priority = 16.5
    })

    MenuHelper:AddSlider({
        id = "missed_shots_tracker_x",
        title = "Counter X",
        callback = "callback_missed_shots_tracker_x",
        value = settings.x,
        min = 0,
        max = 0.91,
        step = 0.01,
        show_value = true,
        menu_id = main_menu_id,
        priority = 16,
        localized = false
    })

    MenuHelper:AddSlider({
        id = "missed_shots_tracker_y",
        title = "Counter Y",
        callback = "callback_missed_shots_tracker_y",
        value = settings.y,
        min = 0,
        max = 0.97,
        step = 0.01,
        show_value = true,
        menu_id = main_menu_id,
        priority = 15,
        localized = false
    })

    MenuHelper:AddDivider({
        id = "missed_shots_tracker_counter_divider",
        size = 16,
        menu_id = main_menu_id,
        priority = 14
    })

    MenuHelper:AddToggle({
        id = "missed_shots_tracker_show_table",
        title = "missed_shots_tracker_table_title",
        desc = "missed_shots_tracker_table_desc",
        callback = "callback_missed_shots_tracker_show_table",
        value = settings.show_table ~= false,
        menu_id = main_menu_id,
        priority = 13
    })

    MenuHelper:AddToggle({
        id = "missed_shots_tracker_show_damage",
        title = "missed_shots_tracker_damage_title",
        desc = "missed_shots_tracker_damage_desc",
        callback = "callback_missed_shots_tracker_show_damage",
        value = settings.show_damage ~= false,
        menu_id = main_menu_id,
        priority = 12.9
    })

    MenuHelper:AddMultipleChoice({
        id = "missed_shots_tracker_damage_mode",
        title = "missed_shots_tracker_damage_mode_title",
        desc = "missed_shots_tracker_damage_mode_desc",
        callback = "callback_missed_shots_tracker_damage_mode",
        items = {
            "missed_shots_tracker_dmg_mode_total",
            "missed_shots_tracker_dmg_mode_hit",
            "missed_shots_tracker_dmg_mode_enemy"
        },
        value = settings.damage_mode or 1,
        menu_id = main_menu_id,
        priority = 12.85
    })

    MenuHelper:AddToggle({
        id = "missed_shots_tracker_show_type",
        title = "missed_shots_tracker_type_title",
        desc = "missed_shots_tracker_type_desc",
        callback = "callback_missed_shots_tracker_show_type",
        value = settings.show_type == true,
        menu_id = main_menu_id,
        priority = 12.8
    })

    MenuHelper:AddToggle({
        id = "missed_shots_tracker_show_name",
        title = "missed_shots_tracker_name_title",
        desc = "missed_shots_tracker_name_desc",
        callback = "callback_missed_shots_tracker_show_name",
        value = settings.show_name ~= false,
        menu_id = main_menu_id,
        priority = 12.7
    })

    MenuHelper:AddToggle({
        id = "missed_shots_tracker_only_equipped",
        title = "missed_shots_tracker_equipped_title",
        desc = "missed_shots_tracker_equipped_desc",
        callback = "callback_missed_shots_tracker_only_equipped",
        value = settings.only_equipped ~= false,
        menu_id = main_menu_id,
        priority = 12.5
    })

    MenuHelper:AddSlider({
        id = "missed_shots_tracker_table_x",
        title = "Table X",
        callback = "callback_missed_shots_tracker_table_x",
        value = settings.table_x,
        min = 0,
        max = 0.91,
        step = 0.01,
        show_value = true,
        menu_id = main_menu_id,
        priority = 12,
        localized = false
    })

    MenuHelper:AddSlider({
        id = "missed_shots_tracker_table_y",
        title = "Table Y",
        callback = "callback_missed_shots_tracker_table_y",
        value = settings.table_y,
        min = 0,
        max = 0.97,
        step = 0.01,
        show_value = true,
        menu_id = main_menu_id,
        priority = 11,
        localized = false
    })

    MenuHelper:AddSlider({
        id = "missed_shots_tracker_col_gap",
        title = "Column spacing",
        callback = "callback_missed_shots_tracker_col_gap",
        value = settings.col_gap,
        min = 0,
        max = 60,
        step = 1,
        show_value = true,
        menu_id = main_menu_id,
        priority = 10.5,
        localized = false
    })

    MenuHelper:AddDivider({
        id = "missed_shots_tracker_table_divider",
        size = 16,
        menu_id = main_menu_id,
        priority = 10
    })

    MenuHelper:AddToggle({
        id = "missed_shots_tracker_bg",
        title = "missed_shots_tracker_bg_title",
        desc = "missed_shots_tracker_bg_desc",
        callback = "callback_missed_shots_tracker_bg",
        value = settings.bg ~= false,
        menu_id = main_menu_id,
        priority = 9
    })

    MenuHelper:AddSlider({
        id = "missed_shots_tracker_bg_opacity",
        title = "Background opacity",
        callback = "callback_missed_shots_tracker_bg_opacity",
        value = settings.bg_opacity,
        min = 0,
        max = 1,
        step = 0.05,
        show_value = true,
        menu_id = main_menu_id,
        priority = 8,
        localized = false
    })

    MenuHelper:AddSlider({
        id = "missed_shots_tracker_bg_padding",
        title = "Background padding",
        callback = "callback_missed_shots_tracker_bg_padding",
        value = settings.bg_padding,
        min = 0,
        max = 20,
        step = 1,
        show_value = true,
        menu_id = main_menu_id,
        priority = 7.5,
        localized = false
    })

    MenuHelper:AddDivider({
        id = "missed_shots_tracker_reset_divider",
        size = 16,
        menu_id = main_menu_id,
        priority = 1
    })

    MenuHelper:AddButton({
        id = "missed_shots_tracker_reset",
        title = "RESET",
        callback = "callback_missed_shots_tracker_reset",
        menu_id = main_menu_id,
        priority = 0,
        localized = false
    })

    nodes[main_menu_id] = MenuHelper:BuildMenu(main_menu_id, { area_bg = "none" })
    MenuHelper:AddMenuItem(nodes["blt_options"], main_menu_id, "missed_shots_tracker_menu", "missed_shots_tracker_menu_desc")

end)
