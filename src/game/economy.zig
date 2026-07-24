const std = @import("std");
const city = @import("city.zig");
const crew = @import("crew.zig");

pub const Economy = struct {
    day: u32,
    treasury: u32,
    total_influence: u32,
};

pub fn init() Economy {
    return .{
        .day = 1,
        .treasury = 2500,
        .total_influence = 0,
    };
}

pub fn dailyTick(eco: *Economy, districts: []city.District, c: *crew.Crew) void {
    // Collect racket income from all districts
    var income: u32 = 0;
    for (districts) |d| {
        income += city.dailyIncome(d);
    }

    // Crew upkeep
    const upkeep: u32 = @as(u32, c.count) * 25;
    if (income >= upkeep) {
        income -= upkeep;
    } else {
        // Forced to dip into treasury
        const shortfall = upkeep - income;
        if (eco.treasury >= shortfall) {
            eco.treasury -= shortfall;
            income = 0;
        } else {
            income = 0;
            eco.treasury = 0;
            // Low funds hurt morale
            if (c.morale > 10) c.morale -= 10 else c.morale = 0;
        }
    }

    eco.treasury += income;
    c.cash += income / 4; // crew share

    // Influence grows slowly with control
    var influence_gain: u32 = 0;
    for (districts) |d| {
        influence_gain += d.control / 10;
    }
    eco.total_influence += influence_gain;

    eco.day += 1;
}

pub fn statusReport(eco: Economy, c: crew.Crew) void {
    std.debug.print("=== Day {d} ===\n", .{eco.day});
    std.debug.print("Treasury: ${d} | Crew Cash: ${d} | Morale: {d}\n", .{ eco.treasury, c.cash, c.morale });
    std.debug.print("Total Influence: {d}\n", .{eco.total_influence});
}
