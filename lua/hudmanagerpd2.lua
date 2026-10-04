local COLUMNS = {
	{ id = "name", title = "Name" },
	{ id = "kills", title = "Kills" },
	{ id = "damage", title = "Damage" },
	{ id = "shots", title = "Hits/Shots" },
	{ id = "acc", title = "Acc%" }
}

local DAMAGE_TITLES = { "Damage", "Hit", "Enemy" }

local function with_commas(n)
	local s = tostring(math.floor(n + 0.5))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (out:gsub("^,", ""))
end

-- Fully saturated colour for a hue in 0..1 (used by the rainbow mode).
local function hue_color(h)
	h = (h % 1) * 6
	local i = math.floor(h)
	local f = h - i
	local q = 1 - f
	if i == 0 then return Color(1, f, 0)
	elseif i == 1 then return Color(q, 1, 0)
	elseif i == 2 then return Color(0, 1, f)
	elseif i == 3 then return Color(0, q, 1)
	elseif i == 4 then return Color(f, 0, 1)
	end
	return Color(1, 0, q)
end

function MissedShotsTracker:init()
	local settings = self.settings
	if managers.hud ~= nil then
		self.hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		local panel = self.hud.panel

		-- backgrounds are created first and sit on layer 0, texts on layer 1
		self.bg_text = panel:rect({ color = Color.black, alpha = settings.bg_opacity, layer = 0, visible = false })
		self.bg_table = panel:rect({ color = Color.black, alpha = settings.bg_opacity, layer = 0, visible = false })

		self.text = panel:text({
			vertical = "top",
			align = "left",
			blend_mode = "normal",
			y = settings.y * panel:height(),
			layer = 1,
			text = "Shots missed: " .. tostring(self.values.shots_missed),
			font = self:get_font(),
			font_size = settings.font_size,
			x = settings.x * panel:width(),
			color = Color.white
		})

		self.columns = {}
		for _, col in ipairs(COLUMNS) do
			self.columns[col.id] = panel:text({
				vertical = "top",
				align = "left",
				blend_mode = "normal",
				layer = 1,
				text = "",
				font = self:get_font(),
				font_size = settings.font_size,
				color = Color.white,
				visible = false
			})
		end
		self:apply_color()
		self:register_equipped()
		self:update_table()
	end
end

function MissedShotsTracker:set_shots(amount)
	if not alive(self.text) then return end
	local text = string.format("Shots missed: %s", amount)
	self.text:set_text(text)
	self:update_table()
end

-- Lays out the "Shots missed" line, the per-weapon table and their backgrounds.
function MissedShotsTracker:update_table()
	if not alive(self.text) then return end

	local settings = self.settings
	local values = self.values
	local panel = self.hud.panel
	local bg_on = settings.bg ~= false
	local alpha = settings.bg_opacity or 0.5
	local show_counter = settings.show_counter == true
	local PAD = settings.bg_padding or 4

	self.text:set_visible(show_counter)

	-- background behind the "Shots missed" line
	if alive(self.bg_text) then
		local _, _, w, h = self.text:text_rect()
		self.bg_text:set_alpha(alpha)
		self.bg_text:set_size(w + PAD * 2, h + PAD * 2)
		self.bg_text:set_position(self.text:x() - PAD, self.text:y() - PAD)
		self.bg_text:set_visible(bg_on and show_counter)
	end

	if not self.columns then return end

	local ids = values.order
	if settings.only_equipped ~= false and values.current_id then
		ids = { values.current_id }
	end
	local show = settings.show_table ~= false and #ids > 0

	local lines = {}
	for _, col in ipairs(COLUMNS) do
		lines[col.id] = { col.title }
	end
	local mode = settings.damage_mode or 1
	lines.damage[1] = DAMAGE_TITLES[mode] or "Damage"

	for _, id in ipairs(ids) do
		local wpn = values.weapons[id]
		table.insert(lines.name, self:weapon_name(id))
		table.insert(lines.kills, tostring(wpn.kills))
		local dmg = wpn.damage or 0
		if mode == 2 then
			dmg = wpn.last_hit or 0
		elseif mode == 3 then
			dmg = values.target_damage or 0
		end
		table.insert(lines.damage, with_commas(dmg))
		table.insert(lines.shots, string.format("%d/%d", wpn.hits, wpn.shots))
		table.insert(lines.acc, wpn.shots > 0 and string.format("%.2f%%", wpn.hits / wpn.shots * 100) or "-")
	end

	local x0 = settings.table_x * panel:width()
	local y0 = settings.table_y * panel:height()
	local x = x0
	local max_h = 0
	local gap = settings.col_gap or 16

	for _, col in ipairs(COLUMNS) do
		local t = self.columns[col.id]
		if alive(t) and ((col.id == "name" and settings.show_name == false) or (col.id == "damage" and settings.show_damage == false)) then
			t:set_visible(false)
		elseif alive(t) then
			t:set_text(table.concat(lines[col.id], "\n"))
			t:set_visible(show)
			local _, _, w, h = t:text_rect()
			t:set_size(w, h)
			t:set_position(x, y0)
			x = x + w + gap
			max_h = math.max(max_h, h)
		end
	end

	if alive(self.bg_table) then
		self.bg_table:set_alpha(alpha)
		self.bg_table:set_size((x - gap - x0) + PAD * 2, max_h + PAD * 2)
		self.bg_table:set_position(x0 - PAD, y0 - PAD)
		self.bg_table:set_visible(show and bg_on)
	end
end

-- Applies the selected text colour; rainbow cycles through hues over time.
function MissedShotsTracker:apply_color()
	if not alive(self.text) then return end
	local entry = self.text_colors[self.settings.text_color] or self.text_colors[1]

	local objects = { self.text }
	for _, col in ipairs(COLUMNS) do
		local t = self.columns and self.columns[col.id]
		if alive(t) then
			table.insert(objects, t)
		end
	end

	for i, obj in ipairs(objects) do
		obj:stop()
		if entry.rainbow then
			local offset = (i - 1) * 0.12 -- neighbouring columns get different hues
			obj:animate(function(o)
				local t = 0
				while true do
					o:set_color(hue_color(t * 0.25 + offset))
					t = t + (coroutine.yield() or 0)
				end
			end)
		else
			obj:set_color(Color(entry.color[1], entry.color[2], entry.color[3]))
		end
	end
end

-- Re-applies font, size and position to every text object.
function MissedShotsTracker:apply_style()
	local settings = self.settings
	if not alive(self.text) then return end
	local font = Idstring(self:get_font())
	self.text:set_font(font)
	self.text:set_font_size(settings.font_size)
	self.text:set_position(settings.x * self.hud.panel:width(), settings.y * self.hud.panel:height())
	for _, t in pairs(self.columns or {}) do
		if alive(t) then
			t:set_font(font)
			t:set_font_size(settings.font_size)
		end
	end
	self:apply_color()
	self:update_table()
end

Hooks:PostHook(HUDManager, "_player_hud_layout", "MissedShotsTracker", function(self)
	MissedShotsTracker:init()
end)
