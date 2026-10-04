-- Checks a few times a second which weapon the local player is holding, so
-- it is registered as soon as it is equipped (and on every weapon switch).
local last_check = 0

Hooks:PostHook(PlayerManager, "update", "update_missed_shots_tracker", function(self, t, dt)
    if t >= last_check and t - last_check < 0.25 then return end
    last_check = t
    MissedShotsTracker:register_equipped()
end)

-- damage dealt by the local player (the hit is de-duplicated in record_damage)
Hooks:PostHook(PlayerManager, "on_damage_dealt", "on_damage_dealt_missed_shots_tracker", function(self, unit, damage_info)
    MissedShotsTracker:record_damage(damage_info, unit)
end)
