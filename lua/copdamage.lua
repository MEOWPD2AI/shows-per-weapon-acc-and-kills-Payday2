-- second source for damage events; duplicates are ignored in record_damage
Hooks:PostHook(CopDamage, "_on_damage_received", "on_damage_received_missed_shots_tracker", function(self, damage_info)
    MissedShotsTracker:record_damage(damage_info, self._unit)
end)
