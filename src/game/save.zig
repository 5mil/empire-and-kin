const std = @import("std");
const economy = @import("economy.zig");
const crew = @import("crew.zig");
const time = @import("time.zig");

// Simple in-memory save slot.
// Later this can write to a real file or use a proper serializer.

pub const SaveData = struct {
    day: u32,
    time_of_day: f64,
    treasury: u32,
    influence: u32,
    crew_cash: u32,
    crew_morale: u8,
    crew_count: u8,
    valid: bool = false,
};

var slot: SaveData = .{
    .day = 0,
    .time_of_day = 0,
    .treasury = 0,
    .influence = 0,
    .crew_cash = 0,
    .crew_morale = 0,
    .crew_count = 0,
    .valid = false,
};

pub fn saveGame(eco: economy.Economy, c: crew.Crew, clock: time.Clock) void {
    slot = .{
        .day = clock.day,
        .time_of_day = clock.time_of_day,
        .treasury = eco.treasury,
        .influence = eco.total_influence,
        .crew_cash = c.cash,
        .crew_morale = c.morale,
        .crew_count = c.count,
        .valid = true,
    };
}

pub fn loadGame() ?SaveData {
    if (!slot.valid) return null;
    return slot;
}

pub fn hasSave() bool {
    return slot.valid;
}

pub fn clearSave() void {
    slot.valid = false;
}
