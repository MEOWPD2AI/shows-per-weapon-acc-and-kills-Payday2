local values = MissedShotsTracker.values

Hooks:PostHook(StatisticsManager, "start_session", "start_session_missed_shots_tracker", function(self)
    MissedShotsTracker:reset_values()
end)

Hooks:PostHook(StatisticsManager, "shot_fired", "shot_fired_missed_shots_tracker", function(self, data)
    local shots_fired = self._global.session.shots_fired
    local total = shots_fired.total
    local hits = shots_fired.hits

    values.shots_missed = total - hits
    MissedShotsTracker:record_shot(data, total, hits)
    MissedShotsTracker:set_shots(values.shots_missed)
end)

-- "killed" only fires for the local player's own kills
Hooks:PostHook(StatisticsManager, "killed", "killed_missed_shots_tracker", function(self, data)
    MissedShotsTracker:record_kill(data)
end)
