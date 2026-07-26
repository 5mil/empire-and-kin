const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");
const action = @import("../game/action.zig");

pub fn drawStars(gfx: backend.Backend, wanted: u8, x: i32, y: i32) void {
    var buf: [16]u8 = undefined;
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        buf[i] = if (i < wanted) '*' else '.';
    }
    const col = if (wanted >= 4) backend.Color.rgb(255, 50, 40)
        else if (wanted >= 2) backend.Color.rgb(255, 180, 40)
        else if (wanted >= 1) backend.Color.rgb(220, 220, 100)
        else backend.Color.rgb(100, 100, 100);
    gfx.drawText("WANTED", x, y, col);
    gfx.drawText(buf[0..5], x + 72, y, col);
}

pub fn drawPoliceBanner(gfx: backend.Backend, police: living.PoliceState, chase: action.ChaseState, y: i32) void {
    var buf: [96]u8 = undefined;
    if (chase.active) {
        const line = std.fmt.bufPrint(&buf, "PURSUIT d={d:.0} heat={d} - SPEED UP", .{ chase.distance, chase.pursuit_heat }) catch "PURSUIT";
        gfx.drawText(line, 10, y, backend.Color.rgb(255, 60, 50));
    } else if (chase.caught) {
        gfx.drawText("BUSTED - lost HP", 10, y, backend.Color.rgb(255, 80, 60));
    } else if (chase.escaped) {
        gfx.drawText("Escaped the heat", 10, y, backend.Color.rgb(120, 200, 120));
    } else if (police.alert_level >= 2) {
        const line = std.fmt.bufPrint(&buf, "Police: {s} (~{d} units)", .{ living.policeStatus(police), police.units_nearby }) catch "";
        gfx.drawText(line, 10, y, backend.Color.rgb(255, 160, 80));
    }
}

pub fn tickWanted(p: *player.Player, police: *living.PoliceState, chase: *action.ChaseState, district_heat: u8, period: living.Period, player_speed: f32, dt: f64, clock_elapsed: f64) void {
    living.updatePolice(police, district_heat, p.wanted_level, period, clock_elapsed);
    if (p.wanted_level >= 3 and !chase.active and !chase.caught) {
        action.startChase(chase, p.wanted_level);
    }
    if (chase.active) {
        action.tickChase(chase, player_speed, dt);
        if (chase.caught) {
            player.takeDamage(p, 15);
            if (p.wanted_level > 1) p.wanted_level -= 1;
        } else if (chase.escaped) {
            if (p.wanted_level > 0) p.wanted_level -= 1;
        }
    }
}

pub fn addWanted(p: *player.Player, amount: u8) void {
    p.wanted_level = @min(5, p.wanted_level + amount);
}
