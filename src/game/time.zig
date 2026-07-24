const std = @import("std");

/// Simple real-time simulation clock.
/// Game time can run faster than real time (time_scale).
pub const Clock = struct {
    /// Total simulated seconds since game start
    elapsed: f64 = 0.0,
    /// Multiplier (1.0 = real-time, 60.0 = 1 real second = 1 game minute, etc.)
    time_scale: f64 = 1.0,
    /// Current game day (starts at 1)
    day: u32 = 1,
    /// Seconds into the current day (0 .. 86400)
    time_of_day: f64 = 8.0 * 3600.0, // start at 8:00 AM

    pub fn tick(self: *Clock, dt_real: f64) void {
        const dt_game = dt_real * self.time_scale;
        self.elapsed += dt_game;
        self.time_of_day += dt_game;

        // Advance day
        while (self.time_of_day >= 86400.0) {
            self.time_of_day -= 86400.0;
            self.day += 1;
        }
    }

    pub fn hour(self: Clock) u32 {
        return @intFromFloat(self.time_of_day / 3600.0);
    }

    pub fn minute(self: Clock) u32 {
        const mins = self.time_of_day / 60.0;
        return @as(u32, @intFromFloat(mins)) % 60;
    }
};
