const std = @import("std");
const backend = @import("backend.zig");
const action = @import("../game/action.zig");
const player = @import("../game/player.zig");
const input = @import("input.zig");

/// A5 — street combat encounter feedback

pub const CombatUI = struct {
    encounter: action.Encounter = .{},
    cooldown: f64 = 0,
    last_msg: []const u8 = "",
};

pub fn maybeSpawn(cui: *CombatUI, p: player.Player, district_heat: u8, seed: u32) void {
    if (cui.encounter.active) return;
    if (district_heat < 50) return;
    if (seed % 17 != 0) return;
    action.startEncounter(&cui.encounter, "Rival Enforcer", 28, 10, 4);
    cui.last_msg = "Street fight! [F] attack";
    _ = p;
}

pub fn tick(cui: *CombatUI, p: *player.Player, dt: f64, attacking: bool) void {
    if (!cui.encounter.active) return;
    action.combatTick(&cui.encounter, p, dt, attacking);
    if (!cui.encounter.active) {
        cui.last_msg = "Enemy down.";
    } else if (p.health == 0) {
        cui.last_msg = "You went down.";
        cui.encounter.active = false;
    }
}

pub fn draw(gfx: backend.Backend, cui: CombatUI) void {
    if (!cui.encounter.active and cui.last_msg.len == 0) return;
    if (cui.encounter.active) {
        var buf: [64]u8 = undefined;
        const line = std.fmt.bufPrint(&buf, "FIGHT: {s} HP {d}  — [F] attack", .{
            cui.encounter.enemy.name,
            cui.encounter.enemy.hp,
        }) catch "FIGHT";
        gfx.drawText(line, 10, 410, backend.Color.rgb(255, 100, 90));
    } else if (cui.last_msg.len > 0) {
        gfx.drawText(cui.last_msg, 10, 410, backend.Color.rgb(200, 200, 120));
    }
}
