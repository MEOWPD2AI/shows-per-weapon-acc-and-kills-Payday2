if not MissedShotsTracker then
	_G.MissedShotsTracker = _G.MissedShotsTracker or {}
	MissedShotsTracker._path = ModPath
	MissedShotsTracker._data_path = SavePath .. "MissedShotsTracker.txt"
	MissedShotsTracker.default = {
		x = 0,
		y = 0,
		font_pack = 1, -- index in font_packs (1 = default game font)
		font_variant = 1, -- 1 small, 2 medium, 3 large
		text_color = 1, -- index in text_colors (1 = white)
		font_size = 20,
		show_table = true,
		show_counter = false,
		show_name = true,
		show_damage = true,
		damage_mode = 1, -- 1 total per weapon, 2 last hit, 3 current enemy
		show_type = false,
		only_equipped = true,
		table_x = 0,
		table_y = 0.05,
		bg = true,
		bg_opacity = 0.5,
		col_gap = 16,
		bg_padding = 4
	}
	MissedShotsTracker.settings = deep_clone(MissedShotsTracker.default)
	MissedShotsTracker.font_packs = {
		{ loc = "missed_shots_tracker_font_default", fonts = { "fonts/font_small_mf", "fonts/font_medium_mf", "fonts/font_large_mf" } },
		{ loc = "missed_shots_tracker_font_andy", fonts = { "fonts/mst_andy_small", "fonts/mst_andy_medium", "fonts/mst_andy_large" } },
		{ loc = "missed_shots_tracker_font_hemi_head", fonts = { "fonts/mst_hemi_head_small", "fonts/mst_hemi_head_medium", "fonts/mst_hemi_head_large" } },
		{ loc = "missed_shots_tracker_font_minecraft", fonts = { "fonts/mst_minecraft_small", "fonts/mst_minecraft_medium", "fonts/mst_minecraft_large" } },
		{ loc = "missed_shots_tracker_font_determination_mono", fonts = { "fonts/mst_determination_mono_small", "fonts/mst_determination_mono_medium", "fonts/mst_determination_mono_large" } },
		{ loc = "missed_shots_tracker_font_rpg_maker", fonts = { "fonts/mst_rpg_maker_small", "fonts/mst_rpg_maker_medium", "fonts/mst_rpg_maker_large" } },
	}
	MissedShotsTracker.font_variants = {
		"missed_shots_tracker_font_small",
		"missed_shots_tracker_font_medium",
		"missed_shots_tracker_font_large"
	}
	MissedShotsTracker.text_colors = {
		{ loc = "missed_shots_tracker_color_white", color = { 1, 1, 1 } },
		{ loc = "missed_shots_tracker_color_red", color = { 1, 0.2, 0.2 } },
		{ loc = "missed_shots_tracker_color_orange", color = { 1, 0.6, 0.1 } },
		{ loc = "missed_shots_tracker_color_yellow", color = { 1, 0.9, 0.2 } },
		{ loc = "missed_shots_tracker_color_green", color = { 0.3, 1, 0.3 } },
		{ loc = "missed_shots_tracker_color_cyan", color = { 0.2, 0.9, 1 } },
		{ loc = "missed_shots_tracker_color_blue", color = { 0.3, 0.5, 1 } },
		{ loc = "missed_shots_tracker_color_purple", color = { 0.7, 0.4, 1 } },
		{ loc = "missed_shots_tracker_color_pink", color = { 1, 0.5, 0.8 } },
		{ loc = "missed_shots_tracker_color_rainbow", rainbow = true },
	}
	MissedShotsTracker.text_color_items = {}
	for i, entry in ipairs(MissedShotsTracker.text_colors) do
		MissedShotsTracker.text_color_items[i] = entry.loc
	end
	MissedShotsTracker.font_pack_items = {}
	for i, pack in ipairs(MissedShotsTracker.font_packs) do
		MissedShotsTracker.font_pack_items[i] = pack.loc
	end

	-- Font helpers ---------------------------------------------------------
	-- The pack fonts are added by main.xml (BeardLib). If BeardLib is missing,
	-- or the game does not know a font, the default font is used instead.

	function MissedShotsTracker:font_exists(path)
		local ok, found = pcall(function()
			return DB:has(Idstring("font"), Idstring(path))
		end)
		return ok and found == true
	end

	-- Asks the game to load the font if it is not loaded yet; true when it is ready.
	function MissedShotsTracker:font_ready(path)
		local ok, ready = pcall(function()
			local dyn = managers.dyn_resource
			if not dyn then return false end
			local ids_font, ids_path = Idstring("font"), Idstring(path)
			local package = DynamicResourceManager.DYN_RESOURCES_PACKAGE
			if dyn:is_resource_ready(ids_font, ids_path, package) then
				return true
			end
			dyn:load(ids_font, ids_path, package, nil)
			return dyn:is_resource_ready(ids_font, ids_path, package)
		end)
		return ok and ready == true
	end

	-- Path of the font selected in the menu (FONT + FONT STYLE).
	function MissedShotsTracker:get_font()
		local settings = self.settings
		local fallback = self.font_packs[1].fonts[1]
		local pack = self.font_packs[settings.font_pack] or self.font_packs[1]
		local path = pack.fonts[settings.font_variant] or pack.fonts[1]
		if path == fallback then return path end
		if self:font_exists(path) and self:font_ready(path) then
			return path
		end
		return fallback
	end

	MissedShotsTracker.values = {
		shots_missed = 0,
		last_total = 0, -- last seen session totals, used to attribute shots per weapon
		last_hits = 0,
		weapons = {},   -- [weapon_id] = { kills, shots, hits, damage }
		order = {},     -- weapon ids in order of first use
		current_id = nil, -- weapon the player is holding right now
		target_key = nil, -- enemy hit most recently
		target_damage = 0 -- damage dealt to that enemy so far
	}

	-- Weapon id helpers ----------------------------------------------------

	function MissedShotsTracker:weapon_id(data)
		if not data then return nil end
		-- prefer the weapon unit; "name_id" is only a fallback
		local unit = data.weapon_unit
		if unit and alive(unit) then
			local ok, id = pcall(function()
				local base = unit:base()
				if base.get_name_id then
					return base:get_name_id()
				end
				return base._name_id or base.name_id
			end)
			if ok and type(id) == "string" then
				return id
			end
		end
		if type(data.name_id) == "string" then
			return data.name_id
		end
		return nil
	end

	-- Weapon type words removed from names when "show weapon type" is off
	-- (English names; longer phrases first).
	local TYPE_WORDS = {
		"light machine gun", "submachine gun", "sub-machine gun", "machine gun",
		"assault rifle", "battle rifle", "sniper rifle", "marksman rifle",
		"grenade launcher", "rocket launcher", "launcher",
		"shotgun", "revolver", "pistol", "carbine", "rifle",
		"special", "smg", "lmg", "dmr"
	}

	function MissedShotsTracker:strip_type(name)
		local out = name
		for _, phrase in ipairs(TYPE_WORDS) do
			local init = 1
			while true do
				local s, e = out:lower():find(phrase, init, true)
				if not s then break end
				-- only whole words (an optional plural "s" is removed too)
				if out:sub(e + 1, e + 1):lower() == "s" and not out:sub(e + 2, e + 2):find("%a") then
					e = e + 1
				end
				local before_ok = s == 1 or not out:sub(s - 1, s - 1):find("%a")
				local after_ok = e == #out or not out:sub(e + 1, e + 1):find("%a")
				if before_ok and after_ok then
					out = out:sub(1, s - 1) .. out:sub(e + 1)
					init = math.max(1, s - 1)
				else
					init = e + 1
				end
			end
		end
		out = (out:gsub("%s+", " "))
		out = (out:gsub("^[%s%-]+", ""))
		out = (out:gsub("[%s%-]+$", ""))
		if out == "" then return name end
		return out
	end

	function MissedShotsTracker:weapon_name(id)
		local ok, name = pcall(function()
			local tweak = tweak_data.weapon[id]
			local name_id = tweak and tweak.name_id
			if name_id and managers.localization:exists(name_id) then
				return managers.localization:text(name_id)
			end
		end)
		if not (ok and type(name) == "string") then
			name = id
		end
		if self.settings.show_type ~= true then
			name = self:strip_type(name)
		end
		return name
	end

	function MissedShotsTracker:get_weapon(id)
		local values = self.values
		local w = values.weapons[id]
		if not w then
			w = { kills = 0, shots = 0, hits = 0, damage = 0, last_hit = 0 }
			values.weapons[id] = w
			table.insert(values.order, id)
		end
		return w
	end

	-- Id of the weapon the local player is holding (nil if unknown).
	function MissedShotsTracker:equipped_weapon_id(inventory)
		local id
		pcall(function()
			if not inventory then
				local player = managers.player and managers.player:player_unit()
				if not alive(player) then return end
				inventory = player:inventory()
			end
			id = self:weapon_id({ weapon_unit = inventory:equipped_unit() })
			if not id then
				-- fallback: look the weapon up through the loadout
				local bm = managers.blackmarket
				local slot = inventory:equipped_selection() == 2 and bm:equipped_primary() or bm:equipped_secondary()
				id = slot and slot.weapon_id
			end
		end)
		return id
	end

	-- Adds the equipped weapon to the table (0 kills, 0/0) so it shows up
	-- before the first shot, and makes it the one the table displays.
	function MissedShotsTracker:register_equipped(inventory)
		local id = self:equipped_weapon_id(inventory)
		if not (id and tweak_data.weapon and tweak_data.weapon[id]) then return end

		self:get_weapon(id)
		if self.values.current_id ~= id then
			self.values.current_id = id
			log("[MissedShotsTracker] now using weapon: " .. tostring(id))
			if self.update_table then
				self:update_table()
			end
		end
	end

	function MissedShotsTracker:reset_values()
		local values = self.values
		values.shots_missed = 0
		values.last_total = 0
		values.last_hits = 0
		values.weapons = {}
		values.order = {}
		values.current_id = nil
		values.target_key = nil
		values.target_damage = 0
		if self.set_shots then
			self:set_shots(0)
		end
		self:register_equipped()
	end

	-- Called after every shot with the game's own session totals. The
	-- change since the last call is attributed to the weapon that fired,
	-- so we follow the game's counting rules (shotgun pellets etc.).
	function MissedShotsTracker:record_shot(data, total, hits)
		local values = self.values
		local d_total = total - values.last_total
		local d_hits = hits - values.last_hits
		values.last_total = total
		values.last_hits = hits

		if d_total < 0 or d_hits < 0 then
			-- the session counters were reset under us
			d_total, d_hits = total, hits
		end
		if d_total == 0 and d_hits == 0 then return end

		local id = self:weapon_id(data)
		if not id then return end

		values.current_id = id
		local w = self:get_weapon(id)
		w.shots = w.shots + d_total
		w.hits = w.hits + d_hits
	end

	-- Damage dealt by the local player's weapons. Hooked in two places
	-- (PlayerManager and CopDamage); each hit is only counted once.
	local seen_hits = setmetatable({}, { __mode = "k" })

	function MissedShotsTracker:record_damage(attack_data, victim)
		pcall(function()
			if type(attack_data) ~= "table" or seen_hits[attack_data] then return end
			local player = managers.player and managers.player:player_unit()
			if not alive(player) or attack_data.attacker_unit ~= player then return end
			if attack_data.variant == "melee" then return end

			local id = self:weapon_id({ weapon_unit = attack_data.weapon_unit })
			local dmg = tonumber(attack_data.damage)
			if not id or not (tweak_data.weapon and tweak_data.weapon[id]) or not dmg or dmg <= 0 then return end

			seen_hits[attack_data] = true
			local wpn = self:get_weapon(id)
			-- the game shows damage x10 compared to the internal value
			local scaled = dmg * 10
			wpn.damage = wpn.damage + scaled
			wpn.last_hit = scaled

			-- damage on the current enemy; starts over when a different enemy is hit
			local ok_key, key = pcall(function() return tostring(victim:key()) end)
			if ok_key and key then
				local values = self.values
				if values.target_key ~= key then
					values.target_key = key
					values.target_damage = 0
				end
				values.target_damage = values.target_damage + scaled
			end
			if self.update_table then
				self:update_table()
			end
		end)
	end

	function MissedShotsTracker:record_kill(data)
		if not data or data.variant == "melee" then return end
		local id = self:weapon_id(data)
		if not id or not (tweak_data.weapon and tweak_data.weapon[id]) then return end
		self:get_weapon(id).kills = self:get_weapon(id).kills + 1
		if self.update_table then
			self:update_table()
		end
	end

    function MissedShotsTracker:Load()
		local save_data
		if io.file_is_readable(self._data_path) then
			save_data = io.load_as_json(self._data_path)
		end
		if save_data then
			for k, v in pairs(save_data) do
				self.settings[k] = v
			end
		end

		-- font settings from older versions are no longer used
		self.settings.saved_font = nil
		self.settings.font = nil
		self.settings.custom_font = nil
		if not self.font_packs[self.settings.font_pack] then self.settings.font_pack = 1 end
		if not self.font_variants[self.settings.font_variant] then self.settings.font_variant = 1 end
		if not self.text_colors[self.settings.text_color] then self.settings.text_color = 1 end
    end
    
    function MissedShotsTracker:Save()
        local file = io.open(self._data_path, "w+")
        if file then
			file:write(json.encode(self.settings))
            file:close()
        end
    end

    Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_missed_shots_tracker", function(loc)
		loc:load_localization_file(MissedShotsTracker._path .. "loc/english.json")
	end)

	Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_missed_shots_tracker", function()
		MissedShotsTracker:get_font()
	end)
    
end

MissedShotsTracker:Load()

local required = {}
if RequiredScript and not required[RequiredScript] then
	local fname = MissedShotsTracker._path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	required[RequiredScript] = true
end