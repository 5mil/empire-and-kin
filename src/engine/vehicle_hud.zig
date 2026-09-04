//! Phase 6 — on-foot HUD stays; driving shows analog-style instruments.
const std = @import("std");
const backend = @import("backend.zig");
const action = @import("../game/action.zig");
const telemetry = @import("../game/telemetry.zig");

pub fn draw(gfx: backend.Backend, car: action.Vehicle, screen_w: i32, screen_h: i32) void {
    if (!car.occupied) return;
    const tel = telemetry.sample(car);
    const white = backend.Color.rgb(245, 240, 230);
    const amber = backend.Color.rgb(255, 190, 70);
    const dim = backend.Color.rgb(150, 155, 165);
    const red = backend.Color.rgb(230, 80, 70);
    const green = backend.Color.rgb(90, 210, 130);

    var buf: [64]u8 = undefined;
    const cx = @divTrunc(screen_w, 2);
    const by = screen_h - 110;

    gfx.drawText(action.vehicleName(car.vtype), cx - 40, by - 8, dim);

    const spd = std.fmt.bufPrint(&buf, "{d:3.0} MPH", .{tel.speed_mph}) catch "MPH";
    gfx.drawText(spd, cx - 50, by + 16, white);

    const rpm_s = std.fmt.bufPrint(&buf, "RPM {d:4.0}", .{tel.rpm}) catch "RPM";
    gfx.drawText(rpm_s, cx - 50, by + 40, amber);

    const gear_s = std.fmt.bufPrint(&buf, "GEAR {s}", .{telemetry.gearLabel(tel.gear)}) catch "G";
    gfx.drawText(gear_s, cx + 80, by + 16, white);

    const slip_n: u8 = @intFromFloat(std.math.clamp(tel.slip * 100.0, 0.0, 100.0));
    const slip_col = if (tel.slip > 0.45) red else if (tel.slip > 0.2) amber else green;
    const slip_s = std.fmt.bufPrint(&buf, "SLIP {d}%", .{slip_n}) catch "SLIP";
    gfx.drawText(slip_s, cx + 80, by + 40, slip_col);

    const dmg_col = if (tel.damage > 40) red else dim;
    const dmg_s = std.fmt.bufPrint(&buf, "DMG {d}%  HP {d}", .{ tel.damage, car.health }) catch "DMG";
    gfx.drawText(dmg_s, cx - 50, by + 64, dmg_col);

    gfx.drawText("Shift handbrake   E exit", 20, screen_h - 28, backend.Color.rgb(110, 115, 130));
}
