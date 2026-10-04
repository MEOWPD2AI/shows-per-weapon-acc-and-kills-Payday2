--This might not be the best way to do this, but still better than before when i overrid it.

Hooks:PostHook(StageEndScreenGui, "init", "init_missed_shots_tracker", function(self, saferect_ws, fullrect_ws, statistics_data)
	local item = self._items[3] -- PERSONAL STATS
	item._main_panel:child(5):clear()

	item:set_stats({
		"total_downed",
		"hit_accuracy",
        "missed_shots",
		"total_kills",
		"total_specials_kills",
		"total_head_shots",
		"favourite_weapon",
		"civilians_killed_penalty"
	})

	if statistics_data then
		self:feed_statistics(statistics_data) --Maybe not important, but just to be sure.
	end
end)

local values = MissedShotsTracker.values
Hooks:PreHook(StageEndScreenGui, "feed_statistics", "feed_statistics_missed_shots_tracker", function(self, data)
   data.missed_shots = values.shots_missed
end)