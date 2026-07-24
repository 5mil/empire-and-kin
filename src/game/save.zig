const std = @import("std");
const economy = @import("economy.zig");
const crew = @import("crew.zig");

// Simple in-memory save slot for now (Phase 5 stub).
// Later this can write to a real file or use a proper serializer.

pub const SaveData = struct {
    day: u32,
    treasury: u32,
    influence: u32,
    crew_cash: u32,
    crew_morale: u8,
    crew_count: u8,
    valid: bool = false,
};

var slot: SaveData = .{
    .day = 0,
    .treasury = 0,
    .influence = 0,
    .crew_cash = 0,
    .crew_morale = 0,
    .crew_count = 0,
    .valid = false,
};

pub fn saveGame(eco: economy.Economy, c: crew.Crew) void {
    slot = .{
        .day = eco.day,
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
