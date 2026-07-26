const std = @import("std");
const backend = @import("backend.zig");
const action = @import("../game/action.zig");
const player = @import("../game/player.zig");

pub const CombatUI = struct {
    encounter: action.Encounter = .{},
    cooldown: f64 = 0,
    last_msg: []const u8 = "",
    msg_ttl: f64 = 0,
};

pub fn maybeSpawn(cui: *CombatUI, p: player.Player, district_heat: u8, seed: u32) void {
    if (cui.encounter.active) return;
    if (cui.cooldown > 0) return;
    if (district_heat < 55) return;
    if (seed % 47 != 0) return;
    action.startEncounter(&cui.encounter, "Rival Enforcer", 28, 10, 4);
    cui.last_msg = "Street fight! [F] attack";
    cui.msg_ttl = 4.0;
    _ = p;
}

pub fn tick(cui: *CombatUI, p: *player.Player, dt: f64, attacking: bool) void {
    if (cui.cooldown > 0) cui.cooldown -= dt;
    if (cui.msg_ttl > 0) cui.msg_ttl -= dt;
    if (!cui.encounter.active) return;
    action.combatTick(&cui.encounter, p, dt, attacking);
    if (!cui.encounter.active) {
        cui.last_msg = "Enemy down.";
        cui.msg_ttl = 3.0;
        cui.cooldown = 20.0;
    } else if (p.health == 0) {
        cui.last_msg = "You went down.";
        cui.msg_ttl = 4.0;
        cui.encounter.active = false;
        cui.cooldown = 25.0;
    }
}

pub fn draw(gfx: backend.Backend, cui: CombatUI) void {
    if (cui.encounter.active) {
        var buf: [64]u8 = undefined;
        const line = std.fmt.bufPrint(&buf, "FIGHT: {s} HP {d}  [F]", .{
            cui.encounter.enemy.name,
            cui.encounter.enemy.hp,
        }) catch "FIGHT";
        gfx.drawText(line, 10, 430, backend.Color.rgb(255, 100, 90));
    } else if (cui.msg_ttl > 0 and cui.last_msg.len > 0) {
        gfx.drawText(cui.last_msg, 10, 430, backend.Color.rgb(200, 200, 120));
    }
}
