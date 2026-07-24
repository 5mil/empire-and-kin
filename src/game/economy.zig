const std = @import("std");
const city = @import("city.zig");
const crew = @import("crew.zig");

/// Real-time economy. All rates are per game-second.
pub const Economy = struct {
    treasury: u32,
    total_influence: u32,
    /// Accumulator for fractional income
    income_accum: f64 = 0.0,
    upkeep_accum: f64 = 0.0,
};

pub fn init() Economy {
    return .{
        .treasury = 2500,
        .total_influence = 0,
    };
}

/// Advance the economy by `dt` game-seconds.
/// Call this every frame (or on a fixed simulation step).
pub fn tick(eco: *Economy, districts: []city.District, c: *crew.Crew, dt: f64) void {
    // --- Income from rackets (per second) ---
    var income_per_sec: f64 = 0.0;
    for (districts) |d| {
        // dailyIncome is designed as a daily figure; convert to per-second
        const daily = @as(f64, @floatFromInt(city.dailyIncome(d)));
        income_per_sec += daily / 86400.0;
    }

    eco.income_accum += income_per_sec * dt;

    // --- Crew upkeep (per second) ---
    const upkeep_per_sec = @as(f64, @floatFromInt(c.count)) * 25.0 / 86400.0;
    eco.upkeep_accum += upkeep_per_sec * dt;

    // Settle whole dollars when accumulators are large enough
    if (eco.income_accum >= 1.0) {
        const gained: u32 = @intFromFloat(eco.income_accum);
        eco.income_accum -= @floatFromInt(gained);

        // Pay upkeep first
        if (eco.upkeep_accum >= 1.0) {
            const cost: u32 = @intFromFloat(eco.upkeep_accum);
            eco.upkeep_accum -= @floatFromInt(cost);

            if (gained >= cost) {
                const net = gained - cost;
                eco.treasury += net;
                c.cash += net / 4;
            } else {
                const shortfall = cost - gained;
                if (eco.treasury >= shortfall) {
                    eco.treasury -= shortfall;
                } else {
                    eco.treasury = 0;
                    if (c.morale > 5) c.morale -= 5 else c.morale = 0;
                }
            }
        } else {
            eco.treasury += gained;
            c.cash += gained / 4;
        }
    }

    // Influence grows slowly with average control
    var control_sum: u32 = 0;
    for (districts) |d| {
        control_sum += d.control;
    }
    if (districts.len > 0) {
        const avg_control = control_sum / districts.len;
        // Very slow influence gain kept simple for the stub
        _ = avg_control;
    }
}

pub fn statusReport(eco: Economy, c: crew.Crew, day: u32, hour: u32, minute: u32) void {
    std.debug.print("=== Day {d}  {d:0>2}:{d:0>2} ===\n", .{ day, hour, minute });
    std.debug.print("Treasury: ${d} | Crew Cash: ${d} | Morale: {d}\n", .{ eco.treasury, c.cash, c.morale });
    std.debug.print("Total Influence: {d}\n", .{eco.total_influence});
}
