const std = @import("std");
const city = @import("city.zig");
const crew = @import("crew.zig");

pub const EventType = enum {
    police_raid,
    informant,
    lucky_break,
    street_brawl,
    supply_shortage,
    dirty_cop,
};

pub const Event = struct {
    etype: EventType,
    title: []const u8,
    description: []const u8,
    heat_change: i8,
    cash_change: i32,
    morale_change: i8,
};

pub fn rollEvent(seed: u32) Event {
    // Simple deterministic roll based on seed
    const roll = seed % 6;
    return switch (roll) {
        0 => .{
            .etype = .police_raid,
            .title = "Police Raid",
            .description = "The bulls hit one of your joints. Heat rises and cash is seized.",
            .heat_change = 15,
            .cash_change = -200,
            .morale_change = -8,
        },
        1 => .{
            .etype = .informant,
            .title = "Informant Spotted",
            .description = "A rat is sniffing around. Loyalty takes a hit.",
            .heat_change = 8,
            .cash_change = 0,
            .morale_change = -12,
        },
        2 => .{
            .etype = .lucky_break,
            .title = "Lucky Break",
            .description = "A shipment slips through clean. Extra cash and lower heat.",
            .heat_change = -10,
            .cash_change = 350,
            .morale_change = 5,
        },
        3 => .{
            .etype = .street_brawl,
            .title = "Street Brawl",
            .description = "Your boys mix it up with rivals. Morale up, but someone got hurt.",
            .heat_change = 5,
            .cash_change = -50,
            .morale_change = 8,
        },
        4 => .{
            .etype = .supply_shortage,
            .title = "Supply Shortage",
            .description = "Bootleg supply dries up. Income takes a temporary hit.",
            .heat_change = 0,
            .cash_change = -150,
            .morale_change = -5,
        },
        else => .{
            .etype = .dirty_cop,
            .title = "Dirty Cop",
            .description = "A copper on the take offers protection... for a price.",
            .heat_change = -12,
            .cash_change = -180,
            .morale_change = 3,
        },
    };
}

pub fn applyEvent(e: Event, districts: []city.District, c: *crew.Crew, treasury: *u32) void {
    // Apply heat to a random-ish district (first one for simplicity)
    if (districts.len > 0) {
        if (e.heat_change > 0) {
            city.raiseHeat(&districts[0], @intCast(e.heat_change));
        } else if (e.heat_change < 0) {
            const reduce: u8 = @intCast(-e.heat_change);
            if (districts[0].heat > reduce) {
                districts[0].heat -= reduce;
            } else {
                districts[0].heat = 0;
            }
        }
    }

    // Cash
    if (e.cash_change > 0) {
        treasury.* += @intCast(e.cash_change);
    } else if (e.cash_change < 0) {
        const loss: u32 = @intCast(-e.cash_change);
        if (treasury.* >= loss) {
            treasury.* -= loss;
        } else {
            treasury.* = 0;
        }
    }

    // Morale
    if (e.morale_change > 0) {
        c.morale = @min(100, c.morale + @as(u8, @intCast(e.morale_change)));
    } else if (e.morale_change < 0) {
        const drop: u8 = @intCast(-e.morale_change);
        if (c.morale > drop) c.morale -= drop else c.morale = 0;
    }
}
